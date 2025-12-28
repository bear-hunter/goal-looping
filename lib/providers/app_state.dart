import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../models/factor.dart';
import '../models/sprint_target.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/habit.dart';
import '../models/reflection.dart';
import '../models/experiment.dart';
import '../models/time_availability.dart';
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
  bool get isLoading => _isLoading;

  // Computed getters
  Goal? get activeGoal => _goals.isNotEmpty ? _goals.first : null;
  
  List<Task> get priorityTasks => 
      _tasks.where((t) => t.isPriority && !t.isCompleted).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  
  List<Task> get backlogTasks => 
      _tasks.where((t) => !t.isPriority && !t.isCompleted).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  List<Task> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList();

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

    _goals = StorageService.getAllGoals();
    _factors = StorageService.getAllFactors();
    _sprintTargets = StorageService.getAllSprintTargets();
    _tasks = StorageService.getAllTasks();
    _habits = StorageService.getAllHabits();
    _reflections = StorageService.getAllReflections();
    _experiments = StorageService.getAllExperiments();
    _barriers = StorageService.getAllBarriers();
    _timeAvailability = StorageService.getTimeAvailability();

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
    final factorIds = _factors.where((f) => f.goalId == id).map((f) => f.id).toList();
    for (final factorId in factorIds) {
      await deleteFactor(factorId);
    }
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
    await StorageService.saveTask(task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await StorageService.saveTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) _tasks[index] = task;
    notifyListeners();
  }

  Future<void> toggleTaskComplete(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.isCompleted = !task.isCompleted;
    task.completedAt = task.isCompleted ? DateTime.now() : null;
    await StorageService.saveTask(task);
    notifyListeners();
  }

  Future<void> promoteTaskToPriority(String id) async {
    if (!canAddPriorityTask) {
      throw Exception('Cannot add more than 2 priority tasks');
    }
    final task = _tasks.firstWhere((t) => t.id == id);
    task.isPriority = true;
    await StorageService.saveTask(task);
    notifyListeners();
  }

  Future<void> demoteTaskToBacklog(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.isPriority = false;
    await StorageService.saveTask(task);
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await StorageService.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
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

  Future<void> logHabit(String id, {required bool completed, String? note, int? mood, String? barrier}) async {
    final habit = _habits.firstWhere((h) => h.id == id);
    habit.logToday(completed: completed, note: note, mood: mood, barrier: barrier);
    await StorageService.saveHabit(habit);
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

  // ========== EXPERIMENTS ==========
  Future<void> addExperiment(Experiment experiment) async {
    await StorageService.saveExperiment(experiment);
    _experiments.add(experiment);
    notifyListeners();
  }

  Future<void> promoteExperimentToTask(String experimentId, {required bool toPriority}) async {
    final experiment = _experiments.firstWhere((e) => e.id == experimentId);
    
    if (toPriority && !canAddPriorityTask) {
      throw Exception('Cannot add more than 2 priority tasks');
    }

    // Create task from experiment
    final task = Task(
      id: StorageService.generateId(),
      title: experiment.description,
      isPriority: toPriority,
      source: TaskSource.experiment,
      experimentId: experimentId,
    );

    await StorageService.saveTask(task);
    _tasks.add(task);

    // Update experiment status
    if (toPriority) {
      experiment.promoteToTop2(task.id);
    } else {
      experiment.promoteToBacklog(task.id);
    }
    await StorageService.saveExperiment(experiment);

    notifyListeners();
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
    final taskCount = getTasksForFactor(factorId).where((t) => t.isCompleted).length;
    final habitLogs = getHabitsForFactor(factorId)
        .fold<int>(0, (sum, h) => sum + h.logs.where((l) => l.completed).length);
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
}
