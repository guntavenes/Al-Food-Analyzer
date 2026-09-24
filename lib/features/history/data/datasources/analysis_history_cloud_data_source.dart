import 'dart:io';
import 'dart:typed_data';

import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';
import 'package:ai_food_analyzer/features/history/data/models/saved_food_analysis_model.dart';
import 'package:ai_food_analyzer/features/history/domain/entities/saved_food_analysis.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalysisHistoryCloudDataSource {
  const AnalysisHistoryCloudDataSource(this._client);

  final SupabaseClient _client;
  static const _bucket = 'analysis-images';
  static const _table = 'food_analysis_history';

  User? get _user => _client.auth.currentUser;

  Future<SavedFoodAnalysisModel?> upload({
    required FoodAnalysis analysis,
    required String imagePath,
    required DateTime createdAt,
  }) async {
    final user = _user;
    if (user == null || user.isAnonymous) return null;
    final extension = p.extension(imagePath).isEmpty
        ? '.jpg'
        : p.extension(imagePath);
    final objectPath =
        '${user.id}/${createdAt.microsecondsSinceEpoch}$extension';
    await _client.storage
        .from(_bucket)
        .upload(
          objectPath,
          File(imagePath),
          fileOptions: const FileOptions(upsert: false),
        );
    try {
      final row = await _client
          .from(_table)
          .insert({
            'user_id': user.id,
            'image_path': objectPath,
            'analysis_data': _analysisToJson(analysis),
            'created_at': createdAt.toIso8601String(),
            'is_consumed': analysis is SavedFoodAnalysis
                ? analysis.isConsumed
                : false,
          })
          .select()
          .single();
      return _fromRow(row);
    } on Object {
      await _client.storage.from(_bucket).remove([objectPath]);
      rethrow;
    }
  }

  Future<List<SavedFoodAnalysisModel>> fetchAll() async {
    final user = _user;
    if (user == null || user.isAnonymous) return const [];
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<Uint8List> downloadImage(String objectPath) =>
      _client.storage.from(_bucket).download(objectPath);

  Future<void> delete(String remoteId) async {
    final row = await _client
        .from(_table)
        .delete()
        .eq('id', remoteId)
        .select('image_path')
        .maybeSingle();
    final imagePath = row?['image_path'] as String?;
    if (imagePath != null) {
      await _client.storage.from(_bucket).remove([imagePath]);
    }
  }

  Future<void> clear() async {
    final items = await fetchAll();
    if (items.isEmpty) return;
    await _client
        .from(_table)
        .delete()
        .inFilter('id', items.map((item) => item.remoteId!).toList());
    await _client.storage
        .from(_bucket)
        .remove(items.map((item) => item.imagePath).toList());
  }

  Future<void> setFavorite(String remoteId, bool value) =>
      _client.from(_table).update({'is_favorite': value}).eq('id', remoteId);

  Future<void> setConsumed(String remoteId, bool value) =>
      _client.from(_table).update({'is_consumed': value}).eq('id', remoteId);

  SavedFoodAnalysisModel _fromRow(Map<String, dynamic> row) {
    final data = row['analysis_data']! as Map<String, dynamic>;
    return SavedFoodAnalysisModel(
      id: 0,
      remoteId: row['id']! as String,
      imagePath: row['image_path']! as String,
      createdAt: DateTime.parse(row['created_at']! as String).toUtc(),
      isFavorite: row['is_favorite'] as bool? ?? false,
      isConsumed: row['is_consumed'] as bool? ?? false,
      foodName: data['foodName']! as String,
      calories: data['calories']! as int,
      proteinGrams: data['proteinGrams']! as int,
      carbsGrams: data['carbsGrams']! as int,
      fatGrams: data['fatGrams']! as int,
      fiberGrams: data['fiberGrams']! as int,
      confidencePercent: data['confidencePercent']! as int,
      servingDescription: data['servingDescription']! as String,
      description: data['description']! as String,
      sugarGrams: data['sugarGrams'] as int? ?? 0,
      sodiumMilligrams: data['sodiumMilligrams'] as int? ?? 0,
      servingWeightGrams: data['servingWeightGrams'] as int? ?? 0,
      healthScore: data['healthScore'] as int? ?? 0,
      warnings: (data['warnings'] as List<dynamic>? ?? const []).cast<String>(),
      detectedFoods: (data['detectedFoods'] as List<dynamic>? ?? const [])
          .map((item) {
            final food = item as Map<String, dynamic>;
            return DetectedFood(
              name: food['name']! as String,
              estimatedWeightGrams: food['estimatedWeightGrams']! as int,
              calories: food['calories']! as int,
              confidencePercent: food['confidencePercent']! as int,
            );
          })
          .toList(growable: false),
    );
  }

  Map<String, Object?> _analysisToJson(FoodAnalysis value) => {
    'foodName': value.foodName,
    'calories': value.calories,
    'proteinGrams': value.proteinGrams,
    'carbsGrams': value.carbsGrams,
    'fatGrams': value.fatGrams,
    'fiberGrams': value.fiberGrams,
    'confidencePercent': value.confidencePercent,
    'servingDescription': value.servingDescription,
    'description': value.description,
    'sugarGrams': value.sugarGrams,
    'sodiumMilligrams': value.sodiumMilligrams,
    'servingWeightGrams': value.servingWeightGrams,
    'healthScore': value.healthScore,
    'warnings': value.warnings,
    'detectedFoods': value.detectedFoods
        .map(
          (food) => {
            'name': food.name,
            'estimatedWeightGrams': food.estimatedWeightGrams,
            'calories': food.calories,
            'confidencePercent': food.confidencePercent,
          },
        )
        .toList(growable: false),
  };
}
