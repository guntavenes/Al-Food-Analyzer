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
}
