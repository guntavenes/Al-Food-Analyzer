import { afterEach, describe, expect, it, vi } from 'vitest';
import { SupabaseAnalysisUsageRepository } from '../src/usage/supabase-analysis-usage-repository.js';

describe('SupabaseAnalysisUsageRepository', () => {
  afterEach(() => vi.unstubAllGlobals());

  it('uses the secret only as an apikey header', async () => {
    const fetchMock = vi.fn().mockResolvedValue(new Response(null, { status: 201 }));
    vi.stubGlobal('fetch', fetchMock);
    const repository = new SupabaseAnalysisUsageRepository(
      'https://project.supabase.co',
      'sb_secret_test'
    );

    await repository.recordAnalysis(
      '3d13ab9e-2bb0-4949-b352-02fb91e1761e',
      '58a33c0e-32fb-491b-9b25-841e38baa8a6'
    );

    const [, options] = fetchMock.mock.calls[0] as [string, RequestInit];
    expect(options.headers).toMatchObject({ apikey: 'sb_secret_test' });
    expect(options.headers).not.toHaveProperty('authorization');
  });
});
