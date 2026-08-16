import type { NextFunction, Request, Response } from 'express';
import { AppError } from '../errors.js';
import type { AuthTokenVerifier } from './auth-token-verifier.js';

export function requireAuth(verifier: AuthTokenVerifier) {
  return async (request: Request, _response: Response, next: NextFunction) => {
    try {
      const authorization = request.header('authorization');
      const match = authorization?.match(/^Bearer\s+(.+)$/i);
      if (!match) throw new AppError('UNAUTHORIZED', 'A valid user session is required.', 401);
      const token = match?.[1];
      if (!token) throw new AppError('UNAUTHORIZED', 'A valid user session is required.', 401);
      request.auth = await verifier.verify(token);
      next();
    } catch (error) {
      next(error);
    }
  };
}
