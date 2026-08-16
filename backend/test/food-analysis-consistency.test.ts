import { describe, expect, it } from 'vitest';
import { validateFoodAnalysisConsistency } from '../src/analysis/food-analysis-consistency.js';
import type { FoodAnalysisModelOutput } from '../src/contracts.js';

const consistentAnalysis: FoodAnalysisModelOutput = {
  foodName: 'Seven beef toasts with tomato salad',
  calories: 1540,
  protein: 70,
  carbohydrates: 161,
  fat: 68,
  fiber: 12,
  sugar: 14,
  sodium: 2100,
  confidence: 0.72,
  servingDescription: 'Entire visible plate: 7 beef toasts and 1 small tomato salad',
  servingWeightGrams: 760,
  healthScore: 48,
  isFoodDetected: true,
  analysisDescription: 'Estimated values may vary by portion and preparation.',
  warnings: ['Hidden oil and meat fat may change calories.'],
  detectedFoods: [
    { name: '7 beef toasts', estimatedWeightGrams: 630, calories: 1400, confidence: 0.7 },
    { name: 'Tomato salad', estimatedWeightGrams: 130, calories: 140, confidence: 0.78 }
  ]
};

describe('food analysis consistency', () => {
  it('accepts whole-meal totals that agree with components and macros', () => {
    expect(validateFoodAnalysisConsistency(consistentAnalysis)).toBe(consistentAnalysis);
  });

  it('rejects calories that represent only one item on a multi-item plate', () => {
    expect(() => validateFoodAnalysisConsistency({
      ...consistentAnalysis,
      calories: 220
    })).toThrowError(/internally inconsistent/i);
  });

  it('rejects serving weight that does not cover all detected foods', () => {
    expect(() => validateFoodAnalysisConsistency({
      ...consistentAnalysis,
      servingWeightGrams: 180
    })).toThrowError(/internally inconsistent/i);
  });

  it('allows the controlled no-food response', () => {
    const noFood: FoodAnalysisModelOutput = {
      foodName: null,
      calories: null,
      protein: null,
      carbohydrates: null,
      fat: null,
      fiber: null,
      sugar: null,
      sodium: null,
      confidence: 0,
      servingDescription: null,
      servingWeightGrams: null,
      healthScore: null,
      isFoodDetected: false,
      analysisDescription: 'No food detected.',
      warnings: [],
      detectedFoods: []
    };

    expect(validateFoodAnalysisConsistency(noFood)).toBe(noFood);
  });
});
