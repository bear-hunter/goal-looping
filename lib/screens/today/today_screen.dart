import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/theme.dart';
import '../../providers/app_state.dart';
import '../../models/habit.dart';
import '../../models/habit_enums.dart';
import '../../models/recurring_task.dart';
import '../../services/haptic_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/confetti.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/section_header.dart';
import '../../widgets/skeleton_loading.dart';
import '../../widgets/mood_barrier_dialog.dart';
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
import '../spaced_repetition/spaced_repetition_screen.dart';
import '../habits/habit_timer_screen.dart';

/// Today Screen - Main daily view with horizontal date picker and item list
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late DateTime _selectedDate;
  late final DateTime _dateStripAnchor;
  late ScrollController _dateScrollController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ConfettiOverlayState> _confettiKey =
      GlobalKey<ConfettiOverlayState>();
  bool _completedExpanded = false;
  // Guards the mood/barrier sheet against double-firing on rapid toggles.
  bool _barrierDialogShowing = false;
  final Set<String> _datesAnimatedOnce = {};

  // Large virtual range so the horizontal calendar feels uncapped without
  // materializing thousands of DateTime objects.
  static const int _virtualDateCount = 200001;
  static const int _anchorDateIndex = _virtualDateCount ~/ 2;
  static const double _dateItemWidth = 38;
  static const double _dateItemHorizontalMargin = 3;
  static const double _dateItemExtent =
      _dateItemWidth + (_dateItemHorizontalMargin * 2);

  @override
  void initState() {
    super.initState();
    _dateStripAnchor = _dateOnly(DateTime.now());
    _selectedDate = _dateStripAnchor;
    _dateScrollController = ScrollController();

    // Scroll to today after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate(animated: false);
    });
  }

  void _scrollToSelectedDate({bool animated = true}) {
    if (!_dateScrollController.hasClients) return;

    final index = _indexForDate(_selectedDate);
    final offset =
        (index * _dateItemExtent) -
        (MediaQuery.of(context).size.width / 2) +
        (_dateItemExtent / 2);
    final targetOffset = offset
        .clamp(0.0, _dateScrollController.position.maxScrollExtent)
        .toDouble();

    if (animated) {
      _dateScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _dateScrollController.jumpTo(targetOffset);
    }
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _dateForIndex(int index) {
    final offset = index - _anchorDateIndex;
    return DateTime(
      _dateStripAnchor.year,
      _dateStripAnchor.month,
      _dateStripAnchor.day + offset,
    );
  }

  int _indexForDate(DateTime date) {
    final index = _anchorDateIndex + _daysBetween(_dateStripAnchor, date);
    if (index < 0) return 0;
    if (index >= _virtualDateCount) return _virtualDateCount - 1;
    return index;
  }

  int _daysBetween(DateTime start, DateTime end) {
    final startUtc = DateTime.utc(start.year, start.month, start.day);
    final endUtc = DateTime.utc(end.year, end.month, end.day);
    return endUtc.difference(startUtc).inDays;
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;
    final bgColor = colors.background;

    return ConfettiOverlay(
      key: _confettiKey,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: bgColor,
        drawer: Consumer<AppState>(
          builder: (context, state, _) =>
              _buildDrawer(context, state, textPrimary),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<AppState>(
                builder: (context, state, _) =>
                    _buildTodayAppBar(context, state, textPrimary),
              ),
              Consumer<AppState>(
                builder: (context, state, _) {
                  final todayData = state.getTodayDateData(_selectedDate);
                  if (todayData.totalCount == 0) {
                    return const SizedBox.shrink();
                  }
                  return _DayProgressHeader(
                    completed: todayData.completedCount,
                    total: todayData.totalCount,
                    selectedDate: _selectedDate,
                  );
                },
              ),

              // Horizontal Date Picker
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.xxs,
                  AppSpacing.sm,
                  2,
                ),
                child: Text(
                  DateFormat('MMMM yyyy').format(_selectedDate),
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 50, child: _buildDateStrip(textPrimary)),

              const SizedBox(height: AppSpacing.xxs),

              // Item List
              Expanded(
                child: Consumer<AppState>(
                  builder: (context, state, _) {
                    final todayData = state.getTodayDateData(_selectedDate);
                    final dateKey = _dateKey(_selectedDate);
                    final shouldAnimateItems = _datesAnimatedOnce.add(dateKey);

                    return state.isLoading
                        ? SingleChildScrollView(
                            child: SkeletonList.habits(count: 5),
                          )
                        : _buildSectionedTodayList(
                            state: state,
                            todayData: todayData,
                            shouldAnimateItems: shouldAnimateItems,
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
  }

  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

  /// Trigger confetti celebration
  void _celebrate() {
    _confettiKey.currentState?.celebrate();
  }

  Widget _buildTodayAppBar(
    BuildContext context,
    AppState state,
    Color textPrimary,
  ) {
    final isToday = _isSameDate(_selectedDate, DateTime.now());
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xxs,
      ),
      child: Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.menu_rounded, color: textPrimary, size: 20),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    _dateTitle(_selectedDate),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ),
                if (!isToday) ...[
                  const SizedBox(width: AppSpacing.xs),
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedDate = _dateOnly(DateTime.now()));
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToSelectedDate();
                      });
                    },
                    child: const Text('Today'),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.search_rounded, color: textPrimary, size: 20),
            onPressed: () => _showSearch(context, state),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.calendar_month_rounded,
              color: textPrimary,
              size: 20,
            ),
            onPressed: () => _showDatePicker(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStrip(Color textPrimary) {
    final today = _dateOnly(DateTime.now());
    return ListView.builder(
      controller: _dateScrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      itemExtent: _dateItemExtent,
      cacheExtent: _dateItemExtent * 8,
      itemCount: _virtualDateCount,
      itemBuilder: (context, index) {
        final date = _dateForIndex(index);
        final isSelected = _isSameDate(date, _selectedDate);
        final isToday = _isSameDate(date, today);

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
    );
  }

  Widget _buildSectionedTodayList({
    required AppState state,
    required TodayDateData todayData,
    required bool shouldAnimateItems,
  }) {
    if (todayData.allItems.isEmpty) {
      return EmptyState(
        icon: Icons.event_available_rounded,
        title: 'Nothing scheduled',
        subtitle: 'Add a habit or task when this day needs a little shape.',
        actionLabel: 'Add',
        onAction: () => _showTaskCreation(context),
        accent: EmptyStateAccent.primary,
      );
    }

    return CustomScrollView(
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: AppSpacing.xxs)),
        if (todayData.topTasks.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: SectionHeader(
                title: 'Top Tasks',
                padding: const EdgeInsets.only(
                  top: AppSpacing.xxs,
                  bottom: AppSpacing.xxs,
                ),
                trailing: _CountBadge(count: todayData.topTasks.length),
              ),
            ),
          ),
          _buildReorderableSection(
            todayData.topTasks,
            state,
            shouldAnimateItems: shouldAnimateItems,
          ),
        ],
        if (todayData.habitRoutine.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: SectionHeader(
                title: 'Habit Routine',
                padding: const EdgeInsets.only(
                  top: AppSpacing.xs,
                  bottom: AppSpacing.xxs,
                ),
                trailing: _CountBadge(count: todayData.habitRoutine.length),
              ),
            ),
          ),
          _buildReorderableSection(
            todayData.habitRoutine,
            state,
            shouldAnimateItems: shouldAnimateItems,
          ),
        ],
        if (todayData.topTasks.isEmpty && todayData.habitRoutine.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: EmptyState.allDone(),
            ),
          ),
        if (todayData.completedItems.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: SectionHeader(
                title: 'Completed',
                padding: const EdgeInsets.only(
                  top: AppSpacing.xs,
                  bottom: AppSpacing.xxs,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CountBadge(count: todayData.completedItems.length),
                    const SizedBox(width: AppSpacing.xs),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: AnimatedRotation(
                        turns: _completedExpanded ? 0.5 : 0,
                        duration: AppMotion.standard,
                        child: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                      onPressed: () {
                        setState(
                          () => _completedExpanded = !_completedExpanded,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_completedExpanded)
            _buildReorderableSection(
              todayData.completedItems,
              state,
              shouldAnimateItems: shouldAnimateItems,
            ),
        ],
        const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.hero)),
      ],
    );
  }

  Widget _buildReorderableSection(
    List<TodayItemData> items,
    AppState state, {
    required bool shouldAnimateItems,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      sliver: SliverReorderableList(
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
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: child,
              );
            },
            child: child,
          );
        },
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final reordered = List<TodayItemData>.from(items);
          final movedItem = reordered.removeAt(oldIndex);
          reordered.insert(newIndex, movedItem);
          _persistReorder(reordered, state);
        },
        itemCount: items.length,
        itemBuilder: (context, i) {
          Widget child = _buildSwipeableCard(items[i], state, i);
          if (shouldAnimateItems) {
            child = child
                .animate()
                .fadeIn(duration: AppMotion.standard, delay: (35 * i).ms)
                .slideY(begin: 0.08, end: 0, duration: AppMotion.standard);
          }
          return KeyedSubtree(
            key: ValueKey('section_${items[i].stableKey}'),
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildSwipeableCard(TodayItemData item, AppState state, int index) {
    final colors = context.colors;
    return Dismissible(
      key: Key('dismiss_${item.stableKey}_${_selectedDate.toIso8601String()}'),
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.25,
        DismissDirection.endToStart: 0.25,
      },
      background: _buildSwipeBackground(
        color: colors.success,
        icon: Icons.check_rounded,
        alignment: Alignment.centerLeft,
        label: _isItemCompleted(item, _selectedDate) ? 'Undo' : 'Done',
      ),
      secondaryBackground: _buildSwipeBackground(
        color: colors.info,
        icon: Icons.more_horiz_rounded,
        alignment: Alignment.centerRight,
        label: 'Actions',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _toggleItemCompletion(item, state);
        } else {
          _showPriorityPicker(context, item, state);
        }
        return false;
      },
      child: _TodayItemCard(
        item: item,
        selectedDate: _selectedDate,
        onTap: () => _openItemDetail(item, state),
        onCompleteTap: () => _toggleItemCompletion(item, state),
        onLongPress: () => _showItemOptions(context, item),
        index: index,
      ),
    );
  }

  void _openItemDetail(TodayItemData item, AppState state) {
    if (item.isHabit) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HabitDetailScreen(habitId: item.habit!.id),
        ),
      ).then((_) => setState(() {}));
    } else if (item.isRecurringTask) {
      _showRecurringTaskEditSheet(context, item.recurringTask!, state);
    } else {
      EditTaskSheet.show(
        context,
        task: item.task!,
        onTaskUpdated: () => setState(() {}),
      );
    }
  }

  void _toggleItemCompletion(TodayItemData item, AppState state) {
    final today = DateTime.now();
    if (_dateOnly(_selectedDate).isAfter(_dateOnly(today))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Future check-ins are read-only')),
      );
      return;
    }
    final usesDetailedCheckIn =
        (item.isHabit &&
            (item.habit!.scoringEnabled ||
                item.habit!.effectiveEvaluationType !=
                    HabitEvaluationType.yesNo)) ||
        (item.isRecurringTask &&
            item.recurringTask!.evaluationType ==
                HabitEvaluationType.checklist);
    if (usesDetailedCheckIn) {
      _handleItemTap(item, state);
      return;
    }
    final beforeOpenCount = _currentOpenItemCount(state);
    final wasCompleted = _isItemCompleted(item, _selectedDate);
    _handleItemTap(item, state);
    HapticService.lightImpact();
    if (!wasCompleted && beforeOpenCount == 1) {
      HapticService.success();
      _celebrate();
    }
  }

  int _currentOpenItemCount(AppState state) {
    final todayData = state.getTodayDateData(_selectedDate);
    return todayData.totalCount - todayData.completedCount;
  }

  bool _isItemCompleted(TodayItemData item, DateTime date) {
    if (item.isHabit) return item.habit!.isCompletedFor(date);
    if (item.isRecurringTask) return item.recurringTask!.isCompletedFor(date);
    return item.task!.isCompleted;
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dateTitle(DateTime date) {
    final today = DateTime.now();
    final day = DateTime(date.year, date.month, date.day);
    final current = DateTime(today.year, today.month, today.day);
    final diff = day.difference(current).inDays;
    if (diff == 0) return 'Today';
    if (diff == -1) return 'Yesterday';
    if (diff == 1) return 'Tomorrow';
    return DateFormat('EEE, MMM d').format(date);
  }

  Widget _buildDrawer(BuildContext context, AppState state, Color textPrimary) {
    final colors = context.colors;
    final bgColor = colors.surface;

    return Drawer(
      backgroundColor: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: colors.primary),
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
              decoration: BoxDecoration(color: colors.surfaceLight),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _DrawerStat(
                    label: 'Habits',
                    value:
                        '${state.habits.where((h) => h.isActive && !h.isArchived).length}',
                    icon: Icons.repeat_rounded,
                    color: colors.success,
                  ),
                  _DrawerStat(
                    label: 'Tasks',
                    value: '${state.tasks.where((t) => !t.isCompleted).length}',
                    icon: Icons.check_circle_outline_rounded,
                    color: colors.primary,
                  ),
                  _DrawerStat(
                    label: 'Streak',
                    value: '${_calculateBestStreak(state)} days',
                    icon: Icons.local_fire_department_rounded,
                    color: colors.warning,
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
                  const Divider(),
                  _DrawerItem(
                    icon: Icons.school_rounded,
                    label: 'Spaced Repetition',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SpacedRepetitionScreen(),
                        ),
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
          } else if (item.isRecurringTask) {
            _showRecurringTaskEditSheet(context, item.recurringTask!, state);
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

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = _dateOnly(picked));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDate();
      });
    }
  }

  void _handleItemTap(TodayItemData item, AppState state) {
    if (item.isHabit) {
      final habit = item.habit!;
      final isCompleted = habit.isCompletedFor(_selectedDate);

      // If scoring is enabled, show scoring dialog
      if (habit.scoringEnabled) {
        _showScoringDialog(context, habit, state);
        return;
      }

      if (isCompleted) {
        state.logHabit(habit.id, date: _selectedDate, completed: false);
        return;
      }

      switch (habit.effectiveEvaluationType) {
        case HabitEvaluationType.yesNo:
          final nowCompleted = !isCompleted;
          state.logHabit(
            habit.id,
            date: _selectedDate,
            completed: nowCompleted,
          );
          // Toggling a habit to "not completed" is a failure path: offer the
          // in-context mood/barrier capture.
          if (!nowCompleted) _promptBarrierForHabit(habit, state);
          return;
        case HabitEvaluationType.numeric:
          _showNumericHabitDialog(habit, state);
          return;
        case HabitEvaluationType.timer:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  HabitTimerScreen(habit: habit, date: _selectedDate),
            ),
          ).then((_) {
            if (mounted) setState(() {});
          });
          return;
        case HabitEvaluationType.checklist:
          final items = habit.checklistItems ?? const <String>[];
          if (items.isEmpty) {
            state.logHabit(habit.id, date: _selectedDate, completed: true);
          } else {
            _showChecklistDialog(
              title: habit.name,
              items: items,
              initialValues: habit.getLogFor(_selectedDate)?.checklistCompleted,
              onSave: (values) => state.logHabit(
                habit.id,
                date: _selectedDate,
                completed: values.every((value) => value),
                checklistCompleted: values,
              ),
            );
          }
          return;
      }
    } else if (item.isRecurringTask) {
      final rt = item.recurringTask!;
      final isCompleted = rt.isCompletedFor(_selectedDate);
      if (!isCompleted &&
          rt.evaluationType == HabitEvaluationType.checklist &&
          (rt.checklistItems?.isNotEmpty ?? false)) {
        _showChecklistDialog(
          title: rt.name,
          items: rt.checklistItems!,
          initialValues: rt.getLogFor(_selectedDate)?.checklistCompleted,
          onSave: (values) => state.logRecurringTaskCompletion(
            rt.id,
            date: _selectedDate,
            completed: values.every((value) => value),
            checklistCompleted: values,
          ),
        );
        return;
      }

      // Toggle recurring task completion for selected date.
      state.logRecurringTaskCompletion(
        rt.id,
        date: _selectedDate,
        completed: !isCompleted,
      );
    } else {
      // Toggle task completion
      state.toggleTaskComplete(item.task!.id, completionDate: _selectedDate);
    }
  }

  void _showNumericHabitDialog(Habit habit, AppState state) {
    final target = (habit.targetValue ?? 1).clamp(1, 1 << 31);
    final existingValue = habit.getCurrentValueFor(_selectedDate);
    final controller = TextEditingController(
      text: existingValue == 0 ? '' : existingValue.toString(),
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(habit.name),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: habit.unit?.trim().isNotEmpty == true
                ? habit.unit
                : 'Value',
            helperText:
                'Target: $target${habit.unit == null ? '' : ' ${habit.unit}'}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = int.tryParse(controller.text.trim());
              if (value == null || value < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a valid number.')),
                );
                return;
              }
              await state.logHabit(
                habit.id,
                date: _selectedDate,
                completed: value >= target,
                numericValue: value,
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  void _showChecklistDialog({
    required String title,
    required List<String> items,
    required List<bool>? initialValues,
    required Future<void> Function(List<bool> values) onSave,
  }) {
    final values = List<bool>.generate(
      items.length,
      (index) => index < (initialValues?.length ?? 0) && initialValues![index],
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.55,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(items[index]),
                      value: values[index],
                      onChanged: (value) =>
                          setSheetState(() => values[index] = value ?? false),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FilledButton(
                  onPressed: () async {
                    await onSave(List<bool>.from(values));
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                  child: const Text('Save progress'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// After a habit is marked failed, offers the mood/barrier capture sheet.
  /// Logs a [BarrierEntry] linked to the habit only if the user picks a tag;
  /// skipping (or saving without a tag) does nothing.
  void _promptBarrierForHabit(Habit habit, AppState state) {
    if (_barrierDialogShowing) return;
    _barrierDialogShowing = true;
    MoodBarrierDialog.show(
      context,
      habitCompleted: false,
      habitName: habit.name,
      onSubmit: (mood, barrierKey) {
        if (barrierKey == null) return;
        state.addBarrier(
          BarrierEntry(
            id: const Uuid().v4(),
            occurredAt: _selectedDate,
            tag: barrierKey,
            linkedHabitId: habit.id,
            moodRating: mood,
          ),
        );
      },
    ).whenComplete(() => _barrierDialogShowing = false);
  }

  void _showScoringDialog(BuildContext context, Habit habit, AppState state) {
    final colors = context.colors;
    final currentLog = habit.getLogFor(_selectedDate);
    double sliderValue = (currentLog?.score ?? 50).toDouble();
    bool isCompleted = currentLog?.completed ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
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
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Score display
              Text(
                '${sliderValue.round()}%',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColorStatic(sliderValue.round(), colors),
                ),
              ),
              const SizedBox(height: 16),

              // Slider
              Slider(
                value: sliderValue,
                min: 0,
                max: 100,
                divisions: 20,
                activeColor: _getScoreColorStatic(sliderValue.round(), colors),
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
                      date: _selectedDate,
                      completed: isCompleted,
                      score: sliderValue.round(),
                    );
                    final failed = !isCompleted;
                    Navigator.pop(ctx);
                    setState(() {});
                    // "Mark as Failed" is a failure path: capture the barrier.
                    if (failed) _promptBarrierForHabit(habit, state);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
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

  Color _getScoreColorStatic(int score, AppColorsTheme colors) {
    if (score >= 70) return colors.success;
    if (score >= 40) return colors.warning;
    return colors.danger;
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
    TodayItemData item,
    AppState state,
  ) {
    final colors = context.colors;
    // Get current numeric priority
    final currentPriority = item.numericPriority;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
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
    TodayItemData item,
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

  Future<bool> _confirmDelete(BuildContext context, TodayItemData item) async {
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
                child: Text(
                  'Delete',
                  style: TextStyle(color: context.colors.danger),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _deleteItem(TodayItemData item, AppState state) {
    if (item.isHabit) {
      state.deleteHabit(item.habit!.id);
    } else if (item.isRecurringTask) {
      state.deleteRecurringTask(item.recurringTask!.id);
    } else {
      state.deleteTask(item.task!.id);
    }
  }

  void _archiveItem(TodayItemData item, AppState state) {
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

  void _showItemOptions(BuildContext context, TodayItemData item) {
    final state = context.read<AppState>();
    final colors = context.colors;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;

    // Get trigger response for display
    String? triggerResponse;
    if (item.isHabit && item.habit!.triggerResponse != null) {
      triggerResponse = item.habit!.triggerResponse;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
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
                  color: textSecondary.withValues(alpha: 0.4),
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
                  subtitle: _reminderCountLabel(item),
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
                  backgroundColor: context.colors.danger.withValues(
                    alpha: 0.18,
                  ),
                  foregroundColor: context.colors.danger,
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

  void _showRemindersDialog(BuildContext context, TodayItemData item) {
    final colors = context.colors;
    final reminders = _remindersForItem(item);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
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
              NotificationService.isSupported
                  ? 'Use Edit to change these reminders.'
                  : 'Device reminders are unavailable in this Web build.',
              style: TextStyle(fontSize: 12, color: colors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _openItemDetail(item, context.read<AppState>());
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHabitEditSheet(BuildContext context, Habit habit, AppState state) {
    final colors = context.colors;
    final surfaceColor = colors.surface;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;

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
                          color: colors.primary,
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
                                    if (selectedDays.length > 1) {
                                      selectedDays.remove(i);
                                    }
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
                                      ? colors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedDays.contains(i)
                                        ? colors.primary
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
                          backgroundColor: colors.primary,
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
    final colors = context.colors;
    final surfaceColor = colors.surface;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;

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
                      Icon(Icons.repeat_rounded, color: colors.primary),
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
                      fillColor: colors.surfaceLight,
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
                      fillColor: colors.surfaceLight,
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
                      color: colors.surfaceLight,
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
                          if (val != null) {
                            setSheetState(() => selectedCategoryId = val);
                          }
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
                      color: colors.surfaceLight,
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
                          if (val != null) {
                            setSheetState(() => frequencyType = val);
                          }
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
                                  ? colors.primary.withAlpha(30)
                                  : colors.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? colors.primary
                                    : colors.glassBorder,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              dayNames[i],
                              style: TextStyle(
                                color: isSelected
                                    ? colors.primary
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
                        backgroundColor: colors.primary,
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

  void _showNotesDialog(
    BuildContext context,
    TodayItemData item,
    AppState state,
  ) {
    final colors = context.colors;
    final currentNote = item.isHabit
        ? (item.habit!.getLogFor(_selectedDate)?.note ?? '')
        : (item.isRecurringTask
              ? (item.recurringTask!.getLogFor(_selectedDate)?.note ?? '')
              : (item.task!.note ?? ''));
    final controller = TextEditingController(text: currentNote);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
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
                state.updateHabitLogNote(
                  habit.id,
                  date: _selectedDate,
                  note: note,
                );
              } else if (item.isRecurringTask) {
                final rt = item.recurringTask!;
                state.updateRecurringTaskLogNote(
                  rt.id,
                  date: _selectedDate,
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

  Widget _reminderCountLabel(TodayItemData item) {
    final reminders = _remindersForItem(item);

    if (reminders.isEmpty) return const Text('No reminders set');
    if (!NotificationService.isSupported) {
      return const Text('Device reminders unavailable on Web');
    }
    if (item.isTask && (item.task!.isCompleted || item.task!.isArchived)) {
      return const Text('Reminder inactive');
    }
    if (item.isHabit || item.isRecurringTask) {
      final frequency = item.isHabit
          ? item.habit!.effectiveFrequencyType
          : item.recurringTask!.frequencyType;
      final endDate = item.isHabit
          ? item.habit!.endDate
          : item.recurringTask!.endDate;
      if ((frequency != HabitFrequencyType.everyday &&
              frequency != HabitFrequencyType.specificDays) ||
          endDate != null) {
        return const Text('Reminders unsupported for this schedule');
      }
    }
    return Text('${reminders.length} reminder(s) set');
  }

  List<String> _remindersForItem(TodayItemData item) {
    if (item.isHabit) return item.habit!.reminderTimes ?? const [];
    if (item.isRecurringTask) return item.recurringTask!.reminderTimes;
    return <String>{
      if (item.task!.scheduledTime != null) item.task!.scheduledTime!,
      ...item.task!.reminderTimes,
    }.toList();
  }

  Widget _notePreviewLabel(TodayItemData item, DateTime selectedDate) {
    final note = item.isHabit
        ? (item.habit!.getLogFor(selectedDate)?.note)
        : (item.isRecurringTask
              ? (item.recurringTask!.getLogFor(selectedDate)?.note)
              : item.task!.note);

    if (note == null || note.trim().isEmpty) return const Text('Add a note');
    return Text(note, maxLines: 1, overflow: TextOverflow.ellipsis);
  }

  Future<void> _persistReorder(
    List<TodayItemData> reordered,
    AppState state,
  ) async {
    final changedItems = <TodayItemData>{};
    final priorities = reordered.map((item) => item.numericPriority).toList()
      ..sort((a, b) => b.compareTo(a));

    // Priority is the primary sort key. Reassign the existing priority values
    // across the whole reordered section so a long drag remains stable after
    // the next rebuild; sortOrder resolves rows that share a priority.
    for (var i = 0; i < reordered.length; i++) {
      final item = reordered[i];
      if (item.numericPriority != priorities[i]) {
        _setItemPriority(item, priorities[i]);
        changedItems.add(item);
      }
    }

    // Update sortOrder for all items to reflect visual order
    for (var i = 0; i < reordered.length; i++) {
      final item = reordered[i];
      if (item.isHabit) {
        if (item.habit!.sortOrder != i) changedItems.add(item);
        item.habit!.sortOrder = i;
      } else if (item.isRecurringTask) {
        if (item.recurringTask!.sortOrder != i) changedItems.add(item);
        item.recurringTask!.sortOrder = i;
      } else {
        if (item.task!.sortOrder != i) changedItems.add(item);
        item.task!.sortOrder = i;
      }
    }

    // Trigger immediate UI refresh.
    state.invalidateTodayCacheFor(_selectedDate);
    setState(() {});

    // Persist every item whose priority or sort order changed. A long drag can
    // shift several intermediate rows, not only the adjacent displaced item.
    final futures = <Future<void>>[];
    for (final item in changedItems) {
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
  void _setItemPriority(TodayItemData item, int priority) {
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

/// Horizontal date picker item
class _DateItem extends StatelessWidget {
  static const List<String> _weekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

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
    final colors = context.colors;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;

    final dayAbbrev = _weekdayLabels[date.weekday - 1];
    final dayNum = date.day.toString();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _TodayScreenState._dateItemWidth,
        margin: const EdgeInsets.symmetric(
          horizontal: _TodayScreenState._dateItemHorizontalMargin,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isToday && !isSelected ? colors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayAbbrev,
              style: TextStyle(
                fontSize: 12,
                height: 1,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isToday ? colors.primary : textSecondary),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              dayNum,
              style: TextStyle(
                fontSize: 15,
                height: 1,
                fontWeight: isSelected || isToday
                    ? FontWeight.bold
                    : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isToday ? colors.primary : textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayProgressHeader extends StatelessWidget {
  final int completed;
  final int total;
  final DateTime selectedDate;

  const _DayProgressHeader({
    required this.completed,
    required this.total,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress = total == 0 ? 0.0 : completed / total;
    final message = completed == total
        ? 'Everything scheduled is complete.'
        : 'Keep the loop moving, one clear action at a time.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.glassBorder),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: AppMotion.expressive,
              curve: AppMotion.expressiveCurve,
              builder: (context, value, _) {
                return ProgressRing(
                  progress: value,
                  size: 44,
                  strokeWidth: 5,
                  progressColor: completed == total && total > 0
                      ? colors.success
                      : colors.primary,
                  child: Text(
                    '$completed/$total',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$completed of $total done',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Today item card (habit or task)
class _TodayItemCard extends StatelessWidget {
  final TodayItemData item;
  final DateTime selectedDate;
  final VoidCallback onTap;
  final VoidCallback onCompleteTap;
  final VoidCallback onLongPress;
  final int index; // Index for reordering

  const _TodayItemCard({
    required this.item,
    required this.selectedDate,
    required this.onTap,
    required this.onCompleteTap,
    required this.onLongPress,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;

    final category = item.category;

    // Determine completion state for selected date
    final isCompleted = item.isCompleted;
    final score = item.score;

    // Get numeric priority for display
    final numericPriority = item.numericPriority;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isCompleted
                ? colors.glassBorder.withAlpha(45)
                : colors.glassBorder,
          ),
          boxShadow: isCompleted ? null : AppShadows.card,
        ),
        child: Row(
          children: [
            // Category ribbon (left edge)
            if (category != null)
              Container(
                width: 3,
                height: 54,
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(AppRadius.full),
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
                  left: category != null ? AppSpacing.sm : 0,
                  right: AppSpacing.xxs,
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _getItemColor(context).withAlpha(25),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(
                            _getItemIcon(),
                            color: _getItemColor(context),
                            size: 16,
                          ),
                        ),
                        if (numericPriority != 0)
                          Positioned(
                            right: -1,
                            top: -1,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _getNumericPriorityColor(
                                  context,
                                  numericPriority,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    ReorderableDragStartListener(
                      index: index,
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        color: colors.textMuted,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xxs),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.15,
                              fontWeight: FontWeight.w600,
                              color: isCompleted ? textSecondary : textPrimary,
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
                                fontSize: 12,
                                height: 1.1,
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
                                  horizontal: AppSpacing.xs,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getItemColor(context).withAlpha(20),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                                child: Text(
                                  item.itemTypeLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: _getItemColor(context),
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
                                    horizontal: AppSpacing.xs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getScoreColor(
                                      score,
                                      colors,
                                    ).withAlpha(20),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    '$score%',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: _getScoreColor(score, colors),
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
                    Semantics(
                      button: true,
                      label: isCompleted ? 'Mark open' : 'Mark complete',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onCompleteTap,
                        child: SizedBox(
                          width: 38,
                          height: 38,
                          child: Center(
                            child: _buildCompletionIndicator(
                              context,
                              isCompleted,
                              score,
                            ),
                          ),
                        ),
                      ),
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

  Color _getScoreColor(int score, AppColorsTheme colors) {
    if (score >= 70) return colors.success;
    if (score >= 40) return colors.warning;
    return colors.danger;
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

  Color _getItemColor(BuildContext context) {
    final colors = context.colors;
    if (item.isHabit) {
      switch (item.habit!.type) {
        case HabitType.build:
          return colors.success;
        case HabitType.quit:
          return colors.danger;
        case HabitType.timed:
          return colors.info;
      }
    }
    if (item.isRecurringTask) {
      return CategoryPalette.of(context)[2];
    }
    return colors.primary;
  }

  Color _getNumericPriorityColor(BuildContext context, int priority) {
    final colors = context.colors;
    if (priority > 10) return colors.danger;
    if (priority > 5) return colors.warning;
    if (priority > 0) return colors.info;
    if (priority == 0) return colors.textMuted;
    if (priority > -10) return colors.textSecondary;
    return colors.textMuted;
  }

  Widget _buildCompletionIndicator(
    BuildContext context,
    bool isCompleted,
    int? score,
  ) {
    final colors = context.colors;
    // If scoring enabled and has score, show score-based indicator
    if (item.isHabit && item.habit!.scoringEnabled && score != null) {
      final color = _getScoreColor(score, colors);
      return Container(
        width: 26,
        height: 26,
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
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: colors.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
      );
    }

    // Show different indicators based on item type
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: colors.textMuted, width: 1.5),
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
    final menu = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Menu options (shown when expanded)
        if (_isExpanded) ...[
          _FABMenuItem(
            label: 'Task',
            icon: Icons.check_circle_outline_rounded,
            color: context.colors.primary,
            onTap: () {
              _toggleExpanded();
              widget.onTaskTap();
            },
          ).animate().fadeIn(duration: 150.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 8),
          _FABMenuItem(
                label: 'Recurring Task',
                icon: Icons.repeat_rounded,
                color: context.colors.warning,
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
                color: context.colors.success,
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
          backgroundColor: context.colors.primary,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0, // 45 degree rotation
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ),
      ],
    );

    if (!_isExpanded) return menu;

    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleExpanded,
              child: AnimatedOpacity(
                opacity: _isExpanded ? 1 : 0,
                duration: AppMotion.micro,
                child: Container(color: Colors.black.withAlpha(45)),
              ),
            ),
          ),
          Positioned(right: AppSpacing.md, bottom: 0, child: menu),
        ],
      ),
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
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surface,
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
                color: colors.textPrimary,
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
    final color = _getScoreColor(score, context.colors);

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

  Color _getScoreColor(int score, AppColorsTheme colors) {
    if (score >= 70) return colors.success;
    if (score >= 40) return colors.warning;
    return colors.danger;
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
    final colors = context.colors;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;

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
    final colors = context.colors;
    final textPrimary = colors.textPrimary;

    return ListTile(
      leading: Icon(icon, color: isSelected ? colors.primary : textPrimary),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? colors.primary : textPrimary,
        ),
      ),
      selected: isSelected,
      selectedTileColor: colors.primary.withAlpha(20),
      onTap: onTap,
    );
  }
}

/// Search delegate for Today screen with filters
class _TodaySearchDelegate extends SearchDelegate<TodayItemData?> {
  final AppState state;
  final Function(TodayItemData) onItemSelected;

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
    final colors = context.colors;
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: colors.textSecondary),
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
          color: _hasActiveFilters ? context.colors.primary : null,
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
    final colors = context.colors;
    final textPrimary = colors.textPrimary;
    final bgColor = colors.surface;

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
                    selectedColor: colors.primary.withAlpha(50),
                  ),
                  FilterChip(
                    label: const Text('Tasks'),
                    selected: _selectedType == 'task',
                    onSelected: (sel) => setSheetState(
                      () => _selectedType = sel ? 'task' : null,
                    ),
                    selectedColor: colors.primary.withAlpha(50),
                  ),
                  FilterChip(
                    label: const Text('Recurring'),
                    selected: _selectedType == 'recurring',
                    onSelected: (sel) => setSheetState(
                      () => _selectedType = sel ? 'recurring' : null,
                    ),
                    selectedColor: colors.primary.withAlpha(50),
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
                        selectedColor: colors.primary.withAlpha(50),
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
                    selectedColor: colors.primary.withAlpha(50),
                  ),
                  FilterChip(
                    label: const Text('Completed'),
                    selected: _selectedStatus == 'completed',
                    onSelected: (sel) => setSheetState(
                      () => _selectedStatus = sel ? 'completed' : null,
                    ),
                    selectedColor: colors.primary.withAlpha(50),
                  ),
                  FilterChip(
                    label: const Text('Archived'),
                    selected: _selectedStatus == 'archived',
                    onSelected: (sel) => setSheetState(
                      () => _selectedStatus = sel ? 'archived' : null,
                    ),
                    selectedColor: colors.primary.withAlpha(50),
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
                      selectedColor: colors.primary.withAlpha(50),
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
                          selectedColor: colors.primary.withAlpha(50),
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
                    backgroundColor: colors.primary,
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
    final colors = context.colors;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;
    final bgColor = colors.background;

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
          if (query.isNotEmpty && !h.name.toLowerCase().contains(lowerQuery)) {
            return false;
          }
          if (_selectedType != null && _selectedType != 'habit') return false;
          if (_selectedCategoryId != null &&
              h.categoryId != _selectedCategoryId) {
            return false;
          }
          if (_selectedPriority != null &&
              h.priorityLevel != _selectedPriority) {
            return false;
          }
          if (_selectedStatus == 'active' && h.isArchived) return false;
          if (_selectedStatus == 'archived' && !h.isArchived) return false;
          return true;
        })
        .map((h) => TodayItemData.habit(h))
        .toList();

    // Search tasks with filters
    var matchingTasks = state.tasks
        .where((t) {
          if (query.isNotEmpty && !t.title.toLowerCase().contains(lowerQuery)) {
            return false;
          }
          if (_selectedType != null && _selectedType != 'task') return false;
          if (_selectedCategoryId != null &&
              t.categoryId != _selectedCategoryId) {
            return false;
          }
          if (_selectedPriority != null &&
              t.priorityLevel != _selectedPriority) {
            return false;
          }
          if (_selectedStatus == 'active' && (t.isCompleted || t.isArchived)) {
            return false;
          }
          if (_selectedStatus == 'completed' && !t.isCompleted) return false;
          if (_selectedStatus == 'archived' && !t.isArchived) return false;
          return true;
        })
        .map((t) => TodayItemData.task(t))
        .toList();

    // Search recurring tasks with filters
    var matchingRecurring = state.recurringTasks
        .where((rt) {
          if (query.isNotEmpty && !rt.name.toLowerCase().contains(lowerQuery)) {
            return false;
          }
          if (_selectedType != null && _selectedType != 'recurring') {
            return false;
          }
          if (_selectedCategoryId != null &&
              rt.categoryId != _selectedCategoryId) {
            return false;
          }
          if (_selectedPriority != null &&
              rt.priorityLevel != _selectedPriority) {
            return false;
          }
          if (_selectedStatus == 'active' && rt.isArchived) return false;
          if (_selectedStatus == 'archived' && !rt.isArchived) return false;
          return true;
        })
        .map((rt) => TodayItemData.recurringTask(rt))
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
              color: colors.surfaceLight,
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
                  iconColor = colors.success;
                  subtitle = 'Habit • ${item.habit!.currentStreak} day streak';
                } else if (item.isRecurringTask) {
                  icon = Icons.repeat_rounded;
                  iconColor = CategoryPalette.of(context)[2];
                  subtitle =
                      'Recurring Task • ${item.recurringTask!.scheduleDaysLabel}';
                } else {
                  icon = Icons.check_circle_outline_rounded;
                  iconColor = colors.primary;
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

  Color _getPriorityColor(BuildContext context, int priority) {
    final colors = context.colors;
    if (priority > 10) return colors.danger;
    if (priority > 5) return colors.warning;
    if (priority > 0) return colors.info;
    if (priority == 0) return colors.textMuted;
    if (priority > -10) return colors.textSecondary;
    return colors.textMuted;
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
    final colors = context.colors;
    final textPrimary = colors.textPrimary;
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
                  color: _getPriorityColor(context, priority),
                ),
              ),
            ],
          ),
          Text(
            _getPriorityLabel(priority),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _getPriorityColor(context, priority),
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
                  activeColor: _getPriorityColor(context, priority),
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
                backgroundColor: _getPriorityColor(context, priority),
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
    final colors = context.colors;
    final isSelected = value == currentValue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : colors.primary,
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

  const _ActionButton({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textPrimary = colors.textPrimary;
    final textMuted = colors.textMuted;
    final actionColor = textPrimary;

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
          color: colors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colors.glassBorder.withAlpha(40),
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
