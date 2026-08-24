export interface AnalysisUsageRepository {
  claimAnalysis(userId: string, requestId: string): Promise<void>;
  releaseAnalysis(userId: string, requestId: string): Promise<void>;
}

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
