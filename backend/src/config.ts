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
  RATE_LIMIT_MAX_REQUESTS: z.coerce.number().int().positive().default(30),
  ANALYSIS_RATE_LIMIT_WINDOW_MS: z.coerce.number().int().positive().default(3600000),
  ANALYSIS_RATE_LIMIT_MAX_REQUESTS: z.coerce.number().int().positive().default(10),
  AUTH_REQUIRED: z.stringbool().default(false),
  SUPABASE_URL: z.url().optional(),
  SUPABASE_SERVER_KEY_V2: z.string().trim().min(1).optional(),
  OPENAI_API_KEY: z.string().trim().min(1).optional(),
  OPENAI_MODEL: z.string().trim().min(1).optional(),
  OPENAI_TIMEOUT_MS: z.coerce.number().int().min(1000).max(120000).default(30000),
  OPENAI_MAX_RETRIES: z.coerce.number().int().min(0).max(3).default(1),
  OPENAI_REASONING_EFFORT: z.enum(['none', 'low', 'medium', 'high', 'xhigh', 'max']).default('low'),
  OPENAI_IMAGE_DETAIL: z.enum(['low', 'high', 'auto']).default('low')
}).superRefine((value, context) => {
  if (value.FOOD_ANALYSIS_PROVIDER === 'openai') {
    if (!value.OPENAI_API_KEY) context.addIssue({ code: 'custom', path: ['OPENAI_API_KEY'], message: 'OPENAI_API_KEY is required when the OpenAI provider is selected.' });
    if (!value.OPENAI_MODEL) context.addIssue({ code: 'custom', path: ['OPENAI_MODEL'], message: 'OPENAI_MODEL is required when the OpenAI provider is selected.' });
  }
  if (value.AUTH_REQUIRED && !value.SUPABASE_URL) context.addIssue({ code: 'custom', path: ['SUPABASE_URL'], message: 'SUPABASE_URL is required when authentication is enabled.' });
  if (value.AUTH_REQUIRED && !value.SUPABASE_SERVER_KEY_V2) context.addIssue({ code: 'custom', path: ['SUPABASE_SERVER_KEY_V2'], message: 'SUPABASE_SERVER_KEY_V2 is required when authentication is enabled.' });
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
  analysisRateLimitWindowMs: number;
  analysisRateLimitMaxRequests: number;
  authRequired: boolean;
  supabaseUrl?: string;
  supabaseSecretKey?: string;
  openaiApiKey?: string;
  openaiModel?: string;
  openaiTimeoutMs: number;
  openaiMaxRetries: number;
  openaiReasoningEffort: 'none' | 'low' | 'medium' | 'high' | 'xhigh' | 'max';
  openaiImageDetail: 'low' | 'high' | 'auto';
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
    rateLimitMaxRequests: value.RATE_LIMIT_MAX_REQUESTS,
    analysisRateLimitWindowMs: value.ANALYSIS_RATE_LIMIT_WINDOW_MS,
    analysisRateLimitMaxRequests: value.ANALYSIS_RATE_LIMIT_MAX_REQUESTS,
    authRequired: value.AUTH_REQUIRED,
    supabaseUrl: value.SUPABASE_URL,
    supabaseSecretKey: value.SUPABASE_SERVER_KEY_V2,
    openaiApiKey: value.OPENAI_API_KEY,
    openaiModel: value.OPENAI_MODEL,
    openaiTimeoutMs: value.OPENAI_TIMEOUT_MS,
    openaiMaxRetries: value.OPENAI_MAX_RETRIES,
    openaiReasoningEffort: value.OPENAI_REASONING_EFFORT,
    openaiImageDetail: value.OPENAI_IMAGE_DETAIL
  };
}
