/// High-performance SQLite database using Drift
/// Designed for scalability to 100M+ records with proper indexing
/// 
/// Migration strategy: Runs in parallel with Hive during transition period
/// All queries are paginated and use indexes for O(log N) lookups

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ============================================================================
// TABLE DEFINITIONS - Optimized for indexed queries
// ============================================================================

/// Goals table - Core anchor for the Goal Achievement Framework
@DataClassName('GoalEntry')
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get targetDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Factors table - Goal dissection elements (Knowledge, Skills, etc.)
@DataClassName('FactorEntry')
class Factors extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get type => integer()(); // FactorType enum index
  IntColumn get targetLevel => integer().withDefault(const Constant(7))();
  IntColumn get currentLevel => integer().withDefault(const Constant(3))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get goalId => text().references(Goals, #id)();
  DateTimeColumn get lastUpdated => dateTime()();
  TextColumn get targetDescription => text().withDefault(const Constant(''))();
  TextColumn get currentDescription => text().withDefault(const Constant(''))();
  BoolColumn get isActiveFocus => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastWorkedOn => dateTime().nullable()();
  RealColumn get healthPercent => real().withDefault(const Constant(100.0))();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Tasks table - Single-instance activities with full indexing
@DataClassName('TaskEntry')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  BoolColumn get isPriority => boolean().withDefault(const Constant(false))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get source => integer()(); // TaskSource enum index
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get experimentId => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get effort => integer()(); // TaskEffort enum index
  IntColumn get impact => integer()(); // TaskImpact enum index
  DateTimeColumn get addedToPriorityAt => dateTime().nullable()();
  IntColumn get abandonReason => integer().nullable()(); // TaskAbandonReason enum index
  TextColumn get blockedByTaskId => text().nullable()();
  TextColumn get category => text().withDefault(const Constant(''))();
  DateTimeColumn get deadline => dateTime().nullable()();
  TextColumn get customTag => text().nullable()();
  TextColumn get marginalGainDescription => text().nullable()();
  BoolColumn get isResearchTask => boolean().withDefault(const Constant(false))();
  TextColumn get categoryId => text().nullable()();
  TextColumn get checklistItemsJson => text().nullable()(); // JSON encoded list
  TextColumn get checklistCompletedJson => text().nullable()(); // JSON encoded list
  IntColumn get priorityLevel => integer().withDefault(const Constant(0))(); // PriorityLevel enum
  TextColumn get note => text().nullable()();
  BoolColumn get isPending => boolean().withDefault(const Constant(false))();
  TextColumn get reminderTimesJson => text().withDefault(const Constant('[]'))(); // JSON encoded
  DateTimeColumn get scheduledDate => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Task-Factor link table for many-to-many relationship
@DataClassName('TaskFactorLink')
class TaskFactorLinks extends Table {
  TextColumn get taskId => text().references(Tasks, #id)();
  TextColumn get factorId => text().references(Factors, #id)();
  
  @override
  Set<Column> get primaryKey => {taskId, factorId};
}

/// Subtasks table
@DataClassName('SubtaskEntry')
class Subtasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get parentTaskId => text().references(Tasks, #id)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Habits table
@DataClassName('HabitEntry')
class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get type => integer()(); // HabitType enum
  TextColumn get triggerResponse => text().nullable()();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get bestStreak => integer().withDefault(const Constant(0))();
  IntColumn get completionCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get factorId => text().nullable()();
  TextColumn get scheduledDaysJson => text().withDefault(const Constant('[]'))();
  IntColumn get targetFrequency => integer().withDefault(const Constant(1))();
  TextColumn get motivation => text().withDefault(const Constant(''))();
  IntColumn get timerMinutes => integer().nullable()();
  IntColumn get streakFreezes => integer().withDefault(const Constant(0))();
  IntColumn get freezesUsed => integer().withDefault(const Constant(0))();
  TextColumn get categoryId => text().nullable()();
  IntColumn get evaluationType => integer().nullable()(); // HabitEvaluationType
  IntColumn get frequencyType => integer().nullable()(); // HabitFrequencyType
  IntColumn get targetValue => integer().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get checklistItemsJson => text().nullable()();
  IntColumn get priorityLevel => integer().nullable()(); // PriorityLevel
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get reminderTimesJson => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get daysPerPeriod => integer().nullable()();
  IntColumn get repeatInterval => integer().nullable()();
  TextColumn get specificDatesJson => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get extraGoal => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get scoringEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Habit completion logs - SEPARATE TABLE for O(1) date lookups
/// This is the KEY optimization for habit queries at scale
@DataClassName('HabitLogEntry')
class HabitLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get habitId => text().references(Habits, #id)();
  DateTimeColumn get date => dateTime()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();
  IntColumn get moodRating => integer().nullable()();
  TextColumn get barrierTag => text().nullable()();
  IntColumn get numericValue => integer().nullable()();
  TextColumn get checklistCompletedJson => text().nullable()();
  IntColumn get timerSeconds => integer().nullable()();
  IntColumn get score => integer().nullable()();
}

/// Reflections table
@DataClassName('ReflectionEntry')
class Reflections extends Table {
  TextColumn get id => text()();
  TextColumn get experience => text().withDefault(const Constant(''))();
  TextColumn get reflection => text().withDefault(const Constant(''))();
  TextColumn get abstraction => text().withDefault(const Constant(''))();
  BoolColumn get isFollowUp => boolean().withDefault(const Constant(false))();
  TextColumn get previousReflectionId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get rawMarkdown => text().nullable()();
  TextColumn get targetFactorId => text().nullable()();
  TextColumn get previousExperimentId => text().nullable()();
  TextColumn get groupId => text().nullable()();
  TextColumn get marginalGainDescription => text().nullable()();
  TextColumn get eventSequence => text().nullable()();
  TextColumn get feelings => text().nullable()();
  TextColumn get difficulties => text().nullable()();
  TextColumn get challengeResponse => text().nullable()();
  TextColumn get triggers => text().nullable()();
  TextColumn get whyBehavior => text().nullable()();
  TextColumn get crossLifePatterns => text().nullable()();
  BoolColumn get isManualEntry => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Reflection-Factor links
@DataClassName('ReflectionFactorLink')
class ReflectionFactorLinks extends Table {
  TextColumn get reflectionId => text().references(Reflections, #id)();
  TextColumn get factorId => text().references(Factors, #id)();
  
  @override
  Set<Column> get primaryKey => {reflectionId, factorId};
}

/// Reflection-Experiment links
@DataClassName('ReflectionExperimentLink')
class ReflectionExperimentLinks extends Table {
  TextColumn get reflectionId => text().references(Reflections, #id)();
  TextColumn get experimentId => text()();
  
  @override
  Set<Column> get primaryKey => {reflectionId, experimentId};
}

/// Experiments table
@DataClassName('ExperimentEntry')
class Experiments extends Table {
  TextColumn get id => text()();
  TextColumn get description => text()();
  IntColumn get status => integer()(); // ExperimentStatus enum
  TextColumn get reflectionId => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get groupId => text().nullable()();
  IntColumn get cycleCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Focus logs table
@DataClassName('FocusLogEntry')
class FocusLogs extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text()();
  TextColumn get taskTitle => text()();
  DateTimeColumn get startTime => dateTime()();
  IntColumn get durationSeconds => integer()();
  IntColumn get completedPomodoros => integer().withDefault(const Constant(0))();
  TextColumn get distractionsJson => text().withDefault(const Constant('[]'))();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Reflection groups table
@DataClassName('ReflectionGroupEntry')
class ReflectionGroups extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  TextColumn get targetFactorId => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Categories table
@DataClassName('CategoryEntry')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get iconCodePoint => integer()();
  TextColumn get iconFontFamily => text().withDefault(const Constant('MaterialIcons'))();
  IntColumn get colorValue => integer()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Recurring tasks table
@DataClassName('RecurringTaskEntry')
class RecurringTasks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get categoryId => text()();
  IntColumn get evaluationType => integer()(); // HabitEvaluationType
  TextColumn get checklistItemsJson => text().nullable()();
  IntColumn get frequencyType => integer()(); // HabitFrequencyType
  TextColumn get scheduledDaysJson => text().withDefault(const Constant('[]'))();
  IntColumn get daysPerPeriod => integer().nullable()();
  IntColumn get repeatInterval => integer().nullable()();
  TextColumn get specificDatesJson => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get reminderTimesJson => text().withDefault(const Constant('[]'))();
  IntColumn get priorityLevel => integer()(); // PriorityLevel
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Recurring task-factor links
@DataClassName('RecurringTaskFactorLink')
class RecurringTaskFactorLinks extends Table {
  TextColumn get recurringTaskId => text().references(RecurringTasks, #id)();
  TextColumn get factorId => text().references(Factors, #id)();
  
  @override
  Set<Column> get primaryKey => {recurringTaskId, factorId};
}

/// Recurring task logs - SEPARATE TABLE for O(1) lookups
@DataClassName('RecurringTaskLogEntry')
class RecurringTaskLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recurringTaskId => text().references(RecurringTasks, #id)();
  DateTimeColumn get date => dateTime()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();
  TextColumn get checklistCompletedJson => text().nullable()();
  IntColumn get numericValue => integer().nullable()();
}

/// Factor-Habit links (from Factor.linkedHabitIds)
@DataClassName('FactorHabitLink')
class FactorHabitLinks extends Table {
  TextColumn get factorId => text().references(Factors, #id)();
  TextColumn get habitId => text().references(Habits, #id)();
  
  @override
  Set<Column> get primaryKey => {factorId, habitId};
}

/// Goal-Factor links (from Goal.factorIds)
@DataClassName('GoalFactorLink')
class GoalFactorLinks extends Table {
  TextColumn get goalId => text().references(Goals, #id)();
  TextColumn get factorId => text().references(Factors, #id)();
  
  @override
  Set<Column> get primaryKey => {goalId, factorId};
}

// ============================================================================
// DATABASE CLASS WITH INDEXES AND QUERIES
// ============================================================================

@DriftDatabase(
  tables: [
    Goals,
    Factors,
    Tasks,
    TaskFactorLinks,
    Subtasks,
    Habits,
    HabitLogs,
    Reflections,
    ReflectionFactorLinks,
    ReflectionExperimentLinks,
    Experiments,
    FocusLogs,
    ReflectionGroups,
    Categories,
    RecurringTasks,
    RecurringTaskFactorLinks,
    RecurringTaskLogs,
    FactorHabitLinks,
    GoalFactorLinks,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // Create indexes after tables are created
      await _createIndexes();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Handle future migrations here
    },
  );
  
  /// Create performance-critical indexes
  Future<void> _createIndexes() async {
    // Task indexes - Critical for date-based queries
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_tasks_scheduled_date 
      ON tasks(scheduled_date)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_tasks_is_completed 
      ON tasks(is_completed)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_tasks_is_priority 
      ON tasks(is_priority)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_tasks_category_id 
      ON tasks(category_id)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_tasks_scheduled_completed 
      ON tasks(scheduled_date, is_completed)
    ''');
    
    // Habit log indexes - Critical for O(1) date lookups
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_habit_logs_habit_date 
      ON habit_logs(habit_id, date)
    ''');
    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_habit_logs_unique 
      ON habit_logs(habit_id, date)
    ''');
    
    // Habit indexes
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_habits_is_active 
      ON habits(is_active)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_habits_factor_id 
      ON habits(factor_id)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_habits_category_id 
      ON habits(category_id)
    ''');
    
    // Reflection indexes
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_reflections_created_at 
      ON reflections(created_at)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_reflections_group_id 
      ON reflections(group_id)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_reflections_target_factor_id 
      ON reflections(target_factor_id)
    ''');
    
    // Experiment indexes
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_experiments_status 
      ON experiments(status)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_experiments_reflection_id 
      ON experiments(reflection_id)
    ''');
    
    // Factor indexes
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_factors_goal_id 
      ON factors(goal_id)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_factors_is_active_focus 
      ON factors(is_active_focus)
    ''');
    
    // Subtask indexes
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_subtasks_parent_task_id 
      ON subtasks(parent_task_id)
    ''');
    
    // Focus log indexes
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_focus_logs_start_time 
      ON focus_logs(start_time)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_focus_logs_task_id 
      ON focus_logs(task_id)
    ''');
    
    // Recurring task log indexes
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_recurring_task_logs_task_date 
      ON recurring_task_logs(recurring_task_id, date)
    ''');
    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_recurring_task_logs_unique 
      ON recurring_task_logs(recurring_task_id, date)
    ''');
    
    // Category index
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_categories_sort_order 
      ON categories(sort_order)
    ''');
    
    // Recurring task indexes
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_recurring_tasks_category_id 
      ON recurring_tasks(category_id)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_recurring_tasks_is_archived 
      ON recurring_tasks(is_archived)
    ''');
  }
  
  // ==========================================================================
  // PAGINATED QUERY METHODS - All queries return limited results
  // ==========================================================================
  
  /// Get tasks for a specific date with pagination
  Future<List<TaskEntry>> getTasksForDate(
    DateTime date, {
    int limit = 50,
    int offset = 0,
    bool? isCompleted,
  }) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final query = select(tasks)
      ..where((t) => t.scheduledDate.isBetweenValues(startOfDay, endOfDay));
    
    if (isCompleted != null) {
      query.where((t) => t.isCompleted.equals(isCompleted));
    }
    
    query
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])
      ..limit(limit, offset: offset);
    
    return query.get();
  }
  
  /// Get incomplete tasks count for a date (for badge/indicator)
  Future<int> getIncompleteTaskCountForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM tasks '
      'WHERE scheduled_date >= ? AND scheduled_date < ? AND is_completed = 0',
      variables: [Variable.withDateTime(startOfDay), Variable.withDateTime(endOfDay)],
    ).getSingle();
    
    return result.read<int>('count');
  }
  
  /// Get habit log for a specific date - O(1) with index
  Future<HabitLogEntry?> getHabitLogForDate(String habitId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return (select(habitLogs)
      ..where((l) => l.habitId.equals(habitId))
      ..where((l) => l.date.isBetweenValues(startOfDay, endOfDay))
      ..limit(1)
    ).getSingleOrNull();
  }
  
  /// Get habit logs for date range (for streak calculation)
  Future<List<HabitLogEntry>> getHabitLogsForDateRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return (select(habitLogs)
      ..where((l) => l.habitId.equals(habitId))
      ..where((l) => l.date.isBetweenValues(startDate, endDate))
      ..orderBy([(l) => OrderingTerm.desc(l.date)])
    ).get();
  }
  
  /// Get active habits with pagination
  Future<List<HabitEntry>> getActiveHabits({
    int limit = 100,
    int offset = 0,
  }) {
    return (select(habits)
      ..where((h) => h.isActive.equals(true))
      ..where((h) => h.isArchived.equals(false))
      ..orderBy([(h) => OrderingTerm.desc(h.priority), (h) => OrderingTerm.asc(h.sortOrder)])
      ..limit(limit, offset: offset)
    ).get();
  }
  
  /// Get reflections with pagination (newest first)
  Future<List<ReflectionEntry>> getReflections({
    int limit = 20,
    int offset = 0,
    String? factorId,
  }) {
    final query = select(reflections);
    
    if (factorId != null) {
      query.where((r) => r.targetFactorId.equals(factorId));
    }
    
    query
      ..orderBy([(r) => OrderingTerm.desc(r.createdAt)])
      ..limit(limit, offset: offset);
    
    return query.get();
  }
  
  /// Get experiments by status with pagination
  Future<List<ExperimentEntry>> getExperimentsByStatus(
    int status, {
    int limit = 50,
    int offset = 0,
  }) {
    return (select(experiments)
      ..where((e) => e.status.equals(status))
      ..orderBy([(e) => OrderingTerm.desc(e.createdAt)])
      ..limit(limit, offset: offset)
    ).get();
  }
  
  /// Batch insert habit logs (for migration)
  Future<void> batchInsertHabitLogs(List<HabitLogsCompanion> logs) async {
    await batch((batch) {
      batch.insertAll(habitLogs, logs, mode: InsertMode.insertOrReplace);
    });
  }
  
  /// Batch insert tasks (for migration)
  Future<void> batchInsertTasks(List<TasksCompanion> taskList) async {
    await batch((batch) {
      batch.insertAll(tasks, taskList, mode: InsertMode.insertOrReplace);
    });
  }
  
  /// Get total counts for UI (cached at app level)
  Future<Map<String, int>> getTotalCounts() async {
    final taskCount = await customSelect('SELECT COUNT(*) as c FROM tasks').getSingle();
    final habitCount = await customSelect('SELECT COUNT(*) as c FROM habits WHERE is_active = 1').getSingle();
    final reflectionCount = await customSelect('SELECT COUNT(*) as c FROM reflections').getSingle();
    
    return {
      'tasks': taskCount.read<int>('c'),
      'habits': habitCount.read<int>('c'),
      'reflections': reflectionCount.read<int>('c'),
    };
  }
  
  /// Archive old completed tasks (data retention policy)
  Future<int> archiveOldTasks(DateTime cutoffDate) async {
    return (delete(tasks)
      ..where((t) => t.isCompleted.equals(true))
      ..where((t) => t.completedAt.isSmallerThanValue(cutoffDate))
    ).go();
  }
  
  /// Get statistics for a date range (optimized aggregate query)
  Future<Map<String, dynamic>> getStatisticsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final completedTasks = await customSelect(
      'SELECT COUNT(*) as count FROM tasks '
      'WHERE completed_at >= ? AND completed_at < ?',
      variables: [Variable.withDateTime(startDate), Variable.withDateTime(endDate)],
    ).getSingle();
    
    final habitCompletions = await customSelect(
      'SELECT COUNT(*) as count FROM habit_logs '
      'WHERE date >= ? AND date < ? AND completed = 1',
      variables: [Variable.withDateTime(startDate), Variable.withDateTime(endDate)],
    ).getSingle();
    
    return {
      'completedTasks': completedTasks.read<int>('count'),
      'habitCompletions': habitCompletions.read<int>('count'),
    };
  }
}

/// Opens database connection with performance optimizations
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'centile_v2.sqlite'));
    
    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        // Enable WAL mode for better concurrent read/write performance
        db.execute('PRAGMA journal_mode=WAL');
        // Set reasonable cache size (negative = KB, so -8000 = 8MB)
        db.execute('PRAGMA cache_size=-8000');
        // Enable foreign keys
        db.execute('PRAGMA foreign_keys=ON');
        // Optimize for speed over safety (we have WAL)
        db.execute('PRAGMA synchronous=NORMAL');
        // Memory-mapped I/O for faster reads
        db.execute('PRAGMA mmap_size=268435456'); // 256MB
      },
    );
  });
}
