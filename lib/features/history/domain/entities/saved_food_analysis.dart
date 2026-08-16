import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';

class SavedFoodAnalysis extends FoodAnalysis {
  const SavedFoodAnalysis({
    required this.id,
    required this.imagePath,
    required this.createdAt,
    required super.foodName,
    required super.calories,
    required super.proteinGrams,
    required super.fatGrams,
    required super.carbsGrams,
    required super.fiberGrams,
    required super.confidencePercent,
    required super.servingDescription,
    required super.description,
    super.sugarGrams,
    super.sodiumMilligrams,
    super.servingWeightGrams,
    super.healthScore,
    super.warnings,
    super.detectedFoods,
  });

  final int id;
  final String imagePath;
  final DateTime createdAt;
}
