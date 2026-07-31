import 'package:ai_food_analyzer/features/analysis/data/datasources/food_analysis_data_source.dart';
import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';
import 'package:ai_food_analyzer/features/analysis/domain/repositories/food_analysis_repository.dart';

class FoodAnalysisRepositoryImpl implements FoodAnalysisRepository {
  const FoodAnalysisRepositoryImpl(this._dataSource);

  final FoodAnalysisDataSource _dataSource;

  @override
  Future<FoodAnalysis> analyzeFood(String imagePath) {
    return _dataSource.analyzeFood(imagePath);
  }
}
