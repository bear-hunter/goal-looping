import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// A reusable section header widget for consistent UI patterns.
/// 
/// Used throughout the app for organizing content into labeled sections.
/// Automatically applies theme-aware colors and consistent styling.
/// 
/// Usage:
/// ```dart
/// SectionHeader(title: 'Recent Activity')
/// SectionHeader(
///   title: 'Tasks',
///   trailing: TextButton(onPressed: () {}, child: Text('See All')),
/// )
/// ```
class SectionHeader extends StatelessWidget {
  /// The section title text
  final String title;
  
  /// Optional trailing widget (e.g., "See All" button, count badge)
  final Widget? trailing;
  
  /// Whether to use uppercase styling (default: true)
  final bool uppercase;
  
  /// Custom text color (uses theme secondary text if not provided)
  final Color? textColor;
  
  /// Padding around the header
  final EdgeInsetsGeometry padding;
  
  /// Whether to add a subtle divider line below
  final bool showDivider;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.uppercase = true,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveColor = textColor ?? colors.textSecondary;
    
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                uppercase ? title.toUpperCase() : title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: effectiveColor,
                  letterSpacing: uppercase ? 1.2 : 0,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (showDivider) ...[
            const SizedBox(height: 8),
            Divider(color: colors.divider, height: 1),
          ],
        ],
      ),
    );
  }
}

/// A larger section header variant for major sections
/// 
/// Uses primary text color and larger font for more prominent sections.
class LargeSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final String? subtitle;

  const LargeSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// A card-based section container with header and content
/// 
/// Useful for grouping related settings or information.
class SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const SectionCard({
    super.key,
    this.title,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}
