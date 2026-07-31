import 'dart:io';

import 'package:ai_food_analyzer/core/router/app_router.dart';
import 'package:ai_food_analyzer/core/theme/app_colors.dart';
import 'package:ai_food_analyzer/features/analysis/domain/errors/food_analysis_exception.dart';
import 'package:ai_food_analyzer/features/analysis/presentation/pages/food_analysis_result_page.dart';
import 'package:ai_food_analyzer/features/analysis/presentation/providers/food_analysis_providers.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PhotoPreviewPage extends ConsumerStatefulWidget {
  const PhotoPreviewPage({required this.imagePath, super.key});

  final String imagePath;

  @override
  ConsumerState<PhotoPreviewPage> createState() => _PhotoPreviewPageState();
}

class _PhotoPreviewPageState extends ConsumerState<PhotoPreviewPage> {
  bool _hasStartedAnalysis = false;

  Future<void> _analyzeFood({bool retry = false}) async {
    final provider = foodAnalysisProvider(widget.imagePath);
    if (retry) {
      ref.invalidate(provider);
    }
    setState(() => _hasStartedAnalysis = true);

    try {
      final analysis = await ref.read(provider.future);
      if (mounted) {
        await context.push(
          AppRoutes.result,
          extra: FoodAnalysisResultArguments(
            imagePath: widget.imagePath,
            analysis: analysis,
          ),
        );
      }
    } on Object {
      // The provider exposes the error state in the UI below.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final analysisState = _hasStartedAnalysis
        ? ref.watch(foodAnalysisProvider(widget.imagePath))
        : null;
    final isAnalyzing = analysisState?.isLoading ?? false;
    final hasError = analysisState?.hasError ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1714),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton.filled(
                    onPressed: context.pop,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text(
                      l10n.previewTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 22),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: ColoredBox(
                    color: Colors.black,
                    child: Image.file(
                      File(widget.imagePath),
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white54,
                            size: 64,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.mint,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.previewReady,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (hasError) ...[
                _AnalysisError(
                  message: _analysisErrorMessage(l10n, analysisState?.error),
                  retryLabel: l10n.tryAgain,
                  onRetry: () => _analyzeFood(retry: true),
                ),
                const SizedBox(height: 14),
              ],
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF22B879), AppColors.teal],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x52129B70),
                      blurRadius: 26,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: FilledButton.icon(
                  onPressed: isAnalyzing ? null : _analyzeFood,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size.fromHeight(64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: isAnalyzing
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.auto_awesome_rounded, size: 22),
                  label: Text(
                    isAnalyzing ? l10n.analyzingFood : l10n.analyzeFood,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _analysisErrorMessage(AppLocalizations l10n, Object? error) {
    if (error is! FoodAnalysisException) return l10n.analysisFailed;
    return switch (error.type) {
      FoodAnalysisErrorType.noFoodDetected => l10n.noFoodDetected,
      FoodAnalysisErrorType.invalidImage => l10n.invalidImage,
      FoodAnalysisErrorType.imageTooLarge => l10n.imageTooLarge,
      FoodAnalysisErrorType.rateLimited => l10n.rateLimited,
      FoodAnalysisErrorType.timeout => l10n.analysisTimeout,
      FoodAnalysisErrorType.network => l10n.networkError,
      FoodAnalysisErrorType.serviceUnavailable => l10n.serviceUnavailable,
      FoodAnalysisErrorType.unknown => l10n.analysisFailed,
    };
  }
}

class _AnalysisError extends StatelessWidget {
  const _AnalysisError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF3A211F),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFFFB4AB)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, height: 1.35),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(foregroundColor: AppColors.mint),
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
