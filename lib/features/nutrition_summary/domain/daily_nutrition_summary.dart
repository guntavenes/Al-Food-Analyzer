import 'package:ai_food_analyzer/features/history/domain/entities/saved_food_analysis.dart';

class DailyNutritionSummary {
  const DailyNutritionSummary({
    required this.date,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.mealCount,
  });

  factory DailyNutritionSummary.empty(DateTime date) {
    return DailyNutritionSummary(
      date: DateTime(date.year, date.month, date.day),
      calories: 0,
      proteinGrams: 0,
      carbsGrams: 0,
      fatGrams: 0,
      mealCount: 0,
    );
  }

  final DateTime date;
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final int mealCount;
}

List<DailyNutritionSummary> buildWeeklyNutritionSummary(
  List<SavedFoodAnalysis> analyses, {
  DateTime? now,
}) {
  final localNow = (now ?? DateTime.now()).toLocal();
  final today = DateTime(localNow.year, localNow.month, localNow.day);
  final totals = <DateTime, List<int>>{};

  for (final analysis in analyses) {
    final localDate = analysis.createdAt.toLocal();
    final day = DateTime(localDate.year, localDate.month, localDate.day);
    final firstDay = today.subtract(const Duration(days: 6));
    if (day.isBefore(firstDay) || day.isAfter(today)) continue;
    final values = totals.putIfAbsent(day, () => [0, 0, 0, 0, 0]);
    values[0] += analysis.calories;
    values[1] += analysis.proteinGrams;
    values[2] += analysis.carbsGrams;
    values[3] += analysis.fatGrams;
    values[4] += 1;
  }

  return List.generate(7, (index) {
    final day = today.subtract(Duration(days: 6 - index));
    final values = totals[day];
    if (values == null) return DailyNutritionSummary.empty(day);
    return DailyNutritionSummary(
      date: day,
      calories: values[0],
      proteinGrams: values[1],
      carbsGrams: values[2],
      fatGrams: values[3],
      mealCount: values[4],
    );
  }, growable: false);
}
