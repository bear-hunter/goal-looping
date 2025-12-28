import 'package:hive/hive.dart';

part 'factor.g.dart';

/// Type of factor for goal dissection
@HiveType(typeId: 10)
enum FactorType {
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

/// Factor - Goal dissection element (Knowledge, Skills, Attributes, etc.)
/// These serve as master tags for tasks and reflections
@HiveType(typeId: 1)
class Factor extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  FactorType type;

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

  Factor({
    required this.id,
    required this.name,
    required this.type,
    this.targetLevel = 7,
    this.currentLevel = 3,
    this.description = '',
    required this.goalId,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// Calculate the gap between target and current level
  int get gap => targetLevel - currentLevel;

  /// Get a percentage of progress (current / target)
  double get progressPercent => 
      targetLevel > 0 ? (currentLevel / targetLevel).clamp(0.0, 1.0) : 0.0;

  /// Check if this factor is the biggest gap (for focus suggestion)
  bool get needsFocus => gap > 3;

  /// Get human-readable type name
  String get typeName {
    switch (type) {
      case FactorType.knowledge:
        return 'Knowledge';
      case FactorType.skill:
        return 'Skill';
      case FactorType.attribute:
        return 'Attribute';
      case FactorType.process:
        return 'Process';
      case FactorType.resource:
        return 'Resource';
    }
  }
}
