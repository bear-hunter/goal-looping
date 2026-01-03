import 'package:hive/hive.dart';

part 'spaced_repetition_topic.g.dart';

/// Review interval options in days
enum ReviewInterval {
  oneDay(1, '1d'),
  twoDays(2, '2d'),
  threeDays(3, '3d'),
  oneWeek(7, '1w'),
  oneMonth(30, '1m'),
  oneYear(365, '1y');

  final int days;
  final String label;

  const ReviewInterval(this.days, this.label);

  /// Get full label for display
  String get fullLabel {
    switch (this) {
      case ReviewInterval.oneDay:
        return '1 Day';
      case ReviewInterval.twoDays:
        return '2 Days';
      case ReviewInterval.threeDays:
        return '3 Days';
      case ReviewInterval.oneWeek:
        return '1 Week';
      case ReviewInterval.oneMonth:
        return '1 Month';
      case ReviewInterval.oneYear:
        return '1 Year';
    }
  }
}

/// Topic model for spaced repetition - nested within subjects
/// Tracks review history and scheduling
@HiveType(typeId: 38)
class SpacedRepetitionTopic extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String subjectId;

  @HiveField(2)
  String name;

  @HiveField(3)
  DateTime? lastReviewedAt;

  @HiveField(4)
  DateTime? nextReviewAt;

  @HiveField(5)
  int? currentIntervalDays; // Last selected interval

  @HiveField(6)
  int reviewCount;

  @HiveField(7)
  int sortOrder;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  String? notes; // Optional notes for the topic

  SpacedRepetitionTopic({
    required this.id,
    required this.subjectId,
    required this.name,
    this.lastReviewedAt,
    this.nextReviewAt,
    this.currentIntervalDays,
    this.reviewCount = 0,
    this.sortOrder = 0,
    DateTime? createdAt,
    this.notes,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Check if the topic is due for review
  bool get isDue {
    if (nextReviewAt == null) return true; // Never reviewed
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      nextReviewAt!.year,
      nextReviewAt!.month,
      nextReviewAt!.day,
    );
    return !dueDate.isAfter(today);
  }

  /// Check if the topic was never reviewed
  bool get isNew => lastReviewedAt == null;

  /// Get days until next review (negative if overdue)
  int get daysUntilDue {
    if (nextReviewAt == null) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      nextReviewAt!.year,
      nextReviewAt!.month,
      nextReviewAt!.day,
    );
    return dueDate.difference(today).inDays;
  }

  /// Get a human-readable status string
  String get statusLabel {
    if (isNew) return 'New';
    if (isDue) {
      final overdue = -daysUntilDue;
      if (overdue == 0) return 'Due today';
      if (overdue == 1) return 'Overdue 1 day';
      return 'Overdue $overdue days';
    }
    final days = daysUntilDue;
    if (days == 1) return 'In 1 day';
    if (days < 7) return 'In $days days';
    if (days < 30) {
      final weeks = (days / 7).floor();
      return weeks == 1 ? 'In 1 week' : 'In $weeks weeks';
    }
    if (days < 365) {
      final months = (days / 30).floor();
      return months == 1 ? 'In 1 month' : 'In $months months';
    }
    return 'In ${(days / 365).floor()} year(s)';
  }

  /// Mark as reviewed and schedule next review
  SpacedRepetitionTopic markReviewed(int intervalDays) {
    final now = DateTime.now();
    return SpacedRepetitionTopic(
      id: id,
      subjectId: subjectId,
      name: name,
      lastReviewedAt: now,
      nextReviewAt: now.add(Duration(days: intervalDays)),
      currentIntervalDays: intervalDays,
      reviewCount: reviewCount + 1,
      sortOrder: sortOrder,
      createdAt: createdAt,
      notes: notes,
    );
  }

  /// Copy with updated fields
  SpacedRepetitionTopic copyWith({
    String? name,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
    int? currentIntervalDays,
    int? reviewCount,
    int? sortOrder,
    String? notes,
  }) {
    return SpacedRepetitionTopic(
      id: id,
      subjectId: subjectId,
      name: name ?? this.name,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      currentIntervalDays: currentIntervalDays ?? this.currentIntervalDays,
      reviewCount: reviewCount ?? this.reviewCount,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      notes: notes ?? this.notes,
    );
  }
}
