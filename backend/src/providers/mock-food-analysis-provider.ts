import type { AnalyzeInput, FoodAnalysisResponse } from '../contracts.js';
import { AppError } from '../errors.js';
import type { FoodAnalysisProvider } from './food-analysis-provider.js';

export class MockFoodAnalysisProvider implements FoodAnalysisProvider {
  readonly name = 'mock';

  constructor(
    private readonly delayMs: number,
    private readonly forceError: boolean,
    private readonly noFood: boolean
  ) {}

  async analyze(_input: AnalyzeInput, requestId: string): Promise<FoodAnalysisResponse> {
    await new Promise((resolve) => setTimeout(resolve, this.delayMs));
    if (this.forceError) {
      throw new AppError('ANALYSIS_FAILED', 'Food analysis could not be completed.', 502);
    }
    if (this.noFood) {
      return {
        requestId,
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
        analysisDescription: 'No food could be detected in this image.',
        warnings: [],
        detectedFoods: [],
        isFoodDetected: false
      };
    }
    return {
      requestId,
      foodName: 'Grilled Chicken Bowl',
      calories: 540,
      protein: 32,
      carbohydrates: 56,
      fat: 18,
      fiber: 7,
      sugar: 8,
      sodium: 720,
      confidence: 0.87,
      servingDescription: '1 medium serving',
      servingWeightGrams: 420,
      healthScore: 78,
      analysisDescription: 'A balanced meal with a good amount of protein.',
      warnings: [],
      detectedFoods: [
        { name: 'Grilled chicken', estimatedWeightGrams: 140, calories: 230, confidence: 0.93 },
        { name: 'Rice', estimatedWeightGrams: 180, calories: 235, confidence: 0.88 },
        { name: 'Mixed vegetables', estimatedWeightGrams: 100, calories: 75, confidence: 0.82 }
      ],
      isFoodDetected: true
    };
  }
}
