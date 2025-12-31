import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/goal.dart';
import '../models/growth_area.dart';
import '../models/sprint_target.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/habit.dart';
import '../models/habit_enums.dart';
import '../models/category_model.dart';
import '../models/recurring_task.dart';
import '../models/reflection.dart';
import '../models/reflection_group.dart';
import '../models/reflection_reminder.dart';
import '../models/experiment.dart';
import '../models/time_availability.dart';
import '../models/user_stats.dart';
import '../models/achievement.dart';
import '../models/focus_log.dart';

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
  static const String userStatsBox = 'userStats';
  static const String achievementsBox = 'achievements';
  static const String focusLogsBox = 'focusLogs';
  static const String reflectionGroupsBox = 'reflectionGroups';
  static const String categoriesBox = 'categories';
  static const String recurringTasksBox = 'recurringTasks';

  static final Uuid _uuid = const Uuid();

  /// Track if storage has been initialized
  static bool _isInitialized = false;

  /// Check if storage is initialized
  static bool get isInitialized => _isInitialized;

  /// Generate a unique ID
  static String generateId() => _uuid.v4();

  /// Clear all Hive data (for corruption recovery)
  static Future<void> clearAllData() async {
    await Hive.initFlutter();
    await Hive.deleteFromDisk();
    _isInitialized = false;
  }

  /// Register all type adapters (only once)
  static void _registerAdapters() {
    // Use try-catch to handle already registered adapters
    void tryRegister<T>(TypeAdapter<T> adapter) {
      try {
        Hive.registerAdapter(adapter);
      } catch (_) {
        // Adapter already registered, ignore
      }
    }

    tryRegister(GoalAdapter());
    tryRegister(GrowthAreaAdapter());
    tryRegister(GrowthAreaTypeAdapter());
    tryRegister(SprintTargetAdapter());
    tryRegister(SprintDurationAdapter());
    tryRegister(TaskAdapter());
    tryRegister(TaskSourceAdapter());
    tryRegister(TaskEffortAdapter());
    tryRegister(TaskImpactAdapter());
    tryRegister(TaskAbandonReasonAdapter());
    tryRegister(SubtaskAdapter());
    tryRegister(HabitAdapter());
    tryRegister(HabitTypeAdapter());
    tryRegister(HabitLogAdapter());
    tryRegister(BarrierEntryAdapter());
    tryRegister(ReflectionAdapter());
    tryRegister(ExperimentAdapter());
    tryRegister(ExperimentStatusAdapter());
    tryRegister(TimeAvailabilityAdapter());
    // Register ReflectionReminderFrequencyAdapter BEFORE UserStatsAdapter
    // because UserStats contains ReflectionReminderFrequency
    tryRegister(ReflectionReminderFrequencyAdapter());
    tryRegister(UserStatsAdapter());
    tryRegister(AchievementAdapter());
    tryRegister(FocusLogAdapter());
    // Register ReflectionGroup adapter
    tryRegister(ReflectionGroupAdapter());
    // Phase 3: New model adapters for Today page
    tryRegister(CategoryModelAdapter());
    tryRegister(RecurringTaskAdapter());
    tryRegister(RecurringTaskLogAdapter());
    tryRegister(HabitEvaluationTypeAdapter());
    tryRegister(HabitFrequencyTypeAdapter());
    tryRegister(PriorityLevelAdapter());
  }

  /// Ensure a box is open (used for defensive access)
  static Future<Box<T>> _ensureBoxOpen<T>(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<T>(boxName);
    }
    return Hive.box<T>(boxName);
  }

  /// Ensure settings box is open (untyped)
  static Future<Box<dynamic>> _ensureSettingsBoxOpen() async {
    if (!Hive.isBoxOpen(settingsBox)) {
      return await Hive.openBox(settingsBox);
    }
    return Hive.box(settingsBox);
  }

  /// Reopen all boxes (recovery method for hot reload issues)
  static Future<void> reopenBoxes() async {
    await Hive.initFlutter();
    _registerAdapters();
    await _openAllBoxes();
    _isInitialized = true;
  }

  /// Open all boxes
  static Future<void> _openAllBoxes() async {
    await _ensureBoxOpen<Goal>(goalsBox);
    await _ensureBoxOpen<Factor>(factorsBox);
    await _ensureBoxOpen<SprintTarget>(sprintTargetsBox);
    await _ensureBoxOpen<Task>(tasksBox);
    await _ensureBoxOpen<Subtask>(subtasksBox);
    await _ensureBoxOpen<Habit>(habitsBox);
    await _ensureBoxOpen<Reflection>(reflectionsBox);
    await _ensureBoxOpen<Experiment>(experimentsBox);
    await _ensureBoxOpen<BarrierEntry>(barriersBox);
    await _ensureSettingsBoxOpen();
    await _ensureBoxOpen<UserStats>(userStatsBox);
    await _ensureBoxOpen<Achievement>(achievementsBox);
    await _ensureBoxOpen<FocusLog>(focusLogsBox);
    await _ensureBoxOpen<ReflectionGroup>(reflectionGroupsBox);
    await _ensureBoxOpen<CategoryModel>(categoriesBox);
    await _ensureBoxOpen<RecurringTask>(recurringTasksBox);
  }

  /// Initialize Hive and register all adapters
  static Future<void> initialize() async {
    if (_isInitialized) return;

    await Hive.initFlutter();
    _registerAdapters();
    await _openAllBoxes();

    _isInitialized = true;
  }

  // ========== GOALS ==========

  static Box<Goal> get _goalsBox {
    if (!Hive.isBoxOpen(goalsBox)) {
      throw StateError(
        'Goals box not open. Ensure StorageService.initialize() is called.',
      );
    }
    return Hive.box<Goal>(goalsBox);
  }

  static List<Goal> getAllGoals() {
    if (!Hive.isBoxOpen(goalsBox)) return [];
    return _goalsBox.values.toList();
  }

  static Goal? getGoal(String id) => _goalsBox.get(id);

  static Future<void> saveGoal(Goal goal) async {
    await _goalsBox.put(goal.id, goal);
  }

  static Future<void> deleteGoal(String id) async {
    await _goalsBox.delete(id);
  }

  // ========== FACTORS ==========

  static Box<Factor> get _factorsBox {
    if (!Hive.isBoxOpen(factorsBox)) {
      throw StateError(
        'Factors box not open. Ensure StorageService.initialize() is called.',
      );
    }
    return Hive.box<Factor>(factorsBox);
  }

  static List<Factor> getAllFactors() {
    if (!Hive.isBoxOpen(factorsBox)) return [];
    return _factorsBox.values.toList();
  }

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

  static Box<SprintTarget> get _sprintTargetsBox {
    if (!Hive.isBoxOpen(sprintTargetsBox)) {
      throw StateError(
        'SprintTargets box not open. Ensure StorageService.initialize() is called.',
      );
    }
    return Hive.box<SprintTarget>(sprintTargetsBox);
  }

  static List<SprintTarget> getAllSprintTargets() {
    if (!Hive.isBoxOpen(sprintTargetsBox)) return [];
    return _sprintTargetsBox.values.toList();
  }

  static List<SprintTarget> getActiveSprintTargets() => _sprintTargetsBox.values
      .where((t) => !t.isCompleted && !t.isOverdue)
      .toList();

  static Future<void> saveSprintTarget(SprintTarget target) async {
    await _sprintTargetsBox.put(target.id, target);
  }

  static Future<void> deleteSprintTarget(String id) async {
    await _sprintTargetsBox.delete(id);
  }

  // ========== TASKS ==========

  static Box<Task> get _tasksBox {
    if (!Hive.isBoxOpen(tasksBox)) {
      throw StateError(
        'Tasks box not open. Ensure StorageService.initialize() is called.',
      );
    }
    return Hive.box<Task>(tasksBox);
  }

  static List<Task> getAllTasks() {
    if (!Hive.isBoxOpen(tasksBox)) return [];
    return _tasksBox.values.toList();
  }

  static List<Task> getPriorityTasks() {
    if (!Hive.isBoxOpen(tasksBox)) return [];
    return _tasksBox.values
        .where((t) => t.isPriority && !t.isCompleted)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  static List<Task> getBacklogTasks() {
    if (!Hive.isBoxOpen(tasksBox)) return [];
    return _tasksBox.values
        .where((t) => !t.isPriority && !t.isCompleted)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  static List<Task> getCompletedTasks() {
    if (!Hive.isBoxOpen(tasksBox)) return [];
    return _tasksBox.values.where((t) => t.isCompleted).toList();
  }

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

  static Box<Subtask> get _subtasksBox {
    if (!Hive.isBoxOpen(subtasksBox)) {
      throw StateError(
        'Subtasks box not open. Ensure StorageService.initialize() is called.',
      );
    }
    return Hive.box<Subtask>(subtasksBox);
  }

  static List<Subtask> getSubtasksForTask(String taskId) {
    if (!Hive.isBoxOpen(subtasksBox)) {
      return [];
    }
    return _subtasksBox.values.where((s) => s.parentTaskId == taskId).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  static Future<void> saveSubtask(Subtask subtask) async {
    await _subtasksBox.put(subtask.id, subtask);
  }

  static Future<void> deleteSubtask(String id) async {
    await _subtasksBox.delete(id);
  }

  // ========== HABITS ==========

  static Box<Habit> get _habitsBox {
    if (!Hive.isBoxOpen(habitsBox)) {
      throw StateError(
        'Habits box not open. Ensure StorageService.initialize() is called.',
      );
    }
    return Hive.box<Habit>(habitsBox);
  }

  static List<Habit> getAllHabits() {
    if (!Hive.isBoxOpen(habitsBox)) return [];
    return _habitsBox.values.toList();
  }

  static List<Habit> getActiveHabits() =>
      _habitsBox.values.where((h) => h.isActive).toList();

  static List<Habit> getLimitingHabits() => _habitsBox.values
      .where((h) => h.type == HabitType.quit && h.isActive)
      .toList();

  static List<Habit> getScriptedActions() => _habitsBox.values
      .where((h) => h.type == HabitType.build && h.isActive)
      .toList();

  static Future<void> saveHabit(Habit habit) async {
    await _habitsBox.put(habit.id, habit);
  }

  static Future<void> deleteHabit(String id) async {
    await _habitsBox.delete(id);
  }

  // ========== BARRIERS ==========

  static Box<BarrierEntry> get _barriersBox {
    if (!Hive.isBoxOpen(barriersBox)) {
      throw StateError(
        'Barriers box not open. Ensure StorageService.initialize() is called.',
      );
    }
    return Hive.box<BarrierEntry>(barriersBox);
  }

  static List<BarrierEntry> getAllBarriers() {
    if (!Hive.isBoxOpen(barriersBox)) return [];
    return _barriersBox.values.toList();
  }

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

  static Box<Reflection> get _reflectionsBox {
    if (!Hive.isBoxOpen(reflectionsBox)) {
      throw StateError(
        'Reflections box not open. Ensure StorageService.initialize() is called.',
      );
    }
    return Hive.box<Reflection>(reflectionsBox);
  }

  static List<Reflection> getAllReflections() {
    if (!Hive.isBoxOpen(reflectionsBox)) return [];
    return _reflectionsBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Reflection? getReflection(String id) => _reflectionsBox.get(id);

  static Future<void> saveReflection(Reflection reflection) async {
    await _reflectionsBox.put(reflection.id, reflection);
  }

  static Future<void> deleteReflection(String id) async {
    await _reflectionsBox.delete(id);
  }

  // ========== REFLECTION GROUPS ==========

  static Box<ReflectionGroup> get _reflectionGroupsBox {
    if (!Hive.isBoxOpen(reflectionGroupsBox)) {
      throw StateError(
        'ReflectionGroups box not open. Ensure StorageService.initialize() is called.',
      );
    }
    return Hive.box<ReflectionGroup>(reflectionGroupsBox);
  }

  static List<ReflectionGroup> getAllReflectionGroups() {
    if (!Hive.isBoxOpen(reflectionGroupsBox)) return [];
    return _reflectionGroupsBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<ReflectionGroup> getActiveReflectionGroups() =>
      getAllReflectionGroups().where((g) => !g.isArchived).toList();

  static List<ReflectionGroup> getArchivedReflectionGroups() =>
      getAllReflectionGroups().where((g) => g.isArchived).toList();

  static ReflectionGroup? getReflectionGroup(String id) =>
      _reflectionGroupsBox.get(id);

  static Future<void> saveReflectionGroup(ReflectionGroup group) async {
    await _reflectionGroupsBox.put(group.id, group);
  }

  static Future<void> deleteReflectionGroup(String id) async {
    await _reflectionGroupsBox.delete(id);
  }

  // ========== EXPERIMENTS ==========

  static Box<Experiment> get _experimentsBox {
    if (!Hive.isBoxOpen(experimentsBox)) {
      throw StateError(
        'Experiments box not open. Ensure StorageService.initialize() is called.',
      );
    }
    return Hive.box<Experiment>(experimentsBox);
  }

  static List<Experiment> getAllExperiments() {
    if (!Hive.isBoxOpen(experimentsBox)) return [];
    return _experimentsBox.values.toList();
  }

  static List<Experiment> getPendingExperiments() => _experimentsBox.values
      .where((e) => e.status == ExperimentStatus.pending)
      .toList();

  static List<Experiment> getActiveExperiments() =>
      _experimentsBox.values.where((e) => e.isActionable).toList();

  static List<Experiment> getArchivedExperiments() => _experimentsBox.values
      .where((e) => e.status == ExperimentStatus.archived)
      .toList();

  static List<Experiment> getExperimentsForReflection(String reflectionId) =>
      _experimentsBox.values
          .where((e) => e.reflectionId == reflectionId)
          .toList();

  static List<Experiment> getExperimentsForGroup(String groupId) =>
      _experimentsBox.values.where((e) => e.groupId == groupId).toList();

  static Future<void> saveExperiment(Experiment experiment) async {
    await _experimentsBox.put(experiment.id, experiment);
  }

  static Future<void> deleteExperiment(String id) async {
    await _experimentsBox.delete(id);
  }

  // ========== SETTINGS ==========

  static Box<dynamic> get _settingsBox {
    if (!Hive.isBoxOpen(settingsBox)) {
      throw StateError(
        'Settings box not open. Ensure StorageService.initialize() is called.',
      );
    }
    return Hive.box(settingsBox);
  }

  static TimeAvailability? getTimeAvailability() {
    if (!Hive.isBoxOpen(settingsBox)) return null;
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

  static List<String> getTaskCategories() {
    if (!Hive.isBoxOpen(settingsBox)) return [];
    return List<String>.from(
      _settingsBox.get(
        'taskCategories',
        defaultValue: <String>[
          'General',
          'Assignment',
          'Activity',
          'Quiz',
          'Exam',
          'Project',
          'Deadline',
          'Chore',
        ],
      ),
    );
  }

  static Future<void> saveTaskCategories(List<String> categories) async {
    await _settingsBox.put('taskCategories', categories);
  }

  // ========== USER STATS (Gamification) ==========

  static Box<UserStats> get _userStatsBox {
    if (!Hive.isBoxOpen(userStatsBox)) {
      throw StateError(
        'UserStats box not open. Ensure StorageService.initialize() is called.',
      );
    }
    return Hive.box<UserStats>(userStatsBox);
  }

  static UserStats getUserStats() {
    if (!Hive.isBoxOpen(userStatsBox)) return UserStats();
    final stats = _userStatsBox.get('main');
    if (stats != null) return stats;
    // Create default stats
    final newStats = UserStats();
    _userStatsBox.put('main', newStats);
    return newStats;
  }

  static Future<void> saveUserStats(UserStats stats) async {
    await _userStatsBox.put('main', stats);
  }

  // ========== ACHIEVEMENTS ==========

  static Box<Achievement> get _achievementsBox {
    if (!Hive.isBoxOpen(achievementsBox)) {
      throw StateError(
        'Achievements box not open. Ensure StorageService.initialize() is called.',
      );
    }
    return Hive.box<Achievement>(achievementsBox);
  }

  static List<Achievement> getAllAchievements() {
    if (!Hive.isBoxOpen(achievementsBox)) return [];
    return _achievementsBox.values.toList();
  }

  static Achievement? getAchievement(String id) => _achievementsBox.get(id);

  static Future<void> saveAchievement(Achievement achievement) async {
    await _achievementsBox.put(achievement.id, achievement);
  }

  // --- Focus Session Logs ---
  static Future<void> saveFocusLog(FocusLog log) async {
    final box = await _ensureBoxOpen<FocusLog>(focusLogsBox);
    await box.put(log.id, log);
  }

  static List<FocusLog> getAllFocusLogs() {
    if (!Hive.isBoxOpen(focusLogsBox)) return [];
    return Hive.box<FocusLog>(focusLogsBox).values.toList();
  }

  // ========== CATEGORIES (Phase 3) ==========

  static Box<CategoryModel> get _categoriesBox {
    if (!Hive.isBoxOpen(categoriesBox)) {
      throw StateError(
        'Categories box not open. Ensure StorageService.initialize() is called.',
      );
    }
    return Hive.box<CategoryModel>(categoriesBox);
  }

  static List<CategoryModel> getAllCategories() {
    if (!Hive.isBoxOpen(categoriesBox)) return [];
    return _categoriesBox.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  static CategoryModel? getCategory(String id) => _categoriesBox.get(id);

  static Future<void> saveCategory(CategoryModel category) async {
    await _categoriesBox.put(category.id, category);
  }

  static Future<void> deleteCategory(String id) async {
    await _categoriesBox.delete(id);
  }

  /// Initialize default categories if none exist
  static Future<void> initializeDefaultCategories() async {
    if (getAllCategories().isEmpty) {
      for (final category in DefaultCategories.all) {
        await saveCategory(category);
      }
    }
  }

  // ========== RECURRING TASKS (Phase 3) ==========

  static Box<RecurringTask> get _recurringTasksBox {
    if (!Hive.isBoxOpen(recurringTasksBox)) {
      throw StateError(
        'RecurringTasks box not open. Ensure StorageService.initialize() is called.',
      );
    }
    return Hive.box<RecurringTask>(recurringTasksBox);
  }

  static List<RecurringTask> getAllRecurringTasks() {
    if (!Hive.isBoxOpen(recurringTasksBox)) return [];
    return _recurringTasksBox.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  static List<RecurringTask> getActiveRecurringTasks() {
    return getAllRecurringTasks().where((t) => !t.isArchived).toList();
  }

  static List<RecurringTask> getRecurringTasksForDate(DateTime date) {
    return getActiveRecurringTasks()
        .where((t) => t.isScheduledFor(date))
        .toList();
  }

  static RecurringTask? getRecurringTask(String id) =>
      _recurringTasksBox.get(id);

  static Future<void> saveRecurringTask(RecurringTask task) async {
    await _recurringTasksBox.put(task.id, task);
  }

  static Future<void> deleteRecurringTask(String id) async {
    await _recurringTasksBox.delete(id);
  }
}
