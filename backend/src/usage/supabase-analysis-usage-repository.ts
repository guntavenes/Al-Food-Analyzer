import { AppError } from '../errors.js';
import type { AnalysisUsageRepository } from './analysis-usage-repository.js';

export class SupabaseAnalysisUsageRepository implements AnalysisUsageRepository {
  private readonly endpoint: string;

  constructor(supabaseUrl: string, private readonly secretKey: string) {
    this.endpoint = `${supabaseUrl.replace(/\/$/, '')}/rest/v1/analysis_usage`;
  }

  async recordAnalysis(userId: string, requestId: string): Promise<void> {
    try {
      const response = await fetch(this.endpoint, {
        method: 'POST',
        headers: {
          apikey: this.secretKey,
          'content-type': 'application/json',
          prefer: 'return=minimal'
        },
        body: JSON.stringify({ user_id: userId, request_id: requestId })
      });
      if (response.ok) return;
      console.error(JSON.stringify({ component: 'usage_tracking', category: 'http_error', status: response.status }));
    } catch (error) {
      const cause = error instanceof Error
        ? (error as Error & { cause?: { code?: unknown; name?: unknown } }).cause
        : undefined;
      console.error(JSON.stringify({
        component: 'usage_tracking',
        category: 'network_error',
        errorType: error instanceof Error ? error.name : 'UnknownError',
        causeCode: typeof cause?.code === 'string' ? cause.code : null,
        causeType: typeof cause?.name === 'string' ? cause.name : null,
        secretLength: this.secretKey.length,
        secretIsAscii: [...this.secretKey].every((character) => character.charCodeAt(0) <= 127),
        secretContainsMask: this.secretKey.includes('•')
      }));
    }

    throw new AppError('SERVICE_UNAVAILABLE', 'Usage tracking is temporarily unavailable.', 503);
  }
}
