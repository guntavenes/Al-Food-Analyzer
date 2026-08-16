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
    super.sugarGrams,
    super.sodiumMilligrams,
    super.servingWeightGrams,
    super.healthScore,
    super.warnings,
    super.detectedFoods,
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
      sugarGrams: (json['sugarGrams'] as int?) ?? 0,
      sodiumMilligrams: (json['sodiumMilligrams'] as int?) ?? 0,
      servingWeightGrams: (json['servingWeightGrams'] as int?) ?? 0,
      healthScore: (json['healthScore'] as int?) ?? 0,
      warnings: ((json['warnings'] as List<Object?>?) ?? const [])
          .cast<String>(),
      detectedFoods: ((json['detectedFoods'] as List<Object?>?) ?? const [])
          .map((item) {
            final value = item! as Map<String, Object?>;
            return DetectedFood(
              name: value['name']! as String,
              estimatedWeightGrams: value['estimatedWeightGrams']! as int,
              calories: value['calories']! as int,
              confidencePercent: value['confidencePercent']! as int,
            );
          })
          .toList(growable: false),
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
      'sugarGrams': sugarGrams,
      'sodiumMilligrams': sodiumMilligrams,
      'servingWeightGrams': servingWeightGrams,
      'healthScore': healthScore,
      'warnings': warnings,
      'detectedFoods': detectedFoods
          .map(
            (food) => <String, Object>{
              'name': food.name,
              'estimatedWeightGrams': food.estimatedWeightGrams,
              'calories': food.calories,
              'confidencePercent': food.confidencePercent,
            },
          )
          .toList(growable: false),
    };
  }
}
