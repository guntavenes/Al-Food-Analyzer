import 'package:ai_food_analyzer/features/history/domain/entities/saved_food_analysis.dart';
import 'package:ai_food_analyzer/features/nutrition_summary/domain/daily_nutrition_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('groups saved meals by local day and totals macros', () {
    final now = DateTime(2026, 9, 15, 18);
    final summaries = buildWeeklyNutritionSummary([
      _meal(DateTime(2026, 9, 15, 8), calories: 400, protein: 20),
      _meal(DateTime(2026, 9, 15, 13), calories: 650, protein: 35),
      _meal(DateTime(2026, 9, 14, 20), calories: 500, protein: 25),
      _meal(DateTime(2026, 9, 1), calories: 999, protein: 99),
    ], now: now);

    expect(summaries, hasLength(7));
    expect(summaries.last.calories, 1050);
    expect(summaries.last.proteinGrams, 55);
    expect(summaries.last.carbsGrams, 80);
    expect(summaries.last.fatGrams, 30);
    expect(summaries.last.mealCount, 2);
    expect(summaries[5].calories, 500);
    expect(summaries.fold<int>(0, (sum, day) => sum + day.mealCount), 3);
  });
}

SavedFoodAnalysis _meal(
  DateTime date, {
  required int calories,
  required int protein,
}) {
  return SavedFoodAnalysis(
    id: date.millisecondsSinceEpoch,
    imagePath: 'meal.jpg',
    createdAt: date,
    foodName: 'Meal',
    calories: calories,
    proteinGrams: protein,
    fatGrams: 15,
    carbsGrams: 40,
    fiberGrams: 5,
    confidencePercent: 90,
    servingDescription: '1 serving',
    description: 'Meal',
  );
}
