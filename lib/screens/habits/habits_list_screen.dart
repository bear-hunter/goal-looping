import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/habit.dart';
import '../../models/habit_enums.dart';
import '../../providers/app_state.dart';
import '../today/habit_creation_wizard.dart';
import '../today/habit_detail_screen.dart';

/// Simple Habits List Screen - shows all habits in a manageable list format
/// Separate from Habit Defense to provide a cleaner habit management experience
class HabitsListScreen extends StatefulWidget {
  const HabitsListScreen({super.key});

  @override
  State<HabitsListScreen> createState() => _HabitsListScreenState();
}

class _HabitsListScreenState extends State<HabitsListScreen> {
  HabitType _selectedType = HabitType.build;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final habits = _selectedType == HabitType.build
            ? state.buildHabits
            : state.quitHabits;

        final filteredHabits = _searchQuery.isEmpty
            ? habits
            : habits
                  .where(
                    (h) =>
                        h.name.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                        (h.triggerResponse?.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ??
                            false) ||
                        h.motivation.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                  )
                  .toList();

        return SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'All Habits',
                            style: Theme.of(context).textTheme.displayMedium,
                          ).animate().fadeIn(duration: 400.ms),
                        ),
                        IconButton(
                          onPressed: () => HabitCreationWizard.show(context),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${habits.length} ${_selectedType == HabitType.build ? 'build' : 'quit'} habits',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search habits...',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.textMuted,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Type toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    _TypeChip(
                      label: 'Build Habits',
                      icon: Icons.trending_up_rounded,
                      isSelected: _selectedType == HabitType.build,
                      color: AppColors.success,
                      count: state.buildHabits.length,
                      onTap: () =>
                          setState(() => _selectedType = HabitType.build),
                    ),
                    const SizedBox(width: 12),
                    _TypeChip(
                      label: 'Quit Habits',
                      icon: Icons.block_rounded,
                      isSelected: _selectedType == HabitType.quit,
                      color: AppColors.danger,
                      count: state.quitHabits.length,
                      onTap: () =>
                          setState(() => _selectedType = HabitType.quit),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Habits list
              Expanded(
                child: filteredHabits.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty
                                  ? Icons.search_off_rounded
                                  : Icons.lightbulb_outline_rounded,
                              size: 64,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No habits match your search'
                                  : 'No ${_selectedType == HabitType.build ? 'build' : 'quit'} habits yet',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_searchQuery.isEmpty)
                              TextButton.icon(
                                onPressed: () =>
                                    HabitCreationWizard.show(context),
                                icon: Icon(Icons.add_rounded),
                                label: Text(
                                  'Add your first ${_selectedType == HabitType.build ? 'build' : 'quit'} habit',
                                ),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: filteredHabits.length,
                        itemBuilder: (context, index) {
                          final habit = filteredHabits[index];
                          return _HabitListTile(
                                habit: habit,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        HabitDetailScreen(habitId: habit.id),
                                  ),
                                ),
                                onEdit: () =>
                                    _showEditHabitDialog(context, state, habit),
                                onDelete: () => _showDeleteConfirmation(
                                  context,
                                  state,
                                  habit,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 300.ms, delay: (50 * index).ms)
                              .slideX(
                                begin: 0.1,
                                end: 0,
                                duration: 300.ms,
                                delay: (50 * index).ms,
                              );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditHabitDialog(BuildContext context, AppState state, Habit habit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surface : LightColors.surface;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;

    final nameController = TextEditingController(text: habit.name);
    final triggerController = TextEditingController(
      text: habit.triggerResponse ?? '',
    );
    final descController = TextEditingController(text: habit.description ?? '');
    String? selectedCategoryId = habit.categoryId;
    List<int> selectedDays = List<int>.from(habit.scheduledDays);
    HabitFrequencyType frequencyType =
        habit.frequencyType ?? HabitFrequencyType.everyday;
    int repeatInterval = habit.repeatInterval ?? 2;
    int daysPerPeriod = habit.daysPerPeriod ?? 3;
    List<DateTime> specificDates = List<DateTime>.from(
      habit.specificDates ?? [],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final categories = state.categories;
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Habit',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: textSecondary),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Name field
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Habit Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // If-Then (trigger response)
                    TextField(
                      controller: triggerController,
                      style: TextStyle(color: textPrimary),
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'If-Then Plan',
                        hintText:
                            'e.g., "If I feel tired → I will do just 5 minutes"',
                        hintStyle: TextStyle(color: textSecondary),
                        prefixIcon: Icon(
                          Icons.psychology_rounded,
                          color: AppColors.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category selection
                    Text(
                      'Category',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            final isSelected = selectedCategoryId == null;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: const Text('None'),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setModalState(
                                    () => selectedCategoryId = null,
                                  );
                                },
                              ),
                            );
                          }
                          final category = categories[index - 1];
                          final isSelected = selectedCategoryId == category.id;
                          final color = Color(category.colorValue);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(category.name),
                              selected: isSelected,
                              selectedColor: color.withAlpha(100),
                              avatar: Icon(
                                category.icon,
                                size: 16,
                                color: isSelected ? color : textSecondary,
                              ),
                              onSelected: (selected) {
                                setModalState(
                                  () => selectedCategoryId = selected
                                      ? category.id
                                      : null,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Frequency Type
                    Text(
                      'Frequency',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: textSecondary.withAlpha(100)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<HabitFrequencyType>(
                          isExpanded: true,
                          value: frequencyType,
                          dropdownColor: surfaceColor,
                          items: HabitFrequencyType.values
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type.label,
                                    style: TextStyle(color: textPrimary),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                frequencyType = val;
                                if (val == HabitFrequencyType.everyday) {
                                  selectedDays = [1, 2, 3, 4, 5, 6, 7];
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Frequency-specific options
                    if (frequencyType == HabitFrequencyType.specificDays) ...[
                      Text(
                        'Select days:',
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var i = 1; i <= 7; i++)
                            GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  if (selectedDays.contains(i)) {
                                    if (selectedDays.length > 1)
                                      selectedDays.remove(i);
                                  } else {
                                    selectedDays.add(i);
                                  }
                                  selectedDays.sort();
                                });
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: selectedDays.contains(i)
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedDays.contains(i)
                                        ? AppColors.primary
                                        : textSecondary,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i - 1],
                                    style: TextStyle(
                                      color: selectedDays.contains(i)
                                          ? Colors.white
                                          : textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],

                    if (frequencyType == HabitFrequencyType.repeatEvery) ...[
                      Row(
                        children: [
                          Text('Every ', style: TextStyle(color: textPrimary)),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: textPrimary),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              controller: TextEditingController(
                                text: '$repeatInterval',
                              ),
                              onChanged: (val) {
                                final parsed = int.tryParse(val);
                                if (parsed != null && parsed >= 2) {
                                  repeatInterval = parsed;
                                }
                              },
                            ),
                          ),
                          Text(' days', style: TextStyle(color: textPrimary)),
                        ],
                      ),
                    ],

                    if (frequencyType ==
                        HabitFrequencyType.someDaysPerPeriod) ...[
                      Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: textPrimary),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              controller: TextEditingController(
                                text: '$daysPerPeriod',
                              ),
                              onChanged: (val) {
                                final parsed = int.tryParse(val);
                                if (parsed != null &&
                                    parsed >= 1 &&
                                    parsed <= 7) {
                                  daysPerPeriod = parsed;
                                }
                              },
                            ),
                          ),
                          Text(
                            ' days per week',
                            style: TextStyle(color: textPrimary),
                          ),
                        ],
                      ),
                    ],

                    if (frequencyType ==
                        HabitFrequencyType.specificDatesOfYear) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Selected dates:',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add'),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                final newDate = DateTime(
                                  2000,
                                  picked.month,
                                  picked.day,
                                );
                                if (!specificDates.any(
                                  (d) =>
                                      d.month == newDate.month &&
                                      d.day == newDate.day,
                                )) {
                                  setModalState(
                                    () => specificDates.add(newDate),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      if (specificDates.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: specificDates.map((date) {
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
                            return Chip(
                              label: Text(
                                '${months[date.month - 1]} ${date.day}',
                              ),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => setModalState(
                                () => specificDates.remove(date),
                              ),
                            );
                          }).toList(),
                        ),
                    ],

                    const SizedBox(height: 16),

                    // Description
                    TextField(
                      controller: descController,
                      style: TextStyle(color: textPrimary),
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a habit name'),
                              ),
                            );
                            return;
                          }

                          habit.name = name;
                          habit.triggerResponse =
                              triggerController.text.trim().isNotEmpty
                              ? triggerController.text.trim()
                              : null;
                          habit.description =
                              descController.text.trim().isNotEmpty
                              ? descController.text.trim()
                              : null;
                          habit.categoryId = selectedCategoryId;
                          habit.frequencyType = frequencyType;
                          habit.scheduledDays = selectedDays;
                          habit.repeatInterval =
                              frequencyType == HabitFrequencyType.repeatEvery
                              ? repeatInterval
                              : null;
                          habit.daysPerPeriod =
                              frequencyType ==
                                  HabitFrequencyType.someDaysPerPeriod
                              ? daysPerPeriod
                              : null;
                          habit.specificDates =
                              frequencyType ==
                                  HabitFrequencyType.specificDatesOfYear
                              ? specificDates
                              : null;

                          state.updateHabit(habit);
                          Navigator.pop(ctx);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Habit updated')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AppState state,
    Habit habit,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete Habit?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'This will permanently delete "${habit.name}" and all its logs. This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppState>().deleteHabit(habit.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Type selection chip for the main screen
class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final int count;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(20) : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.glassBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? color : AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected ? color : AppColors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? color.withAlpha(30) : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? color : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual habit list tile
class _HabitListTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HabitListTile({
    required this.habit,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.glassBorder.withAlpha(40),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: habit.isLoggedToday
                    ? (habit.todayLog?.completed == true
                              ? AppColors.success
                              : AppColors.danger)
                          .withAlpha(15)
                    : AppColors.surfaceLight.withAlpha(80),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: habit.isLoggedToday
                      ? (habit.todayLog?.completed == true
                            ? AppColors.success
                            : AppColors.danger)
                      : AppColors.glassBorder,
                  width: 1,
                ),
              ),
              child: habit.isLoggedToday
                  ? Icon(
                      habit.todayLog?.completed == true
                          ? Icons.check_rounded
                          : Icons.close_rounded,
                      color: habit.todayLog?.completed == true
                          ? AppColors.success
                          : AppColors.danger,
                      size: 16,
                    )
                  : Icon(
                      habit.type == HabitType.build
                          ? Icons.trending_up_rounded
                          : Icons.block_rounded,
                      color: AppColors.textMuted,
                      size: 14,
                    ),
            ),
            const SizedBox(width: 8),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    habit.type == HabitType.quit
                        ? 'No ${habit.name}'
                        : habit.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (habit.type == HabitType.build &&
                      habit.triggerResponse != null &&
                      habit.triggerResponse!.isNotEmpty)
                    Text(
                      'If: ${habit.triggerResponse}',
                      style: TextStyle(fontSize: 10, color: AppColors.warning),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 11,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${habit.currentStreak}d',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.emoji_events_rounded,
                        size: 11,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${habit.bestStreak}d',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: AppColors.textMuted,
                size: 18,
              ),
              padding: EdgeInsets.zero,
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: AppColors.glassBorder),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  height: 36,
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded, size: 16, color: AppColors.info),
                      const SizedBox(width: 8),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  height: 36,
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_rounded,
                        size: 16,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: TextStyle(color: AppColors.danger, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
