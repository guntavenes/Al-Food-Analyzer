import 'dart:async';
import 'dart:io';

import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';
import 'package:ai_food_analyzer/features/history/data/datasources/analysis_history_cloud_data_source.dart';
import 'package:ai_food_analyzer/features/history/data/datasources/analysis_history_local_data_source.dart';
import 'package:ai_food_analyzer/features/history/data/datasources/analysis_image_local_data_source.dart';
import 'package:ai_food_analyzer/features/history/data/models/saved_food_analysis_model.dart';
import 'package:ai_food_analyzer/features/history/domain/entities/saved_food_analysis.dart';
import 'package:ai_food_analyzer/features/history/domain/repositories/analysis_history_repository.dart';

class AnalysisHistoryRepositoryImpl implements AnalysisHistoryRepository {
  const AnalysisHistoryRepositoryImpl(
    this._localDataSource,
    this._imageStore, [
    this._cloudDataSource,
  ]);

  final AnalysisHistoryLocalDataSource _localDataSource;
  final AnalysisImageLocalDataSource _imageStore;
  final AnalysisHistoryCloudDataSource? _cloudDataSource;

  @override
  Future<int> saveAnalysis({
    required FoodAnalysis analysis,
    required String sourceImagePath,
  }) async {
    final persistentImagePath = await _imageStore.persistImage(sourceImagePath);
    final createdAt = DateTime.now().toUtc();
    try {
      final localId = await _localDataSource.insertAnalysis(
        SavedFoodAnalysisModel(
          id: 0,
          remoteId: null,
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
          createdAt: createdAt,
        ),
      );
      final cloud = _cloudDataSource;
      if (cloud != null) {
        unawaited(() async {
          try {
            final uploaded = await cloud.upload(
              analysis: analysis,
              imagePath: persistentImagePath,
              createdAt: createdAt,
            );
            if (uploaded?.remoteId != null) {
              await _localDataSource.setRemoteId(localId, uploaded!.remoteId!);
            }
          } on Object {
            // The local result is already available. A later history sync
            // retries cloud upload without blocking the result screen.
          }
        }());
      }
      return localId;
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
  Future<void> syncFromCloud() async {
    final cloud = _cloudDataSource;
    if (cloud == null) return;
    final local = await _localDataSource.getAllAnalyses();
    final localRemoteIds = local
        .map((item) => item.remoteId)
        .whereType<String>()
        .toSet();
    final remote = await cloud.fetchAll();
    for (final item in remote) {
      if (item.remoteId == null || localRemoteIds.contains(item.remoteId)) {
        continue;
      }
      final bytes = await cloud.downloadImage(item.imagePath);
      final localPath = await _imageStore.persistBytes(
        bytes,
        extension: item.imagePath.split('.').last,
      );
      await _localDataSource.insertAnalysis(
        SavedFoodAnalysisModel(
          id: 0,
          remoteId: item.remoteId,
          imagePath: localPath,
          createdAt: item.createdAt,
          isFavorite: item.isFavorite,
          foodName: item.foodName,
          calories: item.calories,
          proteinGrams: item.proteinGrams,
          fatGrams: item.fatGrams,
          carbsGrams: item.carbsGrams,
          fiberGrams: item.fiberGrams,
          confidencePercent: item.confidencePercent,
          servingDescription: item.servingDescription,
          description: item.description,
          sugarGrams: item.sugarGrams,
          sodiumMilligrams: item.sodiumMilligrams,
          servingWeightGrams: item.servingWeightGrams,
          healthScore: item.healthScore,
          warnings: item.warnings,
          detectedFoods: item.detectedFoods,
        ),
      );
    }
    for (final item in local.where((entry) => entry.remoteId == null)) {
      if (!await File(item.imagePath).exists()) continue;
      final uploaded = await cloud.upload(
        analysis: item,
        imagePath: item.imagePath,
        createdAt: item.createdAt,
      );
      if (uploaded?.remoteId != null) {
        await _localDataSource.setRemoteId(item.id, uploaded!.remoteId!);
      }
    }
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
    if (analysis.remoteId != null) {
      await _cloudDataSource?.delete(analysis.remoteId!);
    }
  }

  @override
  Future<void> clearHistory() async {
    await clearLocalHistory();
    await _cloudDataSource?.clear();
  }

  @override
  Future<void> clearLocalHistory() async {
    final analyses = await _localDataSource.getAllAnalyses();
    await _localDataSource.clearHistory();
    for (final analysis in analyses) {
      await _imageStore.deleteImage(analysis.imagePath);
    }
  }

  @override
  Future<void> setFavorite(int id, {required bool isFavorite}) async {
    await _localDataSource.setFavorite(id, isFavorite: isFavorite);
    final analysis = await _localDataSource.getAnalysis(id);
    if (analysis?.remoteId != null) {
      await _cloudDataSource?.setFavorite(analysis!.remoteId!, isFavorite);
    }
  }
}
