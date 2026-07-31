import 'package:ai_food_analyzer/features/analysis/data/models/food_analysis_model.dart';
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
    required this.confidence,
    required this.servingDescription,
    required this.analysisDescription,
    required this.warnings,
    required this.isFoodDetected,
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
      confidence: (json['confidence']! as num).toDouble(),
      servingDescription: json['servingDescription'] as String?,
      analysisDescription: json['analysisDescription']! as String,
      warnings: (json['warnings']! as List<Object?>).cast<String>(),
      isFoodDetected: json['isFoodDetected']! as bool,
    );
  }

  final String requestId;
  final String? foodName;
  final int? calories;
  final int? protein;
  final int? carbohydrates;
  final int? fat;
  final int? fiber;
  final double confidence;
  final String? servingDescription;
  final String analysisDescription;
  final List<String> warnings;
  final bool isFoodDetected;

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
    );
  }
}
