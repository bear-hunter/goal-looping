import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/theme.dart';
import '../providers/app_state.dart';

/// A reusable category selector widget with add and delete functionality
class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final bool showDeleteOnLongPress;
  final bool showAddButton;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    this.showDeleteOnLongPress = true,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...state.taskCategories.map(
                (cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: showDeleteOnLongPress
                      ? GestureDetector(
                          onLongPress: cat == 'General'
                              ? null
                              : () => _showDeleteDialog(context, state, cat),
                          child: _buildChip(context, cat),
                        )
                      : _buildChip(context, cat),
                ),
              ),
              if (showAddButton)
                ActionChip(
                  avatar: Icon(Icons.add, size: 16, color: AppColors.primary),
                  label: Text(
                    'New',
                    style: TextStyle(color: AppColors.primary),
                  ),
                  backgroundColor: AppColors.surfaceLight,
                  side: BorderSide(color: AppColors.primary.withAlpha(50)),
                  onPressed: () => _showAddCategoryDialog(context, state),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(BuildContext context, String category) {
    final isSelected = selectedCategory == category;
    return FilterChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (_) => onCategoryChanged(category),
      selectedColor: AppColors.primary.withAlpha(50),
      checkmarkColor: AppColors.primary,
      backgroundColor: AppColors.surfaceLight,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.glassBorder,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    AppState state,
    String category,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete Category',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Delete "$category"? Tasks with this category will be moved to "General".',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Move tasks to General before deleting
              for (final task in state.tasks.where(
                (t) => t.category == category,
              )) {
                task.category = 'General';
                state.updateTask(task);
              }
              state.deleteTaskCategory(category);
              if (selectedCategory == category) {
                onCategoryChanged('General');
              }
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, AppState state) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'New Category',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Category Name',
            filled: true,
            fillColor: AppColors.surfaceLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final newCategory = controller.text.trim();
                state.addTaskCategory(newCategory);
                onCategoryChanged(newCategory);
                Navigator.pop(ctx);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}

/// A simple choice chip styled for the app theme
class AppChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.primary.withAlpha(50),
      checkmarkColor: AppColors.primary,
      backgroundColor: AppColors.surfaceLight,
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.glassBorder,
      ),
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
