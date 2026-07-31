import 'package:ai_food_analyzer/features/analysis/data/mappers/backend_error_mapper.dart';
import 'package:ai_food_analyzer/features/analysis/data/models/analyze_food_request.dart';
import 'package:ai_food_analyzer/features/analysis/data/models/food_analysis_response.dart';
import 'package:ai_food_analyzer/features/analysis/domain/errors/food_analysis_exception.dart';
import 'package:dio/dio.dart';

class FoodAnalysisRemoteDataSource {
  const FoodAnalysisRemoteDataSource(this._dio);

  final Dio _dio;

  Future<FoodAnalysisResponse> analyzeFood(AnalyzeFoodRequest request) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(request.imagePath),
        if (request.locale != null) 'locale': request.locale,
      });
      final response = await _dio.post<Map<String, Object?>>(
        '/v1/food/analyze',
        data: formData,
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
    } on Object {
      throw const FoodAnalysisException(FoodAnalysisErrorType.unknown);
    }
  }
}
