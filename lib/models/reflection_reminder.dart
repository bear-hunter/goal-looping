import 'package:hive/hive.dart';

part 'reflection_reminder.g.dart';

/// Frequency options for reflection reminders
@HiveType(typeId: 24)
enum ReflectionReminderFrequency {
  @HiveField(0)
  daily, // Remind every day

  @HiveField(1)
  twiceWeekly, // Remind twice a week

  @HiveField(2)
  weekly, // Remind once a week

  @HiveField(3)
  disabled, // No reminders
}

/// Extension methods for ReflectionReminderFrequency
extension ReflectionReminderFrequencyExtension on ReflectionReminderFrequency {
  /// Get the maximum hours allowed between reflections before considered overdue
  int get maxHoursBetweenReflections {
    switch (this) {
      case ReflectionReminderFrequency.daily:
        return 36; // 1.5 days buffer
      case ReflectionReminderFrequency.twiceWeekly:
        return 96; // 4 days buffer
      case ReflectionReminderFrequency.weekly:
        return 192; // 8 days buffer
      case ReflectionReminderFrequency.disabled:
        return 999999; // Never overdue
    }
  }

  /// Human-readable display name
  String get displayName {
    switch (this) {
      case ReflectionReminderFrequency.daily:
        return 'Daily';
      case ReflectionReminderFrequency.twiceWeekly:
        return 'Twice Weekly';
      case ReflectionReminderFrequency.weekly:
        return 'Weekly';
      case ReflectionReminderFrequency.disabled:
        return 'Disabled';
    }
  }

  /// Description of the frequency
  String get description {
    switch (this) {
      case ReflectionReminderFrequency.daily:
        return 'Ideal for active learning periods';
      case ReflectionReminderFrequency.twiceWeekly:
        return 'Good balance for busy schedules';
      case ReflectionReminderFrequency.weekly:
        return 'Minimum recommended frequency';
      case ReflectionReminderFrequency.disabled:
        return 'No reminders (not recommended)';
    }
  }
}
