import 'dart:async';

import 'package:ai_food_analyzer/core/database/app_database.dart';
import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';
import 'package:ai_food_analyzer/features/history/data/datasources/analysis_history_local_data_source.dart';
import 'package:ai_food_analyzer/features/history/data/datasources/analysis_image_local_data_source.dart';
import 'package:ai_food_analyzer/features/history/data/repositories/analysis_history_repository_impl.dart';
import 'package:ai_food_analyzer/features/history/domain/entities/saved_food_analysis.dart';
import 'package:ai_food_analyzer/features/history/domain/repositories/analysis_history_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

final analysisHistoryLocalDataSourceProvider =
    Provider<AnalysisHistoryLocalDataSource>((ref) {
      return AnalysisHistoryLocalDataSource(ref.watch(appDatabaseProvider));
    });

final analysisImageLocalDataSourceProvider =
    Provider<AnalysisImageLocalDataSource>((ref) {
      return AnalysisImageLocalDataSource();
    });

final analysisHistoryRepositoryProvider = Provider<AnalysisHistoryRepository>((
  ref,
) {
  return AnalysisHistoryRepositoryImpl(
    ref.watch(analysisHistoryLocalDataSourceProvider),
    ref.watch(analysisImageLocalDataSourceProvider),
  );
});

final analysisHistoryProvider =
    StreamProvider.autoDispose<List<SavedFoodAnalysis>>((ref) {
      return ref.watch(analysisHistoryRepositoryProvider).watchAnalyses();
    });

final savedAnalysisProvider = FutureProvider.autoDispose
    .family<SavedFoodAnalysis?, int>((ref, id) {
      return ref.watch(analysisHistoryRepositoryProvider).getAnalysis(id);
    });

class SaveAnalysisRequest {
  const SaveAnalysisRequest({required this.analysis, required this.imagePath});

  final FoodAnalysis analysis;
  final String imagePath;
}

final saveAnalysisProvider = AsyncNotifierProvider.autoDispose
    .family<SaveAnalysisController, int?, SaveAnalysisRequest>(
      (request) => SaveAnalysisController(request),
    );

class SaveAnalysisController extends AsyncNotifier<int?> {
  SaveAnalysisController(this._request);

  final SaveAnalysisRequest _request;

  @override
  int? build() => null;

  Future<int?> save() async {
    if (state.isLoading || state.value != null) {
      return state.value;
    }

    state = const AsyncLoading<int?>();
    state = await AsyncValue.guard(() {
      return ref
          .read(analysisHistoryRepositoryProvider)
          .saveAnalysis(
            analysis: _request.analysis,
            sourceImagePath: _request.imagePath,
          );
    });
    return state.value;
  }
}

final historyActionsProvider =
    AsyncNotifierProvider.autoDispose<HistoryActionsController, void>(
      HistoryActionsController.new,
    );

class HistoryActionsController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> deleteAnalysis(int id) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(
      () => ref.read(analysisHistoryRepositoryProvider).deleteAnalysis(id),
    );
  }

  Future<void> clearHistory() async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(
      ref.read(analysisHistoryRepositoryProvider).clearHistory,
    );
  }
}
