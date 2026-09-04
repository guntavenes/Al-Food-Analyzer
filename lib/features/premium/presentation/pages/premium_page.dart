import 'package:ai_food_analyzer/core/theme/app_colors.dart';
import 'package:ai_food_analyzer/core/widgets/premium_screen_background.dart';
import 'package:ai_food_analyzer/features/premium/presentation/providers/premium_purchase_provider.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PremiumPage extends ConsumerWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final purchaseState = ref.watch(premiumPurchaseProvider);
    return Scaffold(
      body: PremiumScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton.filledTonal(
                      onPressed: context.pop,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.champagneLight, AppColors.champagne],
                      ),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.deepEmerald,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    l10n.premiumTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.premiumDescription,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _Benefit(label: l10n.premiumBenefitAnalysis),
                  _Benefit(label: l10n.premiumBenefitHistory),
                  _Benefit(label: l10n.premiumBenefitNutrition),
                  const SizedBox(height: 24),
                  if (purchaseState.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    )
                  else if (purchaseState.plans.isEmpty)
                    _PurchaseError(
                      message:
                          purchaseState.errorMessage ??
                          l10n.purchaseNotAvailable,
                      onRetry: () => ref
                          .read(premiumPurchaseProvider.notifier)
                          .loadPlans(),
                    )
                  else
                    ...purchaseState.plans.map(
                      (plan) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PlanCard(
                          title: plan.isYearly
                              ? l10n.premiumYearlyPlan
                              : l10n.premiumMonthlyPlan,
                          price: plan.price,
                          badge: plan.isYearly ? l10n.premiumBestValue : null,
                          enabled: !purchaseState.isPurchasing,
                          onTap: () => ref
                              .read(premiumPurchaseProvider.notifier)
                              .purchase(plan.productId),
                        ),
                      ),
                    ),
                  if (purchaseState.errorMessage != null &&
                      purchaseState.plans.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        purchaseState.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  if (purchaseState.isPremium)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l10n.premiumPurchaseSuccess,
                        style: const TextStyle(
                          color: AppColors.emeraldBright,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: purchaseState.isPurchasing
                        ? null
                        : () => ref
                              .read(premiumPurchaseProvider.notifier)
                              .restore(),
                    child: Text(l10n.restorePurchases),
                  ),
                  Text(
                    l10n.premiumRenewalDisclosure,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.enabled,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String price;
  final String? badge;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.82),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (badge != null)
                      Text(
                        badge!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.emeraldBright,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    Text(title, style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
              Text(
                price,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _PurchaseError extends StatelessWidget {
  const _PurchaseError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.emeraldBright,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
