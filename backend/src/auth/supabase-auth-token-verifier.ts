import { createRemoteJWKSet, jwtVerify } from 'jose';
import { z } from 'zod';
import { AppError } from '../errors.js';
import type { AuthenticatedUser, AuthTokenVerifier } from './auth-token-verifier.js';

const claimsSchema = z.object({
  sub: z.uuid(),
  role: z.literal('authenticated'),
  is_anonymous: z.boolean().optional().default(false)
});

export class SupabaseAuthTokenVerifier implements AuthTokenVerifier {
  private readonly issuer: string;
  private readonly jwks: ReturnType<typeof createRemoteJWKSet>;

  constructor(supabaseUrl: string) {
    const normalizedUrl = supabaseUrl.replace(/\/$/, '');
    this.issuer = `${normalizedUrl}/auth/v1`;
    this.jwks = createRemoteJWKSet(new URL(`${this.issuer}/.well-known/jwks.json`));
  }

  async verify(token: string): Promise<AuthenticatedUser> {
    try {
      const { payload } = await jwtVerify(token, this.jwks, {
        issuer: this.issuer,
        audience: 'authenticated'
      });
      const claims = claimsSchema.parse(payload);
      return { userId: claims.sub, isAnonymous: claims.is_anonymous };
    } catch {
      throw new AppError('UNAUTHORIZED', 'A valid user session is required.', 401);
    }
  }
}
