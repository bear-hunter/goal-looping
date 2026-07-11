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
@HiveType(typeId: 7, adapterName: 'GeneratedExperimentAdapter')
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

/// Reads both the current experiment layout and the original layout where
/// field ids 3-6 represented different values. New writes continue to use the
/// generated current layout.
class ExperimentAdapter extends GeneratedExperimentAdapter {
  @override
  Experiment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    final isLegacyLayout = fields[3] is bool;
    if (isLegacyLayout) {
      return Experiment(
        id: fields[0] as String,
        description: fields[1] as String,
        status: fields[2] as ExperimentStatus,
        reflectionId: fields[4] as String,
        createdAt: fields[6] as DateTime?,
      );
    }

    return Experiment(
      id: fields[0] as String,
      description: fields[1] as String,
      status: fields[2] as ExperimentStatus,
      reflectionId: fields[3] as String,
      createdAt: fields[4] as DateTime?,
      groupId: fields[5] as String?,
      cycleCount: fields[6] as int? ?? 0,
      startedAt: fields[7] as DateTime?,
      completedAt: fields[8] as DateTime?,
      notes: fields[9] as String?,
    );
  }
}
