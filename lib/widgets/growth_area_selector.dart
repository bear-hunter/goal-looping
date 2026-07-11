import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/theme.dart';
import '../models/growth_area.dart';
import '../models/goal.dart';
import '../providers/app_state.dart';

/// A reusable widget for selecting Factors (dissected trees/growth areas)
/// Used in task, habit, and recurring task creation/edit forms
/// to connect work items to specific goal factors for tracking work history
class GrowthAreaSelector extends StatelessWidget {
  final List<String> selectedAreaIds;
  final ValueChanged<List<String>> onSelectionChanged;
  final String label;
  final bool multiSelect;
  final bool onlyActiveFocus;

  const GrowthAreaSelector({
    super.key,
    required this.selectedAreaIds,
    required this.onSelectionChanged,
    this.label = 'Link to Growth Area',
    this.multiSelect = true,
    this.onlyActiveFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Consumer<AppState>(
      builder: (context, state, _) {
        List<Factor> areas = state.factors;
        if (onlyActiveFocus) {
          areas = areas.where((a) => a.isActiveFocus).toList();
        }

        final selectedAreas = areas
            .where((a) => selectedAreaIds.contains(a.id))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showAreaPicker(context, state, areas),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: selectedAreas.isNotEmpty
                        ? colors.success.withAlpha(100)
                        : colors.glassBorder,
                  ),
                ),
                child: Row(
                  children: [
                    if (selectedAreas.isNotEmpty) ...[
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: selectedAreas.map((area) {
                            return _AreaChip(
                              area: area,
                              onRemove: () {
                                final newIds = List<String>.from(
                                  selectedAreaIds,
                                )..remove(area.id);
                                onSelectionChanged(newIds);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.account_tree_outlined,
                        color: colors.textMuted,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tap to select a dissected tree',
                          style: TextStyle(color: colors.textMuted),
                        ),
                      ),
                    ],
                    Icon(Icons.chevron_right_rounded, color: colors.textMuted),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAreaPicker(
    BuildContext context,
    AppState state,
    List<Factor> areas,
  ) {
    final colors = context.colors;

    final goals = state.goals;
    final areasByGoal = <String, List<Factor>>{};
    for (final area in areas) {
      areasByGoal.putIfAbsent(area.goalId, () => []).add(area);
    }

    List<String> localSelection = List<String>.from(selectedAreaIds);

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final innerColors = ctx.colors;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: innerColors.glassBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Select Dissected Tree',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: innerColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Work will be tracked in the selected area\'s history',
                    style: TextStyle(
                      fontSize: 13,
                      color: innerColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: MediaQuery.of(ctx).size.height * 0.5,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _AreaOption(
                          area: null,
                          goalName: null,
                          isSelected: localSelection.isEmpty,
                          onTap: () {
                            setModalState(() => localSelection.clear());
                            if (!multiSelect) {
                              onSelectionChanged([]);
                              Navigator.pop(ctx);
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        ...areasByGoal.entries.map((entry) {
                          final goal = goals.firstWhere(
                            (g) => g.id == entry.key,
                            orElse: () => Goal(
                              id: '',
                              title: 'Unknown Goal',
                              targetDate: DateTime.now(),
                            ),
                          );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 16,
                                  bottom: 8,
                                  left: 4,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.flag_rounded,
                                      size: 16,
                                      color: innerColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        goal.title,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: innerColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...entry.value.map((area) {
                                final isSelected = localSelection.contains(
                                  area.id,
                                );
                                return _AreaOption(
                                  area: area,
                                  goalName: goal.title,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setModalState(() {
                                      if (multiSelect) {
                                        if (isSelected) {
                                          localSelection.remove(area.id);
                                        } else {
                                          localSelection.add(area.id);
                                        }
                                      } else {
                                        localSelection = [area.id];
                                        onSelectionChanged(localSelection);
                                        Navigator.pop(ctx);
                                      }
                                    });
                                  },
                                );
                              }),
                            ],
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  if (multiSelect)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            onSelectionChanged(localSelection);
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: innerColors.primary,
                            foregroundColor: innerColors.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          child: Text(
                            localSelection.isEmpty
                                ? 'Clear Selection'
                                : 'Select ${localSelection.length} Area${localSelection.length > 1 ? 's' : ''}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _AreaChip extends StatelessWidget {
  final Factor area;
  final VoidCallback onRemove;

  const _AreaChip({required this.area, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(context, area.type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(area.treeEmoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            area.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 16, color: color),
          ),
        ],
      ),
    );
  }
}

class _AreaOption extends StatelessWidget {
  final Factor? area;
  final String? goalName;
  final bool isSelected;
  final VoidCallback onTap;

  const _AreaOption({
    required this.area,
    required this.goalName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (area == null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary.withAlpha(20)
                : colors.surfaceLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? colors.primary : Colors.transparent,
              width: isSelected ? 2 : 0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.textMuted.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.block_rounded,
                  color: colors.textMuted,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No Link',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      'Work won\'t be tracked in any tree',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: colors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      );
    }

    final color = _typeColor(context, area!.type);
    final gapText = 'Gap: ${area!.gap} levels';
    final healthText = area!.isActiveFocus
        ? '${area!.effectiveHealthPercent.toInt()}% health'
        : 'Dormant';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(20) : colors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(area!.treeEmoji, style: const TextStyle(fontSize: 20)),
                  Text(
                    'Lv${area!.currentLevel}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          area!.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      if (area!.isActiveFocus)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.warning.withAlpha(30),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department_rounded,
                                size: 11,
                                color: colors.warning,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Focus',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: colors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _InfoTag(text: area!.typeName, color: color),
                      const SizedBox(width: 6),
                      _InfoTag(text: gapText, color: colors.textSecondary),
                      const SizedBox(width: 6),
                      _InfoTag(
                        text: healthText,
                        color: area!.isActiveFocus
                            ? colors.success
                            : colors.textMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final String text;
  final Color color;

  const _InfoTag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 10, color: color));
  }
}

Color _typeColor(BuildContext context, FactorType type) {
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

/// Compact badge to show linked growth areas inline
class GrowthAreaBadge extends StatelessWidget {
  final List<String> areaIds;
  final VoidCallback? onTap;

  const GrowthAreaBadge({super.key, required this.areaIds, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (areaIds.isEmpty) return const SizedBox.shrink();

    return Consumer<AppState>(
      builder: (context, state, _) {
        final areas = state.factors
            .where((a) => areaIds.contains(a.id))
            .toList();

        if (areas.isEmpty) return const SizedBox.shrink();

        return GestureDetector(
          onTap: onTap,
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: areas.map((area) {
              final color = _typeColor(context, area.type);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(area.treeEmoji, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 3),
                    Text(
                      area.name,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
