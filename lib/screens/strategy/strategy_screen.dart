import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/goal.dart';
import '../../models/growth_area.dart';
import '../../models/sprint_target.dart';
import '../../models/time_availability.dart';
import '../../providers/app_state.dart';
import '../../services/storage_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/factor_chip.dart';
import '../../widgets/factor_health_tree.dart';
import 'factor_detail_screen.dart';

/// Module 1: Strategy & Setup Screen
class StrategyScreen extends StatelessWidget {
  const StrategyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildHeader(context),
              _buildGoalSection(context, state),
              if (state.activeGoal != null) _buildFactorsSection(context, state),
              _buildTimeSection(context, state),
              _buildSprintSection(context, state),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Strategy', style: Theme.of(context).textTheme.displayMedium)
                .animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 8),
            Text('Anchor your goal and plan your direction',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSection(BuildContext context, AppState state) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          _SectionHeader(title: 'Goal Anchor', icon: Icons.flag_rounded, color: AppColors.primary),
          if (state.activeGoal == null)
            GlassCard(
              onTap: () => _showAddGoalDialog(context),
              child: Row(
                children: [
                  Icon(Icons.add_circle_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text('Set Your Medium-Term Goal', style: TextStyle(color: AppColors.textPrimary)),
                ],
              ),
            )
          else
            GlassCard(
              highlighted: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(state.activeGoal!.title, 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('${state.activeGoal!.daysRemaining} days remaining',
                      style: TextStyle(color: AppColors.primary)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFactorsSection(BuildContext context, AppState state) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Focus Factors (max 2)
          _SectionHeader(
            title: 'Active Focus (${state.activeFocusFactors.length}/2)',
            icon: Icons.local_fire_department_rounded,
            color: AppColors.success,
            onAdd: state.canAddActiveFocus && state.dormantFactors.isNotEmpty 
                ? () => _showSelectFactorToActivate(context, state)
                : null,
          ),
          
          if (state.activeFocusFactors.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassCard(
                child: Column(
                  children: [
                    Text('🎯 Select up to 2 Trees to focus on', 
                        style: TextStyle(color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    Text('Only active Trees grow or decay',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: state.activeFocusFactors.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Stack(
                    children: [
                      FactorHealthTree(
                        factor: f,
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => FactorDetailScreen(factorId: f.id),
                        )),
                      ),
                      // Deactivate button in top-right corner
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            state.setFactorDormant(f.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${f.name} moved to Dissected Trees 💤')),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.textMuted.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.pause_rounded, size: 14, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text('Pause', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          
          // Dissected Trees - ALWAYS show section header
          _SectionHeader(
            title: '🌳 Dissected Trees',
            icon: Icons.nightlight_round,
            color: AppColors.textMuted,
            onAdd: state.activeGoal != null 
                ? () => _showAddFactorDialog(context, state.activeGoal!.id)
                : null,
          ),
          
          if (state.factors.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassCard(
                onTap: state.activeGoal != null 
                    ? () => _showAddFactorDialog(context, state.activeGoal!.id)
                    : null,
                child: Row(
                  children: [
                    Icon(Icons.add_circle_rounded, color: AppColors.textMuted),
                    const SizedBox(width: 12),
                    Text('Add Trees from Goal Dissection', 
                        style: TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
            )
          else if (state.dormantFactors.isEmpty)
            // All factors are active - show empty state
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight.withAlpha(100),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'All trees are in Active Focus! Tap "Pause" above to move one here.',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.dormantFactors.map((f) => GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => FactorDetailScreen(factorId: f.id),
                  )),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(f.treeEmoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(f.name, style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _showSelectFactorToActivate(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Tree to Activate', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('You can focus on up to 2 Factors at a time', 
                style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 16),
            ...state.dormantFactors.map((f) => ListTile(
              leading: Text(f.treeEmoji, style: const TextStyle(fontSize: 24)),
              title: Text(f.name),
              subtitle: Text(f.typeName),
              trailing: Icon(Icons.add_circle_rounded, color: AppColors.primary),
              onTap: () {
                state.setFactorActive(f.id);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection(BuildContext context, AppState state) {
    final availability = state.timeAvailability ?? TimeAvailability.some;
    final hoursPerWeek = availability.hoursPerWeekMin;
    final tasksCompleted = state.completedTasks.length;
    final habitsLogged = state.habits.where((h) => h.isLoggedToday).length;
    
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Time Defense', icon: Icons.schedule_rounded, color: AppColors.warning),
          
          // Weekly Budget Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.warning.withAlpha(30), AppColors.primary.withAlpha(20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.warning.withAlpha(50)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withAlpha(40),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.timer_rounded, color: AppColors.warning, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Weekly Budget', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            Text(
                              hoursPerWeek == 0 ? 'No time set' : '$hoursPerWeek+ hours/week',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.warning),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('This week', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          Text('$tasksCompleted tasks', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          Text('$habitsLogged habits', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    availability.description,
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  if (hoursPerWeek > 0) ...[
                    const SizedBox(height: 12),
                    _TimeRecommendation(hoursPerWeek: hoursPerWeek),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Time availability options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Set your availability:', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ),
          const SizedBox(height: 8),
          ...TimeAvailability.values.map((a) => GestureDetector(
            onTap: () => state.setTimeAvailability(a),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: state.timeAvailability == a ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: state.timeAvailability == a ? AppColors.primary : AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  Icon(state.timeAvailability == a ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: state.timeAvailability == a ? AppColors.primary : AppColors.textMuted, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(a.label, style: TextStyle(color: AppColors.textPrimary))),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSprintSection(BuildContext context, AppState state) {
    final thirtyDayGoals = state.sprintTargets.where((t) => t.duration == SprintDuration.thirtyDays).toList();
    final fourteenDayGoals = state.sprintTargets.where((t) => t.duration == SprintDuration.fourteenDays).toList();
    
    return SliverToBoxAdapter(
      child: Column(
        children: [
          // 30-Day Performance Goals
          _SectionHeader(
            title: '30-Day Performance Goals',
            icon: Icons.calendar_month_rounded,
            color: AppColors.info,
            onAdd: () => _showAddSprintDialog(context, state, SprintDuration.thirtyDays),
          ),
          if (thirtyDayGoals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('No 30-day goals set', style: TextStyle(color: AppColors.textMuted)),
            )
          else
            ...thirtyDayGoals.map((t) => _SprintGoalCard(target: t, factors: state.factors)),
          
          const SizedBox(height: 8),
          
          // 14-Day Performance Goals
          _SectionHeader(
            title: '14-Day Performance Goals',
            icon: Icons.bolt_rounded,
            color: AppColors.warning,
            onAdd: () => _showAddSprintDialog(context, state, SprintDuration.fourteenDays),
          ),
          if (fourteenDayGoals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('No 14-day goals set', style: TextStyle(color: AppColors.textMuted)),
            )
          else
            ...fourteenDayGoals.map((t) => _SprintGoalCard(target: t, factors: state.factors)),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: controller, decoration: const InputDecoration(hintText: 'Your goal')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<AppState>().addGoal(Goal(
                    id: StorageService.generateId(),
                    title: controller.text,
                    targetDate: DateTime.now().add(const Duration(days: 270)),
                  ));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFactorDialog(BuildContext context, String goalId) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: controller, decoration: const InputDecoration(hintText: 'Factor name')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<AppState>().addFactor(Factor(
                    id: StorageService.generateId(),
                    name: controller.text,
                    type: FactorType.skill,
                    goalId: goalId,
                  ));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSprintDialog(BuildContext context, AppState state, SprintDuration duration) {
    final controller = TextEditingController();
    List<String> selectedFactorIds = [];
    
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
              Text(
                duration == SprintDuration.thirtyDays ? 'New 30-Day Goal' : 'New 14-Day Goal',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(controller: controller, decoration: const InputDecoration(hintText: 'Performance goal')),
              const SizedBox(height: 12),
              Text('Link to Factors', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.factors.map((f) {
                  final isSelected = selectedFactorIds.contains(f.id);
                  return GestureDetector(
                    onTap: () => setDialogState(() {
                      if (isSelected) {
                        selectedFactorIds.remove(f.id);
                      } else {
                        selectedFactorIds.add(f.id);
                      }
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withAlpha(30) : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.glassBorder),
                      ),
                      child: Text(f.name, style: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    context.read<AppState>().addSprintTarget(SprintTarget(
                      id: StorageService.generateId(),
                      title: controller.text,
                      duration: duration,
                      linkedFactorIds: selectedFactorIds,
                    ));
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Add Goal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onAdd;

  const _SectionHeader({required this.title, required this.icon, required this.color, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
          if (onAdd != null) IconButton(onPressed: onAdd, icon: Icon(Icons.add_rounded, color: color)),
        ],
      ),
    );
  }
}

class _SprintGoalCard extends StatelessWidget {
  final SprintTarget target;
  final List<Factor> factors;

  const _SprintGoalCard({required this.target, required this.factors});

  @override
  Widget build(BuildContext context) {
    final linkedFactors = factors.where((f) => target.linkedFactorIds.contains(f.id)).toList();
    final isOverdue = target.isOverdue;
    final daysLeft = target.daysRemaining;
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                target.duration == SprintDuration.thirtyDays ? Icons.calendar_month_rounded : Icons.bolt_rounded,
                color: isOverdue ? AppColors.danger : (target.duration == SprintDuration.thirtyDays ? AppColors.info : AppColors.warning),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(target.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverdue ? AppColors.danger.withAlpha(30) : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOverdue ? 'Overdue' : '${daysLeft}d left',
                  style: TextStyle(fontSize: 12, color: isOverdue ? AppColors.danger : AppColors.textMuted),
                ),
              ),
            ],
          ),
          if (linkedFactors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: linkedFactors.map((f) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(f.name, style: TextStyle(fontSize: 11, color: AppColors.primary)),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Time-based recommendations widget
class _TimeRecommendation extends StatelessWidget {
  final int hoursPerWeek;
  
  const _TimeRecommendation({required this.hoursPerWeek});
  
  @override
  Widget build(BuildContext context) {
    final (icon, text, color) = _getRecommendation();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }
  
  (IconData, String, Color) _getRecommendation() {
    if (hoursPerWeek <= 2) {
      return (
        Icons.flash_on_rounded,
        '💡 Focus only on Top 2 tasks. Skip reflections when busy.',
        AppColors.warning,
      );
    } else if (hoursPerWeek <= 5) {
      return (
        Icons.balance_rounded,
        '⚖️ Balance 2 priority tasks + 2-3 habits daily. One reflection weekly.',
        AppColors.info,
      );
    } else if (hoursPerWeek <= 10) {
      return (
        Icons.trending_up_rounded,
        '📈 Good capacity! Add experiments and more habits to accelerate growth.',
        AppColors.success,
      );
    } else {
      return (
        Icons.rocket_launch_rounded,
        '🚀 Full capacity mode! Maximize all modules for rapid progress.',
        AppColors.primary,
      );
    }
  }
}
