import 'package:hive/hive.dart';

part 'experiment.g.dart';

/// Status of an experiment from Kolb's reflection
@HiveType(typeId: 16)
enum ExperimentStatus {
  @HiveField(0)
  pending, // Just extracted, not acted upon

  @HiveField(1)
  inProgress, // Currently being worked on

  @HiveField(2)
  completed, // Successfully completed

  @HiveField(3)
  cycled, // Carried forward to next reflection cycle

  @HiveField(4)
  archived, // Done with this experiment (finished or abandoned)
}

/// Experiment - Actionable items extracted from Kolb's reflections
/// Now a first-class citizen, NOT converted to tasks
@HiveType(typeId: 7)
class Experiment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String description;

  @HiveField(2)
  ExperimentStatus status;

  @HiveField(3)
  String reflectionId; // Parent reflection

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  String? groupId; // Links to ReflectionGroup for cycling

  @HiveField(6)
  int cycleCount; // How many times this experiment has been cycled

  @HiveField(7)
  DateTime? startedAt; // When marked as inProgress

  @HiveField(8)
  DateTime? completedAt; // When completed or archived

  @HiveField(9)
  String? notes; // Optional notes about progress

  Experiment({
    required this.id,
    required this.description,
    this.status = ExperimentStatus.pending,
    required this.reflectionId,
    DateTime? createdAt,
    this.groupId,
    this.cycleCount = 0,
    this.startedAt,
    this.completedAt,
    this.notes,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Start working on this experiment
  void start() {
    status = ExperimentStatus.inProgress;
    startedAt = DateTime.now();
  }

  /// Mark experiment as completed
  void complete() {
    status = ExperimentStatus.completed;
    completedAt = DateTime.now();
  }

  /// Cycle experiment to next reflection
  void cycle() {
    status = ExperimentStatus.cycled;
    cycleCount++;
  }

  /// Archive experiment (done or abandoned)
  void archive() {
    status = ExperimentStatus.archived;
    completedAt ??= DateTime.now();
  }

  /// Check if experiment is actionable (can be started or worked on)
  bool get isActionable =>
      status == ExperimentStatus.pending ||
      status == ExperimentStatus.inProgress;

  /// Check if experiment is finished (completed or archived)
  bool get isFinished =>
      status == ExperimentStatus.completed ||
      status == ExperimentStatus.archived;

  /// Get status display text
  String get statusText {
    switch (status) {
      case ExperimentStatus.pending:
        return 'Pending';
      case ExperimentStatus.inProgress:
        return 'In Progress';
      case ExperimentStatus.completed:
        return 'Completed';
      case ExperimentStatus.cycled:
        return 'Cycled Forward';
      case ExperimentStatus.archived:
        return 'Archived';
    }
  }

  /// Get status emoji
  String get statusEmoji {
    switch (status) {
      case ExperimentStatus.pending:
        return '⏳';
      case ExperimentStatus.inProgress:
        return '🔄';
      case ExperimentStatus.completed:
        return '✅';
      case ExperimentStatus.cycled:
        return '🔁';
      case ExperimentStatus.archived:
        return '📦';
    }
  }
}

