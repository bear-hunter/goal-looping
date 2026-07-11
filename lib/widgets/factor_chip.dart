import 'package:flutter/material.dart';
import '../core/theme/theme.dart';
import '../models/growth_area.dart';

/// Selectable chip for factors (Knowledge, Skills, Attributes, Process, Resource)
class FactorChip extends StatelessWidget {
  final Factor factor;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showGap;

  const FactorChip({
    super.key,
    required this.factor,
    this.isSelected = false,
    this.onTap,
    this.showGap = false,
  });

  Color _typeColor(BuildContext context) {
    final colors = context.colors;
    switch (factor.type) {
      case FactorType.knowledge:
        return colors.info;
      case FactorType.skill:
        return colors.success;
      case FactorType.attribute:
        return colors.warning;
      case FactorType.process:
        return colors.primary;
      case FactorType.resource:
        return colors.accent;
    }
  }

  IconData get typeIcon {
    switch (factor.type) {
      case FactorType.knowledge:
        return Icons.menu_book_rounded;
      case FactorType.skill:
        return Icons.build_rounded;
      case FactorType.attribute:
        return Icons.psychology_rounded;
      case FactorType.process:
        return Icons.account_tree_rounded;
      case FactorType.resource:
        return Icons.inventory_2_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typeColor = _typeColor(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.standard,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? typeColor.withValues(alpha: 0.2)
              : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? typeColor : colors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              typeIcon,
              size: 16,
              color: isSelected ? typeColor : colors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              factor.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? typeColor : colors.textSecondary,
              ),
            ),
            if (showGap && factor.gap > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: factor.needsFocus
                      ? colors.danger.withValues(alpha: 0.2)
                      : colors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '-${factor.gap}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: factor.needsFocus ? colors.danger : colors.warning,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Factor type filter chips
class FactorTypeChip extends StatelessWidget {
  final FactorType type;
  final bool isSelected;
  final VoidCallback? onTap;

  const FactorTypeChip({
    super.key,
    required this.type,
    this.isSelected = false,
    this.onTap,
  });

  Color _typeColor(BuildContext context) {
    final colors = context.colors;
    switch (type) {
      case FactorType.knowledge:
        return colors.info;
      case FactorType.skill:
        return colors.success;
      case FactorType.attribute:
        return colors.warning;
      case FactorType.process:
        return colors.primary;
      case FactorType.resource:
        return colors.accent;
    }
  }

  String get label {
    switch (type) {
      case FactorType.knowledge:
        return 'Knowledge';
      case FactorType.skill:
        return 'Skill';
      case FactorType.attribute:
        return 'Attribute';
      case FactorType.process:
        return 'Process';
      case FactorType.resource:
        return 'Resource';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typeColor = _typeColor(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.standard,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? typeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? typeColor : colors.glassBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? colors.onPrimary : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
