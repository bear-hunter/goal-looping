import 'package:hive/hive.dart';
import 'habit_enums.dart';

part 'habit.g.dart';

/// Type of habit tracking - Phase 2 expanded types (legacy, kept for migration)
@HiveType(typeId: 13)
enum HabitType {
  @HiveField(0)
  build, // Positive habit to build (formerly "scripted")

  @HiveField(1)
  quit, // Negative habit to avoid (formerly "limiting")

  @HiveField(2)
  timed, // Habit with timer (e.g., "Meditate 10 mins")
}

/// Daily log entry for habit - Enhanced with numeric and checklist tracking
@HiveType(typeId: 14)
class HabitLog extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  bool completed; // Did you complete (build/timed) or stay clean (quit)?

  @HiveField(2)
  String? note;

  // Phase 2: Psychological Depth
  @HiveField(3)
  int? moodRating; // 1-5 emoji scale

  @HiveField(4)
  String? barrierTag; // "Tired", "No Time", "Stressed", etc.

  // Phase 3: Enhanced tracking
  @HiveField(5)
  int? numericValue; // For numeric evaluation (e.g., 8 glasses of water)

  @HiveField(6)
  List<bool>? checklistCompleted; // For checklist evaluation

  @HiveField(7)
  int? timerSeconds; // Actual time tracked for timer evaluation

  HabitLog({
    required this.date,
    this.completed = false,
    this.note,
    this.moodRating,
    this.barrierTag,
    this.numericValue,
    this.checklistCompleted,
    this.timerSeconds,
  });
}

/// Habit - Build, Quit, or Timed habits with scheduling
/// Enhanced with evaluation types, frequency options, and category support
@HiveType(typeId: 5)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  HabitType type;

  @HiveField(3)
  String? triggerResponse; // For build: "If X -> I will Y"

  @HiveField(4)
  int currentStreak;

  @HiveField(5)
  int bestStreak;

  @HiveField(6)
  int completionCount; // Total times completed

  @HiveField(7)
  List<HabitLog> logs;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  bool isActive;

  // Phase 2: Factor Linkage (Connection to Strategy)
  @HiveField(10)
  String? factorId; // Link to Strategy Factor

  // Phase 2: Flexible Scheduling (HabitNow standard)
  @HiveField(11)
  List<int> scheduledDays; // [1,3,5] = Mon,Wed,Fri (1=Mon, 7=Sun)

  @HiveField(12)
  int targetFrequency; // Times per day for repetition habits

  // Phase 2: Psychological Depth (Proddy standard)
  @HiveField(13)
  String motivation; // "The Why" - displayed during check-in

  // Phase 2: Timed Habits
  @HiveField(14)
  int? timerMinutes; // Duration for timed habits

  // Phase 2: Streak Freeze
  @HiveField(15)
  int streakFreezes; // Allowed skips without breaking streak

  @HiveField(16)
  int freezesUsed; // Freezes consumed this streak

  // === Phase 3: HabitNow-style enhancements ===

  @HiveField(17)
  String? categoryId; // Link to CategoryModel

  @HiveField(18)
  HabitEvaluationType? evaluationType; // How to track (yesNo, numeric, timer, checklist)

  @HiveField(19)
  HabitFrequencyType? frequencyType; // How often (everyday, specificDays, etc.)

  @HiveField(20)
  int? targetValue; // Target for numeric evaluation (e.g., 8 glasses)

  @HiveField(21)
  String? unit; // Unit for numeric (e.g., "glasses", "pages", "miles")

  @HiveField(22)
  List<String>? checklistItems; // Items for checklist evaluation

  @HiveField(23)
  PriorityLevel? priorityLevel; // Priority (none, low, medium, high)

  @HiveField(24)
  DateTime? startDate; // When to start the habit

  @HiveField(25)
  DateTime? endDate; // Optional end date

  @HiveField(26)
  List<String>? reminderTimes; // Stored as "HH:MM" strings

  @HiveField(27)
  bool isArchived; // Archived habits (hidden but not deleted)

  @HiveField(28)
  int? daysPerPeriod; // For someDaysPerPeriod frequency

  @HiveField(29)
  int? repeatInterval; // For repeatEvery frequency (every N days)

  @HiveField(30)
  List<DateTime>? specificDates; // For specificDatesOfYear frequency

  @HiveField(31)
  String? description; // Additional description/notes

  @HiveField(32)
  int? extraGoal; // Extra goal beyond daily goal

  @HiveField(33)
  int sortOrder; // For custom ordering in lists

  Habit({
    required this.id,
    required this.name,
    required this.type,
    this.triggerResponse,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.completionCount = 0,
    List<HabitLog>? logs,
    DateTime? createdAt,
    this.isActive = true,
    this.factorId,
    List<int>? scheduledDays,
    this.targetFrequency = 1,
    this.motivation = '',
    this.timerMinutes,
    this.streakFreezes = 0,
    this.freezesUsed = 0,
    // Phase 3 fields
    this.categoryId,
    this.evaluationType,
    this.frequencyType,
    this.targetValue,
    this.unit,
    this.checklistItems,
    this.priorityLevel,
    this.startDate,
    this.endDate,
    this.reminderTimes,
    this.isArchived = false,
    this.daysPerPeriod,
    this.repeatInterval,
    this.specificDates,
    this.description,
    this.extraGoal,
    this.sortOrder = 0,
  }) : logs = logs ?? [],
       scheduledDays =
           scheduledDays ?? [1, 2, 3, 4, 5, 6, 7], // Default: every day
       createdAt = createdAt ?? DateTime.now();

  /// Get effective evaluation type (with fallback for legacy habits)
  HabitEvaluationType get effectiveEvaluationType {
    if (evaluationType != null) return evaluationType!;
    // Map legacy type to evaluation type
    switch (type) {
      case HabitType.build:
        return HabitEvaluationType.yesNo;
      case HabitType.quit:
        return HabitEvaluationType.yesNo;
      case HabitType.timed:
        return HabitEvaluationType.timer;
    }
  }

  /// Get effective frequency type (with fallback)
  HabitFrequencyType get effectiveFrequencyType {
    return frequencyType ?? HabitFrequencyType.specificDays;
  }

  /// Get effective priority level (with fallback)
  PriorityLevel get effectivePriorityLevel {
    return priorityLevel ?? PriorityLevel.none;
  }

  /// Check if habit is scheduled for a specific date
  bool isScheduledFor(DateTime date) {
    // Check if before start date
    final effectiveStartDate = startDate ?? createdAt;
    if (date.isBefore(
      DateTime(
        effectiveStartDate.year,
        effectiveStartDate.month,
        effectiveStartDate.day,
      ),
    )) {
      return false;
    }
    // Check if after end date
    if (endDate != null &&
        date.isAfter(DateTime(endDate!.year, endDate!.month, endDate!.day))) {
      return false;
    }

    switch (effectiveFrequencyType) {
      case HabitFrequencyType.everyday:
        return true;

      case HabitFrequencyType.specificDays:
        return scheduledDays.contains(date.weekday);

      case HabitFrequencyType.specificDatesOfYear:
        if (specificDates == null) return false;
        return specificDates!.any(
          (d) => d.month == date.month && d.day == date.day,
        );

      case HabitFrequencyType.someDaysPerPeriod:
        return scheduledDays.contains(date.weekday);

      case HabitFrequencyType.repeatEvery:
        if (repeatInterval == null || repeatInterval! <= 0) return false;
        final daysDiff = date.difference(effectiveStartDate).inDays;
        return daysDiff % repeatInterval! == 0;
    }
  }

  /// Check if habit is scheduled for today
  bool get isScheduledToday => isScheduledFor(DateTime.now());

  /// Get log for a specific date
  HabitLog? getLogFor(DateTime date) {
    try {
      return logs.firstWhere(
        (log) =>
            log.date.year == date.year &&
            log.date.month == date.month &&
            log.date.day == date.day,
      );
    } catch (_) {
      return null;
    }
  }

  /// Check if completed for a specific date
  bool isCompletedFor(DateTime date) {
    final log = getLogFor(date);
    return log?.completed ?? false;
  }

  /// Get current numeric value for a date (for numeric habits)
  int getCurrentValueFor(DateTime date) {
    final log = getLogFor(date);
    return log?.numericValue ?? 0;
  }

  /// Log for a specific date (enhanced)
  void logForDate({
    required DateTime date,
    required bool completed,
    String? note,
    int? mood,
    String? barrier,
    int? numericValue,
    List<bool>? checklistCompleted,
    int? timerSeconds,
  }) {
    // Remove existing log for this date
    logs.removeWhere(
      (log) =>
          log.date.year == date.year &&
          log.date.month == date.month &&
          log.date.day == date.day,
    );

    logs.add(
      HabitLog(
        date: date,
        completed: completed,
        note: note,
        moodRating: mood,
        barrierTag: barrier,
        numericValue: numericValue,
        checklistCompleted: checklistCompleted,
        timerSeconds: timerSeconds,
      ),
    );

    // Update streaks (only if logging for today)
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      _updateStreaks(completed);
    }
  }

  /// Log today's habit check
  void logToday({
    required bool completed,
    String? note,
    int? mood,
    String? barrier,
  }) {
    logForDate(
      date: DateTime.now(),
      completed: completed,
      note: note,
      mood: mood,
      barrier: barrier,
    );
  }

  void _updateStreaks(bool completed) {
    if (type == HabitType.quit) {
      // Quit habit: completed = stayed clean
      if (completed) {
        currentStreak++;
        if (currentStreak > bestStreak) bestStreak = currentStreak;
      } else {
        // Check for streak freeze
        if (streakFreezes > freezesUsed) {
          freezesUsed++;
        } else {
          currentStreak = 0;
          freezesUsed = 0;
        }
      }
    } else {
      // Build/Timed habit: completed = did the action
      if (completed) {
        completionCount++;
        currentStreak++;
        if (currentStreak > bestStreak) bestStreak = currentStreak;
      } else {
        if (streakFreezes > freezesUsed) {
          freezesUsed++;
        } else {
          currentStreak = 0;
          freezesUsed = 0;
        }
      }
    }
  }

  /// Check if already logged today
  bool get isLoggedToday {
    final today = DateTime.now();
    return logs.any(
      (log) =>
          log.date.year == today.year &&
          log.date.month == today.month &&
          log.date.day == today.day,
    );
  }

  /// Get today's log if exists
  HabitLog? get todayLog => getLogFor(DateTime.now());

  /// Get scheduled days as readable string
  String get scheduleDaysLabel {
    if (effectiveFrequencyType == HabitFrequencyType.everyday)
      return 'Every day';
    if (scheduledDays.length == 7) return 'Every day';
    if (scheduledDays.isEmpty) return 'No schedule';

    const dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return scheduledDays.map((d) => dayNames[d]).join(', ');
  }

  /// Get frequency label for display
  String get frequencyLabel {
    switch (effectiveFrequencyType) {
      case HabitFrequencyType.everyday:
        return 'Every day';
      case HabitFrequencyType.specificDays:
        final count = scheduledDays.length;
        return '$count ${count == 1 ? 'day' : 'days'} per week';
      case HabitFrequencyType.specificDatesOfYear:
        return 'Specific dates';
      case HabitFrequencyType.someDaysPerPeriod:
        return '${daysPerPeriod ?? 0} days per period';
      case HabitFrequencyType.repeatEvery:
        return 'Every ${repeatInterval ?? 1} days';
    }
  }

  /// Get habit type label
  String get typeLabel {
    switch (type) {
      case HabitType.build:
        return 'Build';
      case HabitType.quit:
        return 'Quit';
      case HabitType.timed:
        return 'Timed';
    }
  }

  /// Calculate habit score (0-100) based on completion rate
  double get habitScore {
    if (logs.isEmpty) return 0;

    // Get logs from the last 30 days
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentLogs = logs
        .where((log) => log.date.isAfter(thirtyDaysAgo))
        .toList();

    if (recentLogs.isEmpty) return 0;

    // Count scheduled days in the last 30 days
    int scheduledCount = 0;
    int completedCount = 0;

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      if (isScheduledFor(date)) {
        scheduledCount++;
        if (isCompletedFor(date)) {
          completedCount++;
        }
      }
    }

    if (scheduledCount == 0) return 100;
    return (completedCount / scheduledCount * 100).clamp(0, 100);
  }

  /// Get completions for a time period
  int getCompletionsForPeriod(DateTime start, DateTime end) {
    return logs
        .where(
          (log) =>
              log.completed &&
              log.date.isAfter(start.subtract(const Duration(days: 1))) &&
              log.date.isBefore(end.add(const Duration(days: 1))),
        )
        .length;
  }

  /// Restart habit progress (reset streaks and logs)
  void restartProgress() {
    currentStreak = 0;
    bestStreak = 0;
    completionCount = 0;
    freezesUsed = 0;
    logs.clear();
  }
}

/// Barrier Journal Entry
@HiveType(typeId: 15)
class BarrierEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime occurredAt;

  @HiveField(3)
  String? response; // How you handled it

  @HiveField(4)
  bool wasHandled;

  @HiveField(5)
  String? factorId; // Link to Factor

  BarrierEntry({
    required this.id,
    required this.description,
    DateTime? occurredAt,
    this.response,
    this.wasHandled = false,
    this.factorId,
  }) : occurredAt = occurredAt ?? DateTime.now();
}

/// Common barrier tags for quick selection
class BarrierTags {
  static const List<String> common = [
    'Tired',
    'No Time',
    'Stressed',
    'Distracted',
    'Unmotivated',
    'Sick',
    'Social Pressure',
    'Forgot',
    'Other',
  ];
}
