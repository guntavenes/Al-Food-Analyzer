import 'dart:async';

import 'package:ai_food_analyzer/core/auth/access_token_provider.dart';
import 'package:ai_food_analyzer/features/premium/domain/entities/premium_plan.dart';
import 'package:dio/dio.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumPurchaseService {
  PremiumPurchaseService(this._store, this._dio, this._accessTokenProvider);

  static const monthlyProductId = 'com.enesguntav.aifood.premium.monthly';
  static const yearlyProductId = 'com.enesguntav.aifood.premium.yearly';

  final InAppPurchase _store;
  final Dio _dio;
  final AccessTokenProvider _accessTokenProvider;
  final Map<String, ProductDetails> _products = {};

  Stream<List<PurchaseDetails>> get purchaseUpdates => _store.purchaseStream;

  Future<List<PremiumPlan>> loadPlans() async {
    if (!await _store.isAvailable()) {
      throw const PremiumPurchaseException('The App Store is unavailable.');
    }
    final response = await _store.queryProductDetails({
      monthlyProductId,
      yearlyProductId,
    });
    if (response.error != null) {
      throw PremiumPurchaseException(response.error!.message);
    }
    _products
      ..clear()
      ..addEntries(
        response.productDetails.map((item) => MapEntry(item.id, item)),
      );
    if (_products.isEmpty) {
      throw const PremiumPurchaseException(
        'Premium products are not available yet.',
      );
    }
    final plans =
        response.productDetails
            .map(
              (product) => PremiumPlan(
                productId: product.id,
                title: product.title,
                description: product.description,
                price: product.price,
                isYearly: product.id == yearlyProductId,
              ),
            )
            .toList()
          ..sort((a, b) => a.isYearly ? 1 : -1);
    return plans;
  }

  Future<void> purchase(String productId) async {
    final product = _products[productId];
    if (product == null) {
      throw const PremiumPurchaseException('This Premium plan is unavailable.');
    }
    final started = await _store.buyNonConsumable(
      purchaseParam: PurchaseParam(
        productDetails: product,
        applicationUserName: _accessTokenProvider.userId,
      ),
    );
    if (!started) {
      throw const PremiumPurchaseException(
        'The purchase could not be started.',
      );
    }
  }

  Future<void> restore() => _store.restorePurchases();

  Future<void> verifyAndComplete(PurchaseDetails purchase) async {
    final token = await _accessTokenProvider.getAccessToken();
    if (token == null) {
      throw const PremiumPurchaseException('Please sign in before purchasing.');
    }
    await _dio.post<void>(
      '/v1/subscriptions/apple/verify',
      data: {
        'signedTransaction': purchase.verificationData.serverVerificationData,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (purchase.pendingCompletePurchase) {
      await _store.completePurchase(purchase);
    }
  }
}

class PremiumPurchaseException implements Exception {
  const PremiumPurchaseException(this.message);
  final String message;
}
