import 'package:hive/hive.dart';

part 'sprint_target.g.dart';

/// Duration type for sprint targets
@HiveType(typeId: 11)
enum SprintDuration {
  @HiveField(0)
  thirtyDays,

  @HiveField(1)
  fourteenDays,
}

/// Sprint Target - 30-day and 14-day performance goals
@HiveType(typeId: 2)
class SprintTarget extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  SprintDuration duration;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime targetDate;

  @HiveField(7)
  List<String> linkedFactorIds;

  SprintTarget({
    required this.id,
    required this.title,
    this.description = '',
    required this.duration,
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? targetDate,
    List<String>? linkedFactorIds,
  })  : createdAt = createdAt ?? DateTime.now(),
        targetDate = targetDate ?? 
            DateTime.now().add(Duration(days: duration == SprintDuration.thirtyDays ? 30 : 14)),
        linkedFactorIds = linkedFactorIds ?? [];

  /// Days remaining in the sprint
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;

  /// Check if sprint is overdue
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(targetDate);

  /// Human-readable duration
  String get durationLabel => 
      duration == SprintDuration.thirtyDays ? '30 Days' : '14 Days';
}
