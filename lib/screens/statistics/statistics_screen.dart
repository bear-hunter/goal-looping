import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/theme.dart';
import '../../providers/app_state.dart';
import '../../models/habit.dart';

/// Statistics Screen - View global and per-item statistics
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const StatisticsScreen()));
  }

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
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
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: isDark ? AppColors.surface : LightColors.surface,
        foregroundColor: textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: textPrimary.withAlpha(150),
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Habits'),
            Tab(text: 'Tasks'),
          ],
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(state, isDark, textPrimary),
              _buildHabitsTab(state, isDark, textPrimary),
              _buildTasksTab(state, isDark, textPrimary),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(AppState state, bool isDark, Color textPrimary) {
    final stats = state.userStats;
    final activeHabits = state.habits
        .where((h) => h.isActive && !h.isArchived)
        .toList();
    final completedTasks = state.tasks.where((t) => t.isCompleted).length;
    final pendingTasks = state.tasks
        .where((t) => !t.isCompleted && !t.isArchived)
        .length;

    // Calculate overall habit completion rate for last 7 days
    final now = DateTime.now();
    int totalScheduled = 0;
    int totalCompleted = 0;
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      for (final habit in activeHabits) {
        if (habit.isScheduledFor(date)) {
          totalScheduled++;
          if (habit.isCompletedFor(date)) {
            totalCompleted++;
          }
        }
      }
    }
    final weeklyCompletionRate = totalScheduled > 0
        ? (totalCompleted / totalScheduled * 100).round()
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level & XP Card
          _StatCard(
            title: 'Level & Progress',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level ${stats.level}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          '${stats.totalXP} XP total',
                          style: TextStyle(
                            fontSize: 11,
                            color: textPrimary.withAlpha(150),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '🔥 ${stats.currentStreak}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // XP Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value:
                        (stats.totalXP - stats.xpForCurrentLevel) /
                        (stats.xpForNextLevel - stats.xpForCurrentLevel),
                    minHeight: 8,
                    backgroundColor: isDark
                        ? AppColors.surfaceLight
                        : LightColors.surfaceLight,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stats.xpForNextLevel - stats.totalXP} XP to Level ${stats.level + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    color: textPrimary.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Quick Stats Grid
          Row(
            children: [
              Expanded(
                child: _QuickStatCard(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: Colors.orange,
                  value: '${stats.currentStreak}',
                  label: 'Current Streak',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickStatCard(
                  icon: Icons.emoji_events_rounded,
                  iconColor: Colors.amber,
                  value: '${stats.longestStreak}',
                  label: 'Best Streak',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickStatCard(
                  icon: Icons.check_circle_rounded,
                  iconColor: Colors.green,
                  value: '$completedTasks',
                  label: 'Tasks Done',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickStatCard(
                  icon: Icons.pending_actions_rounded,
                  iconColor: Colors.blue,
                  value: '$pendingTasks',
                  label: 'Pending Tasks',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekly Completion Rate
          _StatCard(
            title: 'This Week',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$weeklyCompletionRate%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _getCompletionColor(weeklyCompletionRate),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$totalCompleted / $totalScheduled',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'habits completed',
                          style: TextStyle(
                            fontSize: 10,
                            color: textPrimary.withAlpha(150),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // 7-day mini chart
                _buildWeeklyChart(activeHabits, isDark),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Task Stats
          _StatCard(
            title: 'Task Statistics',
            child: Column(
              children: [
                _StatRow(
                  label: 'Total Tasks Completed',
                  value: '${stats.totalTasksCompleted}',
                  icon: Icons.task_alt_rounded,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _StatRow(
                  label: 'Priority Tasks Done',
                  value: '${stats.priorityTasksCompleted}',
                  icon: Icons.priority_high_rounded,
                  color: Colors.red,
                ),
                const SizedBox(height: 12),
                _StatRow(
                  label: 'Tasks Done Today',
                  value: '${stats.tasksCompletedToday}',
                  icon: Icons.today_rounded,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(List<Habit> habits, bool isDark) {
    final now = DateTime.now();
    final days = <_DayData>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      int scheduled = 0;
      int completed = 0;

      for (final habit in habits) {
        if (habit.isScheduledFor(date)) {
          scheduled++;
          if (habit.isCompletedFor(date)) {
            completed++;
          }
        }
      }

      days.add(
        _DayData(date: date, scheduled: scheduled, completed: completed),
      );
    }

    final maxScheduled = days
        .map((d) => d.scheduled)
        .reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final dayName = DateFormat('E').format(day.date).substring(0, 1);
        final isToday =
            day.date.day == now.day &&
            day.date.month == now.month &&
            day.date.year == now.year;
        final rate = day.scheduled > 0 ? day.completed / day.scheduled : 0.0;

        return Column(
          children: [
            Container(
              width: 32,
              height: 60,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceLight
                    : LightColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: 32,
                    height: maxScheduled > 0
                        ? 60 * (day.completed / maxScheduled).clamp(0.1, 1.0)
                        : 6,
                    decoration: BoxDecoration(
                      color: _getCompletionColor((rate * 100).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? AppColors.primary : null,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHabitsTab(AppState state, bool isDark, Color textPrimary) {
    final habits = state.habits
        .where((h) => h.isActive && !h.isArchived)
        .toList();

    if (habits.isEmpty) {
      return _buildEmptyState(
        'No habits yet',
        'Create habits to see statistics',
        isDark,
      );
    }

    // Sort by completion rate (descending)
    habits.sort((a, b) => b.completionRate.compareTo(a.completionRate));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return _HabitStatCard(habit: habit);
      },
    );
  }

  Widget _buildTasksTab(AppState state, bool isDark, Color textPrimary) {
    final completedTasks = state.tasks.where((t) => t.isCompleted).toList();
    final pendingTasks = state.tasks
        .where((t) => !t.isCompleted && !t.isArchived)
        .toList();

    // Group by date
    final tasksByDate =
        <String, List<dynamic>>{}; // String date -> [completed, pending]

    for (final task in completedTasks) {
      if (task.completedAt != null) {
        final key = DateFormat('yyyy-MM-dd').format(task.completedAt!);
        tasksByDate[key] ??= [0, 0];
        tasksByDate[key]![0]++;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _QuickStatCard(
                  icon: Icons.check_circle_rounded,
                  iconColor: Colors.green,
                  value: '${completedTasks.length}',
                  label: 'Completed',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickStatCard(
                  icon: Icons.schedule_rounded,
                  iconColor: Colors.orange,
                  value: '${pendingTasks.length}',
                  label: 'Pending',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Recent completions
          _StatCard(
            title: 'Recent Completions',
            child: completedTasks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No completed tasks yet',
                      style: TextStyle(color: textPrimary.withAlpha(150)),
                    ),
                  )
                : Column(
                    children: completedTasks.take(10).map((task) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                task.title,
                                style: TextStyle(
                                  color: textPrimary,
                                  decoration: TextDecoration.lineThrough,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (task.completedAt != null)
                              Text(
                                DateFormat('MMM d').format(task.completedAt!),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textPrimary.withAlpha(150),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 64,
            color: (isDark ? AppColors.textMuted : LightColors.textMuted)
                .withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondary
                  : LightColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textMuted : LightColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCompletionColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }
}

class _DayData {
  final DateTime date;
  final int scheduled;
  final int completed;

  _DayData({
    required this.date,
    required this.scheduled,
    required this.completed,
  });
}

class _StatCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _StatCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surface : LightColors.surface;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.glassBorder : LightColors.glassBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textPrimary.withAlpha(180),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _QuickStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surface : LightColors.surface;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? AppColors.glassBorder : LightColors.glassBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: textPrimary.withAlpha(150)),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: textPrimary, fontSize: 13),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
      ],
    );
  }
}

class _HabitStatCard extends StatelessWidget {
  final Habit habit;

  const _HabitStatCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surface : LightColors.surface;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;

    final completionRate = habit.completionRate;
    final color = habit.type == HabitType.build ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? AppColors.glassBorder : LightColors.glassBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  habit.type == HabitType.build
                      ? Icons.add_circle_outline_rounded
                      : Icons.remove_circle_outline_rounded,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      '${habit.type.name} habit',
                      style: TextStyle(fontSize: 10, color: textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                '$completionRate%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getCompletionColor(completionRate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completionRate / 100,
              minHeight: 6,
              backgroundColor: isDark
                  ? AppColors.surfaceLight
                  : LightColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation(
                _getCompletionColor(completionRate),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(
                icon: Icons.local_fire_department_rounded,
                value: '${habit.currentStreak}',
                label: 'Streak',
                color: Colors.orange,
              ),
              _MiniStat(
                icon: Icons.emoji_events_rounded,
                value: '${habit.bestStreak}',
                label: 'Best',
                color: Colors.amber,
              ),
              _MiniStat(
                icon: Icons.check_circle_rounded,
                value: '${habit.completionCount}',
                label: 'Done',
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCompletionColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: textPrimary.withAlpha(150)),
        ),
      ],
    );
  }
}
