import 'dart:io';

import 'package:ai_food_analyzer/core/router/app_router.dart';
import 'package:ai_food_analyzer/core/theme/app_colors.dart';
import 'package:ai_food_analyzer/features/history/domain/entities/saved_food_analysis.dart';
import 'package:ai_food_analyzer/features/history/presentation/formatters/history_formatters.dart';
import 'package:ai_food_analyzer/features/history/presentation/providers/history_providers.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final history = ref.watch(analysisHistoryProvider);
    final actionState = ref.watch(historyActionsProvider);

    ref.listen(historyActionsProvider, (previous, next) {
      if (next.hasError && previous?.hasError != true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.historyActionFailed)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        actions: [
          if (history.value?.isNotEmpty ?? false)
            IconButton(
              tooltip: l10n.clearHistory,
              onPressed: actionState.isLoading
                  ? null
                  : () => _confirmClearHistory(context, ref),
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: Column(
        children: [
          if (actionState.isLoading) const LinearProgressIndicator(),
          Expanded(
            child: history.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _HistoryError(
                message: l10n.historyLoadFailed,
                retryLabel: l10n.tryAgain,
                onRetry: () => ref.invalidate(analysisHistoryProvider),
              ),
              data: (analyses) {
                if (analyses.isEmpty) {
                  return const _EmptyHistory();
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final horizontalPadding = constraints.maxWidth >= 600
                        ? 32.0
                        : 16.0;

                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        12,
                        horizontalPadding,
                        32,
                      ),
                      itemCount: analyses.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final analysis = analyses[index];
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 680),
                            child: _HistoryCard(
                              analysis: analysis,
                              onTap: () => context.push(
                                AppRoutes.historyDetail(analysis.id),
                              ),
                              onDelete: () =>
                                  _confirmDelete(context, ref, analysis.id),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int id,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAnalysisTitle),
        content: Text(l10n.deleteAnalysisMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref.read(historyActionsProvider.notifier).deleteAnalysis(id);
    }
  }

  Future<void> _confirmClearHistory(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearHistoryTitle),
        content: Text(l10n.clearHistoryMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref.read(historyActionsProvider.notifier).clearHistory();
    }
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.analysis,
    required this.onTap,
    required this.onDelete,
  });

  final SavedFoodAnalysis analysis;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: colors.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox.square(
                  dimension: 92,
                  child: ColoredBox(
                    color: colors.surfaceContainerHighest,
                    child: Image.file(
                      File(analysis.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.restaurant_rounded,
                          color: colors.onSurfaceVariant,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis.foodName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        _CompactValue(
                          icon: Icons.local_fire_department_rounded,
                          value: l10n.calorieValue(analysis.calories),
                        ),
                        _CompactValue(
                          icon: Icons.fitness_center_rounded,
                          value: l10n.gramValue(analysis.proteinGrams),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      HistoryFormatters.dateTime(
                        analysis.createdAt,
                        l10n.localeName,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_HistoryAction>(
                tooltip: l10n.moreActions,
                onSelected: (action) {
                  if (action == _HistoryAction.delete) {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<_HistoryAction>(
                    value: _HistoryAction.delete,
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded),
                        const SizedBox(width: 10),
                        Text(l10n.delete),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _HistoryAction { delete }

class _CompactValue extends StatelessWidget {
  const _CompactValue({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.champagne, size: 15),
        const SizedBox(width: 4),
        Text(value, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primaryContainer,
              ),
              child: Icon(
                Icons.history_rounded,
                color: colors.onPrimaryContainer,
                size: 42,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              l10n.emptyHistoryTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              l10n.emptyHistoryDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}
