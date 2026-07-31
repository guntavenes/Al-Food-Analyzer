import 'package:ai_food_analyzer/features/analysis/data/datasources/food_analysis_data_source.dart';
import 'package:ai_food_analyzer/features/analysis/data/models/food_analysis_model.dart';
import 'package:ai_food_analyzer/features/analysis/data/repositories/food_analysis_repository_impl.dart';
import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';
import 'package:ai_food_analyzer/features/analysis/presentation/pages/food_analysis_result_page.dart';
import 'package:ai_food_analyzer/features/analysis/presentation/providers/food_analysis_providers.dart';
import 'package:ai_food_analyzer/features/capture/presentation/pages/photo_preview_page.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
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
      overrides: [foodAnalysisDataSourceProvider.overrideWithValue(dataSource)],
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
          foodAnalysisDataSourceProvider.overrideWithValue(
            const _FailingFoodAnalysisDataSource(),
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
