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
  final GlobalKey<ConfettiOverlayState> _confettiKey = GlobalKey<ConfettiOverlayState>();

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
        final recurringTasksForDate = _getRecurringTasksForDate(state, _selectedDate);
        final allItems = <_TodayItem>[
          ...habitsForDate.map((h) => _TodayItem.habit(h)),
          ...recurringTasksForDate.map((rt) => _TodayItem.recurringTask(rt)),
          ...tasksForDate.map((t) => _TodayItem.task(t)),
        ];

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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _scaffoldKey.currentState?.openDrawer(),
                            child: Icon(
                              Icons.menu_rounded,
                              color: textPrimary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 22,
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
                          IconButton(
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: textPrimary,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Horizontal Date Picker
                SizedBox(
                  height: 72,
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
                            horizontal: 16,
                            vertical: 8,
                          ),
                          proxyDecorator: (child, index, animation) {
                            return AnimatedBuilder(
                              animation: animation,
                              builder: (context, child) {
                                final elevationValue = Tween<double>(begin: 0, end: 6)
                                    .animate(animation)
                                    .value;
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
                            // Save the new order (simplified - would need more complex logic for mixed types)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Moved item from position ${oldIndex + 1} to ${newIndex + 1}'),
                                duration: const Duration(seconds: 1),
                              ),
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
                                      // Swipe left = edit
                                      if (item.isHabit) {
                                        HabitDetailScreen.show(context, habitId: item.habit!.id);
                                      } else if (item.isRecurringTask) {
                                        // Show message - editing coming soon
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Recurring task editing coming soon')),
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
                                  child: ReorderableDragStartListener(
                                    key: Key('reorder_$itemKey'),
                                    index: index,
                                    child: _TodayItemCard(
                                      item: item,
                                      selectedDate: _selectedDate,
                                      onTap: () => _handleItemTap(item, state),
                                      onLongPress: () =>
                                          _showItemOptions(context, item),
                                    ),
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

  Widget _buildDrawer(BuildContext context, AppState state, bool isDark, Color textPrimary) {
    final bgColor = isDark ? AppColors.surface : LightColors.surface;
    
    return Drawer(
      backgroundColor: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withAlpha(50),
                    radius: 24,
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
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
                color: isDark ? AppColors.surfaceLight : LightColors.surfaceLight,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _DrawerStat(
                    label: 'Habits',
                    value: '${state.habits.where((h) => h.isActive && !h.isArchived).length}',
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
                  _DrawerItem(
                    icon: Icons.calendar_month_rounded,
                    label: 'Calendar View',
                    onTap: () {
                      Navigator.pop(context);
                      _showDatePicker(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.category_rounded,
                    label: 'Categories',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  const Divider(),
                  _DrawerItem(
                    icon: Icons.archive_rounded,
                    label: 'Archived Items',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Archive view coming soon')),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Statistics',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Statistics view coming soon')),
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
    for (final habit in state.habits.where((h) => h.isActive && !h.isArchived)) {
      if (habit.currentStreak > bestStreak) {
        bestStreak = habit.currentStreak;
      }
    }
    return bestStreak;
  }

  void _showSearch(BuildContext context, AppState state) {
    showSearch(
      context: context,
      delegate: _TodaySearchDelegate(state: state, onItemSelected: (item) {
        if (item.isHabit) {
          HabitDetailScreen.show(context, habitId: item.habit!.id);
        } else if (item.isTask) {
          EditTaskSheet.show(context, task: item.task!, onTaskUpdated: () => setState(() {}));
        }
      }),
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
    return state.tasks
        .where((t) => t.isScheduledFor(date) && !t.isCompleted)
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'How close did you get to completing this habit?',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondary : LightColors.textSecondary,
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
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
          ],
          Icon(icon, color: color, size: 28),
          if (alignment == Alignment.centerLeft && label != null) ...[
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }

  void _showPriorityPicker(BuildContext context, _TodayItem item, AppState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPriority = item.isHabit 
        ? item.habit!.effectivePriorityLevel 
        : item.task!.priorityLevel;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surface : LightColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set Priority',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...PriorityLevel.values.map((priority) => ListTile(
              leading: Icon(
                _getPriorityIcon(priority),
                color: _getPriorityColor(priority),
              ),
              title: Text(_getPriorityLabel(priority)),
              trailing: currentPriority == priority 
                  ? Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                Navigator.pop(ctx);
                _updateItemPriority(item, priority, state);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _updateItemPriority(_TodayItem item, PriorityLevel priority, AppState state) {
    if (item.isHabit) {
      final habit = item.habit!;
      habit.priorityLevel = priority;
      state.updateHabit(habit);
    } else {
      final task = item.task!;
      task.priorityLevel = priority;
      state.updateTask(task);
    }
    setState(() {});
  }

  IconData _getPriorityIcon(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.none:
        return Icons.flag_outlined;
      case PriorityLevel.low:
        return Icons.flag_rounded;
      case PriorityLevel.medium:
        return Icons.flag_rounded;
      case PriorityLevel.high:
        return Icons.priority_high_rounded;
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

  String _getPriorityLabel(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.none:
        return 'No Priority';
      case PriorityLevel.low:
        return 'Low Priority';
      case PriorityLevel.medium:
        return 'Medium Priority';
      case PriorityLevel.high:
        return 'High Priority';
    }
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

  void _showItemOptions(BuildContext context, _TodayItem item) {
    final state = context.read<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surface : LightColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Item title
            Text(
              item.isHabit ? item.habit!.name : item.task!.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Reminders option
            ListTile(
              leading: const Icon(Icons.notifications_rounded),
              title: const Text('Reminders'),
              subtitle: item.isHabit && (item.habit!.reminderTimes?.isNotEmpty ?? false)
                  ? Text('${item.habit!.reminderTimes!.length} reminder(s) set')
                  : const Text('No reminders set'),
              onTap: () {
                Navigator.pop(ctx);
                _showRemindersDialog(context, item);
              },
            ),
            
            // Notes option
            ListTile(
              leading: const Icon(Icons.note_rounded),
              title: const Text('Notes'),
              subtitle: item.isHabit && item.habit!.todayLog?.note != null
                  ? Text(item.habit!.todayLog!.note!, maxLines: 1, overflow: TextOverflow.ellipsis)
                  : const Text('Add a note'),
              onTap: () {
                Navigator.pop(ctx);
                _showNotesDialog(context, item, state);
              },
            ),
            
            // Statistics (habits only)
            if (item.isHabit)
              ListTile(
                leading: const Icon(Icons.bar_chart_rounded),
                title: const Text('Statistics'),
                subtitle: Text('${item.habit!.currentStreak} day streak'),
                onTap: () {
                  Navigator.pop(ctx);
                  HabitDetailScreen.show(context, habitId: item.habit!.id);
                },
              ),
            
            // Calendar (habits only)
            if (item.isHabit)
              ListTile(
                leading: const Icon(Icons.calendar_today_rounded),
                title: const Text('Calendar'),
                onTap: () {
                  Navigator.pop(ctx);
                  HabitDetailScreen.show(context, habitId: item.habit!.id);
                },
              ),
            
            // Edit option
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(ctx);
                if (item.isHabit) {
                  HabitDetailScreen.show(context, habitId: item.habit!.id);
                } else if (item.isRecurringTask) {
                  // Show recurring task wizard in edit mode (or detail screen when available)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recurring task editing coming soon')),
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
            
            // Delete option
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(ctx);
                final confirmed = await _confirmDelete(context, item);
                if (confirmed) {
                  _deleteItem(item, state);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRemindersDialog(BuildContext context, _TodayItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reminders = item.isHabit ? (item.habit!.reminderTimes ?? []) : <String>[];
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surface : LightColors.surface,
        title: const Text('Reminders'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reminders.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No reminders set for this item.'),
              )
            else
              ...reminders.map((time) => ListTile(
                leading: const Icon(Icons.access_time_rounded),
                title: Text(time),
              )),
            const SizedBox(height: 8),
            Text(
              'Edit reminders in the item detail screen.',
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMuted : LightColors.textMuted),
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

  void _showNotesDialog(BuildContext context, _TodayItem item, AppState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentNote = item.isHabit ? (item.habit!.todayLog?.note ?? '') : '';
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
              if (item.isHabit) {
                final habit = item.habit!;
                final isCompleted = habit.isCompletedFor(_selectedDate);
                state.logHabit(
                  habit.id,
                  completed: isCompleted,
                  note: controller.text.isNotEmpty ? controller.text : null,
                );
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
  factory _TodayItem.recurringTask(RecurringTask rt) => _TodayItem._(recurringTask: rt);

  bool get isHabit => habit != null;
  bool get isTask => task != null;
  bool get isRecurringTask => recurringTask != null;

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

  const _TodayItemCard({
    required this.item,
    required this.selectedDate,
    required this.onTap,
    required this.onLongPress,
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
    final cardColor = isDark ? AppColors.surface : LightColors.surface;

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
    final category = categoryId != null ? appState.getCategoryById(categoryId) : null;

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

    // Get priority for display
    PriorityLevel priority;
    if (item.isHabit) {
      priority = item.habit!.effectivePriorityLevel;
    } else if (item.isRecurringTask) {
      priority = item.recurringTask!.priorityLevel;
    } else {
      priority = item.task!.priorityLevel;
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.glassBorder : LightColors.glassBorder,
            width: 1,
          ),
          // Priority glow effect for uncompleted high-priority items
          boxShadow: !isCompleted && priority == PriorityLevel.high
              ? AppShadows.highPriorityGlow
              : !isCompleted && priority == PriorityLevel.medium
                  ? AppShadows.mediumPriorityGlow
                  : isCompleted
                      ? AppShadows.successGlow
                      : AppShadows.card,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
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
                      left: category != null ? 12 : 16,
                      top: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Row(
          children: [
            // Category icon with priority indicator
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getItemColor().withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_getItemIcon(), color: _getItemColor(), size: 22),
                ),
                if (priority != PriorityLevel.none)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getPriorityColor(priority),
                        shape: BoxShape.circle,
                        border: Border.all(color: cardColor, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? textSecondary : textPrimary,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getItemColor().withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.itemTypeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _getItemColor(),
                          ),
                        ),
                      ),
                      // Show score if scoring enabled and has score
                      if (item.isHabit && item.habit!.scoringEnabled && score != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getScoreColor(score).withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$score%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getScoreColor(score),
                            ),
                          ),
                        ),
                      ] else if (item.isHabit &&
                          item.habit!.effectiveEvaluationType ==
                              HabitEvaluationType.numeric) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Current: ${item.habit!.getCurrentValueFor(selectedDate)}',
                          style: TextStyle(fontSize: 12, color: textSecondary),
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
      ),
    );
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

  Widget _buildCompletionIndicator(bool isCompleted, int? score) {
    // If scoring enabled and has score, show score-based indicator
    if (item.isHabit && item.habit!.scoringEnabled && score != null) {
      final color = _getScoreColor(score);
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Text(
            '$score',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      );
    }

    if (isCompleted) {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
      );
    }

    // Show different indicators based on item type
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey, width: 2),
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
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
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
    final textPrimary = isDark ? AppColors.textPrimary : LightColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : LightColors.textSecondary;
    
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
        Text(
          label,
          style: TextStyle(fontSize: 12, color: textSecondary),
        ),
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
    final textPrimary = isDark ? AppColors.textPrimary : LightColors.textPrimary;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : textPrimary,
      ),
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

/// Search delegate for Today screen
class _TodaySearchDelegate extends SearchDelegate<_TodayItem?> {
  final AppState state;
  final Function(_TodayItem) onItemSelected;

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
        iconTheme: IconThemeData(color: isDark ? AppColors.textPrimary : LightColors.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: isDark ? AppColors.textSecondary : LightColors.textSecondary),
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
    ];
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
    final textPrimary = isDark ? AppColors.textPrimary : LightColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : LightColors.textSecondary;
    final bgColor = isDark ? AppColors.background : LightColors.background;

    if (query.isEmpty) {
      return Container(
        color: bgColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_rounded, size: 64, color: textSecondary.withAlpha(100)),
              const SizedBox(height: 16),
              Text(
                'Search for habits or tasks',
                style: TextStyle(color: textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final lowerQuery = query.toLowerCase();
    
    // Search habits
    final matchingHabits = state.habits
        .where((h) => h.name.toLowerCase().contains(lowerQuery))
        .map((h) => _TodayItem.habit(h))
        .toList();

    // Search tasks
    final matchingTasks = state.tasks
        .where((t) => t.title.toLowerCase().contains(lowerQuery))
        .map((t) => _TodayItem.task(t))
        .toList();

    // Search recurring tasks
    final matchingRecurring = state.recurringTasks
        .where((rt) => rt.name.toLowerCase().contains(lowerQuery))
        .map((rt) => _TodayItem.recurringTask(rt))
        .toList();

    final allResults = [...matchingHabits, ...matchingRecurring, ...matchingTasks];

    if (allResults.isEmpty) {
      return Container(
        color: bgColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 64, color: textSecondary.withAlpha(100)),
              const SizedBox(height: 16),
              Text(
                'No results for "$query"',
                style: TextStyle(color: textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: bgColor,
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
            subtitle = 'Recurring Task • ${item.recurringTask!.scheduleDaysLabel}';
          } else {
            icon = Icons.check_circle_outline_rounded;
            iconColor = AppColors.primary;
            subtitle = 'Task • ${item.task!.isCompleted ? "Completed" : "Pending"}';
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
            subtitle: Text(subtitle, style: TextStyle(color: textSecondary)),
            onTap: () {
              close(context, item);
              onItemSelected(item);
            },
          );
        },
      ),
    );
  }
}
