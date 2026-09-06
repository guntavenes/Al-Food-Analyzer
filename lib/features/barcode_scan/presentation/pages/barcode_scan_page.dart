import 'package:ai_food_analyzer/core/router/app_router.dart';
import 'package:ai_food_analyzer/core/theme/app_colors.dart';
import 'package:ai_food_analyzer/core/widgets/premium_action_button.dart';
import 'package:ai_food_analyzer/core/widgets/premium_screen_background.dart';
import 'package:ai_food_analyzer/features/analysis/presentation/providers/food_analysis_providers.dart';
import 'package:ai_food_analyzer/features/barcode_scan/data/barcode_product_service.dart';
import 'package:ai_food_analyzer/features/barcode_scan/domain/barcode_product.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class BarcodeScanPage extends ConsumerStatefulWidget {
  const BarcodeScanPage({super.key});

  @override
  ConsumerState<BarcodeScanPage> createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends ConsumerState<BarcodeScanPage> {
  final _controller = MobileScannerController(
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
  );
  final _gramsController = TextEditingController(text: '100');
  final _manualBarcodeController = TextEditingController();
  bool _isLookingUp = false;
  BarcodeProduct? _product;
  BarcodeLookupError? _error;

  @override
  void dispose() {
    _controller.dispose();
    _gramsController.dispose();
    _manualBarcodeController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isLookingUp || _product != null) return;
    final value = capture.barcodes.firstOrNull?.rawValue?.replaceAll(
      RegExp(r'\D'),
      '',
    );
    if (value == null || value.length < 8 || value.length > 14) return;
    await _lookup(value);
  }

  Future<void> _lookup(String barcode) async {
    setState(() {
      _isLookingUp = true;
      _error = null;
    });
    await _controller.stop();
    try {
      final product = await BarcodeProductService(
        ref.read(foodAnalysisDioProvider),
      ).find(barcode);
      if (mounted) setState(() => _product = product);
    } on BarcodeLookupException catch (error) {
      if (mounted) setState(() => _error = error.type);
    } finally {
      if (mounted) setState(() => _isLookingUp = false);
    }
  }

  Future<void> _scanAgain() async {
    setState(() {
      _product = null;
      _error = null;
    });
    await _controller.start();
  }

  Future<void> _enterBarcode() async {
    _manualBarcodeController.clear();
    final barcode = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).enterBarcode),
        content: TextField(
          controller: _manualBarcodeController,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 14,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).barcodeHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = _manualBarcodeController.text.replaceAll(
                RegExp(r'\D'),
                '',
              );
              Navigator.pop(
                dialogContext,
                value.length >= 8 && value.length <= 14 ? value : null,
              );
            },
            child: Text(AppLocalizations.of(context).searchProduct),
          ),
        ],
      ),
    );
    if (barcode != null && mounted) await _lookup(barcode);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.scanBarcode,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton.filledTonal(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: PremiumScreenBackground(
        child: _product == null ? _scanner(l10n) : _result(l10n, _product!),
      ),
    );
  }

  Widget _scanner(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
      children: [
        Text(l10n.barcodeScanDescription, textAlign: TextAlign.center),
        const SizedBox(height: 22),
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(controller: _controller, onDetect: _onDetect),
                Container(
                  margin: const EdgeInsets.all(45),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                if (_isLookingUp)
                  ColoredBox(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 14),
                          Text(
                            l10n.findingProduct,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: _isLookingUp ? null : _enterBarcode,
          icon: const Icon(Icons.keyboard_alt_outlined),
          label: Text(l10n.enterBarcodeManually),
        ),
        if (_error != null) ...[
          const SizedBox(height: 18),
          _ErrorCard(
            message: _error == BarcodeLookupError.notFound
                ? l10n.barcodeProductNotFound
                : l10n.barcodeLookupFailed,
            onRetry: _scanAgain,
            onPhoto: () => context.go(AppRoutes.home),
          ),
        ],
      ],
    );
  }

  Widget _result(AppLocalizations l10n, BarcodeProduct product) {
    final grams =
        double.tryParse(_gramsController.text.replaceAll(',', '.')) ?? 100;
    final factor = grams.clamp(1, 5000) / 100;
    String value(double? amount, String suffix) =>
        amount == null ? '—' : '${(amount * factor).round()} $suffix';
    final nutrition = product.nutritionPer100g;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: product.imageUrl == null
                  ? Container(
                      width: 94,
                      height: 94,
                      color: AppColors.emerald.withValues(alpha: .12),
                      child: const Icon(Icons.inventory_2_outlined),
                    )
                  : Image.network(
                      product.imageUrl!,
                      width: 94,
                      height: 94,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox(
                        width: 94,
                        height: 94,
                        child: Icon(Icons.inventory_2_outlined),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: .13),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.verifiedProduct,
                      style: const TextStyle(
                        color: AppColors.emerald,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (product.brand != null)
                    Text(
                      product.brand!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (product.quantity != null)
                    Text(
                      product.quantity!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _gramsController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n.consumedAmount,
            suffixText: 'g',
            prefixIcon: const Icon(Icons.scale_outlined),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.emeraldBright, AppColors.teal],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              Text(
                l10n.caloriesForAmount(grams.round()),
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value(nutrition.calories, 'kcal'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.15,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            _Nutrient(
              label: l10n.proteinLabel,
              value: value(nutrition.protein, 'g'),
            ),
            _Nutrient(
              label: l10n.carbsLabel,
              value: value(nutrition.carbohydrates, 'g'),
            ),
            _Nutrient(label: l10n.fatLabel, value: value(nutrition.fat, 'g')),
            _Nutrient(
              label: l10n.sugarLabel,
              value: value(nutrition.sugar, 'g'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        TextButton.icon(
          onPressed: () => launchUrl(
            Uri.parse(product.sourceUrl),
            mode: LaunchMode.externalApplication,
          ),
          icon: const Icon(Icons.open_in_new_rounded),
          label: Text(l10n.dataSource(product.sourceName)),
        ),
        const SizedBox(height: 8),
        PremiumActionButton(
          label: l10n.scanAnotherBarcode,
          icon: Icons.qr_code_scanner_rounded,
          onPressed: _scanAgain,
        ),
      ],
    );
  }
}

class _Nutrient extends StatelessWidget {
  const _Nutrient({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: .85),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
        ),
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
    required this.onPhoto,
  });
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onPhoto;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.emerald),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onPhoto,
                  child: const Text('Fotoğrafla tara'),
                ),
              ),
              Expanded(
                child: FilledButton(
                  onPressed: onRetry,
                  child: const Text('Tekrar dene'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
