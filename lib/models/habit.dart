import 'package:hive/hive.dart';

part 'habit.g.dart';

/// Type of habit tracking
@HiveType(typeId: 13)
enum HabitType {
  @HiveField(0)
  limiting, // Track absence (e.g., "No doom scrolling")

  @HiveField(1)
  scripted, // Trigger-response (e.g., "If distracted -> 3 deep breaths")
}

/// Daily log entry for habit
@HiveType(typeId: 14)
class HabitLog extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  bool succumbed; // For limiting: did you fail? For scripted: did you execute?

  @HiveField(2)
  String? note;

  HabitLog({
    required this.date,
    this.succumbed = false,
    this.note,
  });
}

/// Habit - Limiting habits and Scripted actions
@HiveType(typeId: 5)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  HabitType type;

  @HiveField(3)
  String? triggerResponse; // For scripted: "If X -> I will Y"

  @HiveField(4)
  int currentStreak;

  @HiveField(5)
  int bestStreak;

  @HiveField(6)
  int scriptedUseCount; // For scripted: how many times deployed

  @HiveField(7)
  List<HabitLog> logs;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  bool isActive;

  Habit({
    required this.id,
    required this.name,
    required this.type,
    this.triggerResponse,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.scriptedUseCount = 0,
    List<HabitLog>? logs,
    DateTime? createdAt,
    this.isActive = true,
  })  : logs = logs ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// Log today's habit check
  void logToday({required bool succumbed, String? note}) {
    final today = DateTime.now();
    
    // Remove existing log for today if any
    logs.removeWhere((log) => 
        log.date.year == today.year && 
        log.date.month == today.month && 
        log.date.day == today.day);
    
    logs.add(HabitLog(date: today, succumbed: succumbed, note: note));
    
    if (type == HabitType.limiting) {
      if (!succumbed) {
        currentStreak++;
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    } else {
      // Scripted action - succumbed means "used successfully"
      if (succumbed) {
        scriptedUseCount++;
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

  BarrierEntry({
    required this.id,
    required this.description,
    DateTime? occurredAt,
    this.response,
    this.wasHandled = false,
  }) : occurredAt = occurredAt ?? DateTime.now();
}
