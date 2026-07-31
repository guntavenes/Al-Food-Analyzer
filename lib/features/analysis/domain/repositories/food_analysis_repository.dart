import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';

abstract interface class FoodAnalysisRepository {
  Future<FoodAnalysis> analyzeFood(String imagePath);
}
