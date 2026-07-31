import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';

class FoodAnalysisModel extends FoodAnalysis {
  const FoodAnalysisModel({
    required super.foodName,
    required super.calories,
    required super.proteinGrams,
    required super.fatGrams,
    required super.carbsGrams,
    required super.fiberGrams,
    required super.confidencePercent,
    required super.servingDescription,
    required super.description,
  });

  factory FoodAnalysisModel.fromJson(Map<String, Object?> json) {
    return FoodAnalysisModel(
      foodName: json['foodName']! as String,
      calories: json['calories']! as int,
      proteinGrams: json['proteinGrams']! as int,
      fatGrams: json['fatGrams']! as int,
      carbsGrams: json['carbsGrams']! as int,
      fiberGrams: json['fiberGrams']! as int,
      confidencePercent: json['confidencePercent']! as int,
      servingDescription: json['servingDescription']! as String,
      description: json['description']! as String,
    );
  }

  Map<String, Object> toJson() {
    return {
      'foodName': foodName,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'fatGrams': fatGrams,
      'carbsGrams': carbsGrams,
      'fiberGrams': fiberGrams,
      'confidencePercent': confidencePercent,
      'servingDescription': servingDescription,
      'description': description,
    };
  }
}
