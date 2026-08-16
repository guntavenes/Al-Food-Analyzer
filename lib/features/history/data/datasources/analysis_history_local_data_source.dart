import 'dart:convert';

import 'package:ai_food_analyzer/core/database/app_database.dart';
import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';
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
            sugar: Value(analysis.sugarGrams),
            sodium: Value(analysis.sodiumMilligrams),
            servingWeightGrams: Value(analysis.servingWeightGrams),
            healthScore: Value(analysis.healthScore),
            warningsJson: Value(jsonEncode(analysis.warnings)),
            detectedFoodsJson: Value(
              jsonEncode(
                analysis.detectedFoods
                    .map(
                      (food) => <String, Object>{
                        'name': food.name,
                        'estimatedWeightGrams': food.estimatedWeightGrams,
                        'calories': food.calories,
                        'confidencePercent': food.confidencePercent,
                      },
                    )
                    .toList(growable: false),
              ),
            ),
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
      sugarGrams: record.sugar,
      sodiumMilligrams: record.sodium,
      servingWeightGrams: record.servingWeightGrams,
      healthScore: record.healthScore,
      warnings: (jsonDecode(record.warningsJson) as List<Object?>)
          .cast<String>(),
      detectedFoods: (jsonDecode(record.detectedFoodsJson) as List<Object?>)
          .map((item) {
            final value = item! as Map<String, Object?>;
            return DetectedFood(
              name: value['name']! as String,
              estimatedWeightGrams: value['estimatedWeightGrams']! as int,
              calories: value['calories']! as int,
              confidencePercent: value['confidencePercent']! as int,
            );
          })
          .toList(growable: false),
      imagePath: record.imagePath,
      createdAt: record.createdAt,
    );
  }
}
