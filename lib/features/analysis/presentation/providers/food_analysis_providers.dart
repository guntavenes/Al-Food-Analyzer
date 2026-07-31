import 'package:ai_food_analyzer/core/config/app_config.dart';
import 'package:ai_food_analyzer/features/analysis/data/datasources/food_analysis_data_source.dart';
import 'package:ai_food_analyzer/features/analysis/data/datasources/food_analysis_remote_data_source.dart';
import 'package:ai_food_analyzer/features/analysis/data/repositories/http_food_analysis_repository.dart';
import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';
import 'package:ai_food_analyzer/features/analysis/domain/repositories/food_analysis_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fakeFoodAnalysisDataSourceProvider = Provider<FoodAnalysisDataSource>((
  ref,
) {
  return const FakeFoodAnalysisDataSource();
});

final foodAnalysisDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
    ),
  );
});

final foodAnalysisRemoteDataSourceProvider = Provider((ref) {
  return FoodAnalysisRemoteDataSource(ref.watch(foodAnalysisDioProvider));
});

final foodAnalysisRepositoryProvider = Provider<FoodAnalysisRepository>((ref) {
  return HttpFoodAnalysisRepository(
    ref.watch(foodAnalysisRemoteDataSourceProvider),
  );
});

final foodAnalysisProvider = FutureProvider.autoDispose
    .family<FoodAnalysis, String>((ref, imagePath) {
      return ref.watch(foodAnalysisRepositoryProvider).analyzeFood(imagePath);
    });
