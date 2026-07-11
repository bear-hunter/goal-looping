import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../models/growth_area.dart';
import '../models/sprint_target.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/habit.dart';
import '../models/habit_enums.dart';
import '../models/barrier_tag.dart';
import '../models/category_model.dart';
import '../models/recurring_task.dart';
import '../models/reflection.dart';
import '../models/reflection_group.dart';
import '../models/experiment.dart';
import '../models/time_availability.dart';
import '../models/user_stats.dart';
import '../models/achievement.dart';
import '../models/focus_log.dart';
import '../models/spaced_repetition_subject.dart';
import '../models/spaced_repetition_topic.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class TodayDateData {
  final List<TodayItemData> allItems;
  final List<TodayItemData> topTasks;
  final List<TodayItemData> habitRoutine;
  final List<TodayItemData> completedItems;
  final int completedCount;
  final int totalCount;

  const TodayDateData({
    required this.allItems,
    required this.topTasks,
    required this.habitRoutine,
    required this.completedItems,
    required this.completedCount,
    required this.totalCount,
  });
}

class TodayItemData {
  final Habit? habit;
  final Task? task;
  final RecurringTask? recurringTask;
  final CategoryModel? category;
  final bool isCompleted;
  final int? score;

  const TodayItemData._({
    this.habit,
    this.task,
    this.recurringTask,
    this.category,
    required this.isCompleted,
    this.score,
  });

  factory TodayItemData.habit(
    Habit habit, {
    DateTime? date,
    CategoryModel? category,
  }) {
    final log = habit.getLogFor(date ?? DateTime.now());
    return TodayItemData._(
      habit: habit,
      category: category,
      isCompleted: log?.completed ?? false,
      score: log?.score,
    );
  }

  factory TodayItemData.task(Task task, {CategoryModel? category}) {
    return TodayItemData._(
      task: task,
      category: category,
      isCompleted: task.isCompleted,
    );
  }

  factory TodayItemData.recurringTask(
    RecurringTask recurringTask, {
    DateTime? date,
    CategoryModel? category,
  }) {
    return TodayItemData._(
      recurringTask: recurringTask,
      category: category,
      isCompleted: recurringTask.isCompletedFor(date ?? DateTime.now()),
    );
  }

  bool get isHabit => habit != null;
  bool get isTask => task != null;
  bool get isRecurringTask => recurringTask != null;

  int get sortOrder => isHabit
      ? habit!.sortOrder
      : (isRecurringTask ? recurringTask!.sortOrder : task!.sortOrder);

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

  String get stableKey {
    if (isHabit) return 'h_${habit!.id}';
    if (isRecurringTask) return 'rt_${recurringTask!.id}';
    return 't_${task!.id}';
  }
}

/// Main application state using ChangeNotifier
class AppState extends ChangeNotifier {
  // ========== DATA ==========
  List<Goal> _goals = [];
  List<Factor> _factors = [];
  List<SprintTarget> _sprintTargets = [];
  List<Task> _tasks = [];
  List<Habit> _habits = [];
  List<Reflection> _reflections = [];
  List<Experiment> _experiments = [];
  List<BarrierEntry> _barriers = [];
  TimeAvailability? _timeAvailability;
  UserStats _userStats = UserStats();
  List<FocusLog> _focusLogs = [];
  List<ReflectionGroup> _reflectionGroups = [];
  List<CategoryModel> _categories = [];
  List<RecurringTask> _recurringTasks = [];
  List<SpacedRepetitionSubject> _srSubjects = [];
  List<SpacedRepetitionTopic> _srTopics = [];
  bool _isLoading = true;

  // ========== MEMOIZATION CACHES (Phase 1: Performance Optimization) ==========
  // These caches prevent O(N log N) operations from running on every getter access
  List<Task>? _cachedPriorityTasks;
  List<Task>? _cachedBacklogTasks;
  List<Task>? _cachedCompletedTasks;
  List<Habit>? _cachedBuildHabits;
  List<Habit>? _cachedQuitHabits;
  List<Habit>? _cachedTimedHabits;
  List<Factor>? _cachedFactorsWithGap;
  Map<String, List<Habit>>? _cachedHabitsForDate;
  Map<String, List<Task>>? _cachedTasksForDate;
  Map<String, List<Task>>? _cachedTodayTasksForDate;
  Map<String, List<RecurringTask>>? _cachedRecurringTasksForDate;
  Map<String, TodayDateData>? _cachedTodayDataByDate;
  Map<String, CategoryModel>? _cachedCategoryById;

  // Debounce for achievement checks
  bool _achievementCheckScheduled = false;

  // ========== GETTERS ==========
  List<Goal> get goals => _goals;
  List<Factor> get factors => _factors;
  List<SprintTarget> get sprintTargets => _sprintTargets;
  List<Task> get tasks => _tasks;
  List<Habit> get habits => _habits;
  List<Reflection> get reflections => _reflections;
  List<Experiment> get experiments => _experiments;
  List<BarrierEntry> get barriers => _barriers;
  TimeAvailability? get timeAvailability => _timeAvailability;
  UserStats get userStats => _userStats;
  List<FocusLog> get focusLogs => _focusLogs;
  List<ReflectionGroup> get reflectionGroups => _reflectionGroups;
  List<CategoryModel> get categories => _categories;
  List<RecurringTask> get recurringTasks => _recurringTasks;
  List<SpacedRepetitionSubject> get srSubjects => _srSubjects;
  List<SpacedRepetitionTopic> get srTopics => _srTopics;
  bool get isLoading => _isLoading;

  // Computed getters
  Goal? get activeGoal => _goals.isNotEmpty ? _goals.first : null;

  /// Priority tasks with memoization - O(1) after first access until cache invalidated
  List<Task> get priorityTasks {
    if (_cachedPriorityTasks != null) return _cachedPriorityTasks!;
    _cachedPriorityTasks =
        _tasks
            .where(
              (t) =>
                  t.isPriority &&
                  !t.isCompleted &&
                  !t.isArchived &&
                  t.quadrant != EisenhowerQuadrant.delete,
            )
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return _cachedPriorityTasks!;
  }

  /// Backlog tasks with memoization - O(1) after first access until cache invalidated
  List<Task> get backlogTasks {
    if (_cachedBacklogTasks != null) return _cachedBacklogTasks!;
    _cachedBacklogTasks =
        _tasks
            .where(
              (t) =>
                  !t.isPriority &&
                  !t.isCompleted &&
                  !t.isArchived &&
                  t.quadrant != EisenhowerQuadrant.delete,
            )
            .toList()
          ..sort((a, b) {
            // Sort by deadline if available, then by sortOrder
            if (a.deadline != null && b.deadline != null) {
              return a.deadline!.compareTo(b.deadline!);
            }
            if (a.deadline != null) return -1;
            if (b.deadline != null) return 1;
            return a.sortOrder.compareTo(b.sortOrder);
          });
    return _cachedBacklogTasks!;
  }

  /// Completed tasks with memoization
  List<Task> get completedTasks {
    if (_cachedCompletedTasks != null) return _cachedCompletedTasks!;
    _cachedCompletedTasks = _tasks.where((t) => t.isCompleted).toList();
    return _cachedCompletedTasks!;
  }

  bool get canAddPriorityTask => priorityTasks.length < 2;

  /// Invalidate all task-related caches. Call this after any task mutation.
  void _invalidateTaskCaches() {
    _cachedPriorityTasks = null;
    _cachedBacklogTasks = null;
    _cachedCompletedTasks = null;
    _cachedTasksForDate = null;
    _cachedTodayTasksForDate = null;
    _cachedTodayDataByDate = null;
  }

  /// Invalidate all habit-related caches. Call this after any habit mutation.
  void _invalidateHabitCaches() {
    _cachedBuildHabits = null;
    _cachedQuitHabits = null;
    _cachedTimedHabits = null;
    _cachedHabitsForDate = null;
    _cachedTodayDataByDate = null;
  }

  /// Invalidate factor-related caches.
  void _invalidateFactorCaches() {
    _cachedFactorsWithGap = null;
  }

  /// Invalidate recurring task caches.
  void _invalidateRecurringTaskCaches() {
    _cachedRecurringTasksForDate = null;
    _cachedTodayDataByDate = null;
  }

  void _invalidateCategoryCaches() {
    _cachedCategoryById = null;
    _cachedTodayDataByDate = null;
  }

  void _invalidateAllCaches() {
    _invalidateTaskCaches();
    _invalidateHabitCaches();
    _invalidateFactorCaches();
    _invalidateRecurringTaskCaches();
    _invalidateCategoryCaches();
    invalidateGoalProgressCache();
  }

  void invalidateTodayCacheFor(DateTime date) {
    final key = _dateKey(date);
    _cachedTasksForDate?.remove(key);
    _cachedTodayTasksForDate?.remove(key);
    _cachedHabitsForDate?.remove(key);
    _cachedRecurringTasksForDate?.remove(key);
    _cachedTodayDataByDate?.remove(key);
  }

  // Phase 2: Updated habit type getters with memoization
  List<Habit> get buildHabits {
    if (_cachedBuildHabits != null) return _cachedBuildHabits!;
    _cachedBuildHabits = _habits
        .where((h) => h.type == HabitType.build && h.isActive && !h.isArchived)
        .toList();
    return _cachedBuildHabits!;
  }

  List<Habit> get quitHabits {
    if (_cachedQuitHabits != null) return _cachedQuitHabits!;
    _cachedQuitHabits = _habits
        .where((h) => h.type == HabitType.quit && h.isActive && !h.isArchived)
        .toList();
    return _cachedQuitHabits!;
  }

  List<Habit> get timedHabits {
    if (_cachedTimedHabits != null) return _cachedTimedHabits!;
    _cachedTimedHabits = _habits
        .where((h) => h.type == HabitType.timed && h.isActive && !h.isArchived)
        .toList();
    return _cachedTimedHabits!;
  }

  // Legacy aliases for backward compatibility
  List<Habit> get limitingHabits => quitHabits;
  List<Habit> get scriptedActions => buildHabits;

  List<Experiment> get pendingExperiments =>
      _experiments.where((e) => e.status == ExperimentStatus.pending).toList();

  /// Factors with gap - memoized
  List<Factor> get factorsWithGap {
    if (_cachedFactorsWithGap != null) return _cachedFactorsWithGap!;
    _cachedFactorsWithGap = _factors.where((f) => f.gap > 0).toList()
      ..sort((a, b) => b.gap.compareTo(a.gap));
    return _cachedFactorsWithGap!;
  }

  Factor? get biggestGapFactor =>
      factorsWithGap.isNotEmpty ? factorsWithGap.first : null;

  // ========== LOAD DATA ==========
  Future<void> loadData() async {
    _isLoading = true;
    _invalidateAllCaches();
    notifyListeners();

    // Ensure boxes are open (handles hot reload scenarios)
    if (!StorageService.isInitialized) {
      try {
        await StorageService.reopenBoxes();
      } catch (e) {
        debugPrint('Failed to reopen boxes during loadData: $e');
      }
    }

    try {
      _goals = StorageService.getAllGoals();
    } catch (e) {
      debugPrint('ERROR loading goals: $e');
      _goals = [];
    }

    try {
      _factors = StorageService.getAllFactors();
    } catch (e) {
      debugPrint('ERROR loading factors: $e');
      _factors = [];
    }

    try {
      _sprintTargets = StorageService.getAllSprintTargets();
    } catch (e) {
      debugPrint('ERROR loading sprint targets: $e');
      _sprintTargets = [];
    }

    try {
      _tasks = StorageService.getAllTasks();
    } catch (e) {
      debugPrint('ERROR loading tasks: $e');
      _tasks = [];
    }

    try {
      _habits = StorageService.getAllHabits();
    } catch (e) {
      debugPrint('ERROR loading habits: $e');
      _habits = [];
    }

    try {
      _reflections = StorageService.getAllReflections();
    } catch (e) {
      debugPrint('ERROR loading reflections: $e');
      _reflections = [];
    }

    try {
      _experiments = StorageService.getAllExperiments();
    } catch (e) {
      debugPrint('ERROR loading experiments: $e');
      _experiments = [];
    }

    try {
      _barriers = StorageService.getAllBarriers();
    } catch (e) {
      debugPrint('ERROR loading barriers: $e');
      _barriers = [];
    }

    try {
      _timeAvailability = StorageService.getTimeAvailability();
    } catch (e) {
      debugPrint('ERROR loading time availability: $e');
      _timeAvailability = null;
    }

    try {
      _userStats = StorageService.getUserStats();
    } catch (e) {
      debugPrint('ERROR loading user stats: $e');
      _userStats = UserStats();
    }

    try {
      _focusLogs = StorageService.getAllFocusLogs();
    } catch (e) {
      debugPrint('ERROR loading focus logs: $e');
      _focusLogs = [];
    }

    try {
      _reflectionGroups = StorageService.getAllReflectionGroups();
    } catch (e) {
      _reflectionGroups = [];
    }

    // Phase 3: Load categories and recurring tasks
    try {
      _categories = StorageService.getAllCategories();
      // Initialize default categories if none exist
      if (_categories.isEmpty) {
        await StorageService.initializeDefaultCategories();
        _categories = StorageService.getAllCategories();
      }
    } catch (e) {
      _categories = [];
    }

    try {
      _recurringTasks = StorageService.getAllRecurringTasks();
    } catch (e) {
      _recurringTasks = [];
    }

    // Spaced Repetition
    try {
      _srSubjects = StorageService.getAllSubjects();
    } catch (e) {
      _srSubjects = [];
    }

    try {
      _srTopics = StorageService.getAllTopics();
    } catch (e) {
      _srTopics = [];
    }

    // Run migration for legacy string-based categories
    await _migrateLegacyCategories();
    // Unify legacy barrier data onto the redesigned BarrierEntry.
    await _migrateBarriers();
    await _resyncAllReminders();

    // Widgets can populate derived caches while the async migrations above
    // yield. Clear those snapshots so the first non-loading frame is built
    // exclusively from the migrated data.
    _invalidateAllCaches();
    _isLoading = false;
    scheduleAchievementCheck();
    notifyListeners();
  }

  /// Folds the legacy string-based category system into [CategoryModel] and
  /// keeps every categorized item linked to a category that still exists.
  ///
  /// Legacy-name ingestion is one-time, while the inexpensive referential
  /// repair remains active so installs that already ran the older task-only
  /// migration also repair habits and recurring tasks.
  Future<void> _migrateLegacyCategories() async {
    final migrationDone = StorageService.categoriesMigrationDone;
    var changed = false;

    final byName = {for (final c in _categories) c.name.toLowerCase(): c};

    // (1) Ingest legacy taskCategories strings that have no CategoryModel yet.
    if (!migrationDone) {
      for (final legacy in StorageService.getLegacyTaskCategories()) {
        final name = legacy.trim();
        final key = name.toLowerCase();
        if (name.isEmpty || key == 'general' || byName.containsKey(key)) {
          continue;
        }
        final created = CategoryModel.create(
          id: const Uuid().v4(),
          name: name,
          icon: Icons.category_rounded,
          color: DefaultCategories.availableColors.first,
          sortOrder: _categories.length,
        );
        await StorageService.saveCategory(created);
        _categories.add(created);
        byName[key] = created;
        changed = true;
      }
    }

    // Guarantee the fallback category exists (a seeded, non-deletable default).
    final validIds = {for (final c in _categories) c.id};
    if (!validIds.contains(kFallbackCategoryId)) {
      final fallback = DefaultCategories.all.firstWhere(
        (c) => c.id == kFallbackCategoryId,
      );
      await StorageService.saveCategory(fallback);
      _categories.add(fallback);
      validIds.add(fallback.id);
      changed = true;
    }

    // (2) Every task ends with a non-null, resolvable categoryId — linked by
    // legacy name, or to the fallback when empty/General/dangling.
    for (final task in _tasks) {
      final current = task.categoryId;
      if (current != null && validIds.contains(current)) continue;

      String? resolved;
      final legacyName = task.category.trim();
      if (legacyName.isNotEmpty && legacyName.toLowerCase() != 'general') {
        resolved = byName[legacyName.toLowerCase()]?.id;
      }
      task.categoryId = resolved ?? kFallbackCategoryId;
      await StorageService.saveTask(task);
      changed = true;
    }

    // Legacy habits have no category name to map, so use the stable fallback.
    for (final habit in _habits) {
      final current = habit.categoryId;
      if (current != null && validIds.contains(current)) continue;
      habit.categoryId = kFallbackCategoryId;
      await StorageService.saveHabit(habit);
      changed = true;
    }

    for (final recurringTask in _recurringTasks) {
      if (validIds.contains(recurringTask.categoryId)) continue;
      recurringTask.categoryId = kFallbackCategoryId;
      await StorageService.saveRecurringTask(recurringTask);
      changed = true;
    }

    if (!migrationDone) {
      await StorageService.setCategoriesMigrationDone(true);
    }
    if (changed) {
      _invalidateTaskCaches();
      _invalidateHabitCaches();
      _invalidateRecurringTaskCaches();
      _invalidateCategoryCaches();
      notifyListeners();
    }
  }

  /// Unifies legacy barrier data onto the redesigned [BarrierEntry].
  ///
  /// Idempotent without a flag: Part A only touches entries whose [tag] is
  /// still null, and Part B uses deterministic ids so re-runs overwrite an
  /// existing record instead of creating a duplicate.
  Future<void> _migrateBarriers() async {
    var changed = false;

    // (A) Upgrade legacy free-text BarrierEntry records to tagged ones.
    for (final barrier in _barriers) {
      if (barrier.tag != null) continue;
      final key = BarrierTags.keyForLegacyLabel(barrier.description);
      if (key != null) {
        barrier.tag = key;
      } else {
        barrier.tag = 'other';
        if (barrier.description.trim().isNotEmpty) {
          barrier.note = barrier.description;
        }
      }
      await StorageService.saveBarrier(barrier);
      changed = true;
    }

    // (B) Materialize a linked BarrierEntry for every HabitLog.barrierTag.
    // HabitLog.barrierTag is intentionally left in place (avoids mass writes).
    final existingIds = {for (final b in _barriers) b.id};
    for (final habit in _habits) {
      for (final log in habit.logs) {
        final rawTag = log.barrierTag;
        if (rawTag == null || rawTag.trim().isEmpty) continue;
        final isoDate = log.date.toIso8601String().split('T').first;
        final id = 'migrated-${habit.id}-$isoDate';
        if (existingIds.contains(id)) continue;
        final resolvedKey = BarrierTags.keyForLegacyLabel(rawTag);
        final entry = BarrierEntry(
          id: id,
          occurredAt: log.date,
          tag: resolvedKey ?? 'other',
          note: resolvedKey == null ? rawTag : null,
          linkedHabitId: habit.id,
          moodRating: log.moodRating,
        );
        await StorageService.saveBarrier(entry);
        _barriers.add(entry);
        existingIds.add(id);
        changed = true;
      }
    }

    if (changed) notifyListeners();
  }

  // ========== GOALS ==========
  Future<void> addGoal(Goal goal) async {
    await StorageService.saveGoal(goal);
    _goals.add(goal);
    scheduleAchievementCheck();
    notifyListeners();
  }

  Future<void> updateGoal(Goal goal) async {
    await StorageService.saveGoal(goal);
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) _goals[index] = goal;
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    await StorageService.deleteGoal(id);
    _goals.removeWhere((g) => g.id == id);
    // Also remove associated factors
    final factorIds = _factors
        .where((f) => f.goalId == id)
        .map((f) => f.id)
        .toList();
    for (final factorId in factorIds) {
      await deleteFactor(factorId);
    }
    notifyListeners();
  }

  // ========== FACTORS ==========
  Future<void> addFactor(Factor factor) async {
    await StorageService.saveFactor(factor);
    _factors.add(factor);
    _invalidateFactorCaches();
    invalidateGoalProgressCache();
    scheduleAchievementCheck();
    notifyListeners();
  }

  Future<void> updateFactor(Factor factor) async {
    await StorageService.saveFactor(factor);
    final index = _factors.indexWhere((f) => f.id == factor.id);
    if (index != -1) _factors[index] = factor;
    _invalidateFactorCaches();
    invalidateGoalProgressCache(); // Re-calculate Goal progress after Factor update
    scheduleAchievementCheck();
    notifyListeners();
  }

  Future<void> deleteFactor(String id) async {
    await StorageService.deleteFactor(id);
    _factors.removeWhere((f) => f.id == id);
    _invalidateFactorCaches();
    invalidateGoalProgressCache();
    notifyListeners();
  }

  // Phase 5: Focus Factor System
  List<Factor> get activeFocusFactors =>
      _factors.where((f) => f.isActiveFocus).toList();

  List<Factor> get dormantFactors =>
      _factors.where((f) => !f.isActiveFocus).toList();

  bool get canAddActiveFocus => activeFocusFactors.length < 2;

  Future<void> setFactorActive(String id) async {
    if (!canAddActiveFocus) {
      throw Exception('Cannot have more than 2 active focus Factors');
    }
    final factor = _factors.firstWhere((f) => f.id == id);
    factor.isActiveFocus = true;
    factor.lastWorkedOn = DateTime.now();
    factor.healthPercent = 100.0; // Start fresh
    await StorageService.saveFactor(factor);
    notifyListeners();
  }

  Future<void> setFactorDormant(String id) async {
    final factor = _factors.firstWhere((f) => f.id == id);
    factor.isActiveFocus = false;
    // Health is preserved but frozen
    await StorageService.saveFactor(factor);
    notifyListeners();
  }

  Future<void> logWorkOnFactor(String factorId) async {
    final factor = _factors.firstWhere((f) => f.id == factorId);
    factor.logWork();
    await StorageService.saveFactor(factor);
    notifyListeners();
  }

  Future<void> resurrectFactor(String id) async {
    if (!_userStats.spendCoins(50)) {
      throw Exception('Not enough coins to resurrect (need 50)');
    }
    final factor = _factors.firstWhere((f) => f.id == id);
    factor.resurrect();
    await StorageService.saveFactor(factor);
    triggerResurrectionAchievement();
    notifyListeners();
  }

  bool purchaseTreeDesign({required String designId, required int cost}) {
    if (_userStats.unlockedBadgeIds.contains('tree_$designId')) return true;
    if (!_userStats.spendCoins(cost)) return false;
    _userStats.unlockBadge('tree_$designId');
    notifyListeners();
    return true;
  }

  List<Factor> getFactorsForGoal(String goalId) =>
      _factors.where((f) => f.goalId == goalId).toList();

  // ========== SPRINT TARGETS ==========
  /// Add sprint target with optimistic UI pattern
  Future<void> addSprintTarget(SprintTarget target) async {
    // OPTIMISTIC: Add to local state first
    _sprintTargets.add(target);
    notifyListeners();

    // Persist in background
    StorageService.saveSprintTarget(target).catchError((e) {
      debugPrint('Sprint target save failed: $e');
    });
  }

  /// Update sprint target with optimistic UI pattern
  Future<void> updateSprintTarget(SprintTarget target) async {
    // OPTIMISTIC: Update local state first
    final index = _sprintTargets.indexWhere((t) => t.id == target.id);
    if (index != -1) _sprintTargets[index] = target;
    notifyListeners();

    // Persist in background
    StorageService.saveSprintTarget(target).catchError((e) {
      debugPrint('Sprint target update failed: $e');
    });
  }

  /// Delete sprint target with optimistic UI pattern
  Future<void> deleteSprintTarget(String id) async {
    // OPTIMISTIC: Remove from local state first
    _sprintTargets.removeWhere((t) => t.id == id);
    notifyListeners();

    // Persist in background
    StorageService.deleteSprintTarget(id).catchError((e) {
      debugPrint('Sprint target delete failed: $e');
    });
  }

  /// Mark sprint target as completed with optimistic UI pattern
  Future<void> markSprintComplete(String id) async {
    // OPTIMISTIC: Update local state first
    final target = _sprintTargets.firstWhere((t) => t.id == id);
    target.isCompleted = true;
    target.isFailed = false;
    target.completedAt = DateTime.now();
    notifyListeners();

    // Persist in background
    StorageService.saveSprintTarget(target).catchError((e) {
      debugPrint('Sprint target complete failed: $e');
    });
  }

  /// Mark sprint target as failed with optimistic UI pattern
  Future<void> markSprintFailed(String id) async {
    // OPTIMISTIC: Update local state first
    final target = _sprintTargets.firstWhere((t) => t.id == id);
    target.isFailed = true;
    target.isCompleted = false;
    target.completedAt = DateTime.now();
    notifyListeners();

    // Persist in background
    StorageService.saveSprintTarget(target).catchError((e) {
      debugPrint('Sprint target fail failed: $e');
    });
  }

  /// Reset sprint target to active (undo complete/failed) with optimistic UI
  Future<void> resetSprintTarget(String id) async {
    // OPTIMISTIC: Update local state first
    final target = _sprintTargets.firstWhere((t) => t.id == id);
    target.isCompleted = false;
    target.isFailed = false;
    target.completedAt = null;
    notifyListeners();

    // Persist in background
    StorageService.saveSprintTarget(target).catchError((e) {
      debugPrint('Sprint target reset failed: $e');
    });
  }

  // ========== TASKS ==========
  Future<void> addTask(Task task) async {
    if (task.isPriority && !canAddPriorityTask) {
      throw Exception('Cannot add more than 2 priority tasks');
    }

    // Add to local state first (optimistic update)
    _tasks.add(task);
    _invalidateTaskCaches();
    notifyListeners();

    // Then persist to storage with error handling
    try {
      await StorageService.saveTask(task);
      await _syncTaskReminder(task);
    } catch (e) {
      debugPrint('Failed to save task: $e');
      // Try to recover by reopening boxes
      try {
        await StorageService.reopenBoxes();
        await StorageService.saveTask(task);
        await _syncTaskReminder(task);
      } catch (e2) {
        debugPrint('Retry save also failed: $e2');
        // Task is still in local state, will persist on next app restart
      }
    }
  }

  /// Update task with optimistic UI pattern
  Future<void> updateTask(Task task) async {
    final previous = _tasks.where((t) => t.id == task.id).firstOrNull;
    // OPTIMISTIC: Update local state first
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) _tasks[index] = task;
    _invalidateTaskCaches();
    notifyListeners();

    // Persist in background
    try {
      if (previous != null) await _cancelTaskReminder(previous);
      await StorageService.saveTask(task);
      await _syncTaskReminder(task);
    } catch (e) {
      debugPrint('Task update failed: $e');
    }
  }

  /// Toggle task completion with optimistic UI pattern
  ///
  /// The UI updates INSTANTLY - storage persistence happens in the background.
  /// This makes the app feel responsive even on slow storage operations.
  Future<void> toggleTaskComplete(String id, {DateTime? completionDate}) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    if (!task.isCompleted && _isFutureDate(completionDate)) return;
    final wasCompleted = task.isCompleted;
    final rewardWasGranted = task.completionRewardGranted ?? wasCompleted;
    task.completionRewardGranted = rewardWasGranted;

    // OPTIMISTIC UPDATE: Change state and notify UI immediately
    task.isCompleted = !task.isCompleted;
    task.completedAt = task.isCompleted
        ? (completionDate ?? DateTime.now())
        : null;

    // Award XP if completing (not uncompleting)
    if (task.isCompleted && !rewardWasGranted) {
      task.completionRewardGranted = true;
      if (task.isPriority) {
        _userStats.earnReward(
          xp: XPRewards.completePriorityTask,
          coinReward: XPRewards.coinsPriorityTask,
        );
      } else {
        _userStats.earnReward(
          xp: XPRewards.completeBacklogTask,
          coinReward: XPRewards.coinsBacklogTask,
        );
      }

      // Record task completion for statistics
      _userStats.recordTaskCompletion(isPriority: task.isPriority);

      // FEEDBACK LOOP: Update health of all linked Factors
      for (final factorId in task.linkedFactorIds) {
        try {
          final factor = _factors.firstWhere((f) => f.id == factorId);
          if (factor.isActiveFocus) {
            factor.logWork();
            // Persist factor update in background
            StorageService.saveFactor(factor).catchError((e) {
              debugPrint('Factor health update failed: $e');
            });
            invalidateGoalProgressCache();
          }
        } catch (_) {
          // Factor not found, skip
        }
      }
    }

    // Notify UI BEFORE storage - makes completion feel instant
    _invalidateTaskCaches();
    scheduleAchievementCheck();
    notifyListeners();

    // Persist to storage in background (fire-and-forget pattern)
    // If storage fails, the in-memory state is still correct for this session
    StorageService.saveTask(task).catchError((e) {
      debugPrint('Task save failed: $e');
      // In production, you might want to queue for retry or show a subtle indicator
    });
    try {
      await _syncTaskReminder(task);
    } catch (e) {
      debugPrint('Task reminder update failed: $e');
    }
  }

  /// Promote task to priority with optimistic UI pattern
  Future<void> promoteTaskToPriority(String id) async {
    if (!canAddPriorityTask) {
      throw Exception('Cannot add more than 2 priority tasks');
    }
    // OPTIMISTIC: Update local state first
    final task = _tasks.firstWhere((t) => t.id == id);
    task.isPriority = true;
    task.addedToPriorityAt = DateTime.now();
    _invalidateTaskCaches();
    notifyListeners();

    // Persist in background
    StorageService.saveTask(task).catchError((e) {
      debugPrint('Task promote failed: $e');
    });
  }

  /// Demote task to backlog with optimistic UI pattern
  Future<void> demoteTaskToBacklog(String id) async {
    // OPTIMISTIC: Update local state first
    final task = _tasks.firstWhere((t) => t.id == id);
    task.isPriority = false;
    task.addedToPriorityAt = null;
    _invalidateTaskCaches();
    notifyListeners();

    // Persist in background
    StorageService.saveTask(task).catchError((e) {
      debugPrint('Task demote failed: $e');
    });
  }

  /// Delete task with optimistic UI pattern
  Future<void> deleteTask(String id) async {
    final removed = _tasks.where((t) => t.id == id).firstOrNull;
    // OPTIMISTIC: Remove from local state first
    _tasks.removeWhere((t) => t.id == id);
    _invalidateTaskCaches();
    scheduleAchievementCheck();
    notifyListeners();

    // Persist in background
    try {
      if (removed != null) await _cancelTaskReminder(removed);
      await StorageService.deleteTask(id);
    } catch (e) {
      debugPrint('Task delete failed: $e');
    }
  }

  /// Reorder priority tasks with optimistic UI pattern
  /// Called when user drags a priority task to a new position
  Future<void> reorderPriorityTasks(int oldIndex, int newIndex) async {
    // Get current priority tasks in order
    final priorityList = priorityTasks;
    if (priorityList.length <= 1) return;

    // Adjust index if moving down (Flutter's reorder callback quirk)
    final adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    if (oldIndex == adjustedNewIndex) return;

    // OPTIMISTIC: Reorder in local state first
    final task = priorityList.removeAt(oldIndex);
    priorityList.insert(adjustedNewIndex, task);

    // Update sortOrder for all priority tasks
    for (int i = 0; i < priorityList.length; i++) {
      priorityList[i].sortOrder = i;
    }
    _invalidateTaskCaches();
    notifyListeners();

    // Persist in background
    for (final t in priorityList) {
      StorageService.saveTask(t).catchError((e) {
        debugPrint('Task reorder save failed: $e');
      });
    }
  }

  // --- Focus Session Logs ---
  Future<void> saveFocusSession(FocusLog log) async {
    await StorageService.saveFocusLog(log);
    _focusLogs.add(log);

    // Award XP for focusing
    _userStats.earnReward(
      xp: log.duration.inMinutes * 2,
      coinReward: log.duration.inMinutes ~/ 5,
    );
    scheduleAchievementCheck();
    notifyListeners();
  }

  List<Subtask> getSubtasksForTask(String taskId) =>
      StorageService.getSubtasksForTask(taskId);

  Future<void> addSubtask(Subtask subtask) async {
    await StorageService.saveSubtask(subtask);
    notifyListeners();
  }

  Future<void> toggleSubtask(String id) async {
    final subtask = StorageService.getSubtask(id);
    if (subtask == null) return;
    subtask.toggle();
    await StorageService.saveSubtask(subtask);
    notifyListeners();
  }

  Future<void> updateSubtask(Subtask subtask) async {
    await StorageService.saveSubtask(subtask);
    notifyListeners();
  }

  Future<void> deleteSubtask(String id) async {
    await StorageService.deleteSubtask(id);
    notifyListeners();
  }

  // ========== HABITS ==========
  Future<void> addHabit(Habit habit) async {
    await StorageService.saveHabit(habit);
    await _syncHabitReminders(habit);
    _habits.add(habit);
    _invalidateHabitCaches();
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    await StorageService.saveHabit(habit);
    await _syncHabitReminders(habit);
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) _habits[index] = habit;
    _invalidateHabitCaches();
    notifyListeners();
  }

  Future<void> logHabit(
    String id, {
    required bool completed,
    DateTime? date,
    String? note,
    int? mood,
    String? barrier,
    int? numericValue,
    List<bool>? checklistCompleted,
    int? timerSeconds,
    int? score,
  }) async {
    final targetDate = date ?? DateTime.now();
    if (_isFutureDate(targetDate)) return;
    final habit = _habits.firstWhere((h) => h.id == id);
    final previousLog = habit.getLogFor(targetDate);
    final wasCompleted = previousLog?.completed ?? false;
    final rewardWasGranted = previousLog == null
        ? false
        : (previousLog.rewardGranted ?? true);

    habit.logForDate(
      date: targetDate,
      completed: completed,
      note: note ?? previousLog?.note,
      mood: mood ?? previousLog?.moodRating,
      barrier: barrier ?? previousLog?.barrierTag,
      numericValue: numericValue ?? previousLog?.numericValue,
      checklistCompleted: checklistCompleted ?? previousLog?.checklistCompleted,
      timerSeconds: timerSeconds ?? previousLog?.timerSeconds,
      score: score ?? previousLog?.score,
      rewardGranted: true,
    );
    await StorageService.saveHabit(habit);

    // A habit occurrence can reward once. Later note/score edits and toggles
    // preserve the record without farming XP.
    if (!rewardWasGranted) {
      if (completed) {
        _userStats.earnReward(
          xp: XPRewards.logHabitCompleted,
          coinReward: XPRewards.coinsHabitCompleted,
        );
      } else {
        _userStats.earnReward(xp: XPRewards.logHabitFailed, coinReward: 0);
      }
    }

    // FEEDBACK LOOP: Update every linked active factor only on the transition
    // into completion, not when editing the same completed log.
    if (completed && !wasCompleted) {
      final linkedFactorIds = <String>{
        if (habit.factorId != null) habit.factorId!,
        ...?habit.linkedFactorIds,
      };
      for (final factorId in linkedFactorIds) {
        try {
          final factor = _factors.firstWhere((f) => f.id == factorId);
          if (factor.isActiveFocus) {
            factor.logWork();
            await StorageService.saveFactor(factor);
            invalidateGoalProgressCache();
          }
        } catch (_) {
          // Factor not found, skip
        }
      }
    }
    _invalidateHabitCaches();
    scheduleAchievementCheck();
    notifyListeners();
  }

  Future<void> updateHabitLogNote(
    String id, {
    required DateTime date,
    String? note,
  }) async {
    final habit = _habits.firstWhere((h) => h.id == id);
    final previousLog = habit.getLogFor(date);
    habit.logForDate(
      date: date,
      completed: previousLog?.completed ?? false,
      note: note,
      mood: previousLog?.moodRating,
      barrier: previousLog?.barrierTag,
      numericValue: previousLog?.numericValue,
      checklistCompleted: previousLog?.checklistCompleted,
      timerSeconds: previousLog?.timerSeconds,
      score: previousLog?.score,
      rewardGranted: previousLog == null
          ? false
          : (previousLog.rewardGranted ?? true),
      affectsStreak: false,
    );
    await StorageService.saveHabit(habit);
    _invalidateHabitCaches();
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    final removed = _habits.where((h) => h.id == id).firstOrNull;
    if (removed != null) {
      await _cancelHabitReminders(removed);
    } else {
      await NotificationService.cancelAllHabitReminders(id);
    }
    await StorageService.deleteHabit(id);
    _habits.removeWhere((h) => h.id == id);
    _invalidateHabitCaches();
    notifyListeners();
  }

  Future<void> _syncTaskReminder(Task task) async {
    final scheduledTime = task.scheduledTime;
    final reminderTime = scheduledTime != null && scheduledTime.isNotEmpty
        ? scheduledTime
        : (task.reminderTimes.isEmpty ? null : task.reminderTimes.first);
    if (task.isCompleted ||
        task.isArchived ||
        reminderTime == null ||
        reminderTime.isEmpty) {
      await _cancelTaskReminder(task);
      return;
    }

    final parts = reminderTime.split(':');
    if (parts.length != 2) {
      await _cancelTaskReminder(task);
      return;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || hour < 0 || hour > 23) {
      await _cancelTaskReminder(task);
      return;
    }
    if (minute == null || minute < 0 || minute > 59) {
      await _cancelTaskReminder(task);
      return;
    }

    await NotificationService.scheduleTaskReminder(
      taskId: task.id,
      taskName: task.title,
      scheduledDateTime: DateTime(
        task.scheduledDate.year,
        task.scheduledDate.month,
        task.scheduledDate.day,
        hour,
        minute,
      ),
    );
  }

  Future<void> _cancelTaskReminder(Task task) async {
    await NotificationService.cancelTaskReminder(task.id);
  }

  Future<void> _syncHabitReminders(Habit habit) async {
    final reminderTimes = habit.reminderTimes ?? const <String>[];
    if (!habit.isActive || habit.isArchived || reminderTimes.isEmpty) {
      await _cancelHabitReminders(habit);
      return;
    }

    final startDate = habit.startDate ?? habit.createdAt;
    final weekdays = _supportedReminderWeekdays(
      habit.effectiveFrequencyType,
      habit.scheduledDays,
    );
    if (_isFutureDate(startDate) || habit.endDate != null || weekdays == null) {
      await _cancelHabitReminders(habit);
      return;
    }

    await NotificationService.scheduleAllHabitReminders(
      habitId: habit.id,
      habitName: habit.name,
      reminderTimes: reminderTimes,
      weekdays: weekdays,
    );
  }

  Future<void> _cancelHabitReminders(Habit habit) async {
    await NotificationService.cancelAllHabitReminders(habit.id);
    for (final time in habit.reminderTimes ?? const <String>[]) {
      await NotificationService.cancelHabitReminder(habit.id, time);
    }
  }

  List<int>? _supportedReminderWeekdays(
    HabitFrequencyType frequencyType,
    List<int> scheduledDays,
  ) {
    switch (frequencyType) {
      case HabitFrequencyType.everyday:
        return const [1, 2, 3, 4, 5, 6, 7];
      case HabitFrequencyType.specificDays:
        return scheduledDays.isEmpty ? null : scheduledDays;
      case HabitFrequencyType.specificDatesOfYear:
      case HabitFrequencyType.someDaysPerPeriod:
      case HabitFrequencyType.repeatEvery:
        return null;
    }
  }

  Future<void> _syncRecurringTaskReminders(RecurringTask task) async {
    final weekdays = _supportedReminderWeekdays(
      task.frequencyType,
      task.scheduledDays,
    );
    if (task.isArchived ||
        task.reminderTimes.isEmpty ||
        _isFutureDate(task.startDate) ||
        task.endDate != null ||
        weekdays == null) {
      await _cancelRecurringTaskReminders(task);
      return;
    }

    await NotificationService.scheduleAllRecurringTaskReminders(
      recurringTaskId: task.id,
      recurringTaskName: task.name,
      reminderTimes: task.reminderTimes,
      weekdays: weekdays,
    );
  }

  Future<void> _cancelRecurringTaskReminders(RecurringTask task) async {
    await NotificationService.cancelAllRecurringTaskReminders(task.id);
    for (final time in task.reminderTimes) {
      await NotificationService.cancelRecurringTaskReminder(task.id, time);
    }
  }

  Future<void> _resyncAllReminders() async {
    if (!NotificationService.canSchedule) return;

    await NotificationService.cancelAllScheduledReminders();
    for (final task in _tasks) {
      try {
        await _syncTaskReminder(task);
      } catch (e) {
        debugPrint('Task reminder sync failed for ${task.id}: $e');
      }
    }
    for (final habit in _habits) {
      try {
        await _syncHabitReminders(habit);
      } catch (e) {
        debugPrint('Habit reminder sync failed for ${habit.id}: $e');
      }
    }
    for (final task in _recurringTasks) {
      try {
        await _syncRecurringTaskReminders(task);
      } catch (e) {
        debugPrint('Recurring task reminder sync failed for ${task.id}: $e');
      }
    }
  }

  // ========== BARRIERS ==========
  Future<void> addBarrier(BarrierEntry barrier) async {
    await StorageService.saveBarrier(barrier);
    _barriers.add(barrier);
    scheduleAchievementCheck();
    notifyListeners();
  }

  Future<void> updateBarrier(BarrierEntry barrier) async {
    await StorageService.saveBarrier(barrier);
    final index = _barriers.indexWhere((b) => b.id == barrier.id);
    if (index != -1) _barriers[index] = barrier;
    notifyListeners();
  }

  /// Permanently removes a barrier from storage and memory.
  Future<void> deleteBarrier(String id) async {
    await StorageService.deleteBarrier(id);
    _barriers.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  // --- Barrier analytics (computed, read-only) ---

  /// Barriers linked to [habitId], newest first.
  List<BarrierEntry> barriersForHabit(String habitId) =>
      _barriers.where((b) => b.linkedHabitId == habitId).toList()
        ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

  /// Barriers linked to [taskId], newest first.
  List<BarrierEntry> barriersForTask(String taskId) =>
      _barriers.where((b) => b.linkedTaskId == taskId).toList()
        ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

  /// Count of barriers per tag key, optionally limited to entries that
  /// occurred on or after [since].
  Map<String, int> barrierCountsByTag({DateTime? since}) {
    final counts = <String, int>{};
    for (final b in _barriers) {
      if (since != null && b.occurredAt.isBefore(since)) continue;
      final key = b.tag ?? 'other';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  /// Barriers whose [occurredAt] falls within [start]..[end] inclusive,
  /// newest first.
  List<BarrierEntry> barriersInRange(DateTime start, DateTime end) =>
      _barriers
          .where(
            (b) => !b.occurredAt.isBefore(start) && !b.occurredAt.isAfter(end),
          )
          .toList()
        ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

  /// Id of the habit with the most linked barriers (optionally since
  /// [since]). Null when no habit-linked barriers exist.
  String? mostBlockedHabitId({DateTime? since}) {
    final counts = <String, int>{};
    for (final b in _barriers) {
      final habitId = b.linkedHabitId;
      if (habitId == null) continue;
      if (since != null && b.occurredAt.isBefore(since)) continue;
      counts[habitId] = (counts[habitId] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }

  /// Fraction (0..1) of barriers marked handled, optionally since [since].
  /// Returns 0 when no barriers fall in range.
  double barrierHandledRate({DateTime? since}) {
    final inScope = since == null
        ? _barriers
        : _barriers.where((b) => !b.occurredAt.isBefore(since)).toList();
    if (inScope.isEmpty) return 0;
    final handled = inScope.where((b) => b.wasHandled).length;
    return handled / inScope.length;
  }

  // ========== REFLECTIONS ==========
  Future<void> addReflection(Reflection reflection) async {
    await StorageService.saveReflection(reflection);
    _reflections.add(reflection);

    // Award XP for completing reflection
    _userStats.earnReward(
      xp: XPRewards.completeReflection,
      coinReward: XPRewards.coinsReflection,
    );
    _userStats.recordReflection();
    scheduleAchievementCheck();
    notifyListeners();
  }

  Future<void> updateReflection(Reflection reflection) async {
    await StorageService.saveReflection(reflection);
    final index = _reflections.indexWhere((r) => r.id == reflection.id);
    if (index != -1) _reflections[index] = reflection;
    notifyListeners();
  }

  Future<void> deleteReflection(String id) async {
    // Get reflection before deletion to check group/links
    final reflection = _reflections.firstWhere(
      (r) => r.id == id,
      orElse: () => Reflection(
        id: 'dummy',
        createdAt: DateTime.now(),
        experience: '',
        reflection: '',
        abstraction: '',
      ),
    );

    if (reflection.id == 'dummy') return;

    // 1. Chain Repair: Update next links to point to previous
    final nextReflections = _reflections
        .where((r) => r.previousReflectionId == id)
        .toList();
    for (final next in nextReflections) {
      next.previousReflectionId = reflection.previousReflectionId;
      await StorageService.saveReflection(next);
    }

    // 2. Group Cleanup
    if (reflection.groupId != null) {
      final group = getReflectionGroup(reflection.groupId!);
      if (group != null) {
        group.reflectionIds.remove(id);
        if (group.reflectionIds.isEmpty) {
          await StorageService.deleteReflectionGroup(group.id);
          _reflectionGroups.removeWhere((g) => g.id == group.id);
        } else {
          await StorageService.saveReflectionGroup(group);
        }
      }
    }

    await StorageService.deleteReflection(id);
    _reflections.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  /// Add a reflection that is part of a cycle (linked to previous)
  Future<void> addLinkedReflection(
    Reflection newReflection, {
    Reflection? previousReflection,
  }) async {
    if (previousReflection != null) {
      ReflectionGroup group;

      if (previousReflection.groupId != null) {
        // Use existing group
        final existing = getReflectionGroup(previousReflection.groupId!);
        if (existing != null) {
          group = existing;
        } else {
          // Should not happen, but fallback
          group = ReflectionGroup(
            id: previousReflection.groupId!,
            title: 'Reflection Cycle',
            targetFactorId: previousReflection.targetFactorId,
          );
          _reflectionGroups.add(group);
        }
      } else {
        // Create new group for the chain
        group = ReflectionGroup(
          id: StorageService.generateId(),
          title: 'Reflection Cycle',
          targetFactorId: previousReflection.targetFactorId,
        );

        // Add previous reflection to this new group
        group.addReflection(previousReflection.id);
        previousReflection.groupId = group.id;
        await updateReflection(previousReflection); // Saves and updates list

        await StorageService.saveReflectionGroup(group);
        _reflectionGroups.add(group);
      }

      // Link new reflection
      newReflection.groupId = group.id;
      newReflection.previousReflectionId = previousReflection.id;
      newReflection.isFollowUp = true;

      // Update group
      group.addReflection(newReflection.id);
      await StorageService.saveReflectionGroup(group);
    }

    await addReflection(newReflection);
  }

  // ========== REFLECTION GROUPS ==========
  List<ReflectionGroup> get activeReflectionGroups =>
      _reflectionGroups.where((g) => !g.isArchived).toList();

  List<ReflectionGroup> get archivedReflectionGroups =>
      _reflectionGroups.where((g) => g.isArchived).toList();

  ReflectionGroup? getReflectionGroup(String id) {
    try {
      return _reflectionGroups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Create a new reflection as a cycle of an existing one
  Future<Reflection> cycleReflection(String reflectionId) async {
    final original = _reflections.firstWhere(
      (r) => r.id == reflectionId,
      orElse: () => throw Exception('Reflection not found'),
    );

    // Get or create the group
    ReflectionGroup group;
    if (original.groupId != null) {
      // Try to find existing group
      final existingGroup = _reflectionGroups
          .cast<ReflectionGroup?>()
          .firstWhere((g) => g?.id == original.groupId, orElse: () => null);

      if (existingGroup != null) {
        group = existingGroup;
      } else {
        // Group reference exists but group not found - create a new one
        group = ReflectionGroup(
          id: original.groupId!,
          title: 'Reflection Cycle',
          targetFactorId: original.targetFactorId,
        );
        group.addReflection(original.id);
        await StorageService.saveReflectionGroup(group);
        _reflectionGroups.add(group);
      }
    } else {
      // Create new group for this chain
      group = ReflectionGroup(
        id: StorageService.generateId(),
        title: 'Reflection Cycle',
        targetFactorId: original.targetFactorId,
      );
      group.addReflection(original.id);
      original.groupId = group.id;
      await StorageService.saveReflection(original);
      await StorageService.saveReflectionGroup(group);
      _reflectionGroups.add(group);
    }

    // Create new reflection in the same group
    final newReflection = Reflection(
      id: StorageService.generateId(),
      isFollowUp: true,
      previousReflectionId: original.id,
      groupId: group.id,
      targetFactorId: original.targetFactorId,
      linkedFactorIds: List.from(original.linkedFactorIds),
    );

    group.addReflection(newReflection.id);
    await StorageService.saveReflectionGroup(group);
    await StorageService.saveReflection(newReflection);
    _reflections.add(newReflection);

    notifyListeners();
    return newReflection;
  }

  /// Archive a single reflection (creates group if needed, then archives it)
  Future<void> archiveReflection(String reflectionId) async {
    final reflection = _reflections.firstWhere(
      (r) => r.id == reflectionId,
      orElse: () => throw Exception('Reflection not found'),
    );

    if (reflection.groupId != null) {
      // Try to find existing group
      final existingGroup = _reflectionGroups
          .cast<ReflectionGroup?>()
          .firstWhere((g) => g?.id == reflection.groupId, orElse: () => null);

      if (existingGroup != null) {
        // Archive the existing group
        existingGroup.archive();
        await StorageService.saveReflectionGroup(existingGroup);
        notifyListeners();
      } else {
        // Group reference exists but group not found - create and archive
        final group = ReflectionGroup(
          id: reflection.groupId!,
          title: 'Archived Reflection',
          targetFactorId: reflection.targetFactorId,
        );
        group.addReflection(reflection.id);
        group.archive();
        await StorageService.saveReflectionGroup(group);
        _reflectionGroups.add(group);
        notifyListeners();
      }
    } else {
      // Create a group for this reflection, then archive it
      final group = ReflectionGroup(
        id: StorageService.generateId(),
        title: 'Archived Reflection',
        targetFactorId: reflection.targetFactorId,
      );
      group.addReflection(reflection.id);
      reflection.groupId = group.id;
      group.archive();

      await StorageService.saveReflection(reflection);
      await StorageService.saveReflectionGroup(group);
      _reflectionGroups.add(group);
      notifyListeners();
    }
  }

  /// Archive a reflection group (finish the cycle chain)
  Future<void> archiveReflectionGroup(String groupId) async {
    // Try to find existing group
    var group = _reflectionGroups.cast<ReflectionGroup?>().firstWhere(
      (g) => g?.id == groupId,
      orElse: () => null,
    );

    if (group == null) {
      // Group not in memory, create a placeholder and archive it
      group = ReflectionGroup(id: groupId, title: 'Archived Reflection');
      _reflectionGroups.add(group);
    }

    group.archive();
    await StorageService.saveReflectionGroup(group);
    notifyListeners();
  }

  /// Restore an archived reflection group
  Future<void> restoreReflectionGroup(String groupId) async {
    final group = _reflectionGroups.cast<ReflectionGroup?>().firstWhere(
      (g) => g?.id == groupId,
      orElse: () => null,
    );

    if (group == null) {
      throw Exception('Cannot restore: reflection group not found');
    }

    group.restore();
    await StorageService.saveReflectionGroup(group);
    notifyListeners();
  }

  // ========== EXPERIMENTS ==========
  Future<void> addExperiment(Experiment experiment) async {
    await StorageService.saveExperiment(experiment);
    _experiments.add(experiment);
    scheduleAchievementCheck();
    notifyListeners();
  }

  Future<void> deleteExperiment(String id) async {
    await StorageService.deleteExperiment(id);
    _experiments.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// Start working on an experiment (pending -> inProgress)
  Future<void> startExperiment(String experimentId) async {
    final experiment = _experiments.firstWhere((e) => e.id == experimentId);
    experiment.start();
    await StorageService.saveExperiment(experiment);
    notifyListeners();
  }

  /// Complete an experiment successfully
  Future<void> completeExperiment(String experimentId) async {
    final experiment = _experiments.firstWhere((e) => e.id == experimentId);
    experiment.complete();
    await StorageService.saveExperiment(experiment);

    // Award XP for completing experiment
    _userStats.earnReward(xp: 30, coinReward: 10);
    scheduleAchievementCheck();
    notifyListeners();
  }

  /// Cycle an experiment to the next reflection
  Future<void> cycleExperiment(String experimentId) async {
    final experiment = _experiments.firstWhere((e) => e.id == experimentId);
    experiment.cycle();
    await StorageService.saveExperiment(experiment);
    notifyListeners();
  }

  /// Archive an experiment (done or abandoned)
  Future<void> archiveExperiment(String experimentId) async {
    final experiment = _experiments.firstWhere((e) => e.id == experimentId);
    experiment.archive();
    await StorageService.saveExperiment(experiment);
    notifyListeners();
  }

  /// Legacy method - now just starts the experiment (for backward compat)
  @Deprecated('Use startExperiment instead')
  Future<void> promoteExperimentToTask(
    String experimentId, {
    required bool toPriority,
  }) async {
    // Now we just start the experiment instead of creating a task
    await startExperiment(experimentId);
  }

  // ========== SETTINGS ==========
  Future<void> setTimeAvailability(TimeAvailability value) async {
    await StorageService.setTimeAvailability(value);
    _timeAvailability = value;
    notifyListeners();
  }

  // ========== PHASE 2: FACTOR-LINKED GETTERS ==========
  /// Get all tasks linked to a specific Factor
  List<Task> getTasksForFactor(String factorId) =>
      _tasks.where((t) => t.linkedFactorIds.contains(factorId)).toList();

  /// Get all habits linked to a specific Factor
  List<Habit> getHabitsForFactor(String factorId) => _habits
      .where(
        (h) =>
            h.factorId == factorId ||
            (h.linkedFactorIds?.contains(factorId) ?? false),
      )
      .toList();

  /// Get all reflections linked to a specific Factor
  List<Reflection> getReflectionsForFactor(String factorId) =>
      _reflections.where((r) => r.linkedFactorIds.contains(factorId)).toList();

  /// Get total effort units for a Factor (Work Volume metric)
  int getEffortUnitsForFactor(String factorId) {
    final taskCount = getTasksForFactor(
      factorId,
    ).where((t) => t.isCompleted).length;
    final habitLogs = getHabitsForFactor(
      factorId,
    ).fold<int>(0, (sum, h) => sum + h.logs.where((l) => l.completed).length);
    final reflectionCount = getReflectionsForFactor(factorId).length;
    return taskCount + habitLogs + reflectionCount;
  }

  // ========== GOAL PROGRESS AGGREGATION (Marginal Gains Feedback Loop) ==========

  // Cache for goal progress calculations (performance optimization)
  final Map<String, double> _goalProgressCache = {};
  DateTime? _goalProgressCacheTime;

  /// Get weighted progress for a Goal based on all linked Factor progress
  /// This aggregates the "dissected" components back to the "anchor" goal
  double getGoalProgress(String goalId) {
    // Check cache (valid for 30 seconds)
    final now = DateTime.now();
    if (_goalProgressCacheTime != null &&
        now.difference(_goalProgressCacheTime!).inSeconds < 30 &&
        _goalProgressCache.containsKey(goalId)) {
      return _goalProgressCache[goalId]!;
    }

    final factors = getFactorsForGoal(goalId);
    if (factors.isEmpty) return 0.0;

    double weightedProgress = 0.0;
    double totalWeight = 0.0;

    for (final factor in factors) {
      // Weight by gap size - bigger gaps are more important to close
      final weight = factor.gap > 0 ? factor.gap.toDouble() : 1.0;
      weightedProgress += factor.progressPercent * weight;
      totalWeight += weight;
    }

    final progress = totalWeight > 0 ? weightedProgress / totalWeight : 0.0;

    // Update cache
    _goalProgressCache[goalId] = progress;
    _goalProgressCacheTime = now;

    return progress;
  }

  /// Invalidate goal progress cache (call after Factor updates)
  void invalidateGoalProgressCache() {
    _goalProgressCache.clear();
    _goalProgressCacheTime = null;
  }

  /// Get smart level recommendation based on effort invested
  /// Returns a suggested level based on work volume
  int getRecommendedLevel(String factorId) {
    final effort = getEffortUnitsForFactor(factorId);
    // Every 10 effort units suggests considering a level increase
    // Capped at 10 (max level)
    return (effort ~/ 10 + 1).clamp(1, 10);
  }

  /// Check if a Factor's actual level is below the recommended level
  bool isFactorLevelBehindEffort(String factorId) {
    final factor = _factors.cast<Factor?>().firstWhere(
      (f) => f?.id == factorId,
      orElse: () => null,
    );
    if (factor == null) return false;
    return factor.currentLevel < getRecommendedLevel(factorId);
  }

  /// Get reflection by ID
  Reflection? getReflectionById(String id) {
    try {
      return _reflections.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get experiment by ID
  Experiment? getExperimentById(String id) {
    try {
      return _experiments.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get experiments for a reflection
  List<Experiment> getExperimentsForReflection(String reflectionId) =>
      _experiments.where((e) => e.reflectionId == reflectionId).toList();

  // ========== PHASE 5: ACHIEVEMENTS ==========
  final List<String> _pendingAchievementNotifications = [];

  List<String> get pendingAchievementNotifications =>
      _pendingAchievementNotifications;

  /// Clear achievement notification
  void clearAchievementNotification(String achievementId) {
    _pendingAchievementNotifications.remove(achievementId);
    notifyListeners();
  }

  /// Schedule achievement check to run after current frame (debounced)
  /// This prevents achievement checks from blocking the UI thread during rapid state changes
  void scheduleAchievementCheck() {
    if (_achievementCheckScheduled) return;
    _achievementCheckScheduled = true;

    scheduleMicrotask(() {
      _achievementCheckScheduled = false;
      checkAchievements();
    });
  }

  /// Check and unlock achievements based on current state
  /// NOTE: This is an O(N) operation. Prefer calling scheduleAchievementCheck() to debounce.
  void checkAchievements() {
    // first_reflection: Complete first reflection
    if (_reflections.isNotEmpty &&
        !_userStats.unlockedBadgeIds.contains('first_reflection')) {
      _unlockAchievement('first_reflection');
    }

    // reflection_10: Complete 10 reflections
    if (_reflections.length >= 10 &&
        !_userStats.unlockedBadgeIds.contains('reflection_10')) {
      _unlockAchievement('reflection_10');
    }

    // experiments_100: Create 100 experiments
    if (_experiments.length >= 100 &&
        !_userStats.unlockedBadgeIds.contains('experiments_100')) {
      _unlockAchievement('experiments_100');
    }

    // streak_7: 7-day streak
    if (_userStats.currentStreak >= 7 &&
        !_userStats.unlockedBadgeIds.contains('streak_7')) {
      _unlockAchievement('streak_7');
    }

    // streak_30: 30-day streak
    if (_userStats.currentStreak >= 30 &&
        !_userStats.unlockedBadgeIds.contains('streak_30')) {
      _unlockAchievement('streak_30');
    }

    // streak_100: 100-day streak
    if (_userStats.currentStreak >= 100 &&
        !_userStats.unlockedBadgeIds.contains('streak_100')) {
      _unlockAchievement('streak_100');
    }

    // barrier_buster: Log 10 barriers
    if (_barriers.length >= 10 &&
        !_userStats.unlockedBadgeIds.contains('barrier_buster')) {
      _unlockAchievement('barrier_buster');
    }

    if (_hasPerfectWeek &&
        !_userStats.unlockedBadgeIds.contains('perfect_week')) {
      _unlockAchievement('perfect_week');
    }

    // first_top2: Complete first priority task
    // Use cached completedTasks to avoid inline filtering
    if (completedTasks.any((t) => t.isPriority) &&
        !_userStats.unlockedBadgeIds.contains('first_top2')) {
      _unlockAchievement('first_top2');
    }

    // tasks_50: Complete 50 tasks
    // Use cached completedTasks (O(1) access) instead of inline filter (O(N))
    if (completedTasks.length >= 50 &&
        !_userStats.unlockedBadgeIds.contains('tasks_50')) {
      _unlockAchievement('tasks_50');
    }

    // zero_backlog: Clear entire backlog (no incomplete backlog tasks)
    // backlogTasks getter is now memoized
    if (backlogTasks.isEmpty &&
        _tasks.isNotEmpty &&
        completedTasks.isNotEmpty &&
        !_userStats.unlockedBadgeIds.contains('zero_backlog')) {
      _unlockAchievement('zero_backlog');
    }

    // first_goal: Set first goal
    if (_goals.isNotEmpty &&
        !_userStats.unlockedBadgeIds.contains('first_goal')) {
      _unlockAchievement('first_goal');
    }

    // factor_master: Create 5 Factors
    if (_factors.length >= 5 &&
        !_userStats.unlockedBadgeIds.contains('factor_master')) {
      _unlockAchievement('factor_master');
    }

    // level_10: Reach Level 10 on any Factor
    if (_factors.any((f) => f.currentLevel >= 10) &&
        !_userStats.unlockedBadgeIds.contains('level_10')) {
      _unlockAchievement('level_10');
    }

    // xp_1000: Earn 1000 XP
    if (_userStats.totalXP >= 1000 &&
        !_userStats.unlockedBadgeIds.contains('xp_1000')) {
      _unlockAchievement('xp_1000');
    }

    // xp_10000: Earn 10000 XP
    if (_userStats.totalXP >= 10000 &&
        !_userStats.unlockedBadgeIds.contains('xp_10000')) {
      _unlockAchievement('xp_10000');
    }
  }

  void _unlockAchievement(String id) {
    final achievement = Achievements.getById(id);
    if (achievement == null) return;

    // Mark as unlocked
    _userStats.unlockBadge(id);

    // Award XP and coins
    _userStats.earnReward(
      xp: achievement.xpReward,
      coinReward: achievement.coinReward,
    );

    // Queue notification
    _pendingAchievementNotifications.add(id);

    notifyListeners();
  }

  bool get _hasPerfectWeek {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (var offset = 0; offset < 7; offset++) {
      final date = today.subtract(Duration(days: offset));
      final due = _habits
          .where(
            (habit) =>
                habit.isActive &&
                !habit.isArchived &&
                habit.isScheduledFor(date),
          )
          .toList();
      if (due.isEmpty || due.any((habit) => !habit.isCompletedFor(date))) {
        return false;
      }
    }
    return true;
  }

  /// Manually trigger achievement check (call resurrection)
  void triggerResurrectionAchievement() {
    if (!_userStats.unlockedBadgeIds.contains('resurrection')) {
      _unlockAchievement('resurrection');
    }
  }

  // ========== CATEGORIES (Phase 3) ==========

  /// Add a new category
  Future<void> addCategory(CategoryModel category) async {
    await StorageService.saveCategory(category);
    _categories.add(category);
    _categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _invalidateCategoryCaches();
    notifyListeners();
  }

  /// Update an existing category
  Future<void> updateCategory(CategoryModel category) async {
    await StorageService.saveCategory(category);
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) _categories[index] = category;
    _invalidateCategoryCaches();
    notifyListeners();
  }

  /// Delete a category (cannot delete default categories)
  Future<void> deleteCategory(String id) async {
    final category = _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => throw Exception('Category not found'),
    );
    if (category.isDefault) {
      throw Exception('Cannot delete default categories');
    }
    await StorageService.deleteCategory(id);
    _categories.removeWhere((c) => c.id == id);
    _invalidateCategoryCaches();
    notifyListeners();
  }

  /// Get category by ID
  CategoryModel? getCategoryById(String id) {
    _cachedCategoryById ??= {
      for (final category in _categories) category.id: category,
    };
    return _cachedCategoryById![id];
  }

  /// Number of tasks, habits, and recurring tasks assigned to [categoryId].
  int categoryUsageCount(String categoryId) {
    return _tasks.where((t) => t.categoryId == categoryId).length +
        _habits.where((h) => h.categoryId == categoryId).length +
        _recurringTasks.where((r) => r.categoryId == categoryId).length;
  }

  /// Persist a new category order. [ordered] is the full category list in the
  /// desired order; each entry's sortOrder is rewritten to its index.
  Future<void> reorderCategories(List<CategoryModel> ordered) async {
    for (var i = 0; i < ordered.length; i++) {
      final category = ordered[i];
      if (category.sortOrder != i) {
        category.sortOrder = i;
        await StorageService.saveCategory(category);
      }
    }
    _categories
      ..clear()
      ..addAll(ordered);
    _categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    notifyListeners();
  }

  /// Move every task, habit, and recurring task from [fromId] to [toId].
  Future<void> reassignCategory(String fromId, String toId) async {
    for (final task in _tasks.where((t) => t.categoryId == fromId).toList()) {
      task.categoryId = toId;
      await StorageService.saveTask(task);
    }
    for (final habit in _habits.where((h) => h.categoryId == fromId).toList()) {
      habit.categoryId = toId;
      await StorageService.saveHabit(habit);
    }
    for (final recurring
        in _recurringTasks.where((r) => r.categoryId == fromId).toList()) {
      recurring.categoryId = toId;
      await StorageService.saveRecurringTask(recurring);
    }
    _invalidateTaskCaches();
    _invalidateHabitCaches();
    _invalidateRecurringTaskCaches();
    notifyListeners();
  }

  // ========== RECURRING TASKS (Phase 3) ==========

  /// Add a new recurring task
  Future<void> addRecurringTask(RecurringTask task) async {
    await StorageService.saveRecurringTask(task);
    await _syncRecurringTaskReminders(task);
    _recurringTasks.add(task);
    _recurringTasks.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _invalidateRecurringTaskCaches();
    notifyListeners();
  }

  /// Update an existing recurring task
  Future<void> updateRecurringTask(RecurringTask task) async {
    await StorageService.saveRecurringTask(task);
    await _syncRecurringTaskReminders(task);
    final index = _recurringTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) _recurringTasks[index] = task;
    _invalidateRecurringTaskCaches();
    notifyListeners();
  }

  /// Delete a recurring task
  Future<void> deleteRecurringTask(String id) async {
    final removed = _recurringTasks.where((task) => task.id == id).firstOrNull;
    if (removed != null) {
      await _cancelRecurringTaskReminders(removed);
    } else {
      await NotificationService.cancelAllRecurringTaskReminders(id);
    }
    await StorageService.deleteRecurringTask(id);
    _recurringTasks.removeWhere((t) => t.id == id);
    _invalidateRecurringTaskCaches();
    notifyListeners();
  }

  /// Log completion for a recurring task
  Future<void> logRecurringTaskCompletion(
    String id, {
    required DateTime date,
    required bool completed,
    String? note,
    List<bool>? checklistCompleted,
  }) async {
    if (_isFutureDate(date)) return;
    final task = _recurringTasks.firstWhere((t) => t.id == id);
    final previousLog = task.getLogFor(date);
    final wasCompleted = previousLog?.completed ?? false;
    final rewardWasGranted =
        previousLog?.rewardGranted ?? (previousLog?.completed ?? false);
    task.logCompletion(
      date: date,
      completed: completed,
      note: note ?? previousLog?.note,
      checklistCompleted: checklistCompleted ?? previousLog?.checklistCompleted,
      rewardGranted: rewardWasGranted || completed,
    );
    await StorageService.saveRecurringTask(task);

    // Each dated occurrence can earn its completion reward once.
    if (completed && !rewardWasGranted) {
      _userStats.earnReward(
        xp: XPRewards.completeBacklogTask,
        coinReward: XPRewards.coinsBacklogTask,
      );
    }

    if (completed && !wasCompleted) {
      for (final factorId in task.linkedFactorIds.toSet()) {
        try {
          final factor = _factors.firstWhere((f) => f.id == factorId);
          if (factor.isActiveFocus) {
            factor.logWork();
            await StorageService.saveFactor(factor);
            invalidateGoalProgressCache();
          }
        } catch (_) {
          // Factor not found, skip.
        }
      }
    }
    _invalidateRecurringTaskCaches();
    scheduleAchievementCheck();
    notifyListeners();
  }

  Future<void> updateRecurringTaskLogNote(
    String id, {
    required DateTime date,
    String? note,
  }) async {
    final task = _recurringTasks.firstWhere((t) => t.id == id);
    final previousLog = task.getLogFor(date);
    task.logCompletion(
      date: date,
      completed: previousLog?.completed ?? false,
      note: note,
      checklistCompleted: previousLog?.checklistCompleted,
      rewardGranted:
          previousLog?.rewardGranted ?? (previousLog?.completed ?? false),
    );
    await StorageService.saveRecurringTask(task);
    _invalidateRecurringTaskCaches();
    notifyListeners();
  }

  // ========== TODAY PAGE HELPERS (Phase 3) ==========

  /// Generate a date key for caching (YYYY-MM-DD format)
  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

  bool _isFutureDate(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).isAfter(DateTime(now.year, now.month, now.day));
  }

  /// Get all habits scheduled for a specific date (excluding archived)
  /// Results are memoized per date until habit data changes
  List<Habit> getHabitsForDate(DateTime date) {
    final key = _dateKey(date);
    _cachedHabitsForDate ??= {};
    if (_cachedHabitsForDate!.containsKey(key)) {
      return _cachedHabitsForDate![key]!;
    }
    final result =
        _habits
            .where((h) => h.isActive && !h.isArchived && h.isScheduledFor(date))
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _cachedHabitsForDate![key] = result;
    return result;
  }

  /// Get all single tasks scheduled for a specific date
  /// Results are memoized per date until task data changes
  List<Task> getTasksForDate(DateTime date) {
    final key = _dateKey(date);
    _cachedTasksForDate ??= {};
    if (_cachedTasksForDate!.containsKey(key)) {
      return _cachedTasksForDate![key]!;
    }
    final result =
        _tasks
            .where(
              (t) => !t.isCompleted && !t.isArchived && t.isScheduledFor(date),
            )
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _cachedTasksForDate![key] = result;
    return result;
  }

  /// Get all non-archived single tasks visible on the Today page.
  ///
  /// This intentionally includes completed tasks on their scheduled date so
  /// they can remain visible in Today's Completed section.
  List<Task> getTodayTasksForDate(DateTime date) {
    final key = _dateKey(date);
    _cachedTodayTasksForDate ??= {};
    if (_cachedTodayTasksForDate!.containsKey(key)) {
      return _cachedTodayTasksForDate![key]!;
    }
    final result =
        _tasks.where((t) => !t.isArchived && t.isScheduledFor(date)).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _cachedTodayTasksForDate![key] = result;
    return result;
  }

  /// Get all recurring tasks scheduled for a specific date
  /// Results are memoized per date until recurring task data changes
  List<RecurringTask> getRecurringTasksForDate(DateTime date) {
    final key = _dateKey(date);
    _cachedRecurringTasksForDate ??= {};
    if (_cachedRecurringTasksForDate!.containsKey(key)) {
      return _cachedRecurringTasksForDate![key]!;
    }
    final result =
        _recurringTasks
            .where((t) => !t.isArchived && t.isScheduledFor(date))
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _cachedRecurringTasksForDate![key] = result;
    return result;
  }

  /// Get count of items scheduled for a date
  int getItemCountForDate(DateTime date) {
    return getHabitsForDate(date).length +
        getTasksForDate(date).length +
        getRecurringTasksForDate(date).length;
  }

  TodayDateData getTodayDateData(DateTime date) {
    final key = _dateKey(date);
    _cachedTodayDataByDate ??= {};
    final cached = _cachedTodayDataByDate![key];
    if (cached != null) return cached;

    final allItems =
        <TodayItemData>[
          ...getHabitsForDate(date).map(
            (habit) => TodayItemData.habit(
              habit,
              date: date,
              category: _categoryFor(habit.categoryId),
            ),
          ),
          ...getRecurringTasksForDate(date).map(
            (recurringTask) => TodayItemData.recurringTask(
              recurringTask,
              date: date,
              category: _categoryFor(recurringTask.categoryId),
            ),
          ),
          ...getTodayTasksForDate(date).map(
            (task) => TodayItemData.task(
              task,
              category: _categoryFor(task.categoryId),
            ),
          ),
        ]..sort((a, b) {
          final byPriority = b.numericPriority.compareTo(a.numericPriority);
          if (byPriority != 0) return byPriority;
          final byOrder = a.sortOrder.compareTo(b.sortOrder);
          if (byOrder != 0) return byOrder;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

    final openItems = allItems.where((item) => !item.isCompleted).toList();
    final completedItems = allItems.where((item) => item.isCompleted).toList();
    final todayData = TodayDateData(
      allItems: List.unmodifiable(allItems),
      topTasks: List.unmodifiable(
        openItems.where((item) => item.isTask || item.isRecurringTask),
      ),
      habitRoutine: List.unmodifiable(openItems.where((item) => item.isHabit)),
      completedItems: List.unmodifiable(completedItems),
      completedCount: completedItems.length,
      totalCount: allItems.length,
    );
    _cachedTodayDataByDate![key] = todayData;
    return todayData;
  }

  CategoryModel? _categoryFor(String? id) {
    if (id == null) return null;
    return getCategoryById(id);
  }

  // ========== SPACED REPETITION ==========

  /// Get due topics count
  int get dueTopicsCount => _srTopics.where((t) => t.isDue).length;

  /// Get topics for a subject
  List<SpacedRepetitionTopic> getTopicsForSubject(String subjectId) {
    return _srTopics.where((t) => t.subjectId == subjectId).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Get due topics count for a subject
  int getDueCountForSubject(String subjectId) {
    return _srTopics.where((t) => t.subjectId == subjectId && t.isDue).length;
  }

  /// Add a new subject
  Future<void> addSubject(SpacedRepetitionSubject subject) async {
    _srSubjects.add(subject);
    notifyListeners();
    await StorageService.saveSubject(subject);
  }

  /// Update a subject
  Future<void> updateSubject(SpacedRepetitionSubject subject) async {
    final index = _srSubjects.indexWhere((s) => s.id == subject.id);
    if (index != -1) _srSubjects[index] = subject;
    notifyListeners();
    await StorageService.saveSubject(subject);
  }

  /// Delete a subject and its topics
  Future<void> deleteSubject(String id) async {
    _srSubjects.removeWhere((s) => s.id == id);
    _srTopics.removeWhere((t) => t.subjectId == id);
    notifyListeners();
    await StorageService.deleteSubject(id);
  }

  /// Toggle subject expanded state
  Future<void> toggleSubjectExpanded(String id) async {
    final subject = _srSubjects.firstWhere((s) => s.id == id);
    final updated = subject.copyWith(isExpanded: !subject.isExpanded);
    final index = _srSubjects.indexWhere((s) => s.id == id);
    if (index != -1) _srSubjects[index] = updated;
    notifyListeners();
    await StorageService.saveSubject(updated);
  }

  /// Add a new topic
  Future<void> addTopic(SpacedRepetitionTopic topic) async {
    _srTopics.add(topic);
    notifyListeners();
    await StorageService.saveTopic(topic);
  }

  /// Update a topic
  Future<void> updateTopic(SpacedRepetitionTopic topic) async {
    final index = _srTopics.indexWhere((t) => t.id == topic.id);
    if (index != -1) _srTopics[index] = topic;
    notifyListeners();
    await StorageService.saveTopic(topic);
  }

  /// Delete a topic
  Future<void> deleteTopic(String id) async {
    _srTopics.removeWhere((t) => t.id == id);
    notifyListeners();
    await StorageService.deleteTopic(id);
  }

  /// Merge multiple topics into one (first topic keeps its review data)
  Future<void> mergeTopics(String subjectId, List<String> topicIds) async {
    if (topicIds.length < 2) return;

    // Get all topics in order
    final topicsToMerge = topicIds
        .map(
          (id) => _srTopics.cast<SpacedRepetitionTopic?>().firstWhere(
            (t) => t?.id == id,
            orElse: () => null,
          ),
        )
        .whereType<SpacedRepetitionTopic>()
        .toList();

    if (topicsToMerge.length < 2) return;

    // Keep the first topic, merge names
    final primary = topicsToMerge.first;
    final combinedName = topicsToMerge.map((t) => t.name).join(' / ');
    final updated = primary.copyWith(name: combinedName);

    // Update the primary topic
    final index = _srTopics.indexWhere((t) => t.id == primary.id);
    if (index != -1) _srTopics[index] = updated;
    await StorageService.saveTopic(updated);

    // Delete the other topics
    for (int i = 1; i < topicsToMerge.length; i++) {
      _srTopics.removeWhere((t) => t.id == topicsToMerge[i].id);
      await StorageService.deleteTopic(topicsToMerge[i].id);
    }

    notifyListeners();
  }

  /// Complete a topic review and schedule next review
  Future<void> completeTopic(String id, int intervalDays) async {
    final topic = _srTopics.firstWhere((t) => t.id == id);
    final updated = topic.markReviewed(intervalDays);
    final index = _srTopics.indexWhere((t) => t.id == id);
    if (index != -1) _srTopics[index] = updated;

    // Award XP for completing review
    _userStats.earnReward(
      xp: 5 + (intervalDays > 7 ? 5 : 0), // Bonus XP for longer intervals
      coinReward: 1,
    );

    scheduleAchievementCheck();
    notifyListeners();
    await StorageService.saveTopic(updated);
  }
}
