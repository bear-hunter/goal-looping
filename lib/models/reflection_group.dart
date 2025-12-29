import 'package:hive/hive.dart';

part 'reflection_group.g.dart';

/// Groups related reflection cycles together for tracking compounding marginal gains
@HiveType(typeId: 25)
class ReflectionGroup extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title; // e.g., "Time Management Deep Dive"

  @HiveField(2)
  List<String> reflectionIds; // Ordered chain of reflection IDs

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? archivedAt; // Null = active, set = archived

  @HiveField(5)
  String? targetFactorId; // Primary factor being addressed

  ReflectionGroup({
    required this.id,
    required this.title,
    List<String>? reflectionIds,
    DateTime? createdAt,
    this.archivedAt,
    this.targetFactorId,
  })  : reflectionIds = reflectionIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// Check if this group is archived
  bool get isArchived => archivedAt != null;

  /// Number of cycles in this group
  int get cycleCount => reflectionIds.length;

  /// Add a new reflection to the group
  void addReflection(String reflectionId) {
    reflectionIds.add(reflectionId);
  }

  /// Archive this group
  void archive() {
    archivedAt = DateTime.now();
  }

  /// Restore from archive
  void restore() {
    archivedAt = null;
  }
}
