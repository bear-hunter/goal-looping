import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/growth_area.dart';
import '../../providers/app_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/progress_ring.dart';

/// Phase 2: Factor Detail Screen - "Work Volume" Dashboard
/// Shows all effort linked to a specific Factor
class FactorDetailScreen extends StatefulWidget {
  final String factorId;

  const FactorDetailScreen({super.key, required this.factorId});

  @override
  State<FactorDetailScreen> createState() => _FactorDetailScreenState();
}

class _FactorDetailScreenState extends State<FactorDetailScreen> {
  late TextEditingController _targetDescController;
  late TextEditingController _currentDescController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _targetDescController = TextEditingController();
    _currentDescController = TextEditingController();
  }

  @override
  void dispose() {
    _targetDescController.dispose();
    _currentDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final factor = state.factors.where((f) => f.id == widget.factorId).firstOrNull;
        
        if (factor == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Factor')),
            body: const Center(child: Text('Factor not found')),
          );
        }

        // Initialize controllers with current values
        if (!_isEditing) {
          _targetDescController.text = factor.targetDescription;
          _currentDescController.text = factor.currentDescription;
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
                icon: Icon(_isEditing ? Icons.check_rounded : Icons.edit_rounded),
                onPressed: () {
                  if (_isEditing) {
                    // Save changes
                    factor.targetDescription = _targetDescController.text;
                    factor.currentDescription = _currentDescController.text;
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
                // Effort Ring (Work Volume)
                Center(
                  child: Column(
                    children: [
                      _EffortRing(effortUnits: effortUnits),
                      const SizedBox(height: 12),
                      Text(
                        'Total Effort Units',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      Text(
                        'Tasks + Habits + Reflections',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),

                const SizedBox(height: 32),

                // Gap Analysis
                _SectionHeader(title: 'Gap Analysis', icon: Icons.analytics_rounded, color: AppColors.info),
                GlassCard(
                  child: Row(
                    children: [
                      Expanded(child: _LevelDisplay(label: 'Target', level: factor.targetLevel, color: AppColors.primary)),
                      Container(width: 1, height: 50, color: AppColors.glassBorder),
                      Expanded(child: _LevelDisplay(label: 'Current', level: factor.currentLevel, color: AppColors.success)),
                      Container(width: 1, height: 50, color: AppColors.glassBorder),
                      Expanded(child: _LevelDisplay(label: 'Gap', level: factor.gap, color: factor.needsFocus ? AppColors.danger : AppColors.warning)),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Focus Status (Activate/Deactivate)
                _SectionHeader(title: 'Focus Status', icon: Icons.local_fire_department_rounded, color: factor.isActiveFocus ? AppColors.success : AppColors.textMuted),
                GlassCard(
                  highlighted: factor.isActiveFocus,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(factor.treeEmoji, style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  factor.isActiveFocus ? '⭐ Active Focus' : '💤 Dormant',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  factor.isActiveFocus 
                                      ? 'Health: ${factor.healthPercent.toInt()}%'
                                      : 'Frozen - no decay penalty',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
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
                                SnackBar(content: Text('${factor.name} is now dormant 💤')),
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
                                SnackBar(content: Text('${factor.name} is now active! 🔥'), backgroundColor: AppColors.success),
                              );
                            },
                            icon: const Icon(Icons.local_fire_department_rounded),
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
                              Icon(Icons.info_rounded, color: AppColors.warning, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Max 2 active focus areas. Deactivate one to activate this.',
                                  style: TextStyle(fontSize: 12, color: AppColors.warning),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _SectionHeader(title: 'Level Criteria', icon: Icons.description_rounded, color: AppColors.warning),
                
                // Target Description
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.flag_rounded, color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Text('Level 10 looks like...', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _isEditing
                          ? TextField(
                              controller: _targetDescController,
                              maxLines: 3,
                              style: TextStyle(color: AppColors.textPrimary),
                              decoration: InputDecoration(hintText: 'Describe mastery level...'),
                            )
                          : Text(
                              factor.targetDescription.isEmpty ? 'Tap edit to define your target...' : factor.targetDescription,
                              style: TextStyle(color: factor.targetDescription.isEmpty ? AppColors.textMuted : AppColors.textSecondary),
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
                          Icon(Icons.person_rounded, color: AppColors.success, size: 18),
                          const SizedBox(width: 8),
                          Text('Why Level ${factor.currentLevel}?', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.success)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _isEditing
                          ? TextField(
                              controller: _currentDescController,
                              maxLines: 3,
                              style: TextStyle(color: AppColors.textPrimary),
                              decoration: InputDecoration(hintText: 'Explain your current state...'),
                            )
                          : Text(
                              factor.currentDescription.isEmpty ? 'Tap edit to explain your current level...' : factor.currentDescription,
                              style: TextStyle(color: factor.currentDescription.isEmpty ? AppColors.textMuted : AppColors.textSecondary),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // History Timeline
                _SectionHeader(title: 'Work History', icon: Icons.history_rounded, color: AppColors.success),
                
                // Stats Row
                Row(
                  children: [
                    Expanded(child: _StatChip(label: 'Tasks', count: linkedTasks.length, color: AppColors.primary)),
                    const SizedBox(width: 8),
                    Expanded(child: _StatChip(label: 'Habits', count: linkedHabits.length, color: AppColors.success)),
                    const SizedBox(width: 8),
                    Expanded(child: _StatChip(label: 'Reflects', count: linkedReflections.length, color: AppColors.info)),
                  ],
                ),

                const SizedBox(height: 16),

                // Tasks List
                if (linkedTasks.isNotEmpty) ...[
                  _SubsectionLabel(label: 'Linked Tasks'),
                  ...linkedTasks.take(5).map((task) => _HistoryItem(
                    icon: task.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: task.isCompleted ? AppColors.success : AppColors.textMuted,
                    title: task.title,
                    subtitle: task.isCompleted ? 'Completed' : 'In progress',
                  )),
                  if (linkedTasks.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(left: 40, top: 8),
                      child: Text('+${linkedTasks.length - 5} more tasks', style: TextStyle(color: AppColors.textMuted)),
                    ),
                ],

                // Habits List
                if (linkedHabits.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SubsectionLabel(label: 'Linked Habits'),
                  ...linkedHabits.map((habit) => _HistoryItem(
                    icon: Icons.repeat_rounded,
                    color: AppColors.success,
                    title: habit.name,
                    subtitle: '${habit.currentStreak} day streak • ${habit.completionCount} total',
                  )),
                ],

                // Reflections List
                if (linkedReflections.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SubsectionLabel(label: 'Linked Reflections'),
                  ...linkedReflections.take(3).map((ref) => _HistoryItem(
                    icon: Icons.psychology_rounded,
                    color: AppColors.info,
                    title: ref.experience.isNotEmpty ? ref.experience : 'Untitled reflection',
                    subtitle: '${ref.experimentIds.length} experiments',
                  )),
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

class _EffortRing extends StatelessWidget {
  final int effortUnits;
  const _EffortRing({required this.effortUnits});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.primary.withAlpha(50), AppColors.success.withAlpha(50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.primary.withAlpha(100), width: 3),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$effortUnits', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary)),
            Text('units', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _LevelDisplay extends StatelessWidget {
  final String label;
  final int level;
  final Color color;

  const _LevelDisplay({required this.label, required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$level', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({required this.label, required this.count, required this.color});

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
          Text('$count', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
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
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1.2),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _HistoryItem({required this.icon, required this.color, required this.title, required this.subtitle});

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
                Text(title, style: TextStyle(color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
