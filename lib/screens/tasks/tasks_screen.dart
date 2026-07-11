import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/task.dart';
import '../../providers/app_state.dart';
import 'collect_task_screen.dart';

/// Task Management Screen with Eisenhower Matrix categorization
/// Japanese minimalist aesthetic: high information density, flat hierarchy,
/// subtle dividers, efficient use of space while maintaining touch accessibility
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _showDecisionHelper = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Consumer<AppState>(
      builder: (context, state, _) {
        final inboxTasks = state.tasks
            .where(
              (t) =>
                  t.quadrant == EisenhowerQuadrant.inbox &&
                  !t.isCompleted &&
                  !t.isArchived,
            )
            .toList();
        final focusTasks = state.tasks
            .where(
              (t) =>
                  t.quadrant == EisenhowerQuadrant.focus &&
                  !t.isCompleted &&
                  !t.isArchived,
            )
            .toList();
        final scheduleTasks = state.tasks
            .where(
              (t) =>
                  t.quadrant == EisenhowerQuadrant.schedule &&
                  !t.isCompleted &&
                  !t.isArchived,
            )
            .toList();
        final branchTasks = state.tasks
            .where(
              (t) =>
                  t.quadrant == EisenhowerQuadrant.branch &&
                  !t.isCompleted &&
                  !t.isArchived,
            )
            .toList();
        final deleteTasks = state.tasks
            .where(
              (t) =>
                  t.quadrant == EisenhowerQuadrant.delete &&
                  !t.isCompleted &&
                  !t.isArchived,
            )
            .toList();

        return SafeArea(
          child: Scaffold(
            backgroundColor: colors.background,
            floatingActionButton: FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CollectTaskScreen()),
              ),
              backgroundColor: colors.primary,
              child: const Icon(Icons.add_rounded),
            ).animate().scale(delay: 300.ms, duration: 200.ms),
            body: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Tasks',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ),
                        // Toggle decision helper
                        IconButton(
                          onPressed: () => setState(
                            () => _showDecisionHelper = !_showDecisionHelper,
                          ),
                          icon: Icon(
                            _showDecisionHelper
                                ? Icons.help_rounded
                                : Icons.help_outline_rounded,
                            color: _showDecisionHelper
                                ? colors.primary
                                : colors.textMuted,
                          ),
                          tooltip: 'Decision Helper',
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms),
                  ),
                ),

                // Decision Helper (collapsible)
                if (_showDecisionHelper)
                  SliverToBoxAdapter(
                    child:
                        Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: _DecisionHelperCard(colors: colors),
                            )
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: -0.1, end: 0),
                  ),

                // Inbox section (uncategorized tasks)
                if (inboxTasks.isNotEmpty)
                  _buildQuadrantSection(
                    context: context,
                    state: state,
                    colors: colors,
                    title: 'Inbox',
                    subtitle: 'Categorize these',
                    icon: Icons.inbox_rounded,
                    color: colors.textMuted,
                    tasks: inboxTasks,
                    quadrant: EisenhowerQuadrant.inbox,
                  ),

                // Focus section (Important + Urgent)
                _buildQuadrantSection(
                  context: context,
                  state: state,
                  colors: colors,
                  title: 'Focus',
                  subtitle: 'Important & Urgent → Do now',
                  icon: Icons.local_fire_department_rounded,
                  color: colors.danger,
                  tasks: focusTasks,
                  quadrant: EisenhowerQuadrant.focus,
                ),

                // Schedule section (Important + Not Urgent)
                _buildQuadrantSection(
                  context: context,
                  state: state,
                  colors: colors,
                  title: 'Schedule',
                  subtitle: 'Important & Not Urgent → Plan it',
                  icon: Icons.calendar_today_rounded,
                  color: colors.primary,
                  tasks: scheduleTasks,
                  quadrant: EisenhowerQuadrant.schedule,
                ),

                // Branch section (Not Important + Urgent)
                _buildQuadrantSection(
                  context: context,
                  state: state,
                  colors: colors,
                  title: 'Branch',
                  subtitle: 'Not Important & Urgent → Delegate/batch',
                  icon: Icons.call_split_rounded,
                  color: colors.warning,
                  tasks: branchTasks,
                  quadrant: EisenhowerQuadrant.branch,
                ),

                // Delete section (Not Important + Not Urgent)
                _buildQuadrantSection(
                  context: context,
                  state: state,
                  colors: colors,
                  title: 'Delete',
                  subtitle: 'Not Important & Not Urgent → Remove',
                  icon: Icons.delete_outline_rounded,
                  color: colors.textMuted,
                  tasks: deleteTasks,
                  quadrant: EisenhowerQuadrant.delete,
                ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuadrantSection({
    required BuildContext context,
    required AppState state,
    required AppColorsTheme colors,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Task> tasks,
    required EisenhowerQuadrant quadrant,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colors.glassBorder, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: color,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${tasks.length}',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Task list or empty state
            if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No tasks',
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ...tasks.asMap().entries.map((entry) {
                final index = entry.key;
                final task = entry.value;
                return _TaskTile(
                  key: ValueKey(task.id),
                  task: task,
                  color: color,
                  colors: colors,
                  onComplete: () => state.toggleTaskComplete(task.id),
                  onChangeQuadrant: (newQuadrant) {
                    task.quadrant = newQuadrant;
                    state.updateTask(task);
                  },
                  onDelete: () => state.deleteTask(task.id),
                ).animate().fadeIn(duration: 200.ms, delay: (50 * index).ms);
              }),
          ],
        ),
      ),
    );
  }
}

/// Decision helper card with the two key questions
class _DecisionHelperCard extends StatelessWidget {
  final AppColorsTheme colors;

  const _DecisionHelperCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ask yourself:',
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _QuestionRow(
            colors: colors,
            question: '"What happens if I don\'t do this today?"',
            answer: 'Major negative consequences → It\'s urgent',
            color: colors.danger,
          ),
          const SizedBox(height: 8),
          _QuestionRow(
            colors: colors,
            question: '"What happens if I never do this?"',
            answer: 'Derails long-term goals → It\'s important',
            color: colors.primary,
          ),
        ],
      ),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  final AppColorsTheme colors;
  final String question;
  final String answer;
  final Color color;

  const _QuestionRow({
    required this.colors,
    required this.question,
    required this.answer,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.arrow_forward_rounded, size: 12, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Text(answer, style: TextStyle(color: color, fontSize: 11)),
            ),
          ],
        ),
      ],
    );
  }
}

/// Individual task tile within a quadrant
class _TaskTile extends StatelessWidget {
  final Task task;
  final Color color;
  final AppColorsTheme colors;
  final VoidCallback onComplete;
  final void Function(EisenhowerQuadrant) onChangeQuadrant;
  final VoidCallback onDelete;

  const _TaskTile({
    super.key,
    required this.task,
    required this.color,
    required this.colors,
    required this.onComplete,
    required this.onChangeQuadrant,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showQuadrantPicker(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Row(
          children: [
            // Delete button for delete quadrant, checkbox for others
            if (task.quadrant == EisenhowerQuadrant.delete)
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colors.danger.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: colors.danger,
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: onComplete,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    border: Border.all(color: color.withAlpha(150), width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: task.isCompleted
                      ? Icon(Icons.check_rounded, size: 14, color: color)
                      : null,
                ),
              ),
            const SizedBox(width: 12),
            // Task info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.description.isNotEmpty)
                    Text(
                      task.description,
                      style: TextStyle(color: colors.textMuted, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuadrantPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Move to...',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _QuadrantOption(
              colors: colors,
              title: 'Focus',
              subtitle: 'Important & Urgent',
              icon: Icons.local_fire_department_rounded,
              color: colors.danger,
              isSelected: task.quadrant == EisenhowerQuadrant.focus,
              onTap: () {
                onChangeQuadrant(EisenhowerQuadrant.focus);
                Navigator.pop(ctx);
              },
            ),
            _QuadrantOption(
              colors: colors,
              title: 'Schedule',
              subtitle: 'Important & Not Urgent',
              icon: Icons.calendar_today_rounded,
              color: colors.primary,
              isSelected: task.quadrant == EisenhowerQuadrant.schedule,
              onTap: () {
                onChangeQuadrant(EisenhowerQuadrant.schedule);
                Navigator.pop(ctx);
              },
            ),
            _QuadrantOption(
              colors: colors,
              title: 'Branch',
              subtitle: 'Not Important & Urgent',
              icon: Icons.call_split_rounded,
              color: colors.warning,
              isSelected: task.quadrant == EisenhowerQuadrant.branch,
              onTap: () {
                onChangeQuadrant(EisenhowerQuadrant.branch);
                Navigator.pop(ctx);
              },
            ),
            _QuadrantOption(
              colors: colors,
              title: 'Delete',
              subtitle: 'Not Important & Not Urgent',
              icon: Icons.delete_outline_rounded,
              color: colors.textMuted,
              isSelected: task.quadrant == EisenhowerQuadrant.delete,
              onTap: () {
                onChangeQuadrant(EisenhowerQuadrant.delete);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _QuadrantOption extends StatelessWidget {
  final AppColorsTheme colors;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuadrantOption({
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(20) : colors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? color.withAlpha(100) : colors.glassBorder,
          ),
        ),
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
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: colors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
