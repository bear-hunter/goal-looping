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

  @HiveField(10)
  String? targetFactorId; // PRIMARY factor this reflection targets

  @HiveField(11)
  String? previousExperimentId; // Cycling from previous Kolb's experiment

  // === NEW FIELDS FOR CYCLING & MANUAL TEMPLATE ===

  @HiveField(12)
  String? groupId; // Links to ReflectionGroup for cycling

  // Step 1 - Experience (manual entry fields from guidedkolbs.md)
  @HiveField(13)
  String? marginalGainDescription; // What would a marginal gain look like?

  // Step 2 - Reflection (detailed fields from guidedkolbs.md)
  @HiveField(14)
  String? eventSequence; // List and describe sequence of events

  @HiveField(15)
  String? feelings; // How did you feel about the experience?

  @HiveField(16)
  String? difficulties; // Which aspects felt difficult/went well?

  @HiveField(17)
  String? challengeResponse; // How did you respond to challenges?

  @HiveField(18)
  String? triggers; // What were the triggers to feeling this way?

  @HiveField(19)
  String? whyBehavior; // Why do you think you acted this way?

  // Step 3 - Abstraction (additional field from guidedkolbs.md)
  @HiveField(20)
  String? crossLifePatterns; // Similar patterns in other parts of life?

  // Entry mode tracking
  @HiveField(21)
  bool isManualEntry; // True = manual template, False = Gemini paste

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
    this.targetFactorId,
    this.previousExperimentId,
    this.groupId,
    this.marginalGainDescription,
    this.eventSequence,
    this.feelings,
    this.difficulties,
    this.challengeResponse,
    this.triggers,
    this.whyBehavior,
    this.crossLifePatterns,
    this.isManualEntry = false,
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

  /// Check if this reflection is part of a group
  bool get isPartOfGroup => groupId != null;

  /// Get manual entry completion percentage (more detailed)
  double get manualEntryCompletionPercent {
    if (!isManualEntry) return completionPercent;
    
    int filled = 0;
    int total = 10;
    
    // Step 1
    if (experience.isNotEmpty) filled++;
    if (marginalGainDescription?.isNotEmpty == true) filled++;
    
    // Step 2
    if (eventSequence?.isNotEmpty == true) filled++;
    if (feelings?.isNotEmpty == true) filled++;
    if (difficulties?.isNotEmpty == true) filled++;
    if (whyBehavior?.isNotEmpty == true) filled++;
    
    // Step 3
    if (abstraction.isNotEmpty) filled++;
    if (crossLifePatterns?.isNotEmpty == true) filled++;
    
    // Step 4
    if (experimentIds.isNotEmpty) filled += 2; // Weighted more
    
    return filled / total;
  }
}

