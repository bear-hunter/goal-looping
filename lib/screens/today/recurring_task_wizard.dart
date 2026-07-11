import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/theme.dart';
import '../../providers/app_state.dart';
import '../../services/notification_service.dart';
import '../../models/recurring_task.dart';
import '../../models/habit_enums.dart';
import '../../widgets/category_picker.dart';
import '../../widgets/growth_area_selector.dart';

/// Multi-page wizard for creating a recurring task
class RecurringTaskWizard extends StatefulWidget {
  final VoidCallback? onComplete;
  final RecurringTask? existingTask;

  const RecurringTaskWizard({super.key, this.onComplete, this.existingTask});

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onComplete,
    RecurringTask? existingTask,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => RecurringTaskWizard(
          onComplete: onComplete,
          existingTask: existingTask,
        ),
      ),
    );
  }

  @override
  State<RecurringTaskWizard> createState() => _RecurringTaskWizardState();
}

class _RecurringTaskWizardState extends State<RecurringTaskWizard> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Wizard data
  String _taskName = '';
  String? _selectedCategoryId;
  HabitEvaluationType _evaluationType = HabitEvaluationType.yesNo;
  HabitFrequencyType _frequencyType = HabitFrequencyType.everyday;
  List<int> _scheduledDays = [1, 2, 3, 4, 5, 6, 7];
  int _repeatInterval = 2; // For repeatEvery (every N days)
  int _daysPerPeriod = 3; // For someDaysPerPeriod (X days per week)
  List<DateTime> _specificDates = []; // For specificDatesOfYear
  final List<String> _checklistItems = [];
  PriorityLevel _priority = PriorityLevel.none;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  final List<TimeOfDay> _reminderTimes = [];
  String _description = '';
  List<String> _linkedFactorIds = [];

  static const int _totalPages = 4; // Simpler than habit wizard

  bool get _supportsDeviceReminderSchedule =>
      (_frequencyType == HabitFrequencyType.everyday ||
          _frequencyType == HabitFrequencyType.specificDays) &&
      _endDate == null;

  bool get _isEditMode => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTask;
    if (existing != null) {
      _taskName = existing.name;
      _selectedCategoryId = existing.categoryId;
      _evaluationType = existing.evaluationType;
      _frequencyType = existing.frequencyType;
      _scheduledDays = List<int>.from(existing.scheduledDays);
      _repeatInterval = existing.repeatInterval ?? _repeatInterval;
      _daysPerPeriod = existing.daysPerPeriod ?? _daysPerPeriod;
      _specificDates = List<DateTime>.from(
        existing.specificDates ?? const <DateTime>[],
      );
      _checklistItems
        ..clear()
        ..addAll(existing.checklistItems ?? const <String>[]);
      _priority = existing.priorityLevel;
      _startDate = existing.startDate;
      _endDate = existing.endDate;
      _reminderTimes.addAll(
        existing.reminderTimes.map(_parseTimeOfDay).whereType<TimeOfDay>(),
      );
      _description = existing.description ?? '';
      _linkedFactorIds = List<String>.from(existing.linkedFactorIds);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  TimeOfDay? _parseTimeOfDay(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _addReminderTime() async {
    if (!NotificationService.isSupported) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTimes.isEmpty
          ? TimeOfDay.now()
          : _reminderTimes.last,
    );
    if (picked == null ||
        _reminderTimes.any(
          (time) => time.hour == picked.hour && time.minute == picked.minute,
        )) {
      return;
    }
    setState(() {
      _reminderTimes.add(picked);
      _reminderTimes.sort(
        (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
      );
    });
  }

  Future<void> _saveTask() async {
    if (_taskName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a task name')));
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    if (_evaluationType == HabitEvaluationType.checklist &&
        _checklistItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one checklist item.')),
      );
      return;
    }
    if (_frequencyType == HabitFrequencyType.specificDays &&
        _scheduledDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one scheduled day.')),
      );
      return;
    }
    if (_frequencyType == HabitFrequencyType.specificDatesOfYear &&
        _specificDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one scheduled date.')),
      );
      return;
    }
    if (_endDate != null &&
        DateUtils.dateOnly(
          _endDate!,
        ).isBefore(DateUtils.dateOnly(_startDate))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date cannot be before start date.')),
      );
      return;
    }

    final appState = context.read<AppState>();

    if (_isEditMode) {
      final task = widget.existingTask!;
      task.name = _taskName;
      task.categoryId = _selectedCategoryId!;
      task.evaluationType = _evaluationType;
      task.checklistItems = _checklistItems.isNotEmpty
          ? List<String>.from(_checklistItems)
          : null;
      task.frequencyType = _frequencyType;
      task.scheduledDays = List<int>.from(_scheduledDays);
      task.repeatInterval = _frequencyType == HabitFrequencyType.repeatEvery
          ? _repeatInterval
          : null;
      task.daysPerPeriod =
          _frequencyType == HabitFrequencyType.someDaysPerPeriod
          ? _daysPerPeriod
          : null;
      task.specificDates =
          _frequencyType == HabitFrequencyType.specificDatesOfYear
          ? List<DateTime>.from(_specificDates)
          : null;
      task.startDate = _startDate;
      task.endDate = _endDate;
      task.reminderTimes =
          (_supportsDeviceReminderSchedule
                  ? _reminderTimes
                  : const <TimeOfDay>[])
              .map(
                (time) =>
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              )
              .toList();
      task.priorityLevel = _priority;
      task.linkedFactorIds = List<String>.from(_linkedFactorIds);
      task.description = _description.trim().isNotEmpty
          ? _description.trim()
          : null;
      // Intentionally preserve fields not edited in this wizard:
      // logs, createdAt, sortOrder, isArchived
      await appState.updateRecurringTask(task);
    } else {
      final task = RecurringTask(
        id: const Uuid().v4(),
        name: _taskName,
        categoryId: _selectedCategoryId!,
        evaluationType: _evaluationType,
        checklistItems: _checklistItems.isNotEmpty ? _checklistItems : null,
        frequencyType: _frequencyType,
        scheduledDays: _scheduledDays,
        repeatInterval: _frequencyType == HabitFrequencyType.repeatEvery
            ? _repeatInterval
            : null,
        daysPerPeriod: _frequencyType == HabitFrequencyType.someDaysPerPeriod
            ? _daysPerPeriod
            : null,
        specificDates: _frequencyType == HabitFrequencyType.specificDatesOfYear
            ? _specificDates
            : null,
        startDate: _startDate,
        endDate: _endDate,
        reminderTimes:
            (_supportsDeviceReminderSchedule
                    ? _reminderTimes
                    : const <TimeOfDay>[])
                .map(
                  (time) =>
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                )
                .toList(),
        priorityLevel: _priority,
        linkedFactorIds: _linkedFactorIds,
        description: _description.isNotEmpty ? _description : null,
      );

      await appState.addRecurringTask(task);
    }

    if (mounted) {
      widget.onComplete?.call();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bgColor = colors.background;
    final textPrimary = colors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: _previousPage,
        ),
        title: Text(
          _isEditMode ? 'Edit Recurring Task' : 'New Recurring Task',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildPage1NameAndCategory(),
                _buildPage2EvaluationType(),
                _buildPage3Frequency(),
                _buildPage4Schedule(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(_totalPages, (index) {
          final isActive = index <= _currentPage;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isActive ? colors.primary : colors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final colors = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            if (_currentPage > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousPage,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),
            if (_currentPage > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _currentPage == _totalPages - 1
                    ? _saveTask
                    : _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentPage == _totalPages - 1
                      ? (_isEditMode ? 'Save' : 'Create Task')
                      : 'Next',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== PAGE 1: Name & Category ==========
  Widget _buildPage1NameAndCategory() {
    final colors = context.colors;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What recurring task do you want to track?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This will repeat on a schedule you define.',
            style: TextStyle(fontSize: 14, color: textSecondary),
          ),
          const SizedBox(height: 24),

          TextField(
            autofocus: true,
            style: TextStyle(color: textPrimary, fontSize: 18),
            decoration: InputDecoration(
              hintText: 'e.g., Weekly review, Water plants',
              hintStyle: TextStyle(color: textSecondary),
              filled: true,
              fillColor: colors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => _taskName = value,
          ),
          const SizedBox(height: 32),

          Text(
            'Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          CategoryPicker(
            selectedCategoryId: _selectedCategoryId,
            onChanged: (id) => setState(() => _selectedCategoryId = id),
            wrap: true,
            allowDeselect: false,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  // ========== PAGE 2: Evaluation Type ==========
  Widget _buildPage2EvaluationType() {
    final colors = context.colors;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;

    // Recurring tasks only support yesNo or checklist
    final supportedTypes = [
      HabitEvaluationType.yesNo,
      HabitEvaluationType.checklist,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How do you track completion?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          ...supportedTypes.map(
            (type) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _EvaluationTypeCard(
                evaluationType: type,
                isSelected: _evaluationType == type,
                onTap: () => setState(() => _evaluationType = type),
              ),
            ),
          ),

          // Checklist items if checklist selected
          if (_evaluationType == HabitEvaluationType.checklist) ...[
            const SizedBox(height: 24),
            Text(
              'Checklist Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            ..._checklistItems.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
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
                      icon: Icon(Icons.close_rounded, color: textSecondary),
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
                fillColor: colors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Icon(Icons.add_rounded, color: colors.primary),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  setState(() => _checklistItems.add(value));
                }
              },
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  // ========== PAGE 3: Frequency ==========
  Widget _buildPage3Frequency() {
    final colors = context.colors;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How often?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set when this task should repeat.',
            style: TextStyle(fontSize: 14, color: textSecondary),
          ),
          const SizedBox(height: 24),

          _FrequencyOption(
            title: 'Every day',
            subtitle: 'Repeats daily',
            icon: Icons.calendar_today_rounded,
            isSelected: _frequencyType == HabitFrequencyType.everyday,
            onTap: () => setState(() {
              _frequencyType = HabitFrequencyType.everyday;
              _scheduledDays = [1, 2, 3, 4, 5, 6, 7];
            }),
          ),
          const SizedBox(height: 12),
          _FrequencyOption(
            title: 'Specific days',
            subtitle: 'Choose days of the week',
            icon: Icons.date_range_rounded,
            isSelected: _frequencyType == HabitFrequencyType.specificDays,
            onTap: () => setState(
              () => _frequencyType = HabitFrequencyType.specificDays,
            ),
          ),
          const SizedBox(height: 12),
          _FrequencyOption(
            title: 'Repeat every X days',
            subtitle: 'e.g., every 2 days, every 3 days',
            icon: Icons.replay_rounded,
            isSelected: _frequencyType == HabitFrequencyType.repeatEvery,
            onTap: () =>
                setState(() => _frequencyType = HabitFrequencyType.repeatEvery),
          ),
          const SizedBox(height: 12),
          _FrequencyOption(
            title: 'X days per week',
            subtitle: 'Flexible - any days you choose',
            icon: Icons.calendar_view_week_rounded,
            isSelected: _frequencyType == HabitFrequencyType.someDaysPerPeriod,
            onTap: () => setState(
              () => _frequencyType = HabitFrequencyType.someDaysPerPeriod,
            ),
          ),
          const SizedBox(height: 12),
          _FrequencyOption(
            title: 'Specific dates',
            subtitle: 'Yearly dates like birthdays',
            icon: Icons.cake_rounded,
            isSelected:
                _frequencyType == HabitFrequencyType.specificDatesOfYear,
            onTap: () => setState(
              () => _frequencyType = HabitFrequencyType.specificDatesOfYear,
            ),
          ),

          if (_frequencyType == HabitFrequencyType.specificDays) ...[
            const SizedBox(height: 20),
            _DaySelector(
              selectedDays: _scheduledDays,
              onChanged: (days) => setState(() => _scheduledDays = days),
            ),
          ],

          // Repeat interval selector (if repeatEvery)
          if (_frequencyType == HabitFrequencyType.repeatEvery) ...[
            const SizedBox(height: 20),
            _RepeatIntervalSelector(
              interval: _repeatInterval,
              onChanged: (val) => setState(() => _repeatInterval = val),
            ),
          ],

          // Days per period selector (if someDaysPerPeriod)
          if (_frequencyType == HabitFrequencyType.someDaysPerPeriod) ...[
            const SizedBox(height: 20),
            _DaysPerPeriodSelector(
              daysPerPeriod: _daysPerPeriod,
              onChanged: (val) => setState(() => _daysPerPeriod = val),
            ),
          ],

          // Specific dates picker (if specificDatesOfYear)
          if (_frequencyType == HabitFrequencyType.specificDatesOfYear) ...[
            const SizedBox(height: 20),
            _SpecificDatesSelector(
              dates: _specificDates,
              onChanged: (dates) => setState(() => _specificDates = dates),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  // ========== PAGE 4: Schedule & Priority ==========
  Widget _buildPage4Schedule() {
    final colors = context.colors;
    final textPrimary = colors.textPrimary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Final details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          _ScheduleOption(
            icon: Icons.play_circle_rounded,
            title: 'Start date',
            value: _formatDate(_startDate),
            onTap: () async {
              final today = DateUtils.dateOnly(DateTime.now());
              final currentStart = DateUtils.dateOnly(_startDate);
              final firstDate = _isEditMode && currentStart.isBefore(today)
                  ? currentStart
                  : today;
              final defaultLastDate = DateTime(2100);
              final lastDate = currentStart.isAfter(defaultLastDate)
                  ? currentStart
                  : defaultLastDate;
              final picked = await showDatePicker(
                context: context,
                initialDate: currentStart,
                firstDate: firstDate,
                lastDate: lastDate,
              );
              if (picked != null) {
                setState(() {
                  _startDate = picked;
                  if (_endDate?.isBefore(picked) ?? false) _endDate = null;
                });
              }
            },
          ),
          const SizedBox(height: 12),

          _ScheduleOption(
            icon: Icons.stop_circle_outlined,
            title: 'End date (optional)',
            value: _endDate != null ? _formatDate(_endDate!) : 'Never',
            onTap: () async {
              final startDate = DateUtils.dateOnly(_startDate);
              final defaultLastDate = DateTime(2100);
              final lastDate = startDate.isAfter(defaultLastDate)
                  ? startDate
                  : defaultLastDate;
              final proposedInitial =
                  _endDate ?? startDate.add(const Duration(days: 30));
              final validInitial = proposedInitial.isBefore(startDate)
                  ? startDate
                  : proposedInitial;
              final initialDate = validInitial.isAfter(lastDate)
                  ? lastDate
                  : validInitial;
              final picked = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: startDate,
                lastDate: lastDate,
              );
              if (picked != null) setState(() => _endDate = picked);
            },
          ),
          const SizedBox(height: 24),

          Text(
            'Reminders',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (!NotificationService.isSupported)
            Text(
              'Device reminders are unavailable in this Web build.',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            )
          else if (!_supportsDeviceReminderSchedule)
            Text(
              _endDate != null
                  ? 'Device reminders currently require a schedule without an end date.'
                  : 'Device reminders currently support Every day or Specific days schedules.',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            )
          else ...[
            if (DateUtils.dateOnly(
              _startDate,
            ).isAfter(DateUtils.dateOnly(DateTime.now())))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'The reminder will activate when you next open the app on or after the start date.',
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
              ),
            if (_reminderTimes.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _reminderTimes
                    .map(
                      (time) => InputChip(
                        label: Text(time.format(context)),
                        onDeleted: () =>
                            setState(() => _reminderTimes.remove(time)),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addReminderTime,
              icon: const Icon(Icons.add_alarm_rounded),
              label: const Text('Add reminder'),
            ),
          ],
          const SizedBox(height: 24),

          Text(
            'Priority',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: PriorityLevel.values
                .map(
                  (p) => ChoiceChip(
                    label: Text(p.label),
                    selected: _priority == p,
                    onSelected: (_) => setState(() => _priority = p),
                    selectedColor: colors.primary.withAlpha(50),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),

          // Growth Area Selector (Dissected Trees)
          GrowthAreaSelector(
            selectedAreaIds: _linkedFactorIds,
            onSelectionChanged: (ids) => setState(() => _linkedFactorIds = ids),
            label: 'Link to Dissected Tree (Optional)',
          ),
          const SizedBox(height: 24),

          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _SummaryRow(
                  label: 'Name',
                  value: _taskName.isEmpty ? 'Not set' : _taskName,
                ),
                _SummaryRow(
                  label: 'Category',
                  value: _selectedCategoryId != null ? 'Selected' : 'None',
                ),
                _SummaryRow(label: 'Tracking', value: _evaluationType.label),
                _SummaryRow(label: 'Frequency', value: _frequencyType.label),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// ========== HELPER WIDGETS ==========

class _EvaluationTypeCard extends StatelessWidget {
  final HabitEvaluationType evaluationType;
  final bool isSelected;
  final VoidCallback onTap;

  const _EvaluationTypeCard({
    required this.evaluationType,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textPrimary = colors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withAlpha(20)
              : colors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary.withAlpha(50)
                    : colors.textMuted.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  evaluationType.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evaluationType.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    evaluationType.description,
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: colors.primary),
          ],
        ),
      ),
    );
  }
}

class _FrequencyOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FrequencyOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textPrimary = colors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withAlpha(20)
              : colors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? colors.primary : colors.textMuted),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: colors.primary),
          ],
        ),
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  final List<int> selectedDays;
  final Function(List<int>) onChanged;

  const _DaySelector({required this.selectedDays, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final dayNum = index + 1;
        final isSelected = selectedDays.contains(dayNum);
        return GestureDetector(
          onTap: () {
            final newDays = List<int>.from(selectedDays);
            isSelected ? newDays.remove(dayNum) : newDays.add(dayNum);
            newDays.sort();
            onChanged(newDays);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? colors.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? colors.primary
                    : colors.textMuted.withAlpha(100),
              ),
            ),
            child: Center(
              child: Text(
                days[index],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? colors.onPrimary : colors.textMuted,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Selector for repeat interval (every X days)
class _RepeatIntervalSelector extends StatelessWidget {
  final int interval;
  final Function(int) onChanged;

  const _RepeatIntervalSelector({
    required this.interval,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textPrimary = colors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text('Every', style: TextStyle(color: textPrimary, fontSize: 16)),
          const SizedBox(width: 12),
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: colors.primary),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 20),
                  icon: const Icon(Icons.remove, size: 16),
                  color: colors.primary,
                  onPressed: interval > 2
                      ? () => onChanged(interval - 1)
                      : null,
                ),
                Text(
                  '$interval',
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 20),
                  icon: const Icon(Icons.add, size: 16),
                  color: colors.primary,
                  onPressed: interval < 30
                      ? () => onChanged(interval + 1)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('days', style: TextStyle(color: textPrimary, fontSize: 16)),
        ],
      ),
    );
  }
}

/// Selector for days per period (X days per week)
class _DaysPerPeriodSelector extends StatelessWidget {
  final int daysPerPeriod;
  final Function(int) onChanged;

  const _DaysPerPeriodSelector({
    required this.daysPerPeriod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textPrimary = colors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complete at least $daysPerPeriod day${daysPerPeriod > 1 ? 's' : ''} per week',
            style: TextStyle(color: textPrimary, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(7, (index) {
              final days = index + 1;
              final isSelected = daysPerPeriod == days;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(days),
                  child: Container(
                    margin: EdgeInsets.only(right: index < 6 ? 4 : 0),
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? colors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? colors.primary
                            : colors.textMuted.withAlpha(100),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$days',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? colors.onPrimary
                              : colors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Selector for specific dates of the year
class _SpecificDatesSelector extends StatelessWidget {
  final List<DateTime> dates;
  final Function(List<DateTime>) onChanged;

  const _SpecificDatesSelector({required this.dates, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected dates',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add date'),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    // Store just month and day for yearly recurrence
                    final newDate = DateTime(2000, picked.month, picked.day);
                    if (!dates.any(
                      (d) => d.month == newDate.month && d.day == newDate.day,
                    )) {
                      onChanged([...dates, newDate]);
                    }
                  }
                },
              ),
            ],
          ),
          if (dates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No dates added yet',
                style: TextStyle(
                  color: textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dates.map((date) {
                return Chip(
                  label: Text('${months[date.month - 1]} ${date.day}'),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    onChanged(dates.where((d) => d != date).toList());
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _ScheduleOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _ScheduleOption({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textPrimary = colors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: TextStyle(color: textPrimary)),
            ),
            Text(
              value,
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
