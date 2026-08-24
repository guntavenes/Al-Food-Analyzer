import { AppError } from '../errors.js';
import type { AnalysisUsageRepository } from './analysis-usage-repository.js';

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
}
