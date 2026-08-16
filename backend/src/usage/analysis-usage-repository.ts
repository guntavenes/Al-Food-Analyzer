export interface AnalysisUsageRepository {
  recordAnalysis(userId: string, requestId: string): Promise<void>;
}

export class NoopAnalysisUsageRepository implements AnalysisUsageRepository {
  async recordAnalysis(userId: string, requestId: string): Promise<void> {
    void userId;
    void requestId;
  }
}
