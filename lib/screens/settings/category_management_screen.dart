import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/theme.dart';
import '../../models/category_model.dart';
import '../../providers/app_state.dart';
import '../../widgets/glass_card.dart';

/// Screen for managing task categories
class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Long-press to edit. The "General" category cannot be deleted.',
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
                  itemCount: state.taskCategories.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    final categories = List<String>.from(state.taskCategories);
                    final item = categories.removeAt(oldIndex);
                    categories.insert(newIndex, item);
                    state.reorderTaskCategories(categories);
                  },
                  itemBuilder: (context, index) {
                    final category = state.taskCategories[index];
                    final isProtected = category == 'General';
                    final taskCount = state.tasks
                        .where((t) => t.category == category)
                        .length;

                    return KeyedSubtree(
                      key: ValueKey(category),
                      child:
                          _CategoryTile(
                                category: category,
                                taskCount: taskCount,
                                isProtected: isProtected,
                                onEdit: () => _showEditCategoryDialog(
                                  context,
                                  state,
                                  category,
                                ),
                                onDelete: () => _showDeleteCategoryDialog(
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
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Category'),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    final state = context.read<AppState>();

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
            child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final name = controller.text.trim();
                state.addTaskCategory(name);
                // Also add to CategoryModel system so it appears in New Task sheet
                final categoryModel = CategoryModel.create(
                  id: const Uuid().v4(),
                  name: name,
                  icon: Icons.category_rounded,
                  color: Colors.blue,
                );
                state.addCategory(categoryModel);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(
    BuildContext context,
    AppState state,
    String oldCategory,
  ) {
    if (oldCategory == 'General') return;

    final controller = TextEditingController(text: oldCategory);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Rename Category',
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
            child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != oldCategory) {
                // Update all tasks with old category
                for (final task in state.tasks.where(
                  (t) => t.category == oldCategory,
                )) {
                  task.category = newName;
                  state.updateTask(task);
                }
                // Replace the category in legacy system
                state.renameTaskCategory(oldCategory, newName);
                // Also update matching CategoryModel
                final matchingCategory = state.categories
                    .where(
                      (c) => c.name.toLowerCase() == oldCategory.toLowerCase(),
                    )
                    .firstOrNull;
                if (matchingCategory != null) {
                  state.updateCategory(
                    matchingCategory.copyWith(name: newName),
                  );
                }
                Navigator.pop(ctx);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(
    BuildContext context,
    AppState state,
    String category,
  ) {
    if (category == 'General') return;

    final taskCount = state.tasks.where((t) => t.category == category).length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete Category',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delete "$category"?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            if (taskCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$taskCount task${taskCount == 1 ? '' : 's'} will be moved to "General"',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
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
              // Also delete matching CategoryModel
              final matchingCategory = state.categories
                  .where((c) => c.name.toLowerCase() == category.toLowerCase())
                  .firstOrNull;
              if (matchingCategory != null && !matchingCategory.isDefault) {
                state.deleteCategory(matchingCategory.id);
              }
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String category;
  final int taskCount;
  final bool isProtected;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryTile({
    required this.category,
    required this.taskCount,
    required this.isProtected,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: isProtected ? null : onEdit,
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: 8),
        onTap: isProtected ? null : onEdit,
        child: Row(
          children: [
            // Drag handle
            ReorderableDragStartListener(
              index: 0,
              child: Icon(
                Icons.drag_handle_rounded,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 12),

            // Category name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        category,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (isProtected) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textMuted.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Default',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$taskCount task${taskCount == 1 ? '' : 's'}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),

            // Actions
            if (!isProtected) ...[
              IconButton(
                icon: Icon(
                  Icons.edit_rounded,
                  size: 20,
                  color: AppColors.textMuted,
                ),
                onPressed: onEdit,
                tooltip: 'Rename',
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.danger,
                ),
                onPressed: onDelete,
                tooltip: 'Delete',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
