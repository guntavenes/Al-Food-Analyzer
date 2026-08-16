import 'package:ai_food_analyzer/features/history/domain/entities/saved_food_analysis.dart';

class SavedFoodAnalysisModel extends SavedFoodAnalysis {
  const SavedFoodAnalysisModel({
    required super.id,
    required super.imagePath,
    required super.createdAt,
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
}
