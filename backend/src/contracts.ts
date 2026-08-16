import { z } from 'zod';

export const localeSchema = z.enum(['en', 'tr']).optional();

export const analysisCorrectionSchema = z.object({
  ingredients: z.string().trim().min(1).max(300),
  servingDescription: z.string().trim().min(1).max(200)
}).strict();

export const detectedFoodSchema = z.object({
  name: z.string().trim().min(1).max(160),
  estimatedWeightGrams: z.number().positive().finite(),
  calories: z.number().nonnegative().finite(),
  confidence: z.number().min(0).max(1).finite()
}).strict();

const commonModelFields = {
  analysisDescription: z.string().trim().min(1).max(1000),
  warnings: z.array(z.string().trim().min(1).max(300)).max(20),
  detectedFoods: z.array(detectedFoodSchema).max(30)
};

const detectedFoodModelSchema = z.object({
  ...commonModelFields,
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
}).extend({ detectedFoods: z.array(detectedFoodSchema).min(1).max(30) }).strict();

const noFoodModelSchema = z.object({
  ...commonModelFields,
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

export const foodAnalysisModelOutputSchema = z.discriminatedUnion('isFoodDetected', [
  detectedFoodModelSchema,
  noFoodModelSchema
]);

// Structured Outputs requires an object at the JSON Schema root. The wrapper is
// transport-only; the public endpoint continues to return FoodAnalysisResponse.
export const foodAnalysisStructuredOutputSchema = z.object({
  analysis: foodAnalysisModelOutputSchema
}).strict();

export const foodAnalysisResponseSchema = z.discriminatedUnion('isFoodDetected', [
  detectedFoodModelSchema.extend({ requestId: z.uuid() }).strict(),
  noFoodModelSchema.extend({ requestId: z.uuid() }).strict()
]);

export type DetectedFood = z.infer<typeof detectedFoodSchema>;
export type FoodAnalysisResponse = z.infer<typeof foodAnalysisResponseSchema>;
export type FoodAnalysisModelOutput = z.infer<typeof foodAnalysisModelOutputSchema>;
export type AnalyzeInput = {
  image: Buffer;
  mimeType: string;
  locale?: 'en' | 'tr';
  correction?: z.infer<typeof analysisCorrectionSchema>;
};
