export interface AnalysisUsageRepository {
  claimAnalysis(userId: string, requestId: string): Promise<void>;
  releaseAnalysis(userId: string, requestId: string): Promise<void>;
  activatePremium?(userId: string, premiumUntil: Date, transactionId: string): Promise<void>;
  applyAppleSubscriptionEvent?(event: AppleSubscriptionEvent): Promise<void>;
  getPremiumEntitlement?(userId: string): Promise<PremiumEntitlement>;
}

export type PremiumEntitlement = {
  isPremium: boolean;
  premiumUntil: Date | null;
  status: string;
  autoRenewEnabled: boolean | null;
};

export type AppleSubscriptionEvent = {
  userId: string;
  productId: string;
  transactionId: string;
  originalTransactionId: string;
  premiumUntil: Date;
  status: 'active' | 'canceled' | 'expired' | 'revoked';
  autoRenewEnabled: boolean | null;
};

export class NoopAnalysisUsageRepository implements AnalysisUsageRepository {
  async claimAnalysis(userId: string, requestId: string): Promise<void> {
    void userId;
    void requestId;
  }

  async releaseAnalysis(userId: string, requestId: string): Promise<void> {
    void userId;
    void requestId;
  }
}
