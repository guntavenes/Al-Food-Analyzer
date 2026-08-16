import type { FoodAnalysisModelOutput } from '../contracts.js';
import { AppError } from '../errors.js';

export function validateFoodAnalysisConsistency(
  analysis: FoodAnalysisModelOutput
): FoodAnalysisModelOutput {
  if (!analysis.isFoodDetected) return analysis;

  const itemCalories = sum(analysis.detectedFoods.map((food) => food.calories));
  const itemWeight = sum(analysis.detectedFoods.map((food) => food.estimatedWeightGrams));
  const macroCalories = analysis.protein * 4 + analysis.carbohydrates * 4 + analysis.fat * 9;

  const caloriesAreConsistent = withinTolerance(
    analysis.calories,
    itemCalories,
    Math.max(80, analysis.calories * 0.2)
  );
  const weightIsConsistent = withinTolerance(
    analysis.servingWeightGrams,
    itemWeight,
    Math.max(50, analysis.servingWeightGrams * 0.25)
  );
  const macrosAreConsistent = withinTolerance(
    analysis.calories,
    macroCalories,
    Math.max(150, analysis.calories * 0.35)
  );
  const itemEnergyDensityIsPlausible = analysis.detectedFoods.every(
    (food) => food.calories / food.estimatedWeightGrams <= 9.5
  );

  if (!caloriesAreConsistent || !weightIsConsistent || !macrosAreConsistent || !itemEnergyDensityIsPlausible) {
    throw new AppError(
      'ANALYSIS_FAILED',
      'The analysis estimates were internally inconsistent. Please try another photo.',
      502
    );
  }
  return analysis;
}

function sum(values: number[]): number {
  return values.reduce((total, value) => total + value, 0);
}

function withinTolerance(actual: number, expected: number, tolerance: number): boolean {
  return Math.abs(actual - expected) <= tolerance;
}
