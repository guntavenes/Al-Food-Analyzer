import { Environment, NotificationTypeV2, SignedDataVerifier, Subtype } from '@apple/app-store-server-library';
import { AppError } from '../errors.js';
import type { AppleSubscriptionEvent } from '../usage/analysis-usage-repository.js';

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

export interface AppleNotificationVerifying {
  verifyNotification(signedPayload: string): Promise<AppleSubscriptionEvent | null>;
}

export class ApplePurchaseVerifier implements ApplePurchaseVerifying, AppleNotificationVerifying {
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

  async verifyNotification(signedPayload: string): Promise<AppleSubscriptionEvent | null> {
    let notification;
    try {
      notification = await this.production.verifyAndDecodeNotification(signedPayload);
    } catch {
      try {
        notification = await this.sandbox.verifyAndDecodeNotification(signedPayload);
      } catch {
        throw new AppError('PURCHASE_INVALID', 'The App Store notification is invalid.', 400);
      }
    }

    if (notification.notificationType === NotificationTypeV2.TEST) return null;
    const signedTransaction = notification.data?.signedTransactionInfo;
    if (!signedTransaction) return null;
    const transaction = notification.data?.environment === Environment.SANDBOX
      ? await this.sandbox.verifyAndDecodeTransaction(signedTransaction)
      : await this.production.verifyAndDecodeTransaction(signedTransaction);
    const {
      appAccountToken: userId,
      productId,
      transactionId,
      originalTransactionId,
      expiresDate,
      revocationDate
    } = transaction;
    if (!userId || !productId || !supportedProducts.has(productId) || !transactionId ||
        !originalTransactionId || !expiresDate) {
      throw new AppError('PURCHASE_INVALID', 'The App Store notification has incomplete transaction data.', 400);
    }

    const type = notification.notificationType;
    const revoked = type === NotificationTypeV2.REFUND || type === NotificationTypeV2.REVOKE || revocationDate != null;
    const expired = type === NotificationTypeV2.EXPIRED || type === NotificationTypeV2.GRACE_PERIOD_EXPIRED;
    const canceled = type === NotificationTypeV2.DID_CHANGE_RENEWAL_STATUS &&
      notification.subtype === Subtype.AUTO_RENEW_DISABLED;
    const premiumUntil = new Date(revoked ? Math.min(revocationDate ?? Date.now(), Date.now()) : expiresDate);
    return {
      userId,
      productId,
      transactionId,
      originalTransactionId,
      premiumUntil,
      status: revoked ? 'revoked' : expired ? 'expired' : canceled ? 'canceled' : 'active',
      autoRenewEnabled: canceled
        ? false
        : type === NotificationTypeV2.DID_CHANGE_RENEWAL_STATUS && notification.subtype === Subtype.AUTO_RENEW_ENABLED
          ? true
          : null
    };
  }
}
