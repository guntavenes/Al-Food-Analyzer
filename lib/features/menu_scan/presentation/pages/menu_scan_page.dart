import 'dart:io';

import 'package:ai_food_analyzer/core/router/app_router.dart';
import 'package:ai_food_analyzer/core/theme/app_colors.dart';
import 'package:ai_food_analyzer/core/widgets/premium_action_button.dart';
import 'package:ai_food_analyzer/core/widgets/premium_screen_background.dart';
import 'package:ai_food_analyzer/features/analysis/domain/errors/food_analysis_exception.dart';
import 'package:ai_food_analyzer/features/menu_scan/domain/menu_analysis.dart';
import 'package:ai_food_analyzer/features/menu_scan/presentation/providers/menu_analysis_providers.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class MenuScanPage extends ConsumerStatefulWidget {
  const MenuScanPage({this.initialImagePath, super.key});

  final String? initialImagePath;

  @override
  ConsumerState<MenuScanPage> createState() => _MenuScanPageState();
}

class _MenuScanPageState extends ConsumerState<MenuScanPage> {
  String? _imagePath;
  MenuAnalysis? _analysis;
  Object? _error;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.initialImagePath;
    if (_imagePath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _analyze());
    }
  }

  Future<void> _chooseSource() async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _MenuIcon(size: 62),
              const SizedBox(height: 14),
              Text(
                l10n.menuPhotoSheetTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                l10n.menuPhotoSheetDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              PremiumActionButton(
                label: l10n.takePhoto,
                icon: Icons.photo_camera_rounded,
                onPressed: () =>
                    Navigator.pop(sheetContext, ImageSource.camera),
              ),
              const SizedBox(height: 10),
              PremiumActionButton(
                label: l10n.chooseFromGallery,
                icon: Icons.photo_library_outlined,
                secondary: true,
                onPressed: () =>
                    Navigator.pop(sheetContext, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null || !mounted) return;
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 92,
    );
    if (image == null || !mounted) return;
    setState(() {
      _imagePath = image.path;
      _analysis = null;
      _error = null;
    });
    await _analyze();
  }

  Future<void> _analyze() async {
    final imagePath = _imagePath;
    if (imagePath == null || _isAnalyzing) return;
    setState(() {
      _isAnalyzing = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(menuAnalysisServiceProvider)
          .analyze(
            imagePath: imagePath,
            locale: ref.read(menuAnalysisLocaleProvider),
          );
      if (mounted) setState(() => _analysis = result);
    } on FoodAnalysisException catch (error) {
      if (error.type == FoodAnalysisErrorType.premiumRequired && mounted) {
        await context.push(AppRoutes.premium);
      } else if (mounted) {
        setState(() => _error = error);
      }
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final analysis = _analysis;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton.filledTonal(
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        title: Text(
          l10n.menuScanTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (_imagePath != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton.filledTonal(
                tooltip: l10n.scanAnotherMenu,
                onPressed: _isAnalyzing ? null : _chooseSource,
                icon: const Icon(Icons.add_a_photo_rounded),
              ),
            ),
        ],
      ),
      body: PremiumScreenBackground(
        child: SafeArea(
          top: false,
          child: analysis == null
              ? _buildCaptureState(l10n)
              : _MenuResultView(analysis: analysis, onNewScan: _chooseSource),
        ),
      ),
    );
  }

  Widget _buildCaptureState(AppLocalizations l10n) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            children: [
              if (_imagePath == null) ...[
                const _MenuIcon(size: 96),
                const SizedBox(height: 24),
                Text(
                  l10n.menuScanHeroTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.menuScanIntroDescription,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                PremiumActionButton(
                  label: l10n.scanMenuAction,
                  icon: Icons.document_scanner_rounded,
                  onPressed: _chooseSource,
                ),
              ] else ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 28),
                if (_isAnalyzing) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 18),
                  Text(
                    l10n.analyzingMenu,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.analyzingMenuDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ] else if (_error != null) ...[
                  Icon(
                    Icons.error_outline_rounded,
                    color: colors.error,
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.menuAnalysisFailed, textAlign: TextAlign.center),
                  const SizedBox(height: 18),
                  PremiumActionButton(
                    label: l10n.tryAgain,
                    icon: Icons.refresh_rounded,
                    onPressed: _analyze,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuResultView extends StatelessWidget {
  const _MenuResultView({required this.analysis, required this.onNewScan});

  final MenuAnalysis analysis;
  final VoidCallback onNewScan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recommended = analysis.items.firstWhere(
      (item) => item.name == analysis.recommendedItemName,
    );
    final others = analysis.items.where((item) => item != recommended).toList()
      ..sort((a, b) => b.healthScore.compareTo(a.healthScore));
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (analysis.restaurantName != null)
                Text(
                  analysis.restaurantName!,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              const SizedBox(height: 8),
              _RecommendationCard(item: recommended),
              const SizedBox(height: 14),
              Text(
                analysis.summary,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.otherMenuOptions,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(l10n.confidenceValue(analysis.confidencePercent)),
                ],
              ),
              const SizedBox(height: 10),
              for (final item in others) ...[
                _MenuItemTile(item: item),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 10),
              PremiumActionButton(
                label: l10n.scanAnotherMenu,
                icon: Icons.add_a_photo_rounded,
                onPressed: onNewScan,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.menuEstimateDisclaimer,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.item});

  final MenuItemAnalysis item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [AppColors.emeraldBright, AppColors.emerald, AppColors.teal],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3308745B),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.champagneLight,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.bestMenuChoice.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            item.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              item.description,
              style: const TextStyle(color: Color(0xE6FFFFFF)),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ResultPill(
                icon: Icons.local_fire_department_rounded,
                text: '${item.minimumCalories}–${item.maximumCalories} kcal',
              ),
              _ResultPill(
                icon: Icons.eco_rounded,
                text: l10n.healthScoreValue(item.healthScore),
              ),
            ],
          ),
          if (item.reasons.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              item.reasons.first,
              style: const TextStyle(color: Colors.white, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultPill extends StatelessWidget {
  const _ResultPill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: AppColors.night.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.champagneLight, size: 17),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({required this.item});
  final MenuItemAnalysis item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${item.minimumCalories}–${item.maximumCalories} kcal · '
          '${l10n.healthScoreValue(item.healthScore)}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        children: [
          if (item.description.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(item.description),
            ),
          for (final reason in item.reasons)
            _Bullet(
              icon: Icons.check_circle_rounded,
              color: AppColors.emerald,
              text: reason,
            ),
          for (final concern in item.concerns)
            _Bullet(
              icon: Icons.info_rounded,
              color: const Color(0xFFD38A31),
              text: concern,
            ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _MenuIcon extends StatelessWidget {
  const _MenuIcon({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [AppColors.champagneLight, AppColors.champagne],
      ),
    ),
    child: Icon(
      Icons.menu_book_rounded,
      color: AppColors.deepEmerald,
      size: size * 0.48,
    ),
  );
}
