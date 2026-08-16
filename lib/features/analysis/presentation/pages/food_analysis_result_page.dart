import 'dart:io';

import 'package:ai_food_analyzer/core/router/app_router.dart';
import 'package:ai_food_analyzer/core/theme/app_colors.dart';
import 'package:ai_food_analyzer/features/analysis/domain/entities/food_analysis.dart';
import 'package:ai_food_analyzer/features/analysis/domain/errors/food_analysis_exception.dart';
import 'package:ai_food_analyzer/features/analysis/domain/repositories/food_analysis_repository.dart';
import 'package:ai_food_analyzer/features/analysis/presentation/providers/food_analysis_providers.dart';
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
  bool _isReanalyzing = false;
  Object? _correctionError;

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

  Future<void> _editAndReanalyze() async {
    if (_isReanalyzing) return;
    final correction = await showModalBottomSheet<FoodAnalysisCorrection>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _CorrectionSheet(
        initialIngredients: widget.arguments.analysis.foodName,
        initialServing: widget.arguments.analysis.servingDescription,
      ),
    );
    if (correction == null || !mounted) return;

    setState(() {
      _isReanalyzing = true;
      _correctionError = null;
    });
    try {
      final analysis = await ref
          .read(foodAnalysisRepositoryProvider)
          .analyzeFood(widget.arguments.imagePath, correction: correction);
      if (mounted) {
        context.go(
          AppRoutes.result,
          extra: FoodAnalysisResultArguments(
            imagePath: widget.arguments.imagePath,
            analysis: analysis,
          ),
        );
      }
    } on Object catch (error) {
      if (mounted) setState(() => _correctionError = error);
    } finally {
      if (mounted) setState(() => _isReanalyzing = false);
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go(AppRoutes.home);
      },
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          title: Text(
            l10n.resultTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton.filledTonal(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
        ),
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.primaryContainer.withValues(alpha: 0.12),
                colors.surface,
              ],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth >= 600
                  ? 32.0
                  : 20.0;

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
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
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
                          value: l10n.calorieRangeValue(
                            analysis.minimumEstimatedCalories,
                            analysis.maximumEstimatedCalories,
                          ),
                          estimate: l10n.centralCalorieEstimate(
                            analysis.calories,
                          ),
                        ),
                        if (analysis.needsIngredientConfirmation &&
                            !widget.arguments.initiallySaved) ...[
                          const SizedBox(height: 16),
                          _IngredientConfirmationCard(
                            title: l10n.confirmIngredientsTitle,
                            message: l10n.confirmIngredientsMessage,
                            actionLabel: l10n.editAndReanalyze,
                            costNotice: l10n.reanalysisCostNotice,
                            isLoading: _isReanalyzing,
                            onPressed: _editAndReanalyze,
                          ),
                          if (_correctionError != null) ...[
                            const SizedBox(height: 12),
                            _SaveError(
                              message: _analysisErrorMessage(
                                l10n,
                                _correctionError,
                              ),
                              retryLabel: l10n.tryAgain,
                              onRetry: _editAndReanalyze,
                            ),
                          ],
                        ],
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
                          healthValue: l10n.healthScoreValue(
                            analysis.healthScore,
                          ),
                          weightLabel: l10n.servingWeightLabel,
                          weightValue: l10n.gramValue(
                            analysis.servingWeightGrams,
                          ),
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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
      FoodAnalysisErrorType.rateLimited => l10n.rateLimited,
      FoodAnalysisErrorType.timeout => l10n.analysisTimeout,
      FoodAnalysisErrorType.network => l10n.networkError,
      FoodAnalysisErrorType.serviceUnavailable => l10n.serviceUnavailable,
      FoodAnalysisErrorType.unknown => l10n.analysisFailed,
    };
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

    return Material(
      color: Theme.of(context).brightness == Brightness.light
          ? AppColors.paleChampagne
          : const Color(0xFF463B22),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Theme.of(context).brightness == Brightness.light
                    ? const Color(0xFF4A3815)
                    : const Color(0xFFF8E7B8),
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Theme.of(context).brightness == Brightness.light
                    ? const Color(0xFF6D5728)
                    : const Color(0xFFEAD59D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaloriesCard extends StatelessWidget {
  const _CaloriesCard({
    required this.label,
    required this.value,
    required this.estimate,
  });

  final String label;
  final String value;
  final String estimate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.emeraldBright, AppColors.teal],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3D08745B),
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
          const SizedBox(height: 4),
          Text(
            estimate,
            style: const TextStyle(
              color: Color(0xE6FFFFFF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientConfirmationCard extends StatelessWidget {
  const _IngredientConfirmationCard({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.costNotice,
    required this.isLoading,
    required this.onPressed,
  });

  final String title;
  final String message;
  final String actionLabel;
  final String costNotice;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.tertiaryContainer.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.help_outline_rounded, color: colors.onTertiaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onTertiaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onTertiaryContainer,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    costNotice,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: isLoading ? null : onPressed,
                    icon: isLoading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.edit_rounded),
                    label: Text(actionLabel),
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

class _CorrectionSheet extends StatefulWidget {
  const _CorrectionSheet({
    required this.initialIngredients,
    required this.initialServing,
  });

  final String initialIngredients;
  final String initialServing;

  @override
  State<_CorrectionSheet> createState() => _CorrectionSheetState();
}

class _CorrectionSheetState extends State<_CorrectionSheet> {
  late final TextEditingController _ingredientsController;
  late final TextEditingController _servingController;

  @override
  void initState() {
    super.initState();
    _ingredientsController = TextEditingController(
      text: widget.initialIngredients,
    );
    _servingController = TextEditingController(text: widget.initialServing);
  }

  @override
  void dispose() {
    _ingredientsController.dispose();
    _servingController.dispose();
    super.dispose();
  }

  void _submit() {
    final ingredients = _ingredientsController.text.trim();
    final serving = _servingController.text.trim();
    if (ingredients.isEmpty || serving.isEmpty) return;
    Navigator.of(context).pop(
      FoodAnalysisCorrection(
        ingredients: ingredients,
        servingDescription: serving,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.correctionSheetTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(l10n.correctionSheetDescription),
          const SizedBox(height: 20),
          TextField(
            controller: _ingredientsController,
            maxLength: 300,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.mainIngredientsLabel,
              hintText: l10n.mainIngredientsHint,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _servingController,
            maxLength: 200,
            decoration: InputDecoration(
              labelText: l10n.servingCorrectionLabel,
              hintText: l10n.servingCorrectionHint,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.reanalysisCostNotice,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: Text(l10n.recalculateAnalysis),
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
