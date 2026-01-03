import 'package:hive/hive.dart';

part 'habit_enums.g.dart';

/// How the habit progress is evaluated
@HiveType(typeId: 37)
enum HabitEvaluationType {
  @HiveField(0)
  yesNo, // Simple yes/no completion

  @HiveField(1)
  numeric, // Track a numeric value (e.g., "8 glasses of water")

  @HiveField(2)
  timer, // Duration-based (e.g., "Meditate 10 mins")

  @HiveField(3)
  checklist, // Multiple sub-items to complete
}

/// How often the habit repeats
@HiveType(typeId: 33)
enum HabitFrequencyType {
  @HiveField(0)
  everyday, // Every single day

  @HiveField(1)
  specificDays, // [1,3,5] = Mon,Wed,Fri

  @HiveField(2)
  specificDatesOfYear, // Specific dates like birthdays

  @HiveField(3)
  someDaysPerPeriod, // e.g., 3 days per week

  @HiveField(4)
  repeatEvery, // e.g., every 2 days
}

/// Priority level for habits and tasks
@HiveType(typeId: 34)
enum PriorityLevel {
  @HiveField(0)
  none, // Default, no special priority

  @HiveField(1)
  low, // Low priority

  @HiveField(2)
  medium, // Medium priority

  @HiveField(3)
  high, // High priority - most important
}

/// Extension methods for HabitEvaluationType
extension HabitEvaluationTypeExtension on HabitEvaluationType {
  String get label {
    switch (this) {
      case HabitEvaluationType.yesNo:
        return 'Yes or No';
      case HabitEvaluationType.numeric:
        return 'Numeric Value';
      case HabitEvaluationType.timer:
        return 'Timer';
      case HabitEvaluationType.checklist:
        return 'Checklist';
    }
  }

  String get description {
    switch (this) {
      case HabitEvaluationType.yesNo:
        return 'Did you complete it? Yes or No.';
      case HabitEvaluationType.numeric:
        return 'Track a number like glasses of water or pages read.';
      case HabitEvaluationType.timer:
        return 'Track time spent on an activity.';
      case HabitEvaluationType.checklist:
        return 'Multiple items to check off.';
    }
  }

  String get icon {
    switch (this) {
      case HabitEvaluationType.yesNo:
        return '✓';
      case HabitEvaluationType.numeric:
        return '123';
      case HabitEvaluationType.timer:
        return '⏱';
      case HabitEvaluationType.checklist:
        return '☑';
    }
  }
}

/// Extension methods for HabitFrequencyType
extension HabitFrequencyTypeExtension on HabitFrequencyType {
  String get label {
    switch (this) {
      case HabitFrequencyType.everyday:
        return 'Every day';
      case HabitFrequencyType.specificDays:
        return 'Specific days of the week';
      case HabitFrequencyType.specificDatesOfYear:
        return 'Specific dates of the year';
      case HabitFrequencyType.someDaysPerPeriod:
        return 'Some days per period';
      case HabitFrequencyType.repeatEvery:
        return 'Repeat every...';
    }
  }
}

/// Extension methods for PriorityLevel
extension PriorityLevelExtension on PriorityLevel {
  String get label {
    switch (this) {
      case PriorityLevel.none:
        return 'Default';
      case PriorityLevel.low:
        return 'Low';
      case PriorityLevel.medium:
        return 'Medium';
      case PriorityLevel.high:
        return 'High';
    }
  }

  int get value {
    switch (this) {
      case PriorityLevel.none:
        return 0;
      case PriorityLevel.low:
        return 1;
      case PriorityLevel.medium:
        return 2;
      case PriorityLevel.high:
        return 3;
    }
  }
}
