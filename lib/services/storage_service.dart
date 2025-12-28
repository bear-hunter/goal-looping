import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/goal.dart';
import '../models/factor.dart';
import '../models/sprint_target.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/habit.dart';
import '../models/reflection.dart';
import '../models/experiment.dart';
import '../models/time_availability.dart';

/// Storage service for all app data using Hive
class StorageService {
  static const String goalsBox = 'goals';
  static const String factorsBox = 'factors';
  static const String sprintTargetsBox = 'sprintTargets';
  static const String tasksBox = 'tasks';
  static const String subtasksBox = 'subtasks';
  static const String habitsBox = 'habits';
  static const String reflectionsBox = 'reflections';
  static const String experimentsBox = 'experiments';
  static const String barriersBox = 'barriers';
  static const String settingsBox = 'settings';

  static final Uuid _uuid = const Uuid();

  /// Generate a unique ID
  static String generateId() => _uuid.v4();

  /// Initialize Hive and register all adapters
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(GoalAdapter());
    Hive.registerAdapter(FactorAdapter());
    Hive.registerAdapter(FactorTypeAdapter());
    Hive.registerAdapter(SprintTargetAdapter());
    Hive.registerAdapter(SprintDurationAdapter());
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TaskSourceAdapter());
    Hive.registerAdapter(SubtaskAdapter());
    Hive.registerAdapter(HabitAdapter());
    Hive.registerAdapter(HabitTypeAdapter());
    Hive.registerAdapter(HabitLogAdapter());
    Hive.registerAdapter(BarrierEntryAdapter());
    Hive.registerAdapter(ReflectionAdapter());
    Hive.registerAdapter(ExperimentAdapter());
    Hive.registerAdapter(ExperimentStatusAdapter());
    Hive.registerAdapter(TimeAvailabilityAdapter());

    // Open all boxes
    await Hive.openBox<Goal>(goalsBox);
    await Hive.openBox<Factor>(factorsBox);
    await Hive.openBox<SprintTarget>(sprintTargetsBox);
    await Hive.openBox<Task>(tasksBox);
    await Hive.openBox<Subtask>(subtasksBox);
    await Hive.openBox<Habit>(habitsBox);
    await Hive.openBox<Reflection>(reflectionsBox);
    await Hive.openBox<Experiment>(experimentsBox);
    await Hive.openBox<BarrierEntry>(barriersBox);
    await Hive.openBox(settingsBox);
  }

  // ========== GOALS ==========
  
  static Box<Goal> get _goalsBox => Hive.box<Goal>(goalsBox);

  static List<Goal> getAllGoals() => _goalsBox.values.toList();

  static Goal? getGoal(String id) => _goalsBox.get(id);

  static Future<void> saveGoal(Goal goal) async {
    await _goalsBox.put(goal.id, goal);
  }

  static Future<void> deleteGoal(String id) async {
    await _goalsBox.delete(id);
  }

  // ========== FACTORS ==========

  static Box<Factor> get _factorsBox => Hive.box<Factor>(factorsBox);

  static List<Factor> getAllFactors() => _factorsBox.values.toList();

  static List<Factor> getFactorsForGoal(String goalId) =>
      _factorsBox.values.where((f) => f.goalId == goalId).toList();

  static Factor? getFactor(String id) => _factorsBox.get(id);

  static Future<void> saveFactor(Factor factor) async {
    await _factorsBox.put(factor.id, factor);
  }

  static Future<void> deleteFactor(String id) async {
    await _factorsBox.delete(id);
  }

  // ========== SPRINT TARGETS ==========

  static Box<SprintTarget> get _sprintTargetsBox => 
      Hive.box<SprintTarget>(sprintTargetsBox);

  static List<SprintTarget> getAllSprintTargets() => 
      _sprintTargetsBox.values.toList();

  static List<SprintTarget> getActiveSprintTargets() =>
      _sprintTargetsBox.values.where((t) => !t.isCompleted && !t.isOverdue).toList();

  static Future<void> saveSprintTarget(SprintTarget target) async {
    await _sprintTargetsBox.put(target.id, target);
  }

  static Future<void> deleteSprintTarget(String id) async {
    await _sprintTargetsBox.delete(id);
  }

  // ========== TASKS ==========

  static Box<Task> get _tasksBox => Hive.box<Task>(tasksBox);

  static List<Task> getAllTasks() => _tasksBox.values.toList();

  static List<Task> getPriorityTasks() =>
      _tasksBox.values
          .where((t) => t.isPriority && !t.isCompleted)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  static List<Task> getBacklogTasks() =>
      _tasksBox.values
          .where((t) => !t.isPriority && !t.isCompleted)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  static List<Task> getCompletedTasks() =>
      _tasksBox.values.where((t) => t.isCompleted).toList();

  static Task? getTask(String id) => _tasksBox.get(id);

  static Future<void> saveTask(Task task) async {
    await _tasksBox.put(task.id, task);
  }

  static Future<void> deleteTask(String id) async {
    await _tasksBox.delete(id);
    // Also delete subtasks
    final subtasks = getSubtasksForTask(id);
    for (final subtask in subtasks) {
      await deleteSubtask(subtask.id);
    }
  }

  // ========== SUBTASKS ==========

  static Box<Subtask> get _subtasksBox => Hive.box<Subtask>(subtasksBox);

  static List<Subtask> getSubtasksForTask(String taskId) =>
      _subtasksBox.values
          .where((s) => s.parentTaskId == taskId)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  static Future<void> saveSubtask(Subtask subtask) async {
    await _subtasksBox.put(subtask.id, subtask);
  }

  static Future<void> deleteSubtask(String id) async {
    await _subtasksBox.delete(id);
  }

  // ========== HABITS ==========

  static Box<Habit> get _habitsBox => Hive.box<Habit>(habitsBox);

  static List<Habit> getAllHabits() => _habitsBox.values.toList();

  static List<Habit> getActiveHabits() =>
      _habitsBox.values.where((h) => h.isActive).toList();

  static List<Habit> getLimitingHabits() =>
      _habitsBox.values
          .where((h) => h.type == HabitType.limiting && h.isActive)
          .toList();

  static List<Habit> getScriptedActions() =>
      _habitsBox.values
          .where((h) => h.type == HabitType.scripted && h.isActive)
          .toList();

  static Future<void> saveHabit(Habit habit) async {
    await _habitsBox.put(habit.id, habit);
  }

  static Future<void> deleteHabit(String id) async {
    await _habitsBox.delete(id);
  }

  // ========== BARRIERS ==========

  static Box<BarrierEntry> get _barriersBox => 
      Hive.box<BarrierEntry>(barriersBox);

  static List<BarrierEntry> getAllBarriers() => _barriersBox.values.toList();

  static List<BarrierEntry> getRecentBarriers({int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _barriersBox.values
        .where((b) => b.occurredAt.isAfter(cutoff))
        .toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }

  static Future<void> saveBarrier(BarrierEntry barrier) async {
    await _barriersBox.put(barrier.id, barrier);
  }

  static Future<void> deleteBarrier(String id) async {
    await _barriersBox.delete(id);
  }

  // ========== REFLECTIONS ==========

  static Box<Reflection> get _reflectionsBox => 
      Hive.box<Reflection>(reflectionsBox);

  static List<Reflection> getAllReflections() => 
      _reflectionsBox.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  static Reflection? getReflection(String id) => _reflectionsBox.get(id);

  static Future<void> saveReflection(Reflection reflection) async {
    await _reflectionsBox.put(reflection.id, reflection);
  }

  static Future<void> deleteReflection(String id) async {
    await _reflectionsBox.delete(id);
  }

  // ========== EXPERIMENTS ==========

  static Box<Experiment> get _experimentsBox => 
      Hive.box<Experiment>(experimentsBox);

  static List<Experiment> getAllExperiments() => _experimentsBox.values.toList();

  static List<Experiment> getPendingExperiments() =>
      _experimentsBox.values
          .where((e) => e.status == ExperimentStatus.pending)
          .toList();

  static List<Experiment> getExperimentsForReflection(String reflectionId) =>
      _experimentsBox.values
          .where((e) => e.reflectionId == reflectionId)
          .toList();

  static Future<void> saveExperiment(Experiment experiment) async {
    await _experimentsBox.put(experiment.id, experiment);
  }

  static Future<void> deleteExperiment(String id) async {
    await _experimentsBox.delete(id);
  }

  // ========== SETTINGS ==========

  static Box get _settingsBox => Hive.box(settingsBox);

  static TimeAvailability? getTimeAvailability() {
    final index = _settingsBox.get('timeAvailability');
    if (index == null) return null;
    return TimeAvailability.values[index as int];
  }

  static Future<void> setTimeAvailability(TimeAvailability value) async {
    await _settingsBox.put('timeAvailability', value.index);
  }

  static bool get hasCompletedOnboarding =>
      _settingsBox.get('onboardingComplete', defaultValue: false) as bool;

  static Future<void> setOnboardingComplete(bool value) async {
    await _settingsBox.put('onboardingComplete', value);
  }
}
