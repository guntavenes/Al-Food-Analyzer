import 'package:ai_food_analyzer/core/localization/locale_providers.dart';
import 'package:ai_food_analyzer/features/analysis/presentation/providers/food_analysis_providers.dart';
import 'package:ai_food_analyzer/features/menu_scan/data/menu_analysis_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final menuAnalysisServiceProvider = Provider((ref) {
  return MenuAnalysisService(
    ref.watch(foodAnalysisDioProvider),
    ref.watch(accessTokenProvider),
  );
});

final menuAnalysisLocaleProvider = Provider((ref) {
  return ref.watch(appLocaleProvider).value?.languageCode ?? 'en';
});
