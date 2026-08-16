import 'dart:async';

import 'package:ai_food_analyzer/features/analysis/data/datasources/food_analysis_data_source.dart';
import 'package:ai_food_analyzer/features/analysis/data/mappers/backend_error_mapper.dart';
import 'package:ai_food_analyzer/features/analysis/data/models/food_analysis_model.dart';
import 'package:ai_food_analyzer/features/analysis/data/models/food_analysis_response.dart';
import 'package:ai_food_analyzer/features/analysis/data/repositories/food_analysis_repository_impl.dart';
import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';
import 'package:ai_food_analyzer/features/analysis/domain/errors/food_analysis_exception.dart';
import 'package:ai_food_analyzer/features/analysis/domain/repositories/food_analysis_repository.dart';
import 'package:ai_food_analyzer/features/analysis/presentation/pages/food_analysis_result_page.dart';
import 'package:ai_food_analyzer/features/analysis/presentation/providers/food_analysis_providers.dart';
import 'package:ai_food_analyzer/features/capture/presentation/pages/photo_preview_page.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const dataSource = FakeFoodAnalysisDataSource(responseDelay: Duration.zero);

  test('fake repository returns the expected nutrition values', () async {
    const repository = FoodAnalysisRepositoryImpl(dataSource);

    final result = await repository.analyzeFood('/tmp/meal.jpg');

    expect(result.calories, 540);
    expect(result.proteinGrams, 32);
    expect(result.fatGrams, 18);
    expect(result.carbsGrams, 56);
    expect(result.fiberGrams, 7);
    expect(result.confidencePercent, 87);
    expect(result.foodName, 'Grilled Chicken Bowl');
    expect(result.servingDescription, '1 medium serving');
  });

  test('provider exposes the fake repository response', () async {
    final container = ProviderContainer(
      overrides: [
        foodAnalysisRepositoryProvider.overrideWithValue(
          const FoodAnalysisRepositoryImpl(dataSource),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      foodAnalysisProvider('/tmp/meal.jpg').future,
    );

    expect(result.calories, 540);
    expect(result.proteinGrams, 32);
    expect(result.fatGrams, 18);
    expect(result.carbsGrams, 56);
  });

  test('model preserves all analysis fields during JSON conversion', () {
    const model = FoodAnalysisModel(
      foodName: 'Grilled Chicken Bowl',
      calories: 540,
      proteinGrams: 32,
      fatGrams: 18,
      carbsGrams: 56,
      fiberGrams: 7,
      confidencePercent: 87,
      servingDescription: '1 medium serving',
      description: 'Balanced meal.',
    );

    final decoded = FoodAnalysisModel.fromJson(model.toJson());

    expect(decoded.foodName, model.foodName);
    expect(decoded.fiberGrams, model.fiberGrams);
    expect(decoded.confidencePercent, model.confidencePercent);
    expect(decoded.description, model.description);
  });

  testWidgets('preview shows a retry action when analysis fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          foodAnalysisRepositoryProvider.overrideWithValue(
            const FoodAnalysisRepositoryImpl(_FailingFoodAnalysisDataSource()),
          ),
        ],
        child: const _LocalizedTestApp(
          home: PhotoPreviewPage(imagePath: '/missing/meal.jpg'),
        ),
      ),
    );

    await tester.tap(find.text('Analyze Food'));
    await tester.pumpAndSettle();

    expect(
      find.text('Analysis could not be completed. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rapid Analyze taps send only one request', (tester) async {
    final repository = _BlockingFoodAnalysisRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          foodAnalysisRepositoryProvider.overrideWithValue(repository),
        ],
        child: const _LocalizedTestApp(
          home: PhotoPreviewPage(imagePath: '/missing/meal.jpg'),
        ),
      ),
    );

    final analyzeButton = find.text('Analyze Food');
    await tester.tap(analyzeButton);
    await tester.tap(analyzeButton);
    await tester.pump();

    expect(repository.callCount, 1);
    repository.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('HTTP response DTO maps backend fields to the domain model', () {
    final response = FoodAnalysisResponse.fromJson({
      'requestId': 'request-id',
      'foodName': 'Grilled Chicken Bowl',
      'calories': 540,
      'protein': 32,
      'carbohydrates': 56,
      'fat': 18,
      'fiber': 7,
      'confidence': 0.87,
      'servingDescription': '1 medium serving',
      'analysisDescription': 'Balanced meal.',
      'warnings': <Object?>[],
      'isFoodDetected': true,
    });

    final model = response.toModel();
    expect(model.confidencePercent, 87);
    expect(model.carbsGrams, 56);
  });

  test('no-food HTTP response maps to a controlled domain error', () {
    final response = FoodAnalysisResponse.fromJson({
      'requestId': 'request-id',
      'foodName': null,
      'calories': null,
      'protein': null,
      'carbohydrates': null,
      'fat': null,
      'fiber': null,
      'confidence': 0,
      'servingDescription': null,
      'analysisDescription': 'No food detected.',
      'warnings': <Object?>[],
      'isFoodDetected': false,
    });

    expect(
      response.toModel,
      throwsA(
        isA<FoodAnalysisException>().having(
          (error) => error.type,
          'type',
          FoodAnalysisErrorType.noFoodDetected,
        ),
      ),
    );
  });

  test('backend rate limit errors map to a domain error', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/v1/food/analyze'),
      response: Response<Map<String, Object?>>(
        requestOptions: RequestOptions(path: '/v1/food/analyze'),
        statusCode: 429,
        data: {
          'error': <String, Object?>{
            'code': 'RATE_LIMITED',
            'message': 'Too many requests.',
          },
        },
      ),
    );

    expect(
      BackendErrorMapper.fromDioException(error).type,
      FoodAnalysisErrorType.rateLimited,
    );
  });

  test(
    'same analysis provider prevents duplicate concurrent requests',
    () async {
      final repository = _CountingFoodAnalysisRepository();
      final container = ProviderContainer(
        overrides: [
          foodAnalysisRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final provider = foodAnalysisProvider('/tmp/meal.jpg');
      final subscription = container.listen(provider, (previous, next) {});
      addTearDown(subscription.close);

      await Future.wait([
        container.read(provider.future),
        container.read(provider.future),
      ]);

      expect(repository.callCount, 1);
    },
  );

  testWidgets('result content fits a small phone using scrolling', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: _LocalizedTestApp(
          home: FoodAnalysisResultPage(
            arguments: FoodAnalysisResultArguments(
              imagePath: '/missing/meal.jpg',
              analysis: FoodAnalysis(
                foodName: 'Grilled Chicken Bowl',
                calories: 540,
                proteinGrams: 32,
                fatGrams: 18,
                carbsGrams: 56,
                fiberGrams: 7,
                confidencePercent: 87,
                servingDescription: '1 medium serving',
                description: 'Balanced meal.',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Grilled Chicken Bowl'), findsOneWidget);
    expect(find.text('540 kcal'), findsOneWidget);
    expect(find.text('32 g'), findsOneWidget);
    expect(find.text('%87'), findsOneWidget);
    expect(find.text('Analyze Another Meal'), findsOneWidget);
    expect(find.text('Save Result'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _CountingFoodAnalysisRepository implements FoodAnalysisRepository {
  int callCount = 0;

  @override
  Future<FoodAnalysis> analyzeFood(String imagePath) async {
    callCount += 1;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return const FoodAnalysis(
      foodName: 'Meal',
      calories: 1,
      proteinGrams: 1,
      fatGrams: 1,
      carbsGrams: 1,
      fiberGrams: 1,
      confidencePercent: 100,
      servingDescription: '1 serving',
      description: 'Description',
    );
  }
}

class _BlockingFoodAnalysisRepository implements FoodAnalysisRepository {
  final Completer<FoodAnalysis> _completer = Completer<FoodAnalysis>();
  int callCount = 0;

  @override
  Future<FoodAnalysis> analyzeFood(String imagePath) {
    callCount += 1;
    return _completer.future;
  }

  void complete() {
    _completer.complete(
      const FoodAnalysis(
        foodName: 'Meal',
        calories: 1,
        proteinGrams: 1,
        fatGrams: 1,
        carbsGrams: 1,
        fiberGrams: 1,
        confidencePercent: 100,
        servingDescription: '1 serving',
        description: 'Description',
      ),
    );
  }
}

class _FailingFoodAnalysisDataSource implements FoodAnalysisDataSource {
  const _FailingFoodAnalysisDataSource();

  @override
  Future<FoodAnalysisModel> analyzeFood(String imagePath) {
    return Future<FoodAnalysisModel>.error(Exception('Analysis failed.'));
  }
}

class _LocalizedTestApp extends StatelessWidget {
  const _LocalizedTestApp({required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }
}
