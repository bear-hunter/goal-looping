import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../providers/app_state.dart';
import '../../models/task.dart';
import '../../models/habit.dart';
import '../../models/recurring_task.dart';

/// Screen to view and manage archived items (habits, tasks, recurring tasks)
class ArchivedItemsScreen extends StatefulWidget {
  const ArchivedItemsScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ArchivedItemsScreen()),
    );
  }

  @override
  State<ArchivedItemsScreen> createState() => _ArchivedItemsScreenState();
}

class _ArchivedItemsScreenState extends State<ArchivedItemsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.background : LightColors.background;
    final textPrimary = isDark ? AppColors.textPrimary : LightColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Archived Items'),
        backgroundColor: isDark ? AppColors.surface : LightColors.surface,
        foregroundColor: textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: textPrimary.withAlpha(150),
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Habits'),
            Tab(text: 'Tasks'),
            Tab(text: 'Recurring'),
          ],
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          final archivedHabits = state.habits.where((h) => h.isArchived).toList();
          final archivedTasks = state.tasks.where((t) => t.isArchived).toList();
          final archivedRecurring = state.recurringTasks.where((rt) => rt.isArchived).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildHabitsList(archivedHabits, state, isDark, textPrimary),
              _buildTasksList(archivedTasks, state, isDark, textPrimary),
              _buildRecurringList(archivedRecurring, state, isDark, textPrimary),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHabitsList(
    List<Habit> habits,
    AppState state,
    bool isDark,
    Color textPrimary,
  ) {
    if (habits.isEmpty) {
      return _buildEmptyState('No archived habits', isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return _ArchivedItemCard(
          title: habit.name,
          subtitle: '${habit.type.name} habit • ${habit.completionCount} completions',
          icon: Icons.repeat_rounded,
          iconColor: habit.type == HabitType.build ? Colors.green : Colors.red,
          onRestore: () => _restoreHabit(habit, state),
          onDelete: () => _confirmDeleteHabit(habit, state),
        );
      },
    );
  }

  Widget _buildTasksList(
    List<Task> tasks,
    AppState state,
    bool isDark,
    Color textPrimary,
  ) {
    if (tasks.isEmpty) {
      return _buildEmptyState('No archived tasks', isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _ArchivedItemCard(
          title: task.title,
          subtitle: task.isCompleted ? 'Completed' : 'Not completed',
          icon: Icons.check_circle_outline_rounded,
          iconColor: AppColors.primary,
          onRestore: () => _restoreTask(task, state),
          onDelete: () => _confirmDeleteTask(task, state),
        );
      },
    );
  }

  Widget _buildRecurringList(
    List<RecurringTask> tasks,
    AppState state,
    bool isDark,
    Color textPrimary,
  ) {
    if (tasks.isEmpty) {
      return _buildEmptyState('No archived recurring tasks', isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _ArchivedItemCard(
          title: task.name,
          subtitle: 'Recurring task',
          icon: Icons.event_repeat_rounded,
          iconColor: Colors.purple,
          onRestore: () => _restoreRecurringTask(task, state),
          onDelete: () => _confirmDeleteRecurringTask(task, state),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.archive_outlined,
            size: 64,
            color: (isDark ? AppColors.textMuted : LightColors.textMuted).withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.textSecondary : LightColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _restoreHabit(Habit habit, AppState state) {
    habit.isArchived = false;
    state.updateHabit(habit);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${habit.name} restored')),
    );
  }

  void _restoreTask(Task task, AppState state) {
    task.isArchived = false;
    state.updateTask(task);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${task.title} restored')),
    );
  }

  void _restoreRecurringTask(RecurringTask task, AppState state) {
    task.isArchived = false;
    state.updateRecurringTask(task);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${task.name} restored')),
    );
  }

  Future<void> _confirmDeleteHabit(Habit habit, AppState state) async {
    final confirmed = await _showDeleteConfirmation('habit', habit.name);
    if (confirmed) {
      state.deleteHabit(habit.id);
    }
  }

  Future<void> _confirmDeleteTask(Task task, AppState state) async {
    final confirmed = await _showDeleteConfirmation('task', task.title);
    if (confirmed) {
      state.deleteTask(task.id);
    }
  }

  Future<void> _confirmDeleteRecurringTask(RecurringTask task, AppState state) async {
    final confirmed = await _showDeleteConfirmation('recurring task', task.name);
    if (confirmed) {
      state.deleteRecurringTask(task.id);
    }
  }

  Future<bool> _showDeleteConfirmation(String type, String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete $type permanently?'),
            content: Text('Are you sure you want to permanently delete "$name"? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }
}

/// Card widget for archived items
class _ArchivedItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _ArchivedItemCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surface : LightColors.surface;
    final textPrimary = isDark ? AppColors.textPrimary : LightColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : LightColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.glassBorder : LightColors.glassBorder,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          IconButton(
            icon: const Icon(Icons.restore_rounded),
            color: AppColors.primary,
            tooltip: 'Restore',
            onPressed: onRestore,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever_rounded),
            color: Colors.red,
            tooltip: 'Delete permanently',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
