import request from 'supertest';
import { describe, expect, it } from 'vitest';
import { createApp } from '../src/app.js';
import { AppError } from '../src/errors.js';
import type { AppConfig } from '../src/config.js';
import type { AuthTokenVerifier } from '../src/auth/auth-token-verifier.js';
import type { AnalysisUsageRepository, AppleSubscriptionEvent } from '../src/usage/analysis-usage-repository.js';
import type { FoodAnalysisProvider } from '../src/providers/food-analysis-provider.js';
import type { AnalyzeInput } from '../src/contracts.js';
import { MockFoodAnalysisProvider } from '../src/providers/mock-food-analysis-provider.js';
import type { AppleNotificationVerifying, ApplePurchaseVerifying } from '../src/purchases/apple-purchase-verifier.js';
import type { MenuAnalysisProvider } from '../src/providers/menu-analysis-provider.js';
import type { AccountDeletionService } from '../src/account/supabase-account-deletion-service.js';
import type {
  AppleProviderCredential,
  AppleTokenRevoking
} from '../src/auth/apple-token-revocation-service.js';

const png = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10, 1, 2, 3]);
const baseConfig: AppConfig = {
  port: 8080, nodeEnv: 'test', providerName: 'mock', maxImageBytes: 8 * 1024 * 1024,
  mockDelayMs: 0, mockForceError: false, mockNoFood: false,
  corsOrigins: ['http://localhost'], rateLimitWindowMs: 60000, rateLimitMaxRequests: 30,
  analysisRateLimitWindowMs: 3600000, analysisRateLimitMaxRequests: 10,
  authRequired: false,
  appleIapEnabled: false,
  appleBundleId: 'com.enesguntav.aiFoodAnalyzer',
  appleAppId: 6806656867,
  appleRootCertificates: [],
  openaiTimeoutMs: 30000, openaiMaxRetries: 1,
  openaiReasoningEffort: 'low', openaiImageDetail: 'low'
};

describe('backend API', () => {
  it('returns health status', async () => {
    const response = await request(createApp(baseConfig)).get('/health');
    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: 'ok', provider: 'mock' });
  });

  it('serves public privacy and terms pages', async () => {
    const app = createApp(baseConfig);
    const privacy = await request(app).get('/privacy');
    const terms = await request(app).get('/terms');

    expect(privacy.status).toBe(200);
    expect(privacy.type).toMatch(/html/);
    expect(privacy.text).toContain('AI Food Analyzer Privacy Policy');
    expect(privacy.text).toContain('mailto:guntav.enes@gmail.com');
    expect(terms.status).toBe(200);
    expect(terms.type).toMatch(/html/);
    expect(terms.text).toContain('AI Food Analyzer Terms of Use');
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

  it('analyzes a restaurant menu and returns a listed recommendation', async () => {
    const response = await request(createApp(baseConfig, { menuProvider: new TestMenuAnalysisProvider() }))
      .post('/v1/menu/analyze')
      .field('locale', 'tr')
      .attach('image', png, { filename: 'menu.png', contentType: 'image/png' });

    expect(response.status).toBe(200);
    expect(response.body.recommendedItemName).toBe('Izgara tavuk salata');
    expect(response.body.items).toHaveLength(2);
    expect(response.body.items[0]).toMatchObject({ healthScore: 88 });
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

  it('claims usage for an authenticated analysis', async () => {
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

  it('allows an anonymous session to use the guest analysis flow', async () => {
    const usageRepository = new TestUsageRepository();
    const response = await request(createApp({ ...baseConfig, authRequired: true }, {
      authTokenVerifier: new TestAnonymousAuthTokenVerifier(),
      usageRepository
    })).post('/v1/food/analyze')
      .set('Authorization', 'Bearer anonymous-token')
      .attach('image', png, { filename: 'meal.png', contentType: 'image/png' });

    expect(response.status).toBe(200);
    expect(usageRepository.userIds).toEqual(['7fc176c2-44dd-41be-a0de-c606aa0b4383']);
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

  it('returns premium required without calling the analysis provider', async () => {
    const provider = new CountingFoodAnalysisProvider();
    const response = await request(createApp({ ...baseConfig, authRequired: true }, {
      provider,
      authTokenVerifier: new TestAuthTokenVerifier(),
      usageRepository: new PremiumRequiredUsageRepository()
    })).post('/v1/food/analyze')
      .set('Authorization', 'Bearer valid-token')
      .attach('image', png, { filename: 'meal.png', contentType: 'image/png' });
    expect(response.status).toBe(402);
    expect(response.body.error.code).toBe('PREMIUM_REQUIRED');
    expect(provider.callCount).toBe(0);
  });

  it('verifies an App Store subscription and activates premium access', async () => {
    const usageRepository = new TestUsageRepository();
    const response = await request(createApp({ ...baseConfig, authRequired: true }, {
      authTokenVerifier: new TestAuthTokenVerifier(),
      usageRepository,
      applePurchaseVerifier: new TestApplePurchaseVerifier()
    })).post('/v1/subscriptions/apple/verify')
      .set('Authorization', 'Bearer valid-token')
      .send({ signedTransaction: 'signed-transaction-value-for-testing' });

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      productId: 'com.enesguntav.aifood.premium.monthly',
      transactionId: 'test-transaction-id'
    });
    expect(usageRepository.premiumActivations).toEqual([{
      userId: '3d13ab9e-2bb0-4949-b352-02fb91e1761e',
      transactionId: 'test-transaction-id'
    }]);
  });

  it('returns the authenticated user premium entitlement', async () => {
    const response = await request(createApp({ ...baseConfig, authRequired: true }, {
      authTokenVerifier: new TestAuthTokenVerifier(),
      usageRepository: new TestUsageRepository()
    })).get('/v1/account/entitlement')
      .set('Authorization', 'Bearer valid-token');

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      isPremium: true,
      status: 'active',
      autoRenewEnabled: true
    });
  });

  it('deletes the authenticated account and associated data', async () => {
    const deletionService = new TestAccountDeletionService();
    const response = await request(createApp({ ...baseConfig, authRequired: true }, {
      authTokenVerifier: new TestAuthTokenVerifier(),
      usageRepository: new TestUsageRepository(),
      accountDeletionService: deletionService
    })).delete('/v1/account').set('Authorization', 'Bearer valid-token');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ appleAuthorizationRevoked: null });
    expect(deletionService.deletedUserIds).toEqual(['3d13ab9e-2bb0-4949-b352-02fb91e1761e']);
  });

  it('revokes Apple authorization before deleting an Apple account', async () => {
    const deletionService = new TestAccountDeletionService();
    const appleTokenRevoker = new TestAppleTokenRevoker();
    const response = await request(createApp({ ...baseConfig, authRequired: true }, {
      authTokenVerifier: new TestAuthTokenVerifier(),
      usageRepository: new TestUsageRepository(),
      accountDeletionService: deletionService,
      appleTokenRevoker
    })).delete('/v1/account')
      .set('Authorization', 'Bearer valid-token')
      .send({
        appleProviderToken: 'apple-provider-refresh-token-value',
        appleProviderTokenType: 'refresh_token'
      });

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ appleAuthorizationRevoked: true });
    expect(appleTokenRevoker.credentials).toEqual([{
      token: 'apple-provider-refresh-token-value',
      tokenType: 'refresh_token'
    }]);
    expect(deletionService.deletedUserIds).toEqual(['3d13ab9e-2bb0-4949-b352-02fb91e1761e']);
  });

  it('deletes the account and reports when Apple authorization cannot be revoked', async () => {
    const deletionService = new TestAccountDeletionService();
    const response = await request(createApp({ ...baseConfig, authRequired: true }, {
      authTokenVerifier: new TestAuthTokenVerifier(),
      usageRepository: new TestUsageRepository(),
      accountDeletionService: deletionService
    })).delete('/v1/account')
      .set('Authorization', 'Bearer valid-token')
      .send({
        appleProviderToken: 'apple-provider-access-token-value',
        appleProviderTokenType: 'access_token'
      });

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ appleAuthorizationRevoked: false });
    expect(deletionService.deletedUserIds).toEqual(['3d13ab9e-2bb0-4949-b352-02fb91e1761e']);
  });

  it('rejects App Store subscription verification without a session', async () => {
    const response = await request(createApp({ ...baseConfig, authRequired: true }, {
      authTokenVerifier: new TestAuthTokenVerifier(),
      usageRepository: new TestUsageRepository(),
      applePurchaseVerifier: new TestApplePurchaseVerifier()
    })).post('/v1/subscriptions/apple/verify')
      .send({ signedTransaction: 'signed-transaction-value-for-testing' });

    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('UNAUTHORIZED');
  });

  it('applies a verified App Store cancellation notification', async () => {
    const usageRepository = new TestUsageRepository();
    const response = await request(createApp(baseConfig, {
      usageRepository,
      appleNotificationVerifier: new TestAppleNotificationVerifier()
    })).post('/v1/subscriptions/apple/notifications')
      .send({ signedPayload: 'signed-notification-value-for-testing' });

    expect(response.status).toBe(200);
    expect(usageRepository.subscriptionEvents).toHaveLength(1);
    expect(usageRepository.subscriptionEvents[0]).toMatchObject({
      status: 'canceled',
      autoRenewEnabled: false
    });
  });
});

class TestAuthTokenVerifier implements AuthTokenVerifier {
  async verify(token: string) {
    if (token !== 'valid-token') throw new AppError('UNAUTHORIZED', 'Invalid session.', 401);
    return { userId: '3d13ab9e-2bb0-4949-b352-02fb91e1761e', isAnonymous: false };
  }
}

class TestAnonymousAuthTokenVerifier implements AuthTokenVerifier {
  async verify(token: string) {
    if (token !== 'anonymous-token') throw new AppError('UNAUTHORIZED', 'Invalid session.', 401);
    return { userId: '7fc176c2-44dd-41be-a0de-c606aa0b4383', isAnonymous: true };
  }
}

class TestAccountDeletionService implements AccountDeletionService {
  readonly deletedUserIds: string[] = [];

  async deleteAccount(userId: string) {
    this.deletedUserIds.push(userId);
  }
}

class TestAppleTokenRevoker implements AppleTokenRevoking {
  readonly credentials: AppleProviderCredential[] = [];

  async revoke(credential: AppleProviderCredential) {
    this.credentials.push(credential);
  }
}

class TestUsageRepository implements AnalysisUsageRepository {
  readonly userIds: string[] = [];
  readonly premiumActivations: Array<{ userId: string; transactionId: string }> = [];
  readonly subscriptionEvents: AppleSubscriptionEvent[] = [];

  async claimAnalysis(userId: string, requestId: string): Promise<void> {
    void requestId;
    this.userIds.push(userId);
  }

  async releaseAnalysis(): Promise<void> {}

  async activatePremium(userId: string, premiumUntil: Date, transactionId: string): Promise<void> {
    void premiumUntil;
    this.premiumActivations.push({ userId, transactionId });
  }

  async applyAppleSubscriptionEvent(event: AppleSubscriptionEvent): Promise<void> {
    this.subscriptionEvents.push(event);
  }

  async getPremiumEntitlement() {
    return {
      isPremium: true,
      freeAnalysesUsed: 1,
      premiumUntil: new Date('2030-01-01T00:00:00.000Z'),
      status: 'active',
      autoRenewEnabled: true
    };
  }
}

class TestApplePurchaseVerifier implements ApplePurchaseVerifying {
  async verify() {
    return {
      productId: 'com.enesguntav.aifood.premium.monthly',
      transactionId: 'test-transaction-id',
      originalTransactionId: 'test-original-transaction-id',
      expiresAt: new Date('2030-01-01T00:00:00.000Z')
    };
  }
}

class TestAppleNotificationVerifier implements AppleNotificationVerifying {
  async verifyNotification(): Promise<AppleSubscriptionEvent> {
    return {
      userId: '3d13ab9e-2bb0-4949-b352-02fb91e1761e',
      productId: 'com.enesguntav.aifood.premium.monthly',
      transactionId: 'renewal-transaction-id',
      originalTransactionId: 'original-transaction-id',
      premiumUntil: new Date('2030-02-01T00:00:00.000Z'),
      status: 'canceled',
      autoRenewEnabled: false
    };
  }
}

class FailingUsageRepository implements AnalysisUsageRepository {
  async claimAnalysis(): Promise<void> {
    throw new AppError('SERVICE_UNAVAILABLE', 'Usage unavailable.', 503);
  }

  async releaseAnalysis(): Promise<void> {}
}

class PremiumRequiredUsageRepository implements AnalysisUsageRepository {
  async claimAnalysis(): Promise<void> {
    throw new AppError('PREMIUM_REQUIRED', 'Premium required.', 402);
  }

  async releaseAnalysis(): Promise<void> {}
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

class TestMenuAnalysisProvider implements MenuAnalysisProvider {
  readonly name = 'test-menu';

  async analyzeMenu(_input: Parameters<MenuAnalysisProvider['analyzeMenu']>[0], requestId: string) {
    return {
      requestId,
      restaurantName: 'Test Restoran',
      summary: 'Izgara tavuk salata daha dengeli bir seçimdir.',
      recommendedItemName: 'Izgara tavuk salata',
      confidence: 0.9,
      items: [
        {
          name: 'Izgara tavuk salata',
          description: 'Tavuk ve mevsim yeşillikleri',
          estimatedCaloriesMin: 380,
          estimatedCaloriesMax: 520,
          healthScore: 88,
          reasons: ['Protein ve sebze dengesi iyi.'],
          concerns: []
        },
        {
          name: 'Kremalı makarna',
          description: 'Krema soslu makarna',
          estimatedCaloriesMin: 700,
          estimatedCaloriesMax: 950,
          healthScore: 48,
          reasons: [],
          concerns: ['Krema nedeniyle enerji yoğun olabilir.']
        }
      ]
    };
  }
}
