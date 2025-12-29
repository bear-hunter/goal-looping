import 'package:hive/hive.dart';

part 'growth_area.g.dart';

/// Type of growth area for goal dissection
@HiveType(typeId: 10)
enum GrowthAreaType {
  @HiveField(0)
  knowledge,

  @HiveField(1)
  skill,

  @HiveField(2)
  attribute,

  @HiveField(3)
  process,

  @HiveField(4)
  resource,
}

/// GrowthArea - Goal dissection element (Knowledge, Skills, Attributes, etc.)
/// These serve as master tags for tasks and reflections
@HiveType(typeId: 1)
class GrowthArea extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  GrowthAreaType type;

  @HiveField(3)
  int targetLevel; // 1-10

  @HiveField(4)
  int currentLevel; // 1-10

  @HiveField(5)
  String description;

  @HiveField(6)
  String goalId; // Parent goal

  @HiveField(7)
  DateTime lastUpdated;

  // Phase 2: Level Criteria (User Agency)
  @HiveField(8)
  String targetDescription; // "What does Level 10 look like?"

  @HiveField(9)
  String currentDescription; // "Why am I at my current level?"

  // Phase 2: Effort Tracking
  @HiveField(10)
  List<String> linkedHabitIds; // All habits linked to this GrowthArea

  // Phase 5: Focus System
  @HiveField(11)
  bool isActiveFocus; // Is this one of the user's 2 focus areas?

  @HiveField(12)
  DateTime? lastWorkedOn; // For decay calculation (active only)

  @HiveField(13)
  double healthPercent; // 0-100, only decays when active

  // Phase 6: Tree Design
  @HiveField(14)
  String treeDesignId; // Which tree design to use

  // Phase 7: Marginal Gains Framework - Uncertainty Flagging
  @HiveField(15)
  int confidenceLevel; // 1-5: How confident are you about this Factor? (1=uncertain, 5=certain)

  @HiveField(16)
  bool needsResearch; // True if knowledge gap identified (Step 5 of framework)

  GrowthArea({
    required this.id,
    required this.name,
    required this.type,
    this.targetLevel = 7,
    this.currentLevel = 3,
    this.description = '',
    required this.goalId,
    DateTime? lastUpdated,
    this.targetDescription = '',
    this.currentDescription = '',
    List<String>? linkedHabitIds,
    this.isActiveFocus = false,
    this.lastWorkedOn,
    this.healthPercent = 100.0,
    this.treeDesignId = 'oak',
    this.confidenceLevel = 3,
    this.needsResearch = false,
  }) : lastUpdated = lastUpdated ?? DateTime.now(),
       linkedHabitIds = linkedHabitIds ?? [];

  /// Calculate the gap between target and current level
  int get gap => targetLevel - currentLevel;

  /// Get a percentage of progress (current / target)
  double get progressPercent => 
      targetLevel > 0 ? (currentLevel / targetLevel).clamp(0.0, 1.0) : 0.0;

  /// Check if this area needs focus (biggest gap)
  bool get needsFocus => gap > 3;

  /// Growth stage based on current level (0-5)
  int get growthStage {
    if (currentLevel <= 1) return 0; // Seed
    if (currentLevel <= 3) return 1; // Sprout
    if (currentLevel <= 5) return 2; // Sapling
    if (currentLevel <= 7) return 3; // Growing
    if (currentLevel <= 9) return 4; // Mature
    return 5; // Mastered
  }

  /// Health status for tree visualization
  String get healthStatus {
    if (!isActiveFocus) return 'dormant'; // 💤
    if (healthPercent >= 75) return 'flourishing';
    if (healthPercent >= 50) return 'healthy';
    if (healthPercent >= 25) return 'wilting';
    return 'dead';
  }

  /// Tree emoji based on growth stage
  String get treeEmoji {
    if (!isActiveFocus) return '💤';
    if (healthStatus == 'dead') return '💀';
    switch (growthStage) {
      case 0: return '🌱';
      case 1: return '🌿';
      case 2: return '🌲';
      case 3: return '🌳';
      case 4: return '🌳';
      case 5: return '👑';
      default: return '🌱';
    }
  }

  /// Days since last work
  int get daysSinceWork {
    if (lastWorkedOn == null) return 0;
    return DateTime.now().difference(lastWorkedOn!).inDays;
  }

  /// Calculate decayed health (call daily for active areas)
  double calculateDecayedHealth() {
    if (!isActiveFocus) return healthPercent;
    if (lastWorkedOn == null) return healthPercent;
    
    final decay = daysSinceWork * 10.0;
    return (healthPercent - decay).clamp(0.0, 100.0);
  }

  /// Log work done on this area
  void logWork() {
    lastWorkedOn = DateTime.now();
    healthPercent = (healthPercent + 20.0).clamp(0.0, 100.0);
    save();
  }

  /// Resurrect a dead area (costs coins)
  void resurrect() {
    healthPercent = 50.0;
    lastWorkedOn = DateTime.now();
    save();
  }

  /// Get human-readable type name
  String get typeName {
    switch (type) {
      case GrowthAreaType.knowledge:
        return 'Knowledge';
      case GrowthAreaType.skill:
        return 'Skill';
      case GrowthAreaType.attribute:
        return 'Attribute';
      case GrowthAreaType.process:
        return 'Process';
      case GrowthAreaType.resource:
        return 'Resource';
    }
  }
}

// Alias for backward compatibility during migration
typedef Factor = GrowthArea;
typedef FactorType = GrowthAreaType;
