import { afterEach, describe, expect, it, vi } from 'vitest';
import type { AppError } from '../src/errors.js';
import { SupabaseAnalysisUsageRepository } from '../src/usage/supabase-analysis-usage-repository.js';

describe('SupabaseAnalysisUsageRepository', () => {
  afterEach(() => vi.unstubAllGlobals());

  it('claims the first free analysis through the atomic RPC', async () => {
    const fetchMock = vi.fn().mockResolvedValue(
      new Response(JSON.stringify('free'), { status: 200 })
    );
    vi.stubGlobal('fetch', fetchMock);
    const repository = new SupabaseAnalysisUsageRepository(
      'https://project.supabase.co',
      'sb_secret_test'
    );

    await repository.claimAnalysis(
      '3d13ab9e-2bb0-4949-b352-02fb91e1761e',
      '58a33c0e-32fb-491b-9b25-841e38baa8a6'
    );

    const [url, options] = fetchMock.mock.calls[0] as [string, RequestInit];
    expect(url).toContain('/rpc/claim_analysis_entitlement');
    expect(options.headers).toMatchObject({ apikey: 'sb_secret_test' });
  });

  it('returns premium required when the free analysis was used', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(
      new Response(JSON.stringify('premium_required'), { status: 200 })
    ));
    const repository = new SupabaseAnalysisUsageRepository(
      'https://project.supabase.co',
      'sb_secret_test'
    );

    await expect(repository.claimAnalysis(
      '3d13ab9e-2bb0-4949-b352-02fb91e1761e',
      '58a33c0e-32fb-491b-9b25-841e38baa8a6'
    )).rejects.toMatchObject({ code: 'PREMIUM_REQUIRED', statusCode: 402 } satisfies Partial<AppError>);
  });
});
