import { importPKCS8, SignJWT } from 'jose';
import { AppError } from '../errors.js';

export type AppleProviderCredential = {
  token: string;
  tokenType: 'access_token' | 'refresh_token';
};

export interface AppleTokenRevoking {
  revoke(credential: AppleProviderCredential): Promise<void>;
}

export class AppleTokenRevocationService implements AppleTokenRevoking {
  constructor(
    private readonly clientId: string,
    private readonly teamId: string,
    private readonly keyId: string,
    private readonly privateKeyPem: string
  ) {}

  async revoke(credential: AppleProviderCredential): Promise<void> {
    let key;
    try {
      key = await importPKCS8(this.privateKeyPem, 'ES256');
    } catch {
      throw new AppError(
        'APPLE_AUTH_CONFIGURATION_ERROR',
        'Apple account revocation is not configured correctly.',
        503
      );
    }

    const now = Math.floor(Date.now() / 1000);
    const clientSecret = await new SignJWT({})
      .setProtectedHeader({ alg: 'ES256', kid: this.keyId })
      .setIssuer(this.teamId)
      .setSubject(this.clientId)
      .setAudience('https://appleid.apple.com')
      .setIssuedAt(now)
      .setExpirationTime(now + 300)
      .sign(key);

    const response = await fetch('https://appleid.apple.com/auth/revoke', {
      method: 'POST',
      headers: { 'content-type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        client_id: this.clientId,
        client_secret: clientSecret,
        token: credential.token,
        token_type_hint: credential.tokenType
      })
    });

    if (!response.ok) {
      throw new AppError(
        'APPLE_AUTH_REVOCATION_FAILED',
        'Apple account authorization could not be revoked.',
        503
      );
    }
  }
}
