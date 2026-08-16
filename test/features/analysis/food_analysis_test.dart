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

  test('calorie range widens conservatively when confidence is lower', () {
    const higherConfidence = FoodAnalysis(
      foodName: 'Meal',
      calories: 800,
      proteinGrams: 20,
      fatGrams: 30,
      carbsGrams: 100,
      fiberGrams: 5,
      confidencePercent: 90,
      servingDescription: 'Entire plate',
      description: 'Estimate',
    );
    const lowerConfidence = FoodAnalysis(
      foodName: 'Meal',
      calories: 800,
      proteinGrams: 20,
      fatGrams: 30,
      carbsGrams: 100,
      fiberGrams: 5,
      confidencePercent: 65,
      servingDescription: 'Entire plate',
      description: 'Estimate',
    );

    expect(higherConfidence.minimumEstimatedCalories, 720);
    expect(higherConfidence.maximumEstimatedCalories, 880);
    expect(higherConfidence.needsIngredientConfirmation, isFalse);
    expect(lowerConfidence.minimumEstimatedCalories, 670);
    expect(lowerConfidence.maximumEstimatedCalories, 930);
    expect(lowerConfidence.needsIngredientConfirmation, isTrue);
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
      'sugar': 8,
      'sodium': 720,
      'confidence': 0.87,
      'servingDescription': '1 medium serving',
      'servingWeightGrams': 420,
      'healthScore': 78,
      'analysisDescription': 'Balanced meal.',
      'warnings': <Object?>['Sauce amount is estimated.'],
      'detectedFoods': <Object?>[
        <String, Object?>{
          'name': 'Chicken',
          'estimatedWeightGrams': 160,
          'calories': 260,
          'confidence': 0.92,
        },
      ],
      'isFoodDetected': true,
    });

    final model = response.toModel();
    expect(model.confidencePercent, 87);
    expect(model.carbsGrams, 56);
    expect(model.sugarGrams, 8);
    expect(model.sodiumMilligrams, 720);
    expect(model.servingWeightGrams, 420);
    expect(model.healthScore, 78);
    expect(model.warnings, ['Sauce amount is estimated.']);
    expect(model.detectedFoods.single.name, 'Chicken');
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

  test('backend unauthorized errors map to a secure-session error', () {
    final requestOptions = RequestOptions(path: '/v1/food/analyze');
    final error = DioException(
      requestOptions: requestOptions,
      response: Response<Map<String, Object?>>(
        requestOptions: requestOptions,
        statusCode: 401,
        data: {
          'error': <String, Object?>{
            'code': 'UNAUTHORIZED',
            'message': 'A valid user session is required.',
          },
        },
      ),
    );

    expect(
      BackendErrorMapper.fromDioException(error).type,
      FoodAnalysisErrorType.unauthorized,
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

  test('failed analysis is not retried automatically', () async {
    final repository = _FailingFoodAnalysisRepository();
    final container = ProviderContainer(
      overrides: [foodAnalysisRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final provider = foodAnalysisProvider('/tmp/meal.jpg');
    final subscription = container.listen(provider, (previous, next) {});
    addTearDown(subscription.close);

    await expectLater(container.read(provider.future), throwsException);
    await Future<void>.delayed(const Duration(seconds: 1));

    expect(repository.callCount, 1);
  });

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
    expect(find.text('480–600 kcal'), findsOneWidget);
    expect(find.text('Central estimate: 540 kcal'), findsOneWidget);
    expect(find.text('Confirm the ingredients'), findsOneWidget);
    expect(find.text('32 g'), findsOneWidget);
    expect(find.text('%87'), findsOneWidget);
    expect(find.text('Analyze Another Meal'), findsOneWidget);
    expect(find.text('Save Result'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('user can submit corrected ingredients for reanalysis', (
    tester,
  ) async {
    final repository = _CorrectionCapturingRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          foodAnalysisRepositoryProvider.overrideWithValue(repository),
        ],
        child: const _LocalizedTestApp(
          home: FoodAnalysisResultPage(
            arguments: FoodAnalysisResultArguments(
              imagePath: '/missing/meal.jpg',
              analysis: FoodAnalysis(
                foodName: 'Ambiguous meal',
                calories: 700,
                proteinGrams: 20,
                fatGrams: 30,
                carbsGrams: 90,
                fiberGrams: 5,
                confidencePercent: 65,
                servingDescription: '6 pieces',
                description: 'Estimate.',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Edit and analyze again'));
    await tester.tap(find.text('Edit and analyze again'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Main ingredients'),
      'ground beef and bread',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Total serving'),
      '6 pieces and one bowl of salsa',
    );
    await tester.tap(find.text('Recalculate'));
    await tester.pumpAndSettle();

    expect(repository.correction?.ingredients, 'ground beef and bread');
    expect(
      repository.correction?.servingDescription,
      '6 pieces and one bowl of salsa',
    );
  });
}

class _CountingFoodAnalysisRepository implements FoodAnalysisRepository {
  int callCount = 0;

  @override
  Future<FoodAnalysis> analyzeFood(
    String imagePath, {
    FoodAnalysisCorrection? correction,
  }) async {
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

class _FailingFoodAnalysisRepository implements FoodAnalysisRepository {
  int callCount = 0;

  @override
  Future<FoodAnalysis> analyzeFood(
    String imagePath, {
    FoodAnalysisCorrection? correction,
  }) {
    callCount += 1;
    return Future<FoodAnalysis>.error(Exception('Analysis failed.'));
  }
}

class _BlockingFoodAnalysisRepository implements FoodAnalysisRepository {
  final Completer<FoodAnalysis> _completer = Completer<FoodAnalysis>();
  int callCount = 0;

  @override
  Future<FoodAnalysis> analyzeFood(
    String imagePath, {
    FoodAnalysisCorrection? correction,
  }) {
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

class _CorrectionCapturingRepository implements FoodAnalysisRepository {
  FoodAnalysisCorrection? correction;

  @override
  Future<FoodAnalysis> analyzeFood(
    String imagePath, {
    FoodAnalysisCorrection? correction,
  }) {
    this.correction = correction;
    return Future<FoodAnalysis>.error(Exception('Stop after capture'));
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
