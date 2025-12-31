import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/task.dart';
import '../../models/subtask.dart';
import '../../providers/app_state.dart';
import '../../services/storage_service.dart';
import '../../widgets/glass_card.dart';

import '../../widgets/swipeable_task_card.dart';
import '../../widgets/completion_animation.dart';
import '../../widgets/xp_bar.dart';
import '../../widgets/why_dialog.dart';
import '../../widgets/fading_horizontal_scroll.dart';
import '../../widgets/task_stats_card.dart';
import '../../services/haptic_service.dart';
import 'focus_mode_screen.dart';
import '../audit/audit_screen.dart';
import '../shop/shop_screen.dart';
import '../settings/category_management_screen.dart';
import '../settings/data_management_screen.dart';

/// Module 2: Priority Task Engine (Home Screen)
/// "What are the 2 most important tasks you need to do?"
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<bool> _showBacklog = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _showCompleted = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _showStats = ValueNotifier<bool>(true);
  String? _selectedCategoryFilter;
  String _deadlineFilter = 'all'; // 'all', 'today', 'week', 'later', 'none'
  final GlobalKey _xpBarKey = GlobalKey();

  @override
  void dispose() {
    _showBacklog.dispose();
    _showCompleted.dispose();
    _showStats.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Apply filters to backlog
        final filteredBacklog = _getFilteredBacklog(state);

        // Theme variables
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surfaceLight = isDark
            ? AppColors.surfaceLight
            : LightColors.surfaceLight;
        final glassBorder = isDark
            ? AppColors.glassBorder
            : LightColors.glassBorder;
        final textMuted = isDark ? AppColors.textMuted : LightColors.textMuted;
        final textSecondary = isDark
            ? AppColors.textSecondary
            : LightColors.textSecondary;
        final textPrimary = isDark
            ? AppColors.textPrimary
            : LightColors.textPrimary;

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddTaskDialog(
              context,
              isPriority: state.canAddPriorityTask,
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Task'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header with XP bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title on its own line (prevents word wrapping)
                        Text(
                              'Today\'s Focus',
                              style: Theme.of(context).textTheme.displayMedium,
                            )
                            .animate(
                              key: const ValueKey('header-title-animate'),
                            )
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: -0.1, end: 0),
                        const SizedBox(height: 12),
                        // XP bar and actions on second row
                        Row(
                          children: [
                            XPBar(
                              key: _xpBarKey,
                              stats: state.userStats,
                              compact: true,
                            ),
                            const Spacer(),
                            // Admin Overflow Menu - consolidated from 3 separate icons
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert_rounded,
                                color: textMuted,
                              ),
                              tooltip: 'More options',
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                              ),
                              color: surfaceLight,
                              onSelected: (value) {
                                switch (value) {
                                  case 'audit':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AuditScreen(),
                                      ),
                                    );
                                    break;
                                  case 'shop':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ShopScreen(),
                                      ),
                                    );
                                    break;
                                  case 'data':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const DataManagementScreen(),
                                      ),
                                    );
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'audit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.analytics_rounded,
                                        size: 20,
                                        color: AppColors.info,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Weekly Audit',
                                        style: TextStyle(color: textPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'shop',
                                  child: Row(
                                    children: [
                                      const Text(
                                        '🏪',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Rewards Shop',
                                        style: TextStyle(color: textPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'data',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.backup_rounded,
                                        size: 20,
                                        color: AppColors.success,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Backup & Restore',
                                        style: TextStyle(color: textPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'What are the 2 most important tasks you need to do?',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.textSecondary
                                    : LightColors.textSecondary,
                              ),
                        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                      ],
                    ),
                  ),
                ),

                // Priority Tasks Counter - removed duplicate Add Task button (FAB is used instead)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        _PriorityCounter(count: state.priorityTasks.length),
                        const Spacer(),
                        // No Add Task button here - FAB handles this
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                ),

                // Priority Tasks (Top 2)
                if (state.priorityTasks.isEmpty)
                  SliverToBoxAdapter(
                    child: _EmptyState(
                      icon: Icons.task_alt_rounded,
                      title: 'No Priority Tasks',
                      subtitle: 'Add your most important tasks for today',
                      // No onAdd - FAB handles task creation
                      onAdd: null,
                    ),
                  )
                else
                  SliverReorderableList(
                    itemCount: state.priorityTasks.length,
                    onReorder: (oldIndex, newIndex) {
                      state.reorderPriorityTasks(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final task = state.priorityTasks[index];
                      return ReorderableDelayedDragStartListener(
                        key: ValueKey(task.id),
                        index: index,
                        child: _buildTaskCard(context, task, state),
                      );
                    },
                  ),

                SliverToBoxAdapter(
                  child:
                      ValueListenableBuilder<bool>(
                            valueListenable: _showBacklog,
                            builder: (context, show, child) {
                              return GestureDetector(
                                onTap: () => _showBacklog.value = !show,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: AppSpacing.lg,
                                  ),
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: surfaceLight,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.lg,
                                    ),
                                    border: Border.all(color: glassBorder),
                                    boxShadow: AppShadows.card,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        show
                                            ? Icons.keyboard_arrow_down_rounded
                                            : Icons
                                                  .keyboard_arrow_right_rounded,
                                        color: textMuted,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Less Important',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: textSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: textMuted.withAlpha(40),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          '${filteredBacklog.length}/${state.backlogTasks.length}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: textMuted,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      // IconButton removed
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                          .animate(
                            key: const ValueKey('backlog-header-animate'),
                          )
                          .fadeIn(delay: 300.ms, duration: 400.ms),
                ),

                // Backlog Content (Filters + Items)
                ValueListenableBuilder<bool>(
                  valueListenable: _showBacklog,
                  builder: (context, show, child) {
                    if (!show) return const SliverToBoxAdapter();

                    return SliverMainAxisGroup(
                      slivers: [
                        // Backlog Filters
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Deadline filters
                                FadingHorizontalScroll(
                                  child: Row(
                                    children: [
                                      _FilterChip(
                                        label: 'All',
                                        selected: _deadlineFilter == 'all',
                                        onSelected: () => setState(
                                          () => _deadlineFilter = 'all',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _FilterChip(
                                        label: 'Today',
                                        icon: Icons.today_rounded,
                                        selected: _deadlineFilter == 'today',
                                        onSelected: () => setState(
                                          () => _deadlineFilter = 'today',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _FilterChip(
                                        label: 'This Week',
                                        icon: Icons.date_range_rounded,
                                        selected: _deadlineFilter == 'week',
                                        onSelected: () => setState(
                                          () => _deadlineFilter = 'week',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _FilterChip(
                                        label: 'Later',
                                        icon: Icons.schedule_rounded,
                                        selected: _deadlineFilter == 'later',
                                        onSelected: () => setState(
                                          () => _deadlineFilter = 'later',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _FilterChip(
                                        label: 'No Deadline',
                                        icon: Icons.event_busy_rounded,
                                        selected: _deadlineFilter == 'none',
                                        onSelected: () => setState(
                                          () => _deadlineFilter = 'none',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Category filters
                                FadingHorizontalScroll(
                                  child: Row(
                                    children: [
                                      _FilterChip(
                                        label: 'All Categories',
                                        selected:
                                            _selectedCategoryFilter == null,
                                        onSelected: () => setState(
                                          () => _selectedCategoryFilter = null,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ...state.taskCategories.map(
                                        (cat) => Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          child: _FilterChip(
                                            label: cat,
                                            selected:
                                                _selectedCategoryFilter == cat,
                                            onSelected: () => setState(
                                              () =>
                                                  _selectedCategoryFilter = cat,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Backlog Items (Categorized)
                        ..._getCategorizedFilteredBacklog(
                          filteredBacklog,
                        ).entries.map(
                          (group) => SliverMainAxisGroup(
                            slivers: [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    28,
                                    16,
                                    20,
                                    8,
                                  ),
                                  child: Text(
                                    group.key.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textMuted,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildTaskCard(
                                    context,
                                    group.value[index],
                                    state,
                                    showPromote: true,
                                  ),
                                  childCount: group.value.length,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Pending Experiments
                if (state.pendingExperiments.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.science_rounded,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pending Experiments',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${state.pendingExperiments.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (state.pendingExperiments.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final exp = state.pendingExperiments[index];
                      return GlassCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                exp.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _MiniButton(
                              label: 'Top 2',
                              color: AppColors.primary,
                              onTap: state.canAddPriorityTask
                                  ? () => state.promoteExperimentToTask(
                                      exp.id,
                                      toPriority: true,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            _MiniButton(
                              label: 'Backlog',
                              color: AppColors.textMuted,
                              onTap: () => state.promoteExperimentToTask(
                                exp.id,
                                toPriority: false,
                              ),
                            ),
                          ],
                        ),
                      );
                    }, childCount: state.pendingExperiments.length),
                  ),

                SliverToBoxAdapter(
                  child:
                      ValueListenableBuilder<bool>(
                            valueListenable: _showStats,
                            builder: (context, show, child) {
                              return GestureDetector(
                                onTap: () => _showStats.value = !show,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: AppSpacing.lg,
                                  ),
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: surfaceLight,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.lg,
                                    ),
                                    border: Border.all(color: glassBorder),
                                    boxShadow: AppShadows.card,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        show
                                            ? Icons.keyboard_arrow_down_rounded
                                            : Icons
                                                  .keyboard_arrow_right_rounded,
                                        color: textMuted,
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.bar_chart_rounded,
                                        color: AppColors.primary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Task Statistics',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                          .animate(key: const ValueKey('stats-header-animate'))
                          .fadeIn(delay: 350.ms, duration: 400.ms),
                ),

                ValueListenableBuilder<bool>(
                  valueListenable: _showStats,
                  builder: (context, show, child) {
                    if (!show) return const SliverToBoxAdapter();
                    return SliverToBoxAdapter(
                      child: TaskStatsCard(stats: state.userStats),
                    );
                  },
                ),

                SliverToBoxAdapter(
                  child:
                      ValueListenableBuilder<bool>(
                            valueListenable: _showCompleted,
                            builder: (context, show, child) {
                              return GestureDetector(
                                onTap: () => _showCompleted.value = !show,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: AppSpacing.md,
                                  ),
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: surfaceLight,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.lg,
                                    ),
                                    border: Border.all(color: glassBorder),
                                    boxShadow: AppShadows.card,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        show
                                            ? Icons.keyboard_arrow_down_rounded
                                            : Icons
                                                  .keyboard_arrow_right_rounded,
                                        color: textMuted,
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.success,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Completed',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: textSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withAlpha(
                                            40,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          '${state.completedTasks.length}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.success,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                          .animate(
                            key: const ValueKey('completed-header-animate'),
                          )
                          .fadeIn(delay: 400.ms, duration: 400.ms),
                ),

                ValueListenableBuilder<bool>(
                  valueListenable: _showCompleted,
                  builder: (context, show, child) {
                    if (!show) return const SliverToBoxAdapter();

                    if (state.completedTasks.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'No completed tasks yet',
                              style: TextStyle(
                                color: textMuted,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final task = state.completedTasks[index];
                          return Opacity(
                            opacity: 0.7,
                            child: _buildTaskCard(context, task, state),
                          );
                        },
                        childCount: state.completedTasks.length > 20
                            ? 20 // Limit to 20 to prevent performance issues
                            : state.completedTasks.length,
                      ),
                    );
                  },
                ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    Task task,
    AppState state, {
    bool showPromote = false,
  }) {
    final subtasks = state.getSubtasksForTask(task.id);
    final completed = subtasks.where((s) => s.isCompleted).length;

    // Use SwipeableTaskCard for gesture-based progressive disclosure
    // Use SwipeableTaskCard for gesture-based progressive disclosure
    return Builder(
      builder: (cardContext) {
        return SwipeableTaskCard(
          task: task,
          subtaskCount: subtasks.length,
          subtaskCompleted: completed,
          onTap: () => _showEditTaskDialog(cardContext, task),
          onComplete: () {
            if (!task.isCompleted) {
              HapticService.success();

              // Show completion animation (Principle 4: Dopamine Feedback Loop)
              // Calculate position from task card context
              final box = cardContext.findRenderObject() as RenderBox?;
              if (box != null) {
                final position = box.localToGlobal(
                  Offset(24, box.size.height / 2),
                );
                final xpAmount = task.isPriority ? 15 : 10;
                CompletionOverlay.show(
                  cardContext,
                  position: position,
                  xpBarKey: _xpBarKey,
                  xpAmount: xpAmount,
                );
              }
            } else {
              HapticService.selectionClick();
            }

            state.toggleTaskComplete(task.id);
          },
          onDelete: () async {
            if (!task.isCompleted) {
              final reason = await showWhyDialog(cardContext, task);
              if (reason != null && cardContext.mounted) {
                task.abandonReason = reason;
                _deleteTaskWithUndo(cardContext, task, state);
              }
            } else {
              _deleteTaskWithUndo(cardContext, task, state);
            }
          },
          onPromote: (showPromote && state.canAddPriorityTask)
              ? () => state.promoteTaskToPriority(task.id)
              : null,
          onDemote: task.isPriority
              ? () async {
                  final reason = await showWhyDialog(cardContext, task);
                  if (reason != null && cardContext.mounted) {
                    task.demoteToBacklog(reason: reason);
                    state.updateTask(task);
                  }
                }
              : null,
          onFocusMode: task.isPriority
              ? () => Navigator.push(
                  cardContext,
                  MaterialPageRoute(
                    builder: (_) => FocusModeScreen(task: task),
                  ),
                )
              : null,
        );
      },
    );
  }

  /// Delete task with undo capability via SnackBar
  void _deleteTaskWithUndo(BuildContext context, Task task, AppState state) {
    // Store task data for potential restore
    final taskCopy = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      isPriority: task.isPriority,
      isCompleted: task.isCompleted,
      effort: task.effort,
      impact: task.impact,
      source: task.source,
      category: task.category,
      deadline: task.deadline,
      customTag: task.customTag,
      addedToPriorityAt: task.addedToPriorityAt,
      abandonReason: task.abandonReason,
    );

    // Haptic feedback for delete
    HapticService.mediumImpact();

    // Delete the task
    state.deleteTask(task.id);

    // Show SnackBar with undo action
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Task "${task.title.length > 20 ? '${task.title.substring(0, 20)}...' : task.title}" deleted',
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.primary,
          onPressed: () {
            // Restore the task
            state.addTask(taskCopy);
          },
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80), // Above FAB
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, {required bool isPriority}) {
    bool currentIsPriority = isPriority;
    final controller = TextEditingController();
    TaskEffort effort = TaskEffort.quick;
    TaskImpact impact = TaskImpact.high;
    String category = 'General';
    DateTime? deadline;
    String? customTag;
    String? titleError; // Validation error message
    bool showAdvanced = false; // Progressive disclosure toggle
    List<String> selectedFactorIds = []; // Linked factors
    final state = context.read<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surface : LightColors.surface;
    final surfaceLight = isDark
        ? AppColors.surfaceLight
        : LightColors.surfaceLight;
    final glassBorder = isDark
        ? AppColors.glassBorder
        : LightColors.glassBorder;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textMuted = isDark ? AppColors.textMuted : LightColors.textMuted;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: glassBorder),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: currentIsPriority
                                ? AppColors.primary
                                : textMuted,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          currentIsPriority
                              ? 'Add Priority Task'
                              : 'Add to Backlog',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'High Priority',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: currentIsPriority
                                ? AppColors.primary
                                : textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: currentIsPriority,
                          activeTrackColor: AppColors.primary,
                          onChanged: (val) {
                            if (val && !state.canAddPriorityTask) {
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Priority list is full (Max 2)',
                                  ),
                                  backgroundColor: AppColors.danger,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.only(
                                    bottom:
                                        MediaQuery.of(
                                          context,
                                        ).viewInsets.bottom +
                                        80,
                                    left: 16,
                                    right: 16,
                                  ),
                                ),
                              );
                              return;
                            }
                            setModalState(() => currentIsPriority = val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(color: textPrimary),
                  onChanged: (value) {
                    // Clear error when user types
                    if (titleError != null && value.trim().isNotEmpty) {
                      setModalState(() => titleError = null);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    hintText: 'What needs to be done?',
                    filled: true,
                    fillColor: surfaceLight,
                    errorText: titleError,
                    errorStyle: TextStyle(color: AppColors.danger),
                  ),
                ),
                const SizedBox(height: 20),

                // Category Selection
                Row(
                  children: [
                    Text(
                      'Category:',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoryManagementScreen(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.settings,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Manage',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...state.taskCategories.map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onLongPress: cat == 'General'
                                ? null
                                : () {
                                    // Show delete confirmation dialog
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        backgroundColor: AppColors.surface,
                                        title: Text(
                                          'Delete Category',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        content: Text(
                                          'Delete "$cat"? Tasks with this category will be moved to "General".',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // Move tasks to General before deleting
                                              for (final task
                                                  in state.tasks.where(
                                                    (t) => t.category == cat,
                                                  )) {
                                                task.category = 'General';
                                                state.updateTask(task);
                                              }
                                              state.deleteTaskCategory(cat);
                                              if (category == cat) {
                                                setModalState(
                                                  () => category = 'General',
                                                );
                                              }
                                              Navigator.pop(ctx);
                                            },
                                            child: Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: AppColors.danger,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                            child: _ChoiceChip(
                              label: cat,
                              selected: category == cat,
                              onSelected: (s) =>
                                  setModalState(() => category = cat),
                            ),
                          ),
                        ),
                      ),
                      ActionChip(
                        avatar: Icon(
                          Icons.add,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          'New',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        backgroundColor: AppColors.surfaceLight,
                        side: BorderSide(
                          color: AppColors.primary.withAlpha(50),
                        ),
                        onPressed: () {
                          // Show dialog to add category
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              final catController = TextEditingController();
                              return AlertDialog(
                                backgroundColor: AppColors.surface,
                                title: Text(
                                  'New Category',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                content: TextField(
                                  controller: catController,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hintText: 'Category Name',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (catController.text.isNotEmpty) {
                                        state.addTaskCategory(
                                          catController.text.trim(),
                                        );
                                        setModalState(
                                          () => category = catController.text
                                              .trim(),
                                        );
                                        Navigator.pop(ctx);
                                      }
                                    },
                                    child: Text('Add'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Deadline Selection
                Row(
                  children: [
                    Text(
                      'Deadline:',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      icon: Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        deadline == null
                            ? 'Set Date'
                            : '${deadline!.month}/${deadline!.day}/${deadline!.year}',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setModalState(() => deadline = picked);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Advanced Options (Collapsible for progressive disclosure)
                GestureDetector(
                  onTap: () =>
                      setModalState(() => showAdvanced = !showAdvanced),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          showAdvanced
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Advanced Options',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (!showAdvanced &&
                            (effort != TaskEffort.quick ||
                                impact != TaskImpact.high ||
                                customTag != null))
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Modified',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Collapsible Advanced Options
                if (showAdvanced) ...[
                  const SizedBox(height: 16),

                  // Effort Selection
                  Text(
                    'Effort Required:',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _ChoiceChip(
                        label: '⚡ Quick',
                        selected: effort == TaskEffort.quick,
                        onSelected: (s) =>
                            setModalState(() => effort = TaskEffort.quick),
                      ),
                      const SizedBox(width: 12),
                      _ChoiceChip(
                        label: '🐘 Deep',
                        selected: effort == TaskEffort.deep,
                        onSelected: (s) =>
                            setModalState(() => effort = TaskEffort.deep),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Impact Selection
                  Text(
                    'Expected Impact:',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _ChoiceChip(
                        label: '⭐ High',
                        selected: impact == TaskImpact.high,
                        onSelected: (s) =>
                            setModalState(() => impact = TaskImpact.high),
                      ),
                      const SizedBox(width: 12),
                      _ChoiceChip(
                        label: '🧹 Maintenance',
                        selected: impact == TaskImpact.maintenance,
                        onSelected: (s) => setModalState(
                          () => impact = TaskImpact.maintenance,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Custom Tag
                  Text(
                    'Custom Tag (Optional):',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(text: customTag)
                      ..selection = TextSelection.collapsed(
                        offset: customTag?.length ?? 0,
                      ),
                    onChanged: (v) => customTag = v.isEmpty ? null : v,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Urgent, Review',
                      filled: true,
                      fillColor: AppColors.surfaceLight,
                    ),
                  ),

                  // Factor Connection (Optional)
                  if (state.factors.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Link to Goal Tree (Factors):',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // "None" chip for no factor link
                        _ChoiceChip(
                          label: '✕ None',
                          selected: selectedFactorIds.isEmpty,
                          onSelected: (_) =>
                              setModalState(() => selectedFactorIds = []),
                        ),
                        // Chips for each factor (dissected tree elements)
                        ...state.factors.map(
                          (factor) => _ChoiceChip(
                            label: factor.name,
                            selected: selectedFactorIds.contains(factor.id),
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  selectedFactorIds.add(factor.id);
                                } else {
                                  selectedFactorIds.remove(factor.id);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],

                const SizedBox(height: 16),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isEmpty) {
                          setModalState(
                            () => titleError = 'Please enter a task title',
                          );
                          return;
                        }
                        _addTask(
                          context,
                          text,
                          currentIsPriority,
                          effort,
                          impact,
                          category,
                          deadline,
                          customTag,
                          selectedFactorIds,
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Add Task'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    final controller = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);
    TaskEffort effort = task.effort;
    TaskImpact impact = task.impact;
    String category = task.category;
    DateTime? deadline = task.deadline;
    String? customTag = task.customTag;
    List<String> selectedFactorIds = List.from(task.linkedFactorIds);
    final state = context.read<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surface : LightColors.surface;
    final surfaceLight = isDark
        ? AppColors.surfaceLight
        : LightColors.surfaceLight;
    final glassBorder = isDark
        ? AppColors.glassBorder
        : LightColors.glassBorder;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textMuted = isDark ? AppColors.textMuted : LightColors.textMuted;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: glassBorder),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Edit Task',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.list_alt_rounded),
                      onPressed: () {
                        Navigator.pop(context);
                        _showSubtaskDialog(context, task);
                      },
                      tooltip: 'Subtasks',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  style: TextStyle(color: AppColors.textPrimary),
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Text(
                      'Category:',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoryManagementScreen(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.settings,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Manage',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...state.taskCategories.map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onLongPress: cat == 'General'
                                ? null
                                : () {
                                    // Show delete confirmation dialog
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        backgroundColor: AppColors.surface,
                                        title: Text(
                                          'Delete Category',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        content: Text(
                                          'Delete "$cat"? Tasks with this category will be moved to "General".',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // Move tasks to General before deleting
                                              for (final t in state.tasks.where(
                                                (t) => t.category == cat,
                                              )) {
                                                t.category = 'General';
                                                state.updateTask(t);
                                              }
                                              state.deleteTaskCategory(cat);
                                              if (category == cat) {
                                                setModalState(
                                                  () => category = 'General',
                                                );
                                              }
                                              Navigator.pop(ctx);
                                            },
                                            child: Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: AppColors.danger,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                            child: _ChoiceChip(
                              label: cat,
                              selected: category == cat,
                              onSelected: (s) =>
                                  setModalState(() => category = cat),
                            ),
                          ),
                        ),
                      ),
                      ActionChip(
                        avatar: Icon(
                          Icons.add,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          'New',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        backgroundColor: AppColors.surfaceLight,
                        side: BorderSide(
                          color: AppColors.primary.withAlpha(50),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              final catController = TextEditingController();
                              return AlertDialog(
                                backgroundColor: AppColors.surface,
                                title: Text(
                                  'New Category',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                content: TextField(
                                  controller: catController,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hintText: 'Category Name',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (catController.text.isNotEmpty) {
                                        state.addTaskCategory(
                                          catController.text.trim(),
                                        );
                                        setModalState(
                                          () => category = catController.text
                                              .trim(),
                                        );
                                        Navigator.pop(ctx);
                                      }
                                    },
                                    child: Text('Add'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Text(
                      'Deadline:',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      icon: Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        deadline == null
                            ? 'Set Date'
                            : '${deadline!.month}/${deadline!.day}/${deadline!.year}',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: deadline ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 30),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setModalState(() => deadline = picked);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Effort:',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _ChoiceChip(
                            label: '⚡ Quick',
                            selected: effort == TaskEffort.quick,
                            onSelected: (s) =>
                                setModalState(() => effort = TaskEffort.quick),
                          ),
                          const SizedBox(height: 4),
                          _ChoiceChip(
                            label: '🐘 Deep',
                            selected: effort == TaskEffort.deep,
                            onSelected: (s) =>
                                setModalState(() => effort = TaskEffort.deep),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Impact:',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _ChoiceChip(
                            label: '⭐ High',
                            selected: impact == TaskImpact.high,
                            onSelected: (s) =>
                                setModalState(() => impact = TaskImpact.high),
                          ),
                          const SizedBox(height: 4),
                          _ChoiceChip(
                            label: '🧹 Maint.',
                            selected: impact == TaskImpact.maintenance,
                            onSelected: (s) => setModalState(
                              () => impact = TaskImpact.maintenance,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Custom Tag
                Text(
                  'Custom Tag (Optional):',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: TextEditingController(text: customTag)
                    ..selection = TextSelection.collapsed(
                      offset: customTag?.length ?? 0,
                    ),
                  onChanged: (v) => customTag = v,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Urgent, Review',
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                  ),
                ),

                // Factor Connection (Optional)
                if (state.factors.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Link to Goal Tree (Factors):',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // "None" chip for no factor link
                      _ChoiceChip(
                        label: '✕ None',
                        selected: selectedFactorIds.isEmpty,
                        onSelected: (_) =>
                            setModalState(() => selectedFactorIds = []),
                      ),
                      // Chips for each factor
                      ...state.factors.map(
                        (factor) => _ChoiceChip(
                          label: factor.name,
                          selected: selectedFactorIds.contains(factor.id),
                          onSelected: (selected) {
                            setModalState(() {
                              if (selected) {
                                selectedFactorIds.add(factor.id);
                              } else {
                                selectedFactorIds.remove(factor.id);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          task.title = controller.text.trim();
                          task.description = descController.text.trim();
                          task.effort = effort;
                          task.impact = impact;
                          task.category = category;
                          task.deadline = deadline;
                          task.customTag = customTag;
                          task.linkedFactorIds = selectedFactorIds;
                          state.updateTask(task);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addTask(
    BuildContext context,
    String title,
    bool isPriority,
    TaskEffort effort,
    TaskImpact impact,
    String category,
    DateTime? deadline,
    String? customTag,
    List<String> linkedFactorIds,
  ) {
    final state = context.read<AppState>();
    final task = Task(
      id: StorageService.generateId(),
      title: title,
      isPriority: isPriority,
      effort: effort,
      impact: impact,
      source: TaskSource.newEntry,
      addedToPriorityAt: isPriority ? DateTime.now() : null,
      category: category,
      deadline: deadline,
      customTag: customTag,
      linkedFactorIds: linkedFactorIds,
    );
    state.addTask(task);
  }

  List<Task> _getFilteredBacklog(AppState state) {
    var tasks = state.backlogTasks.toList();

    // Apply category filter
    if (_selectedCategoryFilter != null) {
      tasks = tasks
          .where((t) => t.category == _selectedCategoryFilter)
          .toList();
    }

    // Apply deadline filter
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekEnd = today.add(const Duration(days: 7));

    switch (_deadlineFilter) {
      case 'today':
        tasks = tasks.where((t) {
          if (t.deadline == null) return false;
          final d = DateTime(
            t.deadline!.year,
            t.deadline!.month,
            t.deadline!.day,
          );
          return d.isAtSameMomentAs(today) || d.isBefore(today);
        }).toList();
        break;
      case 'week':
        tasks = tasks.where((t) {
          if (t.deadline == null) return false;
          final d = DateTime(
            t.deadline!.year,
            t.deadline!.month,
            t.deadline!.day,
          );
          return d.isAfter(today) && d.isBefore(weekEnd);
        }).toList();
        break;
      case 'later':
        tasks = tasks.where((t) {
          if (t.deadline == null) return false;
          final d = DateTime(
            t.deadline!.year,
            t.deadline!.month,
            t.deadline!.day,
          );
          return d.isAfter(weekEnd) || d.isAtSameMomentAs(weekEnd);
        }).toList();
        break;
      case 'none':
        tasks = tasks.where((t) => t.deadline == null).toList();
        break;
    }

    return tasks;
  }

  Map<String, List<Task>> _getCategorizedFilteredBacklog(List<Task> tasks) {
    final Map<String, List<Task>> groups = {};
    for (final task in tasks) {
      if (!groups.containsKey(task.category)) {
        groups[task.category] = [];
      }
      groups[task.category]!.add(task);
    }
    return groups;
  }

  void _showSubtaskDialog(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SubtaskSheet(task: task),
    );
  }
}

class _PriorityCounter extends StatelessWidget {
  final int count;

  const _PriorityCounter({required this.count});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceLight = isDark
        ? AppColors.surfaceLight
        : LightColors.surfaceLight;
    final glassBorder = isDark
        ? AppColors.glassBorder
        : LightColors.glassBorder;
    final textMuted = isDark ? AppColors.textMuted : LightColors.textMuted;

    return Row(
      children: List.generate(2, (index) {
        final isFilled = index < count;
        return Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? AppColors.primary : surfaceLight,
            border: Border.all(
              color: isFilled ? AppColors.primary : glassBorder,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isFilled ? Colors.white : textMuted,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// _AddTaskButton removed - FAB handles task creation now

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onAdd;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            if (onAdd != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Task'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _MiniButton({required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: onTap != null
              ? color.withValues(alpha: 0.1)
              : AppColors.surfaceLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onTap != null
                ? color.withValues(alpha: 0.3)
                : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: onTap != null
                ? color
                : AppColors.textMuted.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

/// Subtask management sheet
class _SubtaskSheet extends StatefulWidget {
  final Task task;

  const _SubtaskSheet({required this.task});

  @override
  State<_SubtaskSheet> createState() => _SubtaskSheetState();
}

class _SubtaskSheetState extends State<_SubtaskSheet> {
  final _controller = TextEditingController();
  List<Subtask> _subtasks = [];

  @override
  void initState() {
    super.initState();
    _loadSubtasks();
  }

  void _loadSubtasks() {
    final state = context.read<AppState>();
    setState(() {
      _subtasks = state.getSubtasksForTask(widget.task.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.task.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Subtasks list
          Expanded(
            child: _subtasks.isEmpty
                ? Center(
                    child: Text(
                      'Break this task into smaller steps',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    itemCount: _subtasks.length,
                    itemBuilder: (context, index) {
                      final subtask = _subtasks[index];
                      return _SubtaskItem(
                        subtask: subtask,
                        onToggle: () => _toggleSubtask(subtask),
                        onDelete: () => _deleteSubtask(subtask),
                      );
                    },
                  ),
          ),

          // Add subtask input
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              border: Border(top: BorderSide(color: AppColors.glassBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Add a subtask...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _addSubtask(value.trim());
                        _controller.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      _addSubtask(_controller.text.trim());
                      _controller.clear();
                    }
                  },
                  icon: Icon(
                    Icons.add_circle_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addSubtask(String title) {
    final state = context.read<AppState>();
    final subtask = Subtask(
      id: StorageService.generateId(),
      title: title,
      parentTaskId: widget.task.id,
      sortOrder: _subtasks.length,
    );
    state.addSubtask(subtask);
    _loadSubtasks();
  }

  void _toggleSubtask(Subtask subtask) {
    final state = context.read<AppState>();
    subtask.toggle();
    state.updateSubtask(subtask);
    _loadSubtasks();
  }

  void _deleteSubtask(Subtask subtask) {
    final state = context.read<AppState>();
    state.deleteSubtask(subtask.id);
    _loadSubtasks();
  }
}

class _SubtaskItem extends StatelessWidget {
  final Subtask subtask;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _SubtaskItem({
    required this.subtask,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: subtask.isCompleted
                    ? AppColors.success
                    : Colors.transparent,
                border: Border.all(
                  color: subtask.isCompleted
                      ? AppColors.success
                      : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: subtask.isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              subtask.title,
              style: TextStyle(
                color: subtask.isCompleted
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
                decoration: subtask.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.textMuted,
              size: 18,
            ),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool) onSelected;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.primary.withAlpha(50),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      backgroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.glassBorder,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withAlpha(30)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
