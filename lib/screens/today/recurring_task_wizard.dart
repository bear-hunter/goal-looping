import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/theme.dart';
import '../../providers/app_state.dart';
import '../../models/recurring_task.dart';
import '../../models/habit_enums.dart';
import '../../models/category_model.dart';

/// Multi-page wizard for creating a recurring task
class RecurringTaskWizard extends StatefulWidget {
  final VoidCallback? onComplete;

  const RecurringTaskWizard({super.key, this.onComplete});

  static Future<void> show(BuildContext context, {VoidCallback? onComplete}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => RecurringTaskWizard(onComplete: onComplete),
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
  final List<String> _checklistItems = [];
  PriorityLevel _priority = PriorityLevel.none;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String _description = '';
  List<String> _linkedFactorIds = [];

  static const int _totalPages = 4; // Simpler than habit wizard

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

  Future<void> _createTask() async {
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

    final task = RecurringTask(
      id: const Uuid().v4(),
      name: _taskName,
      categoryId: _selectedCategoryId!,
      evaluationType: _evaluationType,
      checklistItems: _checklistItems.isNotEmpty ? _checklistItems : null,
      frequencyType: _frequencyType,
      scheduledDays: _scheduledDays,
      startDate: _startDate,
      endDate: _endDate,
      priorityLevel: _priority,
      linkedFactorIds: _linkedFactorIds,
      description: _description.isNotEmpty ? _description : null,
    );

    final appState = context.read<AppState>();
    await appState.addRecurringTask(task);

    if (mounted) {
      widget.onComplete?.call();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.background : LightColors.background;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: _previousPage,
        ),
        title: Text(
          'New Recurring Task',
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
                color: isActive ? AppColors.primary : AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationButtons() {
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
                    ? _createTask
                    : _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentPage == _totalPages - 1 ? 'Create Task' : 'Next',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;
    final categories = context.watch<AppState>().categories;

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
              fillColor: isDark
                  ? AppColors.surfaceLight
                  : LightColors.surfaceLight,
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories
                .map(
                  (cat) => _CategoryChip(
                    category: cat,
                    isSelected: _selectedCategoryId == cat.id,
                    onTap: () => setState(() {
                      _selectedCategoryId = _selectedCategoryId == cat.id
                          ? null
                          : cat.id;
                    }),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  // ========== PAGE 2: Evaluation Type ==========
  Widget _buildPage2EvaluationType() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;

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
                fillColor: isDark
                    ? AppColors.surfaceLight
                    : LightColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Icon(Icons.add_rounded, color: AppColors.primary),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;

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

          if (_frequencyType == HabitFrequencyType.specificDays) ...[
            const SizedBox(height: 20),
            _DaySelector(
              selectedDays: _scheduledDays,
              onChanged: (days) => setState(() => _scheduledDays = days),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  // ========== PAGE 4: Schedule & Priority ==========
  Widget _buildPage4Schedule() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;

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
              final picked = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _startDate = picked);
            },
          ),
          const SizedBox(height: 12),

          _ScheduleOption(
            icon: Icons.stop_circle_outlined,
            title: 'End date (optional)',
            value: _endDate != null ? _formatDate(_endDate!) : 'Never',
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate:
                    _endDate ?? _startDate.add(const Duration(days: 30)),
                firstDate: _startDate,
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _endDate = picked);
            },
          ),
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
                    selectedColor: AppColors.primary.withAlpha(50),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),

          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceLight : LightColors.surfaceLight,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(20)
              : (isDark ? AppColors.surfaceLight : LightColors.surfaceLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
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
                    ? AppColors.primary.withAlpha(50)
                    : Colors.grey.withAlpha(30),
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
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: AppColors.primary),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(20)
              : (isDark ? AppColors.surfaceLight : LightColors.surfaceLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
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
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: AppColors.primary),
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
              color: isSelected ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : Colors.grey.withAlpha(100),
              ),
            ),
            child: Center(
              child: Text(
                days[index],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ),
        );
      }),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceLight : LightColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: TextStyle(color: textPrimary)),
            ),
            Text(
              value,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: Colors.grey),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondary
                  : LightColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textPrimary : LightColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
