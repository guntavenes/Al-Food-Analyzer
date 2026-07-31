import type { AnalyzeInput, FoodAnalysisResponse } from '../contracts.js';

export interface FoodAnalysisProvider {
  readonly name: string;
  analyze(input: AnalyzeInput, requestId: string): Promise<FoodAnalysisResponse>;
}
