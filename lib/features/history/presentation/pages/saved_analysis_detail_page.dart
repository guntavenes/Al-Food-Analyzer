import 'package:ai_food_analyzer/features/analysis/presentation/pages/food_analysis_result_page.dart';
import 'package:ai_food_analyzer/features/history/presentation/providers/history_providers.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SavedAnalysisDetailPage extends ConsumerWidget {
  const SavedAnalysisDetailPage({required this.analysisId, super.key});

  final int analysisId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final analysis = ref.watch(savedAnalysisProvider(analysisId));

    return analysis.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.historyLoadFailed, textAlign: TextAlign.center),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(savedAnalysisProvider(analysisId)),
                  child: Text(l10n.tryAgain),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (savedAnalysis) {
        if (savedAnalysis == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.analysisNotFound)),
          );
        }

        return FoodAnalysisResultPage(
          arguments: FoodAnalysisResultArguments(
            imagePath: savedAnalysis.imagePath,
            analysis: savedAnalysis,
            initiallySaved: true,
          ),
        );
      },
    );
  }
}
