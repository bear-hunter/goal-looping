import 'package:hive/hive.dart';

part 'habit.g.dart';

/// Type of habit tracking - Phase 2 expanded types
@HiveType(typeId: 13)
enum HabitType {
  @HiveField(0)
  build, // Positive habit to build (formerly "scripted")

  @HiveField(1)
  quit, // Negative habit to avoid (formerly "limiting")

  @HiveField(2)
  timed, // Habit with timer (e.g., "Meditate 10 mins")
}

/// Daily log entry for habit - Phase 2 with mood/barrier
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

  HabitLog({
    required this.date,
    this.completed = false,
    this.note,
    this.moodRating,
    this.barrierTag,
  });
}

/// Habit - Build, Quit, or Timed habits with scheduling
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
  })  : logs = logs ?? [],
        scheduledDays = scheduledDays ?? [1, 2, 3, 4, 5, 6, 7], // Default: every day
        createdAt = createdAt ?? DateTime.now();

  /// Check if habit is scheduled for today
  bool get isScheduledToday {
    final weekday = DateTime.now().weekday; // 1=Mon, 7=Sun
    return scheduledDays.contains(weekday);
  }

  /// Log today's habit check
  void logToday({required bool completed, String? note, int? mood, String? barrier}) {
    final today = DateTime.now();
    
    // Remove existing log for today if any
    logs.removeWhere((log) => 
        log.date.year == today.year && 
        log.date.month == today.month && 
        log.date.day == today.day);
    
    logs.add(HabitLog(
      date: today, 
      completed: completed, 
      note: note,
      moodRating: mood,
      barrierTag: barrier,
    ));
    
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
    return logs.any((log) => 
        log.date.year == today.year && 
        log.date.month == today.month && 
        log.date.day == today.day);
  }

  /// Get today's log if exists
  HabitLog? get todayLog {
    final today = DateTime.now();
    try {
      return logs.firstWhere((log) => 
          log.date.year == today.year && 
          log.date.month == today.month && 
          log.date.day == today.day);
    } catch (_) {
      return null;
    }
  }

  /// Get scheduled days as readable string
  String get scheduleDaysLabel {
    if (scheduledDays.length == 7) return 'Every day';
    if (scheduledDays.isEmpty) return 'No schedule';
    
    const dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return scheduledDays.map((d) => dayNames[d]).join(', ');
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
