import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../providers/app_state.dart';
import '../../models/task.dart';
import '../../models/category_model.dart';
import '../../models/habit_enums.dart';
import '../../widgets/growth_area_selector.dart';

/// Bottom sheet for editing an existing task
class EditTaskSheet extends StatefulWidget {
  final Task task;
  final VoidCallback? onTaskUpdated;

  const EditTaskSheet({super.key, required this.task, this.onTaskUpdated});

  /// Show the edit task sheet as a bottom sheet
  static Future<void> show(
    BuildContext context, {
    required Task task,
    VoidCallback? onTaskUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          EditTaskSheet(task: task, onTaskUpdated: onTaskUpdated),
    );
  }

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  String? _selectedCategoryId;
  late PriorityLevel _priority;
  late bool _isPending;
  TimeOfDay? _scheduledTime;
  late bool _hasChecklist;
  late List<String> _checklistItems;
  late List<bool> _checklistCompleted;
  final TextEditingController _checklistInputController =
      TextEditingController();
  late List<String> _linkedFactorIds;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _noteController = TextEditingController(text: widget.task.note ?? '');
    _selectedDate = widget.task.scheduledDate;
    _selectedCategoryId = widget.task.categoryId;
    _priority = widget.task.priorityLevel;
    _isPending = widget.task.isPending;

    // Parse scheduled time
    if (widget.task.scheduledTime != null) {
      final parts = widget.task.scheduledTime!.split(':');
      if (parts.length == 2) {
        _scheduledTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    _hasChecklist =
        widget.task.checklistItems != null &&
        widget.task.checklistItems!.isNotEmpty;
    _checklistItems = List<String>.from(widget.task.checklistItems ?? []);
    _checklistCompleted = List<bool>.from(widget.task.checklistCompleted ?? []);

    // Ensure checklistCompleted matches checklistItems length
    while (_checklistCompleted.length < _checklistItems.length) {
      _checklistCompleted.add(false);
    }

    _linkedFactorIds = List<String>.from(widget.task.linkedFactorIds);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _checklistInputController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a task name')));
      return;
    }

    // Update task fields
    widget.task.title = title;
    widget.task.note = _noteController.text.trim().isNotEmpty
        ? _noteController.text.trim()
        : null;
    widget.task.scheduledDate = _selectedDate;
    widget.task.categoryId = _selectedCategoryId;
    widget.task.priorityLevel = _priority;
    widget.task.isPriority = _priority == PriorityLevel.high;
    widget.task.isPending = _isPending;
    widget.task.scheduledTime = _scheduledTime != null
        ? '${_scheduledTime!.hour.toString().padLeft(2, '0')}:${_scheduledTime!.minute.toString().padLeft(2, '0')}'
        : null;
    widget.task.checklistItems = _hasChecklist && _checklistItems.isNotEmpty
        ? _checklistItems
        : null;
    widget.task.checklistCompleted =
        _hasChecklist && _checklistCompleted.isNotEmpty
        ? _checklistCompleted
        : null;
    widget.task.linkedFactorIds = _linkedFactorIds;

    final appState = context.read<AppState>();
    await appState.updateTask(widget.task);

    if (mounted) {
      widget.onTaskUpdated?.call();
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

  void _clearTime() {
    setState(() => _scheduledTime = null);
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
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
            Row(
              children: [
                Icon(Icons.edit_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Edit Task',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Task Name Input
            TextField(
              controller: _titleController,
              autofocus: false,
              style: TextStyle(color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Task name',
                hintStyle: TextStyle(color: textSecondary),
                prefixIcon: Icon(
                  widget.task.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.check_circle_outline_rounded,
                  color: widget.task.isCompleted ? Colors.green : textSecondary,
                ),
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
                    onLongPress: _scheduledTime != null ? _clearTime : null,
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

            // Notes
            TextField(
              controller: _noteController,
              style: TextStyle(color: textPrimary),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Add notes (optional)',
                hintStyle: TextStyle(color: textSecondary),
                prefixIcon: Icon(Icons.notes_rounded, color: textSecondary),
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
                      'Checklist',
                      style: TextStyle(color: textPrimary),
                    ),
                  ),
                  if (_checklistItems.isNotEmpty)
                    Text(
                      '${_checklistCompleted.where((c) => c).length}/${_checklistItems.length}',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  const SizedBox(width: 8),
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
                      Checkbox(
                        value: entry.key < _checklistCompleted.length
                            ? _checklistCompleted[entry.key]
                            : false,
                        onChanged: (v) {
                          setState(() {
                            while (_checklistCompleted.length <= entry.key) {
                              _checklistCompleted.add(false);
                            }
                            _checklistCompleted[entry.key] = v ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
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
                            style: TextStyle(
                              color:
                                  entry.key < _checklistCompleted.length &&
                                      _checklistCompleted[entry.key]
                                  ? textSecondary
                                  : textPrimary,
                              decoration:
                                  entry.key < _checklistCompleted.length &&
                                      _checklistCompleted[entry.key]
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _checklistItems.removeAt(entry.key);
                            if (entry.key < _checklistCompleted.length) {
                              _checklistCompleted.removeAt(entry.key);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              TextField(
                controller: _checklistInputController,
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
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add_rounded, color: AppColors.primary),
                    onPressed: () {
                      final value = _checklistInputController.text.trim();
                      if (value.isNotEmpty) {
                        setState(() {
                          _checklistItems.add(value);
                          _checklistCompleted.add(false);
                          _checklistInputController.clear();
                        });
                      }
                    },
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    setState(() {
                      _checklistItems.add(value.trim());
                      _checklistCompleted.add(false);
                      _checklistInputController.clear();
                    });
                  }
                },
              ),
            ],
            const SizedBox(height: 16),

            // Growth Area Selector (Dissected Trees)
            GrowthAreaSelector(
              selectedAreaIds: _linkedFactorIds,
              onSelectionChanged: (ids) =>
                  setState(() => _linkedFactorIds = ids),
              label: 'Link to Dissected Tree (Optional)',
            ),
            const SizedBox(height: 24),

            // Action Buttons Row
            Row(
              children: [
                // Delete Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delete_rounded, size: 20),
                    label: const Text('Delete'),
                  ),
                ),
                const SizedBox(width: 12),
                // Save Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.save_rounded, size: 20),
                    label: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text(
          'Are you sure you want to delete "${widget.task.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    // ignore: use_build_context_synchronously - mounted checked above
    final appState = Provider.of<AppState>(context, listen: false);
    final callback = widget.onTaskUpdated;
    await appState.deleteTask(widget.task.id);
    callback?.call();
    if (!mounted) return;
    // ignore: use_build_context_synchronously - mounted checked above
    Navigator.of(context).pop();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == tomorrow) return 'Tomorrow';
    if (dateOnly == yesterday) return 'Yesterday';

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
  final VoidCallback? onLongPress;
  final bool isActive;
  final Color? iconColor;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.onLongPress,
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
      onLongPress: onLongPress,
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
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                  color: isActive ? textPrimary : textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
