import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/goal.dart';
import '../../models/growth_area.dart';
import '../../providers/app_state.dart';
import '../../widgets/forest_platform.dart';
import '../../widgets/glass_card.dart';
import 'factor_detail_screen.dart';

/// Goal Detail Screen with Forest View and Statistics
class GoalDetailScreen extends StatefulWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final goal = state.goals.where((g) => g.id == widget.goalId).firstOrNull;
        
        if (goal == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Goal')),
            body: const Center(child: Text('Goal not found')),
          );
        }

        final factors = state.getFactorsForGoal(goal.id);
        final activeFactors = factors.where((f) => f.isActiveFocus).toList();
        final dormantFactors = factors.where((f) => !f.isActiveFocus).toList();
        
        // Calculate statistics
        final totalEffort = factors.fold<int>(0, (sum, f) => sum + state.getEffortUnitsForFactor(f.id));
        final avgHealth = factors.isEmpty ? 0.0 : 
            factors.where((f) => f.isActiveFocus).fold<double>(0, (sum, f) => sum + f.healthPercent) / 
            (activeFactors.isEmpty ? 1 : activeFactors.length);
        final completedTasks = state.completedTasks.length;
        final habitsLogged = state.habits.where((h) => h.isLoggedToday).length;
        final reflectionCount = state.reflections.length;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(goal.title, style: TextStyle(color: AppColors.textPrimary)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.edit_rounded, color: AppColors.textPrimary),
                onPressed: () => _showEditGoalDialog(context, state, goal),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Days remaining badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: goal.isOverdue 
                        ? AppColors.danger.withAlpha(30)
                        : AppColors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: goal.isOverdue ? AppColors.danger : AppColors.primary,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        goal.isOverdue ? Icons.warning_rounded : Icons.flag_rounded,
                        size: 18,
                        color: goal.isOverdue ? AppColors.danger : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        goal.isOverdue 
                            ? 'Overdue by ${-goal.daysRemaining} days'
                            : '${goal.daysRemaining} days remaining',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: goal.isOverdue ? AppColors.danger : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
                
                const SizedBox(height: 32),
                
                // Forest Platform
                Text(
                  '🌳 Your Forest',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${factors.length} trees planted',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                
                if (factors.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Column(
                      children: [
                        Text('🌱', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'No trees yet!',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Add Dissected Trees in the Strategy page',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                else
                  ForestPlatform(
                    factors: factors,
                    platformWidth: MediaQuery.of(context).size.width - 40,
                    platformHeight: 180,
                    onTreeTap: (factor) => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FactorDetailScreen(factorId: factor.id)),
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(
                    begin: const Offset(0.9, 0.9),
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),
                
                const SizedBox(height: 32),
                
                // Statistics Dashboard
                Text(
                  '📊 Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Stats Grid
                Row(
                  children: [
                    Expanded(child: _StatCard(
                      icon: Icons.park_rounded,
                      label: 'Trees',
                      value: '${factors.length}',
                      subValue: '${activeFactors.length} active',
                      color: AppColors.success,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(
                      icon: Icons.bolt_rounded,
                      label: 'Effort',
                      value: '$totalEffort',
                      subValue: 'units',
                      color: AppColors.warning,
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _StatCard(
                      icon: Icons.favorite_rounded,
                      label: 'Health',
                      value: '${avgHealth.toInt()}%',
                      subValue: 'avg active',
                      color: AppColors.danger,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(
                      icon: Icons.task_alt_rounded,
                      label: 'Tasks',
                      value: '$completedTasks',
                      subValue: 'completed',
                      color: AppColors.info,
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _StatCard(
                      icon: Icons.repeat_rounded,
                      label: 'Habits',
                      value: '$habitsLogged',
                      subValue: 'today',
                      color: AppColors.primary,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(
                      icon: Icons.psychology_rounded,
                      label: 'Reflects',
                      value: '$reflectionCount',
                      subValue: 'total',
                      color: AppColors.textMuted,
                    )),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Tree breakdown
                if (factors.isNotEmpty) ...[
                  _SectionHeader(title: '🔥 Active Focus', count: activeFactors.length),
                  if (activeFactors.isEmpty)
                    _EmptyChip(text: 'No active trees')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: activeFactors.map((f) => _TreeChip(
                        factor: f,
                        onTap: () => Navigator.push(context, 
                          MaterialPageRoute(builder: (_) => FactorDetailScreen(factorId: f.id))),
                      )).toList(),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  _SectionHeader(title: '💤 Dissected', count: dormantFactors.length),
                  if (dormantFactors.isEmpty)
                    _EmptyChip(text: 'All trees are active!')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: dormantFactors.map((f) => _TreeChip(
                        factor: f,
                        onTap: () => Navigator.push(context, 
                          MaterialPageRoute(builder: (_) => FactorDetailScreen(factorId: f.id))),
                      )).toList(),
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

  void _showEditGoalDialog(BuildContext context, AppState state, Goal goal) {
    final titleController = TextEditingController(text: goal.title);
    int selectedMonths = goal.targetDate.difference(goal.createdAt).inDays ~/ 30;
    if (selectedMonths < 9) selectedMonths = 9;
    if (selectedMonths > 36) selectedMonths = 36;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Goal', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(hintText: 'Goal title'),
              ),
              const SizedBox(height: 16),
              Text('Timeline', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [9, 12, 18, 24, 36].map((months) {
                  final isSelected = selectedMonths == months;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedMonths = months),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.glassBorder,
                        ),
                      ),
                      child: Text(
                        months < 12 ? '$months mo' : '${months ~/ 12}${months % 12 > 0 ? '.5' : ''} yr',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          goal.title = titleController.text;
                          goal.targetDate = goal.createdAt.add(Duration(days: selectedMonths * 30));
                          state.updateGoal(goal);
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subValue;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(subValue, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }
}

class _TreeChip extends StatelessWidget {
  final Factor factor;
  final VoidCallback onTap;

  const _TreeChip({required this.factor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: factor.isActiveFocus ? AppColors.primary.withAlpha(20) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: factor.isActiveFocus ? AppColors.primary : AppColors.glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(factor.treeEmoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(factor.name, style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
            const SizedBox(width: 4),
            Text('Lv${factor.currentLevel}', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _EmptyChip extends StatelessWidget {
  final String text;
  const _EmptyChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
    );
  }
}
