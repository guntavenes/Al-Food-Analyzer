import { randomUUID } from 'node:crypto';
import cors from 'cors';
import express, { type NextFunction, type Request, type Response } from 'express';
import rateLimit from 'express-rate-limit';
import helmet from 'helmet';
import multer from 'multer';
import { localeSchema, foodAnalysisResponseSchema } from './contracts.js';
import type { AppConfig } from './config.js';
import { AppError, errorHandler } from './errors.js';
import { validateImage } from './image-validation.js';
import { MockFoodAnalysisProvider } from './providers/mock-food-analysis-provider.js';
import { OpenAIFoodAnalysisProvider } from './providers/openai-food-analysis-provider.js';
import type { FoodAnalysisProvider } from './providers/food-analysis-provider.js';

export function createApp(config: AppConfig, providerOverride?: FoodAnalysisProvider) {
  const app = express();
  const provider = providerOverride ?? (config.providerName === 'mock'
    ? new MockFoodAnalysisProvider(config.mockDelayMs, config.mockForceError, config.mockNoFood)
    : new OpenAIFoodAnalysisProvider());
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
  app.post('/v1/food/analyze', upload.single('image'), async (request, response, next) => {
    try {
      const image = validateImage(request.file);
      const localeResult = localeSchema.safeParse(request.body.locale || undefined);
      if (!localeResult.success) throw new AppError('INVALID_IMAGE', 'The locale value is invalid.', 400);
      const result = await provider.analyze(
        { image: image.buffer, mimeType: image.mimetype, locale: localeResult.data },
        request.id
      );
      response.json(foodAnalysisResponseSchema.parse(result));
    } catch (error) {
      next(error);
    }
  });
  app.use((_request, _response, next) => next(new AppError('INTERNAL_ERROR', 'Route not found.', 404)));
  app.use(errorHandler);
  return app;
}
