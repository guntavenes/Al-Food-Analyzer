import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';

class FoodAnalysisModel extends FoodAnalysis {
  const FoodAnalysisModel({
    required super.calories,
    required super.proteinGrams,
    required super.fatGrams,
    required super.carbsGrams,
  });

  factory FoodAnalysisModel.fromJson(Map<String, Object?> json) {
    return FoodAnalysisModel(
      calories: json['calories']! as int,
      proteinGrams: json['proteinGrams']! as int,
      fatGrams: json['fatGrams']! as int,
      carbsGrams: json['carbsGrams']! as int,
    );
  }

  Map<String, Object> toJson() {
    return {
      'calories': calories,
      'proteinGrams': proteinGrams,
      'fatGrams': fatGrams,
      'carbsGrams': carbsGrams,
    };
  }
}
