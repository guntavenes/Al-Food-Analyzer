import { Environment, SignedDataVerifier } from '@apple/app-store-server-library';
import { AppError } from '../errors.js';

const supportedProducts = new Set([
  'com.enesguntav.aifood.premium.monthly',
  'com.enesguntav.aifood.premium.yearly'
]);

export type VerifiedApplePurchase = {
  productId: string;
  transactionId: string;
  expiresAt: Date;
};

export interface ApplePurchaseVerifying {
  verify(signedTransaction: string, userId: string): Promise<VerifiedApplePurchase>;
}

export class ApplePurchaseVerifier implements ApplePurchaseVerifying {
  private readonly sandbox: SignedDataVerifier;
  private readonly production: SignedDataVerifier;

  constructor(rootCertificates: Buffer[], bundleId: string, appAppleId: number) {
    if (rootCertificates.length === 0) {
      throw new AppError('PURCHASE_CONFIGURATION_ERROR', 'Apple purchase verification is not configured.', 503);
    }
    this.sandbox = new SignedDataVerifier(rootCertificates, true, Environment.SANDBOX, bundleId);
    this.production = new SignedDataVerifier(rootCertificates, true, Environment.PRODUCTION, bundleId, appAppleId);
  }

  async verify(signedTransaction: string, userId: string): Promise<VerifiedApplePurchase> {
    let transaction;
    try {
      transaction = await this.production.verifyAndDecodeTransaction(signedTransaction);
    } catch {
      try {
        transaction = await this.sandbox.verifyAndDecodeTransaction(signedTransaction);
      } catch {
        throw new AppError('PURCHASE_INVALID', 'The App Store purchase could not be verified.', 400);
      }
    }

    const { productId, transactionId, expiresDate, revocationDate } = transaction;
    if (!productId || !supportedProducts.has(productId) || !transactionId || !expiresDate || revocationDate) {
      throw new AppError('PURCHASE_INVALID', 'The App Store purchase is not valid for this app.', 400);
    }
    if (transaction.appAccountToken !== userId) {
      throw new AppError('PURCHASE_INVALID', 'The App Store purchase belongs to another account.', 403);
    }
    const expiresAt = new Date(expiresDate);
    if (expiresAt.getTime() <= Date.now()) {
      throw new AppError('PURCHASE_EXPIRED', 'The App Store subscription has expired.', 409);
    }
    return { productId, transactionId, expiresAt };
  }
}
