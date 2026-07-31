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
        confidence: 0,
        servingDescription: null,
        analysisDescription: 'No food could be detected in this image.',
        warnings: [],
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
      confidence: 0.87,
      servingDescription: '1 medium serving',
      analysisDescription: 'A balanced meal with a good amount of protein.',
      warnings: [],
      isFoodDetected: true
    };
  }
}
