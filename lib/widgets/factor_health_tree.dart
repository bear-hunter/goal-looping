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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _getBorderColor(), width: factor.isActiveFocus ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Tree emoji
                Text(
                  factor.treeEmoji,
                  style: const TextStyle(fontSize: 32),
                ).animate(onPlay: (c) => c.repeat()).shimmer(
                  duration: factor.healthStatus == 'flourishing' ? 2.seconds : 0.ms,
                  color: Colors.white.withAlpha(30),
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
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('⭐ FOCUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ),
                          Expanded(
                            child: Text(
                              factor.name,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(factor.typeName, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
            if (showDetails && factor.isActiveFocus) ...[
              const SizedBox(height: 12),
              // Health bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: factor.healthPercent / 100,
                        backgroundColor: AppColors.surfaceLight,
                        valueColor: AlwaysStoppedAnimation<Color>(_getHealthColor()),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${factor.healthPercent.toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _getHealthColor())),
                ],
              ),
              if (factor.daysSinceWork > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.warning_rounded, size: 14, color: factor.daysSinceWork > 3 ? AppColors.danger : AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      factor.daysSinceWork == 1 ? 'No work yesterday' : 'No work for ${factor.daysSinceWork} days',
                      style: TextStyle(fontSize: 11, color: factor.daysSinceWork > 3 ? AppColors.danger : AppColors.warning),
                    ),
                  ],
                ),
              ],
            ],
            if (!factor.isActiveFocus && showDetails) ...[
              const SizedBox(height: 8),
              Text('💤 Dormant - tap to activate', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (!factor.isActiveFocus) return AppColors.surfaceLight.withAlpha(100);
    switch (factor.healthStatus) {
      case 'flourishing': return AppColors.success.withAlpha(15);
      case 'healthy': return AppColors.success.withAlpha(10);
      case 'wilting': return AppColors.warning.withAlpha(15);
      case 'dead': return AppColors.danger.withAlpha(15);
      default: return AppColors.surfaceLight;
    }
  }

  Color _getBorderColor() {
    if (!factor.isActiveFocus) return AppColors.glassBorder;
    switch (factor.healthStatus) {
      case 'flourishing': return AppColors.success.withAlpha(100);
      case 'healthy': return AppColors.success.withAlpha(50);
      case 'wilting': return AppColors.warning;
      case 'dead': return AppColors.danger;
      default: return AppColors.glassBorder;
    }
  }

  Color _getHealthColor() {
    if (factor.healthPercent >= 75) return AppColors.success;
    if (factor.healthPercent >= 50) return AppColors.info;
    if (factor.healthPercent >= 25) return AppColors.warning;
    return AppColors.danger;
  }
}

/// Compact Factor chip with health indicator
class FactorHealthChip extends StatelessWidget {
  final Factor factor;
  final VoidCallback? onTap;

  const FactorHealthChip({super.key, required this.factor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: factor.isActiveFocus ? AppColors.primary.withAlpha(20) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: factor.isActiveFocus ? AppColors.primary : AppColors.glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(factor.treeEmoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(factor.name, style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
