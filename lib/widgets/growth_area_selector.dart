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
  /// Currently selected factor IDs
  final List<String> selectedAreaIds;

  /// Callback when selection changes
  final ValueChanged<List<String>> onSelectionChanged;

  /// Optional label for the selector
  final String label;

  /// Whether to allow multiple selections
  final bool multiSelect;

  /// Whether to show only active focus areas
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceLight = isDark
        ? AppColors.surfaceLight
        : LightColors.surfaceLight;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;

    return Consumer<AppState>(
      builder: (context, state, _) {
        // Get all factors, optionally filtered
        List<Factor> areas = state.factors;
        if (onlyActiveFocus) {
          areas = areas.where((a) => a.isActiveFocus).toList();
        }

        // Get selected areas for display
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
                color: textSecondary,
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
                  color: surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedAreas.isNotEmpty
                        ? AppColors.success.withAlpha(100)
                        : AppColors.glassBorder,
                  ),
                ),
                child: Row(
                  children: [
                    if (selectedAreas.isNotEmpty) ...[
                      // Show selected areas
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
                        color: AppColors.textMuted,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tap to select a dissected tree',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    ],
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surface : LightColors.surface;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;

    // Group areas by goal
    final goals = state.goals;
    final areasByGoal = <String, List<Factor>>{};
    for (final area in areas) {
      areasByGoal.putIfAbsent(area.goalId, () => []).add(area);
    }

    // Track local selection state
    List<String> localSelection = List<String>.from(selectedAreaIds);

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.glassBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Title
                  Text(
                    'Select Dissected Tree',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Work will be tracked in the selected area\'s history',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Areas list grouped by goal
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        // "None" option to clear selection
                        _AreaOption(
                          area: null,
                          goalName: null,
                          isSelected: localSelection.isEmpty,
                          onTap: () {
                            setModalState(() => localSelection.clear());
                            if (!multiSelect) {
                              onSelectionChanged([]);
                              Navigator.pop(context);
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        // Grouped by goals
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
                              // Goal header
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
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        goal.title,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Areas under this goal
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
                                        Navigator.pop(context);
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
                  // Confirm button (for multi-select)
                  if (multiSelect)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            onSelectionChanged(localSelection);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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

/// Chip showing a selected factor
class _AreaChip extends StatelessWidget {
  final Factor area;
  final VoidCallback onRemove;

  const _AreaChip({required this.area, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor(area.type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
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

/// Individual factor option in the picker
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceLight = isDark
        ? AppColors.surfaceLight
        : LightColors.surfaceLight;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;

    // "None" option
    if (area == null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withAlpha(20) : surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: isSelected ? 2 : 0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.block_rounded,
                  color: AppColors.textMuted,
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
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      'Work won\'t be tracked in any tree',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      );
    }

    final color = _getTypeColor(area!.type);
    final gapText = 'Gap: ${area!.gap} levels';
    final healthText = area!.isActiveFocus
        ? '${area!.healthPercent.toInt()}% health'
        : 'Dormant';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(20) : surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Row(
          children: [
            // Tree emoji and level
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
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
            // Area info
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
                            color: textPrimary,
                          ),
                        ),
                      ),
                      // Focus indicator
                      if (area!.isActiveFocus)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '🔥 Focus',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _InfoTag(text: area!.typeName, color: color),
                      const SizedBox(width: 6),
                      _InfoTag(text: gapText, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      _InfoTag(
                        text: healthText,
                        color: area!.isActiveFocus
                            ? AppColors.success
                            : AppColors.textMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Selection indicator
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}

/// Small info tag
class _InfoTag extends StatelessWidget {
  final String text;
  final Color color;

  const _InfoTag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 10, color: color));
  }
}

/// Get color based on factor type
Color _getTypeColor(FactorType type) {
  switch (type) {
    case FactorType.knowledge:
      return AppColors.info;
    case FactorType.skill:
      return AppColors.success;
    case FactorType.attribute:
      return AppColors.warning;
    case FactorType.process:
      return AppColors.primary;
    case FactorType.resource:
      return AppColors.danger;
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
              final color = _getTypeColor(area.type);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
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
