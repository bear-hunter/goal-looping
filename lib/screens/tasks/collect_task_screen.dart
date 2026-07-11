import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/theme.dart';
import '../../models/task.dart';
import '../../providers/app_state.dart';
import '../../widgets/category_picker.dart';

/// Task collection screen - Quickly capture tasks with optional categorization
/// Japanese minimalist aesthetic: focused, efficient, minimal friction
class CollectTaskScreen extends StatefulWidget {
  const CollectTaskScreen({super.key});

  @override
  State<CollectTaskScreen> createState() => _CollectTaskScreenState();
}

class _CollectTaskScreenState extends State<CollectTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocus = FocusNode();

  EisenhowerQuadrant _selectedQuadrant =
      EisenhowerQuadrant.focus; // Default to Focus
  final List<String> _selectedFactorIds = [];
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Auto-focus title field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close_rounded, color: colors.textPrimary),
            ),
            title: Text(
              'Collect Task',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              TextButton(
                onPressed: _saveTask,
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title field
                TextField(
                  controller: _titleController,
                  focusNode: _titleFocus,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'What needs to be done?',
                    hintStyle: TextStyle(color: colors.textMuted),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(color: colors.glassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(color: colors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                ).animate().fadeIn(duration: 200.ms),

                const SizedBox(height: 12),

                // Description field (optional)
                TextField(
                  controller: _descriptionController,
                  style: TextStyle(color: colors.textPrimary, fontSize: 14),
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Notes (optional)',
                    hintStyle: TextStyle(color: colors.textMuted),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(color: colors.glassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(color: colors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ).animate().fadeIn(duration: 200.ms, delay: 50.ms),

                const SizedBox(height: 20),

                // Decision helper
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: colors.glassBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick categorize:',
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '"What happens if I don\'t do this today?"',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '→ Major consequences = Urgent',
                        style: TextStyle(color: colors.danger, fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '"What happens if I never do this?"',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '→ Derails goals = Important',
                        style: TextStyle(color: colors.primary, fontSize: 11),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 200.ms, delay: 100.ms),

                const SizedBox(height: 16),

                // Quadrant selection (Prioritization)
                Text(
                  'Prioritization',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuadrantChip(
                      colors: colors,
                      label: 'Inbox',
                      icon: Icons.inbox_rounded,
                      color: colors.textMuted,
                      isSelected: _selectedQuadrant == EisenhowerQuadrant.inbox,
                      onTap: () => setState(
                        () => _selectedQuadrant = EisenhowerQuadrant.inbox,
                      ),
                    ),
                    _QuadrantChip(
                      colors: colors,
                      label: 'Focus',
                      icon: Icons.local_fire_department_rounded,
                      color: colors.danger,
                      isSelected: _selectedQuadrant == EisenhowerQuadrant.focus,
                      onTap: () => setState(
                        () => _selectedQuadrant = EisenhowerQuadrant.focus,
                      ),
                    ),
                    _QuadrantChip(
                      colors: colors,
                      label: 'Schedule',
                      icon: Icons.calendar_today_rounded,
                      color: colors.primary,
                      isSelected:
                          _selectedQuadrant == EisenhowerQuadrant.schedule,
                      onTap: () => setState(
                        () => _selectedQuadrant = EisenhowerQuadrant.schedule,
                      ),
                    ),
                    _QuadrantChip(
                      colors: colors,
                      label: 'Branch',
                      icon: Icons.call_split_rounded,
                      color: colors.warning,
                      isSelected:
                          _selectedQuadrant == EisenhowerQuadrant.branch,
                      onTap: () => setState(
                        () => _selectedQuadrant = EisenhowerQuadrant.branch,
                      ),
                    ),
                    _QuadrantChip(
                      colors: colors,
                      label: 'Delete',
                      icon: Icons.delete_outline_rounded,
                      color: colors.textMuted,
                      isSelected:
                          _selectedQuadrant == EisenhowerQuadrant.delete,
                      onTap: () => setState(
                        () => _selectedQuadrant = EisenhowerQuadrant.delete,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 200.ms, delay: 150.ms),

                const SizedBox(height: 20),

                // Factor linking
                Text(
                  'Link to Factor (optional)',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.factors.length,
                    itemBuilder: (context, index) {
                      final factor = state.factors[index];
                      final isSelected = _selectedFactorIds.contains(factor.id);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedFactorIds.remove(factor.id);
                              } else {
                                _selectedFactorIds.add(factor.id);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primary.withAlpha(30)
                                  : colors.surfaceLight,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: isSelected
                                    ? colors.primary.withAlpha(100)
                                    : colors.glassBorder,
                              ),
                            ),
                            child: Text(
                              factor.name,
                              style: TextStyle(
                                color: isSelected
                                    ? colors.primary
                                    : colors.textSecondary,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ).animate().fadeIn(duration: 200.ms, delay: 200.ms),

                const SizedBox(height: 20),

                // Category selection
                Text(
                  'Category',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                CategoryPicker(
                  selectedCategoryId: _selectedCategoryId,
                  onChanged: (id) => setState(() => _selectedCategoryId = id),
                ).animate().fadeIn(duration: 200.ms, delay: 250.ms),

                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveTask,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ).animate().fadeIn(duration: 200.ms, delay: 250.ms),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    final state = context.read<AppState>();
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      description: _descriptionController.text.trim(),
      quadrant: _selectedQuadrant,
      linkedFactorIds: _selectedFactorIds,
      categoryId: _selectedCategoryId,
      scheduledDate: DateTime.now(),
    );

    state.addTask(task);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedQuadrant == EisenhowerQuadrant.inbox
              ? 'Task added to Inbox'
              : 'Task added to ${_selectedQuadrant.name.capitalize()}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _QuadrantChip extends StatelessWidget {
  final AppColorsTheme colors;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuadrantChip({
    required this.colors,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(30) : colors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? color.withAlpha(100) : colors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? color : colors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : colors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to capitalize first letter
extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
