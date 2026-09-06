import type { MenuAnalyzeInput, MenuAnalysisResponse } from '../contracts.js';

export interface MenuAnalysisProvider {
  readonly name: string;
  analyzeMenu(input: MenuAnalyzeInput, requestId: string): Promise<MenuAnalysisResponse>;
}
