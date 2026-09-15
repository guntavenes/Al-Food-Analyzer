import 'dart:math' as math;

import 'package:ai_food_analyzer/core/router/app_router.dart';
import 'package:ai_food_analyzer/core/theme/app_colors.dart';
import 'package:ai_food_analyzer/core/widgets/premium_screen_background.dart';
import 'package:ai_food_analyzer/core/widgets/staggered_reveal.dart';
import 'package:ai_food_analyzer/features/nutrition_summary/domain/daily_nutrition_summary.dart';
import 'package:ai_food_analyzer/features/nutrition_summary/presentation/providers/nutrition_summary_providers.dart';
import 'package:ai_food_analyzer/features/premium/presentation/providers/premium_purchase_provider.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class NutritionSummaryPage extends ConsumerWidget {
  const NutritionSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(weeklyNutritionSummaryProvider);
    final premium = ref.watch(premiumEntitlementProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.nutritionSummaryTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: PremiumScreenBackground(
        child: summary.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(child: Text(l10n.analysisFailed)),
          data: (days) => premium.value == true
              ? _SummaryContent(days: days)
              : _LockedSummary(
                  onUpgrade: () => context.push(AppRoutes.premium),
                ),
        ),
      ),
    );
  }
}

class _LockedSummary extends StatelessWidget {
  const _LockedSummary({required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: .9),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.champagne.withValues(alpha: .45),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.champagneLight, AppColors.champagne],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: AppColors.deepEmerald,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.nutritionSummaryTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                l10n.nutritionSummarySubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: onUpgrade,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(l10n.upgradeToPremium),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({required this.days});

  final List<DailyNutritionSummary> days;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = days.last;
    final hasData = days.any((day) => day.mealCount > 0);
    final average = days.fold<int>(0, (sum, day) => sum + day.calories) ~/ 7;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      children: [
        StaggeredReveal(
          child: _HeroCard(
            badge: l10n.premiumNutritionBadge,
            title: l10n.todaySummary,
            calories: today.calories,
            mealLabel: l10n.mealsTracked(today.mealCount),
          ),
        ),
        const SizedBox(height: 16),
        StaggeredReveal(
          delay: const Duration(milliseconds: 100),
          child: Row(
            children: [
              Expanded(
                child: _MacroCard(
                  label: l10n.proteinLabel,
                  value: l10n.gramValue(today.proteinGrams),
                  color: AppColors.emerald,
                  icon: Icons.fitness_center_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MacroCard(
                  label: l10n.carbsLabel,
                  value: l10n.gramValue(today.carbsGrams),
                  color: const Color(0xFFE49B3F),
                  icon: Icons.grain_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MacroCard(
                  label: l10n.fatLabel,
                  value: l10n.gramValue(today.fatGrams),
                  color: const Color(0xFFD46A7E),
                  icon: Icons.water_drop_rounded,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        StaggeredReveal(
          delay: const Duration(milliseconds: 190),
          child: _WeeklyCard(
            days: days,
            title: l10n.weeklyCalories,
            averageLabel: '${l10n.dailyAverage}: $average kcal',
          ),
        ),
        if (!hasData) ...[
          const SizedBox(height: 18),
          StaggeredReveal(
            delay: const Duration(milliseconds: 280),
            child: _EmptyHint(
              title: l10n.noNutritionData,
              description: l10n.noNutritionDataDescription,
            ),
          ),
        ],
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.badge,
    required this.title,
    required this.calories,
    required this.mealLabel,
  });

  final String badge;
  final String title;
  final int calories;
  final String mealLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.deepEmerald, AppColors.emerald, AppColors.teal],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.champagneLight.withValues(alpha: .3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x38064E3B),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.champagneLight,
                size: 18,
              ),
              const SizedBox(width: 7),
              Text(
                badge,
                style: const TextStyle(
                  color: AppColors.champagneLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$calories',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 46,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                  ),
                ),
                const TextSpan(
                  text: ' kcal',
                  style: TextStyle(
                    color: AppColors.champagneLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(mealLabel, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(height: 9),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  const _WeeklyCard({
    required this.days,
    required this.title,
    required this.averageLabel,
  });

  final List<DailyNutritionSummary> days;
  final String title;
  final String averageLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final maxCalories = math.max(
      1,
      days.fold<int>(0, (maxValue, day) => math.max(maxValue, day.calories)),
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.champagne.withValues(alpha: .28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            averageLabel,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 170,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var index = 0; index < days.length; index++)
                  Expanded(
                    child: _DayBar(
                      day: days[index],
                      maxCalories: maxCalories,
                      label: DateFormat.E(locale).format(days[index].date),
                      isToday: index == days.length - 1,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.day,
    required this.maxCalories,
    required this.label,
    required this.isToday,
  });

  final DailyNutritionSummary day;
  final int maxCalories;
  final String label;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final fraction = day.calories / maxCalories;
    return Semantics(
      label: '$label, ${day.calories} kcal',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              day.calories == 0 ? '–' : '${day.calories}',
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeOutCubic,
                  heightFactor: math.max(.035, fraction),
                  widthFactor: .58,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: isToday
                            ? [AppColors.emerald, AppColors.mint]
                            : [AppColors.champagne, AppColors.champagneLight],
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                color: isToday ? AppColors.emerald : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.paleChampagne.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Icon(Icons.bookmark_add_outlined, color: AppColors.deepEmerald),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
