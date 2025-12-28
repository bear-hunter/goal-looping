import 'package:hive/hive.dart';

part 'task.g.dart';

/// Source of the task
@HiveType(typeId: 12)
enum TaskSource {
  @HiveField(0)
  newEntry,

  @HiveField(1)
  experiment, // From Kolb's reflection

  @HiveField(2)
  backlog, // Promoted from Less Important
}

/// Task - Top 2 priority tasks or backlog items
@HiveType(typeId: 3)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  bool isPriority; // True = Top 2, False = Less Important

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  TaskSource source;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? completedAt;

  @HiveField(8)
  List<String> linkedFactorIds;

  @HiveField(9)
  String? experimentId; // If source is experiment

  @HiveField(10)
  int sortOrder;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isPriority = false,
    this.isCompleted = false,
    this.source = TaskSource.newEntry,
    DateTime? createdAt,
    this.completedAt,
    List<String>? linkedFactorIds,
    this.experimentId,
    this.sortOrder = 0,
  })  : createdAt = createdAt ?? DateTime.now(),
        linkedFactorIds = linkedFactorIds ?? [];

  /// Mark task as completed
  void complete() {
    isCompleted = true;
    completedAt = DateTime.now();
  }

  /// Promote task to priority (Top 2)
  void promoteToPriority() {
    isPriority = true;
  }

  /// Demote task to backlog
  void demoteToBacklog() {
    isPriority = false;
  }
}
