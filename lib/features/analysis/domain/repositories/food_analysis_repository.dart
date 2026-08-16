import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';

abstract interface class FoodAnalysisRepository {
  Future<FoodAnalysis> analyzeFood(
    String imagePath, {
    FoodAnalysisCorrection? correction,
  });
}

class FoodAnalysisCorrection {
  const FoodAnalysisCorrection({
    required this.ingredients,
    required this.servingDescription,
  });

  final String ingredients;
  final String servingDescription;
}
