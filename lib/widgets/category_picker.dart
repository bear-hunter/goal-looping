import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/theme.dart';
import '../models/category_model.dart';
import '../providers/app_state.dart';
import '../screens/settings/category_wizard.dart';

/// Single-select category picker shared across task/habit creation flows.
///
/// Renders one [CategoryChip] per [AppState.categories] entry (icon + name
/// tinted by the category color). When [showNewButton] is set, a trailing
/// "+ New" chip opens [CategoryWizard] and auto-selects the created category.
class CategoryPicker extends StatelessWidget {
  /// Currently selected category id, or null when nothing is selected.
  final String? selectedCategoryId;

  /// Called with the new selection. Receives null when the user deselects
  /// (only possible when [allowDeselect] is true).
  final ValueChanged<String?> onChanged;

  /// Whether tapping the selected chip clears the selection.
  final bool allowDeselect;

  /// Whether to show the trailing "+ New" chip that opens [CategoryWizard].
  final bool showNewButton;

  /// When true, lay chips out in a [Wrap]; otherwise a horizontal scroll row.
  final bool wrap;

  /// When set, the category with this id is omitted from the chip list.
  final String? excludeCategoryId;

  const CategoryPicker({
    super.key,
    required this.selectedCategoryId,
    required this.onChanged,
    this.allowDeselect = true,
    this.showNewButton = true,
    this.wrap = false,
    this.excludeCategoryId,
  });

  void _handleTap(String id) {
    if (selectedCategoryId == id) {
      if (allowDeselect) onChanged(null);
    } else {
      onChanged(id);
    }
  }

  Future<void> _createNew(BuildContext context) async {
    final created = await CategoryWizard.show(context);
    if (created != null) onChanged(created.id);
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<AppState>().categories;

    final chips = <Widget>[
      for (final category in categories)
        if (category.id != excludeCategoryId)
          CategoryChip(
            category: category,
            isSelected: selectedCategoryId == category.id,
            onTap: () => _handleTap(category.id),
          ),
      if (showNewButton) _NewCategoryChip(onTap: () => _createNew(context)),
    ];

    if (wrap) {
      return Wrap(spacing: 8, runSpacing: 8, children: chips);
    }

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) => chips[index],
      ),
    );
  }
}

/// Selectable chip showing a category's icon + name, tinted by its color.
class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = category.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(50) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : colors.textMuted.withAlpha(100),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 16,
              color: isSelected ? color : colors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Trailing chip that opens [CategoryWizard] to create a new category.
class _NewCategoryChip extends StatelessWidget {
  final VoidCallback onTap;

  const _NewCategoryChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.primary.withAlpha(120)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 16, color: colors.primary),
            const SizedBox(width: 6),
            Text(
              'New',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
