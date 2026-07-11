import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/progress_ring.dart';

/// Module 4: Weekly Audit Screen - Gap Analysis
class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Weekly Audit',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          return CustomScrollView(
            slivers: [
              // Header subtitle
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text(
                    'Review your gaps and focus areas',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),

              // Focus Suggestion
              if (state.biggestGapFactor != null)
                SliverToBoxAdapter(
                  child: GlassCard(
                    highlighted: true,
                    margin: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_rounded,
                              color: colors.warning,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Focus Suggestion',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: colors.warning),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your biggest gap is in "${state.biggestGapFactor!.name}" (${state.biggestGapFactor!.gap} points). '
                          'This should be the subject of your next Kolb\'s Cycle.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),

              // Factors with Gaps
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(color: colors.divider, thickness: 1),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.analytics_rounded,
                            color: colors.info,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Gap Analysis',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (state.factors.isEmpty)
                SliverToBoxAdapter(
                  child: GlassCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.psychology_rounded,
                              size: 48,
                              color: colors.textMuted.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Add factors in Strategy to see gap analysis',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: colors.textMuted),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final factor = state.factors[index];
                    return GlassCard(
                      onTap: () => _showEditDialog(context, factor, state),
                      child: Row(
                        children: [
                          GapIndicator(
                            targetLevel: factor.targetLevel,
                            currentLevel: factor.currentLevel,
                            size: 56,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  factor.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _LevelChip(
                                      label: 'Target',
                                      value: factor.targetLevel,
                                      color: colors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    _LevelChip(
                                      label: 'Current',
                                      value: factor.currentLevel,
                                      color: colors.success,
                                    ),
                                    const SizedBox(width: 8),
                                    _LevelChip(
                                      label: 'Gap',
                                      value: factor.gap,
                                      color: factor.needsFocus
                                          ? colors.danger
                                          : colors.warning,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.edit_rounded,
                            color: colors.textMuted,
                            size: 20,
                          ),
                        ],
                      ),
                    );
                  }, childCount: state.factors.length),
                ),

              // Completed Tasks Summary
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: colors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'This Week',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '${state.completedTasks.length}',
                          label: 'Tasks Done',
                          color: colors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          value:
                              '${state.habits.where((h) => h.currentStreak > 0).length}',
                          label: 'Active Streaks',
                          color: colors.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          value: '${state.reflections.length}',
                          label: 'Reflections',
                          color: colors.info,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, factor, AppState state) {
    int target = factor.targetLevel;
    int current = factor.currentLevel;
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(factor.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              Text(
                'Target Level: $target',
                style: TextStyle(color: colors.textMuted),
              ),
              Slider(
                value: target.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (v) => setModalState(() => target = v.round()),
              ),
              Text(
                'Current Level: $current',
                style: TextStyle(color: colors.textMuted),
              ),
              Slider(
                value: current.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (v) => setModalState(() => current = v.round()),
              ),
              const SizedBox(height: 16),
              Center(
                child: GapIndicator(
                  targetLevel: target,
                  currentLevel: current,
                  size: 80,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  factor.targetLevel = target;
                  factor.currentLevel = current;
                  factor.lastUpdated = DateTime.now();
                  state.updateFactor(factor);
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _LevelChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontSize: 11, color: color),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: context.colors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
