import 'package:ai_food_analyzer/features/analysis/data/datasources/food_analysis_data_source.dart';
import 'package:ai_food_analyzer/features/analysis/data/repositories/food_analysis_repository_impl.dart';
import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';
import 'package:ai_food_analyzer/features/analysis/domain/repositories/food_analysis_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final foodAnalysisDataSourceProvider = Provider<FoodAnalysisDataSource>((ref) {
  return const FakeFoodAnalysisDataSource();
});

final foodAnalysisRepositoryProvider = Provider<FoodAnalysisRepository>((ref) {
  return FoodAnalysisRepositoryImpl(ref.watch(foodAnalysisDataSourceProvider));
});

final foodAnalysisProvider = FutureProvider.autoDispose
    .family<FoodAnalysis, String>((ref, imagePath) {
      return ref.watch(foodAnalysisRepositoryProvider).analyzeFood(imagePath);
    });
