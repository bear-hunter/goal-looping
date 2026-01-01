import 'package:hive/hive.dart';
import 'habit_enums.dart';

part 'recurring_task.g.dart';

/// Log entry for a recurring task instance
@HiveType(typeId: 35)
class RecurringTaskLog extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  bool completed;

  @HiveField(2)
  String? note;

  @HiveField(3)
  List<bool>? checklistCompleted; // For checklist evaluation type

  @HiveField(4)
  int? numericValue; // For tracking numeric progress

  RecurringTaskLog({
    required this.date,
    this.completed = false,
    this.note,
    this.checklistCompleted,
    this.numericValue,
  });
}

/// Recurring Task - An activity that repeats over time
/// Connected to dissected trees (Factors) for goal tracking
@HiveType(typeId: 31)
class RecurringTask extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String categoryId;

  @HiveField(3)
  HabitEvaluationType evaluationType; // Only yesNo or checklist

  @HiveField(4)
  List<String>? checklistItems; // For checklist evaluation

  @HiveField(5)
  HabitFrequencyType frequencyType;

  @HiveField(6)
  List<int> scheduledDays; // [1,3,5] = Mon,Wed,Fri (1=Mon, 7=Sun)

  @HiveField(7)
  int? daysPerPeriod; // For someDaysPerPeriod frequency

  @HiveField(8)
  int? repeatInterval; // For repeatEvery frequency (every N days)

  @HiveField(9)
  List<DateTime>? specificDates; // For specificDatesOfYear

  @HiveField(10)
  DateTime startDate;

  @HiveField(11)
  DateTime? endDate;

  @HiveField(12)
  List<String> reminderTimes; // Stored as "HH:MM" strings

  @HiveField(13)
  PriorityLevel priorityLevel;

  @HiveField(14)
  List<String> linkedFactorIds; // Connected to dissected trees

  @HiveField(15)
  List<RecurringTaskLog> logs;

  @HiveField(16)
  String? description;

  @HiveField(17)
  DateTime createdAt;

  @HiveField(18)
  bool isArchived;

  @HiveField(19)
  int sortOrder;

  @HiveField(20)
  int priority; // Numeric priority (-20 to 20, higher = more important)

  RecurringTask({
    required this.id,
    required this.name,
    required this.categoryId,
    this.evaluationType = HabitEvaluationType.yesNo,
    this.checklistItems,
    this.frequencyType = HabitFrequencyType.everyday,
    List<int>? scheduledDays,
    this.daysPerPeriod,
    this.repeatInterval,
    this.specificDates,
    DateTime? startDate,
    this.endDate,
    List<String>? reminderTimes,
    this.priorityLevel = PriorityLevel.none,
    List<String>? linkedFactorIds,
    List<RecurringTaskLog>? logs,
    this.description,
    DateTime? createdAt,
    this.isArchived = false,
    this.sortOrder = 0,
    this.priority = 0,
  }) : scheduledDays = scheduledDays ?? [1, 2, 3, 4, 5, 6, 7],
       startDate = startDate ?? DateTime.now(),
       reminderTimes = reminderTimes ?? [],
       linkedFactorIds = linkedFactorIds ?? [],
       logs = logs ?? [],
       createdAt = createdAt ?? DateTime.now();

  /// Check if scheduled for a specific date
  bool isScheduledFor(DateTime date) {
    // Check if before start date or after end date
    if (date.isBefore(
      DateTime(startDate.year, startDate.month, startDate.day),
    )) {
      return false;
    }
    if (endDate != null &&
        date.isAfter(DateTime(endDate!.year, endDate!.month, endDate!.day))) {
      return false;
    }

    switch (frequencyType) {
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
        // For simplicity, use scheduledDays to track which days of the week
        return scheduledDays.contains(date.weekday);

      case HabitFrequencyType.repeatEvery:
        if (repeatInterval == null || repeatInterval! <= 0) return false;
        final daysDiff = date.difference(startDate).inDays;
        return daysDiff % repeatInterval! == 0;
    }
  }

  /// Check if scheduled for today
  bool get isScheduledToday => isScheduledFor(DateTime.now());

  /// Get log for a specific date
  RecurringTaskLog? getLogFor(DateTime date) {
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

  /// Log completion for a date
  void logCompletion({
    required DateTime date,
    required bool completed,
    String? note,
    List<bool>? checklistCompleted,
  }) {
    // Remove existing log for this date
    logs.removeWhere(
      (log) =>
          log.date.year == date.year &&
          log.date.month == date.month &&
          log.date.day == date.day,
    );

    logs.add(
      RecurringTaskLog(
        date: date,
        completed: completed,
        note: note,
        checklistCompleted: checklistCompleted,
      ),
    );
  }

  /// Get scheduled days as readable string
  String get scheduleDaysLabel {
    if (frequencyType == HabitFrequencyType.everyday) return 'Every day';
    if (scheduledDays.length == 7) return 'Every day';
    if (scheduledDays.isEmpty) return 'No schedule';

    const dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return scheduledDays.map((d) => dayNames[d]).join(', ');
  }
}
