import 'package:ai_food_analyzer/features/analysis/data/datasources/food_analysis_data_source.dart';
import 'package:ai_food_analyzer/features/analysis/data/repositories/food_analysis_repository_impl.dart';
import 'package:ai_food_analyzer/features/analysis/presentation/providers/food_analysis_providers.dart';
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
}
