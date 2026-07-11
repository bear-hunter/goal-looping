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

  /// Optional score (0-100) for "completed with scoring" or "failed with scoring"
  /// null means standard yes/no completion without scoring
  @HiveField(8)
  int? score;

  /// Whether this date's XP/coin reward has already been granted.
  @HiveField(9)
  bool? rewardGranted;

  HabitLog({
    required this.date,
    this.completed = false,
    this.note,
    this.moodRating,
    this.barrierTag,
    this.numericValue,
    this.checklistCompleted,
    this.timerSeconds,
    this.score,
    this.rewardGranted,
  });
}

/// Habit - Build, Quit, or Timed habits with scheduling
/// Enhanced with evaluation types, frequency options, and category support
@HiveType(typeId: 5, adapterName: 'GeneratedHabitAdapter')
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
  String? factorId; // Link to Strategy Factor (DEPRECATED - use linkedFactorIds)

  @HiveField(36)
  List<String>? linkedFactorIds; // Links to Strategy Factors (multiple trees)

  // Phase 2: Flexible Scheduling (HabitNow standard)
  @HiveField(11)
  List<int> scheduledDays; // [1,3,5] = Mon,Wed,Fri (1=Mon, 7=Sun)

  @HiveField(12, defaultValue: 1)
  int targetFrequency; // Times per day for repetition habits

  // Phase 2: Psychological Depth (Proddy standard)
  @HiveField(13, defaultValue: '')
  String motivation; // "The Why" - displayed during check-in

  // Phase 2: Timed Habits
  @HiveField(14)
  int? timerMinutes; // Duration for timed habits

  // Phase 2: Streak Freeze
  @HiveField(15, defaultValue: 0)
  int streakFreezes; // Allowed skips without breaking streak

  @HiveField(16, defaultValue: 0)
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

  @HiveField(27, defaultValue: false)
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

  @HiveField(33, defaultValue: 0)
  int sortOrder; // For custom ordering in lists

  /// Whether this habit uses optional scoring (0-100) instead of simple yes/no
  /// When true, user can mark as "completed with scoring" or "failed with scoring"
  @HiveField(34, defaultValue: false)
  bool scoringEnabled;

  @HiveField(35, defaultValue: 0)
  int priority; // Numeric priority (-20 to 20, higher = more important)

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
    this.linkedFactorIds,
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
    this.scoringEnabled = false,
    this.priority = 0,
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
        final quota = daysPerPeriod ?? 0;
        if (quota <= 0) return false;

        // Flexible weekly habits remain due until their quota is met. Logged
        // dates stay visible so history does not disappear later in the week.
        if (getLogFor(date) != null) return true;
        final day = DateTime(date.year, date.month, date.day);
        final weekStart = day.subtract(Duration(days: day.weekday - 1));
        final completedBefore = logs.where((log) {
          final logDay = DateTime(log.date.year, log.date.month, log.date.day);
          return log.completed &&
              !logDay.isBefore(weekStart) &&
              logDay.isBefore(day);
        }).length;
        return completedBefore < quota;

      case HabitFrequencyType.repeatEvery:
        if (repeatInterval == null || repeatInterval! <= 0) return false;
        final day = DateTime(date.year, date.month, date.day);
        final start = DateTime(
          effectiveStartDate.year,
          effectiveStartDate.month,
          effectiveStartDate.day,
        );
        final daysDiff = day.difference(start).inDays;
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
    int? score,
    bool? rewardGranted,
    bool affectsStreak = true,
  }) {
    final previousLog = getLogFor(date);
    final completionChanged = (previousLog?.completed ?? false) != completed;
    final streakStateChanged = previousLog == null
        ? affectsStreak
        : previousLog.completed != completed;

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
        score: score,
        rewardGranted: rewardGranted ?? previousLog?.rewardGranted,
      ),
    );

    if (type != HabitType.quit && completionChanged) {
      completionCount = completed
          ? completionCount + 1
          : (completionCount > 0 ? completionCount - 1 : 0);
    }

    // Update streaks only when today's completion state changes.
    final now = DateTime.now();
    if (affectsStreak &&
        streakStateChanged &&
        date.year == now.year &&
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
    int? score,
    bool? rewardGranted,
  }) {
    logForDate(
      date: DateTime.now(),
      completed: completed,
      note: note,
      mood: mood,
      barrier: barrier,
      score: score,
      rewardGranted: rewardGranted,
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
    if (effectiveFrequencyType == HabitFrequencyType.everyday) {
      return 'Every day';
    }
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

  /// Get completion rate as integer percentage (0-100)
  int get completionRate => habitScore.round();

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

/// Reads the original ten-field Habit layout without changing the current
/// generated layout or writer.
class HabitAdapter extends GeneratedHabitAdapter {
  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    if (numOfFields != 10) {
      return super.read(_HabitReaderWithFieldCount(reader, numOfFields));
    }

    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // The current enum adapter decodes the original wire values as build (0)
    // and quit (1), so swap them back to their original meanings.
    final decodedType = fields[2] as HabitType;
    final isLegacyLimiting = decodedType == HabitType.build;
    final migratedType = switch (decodedType) {
      HabitType.build => HabitType.quit,
      HabitType.quit => HabitType.build,
      HabitType.timed => HabitType.timed,
    };

    final decodedLogs = (fields[7] as List?)?.cast<HabitLog>();
    final migratedLogs = isLegacyLimiting
        ? decodedLogs?.map(_invertLegacyLimitingLog).toList()
        : decodedLogs;

    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      type: migratedType,
      triggerResponse: fields[3] as String?,
      currentStreak: fields[4] as int,
      bestStreak: fields[5] as int,
      completionCount: fields[6] as int,
      logs: migratedLogs,
      createdAt: fields[8] as DateTime?,
      isActive: fields[9] as bool,
    );
  }

  static HabitLog _invertLegacyLimitingLog(HabitLog log) {
    return HabitLog(
      date: log.date,
      completed: !log.completed,
      note: log.note,
      moodRating: log.moodRating,
      barrierTag: log.barrierTag,
      numericValue: log.numericValue,
      checklistCompleted: log.checklistCompleted,
      timerSeconds: log.timerSeconds,
      score: log.score,
      rewardGranted: log.rewardGranted,
    );
  }
}

/// Replays the field count already consumed for legacy-layout detection.
class _HabitReaderWithFieldCount implements BinaryReader {
  _HabitReaderWithFieldCount(this._reader, this._fieldCount);

  final BinaryReader _reader;
  int? _fieldCount;

  @override
  int readByte() {
    final fieldCount = _fieldCount;
    if (fieldCount != null) {
      _fieldCount = null;
      return fieldCount;
    }
    return _reader.readByte();
  }

  @override
  dynamic read([int? typeId]) => _reader.read(typeId);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Unexpected BinaryReader call: $invocation');
}

/// Barrier entry - a contextual record of something that blocked progress.
///
/// Tag metadata, colors and the legacy-label mapping live in
/// `barrier_tag.dart` (kept separate so this file stays Flutter-free).
@HiveType(typeId: 15)
class BarrierEntry extends HiveObject {
  @HiveField(0)
  String id;

  /// Legacy free-text description. Superseded by [tag] + [note] but kept
  /// physically present so old records still deserialize. New entries leave
  /// this empty; the barrier migration moves it into [tag]/[note].
  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime occurredAt;

  @HiveField(3)
  String? response; // How you handled it

  @HiveField(4)
  bool wasHandled;

  @HiveField(5)
  String? factorId; // Link to Factor (vestigial)

  /// Barrier tag key (see `BarrierTags`). Null on un-migrated legacy records.
  @HiveField(6)
  String? tag;

  /// Free-text note, kept separate from the tag.
  @HiveField(7)
  String? note;

  /// Optional link to the habit this barrier blocked.
  @HiveField(8)
  String? linkedHabitId;

  /// Optional link to the task this barrier blocked.
  @HiveField(9)
  String? linkedTaskId;

  /// Optional mood rating (1-5) captured alongside the barrier.
  @HiveField(10)
  int? moodRating;

  BarrierEntry({
    required this.id,
    this.description = '',
    DateTime? occurredAt,
    this.response,
    this.wasHandled = false,
    this.factorId,
    this.tag,
    this.note,
    this.linkedHabitId,
    this.linkedTaskId,
    this.moodRating,
  }) : occurredAt = occurredAt ?? DateTime.now();
}
