import 'dart:io';

import 'package:centile/models/category_model.dart';
import 'package:centile/models/growth_area.dart';
import 'package:centile/models/habit.dart';
import 'package:centile/models/habit_enums.dart';
import 'package:centile/models/reflection.dart';
import 'package:centile/models/reflection_reminder.dart';
import 'package:centile/models/recurring_task.dart';
import 'package:centile/models/subtask.dart';
import 'package:centile/models/task.dart';
import 'package:centile/models/user_stats.dart';
import 'package:centile/providers/app_state.dart';
import 'package:centile/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory hiveDirectory;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp(
      'centile-state-test-',
    );
    Hive.init(hiveDirectory.path);

    _registerAdapter(GrowthAreaAdapter());
    _registerAdapter(GrowthAreaTypeAdapter());
    _registerAdapter(HabitAdapter());
    _registerAdapter(HabitTypeAdapter());
    _registerAdapter(HabitLogAdapter());
    _registerAdapter(HabitEvaluationTypeAdapter());
    _registerAdapter(HabitFrequencyTypeAdapter());
    _registerAdapter(PriorityLevelAdapter());
    _registerAdapter(RecurringTaskAdapter());
    _registerAdapter(RecurringTaskLogAdapter());
    _registerAdapter(ReflectionAdapter());
    _registerAdapter(ReflectionReminderFrequencyAdapter());
    _registerAdapter(UserStatsAdapter());
    _registerAdapter(SubtaskAdapter());
    _registerAdapter(CategoryModelAdapter());
    _registerAdapter(TaskAdapter());
    _registerAdapter(TaskSourceAdapter());
    _registerAdapter(EisenhowerQuadrantAdapter());
    _registerAdapter(TaskEffortAdapter());
    _registerAdapter(TaskImpactAdapter());
    _registerAdapter(TaskAbandonReasonAdapter());

    await Future.wait([
      Hive.openBox<GrowthArea>(StorageService.factorsBox),
      Hive.openBox<Habit>(StorageService.habitsBox),
      Hive.openBox<Reflection>(StorageService.reflectionsBox),
      Hive.openBox<UserStats>(StorageService.userStatsBox),
      Hive.openBox<Subtask>(StorageService.subtasksBox),
      Hive.openBox<CategoryModel>(StorageService.categoriesBox),
      Hive.openBox<Task>(StorageService.tasksBox),
      Hive.openBox<RecurringTask>(StorageService.recurringTasksBox),
      Hive.openBox(StorageService.settingsBox),
    ]);
  });

  setUp(() async {
    await Future.wait([
      Hive.box<GrowthArea>(StorageService.factorsBox).clear(),
      Hive.box<Habit>(StorageService.habitsBox).clear(),
      Hive.box<Reflection>(StorageService.reflectionsBox).clear(),
      Hive.box<UserStats>(StorageService.userStatsBox).clear(),
      Hive.box<Subtask>(StorageService.subtasksBox).clear(),
      Hive.box<CategoryModel>(StorageService.categoriesBox).clear(),
      Hive.box<Task>(StorageService.tasksBox).clear(),
      Hive.box<RecurringTask>(StorageService.recurringTasksBox).clear(),
      Hive.box(StorageService.settingsBox).clear(),
    ]);
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  test('archiving a habit removes it from active habit caches', () async {
    final state = AppState();
    final habit = Habit(
      id: 'archive-habit',
      name: 'Read',
      type: HabitType.build,
    );

    await state.addHabit(habit);
    expect(state.buildHabits, contains(habit));

    habit.isArchived = true;
    await state.updateHabit(habit);

    expect(state.buildHabits, isNot(contains(habit)));
  });

  test('archived tasks are excluded from active and date getters', () {
    final state = AppState();
    final date = DateTime(2026, 7, 11);
    final archivedPriority = Task(
      id: 'archived-priority',
      title: 'Archived priority',
      isPriority: true,
      isArchived: true,
      scheduledDate: date,
    );
    final archivedBacklog = Task(
      id: 'archived-backlog',
      title: 'Archived backlog',
      isArchived: true,
      scheduledDate: date,
    );
    final visible = Task(
      id: 'visible-task',
      title: 'Visible',
      scheduledDate: date,
    );
    state.tasks.addAll([archivedPriority, archivedBacklog, visible]);

    expect(state.priorityTasks, isEmpty);
    expect(state.backlogTasks, [visible]);
    expect(state.getTasksForDate(date), [visible]);
  });

  test('loadData discards memoized results from the prior data set', () async {
    final state = AppState();
    state.tasks.add(Task(id: 'cached-task', title: 'Cached', isPriority: true));
    expect(state.priorityTasks.single.id, 'cached-task');

    final stored = Task(id: 'stored-task', title: 'Stored', isPriority: true);
    await StorageService.saveTask(stored);
    await state.loadData();

    expect(state.priorityTasks.map((task) => task.id), contains('stored-task'));
    expect(
      state.priorityTasks.map((task) => task.id),
      isNot(contains('cached-task')),
    );
  });

  test(
    'loadData clears caches populated during the loading notification',
    () async {
      final date = DateTime(2026, 7, 11);
      final state = AppState();
      state.tasks.add(
        Task(id: 'stale-task', title: 'Stale', scheduledDate: date),
      );
      await StorageService.saveTask(
        Task(id: 'stored-task', title: 'Stored', scheduledDate: date),
      );

      var populatedDuringLoad = false;
      state.addListener(() {
        if (!populatedDuringLoad && state.isLoading) {
          populatedDuringLoad = true;
          expect(
            state.getTodayDateData(date).allItems.single.task?.id,
            'stale-task',
          );
        }
      });

      await state.loadData();

      expect(populatedDuringLoad, isTrue);
      expect(
        state.getTodayDateData(date).allItems.map((item) => item.task?.id),
        contains('stored-task'),
      );
      expect(
        state.getTodayDateData(date).allItems.map((item) => item.task?.id),
        isNot(contains('stale-task')),
      );
    },
  );

  test(
    'category migration repairs legacy habits and recurring tasks',
    () async {
      final fallback = DefaultCategories.all.firstWhere(
        (category) => category.id == kFallbackCategoryId,
      );
      await StorageService.saveCategory(fallback);
      await StorageService.setCategoriesMigrationDone(true);
      await StorageService.saveHabit(
        Habit(id: 'legacy-habit', name: 'Legacy', type: HabitType.build),
      );
      await StorageService.saveRecurringTask(
        RecurringTask(
          id: 'dangling-recurring',
          name: 'Dangling',
          categoryId: 'missing-category',
        ),
      );

      final state = AppState();
      await state.loadData();

      expect(state.habits.single.categoryId, kFallbackCategoryId);
      expect(state.recurringTasks.single.categoryId, kFallbackCategoryId);
      expect(
        StorageService.getAllHabits().single.categoryId,
        kFallbackCategoryId,
      );
      expect(
        StorageService.getAllRecurringTasks().single.categoryId,
        kFallbackCategoryId,
      );
    },
  );

  test('factor membership changes invalidate cached goal progress', () async {
    final state = AppState();
    final first = GrowthArea(
      id: 'factor-one',
      name: 'First',
      type: GrowthAreaType.skill,
      goalId: 'goal',
      targetLevel: 10,
      currentLevel: 1,
    );
    final second = GrowthArea(
      id: 'factor-two',
      name: 'Second',
      type: GrowthAreaType.skill,
      goalId: 'goal',
      targetLevel: 10,
      currentLevel: 10,
    );

    await state.addFactor(first);
    expect(state.getGoalProgress('goal'), 0.1);

    await state.addFactor(second);
    expect(state.getGoalProgress('goal'), closeTo(0.19, 0.0001));

    await state.deleteFactor(second.id);
    expect(state.getGoalProgress('goal'), 0.1);
  });

  test('toggleSubtask persists the changed completion state', () async {
    final state = AppState();
    final subtask = Subtask(
      id: 'toggle-subtask',
      title: 'First step',
      parentTaskId: 'parent',
    );
    await StorageService.saveSubtask(subtask);

    await state.toggleSubtask(subtask.id);

    expect(StorageService.getSubtask(subtask.id)?.isCompleted, isTrue);
  });

  test('adding a reflection updates reminder tracking', () async {
    final state = AppState();
    await StorageService.saveUserStats(state.userStats);
    final before = DateTime.now();

    await state.addReflection(
      Reflection(
        id: 'completed-reflection',
        experience: 'Experience',
        reflection: 'Reflection',
        abstraction: 'Abstraction',
        experimentIds: const ['experiment'],
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(state.userStats.lastReflectionAt, isNotNull);
    expect(state.userStats.lastReflectionAt!.isBefore(before), isFalse);
    expect(state.userStats.unlockedBadgeIds, contains('first_reflection'));
  });

  test(
    'category reassignment refreshes cached Today item categories',
    () async {
      final state = AppState();
      final from = CategoryModel.create(
        id: 'from-category',
        name: 'From',
        icon: Icons.home,
        color: Colors.blue,
      );
      final to = CategoryModel.create(
        id: 'to-category',
        name: 'To',
        icon: Icons.work,
        color: Colors.green,
      );
      await state.addCategory(from);
      await state.addCategory(to);

      final habit = Habit(
        id: 'recategorized-habit',
        name: 'Practice',
        type: HabitType.build,
        categoryId: from.id,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      await state.addHabit(habit);
      expect(
        state.getTodayDateData(DateTime.now()).allItems.single.category?.id,
        from.id,
      );

      await state.reassignCategory(from.id, to.id);

      expect(
        state.getTodayDateData(DateTime.now()).allItems.single.category?.id,
        to.id,
      );
    },
  );

  test('habit logs target the requested date and reward only once', () async {
    final state = AppState();
    await StorageService.saveUserStats(state.userStats);
    final date = DateTime(2026, 7, 10);
    final firstFactor = GrowthArea(
      id: 'linked-factor-one',
      name: 'First',
      type: GrowthAreaType.skill,
      goalId: 'goal',
      isActiveFocus: true,
    );
    final secondFactor = GrowthArea(
      id: 'linked-factor-two',
      name: 'Second',
      type: GrowthAreaType.skill,
      goalId: 'goal',
      isActiveFocus: true,
    );
    await state.addFactor(firstFactor);
    await state.addFactor(secondFactor);
    final habit = Habit(
      id: 'dated-habit',
      name: 'Practice',
      type: HabitType.build,
      linkedFactorIds: [firstFactor.id, secondFactor.id],
    );
    await state.addHabit(habit);

    await state.logHabit(habit.id, date: date, completed: true);
    final rewardedXp = state.userStats.totalXP;
    await state.updateHabitLogNote(habit.id, date: date, note: 'Kept note');

    expect(habit.isCompletedFor(date), isTrue);
    expect(habit.isCompletedFor(DateTime.now()), isFalse);
    expect(habit.completionCount, 1);
    expect(habit.getLogFor(date)?.note, 'Kept note');
    expect(state.userStats.totalXP, rewardedXp);
    expect(firstFactor.lastWorkedOn, isNotNull);
    expect(secondFactor.lastWorkedOn, isNotNull);
  });

  test('task completion rewards cannot be farmed by undoing', () async {
    final state = AppState();
    await StorageService.saveUserStats(state.userStats);
    final task = Task(id: 'rewarded-task', title: 'Finish');
    await state.addTask(task);

    await state.toggleTaskComplete(task.id);
    final rewardedXp = state.userStats.totalXP;
    await state.toggleTaskComplete(task.id);
    await state.toggleTaskComplete(task.id);

    expect(task.isCompleted, isTrue);
    expect(state.userStats.totalXP, rewardedXp);
    expect(state.userStats.totalTasksCompleted, 1);
  });

  test('recurring completion and note edits reward once', () async {
    final state = AppState();
    await StorageService.saveUserStats(state.userStats);
    final date = DateTime(2026, 7, 11);
    final task = RecurringTask(
      id: 'recurring-reward',
      name: 'Weekly review',
      categoryId: 'general',
    );
    await state.addRecurringTask(task);

    await state.logRecurringTaskCompletion(
      task.id,
      date: date,
      completed: true,
    );
    final rewardedXp = state.userStats.totalXP;
    await state.updateRecurringTaskLogNote(
      task.id,
      date: date,
      note: 'Reviewed',
    );

    expect(task.getLogFor(date)?.note, 'Reviewed');
    expect(state.userStats.totalXP, rewardedXp);
  });

  test('legacy habit reward remains claimed after editing its note', () async {
    final state = AppState();
    await StorageService.saveUserStats(state.userStats);
    final date = DateTime.now().subtract(const Duration(days: 1));
    final habit = Habit(
      id: 'legacy-habit-reward',
      name: 'Legacy habit',
      type: HabitType.build,
      completionCount: 1,
      logs: [HabitLog(date: date, completed: true)],
    );
    await state.addHabit(habit);

    await state.updateHabitLogNote(habit.id, date: date, note: 'Edited');
    final xpBeforeToggle = state.userStats.totalXP;
    await state.logHabit(habit.id, date: date, completed: false);
    await state.logHabit(habit.id, date: date, completed: true);

    expect(habit.getLogFor(date)?.rewardGranted, isTrue);
    expect(state.userStats.totalXP, xpBeforeToggle);
  });

  test(
    'legacy recurring reward remains claimed after editing its note',
    () async {
      final state = AppState();
      await StorageService.saveUserStats(state.userStats);
      final date = DateTime.now().subtract(const Duration(days: 1));
      final task = RecurringTask(
        id: 'legacy-recurring-reward',
        name: 'Legacy recurring task',
        categoryId: 'general',
        logs: [RecurringTaskLog(date: date, completed: true)],
      );
      await state.addRecurringTask(task);

      await state.updateRecurringTaskLogNote(
        task.id,
        date: date,
        note: 'Edited',
      );
      final xpBeforeToggle = state.userStats.totalXP;
      await state.logRecurringTaskCompletion(
        task.id,
        date: date,
        completed: false,
      );
      await state.logRecurringTaskCompletion(
        task.id,
        date: date,
        completed: true,
      );

      expect(task.getLogFor(date)?.rewardGranted, isTrue);
      expect(state.userStats.totalXP, xpBeforeToggle);
    },
  );

  test('pending task completion uses the selected Today date', () async {
    final state = AppState();
    await StorageService.saveUserStats(state.userStats);
    final selectedDate = DateTime.now().subtract(const Duration(days: 2));
    final task = Task(
      id: 'selected-date-task',
      title: 'Rolling task',
      isPending: true,
      scheduledDate: selectedDate.subtract(const Duration(days: 5)),
    );
    await state.addTask(task);

    await state.toggleTaskComplete(task.id, completionDate: selectedDate);

    expect(task.completedAt, selectedDate);
    expect(state.getTodayTasksForDate(selectedDate), contains(task));
    expect(
      state.getTodayTasksForDate(task.scheduledDate),
      isNot(contains(task)),
    );
  });

  test('future dated check-ins are ignored', () async {
    final state = AppState();
    await StorageService.saveUserStats(state.userStats);
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final habit = Habit(
      id: 'future-habit',
      name: 'Future habit',
      type: HabitType.build,
    );
    final recurring = RecurringTask(
      id: 'future-recurring',
      name: 'Future recurring',
      categoryId: 'general',
    );
    final task = Task(id: 'future-task', title: 'Future task');
    await state.addHabit(habit);
    await state.addRecurringTask(recurring);
    await state.addTask(task);
    final xpBefore = state.userStats.totalXP;

    await state.logHabit(habit.id, date: tomorrow, completed: true);
    await state.logRecurringTaskCompletion(
      recurring.id,
      date: tomorrow,
      completed: true,
    );
    await state.toggleTaskComplete(task.id, completionDate: tomorrow);

    expect(habit.getLogFor(tomorrow), isNull);
    expect(recurring.getLogFor(tomorrow), isNull);
    expect(task.isCompleted, isFalse);
    expect(state.userStats.totalXP, xpBefore);
  });

  test('tree purchase updates coins and notifies the shop', () async {
    final state = AppState();
    state.userStats.coins = 100;
    await StorageService.saveUserStats(state.userStats);
    var notificationCount = 0;
    state.addListener(() => notificationCount++);

    final purchased = state.purchaseTreeDesign(designId: 'willow', cost: 40);

    expect(purchased, isTrue);
    expect(state.userStats.coins, 60);
    expect(state.userStats.unlockedBadgeIds, contains('tree_willow'));
    expect(notificationCount, 1);
  });

  test(
    'perfect week achievement is reachable from seven complete days',
    () async {
      final state = AppState();
      await StorageService.saveUserStats(state.userStats);
      final today = DateUtils.dateOnly(DateTime.now());
      final habit = Habit(
        id: 'perfect-week-habit',
        name: 'Daily practice',
        type: HabitType.build,
        startDate: today.subtract(const Duration(days: 6)),
        logs: [
          for (var offset = 0; offset < 7; offset++)
            HabitLog(
              date: today.subtract(Duration(days: offset)),
              completed: true,
              rewardGranted: true,
            ),
        ],
      );
      state.habits.add(habit);

      state.checkAchievements();

      expect(state.userStats.unlockedBadgeIds, contains('perfect_week'));
    },
  );

  test(
    'an unfinished priority task is not an empty-backlog achievement',
    () async {
      final state = AppState();
      await StorageService.saveUserStats(state.userStats);
      state.tasks.add(
        Task(id: 'unfinished-priority', title: 'Priority', isPriority: true),
      );

      state.checkAchievements();

      expect(state.userStats.unlockedBadgeIds, isNot(contains('zero_backlog')));
    },
  );
}

void _registerAdapter<T>(TypeAdapter<T> adapter) {
  if (!Hive.isAdapterRegistered(adapter.typeId)) {
    Hive.registerAdapter(adapter);
  }
}
