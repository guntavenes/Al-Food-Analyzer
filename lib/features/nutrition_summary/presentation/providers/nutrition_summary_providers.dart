import 'package:ai_food_analyzer/features/history/presentation/providers/history_providers.dart';
import 'package:ai_food_analyzer/features/nutrition_summary/data/wellness_preferences.dart';
import 'package:ai_food_analyzer/features/nutrition_summary/domain/daily_nutrition_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final weeklyNutritionSummaryProvider =
    Provider<AsyncValue<List<DailyNutritionSummary>>>((ref) {
      return ref
          .watch(analysisHistoryProvider)
          .whenData(buildWeeklyNutritionSummary);
    });

final wellnessPreferencesProvider = Provider<WellnessPreferences>(
  (ref) => const WellnessPreferences(),
);

final wellnessSettingsProvider = FutureProvider<WellnessSettings>(
  (ref) => ref.watch(wellnessPreferencesProvider).load(),
);
