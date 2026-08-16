import 'package:ai_food_analyzer/core/auth/access_token_provider.dart';
import 'package:ai_food_analyzer/features/analysis/data/mappers/backend_error_mapper.dart';
import 'package:ai_food_analyzer/features/analysis/data/models/analyze_food_request.dart';
import 'package:ai_food_analyzer/features/analysis/data/models/food_analysis_response.dart';
import 'package:ai_food_analyzer/features/analysis/domain/errors/food_analysis_exception.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide MultipartFile;

class FoodAnalysisRemoteDataSource {
  const FoodAnalysisRemoteDataSource(this._dio, this._accessTokenProvider);

  final Dio _dio;
  final AccessTokenProvider _accessTokenProvider;

  Future<FoodAnalysisResponse> analyzeFood(AnalyzeFoodRequest request) async {
    try {
      final accessToken = await _accessTokenProvider.getAccessToken();
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(request.imagePath),
        if (request.locale != null) 'locale': request.locale,
        if (request.ingredients != null) 'ingredients': request.ingredients,
        if (request.servingDescription != null)
          'servingDescription': request.servingDescription,
      });
      final response = await _dio.post<Map<String, Object?>>(
        '/v1/food/analyze',
        data: formData,
        options: Options(
          headers: {
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      final data = response.data;
      if (data == null) {
        throw const FoodAnalysisException(FoodAnalysisErrorType.unknown);
      }
      return FoodAnalysisResponse.fromJson(data);
    } on DioException catch (error) {
      throw BackendErrorMapper.fromDioException(error);
    } on FoodAnalysisException {
      rethrow;
    } on AuthException {
      throw const FoodAnalysisException(FoodAnalysisErrorType.unauthorized);
    } on Object {
      throw const FoodAnalysisException(FoodAnalysisErrorType.unknown);
    }
  }
}
