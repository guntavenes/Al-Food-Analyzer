import type { AppConfig } from '../config.js';
import { AppError } from '../errors.js';
import type { FoodAnalysisProvider } from './food-analysis-provider.js';
import { MockFoodAnalysisProvider } from './mock-food-analysis-provider.js';
import { OpenAIFoodAnalysisProvider } from './openai-food-analysis-provider.js';
import { createOpenAIAnalyzeCall } from './openai-responses-client.js';
import { loadFoodAnalysisPrompt } from './prompt-loader.js';

export function createFoodAnalysisProvider(config: AppConfig): FoodAnalysisProvider {
  if (config.providerName === 'mock') {
    return new MockFoodAnalysisProvider(config.mockDelayMs, config.mockForceError, config.mockNoFood);
  }
  if (!config.openaiApiKey || !config.openaiModel) {
    throw new AppError('SERVICE_UNAVAILABLE', 'The OpenAI provider is not configured.', 503);
  }
  return new OpenAIFoodAnalysisProvider({
    model: config.openaiModel,
    imageDetail: config.openaiImageDetail,
    prompt: loadFoodAnalysisPrompt(),
    call: createOpenAIAnalyzeCall({
      apiKey: config.openaiApiKey,
      timeoutMs: config.openaiTimeoutMs,
      maxRetries: config.openaiMaxRetries,
      reasoningEffort: config.openaiReasoningEffort
    })
  });
}
