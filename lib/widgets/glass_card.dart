import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// Glassmorphism card with blur effect - theme-aware
///
/// Performance note: The blur effect is expensive on mobile GPUs.
/// This implementation uses a semi-transparent overlay to achieve a similar
/// glass aesthetic without the real-time blur overhead.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool highlighted;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: highlighted
                  ? colors.primary.withAlpha(isDark ? 25 : 20)
                  : (isDark ? colors.surface.withAlpha(230) : colors.surface),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: highlighted
                    ? colors.primary.withAlpha(128)
                    : colors.glassBorder.withAlpha(15),
                width: 1,
              ),
              boxShadow: highlighted ? AppShadows.primaryGlow : AppShadows.card,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
