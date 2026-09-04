import 'dart:async';

import 'package:ai_food_analyzer/features/analysis/presentation/providers/food_analysis_providers.dart';
import 'package:ai_food_analyzer/features/premium/data/premium_purchase_service.dart';
import 'package:ai_food_analyzer/features/premium/domain/entities/premium_plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

final premiumPurchaseServiceProvider = Provider<PremiumPurchaseService>((ref) {
  return PremiumPurchaseService(
    InAppPurchase.instance,
    ref.watch(foodAnalysisDioProvider),
    ref.watch(accessTokenProvider),
  );
});

class PremiumPurchaseState {
  const PremiumPurchaseState({
    this.plans = const [],
    this.isLoading = true,
    this.isPurchasing = false,
    this.isPremium = false,
    this.errorMessage,
  });

  final List<PremiumPlan> plans;
  final bool isLoading;
  final bool isPurchasing;
  final bool isPremium;
  final String? errorMessage;

  PremiumPurchaseState copyWith({
    List<PremiumPlan>? plans,
    bool? isLoading,
    bool? isPurchasing,
    bool? isPremium,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PremiumPurchaseState(
      plans: plans ?? this.plans,
      isLoading: isLoading ?? this.isLoading,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      isPremium: isPremium ?? this.isPremium,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final premiumPurchaseProvider =
    NotifierProvider.autoDispose<
      PremiumPurchaseController,
      PremiumPurchaseState
    >(PremiumPurchaseController.new);

class PremiumPurchaseController extends Notifier<PremiumPurchaseState> {
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  PremiumPurchaseService get _service =>
      ref.read(premiumPurchaseServiceProvider);

  @override
  PremiumPurchaseState build() {
    _subscription = _service.purchaseUpdates.listen(_handlePurchases);
    ref.onDispose(() => _subscription?.cancel());
    Future<void>.microtask(loadPlans);
    return const PremiumPurchaseState();
  }

  Future<void> loadPlans() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      state = state.copyWith(
        plans: await _service.loadPlans(),
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: _message(error));
    }
  }

  Future<void> purchase(String productId) async {
    if (state.isPurchasing) return;
    state = state.copyWith(isPurchasing: true, clearError: true);
    try {
      await _service.purchase(productId);
    } catch (error) {
      state = state.copyWith(
        isPurchasing: false,
        errorMessage: _message(error),
      );
    }
  }

  Future<void> restore() async {
    if (state.isPurchasing) return;
    state = state.copyWith(isPurchasing: true, clearError: true);
    try {
      await _service.restore();
    } catch (error) {
      state = state.copyWith(
        isPurchasing: false,
        errorMessage: _message(error),
      );
    }
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        state = state.copyWith(isPurchasing: true, clearError: true);
        continue;
      }
      if (purchase.status == PurchaseStatus.error) {
        state = state.copyWith(
          isPurchasing: false,
          errorMessage: purchase.error?.message ?? 'The purchase failed.',
        );
        continue;
      }
      if (purchase.status == PurchaseStatus.canceled) {
        state = state.copyWith(isPurchasing: false, clearError: true);
        continue;
      }
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        try {
          await _service.verifyAndComplete(purchase);
          state = state.copyWith(
            isPurchasing: false,
            isPremium: true,
            clearError: true,
          );
        } catch (error) {
          state = state.copyWith(
            isPurchasing: false,
            errorMessage: _message(error),
          );
        }
      }
    }
  }

  String _message(Object error) {
    if (error is PremiumPurchaseException) return error.message;
    return 'The purchase could not be verified. Please try again.';
  }
}
