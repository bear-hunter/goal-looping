import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../providers/app_state.dart';
import '../../models/habit.dart';
import '../../models/habit_enums.dart';

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

  // Edit state
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _triggerResponseController;
  String? _selectedCategoryId;
  PriorityLevel _selectedPriority = PriorityLevel.none;
  List<int> _selectedDays = [];
  bool _isEditMode = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _triggerResponseController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _triggerResponseController.dispose();
    super.dispose();
  }

  void _initEditState(Habit habit) {
    if (!_isEditMode) {
      _nameController.text = habit.name;
      _descriptionController.text = habit.description ?? '';
      _triggerResponseController.text = habit.triggerResponse ?? '';
      _selectedCategoryId = habit.categoryId;
      _selectedPriority = habit.effectivePriorityLevel;
      _selectedDays = List<int>.from(habit.scheduledDays);
    }
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
            expandedHeight: 110,
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
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 50),
              title: Text(
                habit.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 44),
                      Icon(
                        category?.icon ?? Icons.repeat_rounded,
                        size: 28,
                        color: Colors.white.withAlpha(200),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${habit.currentStreak} day streak',
                        style: TextStyle(
                          color: Colors.white.withAlpha(220),
                          fontSize: 11,
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
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCalendarTab(habit, isDark, textPrimary),
            _buildStatisticsTab(habit, isDark, textPrimary),
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
      final log = habit.getLogFor(date);
      final isCompleted = log?.completed ?? false;
      final score = log?.score;
      final isScheduled = habit.isScheduledFor(date);
      final isToday =
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isFuture = date.isAfter(today);

      // Determine cell color based on scoring or completion
      Color? cellColor;
      Color textColor = textPrimary;
      bool showCheckmark = false;

      if (habit.scoringEnabled && score != null) {
        if (score >= 70) {
          cellColor = Colors.green;
          showCheckmark = true;
        } else if (score >= 40) {
          cellColor = Colors.orange;
        } else {
          cellColor = Colors.red;
        }
        textColor = Colors.white;
      } else if (isCompleted) {
        cellColor = AppColors.primary;
        textColor = Colors.white;
        showCheckmark = true;
      } else if (isToday) {
        cellColor = AppColors.primary.withAlpha(30);
      } else if (isFuture) {
        textColor = textPrimary.withAlpha(80);
      }

      days.add(
        GestureDetector(
          onTap: isFuture ? null : () => _toggleCompletion(habit, date),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: cellColor,
              borderRadius: BorderRadius.circular(8),
              border: isToday
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
              boxShadow: showCheckmark
                  ? [
                      BoxShadow(
                        color: (cellColor ?? Colors.transparent).withAlpha(80),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: habit.scoringEnabled && score != null
                      ? Text(
                          '$score',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        )
                      : Text(
                          '$day',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                            decoration: isScheduled && !isCompleted && !isFuture
                                ? TextDecoration.underline
                                : null,
                          ),
                        ),
                ),
                if (showCheckmark)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Icon(
                      Icons.check,
                      size: 8,
                      color: textColor.withAlpha(200),
                    ),
                  ),
              ],
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

    // If scoring is enabled, show scoring dialog instead of just toggling
    if (habit.scoringEnabled) {
      _showScoringDialogForDate(habit, date, appState);
    } else {
      habit.logForDate(date: date, completed: !isCompleted);
      await appState.updateHabit(habit);
      setState(() {});
    }
  }

  void _showScoringDialogForDate(
    Habit habit,
    DateTime date,
    AppState appState,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLog = habit.getLogFor(date);
    double sliderValue = (currentLog?.score ?? 50).toDouble();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surface : LightColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Log for ${_formatDateShort(date)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimary
                      : LightColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Score slider
              Text(
                'Score: ${sliderValue.round()}%',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? AppColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: sliderValue,
                min: 0,
                max: 100,
                divisions: 10,
                activeColor: _getScoreColor(sliderValue.round()),
                onChanged: (value) {
                  setDialogState(() => sliderValue = value);
                },
              ),

              // Quick score buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [0, 25, 50, 75, 100].map((score) {
                  final isSelected = sliderValue.round() == score;
                  return GestureDetector(
                    onTap: () =>
                        setDialogState(() => sliderValue = score.toDouble()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _getScoreColor(score)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getScoreColor(score)),
                      ),
                      child: Text(
                        '$score%',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : _getScoreColor(score),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        habit.logForDate(
                          date: date,
                          completed: false,
                          score: null,
                        );
                        await appState.updateHabit(habit);
                        setState(() {});
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        habit.logForDate(
                          date: date,
                          completed: sliderValue > 0,
                          score: sliderValue.round(),
                        );
                        await appState.updateHabit(habit);
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getScoreColor(sliderValue.round()),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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

  Color _getScoreColor(int score) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _formatDateShort(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}';
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

  // ========== DEFENSE TAB ==========
  Widget _buildDefenseTab(Habit habit, bool isDark, Color textPrimary) {
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;
    final accentColor = AppColors.primary;

    // Get barrier logs from habit logs
    final logsWithBarriers =
        habit.logs
            .where(
              (log) => log.barrierTag != null && log.barrierTag!.isNotEmpty,
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    // Count barriers by type
    final barrierCounts = <String, int>{};
    for (final log in logsWithBarriers) {
      final tag = log.barrierTag!;
      barrierCounts[tag] = (barrierCounts[tag] ?? 0) + 1;
    }
    final sortedBarriers = barrierCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scripted Response Section (If-Then Plan)
          _buildDefenseCard(
            'Scripted Response',
            Icons.psychology_rounded,
            accentColor,
            isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your If-Then Plan',
                  style: TextStyle(color: textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                if (habit.triggerResponse != null &&
                    habit.triggerResponse!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accentColor.withAlpha(50)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.bolt_rounded, color: accentColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            habit.triggerResponse!,
                            style: TextStyle(
                              color: textPrimary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  _buildEmptyState(
                    'No scripted response yet',
                    'Add one in the Edit tab to prepare for obstacles',
                    Icons.add_rounded,
                    textSecondary,
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    _tabController.animateTo(3); // Go to Edit tab
                  },
                  icon: Icon(
                    habit.triggerResponse != null
                        ? Icons.edit_rounded
                        : Icons.add_rounded,
                    size: 18,
                  ),
                  label: Text(
                    habit.triggerResponse != null
                        ? 'Edit Response'
                        : 'Add Response',
                  ),
                  style: OutlinedButton.styleFrom(foregroundColor: accentColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Barrier Statistics
          _buildDefenseCard(
            'Barrier Analysis',
            Icons.analytics_rounded,
            Colors.orange,
            isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sortedBarriers.isEmpty)
                  _buildEmptyState(
                    'No barriers logged yet',
                    'When you miss this habit, logging barriers helps identify patterns',
                    Icons.shield_rounded,
                    textSecondary,
                  )
                else ...[
                  Text(
                    'Most Common Barriers',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  ...sortedBarriers
                      .take(5)
                      .map(
                        (entry) => _buildBarrierRow(
                          entry.key,
                          entry.value,
                          logsWithBarriers.length,
                          textPrimary,
                          textSecondary,
                        ),
                      ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Recent Barrier Logs
          _buildDefenseCard(
            'Barrier History',
            Icons.history_rounded,
            Colors.blue,
            isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (logsWithBarriers.isEmpty)
                  _buildEmptyState(
                    'No barrier history',
                    'Barrier logs will appear here when you log them',
                    Icons.timeline_rounded,
                    textSecondary,
                  )
                else ...[
                  ...logsWithBarriers
                      .take(10)
                      .map(
                        (log) => _buildBarrierLogEntry(
                          log,
                          textPrimary,
                          textSecondary,
                        ),
                      ),
                  if (logsWithBarriers.length > 10)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '+ ${logsWithBarriers.length - 10} more entries',
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Defense Actions
          _buildDefenseCard(
            'Quick Actions',
            Icons.flash_on_rounded,
            Colors.amber,
            isDark,
            child: Column(
              children: [
                _buildQuickActionButton(
                  'Log a Barrier Now',
                  Icons.warning_rounded,
                  Colors.orange,
                  () => _showLogBarrierDialog(habit),
                ),
                const SizedBox(height: 8),
                _buildQuickActionButton(
                  'I\'m Struggling - Show My Plan',
                  Icons.psychology_rounded,
                  accentColor,
                  () => _showScriptedResponseDialog(habit),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildDefenseCard(
    String title,
    IconData icon,
    Color color,
    bool isDark, {
    required Widget child,
  }) {
    final surfaceColor = isDark
        ? AppColors.surfaceLight
        : LightColors.surfaceLight;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    Color textSecondary,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(icon, size: 32, color: textSecondary.withAlpha(100)),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: textSecondary)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: textSecondary.withAlpha(150), fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBarrierRow(
    String barrier,
    int count,
    int total,
    Color textPrimary,
    Color textSecondary,
  ) {
    final percentage = (count / total * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(barrier, style: TextStyle(color: textPrimary, fontSize: 14)),
              Text(
                '$count ($percentage%)',
                style: TextStyle(color: textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: count / total,
            backgroundColor: Colors.grey.withAlpha(50),
            valueColor: AlwaysStoppedAnimation(_getBarrierColor(barrier)),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Color _getBarrierColor(String barrier) {
    switch (barrier.toLowerCase()) {
      case 'tired':
        return Colors.purple;
      case 'no time':
        return Colors.blue;
      case 'stressed':
        return Colors.red;
      case 'distracted':
        return Colors.orange;
      case 'unmotivated':
        return Colors.grey;
      case 'sick':
        return Colors.teal;
      case 'social pressure':
        return Colors.pink;
      case 'forgot':
        return Colors.amber;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildBarrierLogEntry(
    HabitLog log,
    Color textPrimary,
    Color textSecondary,
  ) {
    final dateStr = _formatDateRelative(log.date);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getBarrierColor(log.barrierTag ?? ''),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.barrierTag ?? 'Unknown',
                  style: TextStyle(color: textPrimary, fontSize: 14),
                ),
                Text(
                  dateStr,
                  style: TextStyle(color: textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          if (log.note != null && log.note!.isNotEmpty)
            Tooltip(
              message: log.note!,
              child: Icon(Icons.notes_rounded, size: 16, color: textSecondary),
            ),
        ],
      ),
    );
  }

  String _formatDateRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  void _showLogBarrierDialog(Habit habit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    String? selectedBarrier;
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surface : LightColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Log a Barrier',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'What got in the way?',
                style: TextStyle(color: textPrimary.withAlpha(180)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: BarrierTags.common.map((tag) {
                  final isSelected = selectedBarrier == tag;
                  return ChoiceChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setModalState(
                        () => selectedBarrier = selected ? tag : null,
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  hintText: 'Add a note (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedBarrier == null
                      ? null
                      : () {
                          _logBarrier(
                            habit,
                            selectedBarrier!,
                            noteController.text,
                          );
                          Navigator.pop(ctx);
                        },
                  child: const Text('Log Barrier'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logBarrier(Habit habit, String barrier, String note) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    // Find or create today's log
    var todayLog = habit.logs.firstWhere(
      (log) =>
          log.date.year == todayStart.year &&
          log.date.month == todayStart.month &&
          log.date.day == todayStart.day,
      orElse: () {
        final newLog = HabitLog(date: todayStart);
        habit.logs.add(newLog);
        return newLog;
      },
    );

    todayLog.barrierTag = barrier;
    if (note.isNotEmpty) {
      todayLog.note = note;
    }

    context.read<AppState>().updateHabit(habit);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Barrier logged: $barrier'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showScriptedResponseDialog(Habit habit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final accentColor = AppColors.primary;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.psychology_rounded, color: accentColor),
            const SizedBox(width: 8),
            const Text('Your Defense Plan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (habit.triggerResponse != null &&
                habit.triggerResponse!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor.withAlpha(50)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'When facing obstacles:',
                      style: TextStyle(
                        color: textPrimary.withAlpha(180),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      habit.triggerResponse!,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '💡 Remember: This is your pre-planned response. Trust it!',
                style: TextStyle(
                  color: textPrimary.withAlpha(150),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ] else ...[
              const Text('You haven\'t set up a scripted response yet.'),
              const SizedBox(height: 8),
              const Text(
                'An "If-Then" plan helps you overcome obstacles automatically. '
                'Example: "If I feel tired → I will do just 5 minutes"',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          if (habit.triggerResponse == null || habit.triggerResponse!.isEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _tabController.animateTo(3); // Go to Edit tab
              },
              child: const Text('Add One Now'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              habit.triggerResponse != null ? 'Got It!' : 'Maybe Later',
            ),
          ),
        ],
      ),
    );
  }

  // ========== EDIT TAB ==========
  Widget _buildEditTab(Habit habit, bool isDark, Color textPrimary) {
    _initEditState(habit);
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;
    final surfaceColor = isDark
        ? AppColors.surfaceLight
        : LightColors.surfaceLight;
    final categories = context.watch<AppState>().categories;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name field
          _buildEditSection(
            'Habit Name',
            [
              TextField(
                controller: _nameController,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter habit name',
                  hintStyle: TextStyle(color: textSecondary),
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => setState(() => _hasChanges = true),
              ),
            ],
            isDark,
            textPrimary,
          ),
          const SizedBox(height: 16),

          // Type & Evaluation (read-only as they affect core behavior)
          _buildEditSection(
            'Type & Evaluation',
            [
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

          // Priority Selection
          _buildEditSection(
            'Priority',
            [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PriorityLevel.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  return ChoiceChip(
                    label: Text(priority.label),
                    selected: isSelected,
                    selectedColor: _getPriorityColor(priority).withAlpha(100),
                    onSelected: (selected) {
                      setState(() {
                        _selectedPriority = priority;
                        _hasChanges = true;
                        _isEditMode = true;
                      });
                    },
                    avatar: Icon(
                      Icons.flag_rounded,
                      size: 16,
                      color: isSelected
                          ? _getPriorityColor(priority)
                          : textSecondary,
                    ),
                  );
                }).toList(),
              ),
            ],
            isDark,
            textPrimary,
          ),
          const SizedBox(height: 16),

          // Category Selection
          _buildEditSection(
            'Category',
            [
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _selectedCategoryId == category.id;
                    final color = Color(category.colorValue);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category.name),
                        selected: isSelected,
                        selectedColor: color.withAlpha(100),
                        avatar: Icon(
                          category.icon,
                          size: 16,
                          color: isSelected ? color : textSecondary,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryId = selected ? category.id : null;
                            _hasChanges = true;
                            _isEditMode = true;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
            isDark,
            textPrimary,
          ),
          const SizedBox(height: 16),

          // Scheduled Days
          _buildEditSection(
            'Scheduled Days',
            [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 1; i <= 7; i++)
                    _DayChip(
                      day: i,
                      isSelected: _selectedDays.contains(i),
                      onTap: () {
                        setState(() {
                          if (_selectedDays.contains(i)) {
                            _selectedDays.remove(i);
                          } else {
                            _selectedDays.add(i);
                          }
                          _selectedDays.sort();
                          _hasChanges = true;
                          _isEditMode = true;
                        });
                      },
                    ),
                ],
              ),
            ],
            isDark,
            textPrimary,
          ),
          const SizedBox(height: 16),

          // Description
          _buildEditSection(
            'Description',
            [
              TextField(
                controller: _descriptionController,
                style: TextStyle(color: textPrimary),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add a description (optional)',
                  hintStyle: TextStyle(color: textSecondary),
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => setState(() => _hasChanges = true),
              ),
            ],
            isDark,
            textPrimary,
          ),
          const SizedBox(height: 16),

          // Scripted Response (If-Then Plan)
          _buildEditSection(
            'Defense Plan (If-Then)',
            [
              Text(
                'When facing obstacles, what will you do?',
                style: TextStyle(color: textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _triggerResponseController,
                style: TextStyle(color: textPrimary),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText:
                      'e.g., "If I feel tired → I will do just 5 minutes"',
                  hintStyle: TextStyle(color: textSecondary),
                  filled: true,
                  fillColor: surfaceColor,
                  prefixIcon: Icon(
                    Icons.psychology_rounded,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => setState(() => _hasChanges = true),
              ),
            ],
            isDark,
            textPrimary,
          ),
          const SizedBox(height: 24),

          // Save Button (only show if changes made)
          if (_hasChanges)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _saveHabitChanges(habit),
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (_hasChanges) const SizedBox(height: 12),

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

  Future<void> _saveHabitChanges(Habit habit) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit name')),
      );
      return;
    }

    // Update habit properties
    habit.name = name;
    habit.description = _descriptionController.text.trim().isNotEmpty
        ? _descriptionController.text.trim()
        : null;
    habit.triggerResponse = _triggerResponseController.text.trim().isNotEmpty
        ? _triggerResponseController.text.trim()
        : null;
    habit.categoryId = _selectedCategoryId;
    habit.priorityLevel = _selectedPriority;
    habit.scheduledDays = _selectedDays;

    final appState = context.read<AppState>();
    await appState.updateHabit(habit);

    setState(() {
      _hasChanges = false;
      _isEditMode = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Habit updated successfully')),
      );
    }
  }

  Color _getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.none:
        return Colors.grey;
      case PriorityLevel.low:
        return Colors.blue;
      case PriorityLevel.medium:
        return Colors.orange;
      case PriorityLevel.high:
        return Colors.red;
    }
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
      final nav = Navigator.of(context);
      final appState = context.read<AppState>();
      await appState.deleteHabit(habit.id);
      nav.pop();
    }
  }
}

/// Day selection chip for schedule editing
class _DayChip extends StatelessWidget {
  final int day;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayChip({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  static const _dayNames = ['', 'M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _fullDayNames = [
    '',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: _fullDayNames[day],
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.surfaceLight : LightColors.surfaceLight),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : Colors.grey.withAlpha(100),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              _dayNames[day],
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? AppColors.textPrimary
                          : LightColors.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
