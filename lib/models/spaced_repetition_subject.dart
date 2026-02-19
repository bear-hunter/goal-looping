import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'spaced_repetition_subject.g.dart';

/// Subject model for spaced repetition - primary category
/// Subjects contain topics that are scheduled for review
@HiveType(typeId: 31)
class SpacedRepetitionSubject extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int iconCodePoint;

  @HiveField(3)
  String iconFontFamily;

  @HiveField(4)
  int colorValue;

  @HiveField(5)
  int sortOrder;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  bool isExpanded; // UI state for collapsed/expanded

  SpacedRepetitionSubject({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    this.iconFontFamily = 'MaterialIcons',
    required this.colorValue,
    this.sortOrder = 0,
    DateTime? createdAt,
    this.isExpanded = true,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Get the IconData for this subject
  /// Uses a lookup to return const IconData for tree shaking support
  IconData get icon {
    for (final iconData in DefaultSubjects.availableIcons) {
      if (iconData.codePoint == iconCodePoint) {
        return iconData;
      }
    }
    return Icons.category_rounded; // fallback
  }

  /// Get the Color for this subject
  Color get color => Color(colorValue);

  /// Create a SpacedRepetitionSubject from IconData and Color
  factory SpacedRepetitionSubject.create({
    required String id,
    required String name,
    required IconData icon,
    required Color color,
    int sortOrder = 0,
  }) {
    return SpacedRepetitionSubject(
      id: id,
      name: name,
      iconCodePoint: icon.codePoint,
      iconFontFamily: icon.fontFamily ?? 'MaterialIcons',
      colorValue: color.toARGB32(),
      sortOrder: sortOrder,
    );
  }

  /// Copy with updated fields
  SpacedRepetitionSubject copyWith({
    String? name,
    IconData? icon,
    Color? color,
    int? sortOrder,
    bool? isExpanded,
  }) {
    return SpacedRepetitionSubject(
      id: id,
      name: name ?? this.name,
      iconCodePoint: icon?.codePoint ?? iconCodePoint,
      iconFontFamily: icon?.fontFamily ?? iconFontFamily,
      colorValue: color?.toARGB32() ?? colorValue,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

/// Default subjects for quick start
class DefaultSubjects {
  static List<SpacedRepetitionSubject> get all => [
    SpacedRepetitionSubject.create(
      id: 'languages',
      name: 'Languages',
      icon: Icons.translate_rounded,
      color: const Color(0xFF9C27B0),
      sortOrder: 0,
    ),
    SpacedRepetitionSubject.create(
      id: 'mathematics',
      name: 'Mathematics',
      icon: Icons.functions_rounded,
      color: const Color(0xFF2196F3),
      sortOrder: 1,
    ),
    SpacedRepetitionSubject.create(
      id: 'science',
      name: 'Science',
      icon: Icons.science_rounded,
      color: const Color(0xFF4CAF50),
      sortOrder: 2,
    ),
  ];

  /// Available icons for subject creation
  static List<IconData> get availableIcons => [
    Icons.translate_rounded,
    Icons.functions_rounded,
    Icons.science_rounded,
    Icons.history_edu_rounded,
    Icons.psychology_rounded,
    Icons.code_rounded,
    Icons.music_note_rounded,
    Icons.palette_rounded,
    Icons.architecture_rounded,
    Icons.biotech_rounded,
    Icons.calculate_rounded,
    Icons.auto_stories_rounded,
    Icons.language_rounded,
    Icons.schema_rounded,
    Icons.category_rounded,
  ];

  /// Available colors for subject creation
  static List<Color> get availableColors => const [
    Color(0xFFE91E63),
    Color(0xFFF44336),
    Color(0xFFFF5722),
    Color(0xFFFF9800),
    Color(0xFFFFC107),
    Color(0xFF8BC34A),
    Color(0xFF4CAF50),
    Color(0xFF009688),
    Color(0xFF00BCD4),
    Color(0xFF03A9F4),
    Color(0xFF2196F3),
    Color(0xFF3F51B5),
    Color(0xFF673AB7),
    Color(0xFF9C27B0),
    Color(0xFF607D8B),
  ];
}
