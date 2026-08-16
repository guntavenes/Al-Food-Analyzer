class AnalyzeFoodRequest {
  const AnalyzeFoodRequest({
    required this.imagePath,
    this.locale,
    this.ingredients,
    this.servingDescription,
  });

  final String imagePath;
  final String? locale;
  final String? ingredients;
  final String? servingDescription;
}
