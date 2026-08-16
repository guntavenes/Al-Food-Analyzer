import 'package:ai_food_analyzer/features/analysis/data/datasources/food_analysis_remote_data_source.dart';
import 'package:ai_food_analyzer/features/analysis/data/models/analyze_food_request.dart';
import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';
import 'package:ai_food_analyzer/features/analysis/domain/repositories/food_analysis_repository.dart';

class HttpFoodAnalysisRepository implements FoodAnalysisRepository {
  const HttpFoodAnalysisRepository(
    this._remoteDataSource, {
    required this.locale,
  });

  final FoodAnalysisRemoteDataSource _remoteDataSource;
  final String locale;

  @override
  Future<FoodAnalysis> analyzeFood(
    String imagePath, {
    FoodAnalysisCorrection? correction,
  }) async {
    final response = await _remoteDataSource.analyzeFood(
      AnalyzeFoodRequest(
        imagePath: imagePath,
        locale: locale,
        ingredients: correction?.ingredients,
        servingDescription: correction?.servingDescription,
      ),
    );
    return response.toModel();
  }
}
