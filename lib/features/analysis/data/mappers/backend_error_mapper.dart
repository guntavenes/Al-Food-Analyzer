import 'package:ai_food_analyzer/features/analysis/domain/errors/food_analysis_exception.dart';
import 'package:dio/dio.dart';

abstract final class BackendErrorMapper {
  static FoodAnalysisException fromDioException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const FoodAnalysisException(FoodAnalysisErrorType.timeout);
    }
    if (error.type == DioExceptionType.connectionError) {
      return const FoodAnalysisException(FoodAnalysisErrorType.network);
    }

    final data = error.response?.data;
    final errorData = data is Map<String, Object?> ? data['error'] : null;
    final details = errorData is Map<String, Object?> ? errorData : null;
    final code = details?['code'] as String?;
    final message = details?['message'] as String?;

    return FoodAnalysisException(switch (code) {
      'INVALID_IMAGE' ||
      'UNSUPPORTED_IMAGE_TYPE' => FoodAnalysisErrorType.invalidImage,
      'IMAGE_TOO_LARGE' => FoodAnalysisErrorType.imageTooLarge,
      'UNAUTHORIZED' => FoodAnalysisErrorType.unauthorized,
      'PREMIUM_REQUIRED' => FoodAnalysisErrorType.premiumRequired,
      'RATE_LIMITED' => FoodAnalysisErrorType.rateLimited,
      'SERVICE_UNAVAILABLE' => FoodAnalysisErrorType.serviceUnavailable,
      'ANALYSIS_FAILED' => FoodAnalysisErrorType.serviceUnavailable,
      _ => FoodAnalysisErrorType.unknown,
    }, message);
  }
}
