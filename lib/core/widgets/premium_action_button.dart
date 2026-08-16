import 'package:ai_food_analyzer/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PremiumActionButton extends StatefulWidget {
  const PremiumActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.secondary = false,
    this.loading = false,
    this.height = 66,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool secondary;
  final bool loading;
  final double height;

  @override
  State<PremiumActionButton> createState() => _PremiumActionButtonState();
}

class _PremiumActionButtonState extends State<PremiumActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final enabled = widget.onPressed != null && !widget.loading;
    final foreground = widget.secondary ? colors.onSurface : Colors.white;

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.62,
        duration: const Duration(milliseconds: 180),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: widget.secondary
                ? LinearGradient(
                    colors: [
                      colors.surface.withValues(alpha: 0.94),
                      colors.surfaceContainerLow.withValues(alpha: 0.9),
                    ],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.mint,
                      AppColors.emeraldBright,
                      AppColors.teal,
                    ],
                    stops: [0, 0.52, 1],
                  ),
            border: Border.all(
              color: widget.secondary
                  ? colors.outlineVariant.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.secondary
                    ? colors.shadow.withValues(alpha: 0.08)
                    : const Color(0x4A08745B),
                blurRadius: widget.secondary ? 18 : 30,
                offset: const Offset(0, 13),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: enabled ? widget.onPressed : null,
              onHighlightChanged: (value) {
                if (mounted) setState(() => _pressed = value);
              },
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: widget.height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: foreground.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: widget.loading
                            ? Padding(
                                padding: const EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: foreground,
                                ),
                              )
                            : Icon(widget.icon, color: foreground, size: 21),
                      ),
                      const SizedBox(width: 13),
                      Flexible(
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: foreground.withValues(alpha: 0.76),
                        size: 19,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
