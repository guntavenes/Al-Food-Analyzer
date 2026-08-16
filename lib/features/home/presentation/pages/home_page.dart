import 'package:ai_food_analyzer/core/localization/locale_providers.dart';
import 'package:ai_food_analyzer/core/router/app_router.dart';
import 'package:ai_food_analyzer/core/theme/app_colors.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isOpeningHistory = false;

  Future<void> _openHistory() async {
    if (_isOpeningHistory) return;
    setState(() => _isOpeningHistory = true);
    await context.push(AppRoutes.history);
    if (mounted) {
      setState(() => _isOpeningHistory = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFCFDF9), AppColors.cream, Color(0xFFEAF8F0)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -110,
              right: -90,
              child: _AmbientGlow(size: 300, color: Color(0x3355D89B)),
            ),
            const Positioned(
              bottom: -140,
              left: -120,
              child: _AmbientGlow(size: 340, color: Color(0x2619B88A)),
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
                              const _BrandMark(),
                              const SizedBox(height: 24),
                              Text(
                                l10n.aiPowered,
                                style: const TextStyle(
                                  color: AppColors.teal,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.2,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 34),
                            child: Column(
                              children: [
                                Text(
                                  l10n.homeTitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.ink,
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
                                    l10n.homeDescription,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF65756F),
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
                              _CameraButton(
                                label: l10n.takePhoto,
                                onPressed: () => context.push(AppRoutes.camera),
                              ),
                              const SizedBox(height: 14),
                              _GalleryButton(
                                label: l10n.chooseFromGallery,
                                onPressed: () => _pickFromGallery(context),
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
                        backgroundColor: Colors.white.withValues(alpha: 0.78),
                        foregroundColor: AppColors.ink,
                      ),
                      icon: const Icon(Icons.history_rounded),
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
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24128B67),
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
            colors: [AppColors.mint, AppColors.teal],
          ),
        ),
        child: const Icon(Icons.eco_rounded, color: Colors.white, size: 45),
      ),
    );
  }
}

class _CameraButton extends StatelessWidget {
  const _CameraButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF22B879), AppColors.teal],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D129B70),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(68),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        icon: const Icon(Icons.photo_camera_rounded, size: 25),
        label: Text(label),
      ),
    );
  }
}

class _GalleryButton extends StatelessWidget {
  const _GalleryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        backgroundColor: Colors.white.withValues(alpha: 0.72),
        minimumSize: const Size.fromHeight(60),
        side: const BorderSide(color: Color(0xFFDCE8E1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      icon: const Icon(Icons.photo_library_outlined, size: 22),
      label: Text(label),
    );
  }
}
