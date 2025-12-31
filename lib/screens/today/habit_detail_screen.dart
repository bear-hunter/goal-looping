import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../providers/app_state.dart';
import '../../models/habit.dart';
import '../../models/habit_enums.dart';
import '../../models/category_model.dart';

/// Habit Detail Screen with tabbed interface
class HabitDetailScreen extends StatefulWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  static Future<void> show(BuildContext context, {required String habitId}) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HabitDetailScreen(habitId: habitId)),
    );
  }

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _calendarMonth = DateTime.now();

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

    final appState = context.watch<AppState>();
    final habit = appState.habits.firstWhere(
      (h) => h.id == widget.habitId,
      orElse: () => throw Exception('Habit not found'),
    );
    final category = appState.getCategoryById(habit.categoryId ?? '');

    return Scaffold(
      backgroundColor: bgColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: category != null
                ? Color(category.colorValue)
                : AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                habit.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (category != null
                          ? Color(category.colorValue)
                          : AppColors.primary),
                      (category != null
                              ? Color(category.colorValue)
                              : AppColors.primary)
                          .withAlpha(200),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        category?.icon ?? Icons.repeat_rounded,
                        size: 48,
                        color: Colors.white.withAlpha(200),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${habit.currentStreak} day streak',
                        style: TextStyle(
                          color: Colors.white.withAlpha(220),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Calendar'),
                Tab(text: 'Statistics'),
                Tab(text: 'Edit'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCalendarTab(habit, isDark, textPrimary),
            _buildStatisticsTab(habit, isDark, textPrimary),
            _buildEditTab(habit, isDark, textPrimary),
          ],
        ),
      ),
    );
  }

  // ========== CALENDAR TAB ==========
  Widget _buildCalendarTab(Habit habit, bool isDark, Color textPrimary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month navigation
          _buildMonthHeader(isDark, textPrimary),
          const SizedBox(height: 8),

          // Calendar grid
          _buildCalendarGrid(habit, isDark, textPrimary),
          const SizedBox(height: 24),

          // Recent completions
          _buildRecentLogs(habit, isDark, textPrimary),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildMonthHeader(bool isDark, Color textPrimary) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: textPrimary),
          onPressed: () => setState(() {
            _calendarMonth = DateTime(
              _calendarMonth.year,
              _calendarMonth.month - 1,
            );
          }),
        ),
        Text(
          '${months[_calendarMonth.month - 1]} ${_calendarMonth.year}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right_rounded, color: textPrimary),
          onPressed: () => setState(() {
            _calendarMonth = DateTime(
              _calendarMonth.year,
              _calendarMonth.month + 1,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(Habit habit, bool isDark, Color textPrimary) {
    final firstDay = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final lastDay = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0);
    final startWeekday = firstDay.weekday; // 1=Mon, 7=Sun

    final days = <Widget>[];

    // Day headers
    for (final day in ['M', 'T', 'W', 'T', 'F', 'S', 'S']) {
      days.add(
        Center(
          child: Text(
            day,
            style: TextStyle(
              color: textPrimary.withAlpha(150),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    // Empty cells before first day
    for (int i = 1; i < startWeekday; i++) {
      days.add(const SizedBox());
    }

    // Calendar days
    final today = DateTime.now();
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_calendarMonth.year, _calendarMonth.month, day);
      final isCompleted = habit.isCompletedFor(date);
      final isScheduled = habit.isScheduledFor(date);
      final isToday =
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isFuture = date.isAfter(today);

      days.add(
        GestureDetector(
          onTap: isFuture ? null : () => _toggleCompletion(habit, date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.primary
                  : (isToday ? AppColors.primary.withAlpha(30) : null),
              borderRadius: BorderRadius.circular(8),
              border: isToday
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isCompleted
                      ? Colors.white
                      : (isFuture ? textPrimary.withAlpha(80) : textPrimary),
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  decoration: isScheduled && !isCompleted && !isFuture
                      ? TextDecoration.underline
                      : null,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: days,
    );
  }

  void _toggleCompletion(Habit habit, DateTime date) async {
    final appState = context.read<AppState>();
    final isCompleted = habit.isCompletedFor(date);

    habit.logForDate(date: date, completed: !isCompleted);
    await appState.updateHabit(habit);
    setState(() {});
  }

  Widget _buildRecentLogs(Habit habit, bool isDark, Color textPrimary) {
    final recentLogs = habit.logs.where((log) => log.completed).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (recentLogs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceLight : LightColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No completions yet. Tap a date to log!',
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondary
                  : LightColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
        ),
        const SizedBox(height: 8),
        ...recentLogs
            .take(5)
            .map(
              (log) => ListTile(
                dense: true,
                leading: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  _formatDate(log.date),
                  style: TextStyle(color: textPrimary),
                ),
                subtitle: log.note != null ? Text(log.note!) : null,
              ),
            ),
      ],
    );
  }

  // ========== STATISTICS TAB ==========
  Widget _buildStatisticsTab(Habit habit, bool isDark, Color textPrimary) {
    final totalCompletions = habit.logs.where((l) => l.completed).length;
    final completionRate = _calculateCompletionRate(habit);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Score gauge
          _buildScoreGauge(completionRate, isDark, textPrimary),
          const SizedBox(height: 24),

          // Stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'Current Streak',
                '${habit.currentStreak}',
                Icons.local_fire_department_rounded,
                Colors.orange,
                isDark,
                textPrimary,
              ),
              _buildStatCard(
                'Best Streak',
                '${habit.bestStreak}',
                Icons.emoji_events_rounded,
                Colors.amber,
                isDark,
                textPrimary,
              ),
              _buildStatCard(
                'Total',
                '$totalCompletions',
                Icons.check_circle_rounded,
                AppColors.primary,
                isDark,
                textPrimary,
              ),
              _buildStatCard(
                'Rate',
                '${(completionRate * 100).round()}%',
                Icons.trending_up_rounded,
                Colors.green,
                isDark,
                textPrimary,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Weekly distribution
          _buildWeeklyDistribution(habit, isDark, textPrimary),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildScoreGauge(double rate, bool isDark, Color textPrimary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceLight : LightColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: rate,
                    strokeWidth: 12,
                    backgroundColor: AppColors.glassBorder,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                Center(
                  child: Text(
                    '${(rate * 100).round()}%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Habit Score',
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondary
                  : LightColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
    Color textPrimary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceLight : LightColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondary
                  : LightColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyDistribution(Habit habit, bool isDark, Color textPrimary) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayCounts = List.filled(7, 0);

    for (final log in habit.logs.where((l) => l.completed)) {
      dayCounts[log.date.weekday - 1]++;
    }

    final maxCount = dayCounts.isEmpty
        ? 1
        : dayCounts.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceLight : LightColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Distribution',
            style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              7,
              (i) => Column(
                children: [
                  Container(
                    width: 24,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.glassBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 24,
                        height: maxCount > 0
                            ? (dayCounts[i] / maxCount * 60)
                            : 0,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNames[i],
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateCompletionRate(Habit habit) {
    final startDate = habit.startDate ?? habit.createdAt;
    final now = DateTime.now();
    int scheduledDays = 0;
    int completedDays = 0;

    for (
      var date = startDate;
      date.isBefore(now.add(const Duration(days: 1)));
      date = date.add(const Duration(days: 1))
    ) {
      if (habit.isScheduledFor(date)) {
        scheduledDays++;
        if (habit.isCompletedFor(date)) completedDays++;
      }
    }

    if (scheduledDays == 0) return 0;
    return completedDays / scheduledDays;
  }

  // ========== EDIT TAB ==========
  Widget _buildEditTab(Habit habit, bool isDark, Color textPrimary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEditSection(
            'Habit Info',
            [
              _buildInfoRow('Name', habit.name, textPrimary),
              _buildInfoRow(
                'Type',
                habit.type.toString().split('.').last,
                textPrimary,
              ),
              _buildInfoRow(
                'Evaluation',
                habit.effectiveEvaluationType.label,
                textPrimary,
              ),
              _buildInfoRow(
                'Frequency',
                habit.effectiveFrequencyType.label,
                textPrimary,
              ),
            ],
            isDark,
            textPrimary,
          ),
          const SizedBox(height: 16),

          _buildEditSection(
            'Schedule',
            [
              _buildInfoRow('Days', habit.scheduleDaysLabel, textPrimary),
              _buildInfoRow(
                'Start',
                _formatDate(habit.startDate ?? habit.createdAt),
                textPrimary,
              ),
              if (habit.endDate != null)
                _buildInfoRow('End', _formatDate(habit.endDate!), textPrimary),
            ],
            isDark,
            textPrimary,
          ),
          const SizedBox(height: 16),

          _buildEditSection(
            'Priority & Category',
            [
              _buildInfoRow(
                'Priority',
                habit.effectivePriorityLevel.label,
                textPrimary,
              ),
              _buildInfoRow(
                'Category',
                habit.categoryId ?? 'None',
                textPrimary,
              ),
            ],
            isDark,
            textPrimary,
          ),
          const SizedBox(height: 24),

          // Action buttons
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _archiveHabit(habit),
              icon: Icon(
                habit.isArchived
                    ? Icons.unarchive_rounded
                    : Icons.archive_rounded,
              ),
              label: Text(habit.isArchived ? 'Unarchive' : 'Archive'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _deleteHabit(habit),
              icon: const Icon(Icons.delete_rounded, color: Colors.red),
              label: const Text(
                'Delete Habit',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildEditSection(
    String title,
    List<Widget> children,
    bool isDark,
    Color textPrimary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceLight : LightColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: textPrimary.withAlpha(180))),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500, color: textPrimary),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _archiveHabit(Habit habit) async {
    final appState = context.read<AppState>();
    habit.isArchived = !habit.isArchived;
    await appState.updateHabit(habit);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            habit.isArchived ? 'Habit archived' : 'Habit unarchived',
          ),
        ),
      );
    }
  }

  void _deleteHabit(Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit?'),
        content: const Text(
          'This will permanently delete this habit and all its data.',
        ),
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
    );

    if (confirmed == true && mounted) {
      final appState = context.read<AppState>();
      await appState.deleteHabit(habit.id);
      Navigator.of(context).pop();
    }
  }
}
