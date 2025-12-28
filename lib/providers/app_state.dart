import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../models/growth_area.dart';
import '../models/sprint_target.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/habit.dart';
import '../models/reflection.dart';
import '../models/reflection_group.dart';
import '../models/experiment.dart';
import '../models/time_availability.dart';
import '../models/user_stats.dart';
import '../models/achievement.dart';
import '../models/focus_log.dart';
import '../services/storage_service.dart';

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
  bool _isLoading = true;

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
  bool get isLoading => _isLoading;

  // Computed getters
  Goal? get activeGoal => _goals.isNotEmpty ? _goals.first : null;

  List<Task> get priorityTasks =>
      _tasks.where((t) => t.isPriority && !t.isCompleted).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  List<Task> get backlogTasks =>
      _tasks.where((t) => !t.isPriority && !t.isCompleted).toList()
        ..sort((a, b) {
          // Sort by deadline if available, then by sortOrder
          if (a.deadline != null && b.deadline != null) {
            return a.deadline!.compareTo(b.deadline!);
          }
          if (a.deadline != null) return -1;
          if (b.deadline != null) return 1;
          return a.sortOrder.compareTo(b.sortOrder);
        });

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

  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();

  bool get canAddPriorityTask => priorityTasks.length < 2;

  // Phase 2: Updated habit type getters
  List<Habit> get buildHabits =>
      _habits.where((h) => h.type == HabitType.build && h.isActive).toList();

  List<Habit> get quitHabits =>
      _habits.where((h) => h.type == HabitType.quit && h.isActive).toList();

  List<Habit> get timedHabits =>
      _habits.where((h) => h.type == HabitType.timed && h.isActive).toList();

  // Legacy aliases for backward compatibility
  List<Habit> get limitingHabits => quitHabits;
  List<Habit> get scriptedActions => buildHabits;

  List<Experiment> get pendingExperiments =>
      _experiments.where((e) => e.status == ExperimentStatus.pending).toList();

  List<Factor> get factorsWithGap =>
      _factors.where((f) => f.gap > 0).toList()
        ..sort((a, b) => b.gap.compareTo(a.gap));

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
      _goals = [];
    }

    try {
      _factors = StorageService.getAllFactors();
    } catch (e) {
      _factors = [];
    }

    try {
      _sprintTargets = StorageService.getAllSprintTargets();
    } catch (e) {
      _sprintTargets = [];
    }

    try {
      _tasks = StorageService.getAllTasks();
    } catch (e) {
      _tasks = [];
    }

    try {
      _habits = StorageService.getAllHabits();
    } catch (e) {
      _habits = [];
    }

    try {
      _reflections = StorageService.getAllReflections();
    } catch (e) {
      _reflections = [];
    }

    try {
      _experiments = StorageService.getAllExperiments();
    } catch (e) {
      _experiments = [];
    }

    try {
      _barriers = StorageService.getAllBarriers();
    } catch (e) {
      _barriers = [];
    }

    try {
      _timeAvailability = StorageService.getTimeAvailability();
    } catch (e) {
      _timeAvailability = null;
    }

    try {
      _userStats = StorageService.getUserStats();
    } catch (e) {
      _userStats = UserStats();
    }

    try {
      _focusLogs = StorageService.getAllFocusLogs();
    } catch (e) {
      _focusLogs = [];
    }

    try {
      _taskCategories = StorageService.getTaskCategories();
    } catch (e) {
      _taskCategories =
          []; // Will fallback to default in StorageService, but safely empty here
    }

    try {
      _reflectionGroups = StorageService.getAllReflectionGroups();
    } catch (e) {
      _reflectionGroups = [];
    }

    _isLoading = false;
    notifyListeners();
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
    notifyListeners();
  }

  Future<void> updateFactor(Factor factor) async {
    await StorageService.saveFactor(factor);
    final index = _factors.indexWhere((f) => f.id == factor.id);
    if (index != -1) _factors[index] = factor;
    notifyListeners();
  }

  Future<void> deleteFactor(String id) async {
    await StorageService.deleteFactor(id);
    _factors.removeWhere((f) => f.id == id);
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
  Future<void> addSprintTarget(SprintTarget target) async {
    await StorageService.saveSprintTarget(target);
    _sprintTargets.add(target);
    notifyListeners();
  }

  Future<void> updateSprintTarget(SprintTarget target) async {
    await StorageService.saveSprintTarget(target);
    final index = _sprintTargets.indexWhere((t) => t.id == target.id);
    if (index != -1) _sprintTargets[index] = target;
    notifyListeners();
  }

  Future<void> deleteSprintTarget(String id) async {
    await StorageService.deleteSprintTarget(id);
    _sprintTargets.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // ========== TASKS ==========
  Future<void> addTask(Task task) async {
    if (task.isPriority && !canAddPriorityTask) {
      throw Exception('Cannot add more than 2 priority tasks');
    }

    // Add to local state first (optimistic update)
    _tasks.add(task);
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

  Future<void> updateTask(Task task) async {
    await StorageService.saveTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) _tasks[index] = task;
    notifyListeners();
  }

  Future<void> toggleTaskComplete(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    final wasCompleted = task.isCompleted;
    task.isCompleted = !task.isCompleted;
    task.completedAt = task.isCompleted ? DateTime.now() : null;
    await StorageService.saveTask(task);

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
    }
    notifyListeners();
  }

  Future<void> promoteTaskToPriority(String id) async {
    if (!canAddPriorityTask) {
      throw Exception('Cannot add more than 2 priority tasks');
    }
    final task = _tasks.firstWhere((t) => t.id == id);
    task.isPriority = true;
    task.addedToPriorityAt = DateTime.now();
    await StorageService.saveTask(task);
    notifyListeners();
  }

  Future<void> demoteTaskToBacklog(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.isPriority = false;
    task.addedToPriorityAt = null;
    await StorageService.saveTask(task);
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await StorageService.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
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
    final subtasks = StorageService.getSubtasksForTask(id);
    // This needs the subtask ID, not task ID
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
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    await StorageService.saveHabit(habit);
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) _habits[index] = habit;
    notifyListeners();
  }

  Future<void> logHabit(
    String id, {
    required bool completed,
    String? note,
    int? mood,
    String? barrier,
  }) async {
    final habit = _habits.firstWhere((h) => h.id == id);
    habit.logToday(
      completed: completed,
      note: note,
      mood: mood,
      barrier: barrier,
    );
    await StorageService.saveHabit(habit);

    // Award XP for logging habits
    if (completed) {
      _userStats.earnReward(
        xp: XPRewards.logHabitCompleted,
        coinReward: XPRewards.coinsHabitCompleted,
      );
    } else {
      _userStats.earnReward(xp: XPRewards.logHabitFailed, coinReward: 0);
    }
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    await StorageService.deleteHabit(id);
    _habits.removeWhere((h) => h.id == id);
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
    await StorageService.deleteReflection(id);
    _reflections.removeWhere((r) => r.id == id);
    notifyListeners();
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
    final original = _reflections.firstWhere((r) => r.id == reflectionId);
    
    // Get or create the group
    ReflectionGroup group;
    if (original.groupId != null) {
      group = _reflectionGroups.firstWhere((g) => g.id == original.groupId);
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

  /// Archive a reflection group (finish the cycle chain)
  Future<void> archiveReflectionGroup(String groupId) async {
    final group = _reflectionGroups.firstWhere((g) => g.id == groupId);
    group.archive();
    await StorageService.saveReflectionGroup(group);
    notifyListeners();
  }

  /// Restore an archived reflection group
  Future<void> restoreReflectionGroup(String groupId) async {
    final group = _reflectionGroups.firstWhere((g) => g.id == groupId);
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

  void clearAchievementNotification(String achievementId) {
    _pendingAchievementNotifications.remove(achievementId);
    notifyListeners();
  }

  /// Check and unlock achievements based on current state
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
    if (_tasks.any((t) => t.isPriority && t.isCompleted) &&
        !_userStats.unlockedBadgeIds.contains('first_top2')) {
      _unlockAchievement('first_top2');
    }

    // tasks_50: Complete 50 tasks
    if (_tasks.where((t) => t.isCompleted).length >= 50 &&
        !_userStats.unlockedBadgeIds.contains('tasks_50')) {
      _unlockAchievement('tasks_50');
    }

    // zero_backlog: Clear entire backlog (no incomplete backlog tasks)
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
}
