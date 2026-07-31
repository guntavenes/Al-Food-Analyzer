import { z } from 'zod';

export const localeSchema = z.enum(['en', 'tr']).optional();

export const foodAnalysisResponseSchema = z.object({
  requestId: z.uuid(),
  foodName: z.string().nullable(),
  calories: z.number().int().nonnegative().nullable(),
  protein: z.number().nonnegative().nullable(),
  carbohydrates: z.number().nonnegative().nullable(),
  fat: z.number().nonnegative().nullable(),
  fiber: z.number().nonnegative().nullable(),
  confidence: z.number().min(0).max(1),
  servingDescription: z.string().nullable(),
  analysisDescription: z.string(),
  warnings: z.array(z.string()),
  isFoodDetected: z.boolean()
});

export type FoodAnalysisResponse = z.infer<typeof foodAnalysisResponseSchema>;
export type AnalyzeInput = { image: Buffer; mimeType: string; locale?: 'en' | 'tr' };
