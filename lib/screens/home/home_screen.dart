import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/task.dart';
import '../../models/subtask.dart';
import '../../providers/app_state.dart';
import '../../services/storage_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/task_card.dart';
import '../../widgets/xp_bar.dart';
import '../../widgets/why_dialog.dart';
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
  bool _showBacklog = false;
  String? _selectedCategoryFilter;
  String _deadlineFilter = 'all'; // 'all', 'today', 'week', 'later', 'none'

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Apply filters to backlog
        final filteredBacklog = _getFilteredBacklog(state);

        return SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header with XP bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child:
                                Text(
                                      'Today\'s Focus',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.displayMedium,
                                    )
                                    .animate()
                                    .fadeIn(duration: 400.ms)
                                    .slideY(begin: -0.1, end: 0),
                          ),
                          XPBar(stats: state.userStats, compact: true),
                          const SizedBox(width: 8),
                          // Weekly Audit Icon
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AuditScreen(),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.info.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.analytics_rounded,
                                size: 20,
                                color: AppColors.info,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ShopScreen(),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '🏪',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Data Management Icon
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DataManagementScreen(),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.success.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.backup_rounded,
                                size: 20,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'What are the 2 most important tasks you need to do?',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                    ],
                  ),
                ),
              ),

              // Priority Tasks Counter
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
                      if (state.canAddPriorityTask)
                        _AddTaskButton(
                          onPressed: () =>
                              _showAddTaskDialog(context, isPriority: true),
                        ),
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
                    onAdd: state.canAddPriorityTask
                        ? () => _showAddTaskDialog(context, isPriority: true)
                        : null,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildTaskCard(
                      context,
                      state.priorityTasks[index],
                      state,
                    ),
                    childCount: state.priorityTasks.length,
                  ),
                ),

              // Backlog Section
              SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () => setState(() => _showBacklog = !_showBacklog),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _showBacklog
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.keyboard_arrow_right_rounded,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Less Important',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textMuted.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${filteredBacklog.length}/${state.backlogTasks.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.add_rounded,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () =>
                              _showAddTaskDialog(context, isPriority: false),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              ),

              // Backlog Filters
              if (_showBacklog)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Deadline filters
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'All',
                                selected: _deadlineFilter == 'all',
                                onSelected: () =>
                                    setState(() => _deadlineFilter = 'all'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Today',
                                icon: Icons.today_rounded,
                                selected: _deadlineFilter == 'today',
                                onSelected: () =>
                                    setState(() => _deadlineFilter = 'today'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'This Week',
                                icon: Icons.date_range_rounded,
                                selected: _deadlineFilter == 'week',
                                onSelected: () =>
                                    setState(() => _deadlineFilter = 'week'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Later',
                                icon: Icons.schedule_rounded,
                                selected: _deadlineFilter == 'later',
                                onSelected: () =>
                                    setState(() => _deadlineFilter = 'later'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'No Deadline',
                                icon: Icons.event_busy_rounded,
                                selected: _deadlineFilter == 'none',
                                onSelected: () =>
                                    setState(() => _deadlineFilter = 'none'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Category filters
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'All Categories',
                                selected: _selectedCategoryFilter == null,
                                onSelected: () => setState(
                                  () => _selectedCategoryFilter = null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ...state.taskCategories.map(
                                (cat) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _FilterChip(
                                    label: cat,
                                    selected: _selectedCategoryFilter == cat,
                                    onSelected: () => setState(
                                      () => _selectedCategoryFilter = cat,
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
              if (_showBacklog)
                ..._getCategorizedFilteredBacklog(filteredBacklog).entries.map(
                  (group) => SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 16, 20, 8),
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

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
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

    return TaskCard(
      task: task,
      subtaskCount: subtasks.length,
      subtaskCompleted: completed,
      showActions: true,
      onTap: () => _showEditTaskDialog(context, task),
      onComplete: () => state.toggleTaskComplete(task.id),
      onDelete: () async {
        if (!task.isCompleted) {
          final reason = await showWhyDialog(context, task);
          if (reason != null) {
            task.abandonReason = reason;
            state.deleteTask(task.id);
          }
        } else {
          state.deleteTask(task.id);
        }
      },
      onPromote: (showPromote && state.canAddPriorityTask)
          ? () => state.promoteTaskToPriority(task.id)
          : null,
      onDemote: task.isPriority
          ? () async {
              final reason = await showWhyDialog(context, task);
              if (reason != null) {
                task.demoteToBacklog(reason: reason);
                state.updateTask(task);
              }
            }
          : null,
      onFocusMode: task.isPriority
          ? () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FocusModeScreen(task: task)),
            )
          : null,
    );
  }

  void _showAddTaskDialog(BuildContext context, {required bool isPriority}) {
    final controller = TextEditingController();
    TaskEffort effort = TaskEffort.quick;
    TaskImpact impact = TaskImpact.high;
    String category = 'General';
    DateTime? deadline;
    String? customTag;
    final state = context.read<AppState>();

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
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isPriority
                            ? AppColors.primary
                            : AppColors.textMuted,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isPriority ? 'Add Priority Task' : 'Add to Backlog',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'What needs to be done?',
                    filled: true,
                    fillColor: AppColors.surfaceLight,
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
                      onSelected: (s) =>
                          setModalState(() => impact = TaskImpact.maintenance),
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
                        if (controller.text.trim().isNotEmpty) {
                          _addTask(
                            context,
                            controller.text.trim(),
                            isPriority,
                            effort,
                            impact,
                            category,
                            deadline,
                            customTag,
                          );
                          Navigator.pop(context);
                        }
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
    final state = context.read<AppState>();

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
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: AppColors.glassBorder),
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
    return Row(
      children: List.generate(2, (index) {
        final isFilled = index < count;
        return Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? AppColors.primary : AppColors.surfaceLight,
            border: Border.all(
              color: isFilled ? AppColors.primary : AppColors.glassBorder,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isFilled ? Colors.white : AppColors.textMuted,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _AddTaskButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddTaskButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            const Text(
              'Add Task',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
