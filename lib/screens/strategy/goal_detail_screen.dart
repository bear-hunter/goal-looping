import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/goal.dart';
import '../../models/growth_area.dart';
import '../../providers/app_state.dart';
import '../../widgets/forest_platform.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/section_header.dart';

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
    final colors = context.colors;
    return Consumer<AppState>(
      builder: (context, state, _) {
        final goal = state.goals
            .where((g) => g.id == widget.goalId)
            .firstOrNull;

        if (goal == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Goal')),
            body: EmptyState(
              icon: Icons.flag_outlined,
              title: 'Goal not found',
              subtitle: 'This goal may have been removed.',
              actionLabel: 'Back to Plan',
              onAction: () => Navigator.pop(context),
            ),
          );
        }

        final factors = state.getFactorsForGoal(goal.id);
        final activeFactors = factors.where((f) => f.isActiveFocus).toList();

        final totalEffort = factors.fold<int>(
          0,
          (sum, f) => sum + state.getEffortUnitsForFactor(f.id),
        );
        final completedTasks = state.completedTasks.length;
        final goalProgress = state.getGoalProgress(goal.id);
        final needsAttention = activeFactors
            .where(
              (f) =>
                  f.daysSinceWork > 3 ||
                  f.healthStatus == 'wilting' ||
                  f.healthStatus == 'dead',
            )
            .toList();

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              goal.title,
              style: TextStyle(color: colors.textPrimary),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.edit_rounded, color: colors.textPrimary),
                onPressed: () => _showEditGoalDialog(context, state, goal),
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 300,
                pinned: false,
                backgroundColor: colors.background,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: factors.isEmpty
                        ? EmptyState(
                            icon: Icons.eco_rounded,
                            title: 'No trees yet',
                            subtitle:
                                'Plant your first dissected tree from the Plan page.',
                            accent: EmptyStateAccent.success,
                            animate: false,
                          )
                        : ForestPlatform(
                            factors: factors,
                            platformWidth:
                                MediaQuery.of(context).size.width - 40,
                            platformHeight: 230,
                            onTreeTap: (factor) => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FactorDetailScreen(factorId: factor.id),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _GoalPulseStrip(goal: goal, progress: goalProgress),
                    const SizedBox(height: 16),
                    _ForestHealthCard(
                      activeFactors: activeFactors,
                      totalFactors: factors.length,
                    ),
                    if (needsAttention.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _NeedsAttentionCard(
                        factor: needsAttention.first,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FactorDetailScreen(
                              factorId: needsAttention.first.id,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SectionHeader(
                      title: 'This goal at a glance',
                      uppercase: false,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.bolt_rounded,
                            label: 'Effort',
                            value: '$totalEffort',
                            subValue: 'units',
                            color: colors.warning,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.task_alt_rounded,
                            label: 'Tasks',
                            value: '$completedTasks',
                            subValue: 'completed',
                            color: colors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.local_fire_department_rounded,
                            label: 'Active',
                            value: '${activeFactors.length}/2',
                            subValue: 'focus trees',
                            color: colors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.park_rounded,
                            label: 'Dissected',
                            value: '${factors.length}',
                            subValue: factors.length == 1 ? 'tree' : 'trees',
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditGoalDialog(BuildContext context, AppState state, Goal goal) {
    final colors = context.colors;
    final titleController = TextEditingController(text: goal.title);
    int selectedMonths =
        goal.targetDate.difference(goal.createdAt).inDays ~/ 30;
    if (selectedMonths < 9) selectedMonths = 9;
    if (selectedMonths > 36) selectedMonths = 36;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Goal', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: TextStyle(color: colors.textPrimary),
                decoration: const InputDecoration(hintText: 'Goal title'),
              ),
              const SizedBox(height: 16),
              Text('Timeline', style: TextStyle(color: colors.textMuted)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [9, 12, 18, 24, 36].map((months) {
                  final isSelected = selectedMonths == months;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedMonths = months),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary
                            : colors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.glassBorder,
                        ),
                      ),
                      child: Text(
                        months < 12
                            ? '$months mo'
                            : '${months ~/ 12}${months % 12 > 0 ? '.5' : ''} yr',
                        style: TextStyle(
                          color: isSelected ? Colors.white : colors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
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
                          goal.targetDate = goal.createdAt.add(
                            Duration(days: selectedMonths * 30),
                          );
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

class _GoalPulseStrip extends StatelessWidget {
  final Goal goal;
  final double progress;

  const _GoalPulseStrip({required this.goal, required this.progress});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final value = progress.clamp(0.0, 1.0);
    final danger = goal.isOverdue || goal.daysRemaining <= 14;
    final tint = danger
        ? colors.danger
        : goal.daysRemaining <= 30
        ? colors.warning
        : colors.primary;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 18, color: tint),
              const SizedBox(width: 8),
              Text(
                goal.isOverdue
                    ? 'Overdue by ${-goal.daysRemaining} days'
                    : '${goal.daysRemaining} days left',
                style: TextStyle(fontWeight: FontWeight.w700, color: tint),
              ),
              const Spacer(),
              Text(
                '${(value * 100).round()}% to goal',
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: colors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(tint),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForestHealthCard extends StatelessWidget {
  final List<Factor> activeFactors;
  final int totalFactors;

  const _ForestHealthCard({
    required this.activeFactors,
    required this.totalFactors,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final avg = activeFactors.isEmpty
        ? null
        : activeFactors.fold<double>(
                0,
                (s, f) => s + f.effectiveHealthPercent,
              ) /
              activeFactors.length;
    final label = avg == null
        ? 'Resting'
        : avg >= 75
        ? 'Thriving'
        : avg >= 50
        ? 'Steady'
        : avg >= 25
        ? 'Wilting'
        : 'Untended';
    final tint = avg == null
        ? colors.textMuted
        : avg >= 75
        ? colors.success
        : avg >= 50
        ? colors.info
        : avg >= 25
        ? colors.warning
        : colors.danger;
    return GlassCard(
      child: Row(
        children: [
          Icon(Icons.eco_rounded, color: tint, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forest health',
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: tint,
                  ),
                ),
                Text(
                  '${activeFactors.length} active · $totalFactors total',
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NeedsAttentionCard extends StatelessWidget {
  final Factor factor;
  final VoidCallback onTap;

  const _NeedsAttentionCard({required this.factor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: colors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${factor.name} needs attention · ${factor.daysSinceWork}d untended',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.textMuted),
        ],
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
    final colors = context.colors;
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
              Text(
                label,
                style: TextStyle(fontSize: 12, color: colors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subValue,
            style: TextStyle(fontSize: 11, color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}
