import { z } from 'zod';

export const localeSchema = z.enum(['en', 'tr']).optional();

export const detectedFoodSchema = z.object({
  name: z.string().trim().min(1).max(160),
  estimatedWeightGrams: z.number().nonnegative().finite(),
  calories: z.number().nonnegative().finite(),
  confidence: z.number().min(0).max(1).finite()
}).strict();

const commonResponseFields = {
  requestId: z.uuid(),
  analysisDescription: z.string().trim().min(1).max(1000),
  warnings: z.array(z.string().trim().min(1).max(300)).max(20),
  detectedFoods: z.array(detectedFoodSchema).max(30)
};

const detectedFoodResponseSchema = z.object({
  ...commonResponseFields,
  foodName: z.string().trim().min(1).max(200),
  calories: z.number().nonnegative().finite(),
  protein: z.number().nonnegative().finite(),
  carbohydrates: z.number().nonnegative().finite(),
  fat: z.number().nonnegative().finite(),
  fiber: z.number().nonnegative().finite(),
  sugar: z.number().nonnegative().finite(),
  sodium: z.number().nonnegative().finite(),
  confidence: z.number().min(0).max(1).finite(),
  servingDescription: z.string().trim().min(1).max(300),
  servingWeightGrams: z.number().positive().finite(),
  healthScore: z.number().min(0).max(100).finite(),
  isFoodDetected: z.literal(true)
}).strict();

const noFoodResponseSchema = z.object({
  ...commonResponseFields,
  foodName: z.null(),
  calories: z.null(),
  protein: z.null(),
  carbohydrates: z.null(),
  fat: z.null(),
  fiber: z.null(),
  sugar: z.null(),
  sodium: z.null(),
  confidence: z.literal(0),
  servingDescription: z.null(),
  servingWeightGrams: z.null(),
  healthScore: z.null(),
  detectedFoods: z.array(detectedFoodSchema).length(0),
  isFoodDetected: z.literal(false)
}).strict();

export const foodAnalysisResponseSchema = z.discriminatedUnion('isFoodDetected', [
  detectedFoodResponseSchema,
  noFoodResponseSchema
]);

export type DetectedFood = z.infer<typeof detectedFoodSchema>;
export type FoodAnalysisResponse = z.infer<typeof foodAnalysisResponseSchema>;
export type AnalyzeInput = { image: Buffer; mimeType: string; locale?: 'en' | 'tr' };
