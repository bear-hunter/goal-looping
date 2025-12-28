import 'package:hive/hive.dart';

part 'subtask.g.dart';

/// Subtask - Checklist items for a task
@HiveType(typeId: 4)
class Subtask extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  String parentTaskId;

  @HiveField(4)
  int sortOrder;

  @HiveField(5)
  DateTime createdAt;

  Subtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.parentTaskId,
    this.sortOrder = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Toggle completion status
  void toggle() {
    isCompleted = !isCompleted;
  }
}
