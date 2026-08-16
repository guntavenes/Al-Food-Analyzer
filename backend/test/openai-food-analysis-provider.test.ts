import { randomUUID } from 'node:crypto';
import { describe, expect, it, vi } from 'vitest';
import { loadConfig } from '../src/config.js';
import type { FoodAnalysisModelOutput } from '../src/contracts.js';
import { OpenAIFoodAnalysisProvider } from '../src/providers/openai-food-analysis-provider.js';

const requestId = randomUUID();
const image = Buffer.from([137, 80, 78, 71]);
const validOutput: FoodAnalysisModelOutput = {
  foodName: 'Pizza', calories: 700, protein: 28, carbohydrates: 85, fat: 27,
  fiber: 5, sugar: 8, sodium: 1200, confidence: 0.82,
  servingDescription: '2 slices', servingWeightGrams: 300, healthScore: 55,
  isFoodDetected: true, analysisDescription: 'Estimated values may vary by ingredients and portion.',
  warnings: [], detectedFoods: [{ name: 'Pizza', estimatedWeightGrams: 300, calories: 700, confidence: 0.82 }]
};

function provider(call: ConstructorParameters<typeof OpenAIFoodAnalysisProvider>[0]['call'], log?: (value: Record<string, string | number>) => void) {
  return new OpenAIFoodAnalysisProvider({ model: 'test-model', imageDetail: 'low', prompt: 'safe prompt', call, log });
}

describe('OpenAI provider configuration', () => {
  it('does not require an API key for mock mode', () => {
    expect(loadConfig({ FOOD_ANALYSIS_PROVIDER: 'mock' }).providerName).toBe('mock');
  });

  it('requires an API key and explicit model in openai mode', () => {
    expect(() => loadConfig({ FOOD_ANALYSIS_PROVIDER: 'openai' })).toThrow();
    expect(() => loadConfig({ FOOD_ANALYSIS_PROVIDER: 'openai', OPENAI_API_KEY: 'secret' })).toThrow();
  });
});

describe('OpenAIFoodAnalysisProvider', () => {
  it('returns a validated successful result with the runtime requestId', async () => {
    const result = await provider(async (input) => {
      expect(input.imageDataUrl).toBe('data:image/png;base64,iVBORw==');
      expect(input.correction).toEqual({
        ingredients: 'ground beef and bread',
        servingDescription: '6 pieces'
      });
      return { parsed: validOutput, refused: false };
    }).analyze({
      image,
      mimeType: 'image/png',
      locale: 'tr',
      correction: { ingredients: 'ground beef and bread', servingDescription: '6 pieces' }
    }, requestId);
    expect(result).toMatchObject({ requestId, foodName: 'Pizza', isFoodDetected: true });
  });

  it('rejects output that fails the Zod contract', async () => {
    await expect(provider(async () => ({ parsed: { ...validOutput, calories: -1 } as FoodAnalysisModelOutput, refused: false }))
      .analyze({ image, mimeType: 'image/png' }, requestId)).rejects.toMatchObject({ code: 'ANALYSIS_FAILED' });
  });

  it('accepts a valid no-food result', async () => {
    const noFood: FoodAnalysisModelOutput = {
      foodName: null, calories: null, protein: null, carbohydrates: null, fat: null,
      fiber: null, sugar: null, sodium: null, confidence: 0, servingDescription: null,
      servingWeightGrams: null, healthScore: null, isFoodDetected: false,
      analysisDescription: 'No food detected.', warnings: [], detectedFoods: []
    };
    const result = await provider(async () => ({ parsed: noFood, refused: false }))
      .analyze({ image, mimeType: 'image/png' }, requestId);
    expect(result.isFoodDetected).toBe(false);
  });

  it.each([
    [{ status: 429 }, 'RATE_LIMITED'],
    [{ name: 'APIConnectionTimeoutError' }, 'SERVICE_UNAVAILABLE'],
    [{ status: 401 }, 'SERVICE_UNAVAILABLE']
  ])('maps upstream errors without leaking details', async (upstream, code) => {
    await expect(provider(async () => { throw upstream; }).analyze({ image, mimeType: 'image/png' }, requestId))
      .rejects.toMatchObject({ code });
  });

  it('maps refusals to a controlled analysis error', async () => {
    await expect(provider(async () => ({ parsed: null, refused: true })).analyze({ image, mimeType: 'image/png' }, requestId))
      .rejects.toMatchObject({ code: 'ANALYSIS_FAILED' });
  });

  it('logs only safe metadata', async () => {
    const log = vi.fn();
    await provider(async () => ({ parsed: validOutput, refused: false, usage: { inputTokens: 10, outputTokens: 20 } }), log)
      .analyze({ image, mimeType: 'image/png' }, requestId);
    const serialized = JSON.stringify(log.mock.calls);
    expect(serialized).not.toContain('base64');
    expect(serialized).not.toContain('safe prompt');
    expect(serialized).not.toContain('Pizza');
    expect(serialized).toContain('inputTokens');
  });
});
