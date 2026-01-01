import 'package:hive/hive.dart';
import 'habit_enums.dart';

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

/// Effort level for a task (legacy - kept for migration)
@HiveType(typeId: 26)
enum TaskEffort {
  @HiveField(0)
  quick, // ⚡ Low effort, quick win

  @HiveField(1)
  deep, // 🐘 Deep work, heavy effort
}

/// Impact level for a task (legacy - kept for migration)
@HiveType(typeId: 27)
enum TaskImpact {
  @HiveField(0)
  high, // ⭐ High value outcome

  @HiveField(1)
  maintenance, // 🧹 Routine/maintenance
}

/// Reason for abandoning/demoting a task
@HiveType(typeId: 28)
enum TaskAbandonReason {
  @HiveField(0)
  noTime, // 🕐 Ran out of time

  @HiveField(1)
  tooHard, // 🧗 Too difficult

  @HiveField(2)
  notImportant, // ❌ Not important anymore

  @HiveField(3)
  completed, // ✅ Actually completed
}

/// Task - Single-instance activities (one-time tasks)
/// Enhanced for Today page with date-based filtering
@HiveType(typeId: 3)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  bool isPriority; // Legacy: True = Top 2, False = Less Important

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

  // Legacy fields (kept for migration)

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
  String category; // Legacy string-based category

  @HiveField(17)
  DateTime? deadline;

  @HiveField(18)
  String? customTag;

  // Legacy fields (kept for migration)
  @HiveField(19)
  String? marginalGainDescription;

  @HiveField(20)
  bool isResearchTask;

  // === Phase 3: Today page enhancements ===

  @HiveField(21)
  String? categoryId; // Link to CategoryModel

  @HiveField(22)
  List<String>? checklistItems; // Optional checklist

  @HiveField(23)
  List<bool>? checklistCompleted; // Completion state for each checklist item

  @HiveField(24)
  PriorityLevel priorityLevel; // Priority (none, low, medium, high)

  @HiveField(25)
  String? note; // Additional notes

  @HiveField(26)
  bool isPending; // Show each day until completed

  @HiveField(27)
  List<String> reminderTimes; // Stored as "HH:MM" strings

  @HiveField(28)
  DateTime scheduledDate; // The date this task is scheduled for

  @HiveField(29)
  String? scheduledTime; // Time of day as "HH:MM"

  @HiveField(30)
  bool isArchived; // Archived tasks (hidden but not deleted)

  @HiveField(31)
  int priority; // Numeric priority (-20 to 20, higher = more important)

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
    // Phase 3 fields
    this.categoryId,
    this.checklistItems,
    this.checklistCompleted,
    this.priorityLevel = PriorityLevel.none,
    this.note,
    this.isPending = false,
    List<String>? reminderTimes,
    DateTime? scheduledDate,
    this.scheduledTime,
    this.isArchived = false,
    this.priority = 0,
  }) : createdAt = createdAt ?? DateTime.now(),
       linkedFactorIds = linkedFactorIds ?? [],
       reminderTimes = reminderTimes ?? [],
       scheduledDate = scheduledDate ?? DateTime.now();

  /// Check if task is scheduled for a specific date
  bool isScheduledFor(DateTime date) {
    // If pending and not completed, show on all dates from scheduledDate onwards
    if (isPending && !isCompleted) {
      return !date.isBefore(
        DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day),
      );
    }
    // Otherwise, only show on the scheduled date
    return date.year == scheduledDate.year &&
        date.month == scheduledDate.month &&
        date.day == scheduledDate.day;
  }

  /// Check if task is scheduled for today
  bool get isScheduledToday => isScheduledFor(DateTime.now());

  /// Mark task as completed
  void complete() {
    isCompleted = true;
    completedAt = DateTime.now();
    abandonReason = TaskAbandonReason.completed;
  }

  /// Promote task to priority (Top 2) - legacy
  void promoteToPriority() {
    isPriority = true;
    addedToPriorityAt = DateTime.now();
  }

  /// Demote task to backlog - legacy
  void demoteToBacklog({TaskAbandonReason? reason}) {
    isPriority = false;
    if (reason != null) {
      abandonReason = reason;
    }
  }

  /// Check if task is stale (in Top 2 for >24 hours) - legacy
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

  /// Effort emoji - legacy
  String get effortEmoji => effort == TaskEffort.quick ? '⚡' : '🐘';

  /// Impact emoji - legacy
  String get impactEmoji => impact == TaskImpact.high ? '⭐' : '🧹';

  /// Get checklist progress (completed / total)
  String get checklistProgress {
    if (checklistItems == null || checklistItems!.isEmpty) return '';
    final completed = checklistCompleted?.where((c) => c).length ?? 0;
    return '$completed/${checklistItems!.length}';
  }

  /// Toggle a checklist item
  void toggleChecklistItem(int index) {
    if (checklistItems == null || index >= checklistItems!.length) return;

    // Initialize checklistCompleted if needed
    checklistCompleted ??= List.filled(checklistItems!.length, false);

    // Ensure the list is long enough
    while (checklistCompleted!.length < checklistItems!.length) {
      checklistCompleted!.add(false);
    }

    checklistCompleted![index] = !checklistCompleted![index];

    // Auto-complete task if all checklist items are done
    if (checklistCompleted!.every((c) => c)) {
      isCompleted = true;
      completedAt = DateTime.now();
    }
  }

  /// Check if all checklist items are completed
  bool get isChecklistComplete {
    if (checklistItems == null || checklistItems!.isEmpty) return true;
    if (checklistCompleted == null) return false;
    return checklistCompleted!.length >= checklistItems!.length &&
        checklistCompleted!.every((c) => c);
  }
}
