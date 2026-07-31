import 'package:ai_food_analyzer/features/analysis/data/models/food_analysis_model.dart';

abstract interface class FoodAnalysisDataSource {
  Future<FoodAnalysisModel> analyzeFood(String imagePath);
}

class FakeFoodAnalysisDataSource implements FoodAnalysisDataSource {
  const FakeFoodAnalysisDataSource({
    this.responseDelay = const Duration(milliseconds: 700),
  });

  final Duration responseDelay;

  @override
  Future<FoodAnalysisModel> analyzeFood(String imagePath) async {
    if (imagePath.trim().isEmpty) {
      throw ArgumentError.value(imagePath, 'imagePath', 'Must not be empty.');
    }

    await Future<void>.delayed(responseDelay);

    return const FoodAnalysisModel(
      calories: 540,
      proteinGrams: 32,
      fatGrams: 18,
      carbsGrams: 56,
    );
  }
}
