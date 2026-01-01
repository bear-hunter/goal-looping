import 'package:flutter/material.dart';

import '../core/theme/theme.dart';

/// A decorative category ribbon that shows on the left edge of cards
/// Provides visual categorization with a colored vertical stripe
class CategoryRibbon extends StatelessWidget {
  final Color color;
  final double width;
  final double? height;
  final BorderRadius? borderRadius;

  const CategoryRibbon({
    super.key,
    required this.color,
    this.width = 4,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius ?? BorderRadius.circular(width / 2),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(80),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
    );
  }
}

/// A card wrapper that includes the category ribbon on the left
class CategoryRibbonCard extends StatelessWidget {
  final Widget child;
  final Color categoryColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;
  final double ribbonWidth;

  const CategoryRibbonCard({
    super.key,
    required this.child,
    required this.categoryColor,
    this.onTap,
    this.padding,
    this.boxShadow,
    this.ribbonWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: boxShadow ?? AppShadows.card,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Category ribbon
                    Container(
                      width: ribbonWidth,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withAlpha(60),
                            blurRadius: 6,
                            offset: const Offset(2, 0),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: padding ?? const EdgeInsets.all(12),
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A minimal ribbon indicator for inline use
class MiniCategoryIndicator extends StatelessWidget {
  final Color color;
  final double size;

  const MiniCategoryIndicator({
    super.key,
    required this.color,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(100),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}
