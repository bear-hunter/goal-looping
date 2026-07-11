import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/category_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/category_picker.dart';
import '../../widgets/glass_card.dart';
import 'category_wizard.dart';

/// Screen for managing task/habit categories.
///
/// Operates entirely on [CategoryModel]: each row edits icon, color and name
/// through [CategoryWizard]. Default categories are editable but not deletable;
/// deleting a category that is still in use first reassigns its items.
class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Manage Categories',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          final categories = state.categories;
          return Column(
            children: [
              // Info banner
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassCard(
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: colors.info,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tap a category to change its icon, color or name. '
                          'Drag to reorder. Default categories can\'t be '
                          'deleted.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Category list
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    final reordered = List<CategoryModel>.from(categories);
                    final item = reordered.removeAt(oldIndex);
                    reordered.insert(newIndex, item);
                    state.reorderCategories(reordered);
                  },
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return KeyedSubtree(
                      key: ValueKey(category.id),
                      child:
                          _CategoryTile(
                                category: category,
                                index: index,
                                usageCount: state.categoryUsageCount(
                                  category.id,
                                ),
                                onEdit: () => CategoryWizard.show(
                                  context,
                                  category: category,
                                ),
                                onDelete: () => _deleteCategory(
                                  context,
                                  state,
                                  category,
                                ),
                              )
                              .animate(delay: (index * 50).ms)
                              .fadeIn(duration: 300.ms)
                              .slideX(begin: 0.1, end: 0),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CategoryWizard.show(context),
        backgroundColor: colors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Category'),
      ),
    );
  }

  void _deleteCategory(
    BuildContext context,
    AppState state,
    CategoryModel category,
  ) {
    final colors = context.colors;
    final usage = state.categoryUsageCount(category.id);

    if (usage == 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            'Delete Category',
            style: TextStyle(color: colors.textPrimary),
          ),
          content: Text(
            'Delete "${category.name}"? Nothing is using it.',
            style: TextStyle(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: colors.textMuted)),
            ),
            TextButton(
              onPressed: () {
                state.deleteCategory(category.id);
                Navigator.pop(ctx);
              },
              child: Text('Delete', style: TextStyle(color: colors.danger)),
            ),
          ],
        ),
      );
      return;
    }

    // In use: require a reassignment target before deleting.
    showDialog(
      context: context,
      builder: (ctx) => _ReassignDeleteDialog(category: category, usage: usage),
    );
  }
}

/// A single category row: color swatch, name, default pill, usage subtitle.
class _CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final int index;
  final int usageCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryTile({
    required this.category,
    required this.index,
    required this.usageCount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      onTap: onEdit,
      child: Row(
        children: [
          // Drag handle
          ReorderableDragStartListener(
            index: index,
            child: Icon(Icons.drag_handle_rounded, color: colors.textMuted),
          ),
          const SizedBox(width: 12),

          // Icon + color swatch
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(category.icon, color: category.color, size: 22),
          ),
          const SizedBox(width: 12),

          // Name + usage
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        category.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (category.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.textMuted.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Default',
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$usageCount item${usageCount == 1 ? '' : 's'}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),

          // Actions
          IconButton(
            icon: Icon(Icons.edit_rounded, size: 20, color: colors.textMuted),
            onPressed: onEdit,
            tooltip: 'Edit',
          ),
          if (!category.isDefault)
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: colors.danger,
              ),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
        ],
      ),
    );
  }
}

/// Delete dialog for a category still in use: forces picking a category to
/// move its tasks, habits and recurring tasks to before deletion.
class _ReassignDeleteDialog extends StatefulWidget {
  final CategoryModel category;
  final int usage;

  const _ReassignDeleteDialog({required this.category, required this.usage});

  @override
  State<_ReassignDeleteDialog> createState() => _ReassignDeleteDialogState();
}

class _ReassignDeleteDialogState extends State<_ReassignDeleteDialog> {
  String? _targetId;
  bool _deleting = false;

  Future<void> _confirm() async {
    final target = _targetId;
    if (target == null || _deleting) return;
    setState(() => _deleting = true);
    final state = context.read<AppState>();
    await state.reassignCategory(widget.category.id, target);
    await state.deleteCategory(widget.category.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = widget.usage;
    return AlertDialog(
      backgroundColor: colors.surface,
      title: Text(
        'Delete Category',
        style: TextStyle(color: colors.textPrimary),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count item${count == 1 ? '' : 's'} use "${widget.category.name}". '
              'Pick a category to move ${count == 1 ? 'it' : 'them'} to:',
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            CategoryPicker(
              selectedCategoryId: _targetId,
              onChanged: (id) => setState(() => _targetId = id),
              allowDeselect: false,
              showNewButton: false,
              wrap: true,
              excludeCategoryId: widget.category.id,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _deleting ? null : () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: colors.textMuted)),
        ),
        TextButton(
          onPressed: (_targetId == null || _deleting) ? null : _confirm,
          child: Text(
            'Move & Delete',
            style: TextStyle(
              color: (_targetId == null || _deleting)
                  ? colors.textMuted
                  : colors.danger,
            ),
          ),
        ),
      ],
    );
  }
}
