import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/theme.dart';
import '../../providers/app_state.dart';
import '../../models/task.dart';
import '../../models/habit.dart';
import '../../models/habit_enums.dart';
import '../../models/recurring_task.dart';
import '../../widgets/confetti.dart';
import 'add_task_sheet.dart';
import 'edit_task_sheet.dart';
import 'habit_creation_wizard.dart';
import 'recurring_task_wizard.dart';
import 'habit_detail_screen.dart';
import '../settings/settings_screen.dart';
import '../archive/archived_items_screen.dart';
import '../statistics/statistics_screen.dart';
import '../barriers/barriers_screen.dart';
import '../shop/shop_screen.dart';

/// Today Screen - Main daily view with horizontal date picker and item list
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late DateTime _selectedDate;
  late ScrollController _dateScrollController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ConfettiOverlayState> _confettiKey =
      GlobalKey<ConfettiOverlayState>();

  // Date range to show in horizontal picker (2 weeks back, 2 weeks forward)
  static const int _daysBack = 14;
  static const int _daysForward = 14;
  late List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _dateScrollController = ScrollController();
    _generateDates();

    // Scroll to today after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate(animated: false);
    });
  }

  void _generateDates() {
    final now = DateTime.now();
    _dates = List.generate(
      _daysBack + _daysForward + 1,
      (index) => DateTime(now.year, now.month, now.day - _daysBack + index),
    );
  }

  void _scrollToSelectedDate({bool animated = true}) {
    final index = _dates.indexWhere(
      (d) =>
          d.year == _selectedDate.year &&
          d.month == _selectedDate.month &&
          d.day == _selectedDate.day,
    );
    if (index != -1) {
      const itemWidth = 56.0; // Width of date item including margins
      final offset =
          (index * itemWidth) -
          (MediaQuery.of(context).size.width / 2) +
          (itemWidth / 2);
      if (animated) {
        _dateScrollController.animateTo(
          offset.clamp(0.0, _dateScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _dateScrollController.jumpTo(offset.clamp(0.0, double.infinity));
      }
    }
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;
    final bgColor = isDark ? AppColors.background : LightColors.background;

    return Consumer<AppState>(
      builder: (context, state, _) {
        // Get items for selected date
        final tasksForDate = _getTasksForDate(state, _selectedDate);
        final habitsForDate = _getHabitsForDate(state, _selectedDate);
        final recurringTasksForDate = _getRecurringTasksForDate(
          state,
          _selectedDate,
        );
        final allItems = <_TodayItem>[
          ...habitsForDate.map((h) => _TodayItem.habit(h)),
          ...recurringTasksForDate.map((rt) => _TodayItem.recurringTask(rt)),
          ...tasksForDate.map((t) => _TodayItem.task(t)),
        ];

        // Sort by priority (descending - highest at top), then by sortOrder
        allItems.sort((a, b) {
          // First sort by numeric priority (descending)
          final byPriority = b.numericPriority.compareTo(a.numericPriority);
          if (byPriority != 0) return byPriority;
          // Then by sortOrder
          final byOrder = a.sortOrder.compareTo(b.sortOrder);
          if (byOrder != 0) return byOrder;
          // Stable fallback for equal sortOrder.
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

        return ConfettiOverlay(
          key: _confettiKey,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: bgColor,
            drawer: _buildDrawer(context, state, isDark, textPrimary),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  _scaffoldKey.currentState?.openDrawer(),
                              child: Icon(
                                Icons.menu_rounded,
                                color: textPrimary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.search_rounded,
                                color: textPrimary,
                              ),
                              onPressed: () => _showSearch(context, state),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.calendar_month_rounded,
                                color: textPrimary,
                              ),
                              onPressed: () => _showDatePicker(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Horizontal Date Picker
                  SizedBox(
                    height: 64,
                    child: ListView.builder(
                      controller: _dateScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _dates.length,
                      itemBuilder: (context, index) {
                        final date = _dates[index];
                        final isSelected =
                            date.year == _selectedDate.year &&
                            date.month == _selectedDate.month &&
                            date.day == _selectedDate.day;
                        final isToday =
                            date.year == DateTime.now().year &&
                            date.month == DateTime.now().month &&
                            date.day == DateTime.now().day;

                        return _DateItem(
                          date: date,
                          isSelected: isSelected,
                          isToday: isToday,
                          onTap: () {
                            setState(() => _selectedDate = date);
                            _scrollToSelectedDate();
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Item List
                  Expanded(
                    child: allItems.isEmpty
                        ? _buildEmptyState(textSecondary)
                        : ReorderableListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            proxyDecorator: (child, index, animation) {
                              return AnimatedBuilder(
                                animation: animation,
                                builder: (context, child) {
                                  final elevationValue = Tween<double>(
                                    begin: 0,
                                    end: 6,
                                  ).animate(animation).value;
                                  return Material(
                                    elevation: elevationValue,
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    child: child,
                                  );
                                },
                                child: child,
                              );
                            },
                            onReorder: (oldIndex, newIndex) {
                              // Handle reordering
                              if (oldIndex < newIndex) {
                                newIndex -= 1;
                              }

                              final reordered = List<_TodayItem>.from(allItems);
                              final movedItem = reordered.removeAt(oldIndex);
                              reordered.insert(newIndex, movedItem);

                              // Persist new order with smart priority swapping
                              _persistReorder(
                                reordered,
                                state,
                                oldIndex,
                                newIndex,
                              );
                            },
                            itemCount: allItems.length,
                            itemBuilder: (context, index) {
                              final item = allItems[index];
                              final itemKey = item.isHabit
                                  ? 'h_${item.habit!.id}'
                                  : (item.isRecurringTask
                                        ? 'rt_${item.recurringTask!.id}'
                                        : 't_${item.task!.id}');

                              return Dismissible(
                                key: Key('dismiss_$itemKey'),
                                // Swipe right = priority adjustment
                                background: _buildSwipeBackground(
                                  color: Colors.orange,
                                  icon: Icons.flag_rounded,
                                  alignment: Alignment.centerLeft,
                                  label: 'Priority',
                                ),
                                // Swipe left = edit
                                secondaryBackground: _buildSwipeBackground(
                                  color: Colors.blue,
                                  icon: Icons.edit_rounded,
                                  alignment: Alignment.centerRight,
                                  label: 'Edit',
                                ),
                                confirmDismiss: (direction) async {
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    // Swipe right = show priority picker
                                    _showPriorityPicker(context, item, state);
                                    return false; // Don't dismiss
                                  } else {
                                    // Swipe left = show edit sheet (bottom sliding window)
                                    if (item.isHabit) {
                                      _showHabitEditSheet(
                                        context,
                                        item.habit!,
                                        state,
                                      );
                                    } else if (item.isRecurringTask) {
                                      _showRecurringTaskEditSheet(
                                        context,
                                        item.recurringTask!,
                                        state,
                                      );
                                    } else {
                                      EditTaskSheet.show(
                                        context,
                                        task: item.task!,
                                        onTaskUpdated: () => setState(() {}),
                                      );
                                    }
                                    return false; // Don't dismiss
                                  }
                                },
                                child: _TodayItemCard(
                                  item: item,
                                  selectedDate: _selectedDate,
                                  onTap: () => _handleItemTap(item, state),
                                  onLongPress: () =>
                                      _showItemOptions(context, item),
                                  index: index,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

            // Floating Action Button
            floatingActionButton: _AddItemFAB(
              onHabitTap: () => _showHabitCreation(context),
              onRecurringTaskTap: () => _showRecurringTaskCreation(context),
              onTaskTap: () => _showTaskCreation(context),
            ),
          ),
        );
      },
    );
  }

  /// Trigger confetti celebration
  void _celebrate() {
    _confettiKey.currentState?.celebrate();
  }

  Widget _buildDrawer(
    BuildContext context,
    AppState state,
    bool isDark,
    Color textPrimary,
  ) {
    final bgColor = isDark ? AppColors.surface : LightColors.surface;

    return Drawer(
      backgroundColor: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.primary),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withAlpha(50),
                    radius: 24,
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Centile',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Level ${state.userStats.level}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceLight
                    : LightColors.surfaceLight,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _DrawerStat(
                    label: 'Habits',
                    value:
                        '${state.habits.where((h) => h.isActive && !h.isArchived).length}',
                    icon: Icons.repeat_rounded,
                    color: Colors.green,
                  ),
                  _DrawerStat(
                    label: 'Tasks',
                    value: '${state.tasks.where((t) => !t.isCompleted).length}',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.primary,
                  ),
                  _DrawerStat(
                    label: 'Streak',
                    value: '${_calculateBestStreak(state)} days',
                    icon: Icons.local_fire_department_rounded,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.today_rounded,
                    label: 'Today',
                    isSelected: true,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Divider(),
                  _DrawerItem(
                    icon: Icons.shield_rounded,
                    label: 'Barriers',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BarriersScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.archive_rounded,
                    label: 'Archived Items',
                    onTap: () {
                      Navigator.pop(context);
                      ArchivedItemsScreen.show(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Statistics',
                    onTap: () {
                      Navigator.pop(context);
                      StatisticsScreen.show(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.storefront_rounded,
                    label: 'Shop',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ShopScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Settings
            _DrawerItem(
              icon: Icons.settings_rounded,
              label: 'Settings',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  int _calculateBestStreak(AppState state) {
    int bestStreak = 0;
    for (final habit in state.habits.where(
      (h) => h.isActive && !h.isArchived,
    )) {
      if (habit.currentStreak > bestStreak) {
        bestStreak = habit.currentStreak;
      }
    }
    return bestStreak;
  }

  void _showSearch(BuildContext context, AppState state) {
    showSearch(
      context: context,
      delegate: _TodaySearchDelegate(
        state: state,
        onItemSelected: (item) {
          if (item.isHabit) {
            HabitDetailScreen.show(context, habitId: item.habit!.id);
          } else if (item.isTask) {
            EditTaskSheet.show(
              context,
              task: item.task!,
              onTaskUpdated: () => setState(() {}),
            );
          }
        },
      ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 64,
            color: textColor.withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            'No items for this day',
            style: TextStyle(fontSize: 16, color: textColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a habit or task',
            style: TextStyle(fontSize: 14, color: textColor.withAlpha(150)),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _generateDates();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDate();
      });
    }
  }

  List<Task> _getTasksForDate(AppState state, DateTime date) {
    // Show tasks for date including completed ones (they display with strikethrough)
    return state.tasks
        .where((t) => t.isScheduledFor(date) && !t.isArchived)
        .toList();
  }

  List<Habit> _getHabitsForDate(AppState state, DateTime date) {
    return state.habits
        .where((h) => h.isActive && !h.isArchived && h.isScheduledFor(date))
        .toList();
  }

  List<RecurringTask> _getRecurringTasksForDate(AppState state, DateTime date) {
    return state.recurringTasks
        .where((rt) => !rt.isArchived && rt.isScheduledFor(date))
        .toList();
  }

  void _handleItemTap(_TodayItem item, AppState state) {
    if (item.isHabit) {
      final habit = item.habit!;

      // If scoring is enabled, show scoring dialog
      if (habit.scoringEnabled) {
        _showScoringDialog(context, habit, state);
      } else {
        // Toggle habit completion for selected date
        final isCompleted = habit.isCompletedFor(_selectedDate);
        state.logHabit(habit.id, completed: !isCompleted);
        // Celebrate on completion!
        if (!isCompleted) _celebrate();
      }
    } else if (item.isRecurringTask) {
      // Toggle recurring task completion for selected date
      final rt = item.recurringTask!;
      final isCompleted = rt.isCompletedFor(_selectedDate);
      state.logRecurringTaskCompletion(
        rt.id,
        date: _selectedDate,
        completed: !isCompleted,
      );
      // Celebrate on completion!
      if (!isCompleted) _celebrate();
    } else {
      // Toggle task completion
      final wasCompleted = item.task!.isCompleted;
      state.toggleTaskComplete(item.task!.id);
      // Celebrate on completion!
      if (!wasCompleted) _celebrate();
    }
  }

  void _showScoringDialog(BuildContext context, Habit habit, AppState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLog = habit.getLogFor(_selectedDate);
    double sliderValue = (currentLog?.score ?? 50).toDouble();
    bool isCompleted = currentLog?.completed ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surface : LightColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                habit.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'How close did you get to completing this habit?',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.textSecondary
                      : LightColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Score display
              Text(
                '${sliderValue.round()}%',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColorStatic(sliderValue.round()),
                ),
              ),
              const SizedBox(height: 16),

              // Slider
              Slider(
                value: sliderValue,
                min: 0,
                max: 100,
                divisions: 20,
                activeColor: _getScoreColorStatic(sliderValue.round()),
                onChanged: (value) {
                  setModalState(() {
                    sliderValue = value;
                    isCompleted = value >= 50;
                  });
                },
              ),

              // Quick buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ScoreQuickButton(
                    label: 'Failed',
                    score: 0,
                    currentScore: sliderValue.round(),
                    onTap: () => setModalState(() {
                      sliderValue = 0;
                      isCompleted = false;
                    }),
                  ),
                  _ScoreQuickButton(
                    label: '25%',
                    score: 25,
                    currentScore: sliderValue.round(),
                    onTap: () => setModalState(() {
                      sliderValue = 25;
                      isCompleted = false;
                    }),
                  ),
                  _ScoreQuickButton(
                    label: '50%',
                    score: 50,
                    currentScore: sliderValue.round(),
                    onTap: () => setModalState(() {
                      sliderValue = 50;
                      isCompleted = true;
                    }),
                  ),
                  _ScoreQuickButton(
                    label: '75%',
                    score: 75,
                    currentScore: sliderValue.round(),
                    onTap: () => setModalState(() {
                      sliderValue = 75;
                      isCompleted = true;
                    }),
                  ),
                  _ScoreQuickButton(
                    label: 'Done',
                    score: 100,
                    currentScore: sliderValue.round(),
                    onTap: () => setModalState(() {
                      sliderValue = 100;
                      isCompleted = true;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    state.logHabit(
                      habit.id,
                      completed: isCompleted,
                      score: sliderValue.round(),
                    );
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isCompleted ? 'Mark as Completed' : 'Mark as Failed',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColorStatic(int score) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
    String? label,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerRight && label != null) ...[
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
          ],
          Icon(icon, color: color, size: 28),
          if (alignment == Alignment.centerLeft && label != null) ...[
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  void _showPriorityPicker(
    BuildContext context,
    _TodayItem item,
    AppState state,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Get current numeric priority
    final currentPriority = item.numericPriority;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surface : LightColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _NumericPriorityPicker(
        currentPriority: currentPriority,
        onPriorityChanged: (newPriority) {
          Navigator.pop(ctx);
          _updateItemNumericPriority(item, newPriority, state);
        },
      ),
    );
  }

  void _updateItemNumericPriority(
    _TodayItem item,
    int priority,
    AppState state,
  ) {
    if (item.isHabit) {
      final habit = item.habit!;
      habit.priority = priority;
      state.updateHabit(habit);
    } else if (item.isRecurringTask) {
      final rt = item.recurringTask!;
      rt.priority = priority;
      state.updateRecurringTask(rt);
    } else {
      final task = item.task!;
      task.priority = priority;
      state.updateTask(task);
    }
    setState(() {});
  }

  Future<bool> _confirmDelete(BuildContext context, _TodayItem item) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete ${item.itemTypeLabel}?'),
            content: Text('Are you sure you want to delete "${item.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _deleteItem(_TodayItem item, AppState state) {
    if (item.isHabit) {
      state.deleteHabit(item.habit!.id);
    } else if (item.isRecurringTask) {
      state.deleteRecurringTask(item.recurringTask!.id);
    } else {
      state.deleteTask(item.task!.id);
    }
  }

  void _archiveItem(_TodayItem item, AppState state) {
    if (item.isHabit) {
      item.habit!.isArchived = true;
      state.updateHabit(item.habit!);
    } else if (item.isRecurringTask) {
      item.recurringTask!.isArchived = true;
      state.updateRecurringTask(item.recurringTask!);
    } else {
      item.task!.isArchived = true;
      state.updateTask(item.task!);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} archived'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            if (item.isHabit) {
              item.habit!.isArchived = false;
              state.updateHabit(item.habit!);
            } else if (item.isRecurringTask) {
              item.recurringTask!.isArchived = false;
              state.updateRecurringTask(item.recurringTask!);
            } else {
              item.task!.isArchived = false;
              state.updateTask(item.task!);
            }
          },
        ),
      ),
    );
    setState(() {});
  }

  void _showItemOptions(BuildContext context, _TodayItem item) {
    final state = context.read<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;

    // Get trigger response for display
    String? triggerResponse;
    if (item.isHabit && item.habit!.triggerResponse != null) {
      triggerResponse = item.habit!.triggerResponse;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surface : LightColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 32,
                height: 3,
                decoration: BoxDecoration(
                  color: textSecondary.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header: Item title
            Text(
              item.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),

            // If-Then text (if exists)
            if (triggerResponse != null && triggerResponse.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                triggerResponse,
                style: TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 16),

            // Grid of action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Reminders
                _ActionButton(
                  icon: Icons.notifications_rounded,
                  label: 'Reminders',
                  subtitle: _reminderCountLabel(item, _selectedDate),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showRemindersDialog(context, item);
                  },
                ),

                // Notes
                _ActionButton(
                  icon: Icons.note_rounded,
                  label: 'Notes',
                  subtitle: _notePreviewLabel(item, _selectedDate),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showNotesDialog(context, item, state);
                  },
                ),

                // Statistics (habits only)
                if (item.isHabit)
                  _ActionButton(
                    icon: Icons.bar_chart_rounded,
                    label: 'Statistics',
                    subtitle: Text('${item.habit!.currentStreak}d'),
                    onTap: () {
                      Navigator.pop(ctx);
                      HabitDetailScreen.show(context, habitId: item.habit!.id);
                    },
                  ),

                // Calendar (habits only)
                if (item.isHabit)
                  _ActionButton(
                    icon: Icons.calendar_today_rounded,
                    label: 'Calendar',
                    onTap: () {
                      Navigator.pop(ctx);
                      HabitDetailScreen.show(context, habitId: item.habit!.id);
                    },
                  ),

                // Edit
                _ActionButton(
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  onTap: () {
                    Navigator.pop(ctx);
                    if (item.isHabit) {
                      _showHabitEditSheet(context, item.habit!, state);
                    } else if (item.isRecurringTask) {
                      RecurringTaskWizard.show(
                        context,
                        existingTask: item.recurringTask!,
                        onComplete: () => setState(() {}),
                      );
                    } else {
                      EditTaskSheet.show(
                        context,
                        task: item.task!,
                        onTaskUpdated: () => setState(() {}),
                      );
                    }
                  },
                ),

                // Archive
                _ActionButton(
                  icon: Icons.archive_rounded,
                  label: 'Archive',
                  onTap: () {
                    Navigator.pop(ctx);
                    _archiveItem(item, state);
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Destructive action: Delete
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.red.withOpacity(0.18),
                  foregroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final confirmed = await _confirmDelete(context, item);
                  if (confirmed) {
                    _deleteItem(item, state);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.delete_rounded, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemindersDialog(BuildContext context, _TodayItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reminders = item.isHabit
        ? (item.habit!.reminderTimes ?? <String>[])
        : (item.isRecurringTask
              ? item.recurringTask!.reminderTimes
              : item.task!.reminderTimes);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surface : LightColors.surface,
        title: Text('${item.itemTypeLabel} Reminders'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reminders.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No reminders set for this item.'),
              )
            else
              ...reminders.map(
                (time) => ListTile(
                  leading: const Icon(Icons.access_time_rounded),
                  title: Text(time),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Edit reminders via Edit on the item.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textMuted : LightColors.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHabitEditSheet(BuildContext context, Habit habit, AppState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surface : LightColors.surface;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;

    final nameController = TextEditingController(text: habit.name);
    final triggerController = TextEditingController(
      text: habit.triggerResponse ?? '',
    );
    final descController = TextEditingController(text: habit.description ?? '');
    String? selectedCategoryId = habit.categoryId;
    List<int> selectedDays = List<int>.from(habit.scheduledDays);
    HabitFrequencyType frequencyType =
        habit.frequencyType ?? HabitFrequencyType.everyday;
    int repeatInterval = habit.repeatInterval ?? 2;
    int daysPerPeriod = habit.daysPerPeriod ?? 3;
    List<DateTime> specificDates = List<DateTime>.from(
      habit.specificDates ?? [],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final categories = state.categories;
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              child: Padding(
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
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Habit',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: textSecondary),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Name field
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Habit Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // If-Then (trigger response)
                    TextField(
                      controller: triggerController,
                      style: TextStyle(color: textPrimary),
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'If-Then Plan',
                        hintText:
                            'e.g., "If I feel tired → I will do just 5 minutes"',
                        hintStyle: TextStyle(color: textSecondary),
                        prefixIcon: Icon(
                          Icons.psychology_rounded,
                          color: AppColors.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category selection
                    Text(
                      'Category',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            final isSelected = selectedCategoryId == null;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: const Text('None'),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setModalState(
                                    () => selectedCategoryId = null,
                                  );
                                },
                              ),
                            );
                          }
                          final category = categories[index - 1];
                          final isSelected = selectedCategoryId == category.id;
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
                                setModalState(
                                  () => selectedCategoryId = selected
                                      ? category.id
                                      : null,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Frequency Type
                    Text(
                      'Frequency',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: textSecondary.withAlpha(100)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<HabitFrequencyType>(
                          isExpanded: true,
                          value: frequencyType,
                          dropdownColor: surfaceColor,
                          items: HabitFrequencyType.values
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type.label,
                                    style: TextStyle(color: textPrimary),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                frequencyType = val;
                                if (val == HabitFrequencyType.everyday) {
                                  selectedDays = [1, 2, 3, 4, 5, 6, 7];
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Frequency-specific options
                    if (frequencyType == HabitFrequencyType.specificDays) ...[
                      Text(
                        'Select days:',
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var i = 1; i <= 7; i++)
                            GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  if (selectedDays.contains(i)) {
                                    if (selectedDays.length > 1)
                                      selectedDays.remove(i);
                                  } else {
                                    selectedDays.add(i);
                                  }
                                  selectedDays.sort();
                                });
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: selectedDays.contains(i)
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedDays.contains(i)
                                        ? AppColors.primary
                                        : textSecondary,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i - 1],
                                    style: TextStyle(
                                      color: selectedDays.contains(i)
                                          ? Colors.white
                                          : textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],

                    if (frequencyType == HabitFrequencyType.repeatEvery) ...[
                      Row(
                        children: [
                          Text('Every ', style: TextStyle(color: textPrimary)),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: textPrimary),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              controller: TextEditingController(
                                text: '$repeatInterval',
                              ),
                              onChanged: (val) {
                                final parsed = int.tryParse(val);
                                if (parsed != null && parsed >= 2) {
                                  repeatInterval = parsed;
                                }
                              },
                            ),
                          ),
                          Text(' days', style: TextStyle(color: textPrimary)),
                        ],
                      ),
                    ],

                    if (frequencyType ==
                        HabitFrequencyType.someDaysPerPeriod) ...[
                      Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: textPrimary),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              controller: TextEditingController(
                                text: '$daysPerPeriod',
                              ),
                              onChanged: (val) {
                                final parsed = int.tryParse(val);
                                if (parsed != null &&
                                    parsed >= 1 &&
                                    parsed <= 7) {
                                  daysPerPeriod = parsed;
                                }
                              },
                            ),
                          ),
                          Text(
                            ' days per week',
                            style: TextStyle(color: textPrimary),
                          ),
                        ],
                      ),
                    ],

                    if (frequencyType ==
                        HabitFrequencyType.specificDatesOfYear) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Selected dates:',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add'),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                final newDate = DateTime(
                                  2000,
                                  picked.month,
                                  picked.day,
                                );
                                if (!specificDates.any(
                                  (d) =>
                                      d.month == newDate.month &&
                                      d.day == newDate.day,
                                )) {
                                  setModalState(
                                    () => specificDates.add(newDate),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      if (specificDates.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: specificDates.map((date) {
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
                            return Chip(
                              label: Text(
                                '${months[date.month - 1]} ${date.day}',
                              ),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => setModalState(
                                () => specificDates.remove(date),
                              ),
                            );
                          }).toList(),
                        ),
                    ],

                    const SizedBox(height: 16),

                    // Description
                    TextField(
                      controller: descController,
                      style: TextStyle(color: textPrimary),
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a habit name'),
                              ),
                            );
                            return;
                          }

                          habit.name = name;
                          habit.triggerResponse =
                              triggerController.text.trim().isNotEmpty
                              ? triggerController.text.trim()
                              : null;
                          habit.description =
                              descController.text.trim().isNotEmpty
                              ? descController.text.trim()
                              : null;
                          habit.categoryId = selectedCategoryId;
                          habit.frequencyType = frequencyType;
                          habit.scheduledDays = selectedDays;
                          habit.repeatInterval =
                              frequencyType == HabitFrequencyType.repeatEvery
                              ? repeatInterval
                              : null;
                          habit.daysPerPeriod =
                              frequencyType ==
                                  HabitFrequencyType.someDaysPerPeriod
                              ? daysPerPeriod
                              : null;
                          habit.specificDates =
                              frequencyType ==
                                  HabitFrequencyType.specificDatesOfYear
                              ? specificDates
                              : null;

                          state.updateHabit(habit);
                          Navigator.pop(ctx);
                          setState(() {});

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Habit updated')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRecurringTaskEditSheet(
    BuildContext context,
    RecurringTask task,
    AppState state,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surface : LightColors.surface;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;

    final nameController = TextEditingController(text: task.name);
    final descController = TextEditingController(text: task.description ?? '');
    String selectedCategoryId = task.categoryId;
    List<int> selectedDays = List<int>.from(task.scheduledDays);
    HabitFrequencyType frequencyType = task.frequencyType;
    int repeatInterval = task.repeatInterval ?? 2;
    int daysPerPeriod = task.daysPerPeriod ?? 3;
    List<DateTime> specificDates = List<DateTime>.from(
      task.specificDates ?? [],
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) => Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: textSecondary.withAlpha(80),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    children: [
                      Icon(Icons.repeat_rounded, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Edit Recurring Task',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: Icon(Icons.close_rounded, color: textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Name field
                  Text(
                    'Name',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Task name',
                      hintStyle: TextStyle(color: textSecondary.withAlpha(128)),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.surfaceLight
                          : LightColors.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descController,
                    style: TextStyle(color: textPrimary),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Optional description',
                      hintStyle: TextStyle(color: textSecondary.withAlpha(128)),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.surfaceLight
                          : LightColors.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category dropdown
                  Text(
                    'Category',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceLight
                          : LightColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCategoryId,
                        dropdownColor: surfaceColor,
                        style: TextStyle(color: textPrimary),
                        items: state.categories
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat.id,
                                child: Text(cat.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null)
                            setSheetState(() => selectedCategoryId = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Frequency type
                  Text(
                    'Frequency',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceLight
                          : LightColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<HabitFrequencyType>(
                        isExpanded: true,
                        value: frequencyType,
                        dropdownColor: surfaceColor,
                        style: TextStyle(color: textPrimary),
                        items: HabitFrequencyType.values
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type.label,
                                  style: TextStyle(color: textPrimary),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null)
                            setSheetState(() => frequencyType = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Frequency-specific options
                  if (frequencyType == HabitFrequencyType.specificDays) ...[
                    Text(
                      'Days',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: List.generate(7, (i) {
                        final day = i + 1;
                        final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final isSelected = selectedDays.contains(day);
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              if (isSelected && selectedDays.length > 1) {
                                selectedDays.remove(day);
                              } else if (!isSelected) {
                                selectedDays.add(day);
                              }
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withAlpha(30)
                                  : (isDark
                                        ? AppColors.surfaceLight
                                        : LightColors.surfaceLight),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark
                                          ? AppColors.glassBorder
                                          : LightColors.glassBorder),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              dayNames[i],
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],

                  if (frequencyType == HabitFrequencyType.repeatEvery) ...[
                    Row(
                      children: [
                        Text('Every ', style: TextStyle(color: textPrimary)),
                        SizedBox(
                          width: 60,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textPrimary),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            controller: TextEditingController(
                              text: '$repeatInterval',
                            ),
                            onChanged: (val) {
                              final parsed = int.tryParse(val);
                              if (parsed != null && parsed >= 1) {
                                repeatInterval = parsed;
                              }
                            },
                          ),
                        ),
                        Text(' days', style: TextStyle(color: textPrimary)),
                      ],
                    ),
                  ],

                  if (frequencyType ==
                      HabitFrequencyType.someDaysPerPeriod) ...[
                    Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textPrimary),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            controller: TextEditingController(
                              text: '$daysPerPeriod',
                            ),
                            onChanged: (val) {
                              final parsed = int.tryParse(val);
                              if (parsed != null &&
                                  parsed >= 1 &&
                                  parsed <= 7) {
                                daysPerPeriod = parsed;
                              }
                            },
                          ),
                        ),
                        Text(
                          ' days per week',
                          style: TextStyle(color: textPrimary),
                        ),
                      ],
                    ),
                  ],

                  if (frequencyType ==
                      HabitFrequencyType.specificDatesOfYear) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Selected dates:',
                          style: TextStyle(color: textSecondary, fontSize: 12),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add'),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              final newDate = DateTime(
                                2000,
                                picked.month,
                                picked.day,
                              );
                              if (!specificDates.any(
                                (d) =>
                                    d.month == newDate.month &&
                                    d.day == newDate.day,
                              )) {
                                setSheetState(() => specificDates.add(newDate));
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    if (specificDates.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: specificDates.map((d) {
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
                          return Chip(
                            label: Text('${months[d.month - 1]} ${d.day}'),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () =>
                                setSheetState(() => specificDates.remove(d)),
                          );
                        }).toList(),
                      ),
                  ],

                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a name'),
                            ),
                          );
                          return;
                        }

                        task.name = name;
                        task.description = descController.text.trim().isNotEmpty
                            ? descController.text.trim()
                            : null;
                        task.categoryId = selectedCategoryId;
                        task.frequencyType = frequencyType;
                        task.scheduledDays = selectedDays;
                        task.repeatInterval =
                            frequencyType == HabitFrequencyType.repeatEvery
                            ? repeatInterval
                            : null;
                        task.daysPerPeriod =
                            frequencyType ==
                                HabitFrequencyType.someDaysPerPeriod
                            ? daysPerPeriod
                            : null;
                        task.specificDates =
                            frequencyType ==
                                HabitFrequencyType.specificDatesOfYear
                            ? specificDates
                            : null;

                        state.updateRecurringTask(task);
                        Navigator.pop(ctx);
                        setState(() {});

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Recurring task updated'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showNotesDialog(BuildContext context, _TodayItem item, AppState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentNote = item.isHabit
        ? (item.habit!.getLogFor(_selectedDate)?.note ?? '')
        : (item.isRecurringTask
              ? (item.recurringTask!.getLogFor(_selectedDate)?.note ?? '')
              : (item.task!.note ?? ''));
    final controller = TextEditingController(text: currentNote);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surface : LightColors.surface,
        title: const Text('Notes'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Add a note for today...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final note = controller.text.trim().isNotEmpty
                  ? controller.text.trim()
                  : null;

              if (item.isHabit) {
                final habit = item.habit!;
                final isCompleted = habit.isCompletedFor(_selectedDate);
                state.logHabit(habit.id, completed: isCompleted, note: note);
              } else if (item.isRecurringTask) {
                final rt = item.recurringTask!;
                final isCompleted = rt.isCompletedFor(_selectedDate);
                state.logRecurringTaskCompletion(
                  rt.id,
                  date: _selectedDate,
                  completed: isCompleted,
                  note: note,
                );
              } else {
                final task = item.task!;
                task.note = note;
                state.updateTask(task);
              }

              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _reminderCountLabel(_TodayItem item, DateTime selectedDate) {
    final reminders = item.isHabit
        ? (item.habit!.reminderTimes ?? <String>[])
        : (item.isRecurringTask
              ? item.recurringTask!.reminderTimes
              : item.task!.reminderTimes);

    if (reminders.isEmpty) return const Text('No reminders set');
    return Text('${reminders.length} reminder(s) set');
  }

  Widget _notePreviewLabel(_TodayItem item, DateTime selectedDate) {
    final note = item.isHabit
        ? (item.habit!.getLogFor(selectedDate)?.note)
        : (item.isRecurringTask
              ? (item.recurringTask!.getLogFor(selectedDate)?.note)
              : item.task!.note);

    if (note == null || note.trim().isEmpty) return const Text('Add a note');
    return Text(note, maxLines: 1, overflow: TextOverflow.ellipsis);
  }

  Future<void> _persistReorder(
    List<_TodayItem> reordered,
    AppState state,
    int oldIndex,
    int newIndex,
  ) async {
    // Smart priority handling:
    // - SWAP priorities when they're different (efficient, preserves structure)
    // - Only ADD/SUBTRACT when priorities are equal (to create differentiation)

    final movedItem = reordered[newIndex];
    final movedUp =
        newIndex < oldIndex; // Item was dragged upward (higher priority)

    // Get the item that was displaced (the one we're swapping with)
    // If moved up, it's the item now below us (newIndex + 1 in original list, but we need the one that was at newIndex)
    // If moved down, it's the item now above us
    final displacedIndex = movedUp ? newIndex + 1 : newIndex - 1;

    if (displacedIndex >= 0 && displacedIndex < reordered.length) {
      final displacedItem = reordered[displacedIndex];
      final movedPriority = movedItem.numericPriority;
      final displacedPriority = displacedItem.numericPriority;

      if (movedPriority != displacedPriority) {
        // SWAP: Priorities are different, just exchange them
        _setItemPriority(movedItem, displacedPriority);
        _setItemPriority(displacedItem, movedPriority);
      } else {
        // ADJUST: Priorities are equal, need to differentiate
        if (movedUp) {
          // Moving up = should get higher priority
          _setItemPriority(movedItem, (movedPriority + 1).clamp(-20, 20));
        } else {
          // Moving down = should get lower priority
          _setItemPriority(movedItem, (movedPriority - 1).clamp(-20, 20));
        }
      }
    }

    // Update sortOrder for all items to reflect visual order
    for (var i = 0; i < reordered.length; i++) {
      final item = reordered[i];
      if (item.isHabit) {
        item.habit!.sortOrder = i;
      } else if (item.isRecurringTask) {
        item.recurringTask!.sortOrder = i;
      } else {
        item.task!.sortOrder = i;
      }
    }

    // Trigger immediate UI refresh.
    setState(() {});

    // Persist only the items that changed (moved item and displaced item)
    final futures = <Future<void>>[];
    final indicesToSave = {
      newIndex,
      displacedIndex,
    }.where((i) => i >= 0 && i < reordered.length);
    for (final idx in indicesToSave) {
      final item = reordered[idx];
      if (item.isHabit) {
        futures.add(state.updateHabit(item.habit!));
      } else if (item.isRecurringTask) {
        futures.add(state.updateRecurringTask(item.recurringTask!));
      } else {
        futures.add(state.updateTask(item.task!));
      }
    }
    await Future.wait(futures);
  }

  /// Helper to set priority on any item type
  void _setItemPriority(_TodayItem item, int priority) {
    if (item.isHabit) {
      item.habit!.priority = priority;
    } else if (item.isRecurringTask) {
      item.recurringTask!.priority = priority;
    } else {
      item.task!.priority = priority;
    }
  }

  void _showHabitCreation(BuildContext context) {
    HabitCreationWizard.show(context, onComplete: () => setState(() {}));
  }

  void _showRecurringTaskCreation(BuildContext context) {
    RecurringTaskWizard.show(context, onComplete: () => setState(() {}));
  }

  void _showTaskCreation(BuildContext context) {
    AddTaskSheet.show(
      context,
      initialDate: _selectedDate,
      onTaskAdded: () {
        setState(() {}); // Refresh the list
      },
    );
  }
}

/// Data class for items in the Today list
class _TodayItem {
  final Habit? habit;
  final Task? task;
  final RecurringTask? recurringTask;

  const _TodayItem._({this.habit, this.task, this.recurringTask});

  factory _TodayItem.habit(Habit h) => _TodayItem._(habit: h);
  factory _TodayItem.task(Task t) => _TodayItem._(task: t);
  factory _TodayItem.recurringTask(RecurringTask rt) =>
      _TodayItem._(recurringTask: rt);

  bool get isHabit => habit != null;
  bool get isTask => task != null;
  bool get isRecurringTask => recurringTask != null;

  int get sortOrder => isHabit
      ? habit!.sortOrder
      : (isRecurringTask ? recurringTask!.sortOrder : task!.sortOrder);

  /// Get numeric priority for sorting (-20 to 20, higher = more important)
  int get numericPriority => isHabit
      ? habit!.priority
      : (isRecurringTask ? recurringTask!.priority : task!.priority);

  String get name => isHabit
      ? habit!.name
      : (isRecurringTask ? recurringTask!.name : task!.title);

  String get itemTypeLabel {
    if (isHabit) return 'Habit';
    if (isRecurringTask) return 'Recurring';
    return 'Task';
  }
}

/// Horizontal date picker item
class _DateItem extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const _DateItem({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;

    final dayAbbrev = DateFormat('E').format(date).substring(0, 3);
    final dayNum = date.day.toString();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayAbbrev,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isToday ? AppColors.primary : textSecondary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNum,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected || isToday
                    ? FontWeight.bold
                    : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isToday ? AppColors.primary : textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Today item card (habit or task)
class _TodayItemCard extends StatelessWidget {
  final _TodayItem item;
  final DateTime selectedDate;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final int index; // Index for reordering

  const _TodayItemCard({
    required this.item,
    required this.selectedDate,
    required this.onTap,
    required this.onLongPress,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;

    // Get category for ribbon
    final appState = context.read<AppState>();
    String? categoryId;
    if (item.isHabit) {
      categoryId = item.habit!.categoryId;
    } else if (item.isTask) {
      categoryId = item.task!.categoryId;
    } else if (item.isRecurringTask) {
      categoryId = item.recurringTask!.categoryId;
    }
    final category = categoryId != null
        ? appState.getCategoryById(categoryId)
        : null;

    // Determine completion state for selected date
    bool isCompleted = false;
    int? score;
    if (item.isHabit) {
      final log = item.habit!.getLogFor(selectedDate);
      isCompleted = log?.completed ?? false;
      score = log?.score;
    } else if (item.isRecurringTask) {
      isCompleted = item.recurringTask!.isCompletedFor(selectedDate);
    } else {
      isCompleted = item.task!.isCompleted;
    }

    // Get numeric priority for display
    final numericPriority = item.numericPriority;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: (isDark ? AppColors.glassBorder : LightColors.glassBorder)
                  .withAlpha(40),
              width: 0.5,
            ),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Category ribbon (left edge)
              if (category != null)
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: category.color,
                    boxShadow: [
                      BoxShadow(
                        color: category.color.withAlpha(60),
                        blurRadius: 4,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                ),
              // Main content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: category != null ? 6 : 8,
                    top: 4,
                    right: 8,
                    bottom: 4,
                  ),
                  child: Row(
                    children: [
                      // Category icon with priority indicator - DRAG HANDLE
                      ReorderableDragStartListener(
                        index: index,
                        child: Stack(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _getItemColor().withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                _getItemIcon(),
                                color: _getItemColor(),
                                size: 14,
                              ),
                            ),
                            if (numericPriority != 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _getNumericPriorityColor(
                                      numericPriority,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isCompleted
                                    ? textSecondary
                                    : textPrimary,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            // If-Then trigger for habits
                            if (item.isHabit &&
                                item.habit!.triggerResponse != null &&
                                item.habit!.triggerResponse!.isNotEmpty)
                              Text(
                                item.habit!.triggerResponse!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getItemColor().withAlpha(20),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    item.itemTypeLabel,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: _getItemColor(),
                                    ),
                                  ),
                                ),
                                // Show score if scoring enabled and has score
                                if (item.isHabit &&
                                    item.habit!.scoringEnabled &&
                                    score != null) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getScoreColor(
                                        score,
                                      ).withAlpha(20),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      '$score%',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: _getScoreColor(score),
                                      ),
                                    ),
                                  ),
                                ] else if (item.isHabit &&
                                    item.habit!.effectiveEvaluationType ==
                                        HabitEvaluationType.numeric) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    'Current: ${item.habit!.getCurrentValueFor(selectedDate)}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Completion indicator
                      _buildCompletionIndicator(isCompleted, score),
                    ],
                  ),
                ),
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

  IconData _getItemIcon() {
    if (item.isHabit) {
      switch (item.habit!.type) {
        case HabitType.build:
          return Icons.add_circle_outline_rounded;
        case HabitType.quit:
          return Icons.remove_circle_outline_rounded;
        case HabitType.timed:
          return Icons.timer_outlined;
      }
    }
    if (item.isRecurringTask) {
      return Icons.repeat_rounded;
    }
    return Icons.check_circle_outline_rounded;
  }

  Color _getItemColor() {
    if (item.isHabit) {
      switch (item.habit!.type) {
        case HabitType.build:
          return Colors.green;
        case HabitType.quit:
          return Colors.red;
        case HabitType.timed:
          return Colors.blue;
      }
    }
    if (item.isRecurringTask) {
      return Colors.purple;
    }
    return AppColors.primary;
  }

  Color _getNumericPriorityColor(int priority) {
    if (priority > 10) return Colors.red;
    if (priority > 5) return Colors.orange;
    if (priority > 0) return Colors.blue;
    if (priority == 0) return Colors.grey;
    if (priority > -10) return Colors.blueGrey;
    return Colors.grey.shade600;
  }

  Widget _buildCompletionIndicator(bool isCompleted, int? score) {
    // If scoring enabled and has score, show score-based indicator
    if (item.isHabit && item.habit!.scoringEnabled && score != null) {
      final color = _getScoreColor(score);
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.5),
        ),
        child: Center(
          child: Text(
            '$score',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      );
    }

    if (isCompleted) {
      return Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
      );
    }

    // Show different indicators based on item type
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey, width: 1.5),
      ),
    );
  }
}

/// Floating Action Button with slide-up menu
class _AddItemFAB extends StatefulWidget {
  final VoidCallback onHabitTap;
  final VoidCallback onRecurringTaskTap;
  final VoidCallback onTaskTap;

  const _AddItemFAB({
    required this.onHabitTap,
    required this.onRecurringTaskTap,
    required this.onTaskTap,
  });

  @override
  State<_AddItemFAB> createState() => _AddItemFABState();
}

class _AddItemFABState extends State<_AddItemFAB>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Menu options (shown when expanded)
        if (_isExpanded) ...[
          _FABMenuItem(
            label: 'Task',
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.primary,
            onTap: () {
              _toggleExpanded();
              widget.onTaskTap();
            },
          ).animate().fadeIn(duration: 150.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 8),
          _FABMenuItem(
                label: 'Recurring Task',
                icon: Icons.repeat_rounded,
                color: Colors.orange,
                onTap: () {
                  _toggleExpanded();
                  widget.onRecurringTaskTap();
                },
              )
              .animate()
              .fadeIn(delay: 50.ms, duration: 150.ms)
              .slideY(begin: 0.3, end: 0),
          const SizedBox(height: 8),
          _FABMenuItem(
                label: 'Habit',
                icon: Icons.shield_rounded,
                color: Colors.green,
                onTap: () {
                  _toggleExpanded();
                  widget.onHabitTap();
                },
              )
              .animate()
              .fadeIn(delay: 100.ms, duration: 150.ms)
              .slideY(begin: 0.3, end: 0),
          const SizedBox(height: 16),
        ],

        // Main FAB
        FloatingActionButton(
          onPressed: _toggleExpanded,
          backgroundColor: AppColors.primary,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0, // 45 degree rotation
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }
}

/// FAB menu item
class _FABMenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FABMenuItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surface
                  : LightColors.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(100),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Quick score selection button for scoring dialog
class _ScoreQuickButton extends StatelessWidget {
  final String label;
  final int score;
  final int currentScore;
  final VoidCallback onTap;

  const _ScoreQuickButton({
    required this.label,
    required this.score,
    required this.currentScore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentScore == score;
    final color = _getScoreColor(score);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(30),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: isSelected ? 2 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : color,
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
}

/// Drawer stat widget
class _DrawerStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DrawerStat({
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
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: textSecondary)),
      ],
    );
  }
}

/// Drawer menu item
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;

    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : textPrimary),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.primary : textPrimary,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withAlpha(20),
      onTap: onTap,
    );
  }
}

/// Search delegate for Today screen with filters
class _TodaySearchDelegate extends SearchDelegate<_TodayItem?> {
  final AppState state;
  final Function(_TodayItem) onItemSelected;

  // Filter state
  String? _selectedCategoryId;
  String? _selectedType; // 'habit', 'task', 'recurring'
  PriorityLevel? _selectedPriority;
  String? _selectedStatus; // 'active', 'completed', 'archived'

  _TodaySearchDelegate({required this.state, required this.onItemSelected});

  @override
  String get searchFieldLabel => 'Search habits and tasks...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.surface : LightColors.surface,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textPrimary : LightColors.textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: isDark ? AppColors.textSecondary : LightColors.textSecondary,
        ),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded),
          onPressed: () => query = '',
        ),
      IconButton(
        icon: Icon(
          Icons.filter_list_rounded,
          color: _hasActiveFilters ? AppColors.primary : null,
        ),
        onPressed: () => _showFilterSheet(context),
      ),
    ];
  }

  bool get _hasActiveFilters =>
      _selectedCategoryId != null ||
      _selectedType != null ||
      _selectedPriority != null ||
      _selectedStatus != null;

  void _showFilterSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final bgColor = isDark ? AppColors.surface : LightColors.surface;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setSheetState(() {
                        _selectedCategoryId = null;
                        _selectedType = null;
                        _selectedPriority = null;
                        _selectedStatus = null;
                      });
                    },
                    child: const Text('Clear all'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Type filter
              Text(
                'Type',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Habits'),
                    selected: _selectedType == 'habit',
                    onSelected: (sel) => setSheetState(
                      () => _selectedType = sel ? 'habit' : null,
                    ),
                    selectedColor: AppColors.primary.withAlpha(50),
                  ),
                  FilterChip(
                    label: const Text('Tasks'),
                    selected: _selectedType == 'task',
                    onSelected: (sel) => setSheetState(
                      () => _selectedType = sel ? 'task' : null,
                    ),
                    selectedColor: AppColors.primary.withAlpha(50),
                  ),
                  FilterChip(
                    label: const Text('Recurring'),
                    selected: _selectedType == 'recurring',
                    onSelected: (sel) => setSheetState(
                      () => _selectedType = sel ? 'recurring' : null,
                    ),
                    selectedColor: AppColors.primary.withAlpha(50),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Priority filter
              Text(
                'Priority',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: PriorityLevel.values
                    .map(
                      (p) => FilterChip(
                        label: Text(p.label),
                        selected: _selectedPriority == p,
                        onSelected: (sel) => setSheetState(
                          () => _selectedPriority = sel ? p : null,
                        ),
                        selectedColor: AppColors.primary.withAlpha(50),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),

              // Status filter
              Text(
                'Status',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Active'),
                    selected: _selectedStatus == 'active',
                    onSelected: (sel) => setSheetState(
                      () => _selectedStatus = sel ? 'active' : null,
                    ),
                    selectedColor: AppColors.primary.withAlpha(50),
                  ),
                  FilterChip(
                    label: const Text('Completed'),
                    selected: _selectedStatus == 'completed',
                    onSelected: (sel) => setSheetState(
                      () => _selectedStatus = sel ? 'completed' : null,
                    ),
                    selectedColor: AppColors.primary.withAlpha(50),
                  ),
                  FilterChip(
                    label: const Text('Archived'),
                    selected: _selectedStatus == 'archived',
                    onSelected: (sel) => setSheetState(
                      () => _selectedStatus = sel ? 'archived' : null,
                    ),
                    selectedColor: AppColors.primary.withAlpha(50),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category filter
              Text(
                'Category',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategoryId == null,
                      onSelected: (_) =>
                          setSheetState(() => _selectedCategoryId = null),
                      selectedColor: AppColors.primary.withAlpha(50),
                    ),
                    const SizedBox(width: 8),
                    ...state.categories.map(
                      (cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat.name),
                          selected: _selectedCategoryId == cat.id,
                          onSelected: (sel) => setSheetState(
                            () => _selectedCategoryId = sel ? cat.id : null,
                          ),
                          selectedColor: AppColors.primary.withAlpha(50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    // Trigger rebuild
                    showResults(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;
    final bgColor = isDark ? AppColors.background : LightColors.background;

    if (query.isEmpty && !_hasActiveFilters) {
      return Container(
        color: bgColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_rounded,
                size: 64,
                color: textSecondary.withAlpha(100),
              ),
              const SizedBox(height: 16),
              Text(
                'Search for habits or tasks',
                style: TextStyle(color: textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                'Or use filters to browse',
                style: TextStyle(color: textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    final lowerQuery = query.toLowerCase();

    // Search habits with filters
    var matchingHabits = state.habits
        .where((h) {
          if (query.isNotEmpty && !h.name.toLowerCase().contains(lowerQuery))
            return false;
          if (_selectedType != null && _selectedType != 'habit') return false;
          if (_selectedCategoryId != null &&
              h.categoryId != _selectedCategoryId)
            return false;
          if (_selectedPriority != null && h.priorityLevel != _selectedPriority)
            return false;
          if (_selectedStatus == 'active' && h.isArchived) return false;
          if (_selectedStatus == 'archived' && !h.isArchived) return false;
          return true;
        })
        .map((h) => _TodayItem.habit(h))
        .toList();

    // Search tasks with filters
    var matchingTasks = state.tasks
        .where((t) {
          if (query.isNotEmpty && !t.title.toLowerCase().contains(lowerQuery))
            return false;
          if (_selectedType != null && _selectedType != 'task') return false;
          if (_selectedCategoryId != null &&
              t.categoryId != _selectedCategoryId)
            return false;
          if (_selectedPriority != null && t.priorityLevel != _selectedPriority)
            return false;
          if (_selectedStatus == 'active' && (t.isCompleted || t.isArchived))
            return false;
          if (_selectedStatus == 'completed' && !t.isCompleted) return false;
          if (_selectedStatus == 'archived' && !t.isArchived) return false;
          return true;
        })
        .map((t) => _TodayItem.task(t))
        .toList();

    // Search recurring tasks with filters
    var matchingRecurring = state.recurringTasks
        .where((rt) {
          if (query.isNotEmpty && !rt.name.toLowerCase().contains(lowerQuery))
            return false;
          if (_selectedType != null && _selectedType != 'recurring')
            return false;
          if (_selectedCategoryId != null &&
              rt.categoryId != _selectedCategoryId)
            return false;
          if (_selectedPriority != null &&
              rt.priorityLevel != _selectedPriority)
            return false;
          if (_selectedStatus == 'active' && rt.isArchived) return false;
          if (_selectedStatus == 'archived' && !rt.isArchived) return false;
          return true;
        })
        .map((rt) => _TodayItem.recurringTask(rt))
        .toList();

    final allResults = [
      ...matchingHabits,
      ...matchingRecurring,
      ...matchingTasks,
    ];

    if (allResults.isEmpty) {
      return Container(
        color: bgColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: textSecondary.withAlpha(100),
              ),
              const SizedBox(height: 16),
              Text(
                query.isNotEmpty
                    ? 'No results for "$query"'
                    : 'No items match filters',
                style: TextStyle(color: textSecondary),
              ),
              if (_hasActiveFilters) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    _selectedCategoryId = null;
                    _selectedType = null;
                    _selectedPriority = null;
                    _selectedStatus = null;
                    showResults(context);
                  },
                  child: const Text('Clear filters'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Container(
      color: bgColor,
      child: Column(
        children: [
          // Active filters bar
          if (_hasActiveFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark ? AppColors.surfaceLight : LightColors.surfaceLight,
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 16, color: textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_selectedType != null)
                            _buildFilterTag(_selectedType!, () {
                              _selectedType = null;
                              showResults(context);
                            }),
                          if (_selectedPriority != null)
                            _buildFilterTag(_selectedPriority!.label, () {
                              _selectedPriority = null;
                              showResults(context);
                            }),
                          if (_selectedStatus != null)
                            _buildFilterTag(_selectedStatus!, () {
                              _selectedStatus = null;
                              showResults(context);
                            }),
                          if (_selectedCategoryId != null)
                            _buildFilterTag(
                              state.categories
                                  .firstWhere(
                                    (c) => c.id == _selectedCategoryId,
                                    orElse: () => state.categories.first,
                                  )
                                  .name,
                              () {
                                _selectedCategoryId = null;
                                showResults(context);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${allResults.length} result${allResults.length == 1 ? '' : 's'}',
                style: TextStyle(color: textSecondary, fontSize: 12),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allResults.length,
              itemBuilder: (context, index) {
                final item = allResults[index];

                IconData icon;
                Color iconColor;
                String subtitle;

                if (item.isHabit) {
                  icon = Icons.repeat_rounded;
                  iconColor = Colors.green;
                  subtitle = 'Habit • ${item.habit!.currentStreak} day streak';
                } else if (item.isRecurringTask) {
                  icon = Icons.repeat_rounded;
                  iconColor = Colors.purple;
                  subtitle =
                      'Recurring Task • ${item.recurringTask!.scheduleDaysLabel}';
                } else {
                  icon = Icons.check_circle_outline_rounded;
                  iconColor = AppColors.primary;
                  subtitle =
                      'Task • ${item.task!.isCompleted ? "Completed" : "Pending"}';
                }

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor),
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    subtitle,
                    style: TextStyle(color: textSecondary),
                  ),
                  onTap: () {
                    close(context, item);
                    onItemSelected(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTag(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onRemove,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// Numeric priority picker widget (-20 to 20)
class _NumericPriorityPicker extends StatefulWidget {
  final int currentPriority;
  final Function(int) onPriorityChanged;

  const _NumericPriorityPicker({
    required this.currentPriority,
    required this.onPriorityChanged,
  });

  @override
  State<_NumericPriorityPicker> createState() => _NumericPriorityPickerState();
}

class _NumericPriorityPickerState extends State<_NumericPriorityPicker> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.currentPriority.toDouble();
  }

  Color _getPriorityColor(int priority) {
    if (priority > 10) return Colors.red;
    if (priority > 5) return Colors.orange;
    if (priority > 0) return Colors.blue;
    if (priority == 0) return Colors.grey;
    if (priority > -10) return Colors.blueGrey;
    return Colors.grey.shade600;
  }

  String _getPriorityLabel(int priority) {
    if (priority > 15) return 'Critical';
    if (priority > 10) return 'Very High';
    if (priority > 5) return 'High';
    if (priority > 0) return 'Above Normal';
    if (priority == 0) return 'Normal';
    if (priority > -5) return 'Below Normal';
    if (priority > -10) return 'Low';
    return 'Very Low';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final priority = _sliderValue.round();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Set Priority',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Higher priority items appear at the top',
            style: TextStyle(fontSize: 13, color: textPrimary.withAlpha(150)),
          ),
          const SizedBox(height: 24),

          // Priority display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                priority > 0 ? '+$priority' : '$priority',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _getPriorityColor(priority),
                ),
              ),
            ],
          ),
          Text(
            _getPriorityLabel(priority),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _getPriorityColor(priority),
            ),
          ),
          const SizedBox(height: 24),

          // Slider
          Row(
            children: [
              const Text('-20', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _sliderValue,
                  min: -20,
                  max: 20,
                  divisions: 40,
                  activeColor: _getPriorityColor(priority),
                  onChanged: (value) {
                    setState(() => _sliderValue = value);
                  },
                ),
              ),
              const Text('+20', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),

          // Quick buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _QuickPriorityButton(
                label: '-10',
                value: -10,
                currentValue: priority,
                onTap: () => setState(() => _sliderValue = -10),
              ),
              _QuickPriorityButton(
                label: '0',
                value: 0,
                currentValue: priority,
                onTap: () => setState(() => _sliderValue = 0),
              ),
              _QuickPriorityButton(
                label: '+5',
                value: 5,
                currentValue: priority,
                onTap: () => setState(() => _sliderValue = 5),
              ),
              _QuickPriorityButton(
                label: '+10',
                value: 10,
                currentValue: priority,
                onTap: () => setState(() => _sliderValue = 10),
              ),
              _QuickPriorityButton(
                label: '+15',
                value: 15,
                currentValue: priority,
                onTap: () => setState(() => _sliderValue = 15),
              ),
              _QuickPriorityButton(
                label: '+20',
                value: 20,
                currentValue: priority,
                onTap: () => setState(() => _sliderValue = 20),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onPriorityChanged(priority),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getPriorityColor(priority),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Set Priority',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickPriorityButton extends StatelessWidget {
  final String label;
  final int value;
  final int currentValue;
  final VoidCallback onTap;

  const _QuickPriorityButton({
    required this.label,
    required this.value,
    required this.currentValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == currentValue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Compact action button for Grid Action Sheet
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? subtitle;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textMuted = isDark ? AppColors.textMuted : LightColors.textMuted;
    final actionColor = color ?? textPrimary;

    // Calculate width to fit 3 items per row with spacing
    final screenWidth = MediaQuery.of(context).size.width;
    // 16*2 horizontal padding on sheet + 8*2 spacing between 3 items
    final itemWidth = (screenWidth - 48) / 3;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: itemWidth,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: (color != null
              ? color!.withAlpha(15)
              : (isDark ? AppColors.surfaceLight : LightColors.surfaceLight)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (isDark ? AppColors.glassBorder : LightColors.glassBorder)
                .withAlpha(40),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: actionColor, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: actionColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              DefaultTextStyle(
                style: TextStyle(fontSize: 9, color: textMuted),
                child: subtitle!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
