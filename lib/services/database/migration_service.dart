/// Migration service for transitioning from Hive to Drift (SQLite)
/// 
/// Strategy: Parallel operation with gradual migration
/// - Both databases run simultaneously during transition
/// - New data written to both Hive (legacy) and Drift (new)
/// - Background migration of existing Hive data to Drift
/// - Feature flag to switch reads from Hive to Drift per entity
/// 
/// This ensures zero data loss and allows rollback if issues arise

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:drift/drift.dart';

import '../storage_service.dart';
import 'app_database.dart';
import '../../models/goal.dart';
import '../../models/factor.dart';
import '../../models/task.dart';
import '../../models/subtask.dart';
import '../../models/habit.dart';
import '../../models/reflection.dart';
import '../../models/experiment.dart';
import '../../models/focus_log.dart';
import '../../models/reflection_group.dart';
import '../../models/category_model.dart';
import '../../models/recurring_task.dart';

/// Migration status for tracking progress
enum MigrationStatus {
  notStarted,
  inProgress,
  completed,
  failed,
}

/// Per-entity migration state
class EntityMigrationState {
  final String entityName;
  final int totalCount;
  final int migratedCount;
  final MigrationStatus status;
  final String? error;
  
  EntityMigrationState({
    required this.entityName,
    required this.totalCount,
    required this.migratedCount,
    required this.status,
    this.error,
  });
  
  double get progress => totalCount > 0 ? migratedCount / totalCount : 0;
  
  EntityMigrationState copyWith({
    int? migratedCount,
    MigrationStatus? status,
    String? error,
  }) {
    return EntityMigrationState(
      entityName: entityName,
      totalCount: totalCount,
      migratedCount: migratedCount ?? this.migratedCount,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

/// Main migration service
class DatabaseMigrationService {
  final AppDatabase _db;
  
  // Migration state per entity
  final Map<String, EntityMigrationState> _migrationState = {};
  
  // Feature flags - which entities use Drift for reads
  static const Map<String, bool> _useDriftForReads = {
    'goals': false,
    'factors': false,
    'tasks': false,
    'subtasks': false,
    'habits': false,
    'habitLogs': false,
    'reflections': false,
    'experiments': false,
    'focusLogs': false,
    'reflectionGroups': false,
    'categories': false,
    'recurringTasks': false,
  };
  
  DatabaseMigrationService(this._db);
  
  /// Check if migration is needed
  Future<bool> isMigrationNeeded() async {
    final prefs = await Hive.openBox('migration_state');
    return !(prefs.get('migration_completed', defaultValue: false) as bool);
  }
  
  /// Get overall migration progress
  double get overallProgress {
    if (_migrationState.isEmpty) return 0;
    final total = _migrationState.values.map((s) => s.progress).reduce((a, b) => a + b);
    return total / _migrationState.length;
  }
  
  /// Get migration state for UI
  Map<String, EntityMigrationState> get migrationState => Map.unmodifiable(_migrationState);
  
  /// Run full migration in background
  Future<void> runMigration({
    void Function(double progress)? onProgress,
    void Function(String entity)? onEntityStart,
    void Function(String entity, String error)? onError,
  }) async {
    try {
      // Initialize state
      await _initializeMigrationState();
      
      // Migrate each entity type
      await _migrateGoals(onProgress, onEntityStart);
      await _migrateFactors(onProgress, onEntityStart);
      await _migrateCategories(onProgress, onEntityStart);
      await _migrateTasks(onProgress, onEntityStart);
      await _migrateSubtasks(onProgress, onEntityStart);
      await _migrateHabits(onProgress, onEntityStart);
      await _migrateReflections(onProgress, onEntityStart);
      await _migrateExperiments(onProgress, onEntityStart);
      await _migrateFocusLogs(onProgress, onEntityStart);
      await _migrateReflectionGroups(onProgress, onEntityStart);
      await _migrateRecurringTasks(onProgress, onEntityStart);
      
      // Mark migration as complete
      final prefs = await Hive.openBox('migration_state');
      await prefs.put('migration_completed', true);
      await prefs.put('migration_date', DateTime.now().toIso8601String());
      
    } catch (e) {
      debugPrint('Migration error: $e');
      rethrow;
    }
  }
  
  Future<void> _initializeMigrationState() async {
    _migrationState['goals'] = EntityMigrationState(
      entityName: 'Goals',
      totalCount: StorageService.getAllGoals().length,
      migratedCount: 0,
      status: MigrationStatus.notStarted,
    );
    _migrationState['factors'] = EntityMigrationState(
      entityName: 'Factors',
      totalCount: StorageService.getAllFactors().length,
      migratedCount: 0,
      status: MigrationStatus.notStarted,
    );
    _migrationState['tasks'] = EntityMigrationState(
      entityName: 'Tasks',
      totalCount: StorageService.getAllTasks().length,
      migratedCount: 0,
      status: MigrationStatus.notStarted,
    );
    _migrationState['habits'] = EntityMigrationState(
      entityName: 'Habits',
      totalCount: StorageService.getAllHabits().length,
      migratedCount: 0,
      status: MigrationStatus.notStarted,
    );
    _migrationState['reflections'] = EntityMigrationState(
      entityName: 'Reflections',
      totalCount: StorageService.getAllReflections().length,
      migratedCount: 0,
      status: MigrationStatus.notStarted,
    );
  }
  
  // ==========================================================================
  // ENTITY MIGRATION METHODS
  // ==========================================================================
  
  Future<void> _migrateGoals(
    void Function(double)? onProgress,
    void Function(String)? onEntityStart,
  ) async {
    onEntityStart?.call('Goals');
    _migrationState['goals'] = _migrationState['goals']!.copyWith(
      status: MigrationStatus.inProgress,
    );
    
    final goals = StorageService.getAllGoals();
    int migrated = 0;
    
    for (final goal in goals) {
      await _db.into(_db.goals).insertOnConflictUpdate(
        GoalsCompanion(
          id: Value(goal.id),
          title: Value(goal.title),
          description: Value(goal.description),
          targetDate: Value(goal.targetDate),
          createdAt: Value(goal.createdAt),
        ),
      );
      
      // Migrate goal-factor links
      for (final factorId in goal.factorIds) {
        await _db.into(_db.goalFactorLinks).insertOnConflictUpdate(
          GoalFactorLinksCompanion(
            goalId: Value(goal.id),
            factorId: Value(factorId),
          ),
        );
      }
      
      migrated++;
      _migrationState['goals'] = _migrationState['goals']!.copyWith(
        migratedCount: migrated,
      );
      onProgress?.call(overallProgress);
    }
    
    _migrationState['goals'] = _migrationState['goals']!.copyWith(
      status: MigrationStatus.completed,
    );
  }
  
  Future<void> _migrateFactors(
    void Function(double)? onProgress,
    void Function(String)? onEntityStart,
  ) async {
    onEntityStart?.call('Factors');
    _migrationState['factors'] = _migrationState['factors']!.copyWith(
      status: MigrationStatus.inProgress,
    );
    
    final factors = StorageService.getAllFactors();
    int migrated = 0;
    
    for (final factor in factors) {
      await _db.into(_db.factors).insertOnConflictUpdate(
        FactorsCompanion(
          id: Value(factor.id),
          name: Value(factor.name),
          type: Value(factor.type.index),
          targetLevel: Value(factor.targetLevel),
          currentLevel: Value(factor.currentLevel),
          description: Value(factor.description),
          goalId: Value(factor.goalId),
          lastUpdated: Value(factor.lastUpdated),
          targetDescription: Value(factor.targetDescription),
          currentDescription: Value(factor.currentDescription),
          isActiveFocus: Value(factor.isActiveFocus),
          lastWorkedOn: Value(factor.lastWorkedOn),
          healthPercent: Value(factor.healthPercent),
        ),
      );
      
      // Migrate factor-habit links
      for (final habitId in factor.linkedHabitIds) {
        await _db.into(_db.factorHabitLinks).insertOnConflictUpdate(
          FactorHabitLinksCompanion(
            factorId: Value(factor.id),
            habitId: Value(habitId),
          ),
        );
      }
      
      migrated++;
      _migrationState['factors'] = _migrationState['factors']!.copyWith(
        migratedCount: migrated,
      );
      onProgress?.call(overallProgress);
    }
    
    _migrationState['factors'] = _migrationState['factors']!.copyWith(
      status: MigrationStatus.completed,
    );
  }
  
  Future<void> _migrateCategories(
    void Function(double)? onProgress,
    void Function(String)? onEntityStart,
  ) async {
    onEntityStart?.call('Categories');
    
    final categories = StorageService.getAllCategories();
    
    for (final category in categories) {
      await _db.into(_db.categories).insertOnConflictUpdate(
        CategoriesCompanion(
          id: Value(category.id),
          name: Value(category.name),
          iconCodePoint: Value(category.iconCodePoint),
          iconFontFamily: Value(category.iconFontFamily),
          colorValue: Value(category.colorValue),
          isDefault: Value(category.isDefault),
          createdAt: Value(category.createdAt),
          sortOrder: Value(category.sortOrder),
        ),
      );
    }
    
    onProgress?.call(overallProgress);
  }
  
  Future<void> _migrateTasks(
    void Function(double)? onProgress,
    void Function(String)? onEntityStart,
  ) async {
    onEntityStart?.call('Tasks');
    _migrationState['tasks'] = _migrationState['tasks']!.copyWith(
      status: MigrationStatus.inProgress,
    );
    
    final tasks = StorageService.getAllTasks();
    int migrated = 0;
    
    // Batch insert for better performance with large datasets
    const batchSize = 100;
    final batches = <List<Task>>[];
    
    for (var i = 0; i < tasks.length; i += batchSize) {
      batches.add(tasks.sublist(i, (i + batchSize).clamp(0, tasks.length)));
    }
    
    for (final batch in batches) {
      final companions = batch.map((task) => TasksCompanion(
        id: Value(task.id),
        title: Value(task.title),
        description: Value(task.description),
        isPriority: Value(task.isPriority),
        isCompleted: Value(task.isCompleted),
        source: Value(task.source.index),
        createdAt: Value(task.createdAt),
        completedAt: Value(task.completedAt),
        experimentId: Value(task.experimentId),
        sortOrder: Value(task.sortOrder),
        effort: Value(task.effort.index),
        impact: Value(task.impact.index),
        addedToPriorityAt: Value(task.addedToPriorityAt),
        abandonReason: Value(task.abandonReason?.index),
        blockedByTaskId: Value(task.blockedByTaskId),
        category: Value(task.category),
        deadline: Value(task.deadline),
        customTag: Value(task.customTag),
        marginalGainDescription: Value(task.marginalGainDescription),
        isResearchTask: Value(task.isResearchTask),
        categoryId: Value(task.categoryId),
        checklistItemsJson: Value(task.checklistItems != null 
            ? jsonEncode(task.checklistItems) : null),
        checklistCompletedJson: Value(task.checklistCompleted != null 
            ? jsonEncode(task.checklistCompleted) : null),
        priorityLevel: Value(task.priorityLevel.index),
        note: Value(task.note),
        isPending: Value(task.isPending),
        reminderTimesJson: Value(jsonEncode(task.reminderTimes)),
        scheduledDate: Value(task.scheduledDate),
      )).toList();
      
      await _db.batchInsertTasks(companions);
      
      // Migrate task-factor links
      for (final task in batch) {
        for (final factorId in task.linkedFactorIds) {
          await _db.into(_db.taskFactorLinks).insertOnConflictUpdate(
            TaskFactorLinksCompanion(
              taskId: Value(task.id),
              factorId: Value(factorId),
            ),
          );
        }
      }
      
      migrated += batch.length;
      _migrationState['tasks'] = _migrationState['tasks']!.copyWith(
        migratedCount: migrated,
      );
      onProgress?.call(overallProgress);
    }
    
    _migrationState['tasks'] = _migrationState['tasks']!.copyWith(
      status: MigrationStatus.completed,
    );
  }
  
  Future<void> _migrateSubtasks(
    void Function(double)? onProgress,
    void Function(String)? onEntityStart,
  ) async {
    onEntityStart?.call('Subtasks');
    
    // Subtasks are stored per-task, so we need to iterate through all tasks
    final tasks = StorageService.getAllTasks();
    
    for (final task in tasks) {
      final subtasks = StorageService.getSubtasksForTask(task.id);
      for (final subtask in subtasks) {
        await _db.into(_db.subtasks).insertOnConflictUpdate(
          SubtasksCompanion(
            id: Value(subtask.id),
            title: Value(subtask.title),
            isCompleted: Value(subtask.isCompleted),
            parentTaskId: Value(subtask.parentTaskId),
            sortOrder: Value(subtask.sortOrder),
            createdAt: Value(subtask.createdAt),
          ),
        );
      }
    }
    
    onProgress?.call(overallProgress);
  }
  
  Future<void> _migrateHabits(
    void Function(double)? onProgress,
    void Function(String)? onEntityStart,
  ) async {
    onEntityStart?.call('Habits');
    _migrationState['habits'] = _migrationState['habits']!.copyWith(
      status: MigrationStatus.inProgress,
    );
    
    final habits = StorageService.getAllHabits();
    int migrated = 0;
    
    for (final habit in habits) {
      // Insert habit
      await _db.into(_db.habits).insertOnConflictUpdate(
        HabitsCompanion(
          id: Value(habit.id),
          name: Value(habit.name),
          type: Value(habit.type.index),
          triggerResponse: Value(habit.triggerResponse),
          currentStreak: Value(habit.currentStreak),
          bestStreak: Value(habit.bestStreak),
          completionCount: Value(habit.completionCount),
          createdAt: Value(habit.createdAt),
          isActive: Value(habit.isActive),
          factorId: Value(habit.factorId),
          scheduledDaysJson: Value(jsonEncode(habit.scheduledDays)),
          targetFrequency: Value(habit.targetFrequency),
          motivation: Value(habit.motivation),
          timerMinutes: Value(habit.timerMinutes),
          streakFreezes: Value(habit.streakFreezes),
          freezesUsed: Value(habit.freezesUsed),
          categoryId: Value(habit.categoryId),
          evaluationType: Value(habit.evaluationType?.index),
          frequencyType: Value(habit.frequencyType?.index),
          targetValue: Value(habit.targetValue),
          unit: Value(habit.unit),
          checklistItemsJson: Value(habit.checklistItems != null 
              ? jsonEncode(habit.checklistItems) : null),
          priorityLevel: Value(habit.priorityLevel?.index),
          startDate: Value(habit.startDate),
          endDate: Value(habit.endDate),
          reminderTimesJson: Value(habit.reminderTimes != null 
              ? jsonEncode(habit.reminderTimes) : null),
          isArchived: Value(habit.isArchived),
          daysPerPeriod: Value(habit.daysPerPeriod),
          repeatInterval: Value(habit.repeatInterval),
          specificDatesJson: Value(habit.specificDates != null 
              ? jsonEncode(habit.specificDates!.map((d) => d.toIso8601String()).toList()) 
              : null),
          description: Value(habit.description),
          extraGoal: Value(habit.extraGoal),
          sortOrder: Value(habit.sortOrder),
          scoringEnabled: Value(habit.scoringEnabled),
          priority: Value(habit.priority),
        ),
      );
      
      // CRITICAL: Migrate habit logs to separate table for O(1) lookups
      // This is the KEY performance optimization
      final logCompanions = habit.logs.map((log) => HabitLogsCompanion(
        habitId: Value(habit.id),
        date: Value(log.date),
        completed: Value(log.completed),
        note: Value(log.note),
        moodRating: Value(log.moodRating),
        barrierTag: Value(log.barrierTag),
        numericValue: Value(log.numericValue),
        checklistCompletedJson: Value(log.checklistCompleted != null 
            ? jsonEncode(log.checklistCompleted) : null),
        timerSeconds: Value(log.timerSeconds),
        score: Value(log.score),
      )).toList();
      
      if (logCompanions.isNotEmpty) {
        await _db.batchInsertHabitLogs(logCompanions);
      }
      
      migrated++;
      _migrationState['habits'] = _migrationState['habits']!.copyWith(
        migratedCount: migrated,
      );
      onProgress?.call(overallProgress);
    }
    
    _migrationState['habits'] = _migrationState['habits']!.copyWith(
      status: MigrationStatus.completed,
    );
  }
  
  Future<void> _migrateReflections(
    void Function(double)? onProgress,
    void Function(String)? onEntityStart,
  ) async {
    onEntityStart?.call('Reflections');
    _migrationState['reflections'] = _migrationState['reflections']!.copyWith(
      status: MigrationStatus.inProgress,
    );
    
    final reflections = StorageService.getAllReflections();
    int migrated = 0;
    
    for (final reflection in reflections) {
      await _db.into(_db.reflections).insertOnConflictUpdate(
        ReflectionsCompanion(
          id: Value(reflection.id),
          experience: Value(reflection.experience),
          reflection: Value(reflection.reflection),
          abstraction: Value(reflection.abstraction),
          isFollowUp: Value(reflection.isFollowUp),
          previousReflectionId: Value(reflection.previousReflectionId),
          createdAt: Value(reflection.createdAt),
          rawMarkdown: Value(reflection.rawMarkdown),
          targetFactorId: Value(reflection.targetFactorId),
          previousExperimentId: Value(reflection.previousExperimentId),
          groupId: Value(reflection.groupId),
          marginalGainDescription: Value(reflection.marginalGainDescription),
          eventSequence: Value(reflection.eventSequence),
          feelings: Value(reflection.feelings),
          difficulties: Value(reflection.difficulties),
          challengeResponse: Value(reflection.challengeResponse),
          triggers: Value(reflection.triggers),
          whyBehavior: Value(reflection.whyBehavior),
          crossLifePatterns: Value(reflection.crossLifePatterns),
          isManualEntry: Value(reflection.isManualEntry),
        ),
      );
      
      // Migrate reflection-factor links
      for (final factorId in reflection.linkedFactorIds) {
        await _db.into(_db.reflectionFactorLinks).insertOnConflictUpdate(
          ReflectionFactorLinksCompanion(
            reflectionId: Value(reflection.id),
            factorId: Value(factorId),
          ),
        );
      }
      
      // Migrate reflection-experiment links
      for (final experimentId in reflection.experimentIds) {
        await _db.into(_db.reflectionExperimentLinks).insertOnConflictUpdate(
          ReflectionExperimentLinksCompanion(
            reflectionId: Value(reflection.id),
            experimentId: Value(experimentId),
          ),
        );
      }
      
      migrated++;
      _migrationState['reflections'] = _migrationState['reflections']!.copyWith(
        migratedCount: migrated,
      );
      onProgress?.call(overallProgress);
    }
    
    _migrationState['reflections'] = _migrationState['reflections']!.copyWith(
      status: MigrationStatus.completed,
    );
  }
  
  Future<void> _migrateExperiments(
    void Function(double)? onProgress,
    void Function(String)? onEntityStart,
  ) async {
    onEntityStart?.call('Experiments');
    
    final experiments = StorageService.getAllExperiments();
    
    for (final experiment in experiments) {
      await _db.into(_db.experiments).insertOnConflictUpdate(
        ExperimentsCompanion(
          id: Value(experiment.id),
          description: Value(experiment.description),
          status: Value(experiment.status.index),
          reflectionId: Value(experiment.reflectionId),
          createdAt: Value(experiment.createdAt),
          groupId: Value(experiment.groupId),
          cycleCount: Value(experiment.cycleCount),
          startedAt: Value(experiment.startedAt),
          completedAt: Value(experiment.completedAt),
          notes: Value(experiment.notes),
        ),
      );
    }
    
    onProgress?.call(overallProgress);
  }
  
  Future<void> _migrateFocusLogs(
    void Function(double)? onProgress,
    void Function(String)? onEntityStart,
  ) async {
    onEntityStart?.call('Focus Logs');
    
    final focusLogs = StorageService.getAllFocusLogs();
    
    for (final log in focusLogs) {
      await _db.into(_db.focusLogs).insertOnConflictUpdate(
        FocusLogsCompanion(
          id: Value(log.id),
          taskId: Value(log.taskId),
          taskTitle: Value(log.taskTitle),
          startTime: Value(log.startTime),
          durationSeconds: Value(log.duration.inSeconds),
          completedPomodoros: Value(log.completedPomodoros),
          distractionsJson: Value(jsonEncode(log.distractions)),
        ),
      );
    }
    
    onProgress?.call(overallProgress);
  }
  
  Future<void> _migrateReflectionGroups(
    void Function(double)? onProgress,
    void Function(String)? onEntityStart,
  ) async {
    onEntityStart?.call('Reflection Groups');
    
    final groups = StorageService.getAllReflectionGroups();
    
    for (final group in groups) {
      await _db.into(_db.reflectionGroups).insertOnConflictUpdate(
        ReflectionGroupsCompanion(
          id: Value(group.id),
          title: Value(group.title),
          createdAt: Value(group.createdAt),
          archivedAt: Value(group.archivedAt),
          targetFactorId: Value(group.targetFactorId),
        ),
      );
    }
    
    onProgress?.call(overallProgress);
  }
  
  Future<void> _migrateRecurringTasks(
    void Function(double)? onProgress,
    void Function(String)? onEntityStart,
  ) async {
    onEntityStart?.call('Recurring Tasks');
    
    final recurringTasks = StorageService.getAllRecurringTasks();
    
    for (final task in recurringTasks) {
      await _db.into(_db.recurringTasks).insertOnConflictUpdate(
        RecurringTasksCompanion(
          id: Value(task.id),
          name: Value(task.name),
          categoryId: Value(task.categoryId),
          evaluationType: Value(task.evaluationType.index),
          checklistItemsJson: Value(task.checklistItems != null 
              ? jsonEncode(task.checklistItems) : null),
          frequencyType: Value(task.frequencyType.index),
          scheduledDaysJson: Value(jsonEncode(task.scheduledDays)),
          daysPerPeriod: Value(task.daysPerPeriod),
          repeatInterval: Value(task.repeatInterval),
          specificDatesJson: Value(task.specificDates != null 
              ? jsonEncode(task.specificDates!.map((d) => d.toIso8601String()).toList()) 
              : null),
          startDate: Value(task.startDate),
          endDate: Value(task.endDate),
          reminderTimesJson: Value(jsonEncode(task.reminderTimes)),
          priorityLevel: Value(task.priorityLevel.index),
          description: Value(task.description),
          createdAt: Value(task.createdAt),
          isArchived: Value(task.isArchived),
          sortOrder: Value(task.sortOrder),
          priority: Value(task.priority),
        ),
      );
      
      // Migrate recurring task-factor links
      for (final factorId in task.linkedFactorIds) {
        await _db.into(_db.recurringTaskFactorLinks).insertOnConflictUpdate(
          RecurringTaskFactorLinksCompanion(
            recurringTaskId: Value(task.id),
            factorId: Value(factorId),
          ),
        );
      }
      
      // Migrate recurring task logs
      for (final log in task.logs) {
        await _db.into(_db.recurringTaskLogs).insertOnConflictUpdate(
          RecurringTaskLogsCompanion(
            recurringTaskId: Value(task.id),
            date: Value(log.date),
            completed: Value(log.completed),
            note: Value(log.note),
            checklistCompletedJson: Value(log.checklistCompleted != null 
                ? jsonEncode(log.checklistCompleted) : null),
            numericValue: Value(log.numericValue),
          ),
        );
      }
    }
    
    onProgress?.call(overallProgress);
  }
  
  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================
  
  /// Clear all Drift data (for fresh migration)
  Future<void> clearDriftData() async {
    await _db.delete(_db.recurringTaskLogs).go();
    await _db.delete(_db.recurringTaskFactorLinks).go();
    await _db.delete(_db.recurringTasks).go();
    await _db.delete(_db.reflectionGroups).go();
    await _db.delete(_db.focusLogs).go();
    await _db.delete(_db.experiments).go();
    await _db.delete(_db.reflectionExperimentLinks).go();
    await _db.delete(_db.reflectionFactorLinks).go();
    await _db.delete(_db.reflections).go();
    await _db.delete(_db.habitLogs).go();
    await _db.delete(_db.habits).go();
    await _db.delete(_db.subtasks).go();
    await _db.delete(_db.taskFactorLinks).go();
    await _db.delete(_db.tasks).go();
    await _db.delete(_db.categories).go();
    await _db.delete(_db.factorHabitLinks).go();
    await _db.delete(_db.goalFactorLinks).go();
    await _db.delete(_db.factors).go();
    await _db.delete(_db.goals).go();
  }
  
  /// Reset migration state
  Future<void> resetMigrationState() async {
    final prefs = await Hive.openBox('migration_state');
    await prefs.delete('migration_completed');
    await prefs.delete('migration_date');
    _migrationState.clear();
  }
  
  /// Check if reads should use Drift for an entity
  static bool shouldUseDrift(String entityType) {
    return _useDriftForReads[entityType] ?? false;
  }
}
