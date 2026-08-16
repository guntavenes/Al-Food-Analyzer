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

  /// A conservative display range derived from the model's confidence.
  ///
  /// Image-only nutrition analysis cannot know hidden ingredients or exact
  /// portion weights. Keeping the range derived from persisted fields means
  /// saved analyses continue to show the same uncertainty without a database
  /// migration.
  int get minimumEstimatedCalories => _roundedCalorieBound(isLower: true);

  int get maximumEstimatedCalories => _roundedCalorieBound(isLower: false);

  bool get needsIngredientConfirmation => confidencePercent < 90;

  int _roundedCalorieBound({required bool isLower}) {
    final boundedConfidence = confidencePercent.clamp(0, 100);
    final uncertainty = (0.08 + ((100 - boundedConfidence) * 0.0025)).clamp(
      0.08,
      0.25,
    );
    final multiplier = isLower ? 1 - uncertainty : 1 + uncertainty;
    final estimate = calories * multiplier;
    return ((estimate / 10).round() * 10).clamp(0, 1000000);
  }
}
