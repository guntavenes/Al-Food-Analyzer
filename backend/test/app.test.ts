import request from 'supertest';
import { describe, expect, it } from 'vitest';
import { createApp } from '../src/app.js';
import type { AppConfig } from '../src/config.js';

const png = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10, 1, 2, 3]);
const baseConfig: AppConfig = {
  port: 8080, nodeEnv: 'test', providerName: 'mock', maxImageBytes: 8 * 1024 * 1024,
  mockDelayMs: 0, mockForceError: false, mockNoFood: false,
  corsOrigins: ['http://localhost'], rateLimitWindowMs: 60000, rateLimitMaxRequests: 30,
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
});
