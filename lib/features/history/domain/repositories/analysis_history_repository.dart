import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';
import 'package:ai_food_analyzer/features/history/domain/entities/saved_food_analysis.dart';

abstract interface class AnalysisHistoryRepository {
  Future<int> saveAnalysis({
    required FoodAnalysis analysis,
    required String sourceImagePath,
  });

  Future<List<SavedFoodAnalysis>> getAllAnalyses();

  Stream<List<SavedFoodAnalysis>> watchAnalyses();

  Future<void> repairLocalImagePaths();

  Future<void> syncFromCloud();

  Future<SavedFoodAnalysis?> getAnalysis(int id);

  Future<void> deleteAnalysis(int id);

  Future<void> clearHistory();
  Future<void> clearLocalHistory();

  Future<void> setFavorite(int id, {required bool isFavorite});

  Future<void> setConsumed(int id, {required bool isConsumed});
}
