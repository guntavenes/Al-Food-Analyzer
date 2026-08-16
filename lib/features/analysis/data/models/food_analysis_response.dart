import 'package:ai_food_analyzer/features/analysis/data/models/food_analysis_model.dart';
import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';
import 'package:ai_food_analyzer/features/analysis/domain/errors/food_analysis_exception.dart';

class FoodAnalysisResponse {
  const FoodAnalysisResponse({
    required this.requestId,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.confidence,
    required this.servingDescription,
    required this.servingWeightGrams,
    required this.healthScore,
    required this.analysisDescription,
    required this.warnings,
    required this.isFoodDetected,
    required this.detectedFoods,
  });

  factory FoodAnalysisResponse.fromJson(Map<String, Object?> json) {
    return FoodAnalysisResponse(
      requestId: json['requestId']! as String,
      foodName: json['foodName'] as String?,
      calories: (json['calories'] as num?)?.round(),
      protein: (json['protein'] as num?)?.round(),
      carbohydrates: (json['carbohydrates'] as num?)?.round(),
      fat: (json['fat'] as num?)?.round(),
      fiber: (json['fiber'] as num?)?.round(),
      sugar: (json['sugar'] as num?)?.round(),
      sodium: (json['sodium'] as num?)?.round(),
      confidence: (json['confidence']! as num).toDouble(),
      servingDescription: json['servingDescription'] as String?,
      servingWeightGrams: (json['servingWeightGrams'] as num?)?.round(),
      healthScore: (json['healthScore'] as num?)?.round(),
      analysisDescription: json['analysisDescription']! as String,
      warnings: (json['warnings']! as List<Object?>).cast<String>(),
      isFoodDetected: json['isFoodDetected']! as bool,
      detectedFoods: ((json['detectedFoods'] as List<Object?>?) ?? const [])
          .map(
            (item) =>
                DetectedFoodResponse.fromJson(item! as Map<String, Object?>),
          )
          .toList(growable: false),
    );
  }

  final String requestId;
  final String? foodName;
  final int? calories;
  final int? protein;
  final int? carbohydrates;
  final int? fat;
  final int? fiber;
  final int? sugar;
  final int? sodium;
  final double confidence;
  final String? servingDescription;
  final int? servingWeightGrams;
  final int? healthScore;
  final String analysisDescription;
  final List<String> warnings;
  final bool isFoodDetected;
  final List<DetectedFoodResponse> detectedFoods;

  FoodAnalysisModel toModel() {
    if (!isFoodDetected) {
      throw FoodAnalysisException(
        FoodAnalysisErrorType.noFoodDetected,
        analysisDescription,
      );
    }

    return FoodAnalysisModel(
      foodName: foodName!,
      calories: calories!,
      proteinGrams: protein!,
      fatGrams: fat!,
      carbsGrams: carbohydrates!,
      fiberGrams: fiber!,
      confidencePercent: (confidence * 100).round(),
      servingDescription: servingDescription!,
      description: analysisDescription,
      sugarGrams: sugar!,
      sodiumMilligrams: sodium!,
      servingWeightGrams: servingWeightGrams!,
      healthScore: healthScore!,
      warnings: warnings,
      detectedFoods: detectedFoods
          .map((food) => food.toEntity())
          .toList(growable: false),
    );
  }
}

class DetectedFoodResponse {
  const DetectedFoodResponse({
    required this.name,
    required this.estimatedWeightGrams,
    required this.calories,
    required this.confidence,
  });

  factory DetectedFoodResponse.fromJson(Map<String, Object?> json) {
    return DetectedFoodResponse(
      name: json['name']! as String,
      estimatedWeightGrams: (json['estimatedWeightGrams']! as num).round(),
      calories: (json['calories']! as num).round(),
      confidence: (json['confidence']! as num).toDouble(),
    );
  }

  final String name;
  final int estimatedWeightGrams;
  final int calories;
  final double confidence;

  DetectedFood toEntity() => DetectedFood(
    name: name,
    estimatedWeightGrams: estimatedWeightGrams,
    calories: calories,
    confidencePercent: (confidence * 100).round(),
  );
}
