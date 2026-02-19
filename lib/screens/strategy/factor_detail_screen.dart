import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';

import '../../providers/app_state.dart';
import '../../widgets/glass_card.dart';

import '../../widgets/tree_platform.dart';

/// Phase 2: Factor Detail Screen - "Work Volume" Dashboard
/// Shows all effort linked to a specific Factor
class FactorDetailScreen extends StatefulWidget {
  final String factorId;

  const FactorDetailScreen({super.key, required this.factorId});

  @override
  State<FactorDetailScreen> createState() => _FactorDetailScreenState();
}

class _FactorDetailScreenState extends State<FactorDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _targetDescController;
  late TextEditingController _currentDescController;
  late TextEditingController _targetLevelController;
  late TextEditingController _currentLevelController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _targetDescController = TextEditingController();
    _currentDescController = TextEditingController();
    _targetLevelController = TextEditingController();
    _currentLevelController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetDescController.dispose();
    _currentDescController.dispose();
    _targetLevelController.dispose();
    _currentLevelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final factor = state.factors
            .where((f) => f.id == widget.factorId)
            .firstOrNull;

        if (factor == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Factor')),
            body: const Center(child: Text('Factor not found')),
          );
        }

        // Initialize controllers with current values
        if (!_isEditing) {
          _nameController.text = factor.name;
          _targetDescController.text = factor.targetDescription;
          _currentDescController.text = factor.currentDescription;
          _targetLevelController.text = factor.targetLevel.toString();
          _currentLevelController.text = factor.currentLevel.toString();
        }

        final effortUnits = state.getEffortUnitsForFactor(factor.id);
        final linkedTasks = state.getTasksForFactor(factor.id);
        final linkedHabits = state.getHabitsForFactor(factor.id);
        final linkedReflections = state.getReflectionsForFactor(factor.id);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(factor.name),
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                ),
                onPressed: () {
                  if (_isEditing) {
                    // Save changes
                    factor.name = _nameController.text.trim();
                    factor.targetDescription = _targetDescController.text;
                    factor.currentDescription = _currentDescController.text;
                    factor.targetLevel =
                        int.tryParse(_targetLevelController.text) ??
                        factor.targetLevel;
                    factor.currentLevel =
                        int.tryParse(_currentLevelController.text) ??
                        factor.currentLevel;
                    // Clamp levels
                    factor.targetLevel = factor.targetLevel.clamp(1, 10);
                    factor.currentLevel = factor.currentLevel.clamp(1, 10);
                    factor.lastUpdated = DateTime.now();
                    state.updateFactor(factor);
                  }
                  setState(() => _isEditing = !_isEditing);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tree Platform Visualization
                TreePlatform(
                  factor: factor,
                  effortUnits: effortUnits,
                  tasksCompleted: linkedTasks
                      .where((t) => t.isCompleted)
                      .length,
                  habitsLogged: linkedHabits
                      .where((h) => h.isLoggedToday)
                      .length,
                  reflections: linkedReflections.length,
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: 24),

                // Gap Analysis
                _SectionHeader(
                  title: _isEditing ? 'Edit Details' : 'Gap Analysis',
                  icon: _isEditing
                      ? Icons.edit_rounded
                      : Icons.analytics_rounded,
                  color: AppColors.info,
                ),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name field (editable or display)
                      if (_isEditing) ...[
                        Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: TextField(
                            controller: _nameController,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      // Level row
                      Row(
                        children: [
                          // Target
                          Expanded(
                            child: _isEditing
                                ? _EditableLevelBox(
                                    label: 'Target',
                                    controller: _targetLevelController,
                                    color: AppColors.primary,
                                  )
                                : _LevelDisplay(
                                    label: 'Target',
                                    level: factor.targetLevel,
                                    color: AppColors.primary,
                                  ),
                          ),
                          const SizedBox(width: 8),
                          // Current
                          Expanded(
                            child: _isEditing
                                ? _EditableLevelBox(
                                    label: 'Current',
                                    controller: _currentLevelController,
                                    color: AppColors.success,
                                  )
                                : _LevelDisplay(
                                    label: 'Current',
                                    level: factor.currentLevel,
                                    color: AppColors.success,
                                  ),
                          ),
                          if (!_isEditing) ...[
                            Container(
                              width: 1,
                              height: 50,
                              color: AppColors.glassBorder,
                            ),
                            // Gap (always read-only)
                            Expanded(
                              child: _LevelDisplay(
                                label: 'Gap',
                                level: factor.gap,
                                color: factor.needsFocus
                                    ? AppColors.danger
                                    : AppColors.warning,
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Show Gap separately when editing
                      if (_isEditing) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (factor.needsFocus
                                          ? AppColors.danger
                                          : AppColors.warning)
                                      .withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Gap: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Text(
                                  '${factor.gap}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: factor.needsFocus
                                        ? AppColors.danger
                                        : AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Focus Status (Activate/Deactivate)
                _SectionHeader(
                  title: 'Focus Status',
                  icon: Icons.local_fire_department_rounded,
                  color: factor.isActiveFocus
                      ? AppColors.success
                      : AppColors.textMuted,
                ),
                GlassCard(
                  highlighted: factor.isActiveFocus,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            factor.treeEmoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  factor.isActiveFocus
                                      ? '⭐ Active Focus'
                                      : '💤 Dissected',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  factor.isActiveFocus
                                      ? 'Health: ${factor.healthPercent.toInt()}%'
                                      : 'Frozen - no decay penalty',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (factor.isActiveFocus)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              state.setFactorDormant(factor.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${factor.name} is now dormant 💤',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.pause_rounded),
                            label: const Text('Set Dormant'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textMuted,
                              side: BorderSide(color: AppColors.glassBorder),
                            ),
                          ),
                        )
                      else if (state.canAddActiveFocus)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              state.setFactorActive(factor.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${factor.name} is now active! 🔥',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.local_fire_department_rounded,
                            ),
                            label: const Text('Activate Focus'),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_rounded,
                                color: AppColors.warning,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Max 2 active focus areas. Deactivate one to activate this.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Level Criteria',
                  icon: Icons.description_rounded,
                  color: AppColors.warning,
                ),

                // Target Description
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.flag_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Level ${factor.targetLevel} looks like...',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _isEditing
                          ? TextField(
                              controller: _targetDescController,
                              maxLines: 3,
                              style: TextStyle(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Describe mastery level...',
                              ),
                            )
                          : Text(
                              factor.targetDescription.isEmpty
                                  ? 'Tap edit to define your target...'
                                  : factor.targetDescription,
                              style: TextStyle(
                                color: factor.targetDescription.isEmpty
                                    ? AppColors.textMuted
                                    : AppColors.textSecondary,
                              ),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Current Description
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            color: AppColors.success,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Why Level ${factor.currentLevel}?',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _isEditing
                          ? TextField(
                              controller: _currentDescController,
                              maxLines: 3,
                              style: TextStyle(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Explain your current state...',
                              ),
                            )
                          : Text(
                              factor.currentDescription.isEmpty
                                  ? 'Tap edit to explain your current level...'
                                  : factor.currentDescription,
                              style: TextStyle(
                                color: factor.currentDescription.isEmpty
                                    ? AppColors.textMuted
                                    : AppColors.textSecondary,
                              ),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // History Timeline
                _SectionHeader(
                  title: 'Work History',
                  icon: Icons.history_rounded,
                  color: AppColors.success,
                ),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _StatChip(
                        label: 'Tasks',
                        count: linkedTasks.length,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatChip(
                        label: 'Habits',
                        count: linkedHabits.length,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatChip(
                        label: 'Reflects',
                        count: linkedReflections.length,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Tasks List
                if (linkedTasks.isNotEmpty) ...[
                  _SubsectionLabel(label: 'Linked Tasks'),
                  ...linkedTasks
                      .take(5)
                      .map(
                        (task) => _HistoryItem(
                          icon: task.isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: task.isCompleted
                              ? AppColors.success
                              : AppColors.textMuted,
                          title: task.title,
                          subtitle: task.isCompleted
                              ? 'Completed'
                              : 'In progress',
                        ),
                      ),
                  if (linkedTasks.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(left: 40, top: 8),
                      child: Text(
                        '+${linkedTasks.length - 5} more tasks',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                ],

                // Habits List
                if (linkedHabits.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SubsectionLabel(label: 'Linked Habits'),
                  ...linkedHabits.map(
                    (habit) => _HistoryItem(
                      icon: Icons.repeat_rounded,
                      color: AppColors.success,
                      title: habit.name,
                      subtitle:
                          '${habit.currentStreak} day streak • ${habit.completionCount} total',
                    ),
                  ),
                ],

                // Reflections List
                if (linkedReflections.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SubsectionLabel(label: 'Linked Reflections'),
                  ...linkedReflections
                      .take(3)
                      .map(
                        (ref) => _HistoryItem(
                          icon: Icons.psychology_rounded,
                          color: AppColors.info,
                          title: ref.experience.isNotEmpty
                              ? ref.experience
                              : 'Untitled reflection',
                          subtitle: '${ref.experimentIds.length} experiments',
                        ),
                      ),
                ],

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Styled editable level box for edit mode
class _EditableLevelBox extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color color;

  const _EditableLevelBox({
    required this.label,
    required this.controller,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 50,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 2),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelDisplay extends StatelessWidget {
  final String label;
  final int level;
  final Color color;

  const _LevelDisplay({
    required this.label,
    required this.level,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$level',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SubsectionLabel extends StatelessWidget {
  final String label;
  const _SubsectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _HistoryItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
