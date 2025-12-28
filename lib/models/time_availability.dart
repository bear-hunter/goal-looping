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

/// Extension for human-readable labels
extension TimeAvailabilityExtension on TimeAvailability {
  String get label {
    switch (this) {
      case TimeAvailability.absolutelyZero:
        return 'Absolutely Zero';
      case TimeAvailability.veryLittle:
        return 'Very Little';
      case TimeAvailability.some:
        return 'Some';
      case TimeAvailability.decent:
        return 'Decent';
      case TimeAvailability.free:
        return 'Free';
    }
  }

  String get description {
    switch (this) {
      case TimeAvailability.absolutelyZero:
        return 'No way to invest any additional time';
      case TimeAvailability.veryLittle:
        return 'Small amount of time on a weekly basis';
      case TimeAvailability.some:
        return 'Moderate amount of time on a weekly basis';
      case TimeAvailability.decent:
        return 'Significant time on multiple days of the week';
      case TimeAvailability.free:
        return 'Majority of time available for the next 30 days';
    }
  }
}
