import request from 'supertest';
import { describe, expect, it } from 'vitest';
import { createApp } from '../src/app.js';
import { AppError } from '../src/errors.js';
import type { AppConfig } from '../src/config.js';
import type { AuthTokenVerifier } from '../src/auth/auth-token-verifier.js';
import type { AnalysisUsageRepository } from '../src/usage/analysis-usage-repository.js';
import type { FoodAnalysisProvider } from '../src/providers/food-analysis-provider.js';
import type { AnalyzeInput } from '../src/contracts.js';
import { MockFoodAnalysisProvider } from '../src/providers/mock-food-analysis-provider.js';

const png = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10, 1, 2, 3]);
const baseConfig: AppConfig = {
  port: 8080, nodeEnv: 'test', providerName: 'mock', maxImageBytes: 8 * 1024 * 1024,
  mockDelayMs: 0, mockForceError: false, mockNoFood: false,
  corsOrigins: ['http://localhost'], rateLimitWindowMs: 60000, rateLimitMaxRequests: 30,
  analysisRateLimitWindowMs: 3600000, analysisRateLimitMaxRequests: 10,
  authRequired: false,
  openaiTimeoutMs: 30000, openaiMaxRetries: 1, openaiImageDetail: 'low'
};

describe('backend API', () => {
  it('returns health status', async () => {
    const response = await request(createApp(baseConfig)).get('/health');
    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: 'ok', provider: 'mock' });
  });

  it('analyzes a valid image', async () => {
    const response = await request(createApp(baseConfig)).post('/v1/food/analyze').attach('image', png, { filename: 'meal.png', contentType: 'image/png' });
    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      foodName: 'Grilled Chicken Bowl',
      isFoodDetected: true,
      confidence: 0.87,
      sugar: 8,
      sodium: 720,
      servingWeightGrams: 420,
      healthScore: 78
    });
    expect(response.body.detectedFoods).toHaveLength(3);
  });

  it('passes user corrections to the analysis provider', async () => {
    const provider = new CorrectionCapturingProvider();
    const response = await request(createApp(baseConfig, { provider }))
      .post('/v1/food/analyze')
      .field('ingredients', 'ground beef, bread, tomato salsa')
      .field('servingDescription', '6 pieces and 1 small bowl')
      .attach('image', png, { filename: 'meal.png', contentType: 'image/png' });

    expect(response.status).toBe(200);
    expect(provider.input?.correction).toEqual({
      ingredients: 'ground beef, bread, tomato salsa',
      servingDescription: '6 pieces and 1 small bowl'
    });
  });

  it('rejects a request without an image', async () => {
    const response = await request(createApp(baseConfig)).post('/v1/food/analyze');
    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('INVALID_IMAGE');
  });

  it('rejects unsupported mime types', async () => {
    const response = await request(createApp(baseConfig)).post('/v1/food/analyze').attach('image', Buffer.from('text'), { filename: 'meal.txt', contentType: 'text/plain' });
    expect(response.status).toBe(415);
    expect(response.body.error.code).toBe('UNSUPPORTED_IMAGE_TYPE');
  });

  it('rejects images over the size limit', async () => {
    const response = await request(createApp({ ...baseConfig, maxImageBytes: 8 })).post('/v1/food/analyze').attach('image', png, { filename: 'meal.png', contentType: 'image/png' });
    expect(response.status).toBe(413);
    expect(response.body.error.code).toBe('IMAGE_TOO_LARGE');
  });

  it('returns controlled provider errors', async () => {
    const response = await request(createApp({ ...baseConfig, mockForceError: true })).post('/v1/food/analyze').attach('image', png, { filename: 'meal.png', contentType: 'image/png' });
    expect(response.status).toBe(502);
    expect(response.body.error.code).toBe('ANALYSIS_FAILED');
  });

  it('returns a no-food response', async () => {
    const response = await request(createApp({ ...baseConfig, mockNoFood: true })).post('/v1/food/analyze').attach('image', png, { filename: 'meal.png', contentType: 'image/png' });
    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({ foodName: null, isFoodDetected: false, confidence: 0 });
  });

  it('rate limits excessive requests', async () => {
    const app = createApp({ ...baseConfig, rateLimitMaxRequests: 1 });
    await request(app).get('/health');
    const response = await request(app).get('/health');
    expect(response.status).toBe(429);
    expect(response.body.error.code).toBe('RATE_LIMITED');
  });

  it('rejects protected analysis requests without a bearer token', async () => {
    const response = await request(createApp({ ...baseConfig, authRequired: true }, {
      authTokenVerifier: new TestAuthTokenVerifier(),
      usageRepository: new TestUsageRepository()
    })).post('/v1/food/analyze').attach('image', png, { filename: 'meal.png', contentType: 'image/png' });
    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('UNAUTHORIZED');
  });

  it('records usage for an authenticated analysis', async () => {
    const usageRepository = new TestUsageRepository();
    const response = await request(createApp({ ...baseConfig, authRequired: true }, {
      authTokenVerifier: new TestAuthTokenVerifier(),
      usageRepository
    })).post('/v1/food/analyze')
      .set('Authorization', 'Bearer valid-token')
      .attach('image', png, { filename: 'meal.png', contentType: 'image/png' });
    expect(response.status).toBe(200);
    expect(usageRepository.userIds).toEqual(['3d13ab9e-2bb0-4949-b352-02fb91e1761e']);
  });

  it('does not call the analysis provider when usage cannot be recorded', async () => {
    const provider = new CountingFoodAnalysisProvider();
    const response = await request(createApp({ ...baseConfig, authRequired: true }, {
      provider,
      authTokenVerifier: new TestAuthTokenVerifier(),
      usageRepository: new FailingUsageRepository()
    })).post('/v1/food/analyze')
      .set('Authorization', 'Bearer valid-token')
      .attach('image', png, { filename: 'meal.png', contentType: 'image/png' });
    expect(response.status).toBe(503);
    expect(provider.callCount).toBe(0);
  });
});

class TestAuthTokenVerifier implements AuthTokenVerifier {
  async verify(token: string) {
    if (token !== 'valid-token') throw new AppError('UNAUTHORIZED', 'Invalid session.', 401);
    return { userId: '3d13ab9e-2bb0-4949-b352-02fb91e1761e', isAnonymous: true };
  }
}

class TestUsageRepository implements AnalysisUsageRepository {
  readonly userIds: string[] = [];

  async recordAnalysis(userId: string, requestId: string): Promise<void> {
    void requestId;
    this.userIds.push(userId);
  }
}

class FailingUsageRepository implements AnalysisUsageRepository {
  async recordAnalysis(): Promise<void> {
    throw new AppError('SERVICE_UNAVAILABLE', 'Usage unavailable.', 503);
  }
}

class CountingFoodAnalysisProvider implements FoodAnalysisProvider {
  readonly name = 'counting';
  callCount = 0;

  async analyze(): Promise<never> {
    this.callCount += 1;
    throw new Error('Provider must not be called.');
  }
}

class CorrectionCapturingProvider implements FoodAnalysisProvider {
  readonly name = 'capture';
  input?: AnalyzeInput;
  private readonly mock = new MockFoodAnalysisProvider(0, false, false);

  async analyze(input: AnalyzeInput, requestId: string) {
    this.input = input;
    return this.mock.analyze(input, requestId);
  }
}
