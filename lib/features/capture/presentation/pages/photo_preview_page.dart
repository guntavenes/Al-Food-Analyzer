import 'dart:io';

import 'package:ai_food_analyzer/core/theme/app_colors.dart';
import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';
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
  bool _isAnalyzing = false;

  Future<void> _analyzeFood() async {
    setState(() => _isAnalyzing = true);

    try {
      final analysis = await ref.read(
        foodAnalysisProvider(widget.imagePath).future,
      );
      if (mounted) {
        _showAnalysis(analysis);
      }
    } on Object {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.analysisFailed)));
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _showAnalysis(FoodAnalysis analysis) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        content: Text(
          l10n.analysisSummary(
            analysis.calories,
            analysis.proteinGrams,
            analysis.fatGrams,
            analysis.carbsGrams,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                  onPressed: _isAnalyzing ? null : _analyzeFood,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size.fromHeight(64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: _isAnalyzing
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.auto_awesome_rounded, size: 22),
                  label: Text(
                    _isAnalyzing ? l10n.analyzingFood : l10n.analyzeFood,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
