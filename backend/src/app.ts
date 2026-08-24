import { randomUUID } from 'node:crypto';
import cors from 'cors';
import express, { type NextFunction, type Request, type Response } from 'express';
import rateLimit, { ipKeyGenerator } from 'express-rate-limit';
import helmet from 'helmet';
import multer from 'multer';
import { requireAuth } from './auth/require-auth.js';
import { SupabaseAuthTokenVerifier } from './auth/supabase-auth-token-verifier.js';
import type { AuthTokenVerifier } from './auth/auth-token-verifier.js';
import { analysisCorrectionSchema, localeSchema, foodAnalysisResponseSchema } from './contracts.js';
import type { AppConfig } from './config.js';
import { AppError, errorHandler } from './errors.js';
import { validateImage } from './image-validation.js';
import { createFoodAnalysisProvider } from './providers/create-food-analysis-provider.js';
import type { FoodAnalysisProvider } from './providers/food-analysis-provider.js';
import { NoopAnalysisUsageRepository, type AnalysisUsageRepository } from './usage/analysis-usage-repository.js';
import { SupabaseAnalysisUsageRepository } from './usage/supabase-analysis-usage-repository.js';

type AppDependencies = {
  provider?: FoodAnalysisProvider;
  authTokenVerifier?: AuthTokenVerifier;
  usageRepository?: AnalysisUsageRepository;
};

export function createApp(config: AppConfig, dependencies: AppDependencies = {}) {
  const app = express();
  const provider = dependencies.provider ?? createFoodAnalysisProvider(config);
  const authTokenVerifier = dependencies.authTokenVerifier ?? (config.authRequired
    ? new SupabaseAuthTokenVerifier(config.supabaseUrl!)
    : undefined);
  const usageRepository = dependencies.usageRepository ?? (config.authRequired
    ? new SupabaseAnalysisUsageRepository(config.supabaseUrl!, config.supabaseSecretKey!)
    : new NoopAnalysisUsageRepository());
  const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: config.maxImageBytes, files: 1 } });

  app.disable('x-powered-by');
  app.use(helmet());
  app.use(cors({ origin: config.corsOrigins, methods: ['GET', 'POST'] }));
  app.use((request: Request, response: Response, next: NextFunction) => {
    request.id = randomUUID();
    response.setHeader('X-Request-Id', request.id);
    next();
  });
  app.use(express.json({ limit: '32kb' }));
  app.use(rateLimit({
    windowMs: config.rateLimitWindowMs,
    limit: config.rateLimitMaxRequests,
    standardHeaders: true,
    legacyHeaders: false,
    handler: (request, response) => response.status(429).json({
      error: { code: 'RATE_LIMITED', message: 'Too many requests. Please try again later.', requestId: request.id }
    })
  }));

  app.get('/health', (_request, response) => response.json({ status: 'ok', provider: provider.name }));
  const analysisRateLimiter = rateLimit({
    windowMs: config.analysisRateLimitWindowMs,
    limit: config.analysisRateLimitMaxRequests,
    keyGenerator: (request) => request.auth?.userId ?? ipKeyGenerator(request.ip ?? 'unknown'),
    standardHeaders: true,
    legacyHeaders: false,
    handler: (request, response) => response.status(429).json({
      error: { code: 'RATE_LIMITED', message: 'Too many analyses. Please try again later.', requestId: request.id }
    })
  });
  const analysisMiddleware = config.authRequired && authTokenVerifier
    ? [requireAuth(authTokenVerifier), analysisRateLimiter, upload.single('image')]
    : [analysisRateLimiter, upload.single('image')];
  app.post('/v1/food/analyze', ...analysisMiddleware, async (request, response, next) => {
    try {
      const image = validateImage(request.file);
      const localeResult = localeSchema.safeParse(request.body.locale || undefined);
      if (!localeResult.success) throw new AppError('INVALID_IMAGE', 'The locale value is invalid.', 400);
      const hasCorrection = request.body.ingredients || request.body.servingDescription;
      const correctionResult = hasCorrection ? analysisCorrectionSchema.safeParse({
        ingredients: request.body.ingredients,
        servingDescription: request.body.servingDescription
      }) : undefined;
      if (correctionResult && !correctionResult.success) {
        throw new AppError('INVALID_IMAGE', 'The correction details are invalid.', 400);
      }
      const userId = request.auth?.userId ?? 'development';
      await usageRepository.claimAnalysis(userId, request.id);
      let result;
      try {
        result = await provider.analyze(
          {
            image: image.buffer,
            mimeType: image.mimetype,
            locale: localeResult.data,
            correction: correctionResult?.data
          },
          request.id
        );
      } catch (error) {
        await usageRepository.releaseAnalysis(userId, request.id);
        throw error;
      }
      response.json(foodAnalysisResponseSchema.parse(result));
    } catch (error) {
      next(error);
    }
  });
  app.use((_request, _response, next) => next(new AppError('INTERNAL_ERROR', 'Route not found.', 404)));
  app.use(errorHandler);
  return app;
}
