import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { AppError } from '../errors.js';

export function loadFoodAnalysisPrompt(): string {
  const promptUrl = new URL('../../prompts/food-analysis-system-prompt.md', import.meta.url);
  try {
    const prompt = readFileSync(fileURLToPath(promptUrl), 'utf8').trim();
    if (!prompt) throw new Error('Prompt is empty');
    return prompt;
  } catch {
    throw new AppError('SERVICE_UNAVAILABLE', 'The AI provider prompt is not configured.', 503);
  }
}
