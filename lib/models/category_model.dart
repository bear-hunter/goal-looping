import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category_model.g.dart';

/// Id of the seeded default category used as a fallback for uncategorized items
/// (legacy tasks with no category, or items whose category was deleted).
const String kFallbackCategoryId = 'personal';

/// Category model for organizing habits, tasks, and recurring tasks
/// Supports custom icon and color for visual identification
@HiveType(typeId: 30)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int iconCodePoint; // Flutter IconData codePoint

  @HiveField(3)
  String iconFontFamily; // Font family for the icon (e.g., 'MaterialIcons')

  @HiveField(4)
  int colorValue; // Color stored as int

  @HiveField(5)
  bool isDefault; // Built-in category that cannot be deleted

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  int sortOrder; // For custom ordering

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    this.iconFontFamily = 'MaterialIcons',
    required this.colorValue,
    this.isDefault = false,
    DateTime? createdAt,
    this.sortOrder = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Get the IconData for this category.
  /// Resolves the stored codePoint to a const IconData (kept const for web icon
  /// tree-shaking). Falls back to a generic icon for unknown codePoints.
  IconData get icon =>
      _iconByCodePoint[iconCodePoint] ?? Icons.category_rounded;

  /// Lookup map built once from the canonical icon list.
  static final Map<int, IconData> _iconByCodePoint = {
    for (final i in DefaultCategories.availableIcons) i.codePoint: i,
  };

  /// Get the Color for this category
  Color get color => Color(colorValue);

  /// Create a CategoryModel from IconData and Color
  factory CategoryModel.create({
    required String id,
    required String name,
    required IconData icon,
    required Color color,
    bool isDefault = false,
    int sortOrder = 0,
  }) {
    return CategoryModel(
      id: id,
      name: name,
      iconCodePoint: icon.codePoint,
      iconFontFamily: icon.fontFamily ?? 'MaterialIcons',
      colorValue: color.toARGB32(),
      isDefault: isDefault,
      sortOrder: sortOrder,
    );
  }

  /// Copy with updated fields
  CategoryModel copyWith({
    String? name,
    IconData? icon,
    Color? color,
    int? sortOrder,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      iconCodePoint: icon?.codePoint ?? iconCodePoint,
      iconFontFamily: icon?.fontFamily ?? iconFontFamily,
      colorValue: color?.toARGB32() ?? colorValue,
      isDefault: isDefault,
      createdAt: createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// Default categories that come pre-installed
class DefaultCategories {
  static List<CategoryModel> get all => [
    CategoryModel.create(
      id: 'health',
      name: 'Health',
      icon: Icons.favorite_rounded,
      color: const Color(0xFFE91E63), // Pink
      isDefault: true,
      sortOrder: 0,
    ),
    CategoryModel.create(
      id: 'work',
      name: 'Work',
      icon: Icons.work_rounded,
      color: const Color(0xFF2196F3), // Blue
      isDefault: true,
      sortOrder: 1,
    ),
    CategoryModel.create(
      id: 'fitness',
      name: 'Fitness',
      icon: Icons.fitness_center_rounded,
      color: const Color(0xFFFF5722), // Deep Orange
      isDefault: true,
      sortOrder: 2,
    ),
    CategoryModel.create(
      id: 'learning',
      name: 'Learning',
      icon: Icons.school_rounded,
      color: const Color(0xFF9C27B0), // Purple
      isDefault: true,
      sortOrder: 3,
    ),
    CategoryModel.create(
      id: 'finance',
      name: 'Finance',
      icon: Icons.account_balance_wallet_rounded,
      color: const Color(0xFF4CAF50), // Green
      isDefault: true,
      sortOrder: 4,
    ),
    CategoryModel.create(
      id: 'social',
      name: 'Social',
      icon: Icons.people_rounded,
      color: const Color(0xFFFF9800), // Orange
      isDefault: true,
      sortOrder: 5,
    ),
    CategoryModel.create(
      id: 'mindfulness',
      name: 'Mindfulness',
      icon: Icons.self_improvement_rounded,
      color: const Color(0xFF00BCD4), // Cyan
      isDefault: true,
      sortOrder: 6,
    ),
    CategoryModel.create(
      id: 'personal',
      name: 'Personal',
      icon: Icons.person_rounded,
      color: const Color(0xFF607D8B), // Blue Grey
      isDefault: true,
      sortOrder: 7,
    ),
  ];

  /// Available icons for category creation
  static List<IconData> get availableIcons => [
    Icons.favorite_rounded,
    Icons.work_rounded,
    Icons.fitness_center_rounded,
    Icons.school_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.people_rounded,
    Icons.self_improvement_rounded,
    Icons.person_rounded,
    Icons.home_rounded,
    Icons.restaurant_rounded,
    Icons.directions_run_rounded,
    Icons.book_rounded,
    Icons.music_note_rounded,
    Icons.palette_rounded,
    Icons.code_rounded,
    Icons.camera_alt_rounded,
    Icons.shopping_cart_rounded,
    Icons.local_hospital_rounded,
    Icons.pets_rounded,
    Icons.eco_rounded,
    Icons.sports_esports_rounded,
    Icons.movie_rounded,
    Icons.flight_rounded,
    Icons.beach_access_rounded,
    Icons.bedtime_rounded,
    Icons.coffee_rounded,
    Icons.emoji_events_rounded,
    Icons.lightbulb_rounded,
    Icons.star_rounded,
    Icons.timer_rounded,
    // Merged from the legacy category editor list:
    Icons.bed_rounded,
    Icons.monetization_on_rounded,
    Icons.brush_rounded,
    Icons.local_cafe_rounded,
    Icons.language_rounded,
    Icons.psychology_rounded,
    Icons.travel_explore_rounded,
    Icons.task_alt_rounded,
    Icons.celebration_rounded,
    Icons.wb_sunny_rounded,
    // Generic fallback icon, also pickable:
    Icons.category_rounded,
  ];

  /// Available colors for category creation
  static List<Color> get availableColors => const [
    Color(0xFFE91E63), // Pink
    Color(0xFFF44336), // Red
    Color(0xFFFF5722), // Deep Orange
    Color(0xFFFF9800), // Orange
    Color(0xFFFFC107), // Amber
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF8BC34A), // Light Green
    Color(0xFF4CAF50), // Green
    Color(0xFF009688), // Teal
    Color(0xFF00BCD4), // Cyan
    Color(0xFF03A9F4), // Light Blue
    Color(0xFF2196F3), // Blue
    Color(0xFF3F51B5), // Indigo
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF9C27B0), // Purple
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF795548), // Brown
  ];
}
