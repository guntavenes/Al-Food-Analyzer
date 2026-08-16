import { describe, expect, it } from 'vitest';
import { zodTextFormat } from 'openai/helpers/zod';
import { foodAnalysisStructuredOutputSchema } from '../src/contracts.js';

describe('OpenAI structured output schema', () => {
  it('generates a strict object-root JSON schema', () => {
    const format = zodTextFormat(foodAnalysisStructuredOutputSchema, 'food_analysis');
    expect(format).toMatchObject({
      type: 'json_schema',
      strict: true,
      schema: { type: 'object' }
    });
  });
});
