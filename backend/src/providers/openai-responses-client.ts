import OpenAI from 'openai';
import { zodTextFormat } from 'openai/helpers/zod';
import { foodAnalysisModelOutputSchema, type FoodAnalysisModelOutput } from '../contracts.js';

export type OpenAIResponseResult = {
  parsed: FoodAnalysisModelOutput | null;
  refused: boolean;
  usage?: { inputTokens: number; outputTokens: number };
};

export type OpenAIAnalyzeCall = (input: {
  model: string;
  prompt: string;
  imageDataUrl: string;
  imageDetail: 'low' | 'high' | 'auto';
  locale?: 'en' | 'tr';
}) => Promise<OpenAIResponseResult>;

export function createOpenAIAnalyzeCall(options: {
  apiKey: string;
  timeoutMs: number;
  maxRetries: number;
}): OpenAIAnalyzeCall {
  const client = new OpenAI({
    apiKey: options.apiKey,
    timeout: options.timeoutMs,
    maxRetries: options.maxRetries
  });

  return async (input) => {
    const response = await client.responses.parse({
      model: input.model,
      instructions: input.prompt,
      input: [{
        role: 'user',
        content: [
          { type: 'input_text', text: `Analyze this image. Response language: ${input.locale ?? 'en'}.` },
          { type: 'input_image', image_url: input.imageDataUrl, detail: input.imageDetail }
        ]
      }],
      text: { format: zodTextFormat(foodAnalysisModelOutputSchema, 'food_analysis') },
      max_output_tokens: 1600
    });
    const refused = response.output.some((item) => item.type === 'message' &&
      item.content.some((content) => content.type === 'refusal'));
    return {
      parsed: response.output_parsed,
      refused,
      usage: response.usage ? {
        inputTokens: response.usage.input_tokens,
        outputTokens: response.usage.output_tokens
      } : undefined
    };
  };
}
