import type { AnalyzeInput, FoodAnalysisResponse } from '../contracts.js';
import { AppError } from '../errors.js';
import type { FoodAnalysisProvider } from './food-analysis-provider.js';

export class OpenAIFoodAnalysisProvider implements FoodAnalysisProvider {
  readonly name = 'openai';

  async analyze(_input: AnalyzeInput, _requestId: string): Promise<FoodAnalysisResponse> {
    void _input;
    void _requestId;
    // TODO: Load the versioned system prompt from
    // backend/prompts/food-analysis-system-prompt.md at process startup.
    // TODO: Send the image only from this trusted backend and request strict
    // structured output matching foodAnalysisResponseSchema. Never expose the
    // provider credential to Flutter or include raw image bytes in logs.
    // TODO: Parse the provider payload with foodAnalysisResponseSchema before
    // returning it. Map refusal, timeout, malformed output and upstream rate
    // limits to the existing AppError contract.
    // TODO: Add provider-specific timeout, abort handling and bounded retries
    // for transient failures only. Do not retry invalid images or refusals.
    // TODO: Add contract tests with recorded, non-sensitive fixtures before
    // enabling FOOD_ANALYSIS_PROVIDER=openai in any environment.
    throw new AppError('SERVICE_UNAVAILABLE', 'The configured provider is unavailable.', 503);
  }
}
