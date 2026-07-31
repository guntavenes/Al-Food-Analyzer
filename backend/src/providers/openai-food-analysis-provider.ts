import type { AnalyzeInput, FoodAnalysisResponse } from '../contracts.js';
import { AppError } from '../errors.js';
import type { FoodAnalysisProvider } from './food-analysis-provider.js';

export class OpenAIFoodAnalysisProvider implements FoodAnalysisProvider {
  readonly name = 'openai';

  async analyze(_input: AnalyzeInput, _requestId: string): Promise<FoodAnalysisResponse> {
    void _input;
    void _requestId;
    // TODO: Implement server-side OpenAI integration in a future phase.
    throw new AppError('SERVICE_UNAVAILABLE', 'The configured provider is unavailable.', 503);
  }
}
