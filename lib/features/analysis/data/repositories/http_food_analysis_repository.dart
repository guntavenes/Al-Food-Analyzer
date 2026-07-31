import 'package:ai_food_analyzer/features/analysis/data/datasources/food_analysis_remote_data_source.dart';
import 'package:ai_food_analyzer/features/analysis/data/models/analyze_food_request.dart';
import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';
import 'package:ai_food_analyzer/features/analysis/domain/repositories/food_analysis_repository.dart';

class HttpFoodAnalysisRepository implements FoodAnalysisRepository {
  const HttpFoodAnalysisRepository(this._remoteDataSource);

  final FoodAnalysisRemoteDataSource _remoteDataSource;

  @override
  Future<FoodAnalysis> analyzeFood(String imagePath) async {
    final response = await _remoteDataSource.analyzeFood(
      AnalyzeFoodRequest(imagePath: imagePath),
    );
    return response.toModel();
  }
}
