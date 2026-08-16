enum FoodAnalysisErrorType {
  noFoodDetected,
  invalidImage,
  imageTooLarge,
  unauthorized,
  rateLimited,
  timeout,
  network,
  serviceUnavailable,
  unknown,
}

class FoodAnalysisException implements Exception {
  const FoodAnalysisException(this.type, [this.message]);

  final FoodAnalysisErrorType type;
  final String? message;
}
