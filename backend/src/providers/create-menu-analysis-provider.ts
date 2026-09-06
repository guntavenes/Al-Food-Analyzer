import type { AppConfig } from '../config.js';
import type { MenuAnalysisProvider } from './menu-analysis-provider.js';
import { OpenAIMenuAnalysisProvider } from './openai-menu-analysis-provider.js';

export function createMenuAnalysisProvider(config: AppConfig): MenuAnalysisProvider | undefined {
  if (config.providerName !== 'openai') return undefined;
  return new OpenAIMenuAnalysisProvider({
    apiKey: config.openaiApiKey!,
    model: config.openaiModel!,
    imageDetail: config.openaiImageDetail,
    timeoutMs: config.openaiTimeoutMs,
    maxRetries: config.openaiMaxRetries,
    reasoningEffort: config.openaiReasoningEffort
  });
}
