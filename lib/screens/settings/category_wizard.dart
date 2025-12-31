import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/theme.dart';
import '../../providers/app_state.dart';
import '../../models/category_model.dart';

/// Bottom sheet for creating or editing a category
class CategoryWizard extends StatefulWidget {
  final CategoryModel? category; // If editing

  const CategoryWizard({super.key, this.category});

  static Future<void> show(BuildContext context, {CategoryModel? category}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryWizard(category: category),
    );
  }

  @override
  State<CategoryWizard> createState() => _CategoryWizardState();
}

class _CategoryWizardState extends State<CategoryWizard> {
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.category_rounded;
  Color _selectedColor = const Color(0xFF2196F3); // Blue default

  bool get isEditing => widget.category != null;

  // Available icons
  static const List<IconData> _availableIcons = [
    Icons.favorite_rounded,
    Icons.fitness_center_rounded,
    Icons.restaurant_rounded,
    Icons.bed_rounded,
    Icons.work_rounded,
    Icons.school_rounded,
    Icons.monetization_on_rounded,
    Icons.people_rounded,
    Icons.brush_rounded,
    Icons.music_note_rounded,
    Icons.sports_esports_rounded,
    Icons.directions_run_rounded,
    Icons.local_cafe_rounded,
    Icons.book_rounded,
    Icons.code_rounded,
    Icons.language_rounded,
    Icons.psychology_rounded,
    Icons.self_improvement_rounded,
    Icons.eco_rounded,
    Icons.home_rounded,
    Icons.pets_rounded,
    Icons.travel_explore_rounded,
    Icons.camera_alt_rounded,
    Icons.star_rounded,
    Icons.task_alt_rounded,
    Icons.lightbulb_rounded,
    Icons.timer_rounded,
    Icons.celebration_rounded,
    Icons.emoji_events_rounded,
    Icons.wb_sunny_rounded,
  ];

  // Available colors
  static const List<Color> _availableColors = [
    Color(0xFFE91E63), // Pink
    Color(0xFFF44336), // Red
    Color(0xFFFF9800), // Orange
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF4CAF50), // Green
    Color(0xFF009688), // Teal
    Color(0xFF2196F3), // Blue
    Color(0xFF3F51B5), // Indigo
    Color(0xFF9C27B0), // Purple
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF00BCD4), // Cyan
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    final appState = context.read<AppState>();

    if (isEditing) {
      final updated = widget.category!.copyWith(
        name: name,
        icon: _selectedIcon,
        color: _selectedColor,
      );
      await appState.updateCategory(updated);
    } else {
      final category = CategoryModel.create(
        id: const Uuid().v4(),
        name: name,
        icon: _selectedIcon,
        color: _selectedColor,
      );
      await appState.addCategory(category);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surface : LightColors.surface;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textSecondary.withAlpha(100),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              isEditing ? 'Edit Category' : 'New Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Preview
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _selectedColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _selectedColor, width: 2),
                ),
                child: Icon(_selectedIcon, color: _selectedColor, size: 40),
              ),
            ),
            const SizedBox(height: 20),

            // Name input
            TextField(
              controller: _nameController,
              autofocus: true,
              style: TextStyle(color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Category name',
                hintStyle: TextStyle(color: textSecondary),
                filled: true,
                fillColor: isDark
                    ? AppColors.surfaceLight
                    : LightColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Icon picker
            Text(
              'Icon',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final icon = _availableIcons[index];
                  final isSelected = icon == _selectedIcon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withAlpha(30)
                            : (isDark
                                  ? AppColors.surfaceLight
                                  : LightColors.surfaceLight),
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(color: _selectedColor, width: 2)
                            : null,
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? _selectedColor : textSecondary,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Color picker
            Text(
              'Color',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((color) {
                final isSelected = color.value == _selectedColor.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: textPrimary, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Create Category',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0);
  }
}
