class DetectedFood {
  const DetectedFood({
    required this.name,
    required this.estimatedWeightGrams,
    required this.calories,
    required this.confidencePercent,
  });

  final String name;
  final int estimatedWeightGrams;
  final int calories;
  final int confidencePercent;
}

class FoodAnalysis {
  const FoodAnalysis({
    required this.foodName,
    required this.calories,
    required this.proteinGrams,
    required this.fatGrams,
    required this.carbsGrams,
    required this.fiberGrams,
    required this.confidencePercent,
    required this.servingDescription,
    required this.description,
    this.sugarGrams = 0,
    this.sodiumMilligrams = 0,
    this.servingWeightGrams = 0,
    this.healthScore = 0,
    this.warnings = const [],
    this.detectedFoods = const [],
  });

  final String foodName;
  final int calories;
  final int proteinGrams;
  final int fatGrams;
  final int carbsGrams;
  final int fiberGrams;
  final int confidencePercent;
  final String servingDescription;
  final String description;
  final int sugarGrams;
  final int sodiumMilligrams;
  final int servingWeightGrams;
  final int healthScore;
  final List<String> warnings;
  final List<DetectedFood> detectedFoods;
}
