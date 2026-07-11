import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/theme.dart';
import '../../providers/app_state.dart';
import '../../services/notification_service.dart';
import '../../models/habit.dart';
import '../../models/habit_enums.dart';
import '../../widgets/category_picker.dart';
import '../../widgets/growth_area_selector.dart';

/// Multi-page wizard for creating a new habit
class HabitCreationWizard extends StatefulWidget {
  final VoidCallback? onComplete;

  const HabitCreationWizard({super.key, this.onComplete});

  static Future<void> show(BuildContext context, {VoidCallback? onComplete}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => HabitCreationWizard(onComplete: onComplete),
      ),
    );
  }

  @override
  State<HabitCreationWizard> createState() => _HabitCreationWizardState();
}

class _HabitCreationWizardState extends State<HabitCreationWizard> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Text controllers to persist values across page navigations
  final _nameController = TextEditingController();
  final _triggerResponseController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitController = TextEditingController();

  // Wizard data
  String? _selectedCategoryId;
  HabitType _habitType = HabitType.build;
  HabitEvaluationType _evaluationType = HabitEvaluationType.yesNo;
  HabitFrequencyType _frequencyType = HabitFrequencyType.everyday;
  List<int> _scheduledDays = [1, 2, 3, 4, 5, 6, 7]; // All days
  int _repeatInterval = 2; // For repeatEvery (every N days)
  int _daysPerPeriod = 3; // For someDaysPerPeriod (X days per week)
  List<DateTime> _specificDates = []; // For specificDatesOfYear
  int _targetValue = 1;
  final List<String> _checklistItems = [];
  PriorityLevel _priority = PriorityLevel.none;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  final List<TimeOfDay> _reminderTimes = [];
  bool _scoringEnabled = false; // Optional scoring (0-100) for completion
  List<String> _linkedFactorIds =
      []; // Dissected trees (GrowthAreas) to link habit to

  static const int _totalPages = 5;

  bool get _supportsDeviceReminderSchedule =>
      (_frequencyType == HabitFrequencyType.everyday ||
          _frequencyType == HabitFrequencyType.specificDays) &&
      _endDate == null;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _triggerResponseController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
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

  Future<void> _createHabit() async {
    final habitName = _nameController.text.trim();
    final triggerResponse = _triggerResponseController.text.trim();
    final description = _descriptionController.text.trim();
    final unit = _unitController.text.trim();

    if (habitName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit name')),
      );
      return;
    }
    if ((_evaluationType == HabitEvaluationType.numeric ||
            _evaluationType == HabitEvaluationType.timer) &&
        _targetValue < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The daily target must be at least 1.')),
      );
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

    try {
      final habit = Habit(
        id: const Uuid().v4(),
        name: habitName,
        type: _habitType,
        triggerResponse: triggerResponse.isNotEmpty ? triggerResponse : null,
        categoryId: _selectedCategoryId,
        evaluationType: _evaluationType,
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
        targetValue: _targetValue,
        timerMinutes: _evaluationType == HabitEvaluationType.timer
            ? _targetValue
            : null,
        unit: unit.isNotEmpty ? unit : null,
        checklistItems: _checklistItems.isNotEmpty ? _checklistItems : null,
        priorityLevel: _priority,
        startDate: _startDate,
        endDate: _endDate,
        reminderTimes:
            (_supportsDeviceReminderSchedule
                    ? _reminderTimes
                    : const <TimeOfDay>[])
                .map(
                  (t) =>
                      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
                )
                .toList(),
        description: description.isNotEmpty ? description : null,
        scoringEnabled: _scoringEnabled,
        factorId: null, // Legacy field, kept for backward compatibility
        linkedFactorIds: _linkedFactorIds.isNotEmpty ? _linkedFactorIds : null,
      );

      final appState = context.read<AppState>();
      await appState.addHabit(habit);

      if (mounted) {
        widget.onComplete?.call();
        Navigator.of(context).pop();
      }
    } catch (e, stackTrace) {
      debugPrint('Error creating habit: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating habit: $e')));
      }
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
          'New Habit',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (_currentPage == _totalPages - 1)
            TextButton(onPressed: _createHabit, child: const Text('Create')),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildPage1NameAndCategory(),
                _buildPage2HabitType(),
                _buildPage3EvaluationType(),
                _buildPage4Frequency(),
                _buildPage5Schedule(),
              ],
            ),
          ),

          // Navigation buttons
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
              flex: _currentPage == 0 ? 1 : 1,
              child: ElevatedButton(
                onPressed: _currentPage == _totalPages - 1
                    ? _createHabit
                    : _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentPage == _totalPages - 1 ? 'Create Habit' : 'Next',
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
            'What habit do you want to build?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Give your habit a clear, specific name.',
            style: TextStyle(fontSize: 14, color: textSecondary),
          ),
          const SizedBox(height: 24),

          // Habit name input
          TextField(
            controller: _nameController,
            autofocus: true,
            style: TextStyle(color: textPrimary, fontSize: 18),
            decoration: InputDecoration(
              hintText: 'e.g., Drink 8 glasses of water',
              hintStyle: TextStyle(color: textSecondary),
              filled: true,
              fillColor: colors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Habit type (Build/Quit)
          Text(
            'Habit Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _HabitTypeOption(
                label: 'Build',
                icon: Icons.add_circle_rounded,
                color: colors.success,
                isSelected: _habitType == HabitType.build,
                onTap: () => setState(() => _habitType = HabitType.build),
              ),
              const SizedBox(width: 12),
              _HabitTypeOption(
                label: 'Quit',
                icon: Icons.remove_circle_rounded,
                color: colors.danger,
                isSelected: _habitType == HabitType.quit,
                onTap: () => setState(() => _habitType = HabitType.quit),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Category selection
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
          ),
          const SizedBox(height: 32),

          // If-Then Plan (Implementation Intention)
          Text(
            'If-Then Plan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When will you do this habit? Link it to an existing routine.',
            style: TextStyle(fontSize: 12, color: textSecondary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _triggerResponseController,
            style: TextStyle(color: textPrimary, fontSize: 16),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: _habitType == HabitType.build
                  ? 'e.g., After I wake up, I will drink a glass of water'
                  : 'e.g., When I feel stressed, I will take 3 deep breaths instead',
              hintStyle: TextStyle(
                color: textSecondary.withAlpha(150),
                fontSize: 14,
              ),
              filled: true,
              fillColor: colors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  // ========== PAGE 2: Habit Type (Build/Quit/Timed) ==========
  Widget _buildPage2HabitType() {
    final colors = context.colors;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How do you want to track "${_nameController.text}"?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how you\'ll measure your progress.',
            style: TextStyle(fontSize: 14, color: textSecondary),
          ),
          const SizedBox(height: 24),

          ...HabitEvaluationType.values.map(
            (type) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _EvaluationTypeCard(
                evaluationType: type,
                isSelected: _evaluationType == type,
                onTap: () => setState(() => _evaluationType = type),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  // ========== PAGE 3: Type-specific Configuration ==========
  Widget _buildPage3EvaluationType() {
    final colors = context.colors;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configure your habit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          if (_evaluationType == HabitEvaluationType.yesNo)
            _buildYesNoConfig(textPrimary, textSecondary, colors),
          if (_evaluationType == HabitEvaluationType.numeric)
            _buildNumericConfig(textPrimary, textSecondary, colors),
          if (_evaluationType == HabitEvaluationType.timer)
            _buildTimerConfig(textPrimary, textSecondary, colors),
          if (_evaluationType == HabitEvaluationType.checklist)
            _buildChecklistConfig(textPrimary, textSecondary, colors),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildYesNoConfig(
    Color textPrimary,
    Color textSecondary,
    AppColorsTheme colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.primary.withAlpha(50)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: colors.primary, size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simple Tracking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Just tap to mark your habit as done each day.',
                      style: TextStyle(color: textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Scoring option toggle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.score_rounded,
                color: _scoringEnabled ? colors.primary : textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Scoring',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rate how close you got (0-100%) when completing or missing the habit',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _scoringEnabled,
                onChanged: (value) => setState(() => _scoringEnabled = value),
                activeTrackColor: colors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'Optional: Add a note about this habit',
          style: TextStyle(fontSize: 14, color: textSecondary),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          style: TextStyle(color: textPrimary),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Why is this habit important to you?',
            hintStyle: TextStyle(color: textSecondary),
            filled: true,
            fillColor: colors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumericConfig(
    Color textPrimary,
    Color textSecondary,
    AppColorsTheme colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Target',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                style: TextStyle(color: textPrimary, fontSize: 24),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '8',
                  hintStyle: TextStyle(color: textSecondary),
                  filled: true,
                  fillColor: colors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null) _targetValue = parsed;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _unitController,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'glasses of water',
                  hintStyle: TextStyle(color: textSecondary),
                  filled: true,
                  fillColor: colors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimerConfig(
    Color textPrimary,
    Color textSecondary,
    AppColorsTheme colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Goal (minutes)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          style: TextStyle(color: textPrimary, fontSize: 24),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: '30',
            hintStyle: TextStyle(color: textSecondary),
            filled: true,
            fillColor: colors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixText: 'minutes',
          ),
          onChanged: (value) {
            final parsed = int.tryParse(value);
            if (parsed != null) _targetValue = parsed;
          },
        ),
      ],
    );
  }

  Widget _buildChecklistConfig(
    Color textPrimary,
    Color textSecondary,
    AppColorsTheme colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Checklist Items',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add items you need to complete for this habit.',
          style: TextStyle(color: textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 16),

        // Existing items
        ..._checklistItems.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.drag_indicator_rounded, color: textSecondary),
                const SizedBox(width: 8),
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

        // Add new item
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
    );
  }

  // ========== PAGE 4: Frequency ==========
  Widget _buildPage4Frequency() {
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
            'Set the frequency for your habit.',
            style: TextStyle(fontSize: 14, color: textSecondary),
          ),
          const SizedBox(height: 24),

          // Frequency options
          _FrequencyOption(
            title: 'Every day',
            subtitle: 'Build consistency with daily practice',
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
            subtitle: 'Choose which days of the week',
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

          // Day selector (if specific days)
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

  // ========== PAGE 5: Schedule ==========
  Widget _buildPage5Schedule() {
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

          // Start date
          _ScheduleOption(
            icon: Icons.play_circle_rounded,
            title: 'Start date',
            value: _formatDate(_startDate),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
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

          // End date (optional)
          _ScheduleOption(
            icon: Icons.stop_circle_outlined,
            title: 'End date (optional)',
            value: _endDate != null ? _formatDate(_endDate!) : 'Never',
            onTap: () async {
              final lastDate = DateTime(2100);
              final proposedInitial =
                  _endDate ?? _startDate.add(const Duration(days: 30));
              final initialDate = proposedInitial.isAfter(lastDate)
                  ? lastDate
                  : proposedInitial;
              final picked = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: _startDate,
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

          // Priority
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

          // Growth Area Selector (Dissected Trees - multi-select)
          GrowthAreaSelector(
            selectedAreaIds: _linkedFactorIds,
            onSelectionChanged: (ids) => setState(() => _linkedFactorIds = ids),
            label: 'Link to Dissected Tree (Optional)',
            multiSelect: true,
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
                  value: _nameController.text.isEmpty
                      ? 'Not set'
                      : _nameController.text,
                ),
                _SummaryRow(
                  label: 'Type',
                  value: _habitType.toString().split('.').last,
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

class _HabitTypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _HabitTypeOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(30) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : colors.textMuted.withAlpha(100),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : colors.textMuted,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
            if (isSelected) {
              newDays.remove(dayNum);
            } else {
              newDays.add(dayNum);
            }
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
