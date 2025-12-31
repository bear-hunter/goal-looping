import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/theme.dart';
import '../../providers/app_state.dart';
import '../../models/task.dart';
import '../../models/habit.dart';
import '../../models/habit_enums.dart';
import 'add_task_sheet.dart';
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
        final allItems = <_TodayItem>[
          ...habitsForDate.map((h) => _TodayItem.habit(h)),
          ...tasksForDate.map((t) => _TodayItem.task(t)),
        ];

        return Scaffold(
          backgroundColor: bgColor,
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
                          Icon(
                            Icons.menu_rounded,
                            color: textPrimary,
                            size: 24,
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
                            onPressed: () {
                              // TODO: Search
                            },
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
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: allItems.length,
                          itemBuilder: (context, index) {
                            final item = allItems[index];
                            return Dismissible(
                                  key: Key(
                                    item.isHabit
                                        ? 'h_${item.habit!.id}'
                                        : 't_${item.task!.id}',
                                  ),
                                  background: _buildSwipeBackground(
                                    color: Colors.green,
                                    icon: Icons.check_rounded,
                                    alignment: Alignment.centerLeft,
                                  ),
                                  secondaryBackground: _buildSwipeBackground(
                                    color: Colors.red,
                                    icon: Icons.delete_rounded,
                                    alignment: Alignment.centerRight,
                                  ),
                                  confirmDismiss: (direction) async {
                                    if (direction ==
                                        DismissDirection.startToEnd) {
                                      // Swipe right = complete
                                      _handleItemTap(item, state);
                                      return false; // Don't dismiss, just toggle
                                    } else {
                                      // Swipe left = delete
                                      return await _confirmDelete(
                                        context,
                                        item,
                                      );
                                    }
                                  },
                                  onDismissed: (direction) {
                                    if (direction ==
                                        DismissDirection.endToStart) {
                                      _deleteItem(item, state);
                                    }
                                  },
                                  child: _TodayItemCard(
                                    item: item,
                                    onTap: () => _handleItemTap(item, state),
                                    onLongPress: () =>
                                        _showItemOptions(context, item),
                                  ),
                                )
                                .animate()
                                .fadeIn(
                                  delay: Duration(milliseconds: index * 50),
                                )
                                .slideX(begin: 0.1, end: 0);
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
        );
      },
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

  void _handleItemTap(_TodayItem item, AppState state) {
    if (item.isHabit) {
      // Toggle habit completion for today
      final habit = item.habit!;
      final isCompleted = habit.isCompletedFor(_selectedDate);
      state.logHabit(habit.id, completed: !isCompleted);
    } else {
      // Toggle task completion
      state.toggleTaskComplete(item.task!.id);
    }
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(icon, color: color, size: 28),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, _TodayItem item) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete ${item.isHabit ? 'Habit' : 'Task'}?'),
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
    } else {
      state.deleteTask(item.task!.id);
    }
  }

  void _showItemOptions(BuildContext context, _TodayItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surface
          : LightColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.isHabit ? item.habit!.name : item.task!.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.calendar_today_rounded),
              title: const Text('Calendar'),
              onTap: () {
                Navigator.pop(context);
                if (item.isHabit) {
                  HabitDetailScreen.show(context, habitId: item.habit!.id);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_rounded),
              title: const Text('Statistics'),
              onTap: () {
                Navigator.pop(context);
                if (item.isHabit) {
                  HabitDetailScreen.show(context, habitId: item.habit!.id);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                if (item.isHabit) {
                  HabitDetailScreen.show(context, habitId: item.habit!.id);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Delete item
              },
            ),
          ],
        ),
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

  const _TodayItem._({this.habit, this.task});

  factory _TodayItem.habit(Habit h) => _TodayItem._(habit: h);
  factory _TodayItem.task(Task t) => _TodayItem._(task: t);

  bool get isHabit => habit != null;
  bool get isTask => task != null;

  String get name => isHabit ? habit!.name : task!.title;
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
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _TodayItemCard({
    required this.item,
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

    // Determine completion state
    bool isCompleted = false;
    if (item.isHabit) {
      isCompleted =
          item.habit!.isLoggedToday &&
          (item.habit!.todayLog?.completed ?? false);
    } else {
      isCompleted = item.task!.isCompleted;
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.glassBorder : LightColors.glassBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getItemColor().withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_getItemIcon(), color: _getItemColor(), size: 22),
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
                          item.isHabit ? 'Habit' : 'Task',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _getItemColor(),
                          ),
                        ),
                      ),
                      if (item.isHabit &&
                          item.habit!.effectiveEvaluationType ==
                              HabitEvaluationType.numeric) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Current: ${item.habit!.getCurrentValueFor(DateTime.now())}',
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Completion indicator
            _buildCompletionIndicator(isCompleted),
          ],
        ),
      ),
    );
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
    return AppColors.primary;
  }

  Widget _buildCompletionIndicator(bool isCompleted) {
    if (isCompleted) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
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
