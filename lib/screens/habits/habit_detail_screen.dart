import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/habit.dart';
import '../../providers/app_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/habit_calendar.dart';

/// Habit Detail Screen with Stats, Edit, and Delete
class HabitDetailScreen extends StatefulWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _motivationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _motivationController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final habit = state.habits.where((h) => h.id == widget.habitId).firstOrNull;
        
        if (habit == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Habit')),
            body: const Center(child: Text('Habit not found')),
          );
        }

        if (!_isEditing) {
          _nameController.text = habit.name;
          _motivationController.text = habit.motivation;
        }

        // Calculate stats
        final totalLogs = habit.logs.length;
        final completedLogs = habit.logs.where((l) => l.completed).length;
        final completionRate = totalLogs > 0 ? (completedLogs / totalLogs * 100).toInt() : 0;
        final linkedFactor = habit.factorId != null 
            ? state.factors.where((f) => f.id == habit.factorId).firstOrNull 
            : null;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              habit.type == HabitType.quit ? 'Quit Habit' : 
              habit.type == HabitType.build ? 'Build Habit' : 'Timed Habit',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (!_isEditing)
                IconButton(
                  icon: Icon(Icons.edit_rounded, color: AppColors.textPrimary),
                  onPressed: () => setState(() => _isEditing = true),
                )
              else
                IconButton(
                  icon: Icon(Icons.check_rounded, color: AppColors.success),
                  onPressed: () => _saveChanges(state, habit),
                ),
              IconButton(
                icon: Icon(Icons.delete_rounded, color: AppColors.danger),
                onPressed: () => _confirmDelete(context, state, habit),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Habit Header
                _isEditing
                    ? TextField(
                        controller: _nameController,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Habit name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    : Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getTypeColor(habit.type).withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getTypeIcon(habit.type),
                              color: _getTypeColor(habit.type),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit.type == HabitType.quit ? 'No ${habit.name}' : habit.name,
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(habit.type).withAlpha(30),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    habit.type.name.toUpperCase(),
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _getTypeColor(habit.type)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms),
                
                const SizedBox(height: 24),
                
                // Streak Display
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.warning.withAlpha(30), AppColors.danger.withAlpha(20)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.warning.withAlpha(50)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StreakStat(label: 'Current', value: habit.currentStreak, icon: '🔥'),
                      Container(width: 1, height: 40, color: AppColors.glassBorder),
                      _StreakStat(label: 'Best', value: habit.bestStreak, icon: '🏆'),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 20),
                
                // Stats Grid
                Row(
                  children: [
                    Expanded(child: _StatCard(
                      icon: Icons.check_circle_rounded,
                      label: 'Completed',
                      value: '$completedLogs',
                      color: AppColors.success,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(
                      icon: Icons.pie_chart_rounded,
                      label: 'Rate',
                      value: '$completionRate%',
                      color: AppColors.info,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(
                      icon: Icons.calendar_today_rounded,
                      label: 'Total',
                      value: '$totalLogs',
                      color: AppColors.primary,
                    )),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Linked Factor
                if (linkedFactor != null) ...[
                  Text('Linked Tree', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      children: [
                        Text(linkedFactor.treeEmoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(linkedFactor.name, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              Text('Level ${linkedFactor.currentLevel}', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Motivation
                Text('Motivation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                const SizedBox(height: 8),
                _isEditing
                    ? TextField(
                        controller: _motivationController,
                        maxLines: 3,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Why is this habit important?',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Text(
                          habit.motivation.isEmpty ? 'No motivation set' : habit.motivation,
                          style: TextStyle(
                            color: habit.motivation.isEmpty ? AppColors.textMuted : AppColors.textSecondary,
                            fontStyle: habit.motivation.isEmpty ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                      ),
                
                const SizedBox(height: 24),
                
                // Calendar
                Text('History', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                const SizedBox(height: 12),
                HabitCalendar(habit: habit),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getTypeColor(HabitType type) {
    switch (type) {
      case HabitType.quit: return AppColors.danger;
      case HabitType.build: return AppColors.success;
      case HabitType.timed: return AppColors.info;
    }
  }

  IconData _getTypeIcon(HabitType type) {
    switch (type) {
      case HabitType.quit: return Icons.block_rounded;
      case HabitType.build: return Icons.add_circle_rounded;
      case HabitType.timed: return Icons.timer_rounded;
    }
  }

  void _saveChanges(AppState state, Habit habit) {
    habit.name = _nameController.text;
    habit.motivation = _motivationController.text;
    state.updateHabit(habit);
    setState(() => _isEditing = false);
  }

  void _confirmDelete(BuildContext context, AppState state, Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Habit?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'This will permanently delete "${habit.name}" and all its history.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              state.deleteHabit(habit.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StreakStat extends StatelessWidget {
  final String label;
  final int value;
  final String icon;

  const _StreakStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text('$value', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.warning)),
        Text('$label streak', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
