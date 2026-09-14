import { AppError } from '../errors.js';
import type { AnalysisUsageRepository, AppleSubscriptionEvent, PremiumEntitlement } from './analysis-usage-repository.js';

export class SupabaseAnalysisUsageRepository implements AnalysisUsageRepository {
  private readonly claimEndpoint: string;
  private readonly releaseEndpoint: string;

  constructor(supabaseUrl: string, private readonly secretKey: string) {
    const rpcEndpoint = `${supabaseUrl.replace(/\/$/, '')}/rest/v1/rpc`;
    this.claimEndpoint = `${rpcEndpoint}/claim_analysis_entitlement`;
    this.releaseEndpoint = `${rpcEndpoint}/release_analysis_entitlement`;
  }

  async claimAnalysis(userId: string, requestId: string): Promise<void> {
    try {
      const response = await fetch(this.claimEndpoint, {
        method: 'POST',
        headers: {
          apikey: this.secretKey,
          'content-type': 'application/json',
          prefer: 'return=representation'
        },
        body: JSON.stringify({ p_user_id: userId, p_request_id: requestId })
      });
      if (response.ok) {
        const result: unknown = await response.json();
        if (result === 'free' || result === 'premium' || result === 'duplicate') return;
        if (result === 'premium_required') {
          throw new AppError('PREMIUM_REQUIRED', 'A premium membership is required.', 402);
        }
      }
      console.error(JSON.stringify({ component: 'usage_tracking', category: 'http_error', status: response.status }));
    } catch (error) {
      if (error instanceof AppError) throw error;
      console.error(JSON.stringify({
        component: 'usage_tracking',
        category: 'network_error',
        errorType: error instanceof Error ? error.name : 'UnknownError'
      }));
    }
    throw new AppError('SERVICE_UNAVAILABLE', 'Usage tracking is temporarily unavailable.', 503);
  }

  async releaseAnalysis(userId: string, requestId: string): Promise<void> {
    try {
      const response = await fetch(this.releaseEndpoint, {
        method: 'POST',
        headers: {
          apikey: this.secretKey,
          'content-type': 'application/json',
          prefer: 'return=minimal'
        },
        body: JSON.stringify({ p_user_id: userId, p_request_id: requestId })
      });
      if (response.ok) return;
      console.error(JSON.stringify({ component: 'usage_release', category: 'http_error', status: response.status }));
    } catch (error) {
      console.error(JSON.stringify({
        component: 'usage_release',
        category: 'network_error',
        errorType: error instanceof Error ? error.name : 'UnknownError'
      }));
    }
  }

  async activatePremium(
    userId: string,
    premiumUntil: Date,
    transactionId: string,
    originalTransactionId?: string,
    productId?: string
  ): Promise<void> {
    const response = await fetch(`${this.claimEndpoint.replace('/rpc/claim_analysis_entitlement', '/user_entitlements')}?on_conflict=user_id`, {
      method: 'POST',
      headers: {
        apikey: this.secretKey,
        'content-type': 'application/json',
        prefer: 'resolution=merge-duplicates,return=minimal'
      },
      body: JSON.stringify({
        user_id: userId,
        premium_until: premiumUntil.toISOString(),
        premium_source: 'apple',
        premium_transaction_id: transactionId,
        apple_original_transaction_id: originalTransactionId,
        apple_product_id: productId,
        subscription_status: 'active',
        updated_at: new Date().toISOString()
      })
    });
    if (!response.ok) {
      throw new AppError('SERVICE_UNAVAILABLE', 'Premium access could not be updated.', 503);
    }
  }

  async applyAppleSubscriptionEvent(event: AppleSubscriptionEvent): Promise<void> {
    const response = await fetch(`${this.claimEndpoint.replace('/rpc/claim_analysis_entitlement', '/user_entitlements')}?on_conflict=user_id`, {
      method: 'POST',
      headers: {
        apikey: this.secretKey,
        'content-type': 'application/json',
        prefer: 'resolution=merge-duplicates,return=minimal'
      },
      body: JSON.stringify({
        user_id: event.userId,
        premium_until: event.premiumUntil.toISOString(),
        premium_source: 'apple',
        premium_transaction_id: event.transactionId,
        apple_original_transaction_id: event.originalTransactionId,
        apple_product_id: event.productId,
        subscription_status: event.status,
        auto_renew_enabled: event.autoRenewEnabled,
        updated_at: new Date().toISOString()
      })
    });
    if (!response.ok) {
      throw new AppError('SERVICE_UNAVAILABLE', 'Subscription status could not be updated.', 503);
    }
  }

  async getPremiumEntitlement(userId: string): Promise<PremiumEntitlement> {
    const endpoint = this.claimEndpoint.replace('/rpc/claim_analysis_entitlement', '/user_entitlements');
    const response = await fetch(
      `${endpoint}?user_id=eq.${encodeURIComponent(userId)}&select=free_analyses_used,premium_until,subscription_status,auto_renew_enabled`,
      { headers: { apikey: this.secretKey } }
    );
    if (!response.ok) {
      throw new AppError('SERVICE_UNAVAILABLE', 'Premium status could not be loaded.', 503);
    }
    const rows = await response.json() as Array<{
      free_analyses_used: number;
      premium_until: string | null;
      subscription_status?: string;
      auto_renew_enabled?: boolean | null;
    }>;
    const row = rows[0];
    const premiumUntil = row?.premium_until ? new Date(row.premium_until) : null;
    return {
      isPremium: premiumUntil != null && premiumUntil.getTime() > Date.now(),
      freeAnalysesUsed: row?.free_analyses_used ?? 0,
      premiumUntil,
      status: row?.subscription_status ?? 'inactive',
      autoRenewEnabled: row?.auto_renew_enabled ?? null
    };
  }
}
