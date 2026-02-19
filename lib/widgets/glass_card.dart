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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-aware colors
    final glassBorder = isDark
        ? AppColors.glassBorder
        : LightColors.glassBorder;
    final surfaceColor = isDark ? AppColors.surface : LightColors.surface;

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
              // Use semi-transparent surface color for glass effect (much faster than BackdropFilter)
              color: isDark
                  ? (highlighted
                        ? AppColors.primary.withAlpha(25)
                        : surfaceColor.withAlpha(230))
                  : surfaceColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: highlighted
                    ? AppColors.primary.withAlpha(128)
                    : glassBorder.withAlpha(
                        15,
                      ), // Reduced from default opacity for subtler glass look
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
