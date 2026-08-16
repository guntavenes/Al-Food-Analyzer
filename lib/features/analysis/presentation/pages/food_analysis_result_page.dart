import 'dart:io';

import 'package:ai_food_analyzer/core/router/app_router.dart';
import 'package:ai_food_analyzer/core/theme/app_colors.dart';
import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';
import 'package:ai_food_analyzer/features/history/presentation/providers/history_providers.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FoodAnalysisResultArguments {
  const FoodAnalysisResultArguments({
    required this.imagePath,
    required this.analysis,
    this.initiallySaved = false,
  });

  final String imagePath;
  final FoodAnalysis analysis;
  final bool initiallySaved;
}

class FoodAnalysisResultPage extends ConsumerStatefulWidget {
  const FoodAnalysisResultPage({required this.arguments, super.key});

  final FoodAnalysisResultArguments arguments;

  @override
  ConsumerState<FoodAnalysisResultPage> createState() =>
      _FoodAnalysisResultPageState();
}

class _FoodAnalysisResultPageState
    extends ConsumerState<FoodAnalysisResultPage> {
  late final SaveAnalysisRequest _saveRequest;

  @override
  void initState() {
    super.initState();
    _saveRequest = SaveAnalysisRequest(
      analysis: widget.arguments.analysis,
      imagePath: widget.arguments.imagePath,
    );
  }

  Future<void> _saveResult() async {
    final savedId = await ref
        .read(saveAnalysisProvider(_saveRequest).notifier)
        .save();
    if (savedId != null && mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.analysisSaved)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final analysis = widget.arguments.analysis;
    final saveState = widget.arguments.initiallySaved
        ? const AsyncData<int?>(0)
        : ref.watch(saveAnalysisProvider(_saveRequest));
    final isSaved = widget.arguments.initiallySaved || saveState.value != null;
    final isSaving = saveState.isLoading;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(l10n.resultTitle),
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 600 ? 32.0 : 20.0;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              8,
              horizontalPadding,
              32,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _MealImage(imagePath: widget.arguments.imagePath),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                analysis.foodName,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                analysis.servingDescription,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        _ConfidenceBadge(
                          label: l10n.confidenceLabel,
                          value: l10n.confidenceValue(
                            analysis.confidencePercent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _CaloriesCard(
                      label: l10n.estimatedCalories,
                      value: l10n.calorieValue(analysis.calories),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, cardConstraints) {
                        const spacing = 12.0;
                        final cardWidth =
                            (cardConstraints.maxWidth - spacing) / 2;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            _NutrientCard(
                              width: cardWidth,
                              icon: Icons.fitness_center_rounded,
                              color: const Color(0xFF2F9E76),
                              label: l10n.proteinLabel,
                              value: l10n.gramValue(analysis.proteinGrams),
                            ),
                            _NutrientCard(
                              width: cardWidth,
                              icon: Icons.grain_rounded,
                              color: const Color(0xFFE49B3F),
                              label: l10n.carbsLabel,
                              value: l10n.gramValue(analysis.carbsGrams),
                            ),
                            _NutrientCard(
                              width: cardWidth,
                              icon: Icons.water_drop_rounded,
                              color: const Color(0xFFD46A7E),
                              label: l10n.fatLabel,
                              value: l10n.gramValue(analysis.fatGrams),
                            ),
                            _NutrientCard(
                              width: cardWidth,
                              icon: Icons.eco_rounded,
                              color: const Color(0xFF5B8FD3),
                              label: l10n.fiberLabel,
                              value: l10n.gramValue(analysis.fiberGrams),
                            ),
                            _NutrientCard(
                              width: cardWidth,
                              icon: Icons.cake_outlined,
                              color: const Color(0xFF9B6BC2),
                              label: l10n.sugarLabel,
                              value: l10n.gramValue(analysis.sugarGrams),
                            ),
                            _NutrientCard(
                              width: cardWidth,
                              icon: Icons.science_outlined,
                              color: const Color(0xFF4C93A8),
                              label: l10n.sodiumLabel,
                              value: l10n.milligramValue(
                                analysis.sodiumMilligrams,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _AnalysisHighlights(
                      healthLabel: l10n.healthScoreLabel,
                      healthValue: l10n.healthScoreValue(analysis.healthScore),
                      weightLabel: l10n.servingWeightLabel,
                      weightValue: l10n.gramValue(analysis.servingWeightGrams),
                    ),
                    if (analysis.detectedFoods.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _DetectedFoodsCard(
                        title: l10n.detectedFoodsTitle,
                        foods: analysis.detectedFoods,
                      ),
                    ],
                    if (analysis.warnings.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _WarningsCard(
                        title: l10n.warningsTitle,
                        warnings: analysis.warnings,
                      ),
                    ],
                    const SizedBox(height: 20),
                    _DescriptionCard(description: analysis.description),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 17,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.analysisDisclaimer,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.go(AppRoutes.home),
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: Text(l10n.analyzeAnotherMeal),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: isSaved || isSaving ? null : _saveResult,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(58),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: isSaving
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              isSaved
                                  ? Icons.bookmark_added_rounded
                                  : Icons.bookmark_border_rounded,
                            ),
                      label: Text(
                        isSaving
                            ? l10n.savingResult
                            : isSaved
                            ? l10n.saved
                            : l10n.saveResult,
                      ),
                    ),
                    if (saveState.hasError && !isSaved) ...[
                      const SizedBox(height: 12),
                      _SaveError(
                        message: l10n.saveAnalysisFailed,
                        retryLabel: l10n.tryAgain,
                        onRetry: _saveResult,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SaveError extends StatelessWidget {
  const _SaveError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.errorContainer,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: colors.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.onErrorContainer),
              ),
            ),
            TextButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}

class _MealImage extends StatelessWidget {
  const _MealImage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: ColoredBox(
          color: colors.surfaceContainerHighest,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: colors.onSurfaceVariant,
                  size: 56,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaloriesCard extends StatelessWidget {
  const _CaloriesCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.mint, AppColors.teal],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33128B67),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 46,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutrientCard extends StatelessWidget {
  const _NutrientCard({
    required this.width,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final double width;
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: width,
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      maxLines: 1,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalysisHighlights extends StatelessWidget {
  const _AnalysisHighlights({
    required this.healthLabel,
    required this.healthValue,
    required this.weightLabel,
    required this.weightValue,
  });

  final String healthLabel;
  final String healthValue;
  final String weightLabel;
  final String weightValue;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.primaryContainer.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: _HighlightItem(label: healthLabel, value: healthValue),
            ),
            SizedBox(
              height: 42,
              child: VerticalDivider(color: colors.outlineVariant),
            ),
            Expanded(
              child: _HighlightItem(label: weightLabel, value: weightValue),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightItem extends StatelessWidget {
  const _HighlightItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _DetectedFoodsCard extends StatelessWidget {
  const _DetectedFoodsCard({required this.title, required this.foods});

  final String title;
  final List<DetectedFood> foods;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            for (var index = 0; index < foods.length; index++) ...[
              if (index > 0) const Divider(height: 20),
              Text(
                foods[index].name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.foodComponentSummary(
                  foods[index].estimatedWeightGrams,
                  foods[index].calories,
                  foods[index].confidencePercent,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WarningsCard extends StatelessWidget {
  const _WarningsCard({required this.title, required this.warnings});

  final String title;
  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: colors.tertiaryContainer.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            for (final warning in warnings)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: colors.onTertiaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning,
                        style: TextStyle(color: colors.onTertiaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.secondaryContainer.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSecondaryContainer,
            height: 1.55,
          ),
        ),
      ),
    );
  }
}
