import 'package:hive/hive.dart';

part 'time_availability.g.dart';

/// Time Availability options from Performance Plan
@HiveType(typeId: 17)
enum TimeAvailability {
  @HiveField(0)
  absolutelyZero, // No way to invest additional time

  @HiveField(1)
  veryLittle, // Small amount weekly

  @HiveField(2)
  some, // Moderate amount weekly

  @HiveField(3)
  decent, // Multiple days, significant time

  @HiveField(4)
  free, // Majority of time available
}

/// Extension for human-readable labels with quantified hours
extension TimeAvailabilityExtension on TimeAvailability {
  String get label {
    switch (this) {
      case TimeAvailability.absolutelyZero:
        return 'Absolutely Zero (0 hrs/wk)';
      case TimeAvailability.veryLittle:
        return 'Very Little (1-2 hrs/wk)';
      case TimeAvailability.some:
        return 'Some (3-5 hrs/wk)';
      case TimeAvailability.decent:
        return 'Decent (6-10 hrs/wk)';
      case TimeAvailability.free:
        return 'Free (10+ hrs/wk)';
    }
  }

  int get hoursPerWeekMin {
    switch (this) {
      case TimeAvailability.absolutelyZero: return 0;
      case TimeAvailability.veryLittle: return 1;
      case TimeAvailability.some: return 3;
      case TimeAvailability.decent: return 6;
      case TimeAvailability.free: return 10;
    }
  }

  String get description {
    switch (this) {
      case TimeAvailability.absolutelyZero:
        return 'No way to invest any additional time';
      case TimeAvailability.veryLittle:
        return '1-2 hours per week for focused work';
      case TimeAvailability.some:
        return '3-5 hours per week for focused work';
      case TimeAvailability.decent:
        return '6-10 hours per week across multiple days';
      case TimeAvailability.free:
        return '10+ hours per week, majority of time available';
    }
  }
}
