// Indexed habit-completion lookups used when the Drift migration is enabled.

import 'dart:async';

import 'app_database.dart';
import 'migration_service.dart';
import '../../models/habit.dart';

/// Cache for habit log lookups to reduce database queries
class HabitLogCache {
  final AppDatabase _db;
  
  // Cache structure: habitId -> dateKey -> completed
  final Map<String, Map<String, bool>> _completionCache = {};
  
  // Cache structure: habitId -> dateKey -> HabitLog
  final Map<String, Map<String, HabitLog>> _logCache = {};
  
  // Track which habits have been fully loaded
  final Set<String> _fullyLoadedHabits = {};
  
  // Cache expiry tracking
  DateTime? _lastCacheRefresh;
  static const Duration _cacheExpiry = Duration(minutes: 15);
  
  HabitLogCache(this._db);
  
  /// Check if habit is completed for date - O(1) with cache hit
  Future<bool> isCompletedFor(String habitId, DateTime date) async {
    final dateKey = _dateKey(date);
    
    // Check cache first
    if (_completionCache.containsKey(habitId) &&
        _completionCache[habitId]!.containsKey(dateKey)) {
      return _completionCache[habitId]![dateKey]!;
    }
    
    // Query database
    if (DatabaseMigrationService.shouldUseDrift('habitLogs')) {
      final log = await _db.getHabitLogForDate(habitId, date);
      final completed = log?.completed ?? false;
      
      // Cache result
      _completionCache.putIfAbsent(habitId, () => {});
      _completionCache[habitId]![dateKey] = completed;
      
      return completed;
    } else {
      // Fallback: this shouldn't happen in production after migration
      return false;
    }
  }
  
  /// Get habit log for date - O(1) with cache hit
  Future<HabitLog?> getLogFor(String habitId, DateTime date) async {
    final dateKey = _dateKey(date);
    
    // Check cache first
    if (_logCache.containsKey(habitId) &&
        _logCache[habitId]!.containsKey(dateKey)) {
      return _logCache[habitId]![dateKey];
    }
    
    if (!DatabaseMigrationService.shouldUseDrift('habitLogs')) {
      return null;
    }
    
    final entry = await _db.getHabitLogForDate(habitId, date);
    if (entry == null) return null;
    
    final log = HabitLog(
      date: entry.date,
      completed: entry.completed,
      note: entry.note,
      moodRating: entry.moodRating,
      barrierTag: entry.barrierTag,
      numericValue: entry.numericValue,
      timerSeconds: entry.timerSeconds,
      score: entry.score,
    );
    
    // Cache result
    _logCache.putIfAbsent(habitId, () => {});
    _logCache[habitId]![dateKey] = log;
    
    return log;
  }
  
  /// Prefetch logs for a date range - reduces individual queries
  Future<void> prefetchLogsForDateRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (!DatabaseMigrationService.shouldUseDrift('habitLogs')) return;
    
    final logs = await _db.getHabitLogsForDateRange(habitId, startDate, endDate);
    
    // Cache all results
    _completionCache.putIfAbsent(habitId, () => {});
    _logCache.putIfAbsent(habitId, () => {});
    
    for (final entry in logs) {
      final dateKey = _dateKey(entry.date);
      _completionCache[habitId]![dateKey] = entry.completed;
      _logCache[habitId]![dateKey] = HabitLog(
        date: entry.date,
        completed: entry.completed,
        note: entry.note,
        moodRating: entry.moodRating,
        barrierTag: entry.barrierTag,
        numericValue: entry.numericValue,
        timerSeconds: entry.timerSeconds,
        score: entry.score,
      );
    }
  }
  
  /// Prefetch logs for multiple habits (batch operation)
  Future<void> prefetchLogsForHabits(
    List<String> habitIds,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Run prefetch operations in parallel
    await Future.wait(
      habitIds.map((id) => prefetchLogsForDateRange(id, startDate, endDate)),
    );
  }
  
  /// Invalidate cache for a specific habit
  void invalidateHabit(String habitId) {
    _completionCache.remove(habitId);
    _logCache.remove(habitId);
    _fullyLoadedHabits.remove(habitId);
  }
  
  /// Invalidate cache for a specific date across all habits
  void invalidateDate(DateTime date) {
    final dateKey = _dateKey(date);
    
    for (final habitCache in _completionCache.values) {
      habitCache.remove(dateKey);
    }
    for (final habitCache in _logCache.values) {
      habitCache.remove(dateKey);
    }
  }
  
  /// Clear all caches
  void clearAll() {
    _completionCache.clear();
    _logCache.clear();
    _fullyLoadedHabits.clear();
    _lastCacheRefresh = null;
  }
  
  /// Check if cache needs refresh
  bool get needsRefresh {
    if (_lastCacheRefresh == null) return true;
    return DateTime.now().difference(_lastCacheRefresh!) > _cacheExpiry;
  }
  
  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';
}

/// Optimized habit statistics calculator
class OptimizedHabitStats {
  final AppDatabase _db;

  OptimizedHabitStats(this._db);
  
  /// Calculate habit score using indexed queries - O(log N) vs O(N*days)
  Future<double> calculateHabitScore(Habit habit, {int days = 30}) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    
    if (!DatabaseMigrationService.shouldUseDrift('habitLogs')) {
      // Fall back to original calculation
      return habit.habitScore;
    }
    
    // Use single indexed query to get all logs in range
    final logs = await _db.getHabitLogsForDateRange(habit.id, startDate, now);
    
    // Create a set of completed dates for O(1) lookup
    final completedDates = <String>{};
    for (final log in logs) {
      if (log.completed) {
        completedDates.add(_dateKey(log.date));
      }
    }
    
    // Count scheduled vs completed
    int scheduledCount = 0;
    int completedCount = 0;
    
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      if (habit.isScheduledFor(date)) {
        scheduledCount++;
        if (completedDates.contains(_dateKey(date))) {
          completedCount++;
        }
      }
    }
    
    if (scheduledCount == 0) return 100;
    return (completedCount / scheduledCount * 100).clamp(0, 100);
  }
  
  /// Calculate completion rate for multiple habits efficiently
  Future<Map<String, double>> calculateBatchHabitScores(
    List<Habit> habits, {
    int days = 30,
  }) async {
    final results = <String, double>{};
    
    // Run calculations in parallel
    final futures = habits.map((habit) async {
      final score = await calculateHabitScore(habit, days: days);
      return MapEntry(habit.id, score);
    });
    
    final entries = await Future.wait(futures);
    
    for (final entry in entries) {
      results[entry.key] = entry.value;
    }
    
    return results;
  }
  
  /// Get streak calculation using indexed query
  Future<int> calculateCurrentStreak(Habit habit) async {
    if (!DatabaseMigrationService.shouldUseDrift('habitLogs')) {
      return habit.currentStreak;
    }
    
    // Get recent logs in descending date order
    final now = DateTime.now();
    final sixMonthsAgo = now.subtract(const Duration(days: 180));
    final logs = await _db.getHabitLogsForDateRange(habit.id, sixMonthsAgo, now);
    
    if (logs.isEmpty) return 0;
    
    // Sort by date descending
    logs.sort((a, b) => b.date.compareTo(a.date));
    
    int streak = 0;
    for (int i = 0; i < 180; i++) {
      final date = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      
      if (!habit.isScheduledFor(date)) continue;
      
      // Find log for this date
      final log = logs.firstWhere(
        (l) => _sameDay(l.date, date),
        orElse: () => HabitLogEntry(
          id: -1,
          habitId: habit.id,
          date: date,
          completed: false,
        ),
      );
      
      if (log.completed) {
        streak++;
      } else {
        // Check for streak freeze
        if (habit.streakFreezes > habit.freezesUsed) {
          // Allow one miss without breaking streak
          continue;
        }
        break;
      }
    }
    
    return streak;
  }
  
  /// Get weekly statistics for a habit - single query
  Future<Map<String, int>> getWeeklyStats(
    String habitId,
    DateTime weekStart,
  ) async {
    final weekEnd = weekStart.add(const Duration(days: 7));
    
    if (!DatabaseMigrationService.shouldUseDrift('habitLogs')) {
      return {'scheduled': 0, 'completed': 0, 'missed': 0};
    }
    
    final logs = await _db.getHabitLogsForDateRange(habitId, weekStart, weekEnd);
    
    int completed = 0;
    for (final log in logs) {
      if (log.completed) completed++;
    }
    
    return {
      'total': logs.length,
      'completed': completed,
      'missed': logs.length - completed,
    };
  }
  
  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';
  
  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Extension on Habit for backward compatibility
extension OptimizedHabitExtension on Habit {
  /// Use indexed lookup when available (call this from AppState)
  static Future<bool> isCompletedForOptimized(
    Habit habit,
    DateTime date,
    HabitLogCache cache,
  ) async {
    if (DatabaseMigrationService.shouldUseDrift('habitLogs')) {
      return cache.isCompletedFor(habit.id, date);
    } else {
      return habit.isCompletedFor(date);
    }
  }
  
  /// Use indexed lookup for log (call this from AppState)
  static Future<HabitLog?> getLogForOptimized(
    Habit habit,
    DateTime date,
    HabitLogCache cache,
  ) async {
    if (DatabaseMigrationService.shouldUseDrift('habitLogs')) {
      return cache.getLogFor(habit.id, date);
    } else {
      return habit.getLogFor(date);
    }
  }
}
