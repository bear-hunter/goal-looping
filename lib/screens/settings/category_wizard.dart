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

  static Future<CategoryModel?> show(
    BuildContext context, {
    CategoryModel? category,
  }) {
    return showModalBottomSheet<CategoryModel>(
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
    final CategoryModel result;

    if (isEditing) {
      result = widget.category!.copyWith(
        name: name,
        icon: _selectedIcon,
        color: _selectedColor,
      );
      await appState.updateCategory(result);
    } else {
      result = CategoryModel.create(
        id: const Uuid().v4(),
        name: name,
        icon: _selectedIcon,
        color: _selectedColor,
        sortOrder: appState.categories.length,
      );
      await appState.addCategory(result);
    }

    if (mounted) Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bgColor = colors.surface;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;
    final icons = DefaultCategories.availableIcons;
    final palette = DefaultCategories.availableColors;

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
                fillColor: colors.surfaceLight,
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
                itemCount: icons.length,
                itemBuilder: (context, index) {
                  final icon = icons[index];
                  final isSelected = icon == _selectedIcon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withAlpha(30)
                            : colors.surfaceLight,
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
              children: palette.map((color) {
                final isSelected = color.toARGB32() == _selectedColor.toARGB32();
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
