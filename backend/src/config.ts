import 'dotenv/config';
import { z } from 'zod';

const environmentSchema = z.object({
  PORT: z.coerce.number().int().positive().default(8080),
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  FOOD_ANALYSIS_PROVIDER: z.enum(['mock', 'openai']).default('mock'),
  MAX_IMAGE_SIZE_MB: z.coerce.number().positive().default(8),
  MOCK_ANALYSIS_DELAY_MS: z.coerce.number().int().nonnegative().default(1200),
  MOCK_ANALYSIS_FORCE_ERROR: z.stringbool().default(false),
  MOCK_ANALYSIS_NO_FOOD: z.stringbool().default(false),
  CORS_ORIGINS: z.string().default('http://localhost:3000'),
  RATE_LIMIT_WINDOW_MS: z.coerce.number().int().positive().default(60000),
  RATE_LIMIT_MAX_REQUESTS: z.coerce.number().int().positive().default(30)
});

export type AppConfig = {
  port: number;
  nodeEnv: 'development' | 'test' | 'production';
  providerName: 'mock' | 'openai';
  maxImageBytes: number;
  mockDelayMs: number;
  mockForceError: boolean;
  mockNoFood: boolean;
  corsOrigins: string[];
  rateLimitWindowMs: number;
  rateLimitMaxRequests: number;
};

export function loadConfig(environment: NodeJS.ProcessEnv = process.env): AppConfig {
  const value = environmentSchema.parse(environment);
  return {
    port: value.PORT,
    nodeEnv: value.NODE_ENV,
    providerName: value.FOOD_ANALYSIS_PROVIDER,
    maxImageBytes: Math.floor(value.MAX_IMAGE_SIZE_MB * 1024 * 1024),
    mockDelayMs: value.MOCK_ANALYSIS_DELAY_MS,
    mockForceError: value.MOCK_ANALYSIS_FORCE_ERROR,
    mockNoFood: value.MOCK_ANALYSIS_NO_FOOD,
    corsOrigins: value.CORS_ORIGINS.split(',').map((origin) => origin.trim()),
    rateLimitWindowMs: value.RATE_LIMIT_WINDOW_MS,
    rateLimitMaxRequests: value.RATE_LIMIT_MAX_REQUESTS
  };
}
