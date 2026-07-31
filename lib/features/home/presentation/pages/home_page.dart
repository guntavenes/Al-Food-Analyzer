import 'package:ai_food_analyzer/core/theme/app_colors.dart';
import 'package:ai_food_analyzer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                              _CameraButton(label: l10n.takePhoto),
                              const SizedBox(height: 14),
                              _GalleryButton(label: l10n.chooseFromGallery),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
  const _CameraButton({required this.label});

  final String label;

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
        onPressed: () {},
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
  const _GalleryButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
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
