import 'package:ai_food_analyzer/core/database/app_database.dart';
import 'package:ai_food_analyzer/features/history/data/models/saved_food_analysis_model.dart';
import 'package:drift/drift.dart';

class AnalysisHistoryLocalDataSource {
  const AnalysisHistoryLocalDataSource(this._database);

  final AppDatabase _database;

  Future<int> insertAnalysis(SavedFoodAnalysisModel analysis) {
    return _database
        .into(_database.foodAnalysisRecords)
        .insert(
          FoodAnalysisRecordsCompanion.insert(
            foodName: analysis.foodName,
            calories: analysis.calories,
            protein: analysis.proteinGrams,
            carbohydrates: analysis.carbsGrams,
            fat: analysis.fatGrams,
            fiber: analysis.fiberGrams,
            confidence: analysis.confidencePercent,
            servingDescription: analysis.servingDescription,
            analysisDescription: analysis.description,
            imagePath: analysis.imagePath,
            createdAt: analysis.createdAt,
          ),
        );
  }

  Future<List<SavedFoodAnalysisModel>> getAllAnalyses() async {
    final query = _database.select(_database.foodAnalysisRecords)
      ..orderBy([(record) => OrderingTerm.desc(record.createdAt)]);
    final records = await query.get();
    return records.map(_mapRecord).toList(growable: false);
  }

  Stream<List<SavedFoodAnalysisModel>> watchAnalyses() {
    final query = _database.select(_database.foodAnalysisRecords)
      ..orderBy([(record) => OrderingTerm.desc(record.createdAt)]);
    return query.watch().map(
      (records) => records.map(_mapRecord).toList(growable: false),
    );
  }

  Future<SavedFoodAnalysisModel?> getAnalysis(int id) async {
    final query = _database.select(_database.foodAnalysisRecords)
      ..where((record) => record.id.equals(id));
    final record = await query.getSingleOrNull();
    return record == null ? null : _mapRecord(record);
  }

  Future<void> deleteAnalysis(int id) async {
    await (_database.delete(
      _database.foodAnalysisRecords,
    )..where((record) => record.id.equals(id))).go();
  }

  Future<void> clearHistory() async {
    await _database.delete(_database.foodAnalysisRecords).go();
  }

  SavedFoodAnalysisModel _mapRecord(FoodAnalysisRecord record) {
    return SavedFoodAnalysisModel(
      id: record.id,
      foodName: record.foodName,
      calories: record.calories,
      proteinGrams: record.protein,
      carbsGrams: record.carbohydrates,
      fatGrams: record.fat,
      fiberGrams: record.fiber,
      confidencePercent: record.confidence,
      servingDescription: record.servingDescription,
      description: record.analysisDescription,
      imagePath: record.imagePath,
      createdAt: record.createdAt,
    );
  }
}
