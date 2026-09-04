import type { NextFunction, Request, Response } from 'express';
import multer from 'multer';

export type ErrorCode =
  | 'UNAUTHORIZED'
  | 'PREMIUM_REQUIRED'
  | 'PURCHASE_INVALID'
  | 'PURCHASE_EXPIRED'
  | 'PURCHASE_CONFIGURATION_ERROR'
  | 'INVALID_IMAGE'
  | 'IMAGE_TOO_LARGE'
  | 'UNSUPPORTED_IMAGE_TYPE'
  | 'RATE_LIMITED'
  | 'ANALYSIS_FAILED'
  | 'SERVICE_UNAVAILABLE'
  | 'INTERNAL_ERROR';

export class AppError extends Error {
  constructor(
    public readonly code: ErrorCode,
    message: string,
    public readonly statusCode: number
  ) {
    super(message);
  }
}

export function errorHandler(
  error: unknown,
  request: Request,
  response: Response,
  _next: NextFunction
): void {
  void _next;
  let appError: AppError;
  if (error instanceof multer.MulterError && error.code === 'LIMIT_FILE_SIZE') {
    appError = new AppError('IMAGE_TOO_LARGE', 'The uploaded image is too large.', 413);
  } else if (error instanceof AppError) {
    appError = error;
  } else {
    appError = new AppError('INTERNAL_ERROR', 'An unexpected error occurred.', 500);
  }

  response.status(appError.statusCode).json({
    error: {
      code: appError.code,
      message: appError.message,
      requestId: request.id
    }
  });
}
