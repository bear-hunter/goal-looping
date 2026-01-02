import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/theme.dart';
import '../../providers/app_state.dart';
import '../../models/task.dart';
import '../../models/category_model.dart';
import '../../models/habit_enums.dart';
import '../../widgets/growth_area_selector.dart';

/// Bottom sheet for quick task creation
class AddTaskSheet extends StatefulWidget {
  final DateTime initialDate;
  final VoidCallback? onTaskAdded;

  const AddTaskSheet({super.key, required this.initialDate, this.onTaskAdded});

  /// Show the add task sheet as a bottom sheet
  static Future<void> show(
    BuildContext context, {
    required DateTime initialDate,
    VoidCallback? onTaskAdded,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AddTaskSheet(initialDate: initialDate, onTaskAdded: onTaskAdded),
    );
  }

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _selectedDate;
  String? _selectedCategoryId;
  PriorityLevel _priority = PriorityLevel.none;
  bool _isPending = false;
  TimeOfDay? _scheduledTime;
  bool _hasChecklist = false;
  final List<String> _checklistItems = [];
  List<String> _linkedFactorIds = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _createTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a task name')));
      return;
    }

    final task = Task(
      id: const Uuid().v4(),
      title: title,
      createdAt: DateTime.now(),
      source: TaskSource.newEntry,
      isPriority: _priority == PriorityLevel.high,
      categoryId: _selectedCategoryId,
      scheduledDate: _selectedDate,
      scheduledTime: _scheduledTime != null
          ? '${_scheduledTime!.hour.toString().padLeft(2, '0')}:${_scheduledTime!.minute.toString().padLeft(2, '0')}'
          : null,
      priorityLevel: _priority,
      isPending: _isPending,
      note: _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : null,
      checklistItems: _hasChecklist && _checklistItems.isNotEmpty
          ? _checklistItems
          : null,
      linkedFactorIds: _linkedFactorIds,
    );

    final appState = context.read<AppState>();
    await appState.addTask(task);

    if (mounted) {
      widget.onTaskAdded?.call();
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _scheduledTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;
    final bgColor = isDark ? AppColors.surface : LightColors.surface;

    final categories = context.watch<AppState>().categories;

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
              'New Task',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Task Name Input
            TextField(
              controller: _titleController,
              autofocus: true,
              style: TextStyle(color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Task name',
                hintStyle: TextStyle(color: textSecondary),
                prefixIcon: Icon(
                  Icons.check_circle_outline_rounded,
                  color: textSecondary,
                ),
                filled: true,
                fillColor: (isDark
                    ? AppColors.surfaceLight
                    : LightColors.surfaceLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _createTask(),
            ),
            const SizedBox(height: 16),

            // Category Selection
            Text(
              'Category',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategoryId == category.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CategoryChip(
                      category: category,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = isSelected ? null : category.id;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Date & Time Row
            Row(
              children: [
                Expanded(
                  child: _OptionTile(
                    icon: Icons.calendar_today_rounded,
                    label: _formatDate(_selectedDate),
                    onTap: _selectDate,
                    isActive: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OptionTile(
                    icon: Icons.access_time_rounded,
                    label: _scheduledTime != null
                        ? _scheduledTime!.format(context)
                        : 'Add time',
                    onTap: _selectTime,
                    isActive: _scheduledTime != null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Priority Selection Row
            Row(
              children: [
                Expanded(
                  child: _OptionTile(
                    icon: Icons.flag_rounded,
                    label: _priority.label,
                    iconColor: _getPriorityColor(_priority),
                    onTap: _showPriorityPicker,
                    isActive: _priority != PriorityLevel.none,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OptionTile(
                    icon: _isPending
                        ? Icons.pause_circle_rounded
                        : Icons.play_circle_outline_rounded,
                    label: _isPending ? 'Pending' : 'Active',
                    onTap: () => setState(() => _isPending = !_isPending),
                    isActive: _isPending,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Growth Area Selector (Dissected Trees)
            GrowthAreaSelector(
              selectedAreaIds: _linkedFactorIds,
              onSelectionChanged: (ids) =>
                  setState(() => _linkedFactorIds = ids),
              label: 'Link to Dissected Tree (Optional)',
            ),
            const SizedBox(height: 16),

            // Notes (optional)
            TextField(
              controller: _noteController,
              style: TextStyle(color: textPrimary),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Add notes (optional)',
                hintStyle: TextStyle(color: textSecondary),
                prefixIcon: Icon(Icons.notes_rounded, color: textSecondary),
                filled: true,
                fillColor: (isDark
                    ? AppColors.surfaceLight
                    : LightColors.surfaceLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Checklist Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceLight
                    : LightColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.checklist_rounded, color: textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add checklist',
                      style: TextStyle(color: textPrimary),
                    ),
                  ),
                  Switch(
                    value: _hasChecklist,
                    onChanged: (v) => setState(() => _hasChecklist = v),
                    activeTrackColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            // Checklist Items (if enabled)
            if (_hasChecklist) ...[
              const SizedBox(height: 8),
              ..._checklistItems.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceLight
                                : LightColors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            entry.value,
                            style: TextStyle(color: textPrimary),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: textSecondary,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _checklistItems.removeAt(entry.key)),
                      ),
                    ],
                  ),
                ),
              ),
              TextField(
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Add item...',
                  hintStyle: TextStyle(color: textSecondary),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.surfaceLight
                      : LightColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  suffixIcon: Icon(Icons.add_rounded, color: AppColors.primary),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    setState(() => _checklistItems.add(value.trim()));
                  }
                },
              ),
            ],
            const SizedBox(height: 24),

            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Create Task',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == tomorrow) return 'Tomorrow';

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  Color _getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.high:
        return Colors.red;
      case PriorityLevel.medium:
        return Colors.orange;
      case PriorityLevel.low:
        return Colors.blue;
      case PriorityLevel.none:
        return Colors.grey;
    }
  }

  void _showPriorityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surface
          : LightColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Priority',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...PriorityLevel.values.map(
              (priority) => ListTile(
                leading: Icon(
                  Icons.flag_rounded,
                  color: _getPriorityColor(priority),
                ),
                title: Text(priority.label),
                trailing: _priority == priority
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _priority = priority);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category selection chip
class _CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(50) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withAlpha(100),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 16,
              color: isSelected ? color : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Option tile for date, time, priority, etc.
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final Color? iconColor;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withAlpha(20)
              : (isDark ? AppColors.surfaceLight : LightColors.surfaceLight),
          borderRadius: BorderRadius.circular(10),
          border: isActive
              ? Border.all(color: AppColors.primary.withAlpha(100), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color:
                  iconColor ?? (isActive ? AppColors.primary : textSecondary),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                color: isActive ? textPrimary : textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
