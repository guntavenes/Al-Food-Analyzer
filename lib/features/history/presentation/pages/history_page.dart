import 'dart:io';

import 'package:ai_food_analyzer/core/router/app_router.dart';
import 'package:ai_food_analyzer/core/theme/app_colors.dart';
import 'package:ai_food_analyzer/core/widgets/premium_screen_background.dart';
import 'package:ai_food_analyzer/features/history/domain/entities/saved_food_analysis.dart';
import 'package:ai_food_analyzer/features/history/presentation/formatters/history_formatters.dart';
import 'package:ai_food_analyzer/features/history/presentation/providers/history_providers.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  final _searchController = TextEditingController();
  _HistoryFilter _filter = _HistoryFilter.all;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.emeraldBright, AppColors.teal],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
            const SizedBox(width: 10),
            Text(l10n.historyTitle),
          ],
        ),
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
      body: PremiumScreenBackground(
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + kToolbarHeight,
          ),
          child: Column(
            children: [
              if (actionState.isLoading) const LinearProgressIndicator(),
              Expanded(
                child: history.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => _HistoryError(
                    message: l10n.historyLoadFailed,
                    retryLabel: l10n.tryAgain,
                    onRetry: () => ref.invalidate(analysisHistoryProvider),
                  ),
                  data: (analyses) {
                    if (analyses.isEmpty) {
                      return const _EmptyHistory();
                    }

                    final filtered = _filteredAnalyses(analyses);
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final horizontalPadding = constraints.maxWidth >= 600
                            ? 32.0
                            : 16.0;

                        return ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            20,
                            horizontalPadding,
                            32,
                          ),
                          itemCount:
                              filtered.length + 2 + (filtered.isEmpty ? 1 : 0),
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 680,
                                  ),
                                  child: _HistoryControls(
                                    controller: _searchController,
                                    filter: _filter,
                                    selectedDate: _selectedDate,
                                    onSearchChanged: (_) => setState(() {}),
                                    onFilterChanged: (filter) =>
                                        setState(() => _filter = filter),
                                    onSelectDate: _selectDate,
                                    onClearDate: () =>
                                        setState(() => _selectedDate = null),
                                  ),
                                ),
                              );
                            }
                            if (index == 1) {
                              return Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 680,
                                  ),
                                  child: _WeeklyComparison(analyses: analyses),
                                ),
                              );
                            }
                            if (filtered.isEmpty && index == 2) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 36,
                                ),
                                child: Center(
                                  child: Text(l10n.noFilteredHistory),
                                ),
                              );
                            }
                            final analysis = filtered[index - 2];
                            return Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 680,
                                ),
                                child: _HistoryCard(
                                  analysis: analysis,
                                  onTap: () => context.push(
                                    AppRoutes.historyDetail(analysis.id),
                                  ),
                                  onDelete: () =>
                                      _confirmDelete(context, ref, analysis.id),
                                  onFavorite: () => ref
                                      .read(historyActionsProvider.notifier)
                                      .setFavorite(
                                        analysis.id,
                                        isFavorite: !analysis.isFavorite,
                                      ),
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
        ),
      ),
    );
  }

  List<SavedFoodAnalysis> _filteredAnalyses(List<SavedFoodAnalysis> analyses) {
    final query = _searchController.text.trim().toLowerCase();
    return analyses
        .where((analysis) {
          if (query.isNotEmpty &&
              !analysis.foodName.toLowerCase().contains(query) &&
              !analysis.description.toLowerCase().contains(query)) {
            return false;
          }
          if (_filter == _HistoryFilter.favorites && !analysis.isFavorite) {
            return false;
          }
          if (_filter == _HistoryFilter.highProtein &&
              analysis.proteinGrams < 25) {
            return false;
          }
          if (_selectedDate != null) {
            final date = analysis.createdAt.toLocal();
            if (date.year != _selectedDate!.year ||
                date.month != _selectedDate!.month ||
                date.day != _selectedDate!.day) {
              return false;
            }
          }
          return true;
        })
        .toList(growable: false);
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (date != null && mounted) setState(() => _selectedDate = date);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int id,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DestructiveConfirmationDialog(
        title: Text(l10n.deleteAnalysisTitle),
        message: l10n.deleteAnalysisMessage,
        cancelLabel: l10n.cancel,
        confirmLabel: l10n.delete,
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
      builder: (context) => _DestructiveConfirmationDialog(
        title: Text(l10n.clearHistoryTitle),
        message: l10n.clearHistoryMessage,
        cancelLabel: l10n.cancel,
        confirmLabel: l10n.clear,
      ),
    );

    if (confirmed ?? false) {
      await ref.read(historyActionsProvider.notifier).clearHistory();
    }
  }
}

class _DestructiveConfirmationDialog extends StatelessWidget {
  const _DestructiveConfirmationDialog({
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
  });

  final Widget title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 42),
      contentPadding: const EdgeInsets.fromLTRB(24, 6, 24, 22),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
      iconPadding: const EdgeInsets.only(top: 22),
      icon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colors.errorContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: colors.onErrorContainer,
          size: 24,
        ),
      ),
      title: DefaultTextStyle.merge(
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.25,
        ),
        child: title,
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
          height: 1.4,
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(cancelLabel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                  minimumSize: const Size.fromHeight(52),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(confirmLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum _HistoryFilter { all, favorites, highProtein }

class _HistoryControls extends StatelessWidget {
  const _HistoryControls({
    required this.controller,
    required this.filter,
    required this.selectedDate,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onSelectDate,
    required this.onClearDate,
  });

  final TextEditingController controller;
  final _HistoryFilter filter;
  final DateTime? selectedDate;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<_HistoryFilter> onFilterChanged;
  final VoidCallback onSelectDate;
  final VoidCallback onClearDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          onChanged: onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.searchHistory,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      controller.clear();
                      onSearchChanged('');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: Text(l10n.allHistory),
                selected: filter == _HistoryFilter.all,
                onSelected: (_) => onFilterChanged(_HistoryFilter.all),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                avatar: const Icon(Icons.favorite_rounded, size: 16),
                label: Text(l10n.favorites),
                selected: filter == _HistoryFilter.favorites,
                onSelected: (_) => onFilterChanged(_HistoryFilter.favorites),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                avatar: const Icon(Icons.fitness_center_rounded, size: 16),
                label: Text(l10n.highProtein),
                selected: filter == _HistoryFilter.highProtein,
                onSelected: (_) => onFilterChanged(_HistoryFilter.highProtein),
              ),
              const SizedBox(width: 8),
              ActionChip(
                avatar: const Icon(Icons.calendar_month_rounded, size: 17),
                label: Text(
                  selectedDate == null
                      ? l10n.selectDate
                      : DateFormat.yMMMd(locale).format(selectedDate!),
                ),
                onPressed: onSelectDate,
              ),
              if (selectedDate != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: l10n.clearDate,
                  onPressed: onClearDate,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyComparison extends StatelessWidget {
  const _WeeklyComparison({required this.analyses});

  final List<SavedFoodAnalysis> analyses;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    var thisWeekCalories = 0;
    var lastWeekCalories = 0;
    for (final analysis in analyses) {
      final local = analysis.createdAt.toLocal();
      if (!local.isBefore(thisWeekStart)) {
        thisWeekCalories += analysis.calories;
      } else if (!local.isBefore(lastWeekStart) &&
          local.isBefore(thisWeekStart)) {
        lastWeekCalories += analysis.calories;
      }
    }
    final difference = thisWeekCalories - lastWeekCalories;
    final percent = lastWeekCalories == 0
        ? (thisWeekCalories == 0 ? 0 : 100)
        : ((difference.abs() / lastWeekCalories) * 100).round();
    final comparison = difference > 0
        ? l10n.calorieChangeUp(percent)
        : difference < 0
        ? l10n.calorieChangeDown(percent)
        : l10n.calorieChangeSame;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.deepEmerald.withValues(alpha: .96),
            AppColors.teal.withValues(alpha: .92),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.champagneLight.withValues(alpha: .3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.compare_arrows_rounded,
                color: AppColors.champagneLight,
              ),
              const SizedBox(width: 9),
              Text(
                l10n.weeklyComparison,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _WeekValue(
                  label: l10n.thisWeek,
                  value: '$thisWeekCalories kcal',
                  emphasized: true,
                ),
              ),
              Container(width: 1, height: 42, color: Colors.white24),
              Expanded(
                child: _WeekValue(
                  label: l10n.lastWeek,
                  value: '$lastWeekCalories kcal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            comparison,
            style: TextStyle(
              color: colors.surface,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekValue extends StatelessWidget {
  const _WeekValue({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: emphasized ? AppColors.champagneLight : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.analysis,
    required this.onTap,
    required this.onDelete,
    required this.onFavorite,
  });

  final SavedFoodAnalysis analysis;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox.square(
                  dimension: 96,
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
                        letterSpacing: -0.25,
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
                  if (action == _HistoryAction.favorite) {
                    onFavorite();
                  } else if (action == _HistoryAction.delete) {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<_HistoryAction>(
                    value: _HistoryAction.favorite,
                    child: Row(
                      children: [
                        Icon(
                          analysis.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: analysis.isFavorite ? Colors.redAccent : null,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          analysis.isFavorite
                              ? l10n.removeFromFavorites
                              : l10n.addToFavorites,
                        ),
                      ],
                    ),
                  ),
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

enum _HistoryAction { favorite, delete }

class _CompactValue extends StatelessWidget {
  const _CompactValue({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.champagne, size: 14),
          const SizedBox(width: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
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
              width: 106,
              height: 106,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.emeraldBright, AppColors.teal],
                ),
                border: Border.all(
                  color: AppColors.champagneLight.withValues(alpha: 0.5),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x38064E3B),
                    blurRadius: 28,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(Icons.history_rounded, color: Colors.white, size: 46),
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
