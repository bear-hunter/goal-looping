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

/// Effort level for a task
@HiveType(typeId: 26)
enum TaskEffort {
  @HiveField(0)
  quick,  // ⚡ Low effort, quick win

  @HiveField(1)
  deep,   // 🐘 Deep work, heavy effort
}

/// Impact level for a task
@HiveType(typeId: 27)
enum TaskImpact {
  @HiveField(0)
  high,        // ⭐ High value outcome

  @HiveField(1)
  maintenance, // 🧹 Routine/maintenance
}

/// Reason for abandoning/demoting a task
@HiveType(typeId: 28)
enum TaskAbandonReason {
  @HiveField(0)
  noTime,       // 🕐 Ran out of time

  @HiveField(1) 
  tooHard,      // 🧗 Too difficult

  @HiveField(2)
  notImportant, // ❌ Not important anymore

  @HiveField(3)
  completed,    // ✅ Actually completed
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

  // New fields for smart task management
  
  @HiveField(11)
  TaskEffort effort;

  @HiveField(12)
  TaskImpact impact;

  @HiveField(13)
  DateTime? addedToPriorityAt; // When task was promoted to Top 2

  @HiveField(14)
  TaskAbandonReason? abandonReason; // Why task was demoted/deleted

  @HiveField(15)
  String? blockedByTaskId; // Task dependency

  @HiveField(16)
  String category;

  @HiveField(17)
  DateTime? deadline;

  @HiveField(18)
  String? customTag;

  // Phase 7: Marginal Gains Framework - 1% Improvement Tracking
  @HiveField(19)
  String? marginalGainDescription; // "What 1% improvement does this task represent?"

  @HiveField(20)
  bool isResearchTask; // True if task is about gaining knowledge (framework key principle)

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
    this.effort = TaskEffort.quick,
    this.impact = TaskImpact.high,
    this.addedToPriorityAt,
    this.abandonReason,
    this.blockedByTaskId,
    this.category = 'General',
    this.deadline,
    this.customTag,
    this.marginalGainDescription,
    this.isResearchTask = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        linkedFactorIds = linkedFactorIds ?? [];

  /// Mark task as completed
  void complete() {
    isCompleted = true;
    completedAt = DateTime.now();
    abandonReason = TaskAbandonReason.completed;
  }

  /// Promote task to priority (Top 2)
  void promoteToPriority() {
    isPriority = true;
    addedToPriorityAt = DateTime.now();
  }

  /// Demote task to backlog
  void demoteToBacklog({TaskAbandonReason? reason}) {
    isPriority = false;
    if (reason != null) {
      abandonReason = reason;
    }
  }

  /// Check if task is stale (in Top 2 for >24 hours)
  bool get isStale {
    if (!isPriority || addedToPriorityAt == null) return false;
    return DateTime.now().difference(addedToPriorityAt!).inHours >= 24;
  }

  /// Check if task is blocked by another task
  bool get isBlocked => blockedByTaskId != null;

  /// Hours since added to priority
  int get hoursInPriority {
    if (addedToPriorityAt == null) return 0;
    return DateTime.now().difference(addedToPriorityAt!).inHours;
  }

  /// Effort emoji
  String get effortEmoji => effort == TaskEffort.quick ? '⚡' : '🐘';

  /// Impact emoji  
  String get impactEmoji => impact == TaskImpact.high ? '⭐' : '🧹';
}
