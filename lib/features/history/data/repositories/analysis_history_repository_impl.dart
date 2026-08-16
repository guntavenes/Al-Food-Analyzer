import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';
import 'package:ai_food_analyzer/features/history/data/datasources/analysis_history_local_data_source.dart';
import 'package:ai_food_analyzer/features/history/data/datasources/analysis_image_local_data_source.dart';
import 'package:ai_food_analyzer/features/history/data/models/saved_food_analysis_model.dart';
import 'package:ai_food_analyzer/features/history/domain/entities/saved_food_analysis.dart';
import 'package:ai_food_analyzer/features/history/domain/repositories/analysis_history_repository.dart';

class AnalysisHistoryRepositoryImpl implements AnalysisHistoryRepository {
  const AnalysisHistoryRepositoryImpl(this._localDataSource, this._imageStore);

  final AnalysisHistoryLocalDataSource _localDataSource;
  final AnalysisImageLocalDataSource _imageStore;

  @override
  Future<int> saveAnalysis({
    required FoodAnalysis analysis,
    required String sourceImagePath,
  }) async {
    final persistentImagePath = await _imageStore.persistImage(sourceImagePath);

    try {
      return await _localDataSource.insertAnalysis(
        SavedFoodAnalysisModel(
          id: 0,
          foodName: analysis.foodName,
          calories: analysis.calories,
          proteinGrams: analysis.proteinGrams,
          carbsGrams: analysis.carbsGrams,
          fatGrams: analysis.fatGrams,
          fiberGrams: analysis.fiberGrams,
          confidencePercent: analysis.confidencePercent,
          servingDescription: analysis.servingDescription,
          description: analysis.description,
          sugarGrams: analysis.sugarGrams,
          sodiumMilligrams: analysis.sodiumMilligrams,
          servingWeightGrams: analysis.servingWeightGrams,
          healthScore: analysis.healthScore,
          warnings: analysis.warnings,
          detectedFoods: analysis.detectedFoods,
          imagePath: persistentImagePath,
          createdAt: DateTime.now().toUtc(),
        ),
      );
    } on Object {
      await _imageStore.deleteImage(persistentImagePath);
      rethrow;
    }
  }

  @override
  Future<List<SavedFoodAnalysis>> getAllAnalyses() {
    return _localDataSource.getAllAnalyses();
  }

  @override
  Stream<List<SavedFoodAnalysis>> watchAnalyses() {
    return _localDataSource.watchAnalyses();
  }

  @override
  Future<SavedFoodAnalysis?> getAnalysis(int id) {
    return _localDataSource.getAnalysis(id);
  }

  @override
  Future<void> deleteAnalysis(int id) async {
    final analysis = await _localDataSource.getAnalysis(id);
    if (analysis == null) {
      return;
    }

    await _localDataSource.deleteAnalysis(id);
    await _imageStore.deleteImage(analysis.imagePath);
  }

  @override
  Future<void> clearHistory() async {
    final analyses = await _localDataSource.getAllAnalyses();
    await _localDataSource.clearHistory();
    for (final analysis in analyses) {
      await _imageStore.deleteImage(analysis.imagePath);
    }
  }
}
