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
import '../../widgets/section_header.dart';
import '../../widgets/xp_bar.dart';
import '../../widgets/empty_state.dart';

import '../../widgets/factor_health_tree.dart';
import 'factor_detail_screen.dart';
import 'goal_detail_screen.dart';

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
              _buildHeader(context, state),
              _buildGoalSection(context, state),
              if (state.activeGoal != null)
                _buildFactorsSection(context, state),
              _buildSprintSection(context, state),
              _buildTimeSection(context, state),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppState state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Strategy',
                        style: Theme.of(context).textTheme.displayMedium,
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Mission control for your goal',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    XPBar(stats: state.userStats, compact: true),
                    const SizedBox(height: 8),
                    StreakBadge(
                      streak: state.userStats.currentStreak,
                      isAtRisk: state.userStats.isStreakAtRisk,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSection(BuildContext context, AppState state) {
    final colors = context.colors;
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(
              title: 'Your Goal',
              uppercase: false,
              trailing: Icon(
                Icons.flag_rounded,
                color: colors.primary,
                size: 18,
              ),
            ),
          ),
          if (state.activeGoal == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassCard(
                onTap: () => _showAddGoalDialog(context),
                child: EmptyState(
                  icon: Icons.flag_rounded,
                  title: 'Set your goal',
                  subtitle:
                      'Choose the medium-term outcome your forest will grow toward.',
                  actionLabel: 'Set Goal',
                  onAction: () => _showAddGoalDialog(context),
                  animate: false,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassCard(
                highlighted: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        GoalDetailScreen(goalId: state.activeGoal!.id),
                  ),
                ),
                child: _GoalHeroContent(
                  goal: state.activeGoal!,
                  progress: state.getGoalProgress(state.activeGoal!.id),
                  treeCount: state
                      .getFactorsForGoal(state.activeGoal!.id)
                      .length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFactorsSection(BuildContext context, AppState state) {
    final colors = context.colors;
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Focus Factors (max 2)
          _SectionHeader(
            title: 'Active Focus (${state.activeFocusFactors.length}/2)',
            icon: Icons.local_fire_department_rounded,
            color: colors.success,
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
                    Text(
                      '🎯 Select up to 2 Trees to focus on',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: colors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Only active Trees grow or decay',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: state.activeFocusFactors
                    .map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Stack(
                          children: [
                            FactorHealthTree(
                              factor: f,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      FactorDetailScreen(factorId: f.id),
                                ),
                              ),
                            ),
                            // Deactivate button in top-right corner
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  state.setFactorDormant(f.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${f.name} moved to Dissected Trees 💤',
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.textMuted.withAlpha(30),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.pause_rounded,
                                        size: 14,
                                        color: colors.textMuted,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Pause',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: colors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

          // Dissected Trees - ALWAYS show section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(
              title: 'Dissected trees',
              uppercase: false,
              trailing: IconButton(
                icon: Icon(Icons.add_circle_rounded, color: colors.textMuted),
                onPressed: state.activeGoal != null
                    ? () => _showAddFactorDialog(context, state.activeGoal!.id)
                    : null,
              ),
            ),
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
                    Icon(Icons.add_circle_rounded, color: colors.textMuted),
                    const SizedBox(width: 12),
                    Text(
                      'Add Trees from Goal Dissection',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: colors.textMuted),
                    ),
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
                  color: colors.surfaceLight.withAlpha(100),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.glassBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: colors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'All trees are in Active Focus! Tap "Pause" above to move one here.',
                        style: TextStyle(fontSize: 13, color: colors.textMuted),
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
                children: state.dormantFactors
                    .map(
                      (f) => FactorTile(
                        factor: f,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FactorDetailScreen(factorId: f.id),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _showSelectFactorToActivate(BuildContext context, AppState state) {
    final colors = context.colors;
    final surfaceColor = colors.surface;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Tree to Activate',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'You can focus on up to 2 Factors at a time',
              style: TextStyle(color: colors.textMuted),
            ),
            const SizedBox(height: 16),
            ...state.dormantFactors.map(
              (f) => ListTile(
                leading: Text(
                  f.treeEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(f.name),
                subtitle: Text(f.typeName),
                trailing: Icon(Icons.add_circle_rounded, color: colors.primary),
                onTap: () {
                  state.setFactorActive(f.id);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection(BuildContext context, AppState state) {
    final colors = context.colors;
    final availability = state.timeAvailability ?? TimeAvailability.some;
    final hoursPerWeek = availability.hoursPerWeekMin;
    final tasksCompleted = state.completedTasks.length;
    final habitsLogged = state.habits.where((h) => h.isLoggedToday).length;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Time Defense',
            icon: Icons.schedule_rounded,
            color: colors.warning,
          ),

          // Weekly Budget Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.warning.withAlpha(20),
                    colors.primary.withAlpha(15),
                  ], // Subtler
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: colors.warning.withAlpha(30)),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.warning.withAlpha(40),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.timer_rounded,
                          color: colors.warning,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weekly Budget',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              hoursPerWeek == 0
                                  ? 'No time set'
                                  : '$hoursPerWeek+ hours/week',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'This week',
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.textMuted,
                            ),
                          ),
                          Text(
                            '$tasksCompleted tasks',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textSecondary,
                            ),
                          ),
                          Text(
                            '$habitsLogged habits',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    availability.description,
                    style: TextStyle(fontSize: 11, color: colors.textMuted),
                  ),
                  if (hoursPerWeek > 0) ...[
                    const SizedBox(height: 8),
                    _TimeRecommendation(hoursPerWeek: hoursPerWeek),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: () => _showTimeAvailabilitySheet(context, state),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: colors.glassBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tune_rounded, color: colors.warning, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Capacity setting',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: colors.textMuted),
                          ),
                          Text(
                            availability.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Change',
                      style: TextStyle(
                        color: colors.warning,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: colors.warning,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTimeAvailabilitySheet(BuildContext context, AppState state) {
    final colors = context.colors;
    final selected = state.timeAvailability ?? TimeAvailability.some;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.86,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_moon_rounded, color: colors.warning),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Choose your weekly capacity',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Pick the honest time budget. The app will scale recommendations around it.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
                ),
                const SizedBox(height: 16),
                ...TimeAvailability.values.map((a) {
                  final isSelected = a == selected;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      onTap: () {
                        state.setTimeAvailability(a);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.warning.withAlpha(24)
                              : colors.surfaceLight.withAlpha(120),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isSelected
                                ? colors.warning.withAlpha(90)
                                : colors.glassBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.warning.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                a.hoursPerWeekMin == 0
                                    ? '0'
                                    : '${a.hoursPerWeekMin}+',
                                style: TextStyle(
                                  color: colors.warning,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    a.description,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: colors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: colors.warning,
                              )
                            else
                              Icon(
                                Icons.circle_outlined,
                                color: colors.textMuted,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSprintSection(BuildContext context, AppState state) {
    final colors = context.colors;
    final thirtyDayGoals = state.sprintTargets
        .where((t) => t.duration == SprintDuration.thirtyDays)
        .toList();
    final fourteenDayGoals = state.sprintTargets
        .where((t) => t.duration == SprintDuration.fourteenDays)
        .toList();

    return SliverToBoxAdapter(
      child: Column(
        children: [
          // 30-Day Performance Goals
          _SectionHeader(
            title: '30-Day Performance Goals',
            icon: Icons.calendar_month_rounded,
            color: colors.info,
            onAdd: () =>
                _showAddSprintDialog(context, state, SprintDuration.thirtyDays),
          ),
          if (thirtyDayGoals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'No 30-day goals set',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colors.textMuted),
              ),
            )
          else
            ...thirtyDayGoals.map(
              (t) => _SprintGoalCard(
                target: t,
                factors: state.factors,
                onEdit: () => _showEditSprintDialog(context, state, t),
                onDelete: () =>
                    _showDeleteSprintConfirmation(context, state, t),
                onComplete: () => state.markSprintComplete(t.id),
                onFail: () => state.markSprintFailed(t.id),
                onReset: () => state.resetSprintTarget(t.id),
              ),
            ),

          const SizedBox(height: 8),

          // 14-Day Performance Goals
          _SectionHeader(
            title: '14-Day Performance Goals',
            icon: Icons.bolt_rounded,
            color: colors.warning,
            onAdd: () => _showAddSprintDialog(
              context,
              state,
              SprintDuration.fourteenDays,
            ),
          ),
          if (fourteenDayGoals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'No 14-day goals set',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colors.textMuted),
              ),
            )
          else
            ...fourteenDayGoals.map(
              (t) => _SprintGoalCard(
                target: t,
                factors: state.factors,
                onEdit: () => _showEditSprintDialog(context, state, t),
                onDelete: () =>
                    _showDeleteSprintConfirmation(context, state, t),
                onComplete: () => state.markSprintComplete(t.id),
                onFail: () => state.markSprintFailed(t.id),
                onReset: () => state.resetSprintTarget(t.id),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final controller = TextEditingController();
    final colors = context.colors;
    final surfaceColor = colors.surface;
    int selectedDays = 270; // Default: 9 months
    DateTime? customDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Your goal'),
              ),
              const SizedBox(height: 16),
              Text(
                'Timeline',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTimelineChip('3 months', 90, selectedDays, customDate, (
                    days,
                  ) {
                    setModalState(() {
                      selectedDays = days;
                      customDate = null;
                    });
                  }),
                  _buildTimelineChip(
                    '6 months',
                    180,
                    selectedDays,
                    customDate,
                    (days) {
                      setModalState(() {
                        selectedDays = days;
                        customDate = null;
                      });
                    },
                  ),
                  _buildTimelineChip(
                    '9 months',
                    270,
                    selectedDays,
                    customDate,
                    (days) {
                      setModalState(() {
                        selectedDays = days;
                        customDate = null;
                      });
                    },
                  ),
                  _buildTimelineChip('1 year', 365, selectedDays, customDate, (
                    days,
                  ) {
                    setModalState(() {
                      selectedDays = days;
                      customDate = null;
                    });
                  }),
                  ChoiceChip(
                    label: Text(
                      customDate != null
                          ? '${customDate!.day}/${customDate!.month}/${customDate!.year}'
                          : 'Custom',
                    ),
                    selected: customDate != null,
                    onSelected: (_) async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          Duration(days: selectedDays),
                        ),
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(
                          const Duration(days: 3650),
                        ),
                      );
                      if (picked != null) {
                        setModalState(() {
                          customDate = picked;
                          selectedDays = picked
                              .difference(DateTime.now())
                              .inDays;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    final targetDate =
                        customDate ??
                        DateTime.now().add(Duration(days: selectedDays));
                    context.read<AppState>().addGoal(
                      Goal(
                        id: StorageService.generateId(),
                        title: controller.text,
                        targetDate: targetDate,
                      ),
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineChip(
    String label,
    int days,
    int selectedDays,
    DateTime? customDate,
    ValueChanged<int> onSelected,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedDays == days && customDate == null,
      onSelected: (_) => onSelected(days),
    );
  }

  void _showAddFactorDialog(BuildContext context, String goalId) {
    final controller = TextEditingController();
    final colors = context.colors;
    final surfaceColor = colors.surface;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Factor name'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<AppState>().addFactor(
                    Factor(
                      id: StorageService.generateId(),
                      name: controller.text,
                      type: FactorType.skill,
                      goalId: goalId,
                    ),
                  );
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

  void _showAddSprintDialog(
    BuildContext context,
    AppState state,
    SprintDuration duration,
  ) {
    final controller = TextEditingController();
    List<String> selectedFactorIds = [];
    final colors = context.colors;
    final surfaceColor = colors.surface;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
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
              Text(
                duration == SprintDuration.thirtyDays
                    ? 'New 30-Day Goal'
                    : 'New 14-Day Goal',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Performance goal'),
              ),
              const SizedBox(height: 12),
              Text(
                'Link to Factors',
                style: TextStyle(fontSize: 13, color: colors.textMuted),
              ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary.withAlpha(30)
                            : colors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.glassBorder,
                        ),
                      ),
                      child: Text(
                        f.name,
                        style: TextStyle(
                          color: isSelected
                              ? colors.primary
                              : colors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    context.read<AppState>().addSprintTarget(
                      SprintTarget(
                        id: StorageService.generateId(),
                        title: controller.text,
                        duration: duration,
                        linkedFactorIds: selectedFactorIds,
                      ),
                    );
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

  void _showEditSprintDialog(
    BuildContext context,
    AppState state,
    SprintTarget target,
  ) {
    final controller = TextEditingController(text: target.title);
    List<String> selectedFactorIds = List.from(target.linkedFactorIds);
    final colors = context.colors;
    final surfaceColor = colors.surface;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
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
              Text(
                'Edit ${target.duration == SprintDuration.thirtyDays ? '30-Day' : '14-Day'} Goal',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Performance goal'),
              ),
              const SizedBox(height: 12),
              Text(
                'Link to Factors',
                style: TextStyle(fontSize: 13, color: colors.textMuted),
              ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary.withAlpha(30)
                            : colors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.glassBorder,
                        ),
                      ),
                      child: Text(
                        f.name,
                        style: TextStyle(
                          color: isSelected
                              ? colors.primary
                              : colors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    // Create updated target
                    final updatedTarget = SprintTarget(
                      id: target.id,
                      title: controller.text,
                      duration: target.duration,
                      linkedFactorIds: selectedFactorIds,
                      createdAt: target.createdAt,
                    );
                    state.updateSprintTarget(updatedTarget);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Goal updated!')),
                    );
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteSprintConfirmation(
    BuildContext context,
    AppState state,
    SprintTarget target,
  ) {
    final colors = context.colors;
    final surfaceColor = colors.surface;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceColor,
        title: const Text('Delete Goal?'),
        content: Text('Are you sure you want to delete "${target.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              state.deleteSprintTarget(target.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Goal deleted')));
            },
            style: TextButton.styleFrom(foregroundColor: colors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _GoalHeroContent extends StatelessWidget {
  final Goal goal;
  final double progress;
  final int treeCount;

  const _GoalHeroContent({
    required this.goal,
    required this.progress,
    required this.treeCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progressValue = progress.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.park_rounded, color: colors.primary, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                goal.title,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontSize: 24),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.textMuted),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _HeroMetric(
              icon: Icons.schedule_rounded,
              label: goal.isOverdue ? 'overdue' : 'days left',
              value: '${goal.daysRemaining.abs()}',
            ),
            const SizedBox(width: 12),
            _HeroMetric(
              icon: Icons.forest_rounded,
              label: treeCount == 1 ? 'tree' : 'trees',
              value: '$treeCount',
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: 9,
            backgroundColor: colors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(colors.primary),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progressValue * 100).round()}% to goal · view forest →',
          style: TextStyle(fontSize: 12, color: colors.textMuted),
        ),
      ],
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeroMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.surfaceLight.withAlpha(130),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: colors.primary),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 11, color: colors.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
  final VoidCallback? onAdd;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        AppSpacing.lg,
        20,
        AppSpacing.sm,
      ), // More top padding
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700, // Bold headers
              ),
            ),
          ),
          if (onAdd != null)
            IconButton(
              onPressed: onAdd,
              icon: Icon(Icons.add_rounded, color: color),
            ),
        ],
      ),
    );
  }
}

class _SprintGoalCard extends StatelessWidget {
  final SprintTarget target;
  final List<Factor> factors;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onComplete;
  final VoidCallback? onFail;
  final VoidCallback? onReset;

  const _SprintGoalCard({
    required this.target,
    required this.factors,
    this.onEdit,
    this.onDelete,
    this.onComplete,
    this.onFail,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final linkedFactors = factors
        .where((f) => target.linkedFactorIds.contains(f.id))
        .toList();
    final isOverdue = target.isOverdue;
    final daysLeft = target.daysRemaining;
    final isCompleted = target.isCompleted;
    final isFailed = target.isFailed;
    final isActive = target.isActive;

    return GlassCard(
      onTap: isActive ? onEdit : null,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status icon - changes based on completion state
                Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : isFailed
                      ? Icons.cancel_rounded
                      : target.duration == SprintDuration.thirtyDays
                      ? Icons.calendar_month_rounded
                      : Icons.bolt_rounded,
                  color: isCompleted
                      ? colors.success
                      : isFailed
                      ? colors.danger
                      : isOverdue
                      ? colors.danger
                      : (target.duration == SprintDuration.thirtyDays
                            ? colors.info
                            : colors.warning),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    target.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      decoration: isCompleted || isFailed
                          ? TextDecoration.lineThrough
                          : null,
                      color: isCompleted || isFailed ? colors.textMuted : null,
                    ),
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? colors.success.withAlpha(30)
                        : isFailed
                        ? colors.danger.withAlpha(30)
                        : isOverdue
                        ? colors.danger.withAlpha(30)
                        : colors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isCompleted
                        ? '✓ Done'
                        : isFailed
                        ? '✗ Failed'
                        : isOverdue
                        ? 'Overdue'
                        : '${daysLeft}d left',
                    style: TextStyle(
                      fontSize: 12,
                      color: isCompleted
                          ? colors.success
                          : isFailed
                          ? colors.danger
                          : isOverdue
                          ? colors.danger
                          : colors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            if (linkedFactors.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: linkedFactors
                    .map(
                      (f) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          f.name,
                          style: TextStyle(fontSize: 11, color: colors.primary),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            // Action buttons row
            Row(
              children: [
                if (isActive) ...[
                  // Complete button
                  Expanded(
                    child: GestureDetector(
                      onTap: onComplete,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.success.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colors.success.withAlpha(50),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_rounded,
                              color: colors.success,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Complete',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Fail button
                  Expanded(
                    child: GestureDetector(
                      onTap: onFail,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.danger.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colors.danger.withAlpha(40),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.close_rounded,
                              color: colors.danger,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Failed',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Reset button for completed/failed goals
                  Expanded(
                    child: GestureDetector(
                      onTap: onReset,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.textMuted.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              color: colors.textMuted,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Undo',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                // Delete button
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.textMuted.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: colors.textMuted,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
    final (icon, text, color) = _getRecommendation(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 11, color: color)),
          ),
        ],
      ),
    );
  }

  (IconData, String, Color) _getRecommendation(BuildContext context) {
    final colors = context.colors;
    if (hoursPerWeek <= 2) {
      return (
        Icons.flash_on_rounded,
        '💡 Focus only on Top 2 tasks. Skip reflections when busy.',
        colors.warning,
      );
    } else if (hoursPerWeek <= 5) {
      return (
        Icons.balance_rounded,
        '⚖️ Balance 2 priority tasks + 2-3 habits daily. One reflection weekly.',
        colors.info,
      );
    } else if (hoursPerWeek <= 10) {
      return (
        Icons.trending_up_rounded,
        '📈 Good capacity! Add experiments and more habits to accelerate growth.',
        colors.success,
      );
    } else {
      return (
        Icons.rocket_launch_rounded,
        '🚀 Full capacity mode! Maximize all modules for rapid progress.',
        colors.primary,
      );
    }
  }
}
