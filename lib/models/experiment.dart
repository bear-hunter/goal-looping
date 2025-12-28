import 'package:hive/hive.dart';

part 'experiment.g.dart';

/// Status of an experiment from Kolb's reflection
@HiveType(typeId: 16)
enum ExperimentStatus {
  @HiveField(0)
  pending, // Just extracted, not acted upon

  @HiveField(1)
  promoted, // Added to Top 2 or Backlog

  @HiveField(2)
  completed, // Task completed
}

/// Experiment - Actionable items extracted from Kolb's reflections
@HiveType(typeId: 7)
class Experiment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String description;

  @HiveField(2)
  ExperimentStatus status;

  @HiveField(3)
  bool promotedToPriority; // True = Top 2, False = Backlog

  @HiveField(4)
  String reflectionId; // Parent reflection

  @HiveField(5)
  String? taskId; // Linked task if promoted

  @HiveField(6)
  DateTime createdAt;

  Experiment({
    required this.id,
    required this.description,
    this.status = ExperimentStatus.pending,
    this.promotedToPriority = false,
    required this.reflectionId,
    this.taskId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Promote to Top 2 tasks
  void promoteToTop2(String linkedTaskId) {
    status = ExperimentStatus.promoted;
    promotedToPriority = true;
    taskId = linkedTaskId;
  }

  /// Promote to Backlog
  void promoteToBacklog(String linkedTaskId) {
    status = ExperimentStatus.promoted;
    promotedToPriority = false;
    taskId = linkedTaskId;
  }

  /// Mark as completed
  void markCompleted() {
    status = ExperimentStatus.completed;
  }
}
