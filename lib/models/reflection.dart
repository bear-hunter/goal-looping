import 'package:hive/hive.dart';

part 'reflection.g.dart';

/// Kolb's Reflection Cycle
@HiveType(typeId: 6)
class Reflection extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String experience; // Step 1: What happened

  @HiveField(2)
  String reflection; // Step 2: Sequence of events, feelings

  @HiveField(3)
  String abstraction; // Step 3: Habits, beliefs, tendencies identified

  @HiveField(4)
  List<String> experimentIds; // Step 4: Extracted experiments

  @HiveField(5)
  List<String> linkedFactorIds; // Tags (e.g., "Time Management")

  @HiveField(6)
  bool isFollowUp; // Is this a follow-up to previous cycle?

  @HiveField(7)
  String? previousReflectionId; // Threading to previous cycle

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  String? rawMarkdown; // Original pasted content

  Reflection({
    required this.id,
    this.experience = '',
    this.reflection = '',
    this.abstraction = '',
    List<String>? experimentIds,
    List<String>? linkedFactorIds,
    this.isFollowUp = false,
    this.previousReflectionId,
    DateTime? createdAt,
    this.rawMarkdown,
  })  : experimentIds = experimentIds ?? [],
        linkedFactorIds = linkedFactorIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// Check if reflection is complete (all steps filled)
  bool get isComplete => 
      experience.isNotEmpty && 
      reflection.isNotEmpty && 
      abstraction.isNotEmpty &&
      experimentIds.isNotEmpty;

  /// Get completion percentage
  double get completionPercent {
    int filled = 0;
    if (experience.isNotEmpty) filled++;
    if (reflection.isNotEmpty) filled++;
    if (abstraction.isNotEmpty) filled++;
    if (experimentIds.isNotEmpty) filled++;
    return filled / 4.0;
  }
}
