import { AppError } from '../errors.js';
import type { AnalysisUsageRepository } from './analysis-usage-repository.js';

export class SupabaseAnalysisUsageRepository implements AnalysisUsageRepository {
  private readonly endpoint: string;

  constructor(supabaseUrl: string, private readonly secretKey: string) {
    this.endpoint = `${supabaseUrl.replace(/\/$/, '')}/rest/v1/analysis_usage`;
  }

  async recordAnalysis(userId: string, requestId: string): Promise<void> {
    const response = await fetch(this.endpoint, {
      method: 'POST',
      headers: {
        apikey: this.secretKey,
        'content-type': 'application/json',
        prefer: 'return=minimal'
      },
      body: JSON.stringify({ user_id: userId, request_id: requestId })
    });
    if (!response.ok) {
      throw new AppError('SERVICE_UNAVAILABLE', 'Usage tracking is temporarily unavailable.', 503);
    }
  }
}
