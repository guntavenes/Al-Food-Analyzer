import 'package:ai_food_analyzer/core/config/app_config.dart';
import 'package:ai_food_analyzer/core/localization/locale_providers.dart';
import 'package:ai_food_analyzer/core/router/app_router.dart';
import 'package:ai_food_analyzer/core/theme/app_colors.dart';
import 'package:ai_food_analyzer/core/widgets/premium_action_button.dart';
import 'package:ai_food_analyzer/features/premium/presentation/providers/premium_purchase_provider.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isOpeningHistory = false;
  bool _isSigningOut = false;

  Future<void> _openHistory() async {
    if (_isOpeningHistory) return;
    setState(() => _isOpeningHistory = true);
    await context.push(AppRoutes.history);
    if (mounted) {
      setState(() => _isOpeningHistory = false);
    }
  }

  Future<void> _confirmSignOut() async {
    if (_isSigningOut) return;
    final l10n = AppLocalizations.of(context);
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Theme.of(dialogContext).colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Theme.of(dialogContext).colorScheme.error,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.signOutTitle,
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.signOutDescription,
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(dialogContext).colorScheme.error,
                    foregroundColor: Theme.of(
                      dialogContext,
                    ).colorScheme.onError,
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(l10n.signOut),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
    if (shouldSignOut != true || !mounted) return;

    setState(() => _isSigningOut = true);
    try {
      if (AppConfig.isSupabaseConfigured) {
        await Supabase.instance.client.auth.signOut();
      }
      if (mounted) context.go(AppRoutes.auth);
    } on AuthException {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.signOutFailed)));
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  Future<void> _openAccount() async {
    final l10n = AppLocalizations.of(context);
    final isPremium = ref.read(premiumEntitlementProvider).value ?? false;
    final email = AppConfig.isSupabaseConfigured
        ? Supabase.instance.client.auth.currentUser?.email ?? ''
        : '';
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: isPremium
                  ? AppColors.champagneLight
                  : Theme.of(sheetContext).colorScheme.surfaceContainerHighest,
              child: Icon(
                isPremium
                    ? Icons.workspace_premium_rounded
                    : Icons.person_rounded,
                color: isPremium
                    ? AppColors.deepEmerald
                    : Theme.of(sheetContext).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.accountTitle,
              style: Theme.of(
                sheetContext,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(
                  sheetContext,
                ).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mail_outline_rounded, size: 21),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      email.isNotEmpty ? email : l10n.emailUnavailable,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isPremium ? l10n.premiumMember : l10n.freeMember,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: isPremium
                      ? AppColors.deepEmerald
                      : AppColors.emerald,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(sheetContext).pop('premium'),
                icon: Icon(
                  isPremium
                      ? Icons.workspace_premium_outlined
                      : Icons.auto_awesome_rounded,
                ),
                label: Text(
                  isPremium ? l10n.managePremium : l10n.upgradeToPremium,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(sheetContext).colorScheme.error,
                  side: BorderSide(
                    color: Theme.of(
                      sheetContext,
                    ).colorScheme.error.withValues(alpha: 0.55),
                  ),
                ),
                onPressed: () => Navigator.of(sheetContext).pop('signOut'),
                icon: const Icon(Icons.logout_rounded),
                label: Text(l10n.signOut),
              ),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'premium') {
      await context.push(AppRoutes.premium);
      ref.invalidate(premiumEntitlementProvider);
    } else if (action == 'signOut') {
      await _confirmSignOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isPremium = ref.watch(premiumEntitlementProvider).value ?? false;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF071B15),
                    Color(0xFF0A211A),
                    Color(0xFF102B22),
                  ]
                : const [AppColors.ivory, AppColors.cream, Color(0xFFEAF5EE)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -110,
              right: -90,
              child: _AmbientGlow(
                size: 300,
                color: isDark
                    ? const Color(0x263BCB94)
                    : const Color(0x2ED6B875),
              ),
            ),
            Positioned(
              bottom: -140,
              left: -120,
              child: _AmbientGlow(
                size: 340,
                color: isDark
                    ? const Color(0x1FD6B875)
                    : const Color(0x241FAD82),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 52,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              _BrandMark(isPremium: isPremium),
                              const SizedBox(height: 24),
                              Text(
                                l10n.aiPowered,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.champagne
                                      : AppColors.emerald,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.2,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Text(
                                  l10n.chooseFeatureTitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: colors.onSurface,
                                    fontSize: 40,
                                    height: 1.08,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.7,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 380,
                                  ),
                                  child: Text(
                                    l10n.chooseFeatureDescription,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 16,
                                      height: 1.55,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              _FeatureCard(
                                icon: Icons.restaurant_rounded,
                                title: l10n.scanFoodTitle,
                                description: l10n.scanFoodDescription,
                                accent: AppColors.emerald,
                                onTap: () => _showFoodSource(context),
                              ),
                              const SizedBox(height: 14),
                              _FeatureCard(
                                icon: Icons.menu_book_rounded,
                                title: l10n.menuScanTitle,
                                description: l10n.menuScanDescription,
                                accent: AppColors.champagne,
                                onTap: () => _showMenuSource(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 10,
              right: 18,
              child: SafeArea(
                child: Row(
                  children: [
                    PopupMenuButton<String>(
                      tooltip: l10n.languageTitle,
                      onSelected: (languageCode) {
                        ref
                            .read(appLocaleProvider.notifier)
                            .setLocale(Locale(languageCode));
                      },
                      itemBuilder: (context) {
                        final selected = Localizations.localeOf(
                          context,
                        ).languageCode;
                        return [
                          _languageItem(
                            code: 'en',
                            label: l10n.englishLanguage,
                            selected: selected == 'en',
                          ),
                          _languageItem(
                            code: 'tr',
                            label: l10n.turkishLanguage,
                            selected: selected == 'tr',
                          ),
                        ];
                      },
                      icon: const Icon(Icons.language_rounded),
                    ),
                    IconButton.filledTonal(
                      tooltip: l10n.historyTitle,
                      onPressed: _isOpeningHistory ? null : _openHistory,
                      style: IconButton.styleFrom(
                        backgroundColor: colors.surface.withValues(alpha: 0.78),
                        foregroundColor: colors.onSurface,
                      ),
                      icon: const Icon(Icons.history_rounded),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filledTonal(
                      tooltip: l10n.accountTitle,
                      onPressed: _isSigningOut ? null : _openAccount,
                      style: IconButton.styleFrom(
                        backgroundColor: colors.surface.withValues(alpha: 0.78),
                        foregroundColor: colors.onSurface,
                      ),
                      icon: _isSigningOut
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.person_outline_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _languageItem({
    required String code,
    required String label,
    required bool selected,
  }) {
    return PopupMenuItem(
      value: code,
      child: Row(
        children: [
          Icon(selected ? Icons.check_rounded : Icons.language_rounded),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );

    if (image != null && context.mounted) {
      await context.push(AppRoutes.preview, extra: image.path);
    }
  }

  Future<void> _showFoodSource(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<_FoodSource>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.emerald,
                  size: 30,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.scanFoodTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                l10n.scanFoodSourceDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              PremiumActionButton(
                label: l10n.takePhoto,
                icon: Icons.photo_camera_rounded,
                onPressed: () =>
                    Navigator.pop(sheetContext, _FoodSource.camera),
              ),
              const SizedBox(height: 8),
              PremiumActionButton(
                label: l10n.chooseFromGallery,
                icon: Icons.photo_library_outlined,
                secondary: true,
                onPressed: () =>
                    Navigator.pop(sheetContext, _FoodSource.gallery),
              ),
              const SizedBox(height: 8),
              PremiumActionButton(
                label: l10n.scanBarcode,
                icon: Icons.qr_code_scanner_rounded,
                secondary: true,
                onPressed: () =>
                    Navigator.pop(sheetContext, _FoodSource.barcode),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || source == null) return;
    if (source == _FoodSource.camera) {
      await this.context.push(AppRoutes.camera);
    } else if (source == _FoodSource.gallery) {
      await _pickFromGallery(this.context);
    } else {
      await this.context.push(AppRoutes.barcodeScan);
    }
  }

  Future<void> _showMenuSource(BuildContext context) async {
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
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.champagne.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.deepEmerald,
                  size: 30,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.menuPhotoSheetTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                l10n.menuPhotoSheetDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    if (!mounted || source == null) return;
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 92,
    );
    if (image != null && mounted) {
      await this.context.push(AppRoutes.menuScan, extra: image.path);
    }
  }
}

enum _FoodSource { camera, gallery, barcode }

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.84),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.size, required this.color});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: 104,
          height: 104,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.82),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? AppColors.champagne.withValues(alpha: 0.5)
                  : Colors.white,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2ED6B875),
                blurRadius: 32,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.emeraldBright, AppColors.teal],
              ),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 45),
          ),
        ),
        if (isPremium)
          Positioned(
            bottom: -9,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.champagneLight, AppColors.champagne],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 10),
                ],
              ),
              child: const Text(
                'PREMIUM',
                style: TextStyle(
                  color: AppColors.deepEmerald,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
