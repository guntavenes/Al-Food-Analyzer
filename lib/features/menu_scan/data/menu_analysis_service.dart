import 'package:ai_food_analyzer/core/auth/access_token_provider.dart';
import 'package:ai_food_analyzer/features/analysis/data/mappers/backend_error_mapper.dart';
import 'package:ai_food_analyzer/features/analysis/domain/errors/food_analysis_exception.dart';
import 'package:ai_food_analyzer/features/menu_scan/domain/menu_analysis.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide MultipartFile;

class MenuAnalysisService {
  const MenuAnalysisService(this._dio, this._accessTokenProvider);

  final Dio _dio;
  final AccessTokenProvider _accessTokenProvider;

  Future<MenuAnalysis> analyze({
    required String imagePath,
    required String locale,
  }) async {
    try {
      final token = await _accessTokenProvider.getAccessToken();
      final response = await _dio.post<Map<String, Object?>>(
        '/v1/menu/analyze',
        data: FormData.fromMap({
          'image': await MultipartFile.fromFile(imagePath),
          'locale': locale,
        }),
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );
      if (response.data == null) {
        throw const FoodAnalysisException(FoodAnalysisErrorType.unknown);
      }
      return MenuAnalysis.fromJson(response.data!);
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
