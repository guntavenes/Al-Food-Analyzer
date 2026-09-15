import 'dart:math' as math;

import 'package:ai_food_analyzer/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PremiumAnalysisLoader extends StatefulWidget {
  const PremiumAnalysisLoader({required this.label, super.key});

  final String label;

  @override
  State<PremiumAnalysisLoader> createState() => _PremiumAnalysisLoaderState();
}

class _PremiumAnalysisLoaderState extends State<PremiumAnalysisLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.night.withValues(alpha: 0.72),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.rotate(
                angle: _controller.value * math.pi * 2,
                child: child,
              ),
              child: Container(
                width: 74,
                height: 74,
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.mint,
                      AppColors.champagneLight,
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.forest,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.champagneLight,
                    size: 29,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 9),
            SizedBox(
              width: 132,
              child: LinearProgressIndicator(
                minHeight: 3,
                borderRadius: BorderRadius.circular(99),
                color: AppColors.mint,
                backgroundColor: Colors.white.withValues(alpha: 0.14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
