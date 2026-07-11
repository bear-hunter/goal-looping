import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/theme.dart';
import '../../providers/app_state.dart';
import '../../models/task.dart';
import '../../models/habit_enums.dart';
import '../../widgets/category_picker.dart';
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
  final _checklistInputController = TextEditingController();
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
    _checklistInputController.dispose();
    super.dispose();
  }

  void _commitChecklistDraft() {
    final value = _checklistInputController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _checklistItems.add(value);
      _checklistInputController.clear();
    });
  }

  Future<void> _createTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a task name')));
      return;
    }

    final appState = context.read<AppState>();
    if (_priority == PriorityLevel.high && !appState.canAddPriorityTask) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You already have two active High-priority tasks. Complete or lower one first.',
          ),
        ),
      );
      return;
    }

    if (_hasChecklist) _commitChecklistDraft();
    final scheduledTime = _scheduledTime != null
        ? '${_scheduledTime!.hour.toString().padLeft(2, '0')}:${_scheduledTime!.minute.toString().padLeft(2, '0')}'
        : null;

    final task = Task(
      id: const Uuid().v4(),
      title: title,
      createdAt: DateTime.now(),
      source: TaskSource.newEntry,
      isPriority: _priority == PriorityLevel.high,
      categoryId: _selectedCategoryId,
      scheduledDate: _selectedDate,
      scheduledTime: scheduledTime,
      reminderTimes: scheduledTime == null ? const [] : [scheduledTime],
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

    try {
      await appState.addTask(task);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not create the task. Please try again.'),
          ),
        );
      }
      return;
    }

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
    final colors = context.colors;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;
    final bgColor = colors.surface;

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
                fillColor: colors.surfaceLight,
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
            CategoryPicker(
              selectedCategoryId: _selectedCategoryId,
              onChanged: (id) => setState(() => _selectedCategoryId = id),
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
                    iconColor: _getPriorityColor(context, _priority),
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
                fillColor: colors.surfaceLight,
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
                color: colors.surfaceLight,
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
                    activeTrackColor: colors.primary,
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
                            color: colors.surfaceLight,
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
                controller: _checklistInputController,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Add item...',
                  hintStyle: TextStyle(color: textSecondary),
                  filled: true,
                  fillColor: colors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  suffixIcon: IconButton(
                    onPressed: _commitChecklistDraft,
                    icon: Icon(Icons.add_rounded, color: colors.primary),
                  ),
                ),
                onSubmitted: (_) => _commitChecklistDraft(),
              ),
            ],
            const SizedBox(height: 24),

            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
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

  Color _getPriorityColor(BuildContext context, PriorityLevel priority) {
    final colors = context.colors;
    switch (priority) {
      case PriorityLevel.high:
        return colors.danger;
      case PriorityLevel.medium:
        return colors.warning;
      case PriorityLevel.low:
        return colors.info;
      case PriorityLevel.none:
        return colors.textMuted;
    }
  }

  void _showPriorityPicker() {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
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
                  color: _getPriorityColor(context, priority),
                ),
                title: Text(priority.label),
                trailing: _priority == priority
                    ? Icon(Icons.check_rounded, color: colors.primary)
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
    final colors = context.colors;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? colors.primary.withAlpha(20) : colors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: isActive
              ? Border.all(color: colors.primary.withAlpha(100), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor ?? (isActive ? colors.primary : textSecondary),
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
