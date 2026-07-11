// Paginated data provider with prefetching and LRU caches.

import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

import 'app_database.dart';
import 'migration_service.dart';
import '../storage_service.dart';
import '../../models/task.dart';
import '../../models/habit.dart';
import '../../models/reflection.dart';

/// Generic paginated result with cursor for next page
class PaginatedResult<T> {
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;
  final int totalCount;
  
  PaginatedResult({
    required this.items,
    this.nextCursor,
    required this.hasMore,
    this.totalCount = 0,
  });
}

/// LRU cache with configurable max size
class LRUCache<K, V extends Object> {
  final int maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap();
  
  LRUCache({this.maxSize = 1000});
  
  V? get(K key) {
    if (!_cache.containsKey(key)) return null;
    // Move to end (most recently used)
    final value = _cache.remove(key)!;
    _cache[key] = value;
    return value;
  }
  
  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= maxSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }
  
  void remove(K key) => _cache.remove(key);
  
  void clear() => _cache.clear();
  
  int get size => _cache.length;
}

/// Main paginated data provider
class PaginatedDataProvider extends ChangeNotifier {
  final AppDatabase _db;
  
  // LRU caches for hot data
  final LRUCache<String, Task> _taskCache = LRUCache(maxSize: 500);
  final LRUCache<String, Habit> _habitCache = LRUCache(maxSize: 200);
  final LRUCache<String, Reflection> _reflectionCache = LRUCache(maxSize: 100);
  
  // Date-indexed cache for today view
  final Map<String, List<String>> _tasksByDate = {};
  
  // Prefetch state
  final Set<String> _prefetchingDates = {};
  
  // Statistics cache (refreshed periodically)
  Map<String, int>? _cachedCounts;
  DateTime? _countsLastFetched;
  
  static const int _defaultPageSize = 50;
  static const Duration _countsCacheDuration = Duration(minutes: 5);
  
  PaginatedDataProvider(this._db);
  
  // ==========================================================================
  // TASK METHODS - Optimized for Today view
  // ==========================================================================
  
  /// Get tasks for a specific date with smart caching
  Future<List<Task>> getTasksForDate(
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    final dateKey = _dateKey(date);
    
    // Check cache first
    if (!forceRefresh && _tasksByDate.containsKey(dateKey)) {
      return _getTasksFromCache(_tasksByDate[dateKey]!);
    }
    
    // Determine data source
    if (DatabaseMigrationService.shouldUseDrift('tasks')) {
      return _getTasksForDateFromDrift(date);
    } else {
      return _getTasksForDateFromHive(date);
    }
  }
  
  Future<List<Task>> _getTasksForDateFromDrift(DateTime date) async {
    final entries = await _db.getTasksForDate(date);
    final tasks = entries.map(_taskEntryToTask).toList();
    
    // Update cache
    final dateKey = _dateKey(date);
    _tasksByDate[dateKey] = tasks.map((t) => t.id).toList();
    for (final task in tasks) {
      _taskCache.put(task.id, task);
    }
    
    return tasks;
  }
  
  Future<List<Task>> _getTasksForDateFromHive(DateTime date) async {
    // Use existing Hive storage but cache results
    final allTasks = StorageService.getAllTasks();
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final tasks = allTasks.where((t) {
      return t.scheduledDate.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
             t.scheduledDate.isBefore(endOfDay);
    }).toList();
    
    // Sort by priority, then sort order
    tasks.sort((a, b) {
      if (a.isPriority != b.isPriority) {
        return a.isPriority ? -1 : 1;
      }
      return a.sortOrder.compareTo(b.sortOrder);
    });
    
    // Update cache
    final dateKey = _dateKey(date);
    _tasksByDate[dateKey] = tasks.map((t) => t.id).toList();
    for (final task in tasks) {
      _taskCache.put(task.id, task);
    }
    
    return tasks;
  }
  
  /// Prefetch tasks for surrounding dates (smooth calendar scrolling)
  Future<void> prefetchTasksForDateRange(DateTime centerDate, {int days = 3}) async {
    for (int i = -days; i <= days; i++) {
      final date = centerDate.add(Duration(days: i));
      final dateKey = _dateKey(date);
      
      if (_tasksByDate.containsKey(dateKey) || _prefetchingDates.contains(dateKey)) {
        continue;
      }
      
      _prefetchingDates.add(dateKey);
      
      // Don't await - run in background
      getTasksForDate(date).then((_) {
        _prefetchingDates.remove(dateKey);
      });
    }
  }
  
  /// Get paginated incomplete tasks (backlog)
  Future<PaginatedResult<Task>> getBacklogTasks({
    int limit = _defaultPageSize,
    String? afterId,
  }) async {
    if (DatabaseMigrationService.shouldUseDrift('tasks')) {
      // TODO: Implement cursor-based pagination in Drift
      final entries = await _db.getTasksForDate(
        DateTime.now(),
        limit: limit,
        isCompleted: false,
      );
      return PaginatedResult(
        items: entries.map(_taskEntryToTask).toList(),
        hasMore: entries.length == limit,
      );
    } else {
      // Hive fallback with manual pagination
      final allTasks = StorageService.getAllTasks()
          .where((t) => !t.isCompleted && !t.isPriority)
          .toList();
      
      allTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      int startIndex = 0;
      if (afterId != null) {
        startIndex = allTasks.indexWhere((t) => t.id == afterId) + 1;
      }
      
      final pageItems = allTasks.skip(startIndex).take(limit).toList();
      
      return PaginatedResult(
        items: pageItems,
        hasMore: startIndex + pageItems.length < allTasks.length,
        totalCount: allTasks.length,
        nextCursor: pageItems.isNotEmpty ? pageItems.last.id : null,
      );
    }
  }
  
  // ==========================================================================
  // HABIT METHODS - Optimized for O(1) completion lookups
  // ==========================================================================
  
  /// Get active habits with pagination
  Future<PaginatedResult<Habit>> getActiveHabits({
    int limit = _defaultPageSize,
    int offset = 0,
  }) async {
    if (DatabaseMigrationService.shouldUseDrift('habits')) {
      final entries = await _db.getActiveHabits(limit: limit, offset: offset);
      final habits = await Future.wait(
        entries.map((e) => _habitEntryToHabit(e)),
      );
      return PaginatedResult(
        items: habits,
        hasMore: entries.length == limit,
      );
    } else {
      // Hive fallback
      final allHabits = StorageService.getAllHabits()
          .where((h) => h.isActive && !h.isArchived)
          .toList();
      
      allHabits.sort((a, b) {
        if (a.priority != b.priority) {
          return b.priority.compareTo(a.priority);
        }
        return a.sortOrder.compareTo(b.sortOrder);
      });
      
      final pageItems = allHabits.skip(offset).take(limit).toList();
      
      // Cache results
      for (final habit in pageItems) {
        _habitCache.put(habit.id, habit);
      }
      
      return PaginatedResult(
        items: pageItems,
        hasMore: offset + pageItems.length < allHabits.length,
        totalCount: allHabits.length,
      );
    }
  }
  
  /// Check if habit is completed for date - O(1) with Drift index
  Future<bool> isHabitCompletedForDate(String habitId, DateTime date) async {
    if (DatabaseMigrationService.shouldUseDrift('habitLogs')) {
      final log = await _db.getHabitLogForDate(habitId, date);
      return log?.completed ?? false;
    } else {
      // Hive fallback - still O(n) on logs
      final habit = _habitCache.get(habitId) ?? 
          StorageService.getAllHabits().firstWhere(
            (h) => h.id == habitId,
            orElse: () => throw StateError('Habit not found'),
          );
      return habit.isCompletedFor(date);
    }
  }
  
  /// Get habit completion rate for date range - single indexed query
  Future<double> getHabitCompletionRate(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (DatabaseMigrationService.shouldUseDrift('habitLogs')) {
      final logs = await _db.getHabitLogsForDateRange(habitId, startDate, endDate);
      if (logs.isEmpty) return 0;
      
      final completed = logs.where((l) => l.completed).length;
      return completed / logs.length;
    } else {
      // Hive fallback
      final habit = _habitCache.get(habitId) ??
          StorageService.getAllHabits().firstWhere(
            (h) => h.id == habitId,
            orElse: () => throw StateError('Habit not found'),
          );
      
      int scheduled = 0;
      int completed = 0;
      
      for (var d = startDate; d.isBefore(endDate); d = d.add(const Duration(days: 1))) {
        if (habit.isScheduledFor(d)) {
          scheduled++;
          if (habit.isCompletedFor(d)) {
            completed++;
          }
        }
      }
      
      return scheduled > 0 ? completed / scheduled : 0;
    }
  }
  
  // ==========================================================================
  // REFLECTION METHODS
  // ==========================================================================
  
  /// Get reflections with pagination
  Future<PaginatedResult<Reflection>> getReflections({
    int limit = 20,
    int offset = 0,
    String? factorId,
  }) async {
    if (DatabaseMigrationService.shouldUseDrift('reflections')) {
      final entries = await _db.getReflections(
        limit: limit,
        offset: offset,
        factorId: factorId,
      );
      final reflections = entries.map(_reflectionEntryToReflection).toList();
      return PaginatedResult(
        items: reflections,
        hasMore: entries.length == limit,
      );
    } else {
      // Hive fallback
      var allReflections = StorageService.getAllReflections();
      
      if (factorId != null) {
        allReflections = allReflections
            .where((r) => r.targetFactorId == factorId)
            .toList();
      }
      
      allReflections.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      final pageItems = allReflections.skip(offset).take(limit).toList();
      
      // Cache results
      for (final reflection in pageItems) {
        _reflectionCache.put(reflection.id, reflection);
      }
      
      return PaginatedResult(
        items: pageItems,
        hasMore: offset + pageItems.length < allReflections.length,
        totalCount: allReflections.length,
      );
    }
  }
  
  // ==========================================================================
  // STATISTICS - Cached aggregates
  // ==========================================================================
  
  /// Get total counts (cached for 5 minutes)
  Future<Map<String, int>> getTotalCounts({bool forceRefresh = false}) async {
    final now = DateTime.now();
    
    if (!forceRefresh &&
        _cachedCounts != null &&
        _countsLastFetched != null &&
        now.difference(_countsLastFetched!) < _countsCacheDuration) {
      return _cachedCounts!;
    }
    
    if (DatabaseMigrationService.shouldUseDrift('tasks')) {
      _cachedCounts = await _db.getTotalCounts();
    } else {
      _cachedCounts = {
        'tasks': StorageService.getAllTasks().length,
        'habits': StorageService.getAllHabits().where((h) => h.isActive).length,
        'reflections': StorageService.getAllReflections().length,
      };
    }
    
    _countsLastFetched = now;
    return _cachedCounts!;
  }
  
  /// Get statistics for a date range
  Future<Map<String, dynamic>> getStatisticsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (DatabaseMigrationService.shouldUseDrift('tasks')) {
      return _db.getStatisticsForDateRange(startDate, endDate);
    } else {
      // Hive fallback with manual calculation
      final tasks = StorageService.getAllTasks();
      final completedTasks = tasks.where((t) =>
        t.completedAt != null &&
        t.completedAt!.isAfter(startDate) &&
        t.completedAt!.isBefore(endDate)
      ).length;
      
      // This is expensive - one of the reasons to migrate to Drift
      int habitCompletions = 0;
      for (final habit in StorageService.getAllHabits()) {
        for (final log in habit.logs) {
          if (log.completed &&
              log.date.isAfter(startDate) &&
              log.date.isBefore(endDate)) {
            habitCompletions++;
          }
        }
      }
      
      return {
        'completedTasks': completedTasks,
        'habitCompletions': habitCompletions,
      };
    }
  }
  
  // ==========================================================================
  // CACHE MANAGEMENT
  // ==========================================================================
  
  /// Invalidate cache for a specific date
  void invalidateDateCache(DateTime date) {
    final dateKey = _dateKey(date);
    _tasksByDate.remove(dateKey);
  }
  
  /// Invalidate cache for a specific task
  void invalidateTaskCache(String taskId) {
    _taskCache.remove(taskId);
    // Also remove from date caches
    _tasksByDate.forEach((date, taskIds) {
      taskIds.remove(taskId);
    });
  }
  
  /// Invalidate all caches
  void invalidateAllCaches() {
    _taskCache.clear();
    _habitCache.clear();
    _reflectionCache.clear();
    _tasksByDate.clear();
    _cachedCounts = null;
    notifyListeners();
  }
  
  // ==========================================================================
  // DATA ARCHIVAL - Keep database size manageable
  // ==========================================================================
  
  /// Archive old completed tasks (6 month retention)
  Future<int> archiveOldTasks({int retentionDays = 180}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: retentionDays));
    
    if (DatabaseMigrationService.shouldUseDrift('tasks')) {
      return _db.archiveOldTasks(cutoffDate);
    } else {
      // Hive doesn't have efficient bulk delete
      // Would need to implement in StorageService
      return 0;
    }
  }
  
  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================
  
  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';
  
  List<Task> _getTasksFromCache(List<String> taskIds) {
    return taskIds
        .map((id) => _taskCache.get(id))
        .whereType<Task>()
        .toList();
  }
  
  /// Convert Drift TaskEntry to Task model
  Task _taskEntryToTask(TaskEntry entry) {
    // This would need full implementation based on your Task model
    // For now, creating a basic conversion
    return Task(
      id: entry.id,
      title: entry.title,
      description: entry.description,
      isPriority: entry.isPriority,
      isCompleted: entry.isCompleted,
      source: TaskSource.values[entry.source],
      createdAt: entry.createdAt,
      sortOrder: entry.sortOrder,
      effort: TaskEffort.values[entry.effort],
      impact: TaskImpact.values[entry.impact],
      scheduledDate: entry.scheduledDate,
    );
  }
  
  /// Convert Drift HabitEntry to Habit model (async due to log fetching)
  Future<Habit> _habitEntryToHabit(HabitEntry entry) async {
    // Fetch logs separately - they're in a different table now
    final logs = await _db.getHabitLogsForDateRange(
      entry.id,
      entry.createdAt,
      DateTime.now(),
    );
    
    // Convert logs
    final habitLogs = logs.map((l) => HabitLog(
      date: l.date,
      completed: l.completed,
      note: l.note,
      moodRating: l.moodRating,
      barrierTag: l.barrierTag,
      numericValue: l.numericValue,
      timerSeconds: l.timerSeconds,
      score: l.score,
    )).toList();
    
    return Habit(
      id: entry.id,
      name: entry.name,
      type: HabitType.values[entry.type],
      triggerResponse: entry.triggerResponse,
      currentStreak: entry.currentStreak,
      bestStreak: entry.bestStreak,
      completionCount: entry.completionCount,
      logs: habitLogs,
      createdAt: entry.createdAt,
      isActive: entry.isActive,
      factorId: entry.factorId,
      targetFrequency: entry.targetFrequency,
      motivation: entry.motivation,
      timerMinutes: entry.timerMinutes,
      streakFreezes: entry.streakFreezes,
      freezesUsed: entry.freezesUsed,
      isArchived: entry.isArchived,
      sortOrder: entry.sortOrder,
      scoringEnabled: entry.scoringEnabled,
      priority: entry.priority,
    );
  }
  
  /// Convert Drift ReflectionEntry to Reflection model
  Reflection _reflectionEntryToReflection(ReflectionEntry entry) {
    return Reflection(
      id: entry.id,
      experience: entry.experience,
      reflection: entry.reflection,
      abstraction: entry.abstraction,
      isFollowUp: entry.isFollowUp,
      previousReflectionId: entry.previousReflectionId,
      createdAt: entry.createdAt,
      rawMarkdown: entry.rawMarkdown,
      targetFactorId: entry.targetFactorId,
      previousExperimentId: entry.previousExperimentId,
      groupId: entry.groupId,
      marginalGainDescription: entry.marginalGainDescription,
      eventSequence: entry.eventSequence,
      feelings: entry.feelings,
      difficulties: entry.difficulties,
      challengeResponse: entry.challengeResponse,
      triggers: entry.triggers,
      whyBehavior: entry.whyBehavior,
      crossLifePatterns: entry.crossLifePatterns,
      isManualEntry: entry.isManualEntry,
    );
  }
}
