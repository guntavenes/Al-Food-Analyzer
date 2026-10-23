import { exportPKCS8, generateKeyPair } from 'jose';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { AppleTokenRevocationService } from '../src/auth/apple-token-revocation-service.js';

describe('AppleTokenRevocationService', () => {
  afterEach(() => vi.unstubAllGlobals());

  it('sends an Apple provider token to the official revocation endpoint', async () => {
    const { privateKey } = await generateKeyPair('ES256', {
      extractable: true
    });
    const privateKeyPem = await exportPKCS8(privateKey);
    const fetchMock = vi.fn(
      async (input: string | URL | Request, init?: RequestInit) => {
        void input;
        void init;
        return new Response(null, { status: 200 });
      }
    );
    vi.stubGlobal('fetch', fetchMock);

    const service = new AppleTokenRevocationService(
      'com.example.web',
      'TEAM123456',
      'KEY1234567',
      privateKeyPem
    );
    await service.revoke({
      token: 'apple-refresh-token-value',
      tokenType: 'refresh_token'
    });

    expect(fetchMock).toHaveBeenCalledOnce();
    const [url, init] = fetchMock.mock.calls[0]!;
    expect(url).toBe('https://appleid.apple.com/auth/revoke');
    expect(init?.method).toBe('POST');
    const body = init?.body as URLSearchParams;
    expect(body.get('client_id')).toBe('com.example.web');
    expect(body.get('token')).toBe('apple-refresh-token-value');
    expect(body.get('token_type_hint')).toBe('refresh_token');
    expect(body.get('client_secret')?.split('.')).toHaveLength(3);
  });
});
