import { foodAnalysisModelOutputSchema, foodAnalysisResponseSchema, type AnalyzeInput, type FoodAnalysisResponse } from '../contracts.js';
import { validateFoodAnalysisConsistency } from '../analysis/food-analysis-consistency.js';
import { AppError } from '../errors.js';
import type { FoodAnalysisProvider } from './food-analysis-provider.js';
import type { OpenAIAnalyzeCall } from './openai-responses-client.js';

type SafeLog = (event: Record<string, string | number>) => void;

export class OpenAIFoodAnalysisProvider implements FoodAnalysisProvider {
  readonly name = 'openai';

  constructor(private readonly options: {
    model: string;
    imageDetail: 'low' | 'high' | 'auto';
    prompt: string;
    call: OpenAIAnalyzeCall;
    log?: SafeLog;
  }) {}

  async analyze(input: AnalyzeInput, requestId: string): Promise<FoodAnalysisResponse> {
    const startedAt = Date.now();
    try {
      const result = await this.options.call({
        model: this.options.model,
        prompt: this.options.prompt,
        imageDataUrl: `data:${input.mimeType};base64,${input.image.toString('base64')}`,
        imageDetail: this.options.imageDetail,
        locale: input.locale,
        correction: input.correction
      });
      if (result.refused || result.parsed === null) {
        throw new AppError('ANALYSIS_FAILED', 'The image could not be analyzed.', 502);
      }
      const parsed = foodAnalysisModelOutputSchema.safeParse(result.parsed);
      if (!parsed.success) throw new AppError('ANALYSIS_FAILED', 'The analysis response was invalid.', 502);
      const validated = validateFoodAnalysisConsistency(parsed.data);
      this.log({ requestId, durationMs: Date.now() - startedAt, category: 'success',
        inputTokens: result.usage?.inputTokens ?? 0, outputTokens: result.usage?.outputTokens ?? 0 });
      return foodAnalysisResponseSchema.parse({ ...validated, requestId });
    } catch (error) {
      const mapped = mapOpenAIError(error);
      this.log({ requestId, durationMs: Date.now() - startedAt, category: mapped.code });
      throw mapped;
    }
  }

  private log(fields: Record<string, string | number>): void {
    const event = { provider: this.name, model: this.options.model, ...fields };
    if (this.options.log) this.options.log(event);
    else console.info(JSON.stringify(event));
  }
}

export function mapOpenAIError(error: unknown): AppError {
  if (error instanceof AppError) return error;
  const value = error as { status?: number; name?: string; code?: string };
  if (value.status === 429) return new AppError('RATE_LIMITED', 'The analysis service is busy. Please try again later.', 429);
  if (value.name === 'APIConnectionTimeoutError' || value.code === 'ETIMEDOUT' || value.code === 'ECONNABORTED') {
    return new AppError('SERVICE_UNAVAILABLE', 'The analysis service timed out. Please try again.', 503);
  }
  if (value.status === 401 || value.status === 403 || (value.status !== undefined && value.status >= 500)) {
    return new AppError('SERVICE_UNAVAILABLE', 'The analysis service is unavailable.', 503);
  }
  return new AppError('ANALYSIS_FAILED', 'The image could not be analyzed.', 502);
}
