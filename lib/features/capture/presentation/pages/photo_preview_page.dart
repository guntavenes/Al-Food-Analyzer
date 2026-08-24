import 'dart:io';

import 'package:ai_food_analyzer/core/router/app_router.dart';
import 'package:ai_food_analyzer/core/theme/app_colors.dart';
import 'package:ai_food_analyzer/core/widgets/premium_action_button.dart';
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
  bool _isRequestInFlight = false;

  Future<void> _analyzeFood({bool retry = false}) async {
    if (_isRequestInFlight) return;
    _isRequestInFlight = true;

    final provider = foodAnalysisProvider(widget.imagePath);
    if (retry) {
      ref.invalidate(provider);
    }
    final subscription = ref.listenManual(provider, (previous, next) {});
    setState(() => _hasStartedAnalysis = true);

    try {
      final analysis = await ref.read(provider.future);
      if (mounted) {
        context.go(
          AppRoutes.result,
          extra: FoodAnalysisResultArguments(
            imagePath: widget.imagePath,
            analysis: analysis,
          ),
        );
      }
    } on FoodAnalysisException catch (error) {
      if (error.type == FoodAnalysisErrorType.premiumRequired && mounted) {
        await context.push(AppRoutes.premium);
      }
      // The provider exposes other error states in the UI below.
    } on Object {
      // The provider exposes the error state in the UI below.
    } finally {
      subscription.close();
      if (mounted) {
        setState(() => _isRequestInFlight = false);
      } else {
        _isRequestInFlight = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final analysisState = _hasStartedAnalysis
        ? ref.watch(foodAnalysisProvider(widget.imagePath))
        : null;
    final isAnalyzing =
        _isRequestInFlight || (analysisState?.isLoading ?? false);
    final hasError = analysisState?.hasError ?? false;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go(AppRoutes.home);
      },
      child: Scaffold(
        backgroundColor: AppColors.forest,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.25,
              colors: [Color(0xFF174B39), AppColors.forest],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton.filled(
                        onPressed: () => context.go(AppRoutes.home),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.14),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.square(52),
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
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.13),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x66000000),
                                blurRadius: 36,
                                offset: Offset(0, 18),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(29),
                            child: ColoredBox(
                              color: Colors.black,
                              child: Image.file(
                                File(widget.imagePath),
                                width: double.infinity,
                                fit: BoxFit.cover,
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (hasError) ...[
                    _AnalysisError(
                      message: _analysisErrorMessage(
                        l10n,
                        analysisState?.error,
                      ),
                      retryLabel: l10n.tryAgain,
                      onRetry: () => _analyzeFood(retry: true),
                    ),
                    const SizedBox(height: 14),
                  ],
                  PremiumActionButton(
                    label: isAnalyzing ? l10n.analyzingFood : l10n.analyzeFood,
                    icon: Icons.auto_awesome_rounded,
                    onPressed: isAnalyzing ? null : _analyzeFood,
                    loading: isAnalyzing,
                  ),
                ],
              ),
            ),
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
      FoodAnalysisErrorType.unauthorized => l10n.authenticationRequired,
      FoodAnalysisErrorType.premiumRequired => l10n.premiumRequired,
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
