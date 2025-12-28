import 'package:hive/hive.dart';

part 'goal.g.dart';

/// Medium-term goal (6-12 months)
/// Core anchor for the Goal Achievement Framework
@HiveType(typeId: 0)
class Goal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime targetDate;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  List<String> factorIds; // Links to Factor objects

  Goal({
    required this.id,
    required this.title,
    this.description = '',
    required this.targetDate,
    DateTime? createdAt,
    List<String>? factorIds,
  })  : createdAt = createdAt ?? DateTime.now(),
        factorIds = factorIds ?? [];

  /// Calculate days remaining to target
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;

  /// Check if goal is overdue
  bool get isOverdue => DateTime.now().isAfter(targetDate);
}
