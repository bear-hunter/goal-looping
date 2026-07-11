import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/theme.dart';
import '../models/growth_area.dart';

/// Factor health tree visualization widget
class FactorHealthTree extends StatelessWidget {
  final Factor factor;
  final VoidCallback? onTap;
  final bool showDetails;

  const FactorHealthTree({
    super.key,
    required this.factor,
    this.onTap,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _getBorderColor(context),
            width: factor.isActiveFocus ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  factor.treeEmoji,
                  style: const TextStyle(fontSize: 32),
                ).animate().shimmer(
                  duration: factor.healthStatus == 'flourishing'
                      ? 900.ms
                      : 0.ms,
                  color: colors.onPrimary.withAlpha(30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (factor.isActiveFocus)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: colors.primary.withAlpha(30),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              ),
                              child: Text(
                                'FOCUS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              factor.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        factor.typeName,
                        style: TextStyle(fontSize: 12, color: colors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (showDetails && factor.isActiveFocus) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: factor.effectiveHealthPercent / 100,
                        backgroundColor: colors.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getHealthColor(context),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${factor.effectiveHealthPercent.toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getHealthColor(context),
                    ),
                  ),
                ],
              ),
              if (factor.daysSinceWork > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      size: 14,
                      color: factor.daysSinceWork > 3
                          ? colors.danger
                          : colors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      factor.daysSinceWork == 1
                          ? 'No work yesterday'
                          : 'No work for ${factor.daysSinceWork} days',
                      style: TextStyle(
                        fontSize: 11,
                        color: factor.daysSinceWork > 3
                            ? colors.danger
                            : colors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ],
            if (!factor.isActiveFocus && showDetails) ...[
              const SizedBox(height: 8),
              Text(
                'Dormant — tap to activate',
                style: TextStyle(fontSize: 11, color: colors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    final colors = context.colors;
    if (!factor.isActiveFocus) return colors.surfaceVariant.withAlpha(100);
    switch (factor.healthStatus) {
      case 'flourishing':
        return colors.success.withAlpha(15);
      case 'healthy':
        return colors.success.withAlpha(10);
      case 'wilting':
        return colors.warning.withAlpha(15);
      case 'dead':
        return colors.danger.withAlpha(15);
      default:
        return colors.surfaceVariant;
    }
  }

  Color _getBorderColor(BuildContext context) {
    final colors = context.colors;
    if (!factor.isActiveFocus) return colors.glassBorder;
    switch (factor.healthStatus) {
      case 'flourishing':
        return colors.success.withAlpha(100);
      case 'healthy':
        return colors.success.withAlpha(50);
      case 'wilting':
        return colors.warning;
      case 'dead':
        return colors.danger;
      default:
        return colors.glassBorder;
    }
  }

  Color _getHealthColor(BuildContext context) {
    final colors = context.colors;
    if (factor.effectiveHealthPercent >= 75) return colors.success;
    if (factor.effectiveHealthPercent >= 50) return colors.info;
    if (factor.effectiveHealthPercent >= 25) return colors.warning;
    return colors.danger;
  }
}

/// Shared compact factor tile for Plan/Forest factor lists.
class FactorTile extends StatelessWidget {
  final Factor factor;
  final VoidCallback? onTap;
  final bool compact;
  final Widget? trailing;

  const FactorTile({
    super.key,
    required this.factor,
    this.onTap,
    this.compact = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderColor = factor.isActiveFocus
        ? colors.primary.withAlpha(90)
        : colors.glassBorder;
    final bgColor = factor.isActiveFocus
        ? colors.primary.withAlpha(18)
        : colors.surfaceLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: compact ? 170 : double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Text(factor.treeEmoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    factor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _MiniPill(
                        label: 'Lv${factor.currentLevel}',
                        color: colors.primary,
                      ),
                      _MiniPill(
                        label: 'gap ${factor.gap}',
                        color: factor.needsFocus
                            ? colors.warning
                            : colors.textMuted,
                      ),
                      if (factor.needsResearch)
                        _MiniPill(label: 'research', color: colors.info),
                    ],
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Compact factor chip with health indicator
class FactorHealthChip extends StatelessWidget {
  final Factor factor;
  final VoidCallback? onTap;

  const FactorHealthChip({super.key, required this.factor, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: factor.isActiveFocus
              ? colors.primary.withAlpha(20)
              : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: factor.isActiveFocus ? colors.primary : colors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(factor.treeEmoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              factor.name,
              style: TextStyle(fontSize: 12, color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
