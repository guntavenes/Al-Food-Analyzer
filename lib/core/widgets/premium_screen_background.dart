import 'package:ai_food_analyzer/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PremiumScreenBackground extends StatelessWidget {
  const PremiumScreenBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [AppColors.night, AppColors.forest, Color(0xFF0B241B)]
              : const [AppColors.ivory, Color(0xFFF5F6EE), Color(0xFFEAF4ED)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -150,
            right: -120,
            child: _Glow(
              color: isDark ? const Color(0x1F53D6A0) : const Color(0x28D6B875),
            ),
          ),
          Positioned(
            bottom: -190,
            left: -150,
            child: _Glow(
              size: 380,
              color: isDark ? const Color(0x16D6B875) : const Color(0x1F0F8F6A),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, this.size = 320});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
