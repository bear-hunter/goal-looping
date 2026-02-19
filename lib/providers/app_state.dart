import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../models/growth_area.dart';
import '../models/sprint_target.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/habit.dart';
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
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

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
  List<String> _taskCategories = [];
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
  Map<String, List<RecurringTask>>? _cachedRecurringTasksForDate;

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
  List<String> get taskCategories => _taskCategories;
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

  Map<String, List<Task>> get categorizedBacklog {
    final Map<String, List<Task>> groups = {};
    for (final task in backlogTasks) {
      if (!groups.containsKey(task.category)) {
        groups[task.category] = [];
      }
      groups[task.category]!.add(task);
    }
    return groups;
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
  }

  /// Invalidate all habit-related caches. Call this after any habit mutation.
  void _invalidateHabitCaches() {
    _cachedBuildHabits = null;
    _cachedQuitHabits = null;
    _cachedTimedHabits = null;
    _cachedHabitsForDate = null;
  }

  /// Invalidate factor-related caches.
  void _invalidateFactorCaches() {
    _cachedFactorsWithGap = null;
  }

  /// Invalidate recurring task caches.
  void _invalidateRecurringTaskCaches() {
    _cachedRecurringTasksForDate = null;
  }

  // Phase 2: Updated habit type getters with memoization
  List<Habit> get buildHabits {
    if (_cachedBuildHabits != null) return _cachedBuildHabits!;
    _cachedBuildHabits = _habits
        .where((h) => h.type == HabitType.build && h.isActive)
        .toList();
    return _cachedBuildHabits!;
  }

  List<Habit> get quitHabits {
    if (_cachedQuitHabits != null) return _cachedQuitHabits!;
    _cachedQuitHabits = _habits
        .where((h) => h.type == HabitType.quit && h.isActive)
        .toList();
    return _cachedQuitHabits!;
  }

  List<Habit> get timedHabits {
    if (_cachedTimedHabits != null) return _cachedTimedHabits!;
    _cachedTimedHabits = _habits
        .where((h) => h.type == HabitType.timed && h.isActive)
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
      _taskCategories = StorageService.getTaskCategories();
    } catch (e) {
      debugPrint('ERROR loading task categories: $e');
      _taskCategories = [];
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

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _migrateLegacyCategories() async {
    bool changesMade = false;
    final Map<String, CategoryModel> categoryMap = {
      for (var c in _categories) c.name.toLowerCase(): c,
    };

    for (final task in _tasks) {
      // If task has no categoryId but has a legacy category string
      if (task.categoryId == null &&
          task.category.isNotEmpty &&
          task.category != 'General') {
        final legacyName = task.category;
        final key = legacyName.toLowerCase();

        if (categoryMap.containsKey(key)) {
          // Link to existing category
          task.categoryId = categoryMap[key]!.id;
          await StorageService.saveTask(task);
          changesMade = true;
        } else {
          // Create new category
          final newCategory = CategoryModel.create(
            id: const Uuid().v4(),
            name: legacyName,
            icon: Icons.category_rounded, // Default icon
            color: Colors.blue, // Default color
          );
          await StorageService.saveCategory(newCategory);
          _categories.add(newCategory);
          categoryMap[key] = newCategory;

          // Link task
          task.categoryId = newCategory.id;
          await StorageService.saveTask(task);
          changesMade = true;
        }
      }
    }

    if (changesMade) {
      notifyListeners();
    }
  }

  // ========== GOALS ==========
  Future<void> addGoal(Goal goal) async {
    await StorageService.saveGoal(goal);
    _goals.add(goal);
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

  // ========== CATEGORIES ==========
  Future<void> addTaskCategory(String category) async {
    if (_taskCategories.contains(category)) return;
    _taskCategories.add(category);
    await StorageService.saveTaskCategories(_taskCategories);
    notifyListeners();
  }

  Future<void> deleteTaskCategory(String category) async {
    _taskCategories.remove(category);
    await StorageService.saveTaskCategories(_taskCategories);
    notifyListeners();
  }

  Future<void> renameTaskCategory(String oldName, String newName) async {
    final index = _taskCategories.indexOf(oldName);
    if (index != -1) {
      _taskCategories[index] = newName;
      await StorageService.saveTaskCategories(_taskCategories);
      notifyListeners();
    }
  }

  Future<void> reorderTaskCategories(List<String> categories) async {
    _taskCategories.clear();
    _taskCategories.addAll(categories);
    await StorageService.saveTaskCategories(_taskCategories);
    notifyListeners();
  }

  // ========== FACTORS ==========
  Future<void> addFactor(Factor factor) async {
    await StorageService.saveFactor(factor);
    _factors.add(factor);
    _invalidateFactorCaches();
    notifyListeners();
  }

  Future<void> updateFactor(Factor factor) async {
    await StorageService.saveFactor(factor);
    final index = _factors.indexWhere((f) => f.id == factor.id);
    if (index != -1) _factors[index] = factor;
    _invalidateFactorCaches();
    invalidateGoalProgressCache(); // Re-calculate Goal progress after Factor update
    notifyListeners();
  }

  Future<void> deleteFactor(String id) async {
    await StorageService.deleteFactor(id);
    _factors.removeWhere((f) => f.id == id);
    _invalidateFactorCaches();
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
    notifyListeners();
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
    } catch (e) {
      debugPrint('Failed to save task: $e');
      // Try to recover by reopening boxes
      try {
        await StorageService.reopenBoxes();
        await StorageService.saveTask(task);
      } catch (e2) {
        debugPrint('Retry save also failed: $e2');
        // Task is still in local state, will persist on next app restart
      }
    }
  }

  /// Update task with optimistic UI pattern
  Future<void> updateTask(Task task) async {
    // OPTIMISTIC: Update local state first
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) _tasks[index] = task;
    _invalidateTaskCaches();
    notifyListeners();

    // Persist in background
    StorageService.saveTask(task).catchError((e) {
      debugPrint('Task update failed: $e');
    });
  }

  /// Toggle task completion with optimistic UI pattern
  ///
  /// The UI updates INSTANTLY - storage persistence happens in the background.
  /// This makes the app feel responsive even on slow storage operations.
  Future<void> toggleTaskComplete(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    final wasCompleted = task.isCompleted;

    // OPTIMISTIC UPDATE: Change state and notify UI immediately
    task.isCompleted = !task.isCompleted;
    task.completedAt = task.isCompleted ? DateTime.now() : null;

    // Award XP if completing (not uncompleting)
    if (task.isCompleted && !wasCompleted) {
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
          }
        } catch (_) {
          // Factor not found, skip
        }
      }
    }

    // Notify UI BEFORE storage - makes completion feel instant
    _invalidateTaskCaches();
    notifyListeners();

    // Persist to storage in background (fire-and-forget pattern)
    // If storage fails, the in-memory state is still correct for this session
    StorageService.saveTask(task).catchError((e) {
      debugPrint('Task save failed: $e');
      // In production, you might want to queue for retry or show a subtle indicator
    });
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
    // OPTIMISTIC: Remove from local state first
    _tasks.removeWhere((t) => t.id == id);
    _invalidateTaskCaches();
    notifyListeners();

    // Persist in background
    StorageService.deleteTask(id).catchError((e) {
      debugPrint('Task delete failed: $e');
    });
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
    notifyListeners();
  }

  List<Subtask> getSubtasksForTask(String taskId) =>
      StorageService.getSubtasksForTask(taskId);

  Future<void> addSubtask(Subtask subtask) async {
    await StorageService.saveSubtask(subtask);
    notifyListeners();
  }

  Future<void> toggleSubtask(String id) async {
    // Needs subtask ID to retrieve and toggle; currently a no-op stub.
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
    _habits.add(habit);
    _invalidateHabitCaches();
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    await StorageService.saveHabit(habit);
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) _habits[index] = habit;
    _invalidateHabitCaches();
    notifyListeners();
  }

  Future<void> logHabit(
    String id, {
    required bool completed,
    String? note,
    int? mood,
    String? barrier,
    int? score,
  }) async {
    final habit = _habits.firstWhere((h) => h.id == id);
    habit.logToday(
      completed: completed,
      note: note,
      mood: mood,
      barrier: barrier,
      score: score,
    );
    await StorageService.saveHabit(habit);

    // Award XP for logging habits
    if (completed) {
      _userStats.earnReward(
        xp: XPRewards.logHabitCompleted,
        coinReward: XPRewards.coinsHabitCompleted,
      );

      // FEEDBACK LOOP: Update health of linked Factor
      if (habit.factorId != null) {
        try {
          final factor = _factors.firstWhere((f) => f.id == habit.factorId);
          if (factor.isActiveFocus) {
            factor.logWork();
            await StorageService.saveFactor(factor);
          }
        } catch (_) {
          // Factor not found, skip
        }
      }
    } else {
      _userStats.earnReward(xp: XPRewards.logHabitFailed, coinReward: 0);
    }
    _invalidateHabitCaches();
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    await StorageService.deleteHabit(id);
    _habits.removeWhere((h) => h.id == id);
    _invalidateHabitCaches();
    notifyListeners();
  }

  // ========== BARRIERS ==========
  Future<void> addBarrier(BarrierEntry barrier) async {
    await StorageService.saveBarrier(barrier);
    _barriers.add(barrier);
    notifyListeners();
  }

  Future<void> updateBarrier(BarrierEntry barrier) async {
    await StorageService.saveBarrier(barrier);
    final index = _barriers.indexWhere((b) => b.id == barrier.id);
    if (index != -1) _barriers[index] = barrier;
    notifyListeners();
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

    // Record reflection for reminder tracking
    _userStats.recordReflection();

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
  List<Habit> getHabitsForFactor(String factorId) =>
      _habits.where((h) => h.factorId == factorId).toList();

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
    notifyListeners();
  }

  /// Update an existing category
  Future<void> updateCategory(CategoryModel category) async {
    await StorageService.saveCategory(category);
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) _categories[index] = category;
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
    notifyListeners();
  }

  /// Get category by ID
  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ========== RECURRING TASKS (Phase 3) ==========

  /// Add a new recurring task
  Future<void> addRecurringTask(RecurringTask task) async {
    await StorageService.saveRecurringTask(task);
    _recurringTasks.add(task);
    _recurringTasks.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _invalidateRecurringTaskCaches();
    notifyListeners();
  }

  /// Update an existing recurring task
  Future<void> updateRecurringTask(RecurringTask task) async {
    await StorageService.saveRecurringTask(task);
    final index = _recurringTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) _recurringTasks[index] = task;
    _invalidateRecurringTaskCaches();
    notifyListeners();
  }

  /// Delete a recurring task
  Future<void> deleteRecurringTask(String id) async {
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
    final task = _recurringTasks.firstWhere((t) => t.id == id);
    task.logCompletion(
      date: date,
      completed: completed,
      note: note,
      checklistCompleted: checklistCompleted,
    );
    await StorageService.saveRecurringTask(task);

    // Award XP if completed
    if (completed) {
      _userStats.earnReward(
        xp: XPRewards.completeBacklogTask,
        coinReward: XPRewards.coinsBacklogTask,
      );
    }
    _invalidateRecurringTaskCaches();
    notifyListeners();
  }

  // ========== TODAY PAGE HELPERS (Phase 3) ==========

  /// Generate a date key for caching (YYYY-MM-DD format)
  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

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
        _tasks.where((t) => !t.isCompleted && t.isScheduledFor(date)).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _cachedTasksForDate![key] = result;
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

    notifyListeners();
    await StorageService.saveTopic(updated);
  }
}
