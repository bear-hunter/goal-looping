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

/// Module 2: Priority Task Engine (Home Screen)
/// "What are the 2 most important tasks you need to do?"
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showBacklog = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Focus',
                        style: Theme.of(context).textTheme.displayMedium,
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      _PriorityCounter(count: state.priorityTasks.length),
                      const Spacer(),
                      if (state.canAddPriorityTask)
                        _AddTaskButton(
                          onPressed: () => _showAddTaskDialog(context, isPriority: true),
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
                    (context, index) => _buildTaskCard(context, state.priorityTasks[index], state),
                    childCount: state.priorityTasks.length,
                  ),
                ),

              // Backlog Section
              SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () => setState(() => _showBacklog = !_showBacklog),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight.withOpacity(0.5),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.textMuted.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${state.backlogTasks.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.add_rounded, color: AppColors.textMuted, size: 20),
                          onPressed: () => _showAddTaskDialog(context, isPriority: false),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              ),

              // Backlog Items
              if (_showBacklog)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildTaskCard(
                      context, 
                      state.backlogTasks[index], 
                      state,
                      showPromote: true,
                    ),
                    childCount: state.backlogTasks.length,
                  ),
                ),

              // Pending Experiments
              if (state.pendingExperiments.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Row(
                      children: [
                        Icon(Icons.science_rounded, color: AppColors.warning, size: 20),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.2),
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
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                                  ? () => state.promoteExperimentToTask(exp.id, toPriority: true)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            _MiniButton(
                              label: 'Backlog',
                              color: AppColors.textMuted,
                              onTap: () => state.promoteExperimentToTask(exp.id, toPriority: false),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: state.pendingExperiments.length,
                  ),
                ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task, AppState state, {bool showPromote = false}) {
    final subtasks = state.getSubtasksForTask(task.id);
    final completed = subtasks.where((s) => s.isCompleted).length;
    
    return TaskCard(
      task: task,
      subtaskCount: subtasks.length,
      subtaskCompleted: completed,
      showActions: true,
      onTap: () => _showSubtaskDialog(context, task),
      onComplete: () => state.toggleTaskComplete(task.id),
      onDelete: () => state.deleteTask(task.id),
      onPromote: (showPromote && state.canAddPriorityTask) 
          ? () => state.promoteTaskToPriority(task.id) 
          : null,
      onDemote: task.isPriority ? () => state.demoteTaskToBacklog(task.id) : null,
    );
  }

  void _showAddTaskDialog(BuildContext context, {required bool isPriority}) {
    final controller = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: AppColors.glassBorder),
        ),
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
                    color: isPriority ? AppColors.primary : AppColors.textMuted,
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
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _addTask(context, value.trim(), isPriority);
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      _addTask(context, controller.text.trim(), isPriority);
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
    );
  }

  void _addTask(BuildContext context, String title, bool isPriority) {
    final state = context.read<AppState>();
    final task = Task(
      id: StorageService.generateId(),
      title: title,
      isPriority: isPriority,
      source: TaskSource.newEntry,
    );
    state.addTask(task);
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
              color: AppColors.primary.withOpacity(0.3),
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
            Icon(icon, size: 64, color: AppColors.textMuted.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textMuted,
              ),
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

  const _MiniButton({
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: onTap != null ? color.withOpacity(0.1) : AppColors.surfaceLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onTap != null ? color.withOpacity(0.3) : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: onTap != null ? color : AppColors.textMuted.withOpacity(0.5),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
            padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
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
                  icon: Icon(Icons.add_circle_rounded, color: AppColors.primary),
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
                color: subtask.isCompleted ? AppColors.success : Colors.transparent,
                border: Border.all(
                  color: subtask.isCompleted ? AppColors.success : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: subtask.isCompleted
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              subtask.title,
              style: TextStyle(
                color: subtask.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
