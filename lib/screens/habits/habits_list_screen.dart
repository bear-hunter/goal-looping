import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/habit.dart';
import '../../providers/app_state.dart';
import '../../services/storage_service.dart';
import '../../widgets/glass_card.dart';
import 'habit_detail_screen.dart';

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
            : habits.where((h) => 
                h.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (h.triggerResponse?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                h.motivation.toLowerCase().contains(_searchQuery.toLowerCase())
              ).toList();

        return SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
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
                          onPressed: () => _showAddHabitDialog(context, state),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.add_rounded, color: AppColors.primary),
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search habits...',
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close_rounded, color: AppColors.textMuted),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Type toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _TypeChip(
                      label: 'Build Habits',
                      icon: Icons.trending_up_rounded,
                      isSelected: _selectedType == HabitType.build,
                      color: AppColors.success,
                      count: state.buildHabits.length,
                      onTap: () => setState(() => _selectedType = HabitType.build),
                    ),
                    const SizedBox(width: 12),
                    _TypeChip(
                      label: 'Quit Habits',
                      icon: Icons.block_rounded,
                      isSelected: _selectedType == HabitType.quit,
                      color: AppColors.danger,
                      count: state.quitHabits.length,
                      onTap: () => setState(() => _selectedType = HabitType.quit),
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
                              style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            if (_searchQuery.isEmpty)
                              TextButton.icon(
                                onPressed: () => _showAddHabitDialog(context, state),
                                icon: Icon(Icons.add_rounded),
                                label: Text('Add your first ${_selectedType == HabitType.build ? 'build' : 'quit'} habit'),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredHabits.length,
                        itemBuilder: (context, index) {
                          final habit = filteredHabits[index];
                          return _HabitListTile(
                            habit: habit,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HabitDetailScreen(habitId: habit.id),
                              ),
                            ),
                            onEdit: () => _showEditHabitDialog(context, state, habit),
                            onDelete: () => _showDeleteConfirmation(context, state, habit),
                          ).animate()
                            .fadeIn(duration: 300.ms, delay: (50 * index).ms)
                            .slideX(begin: 0.1, end: 0, duration: 300.ms, delay: (50 * index).ms);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddHabitDialog(BuildContext context, AppState state) {
    final nameController = TextEditingController();
    final triggerController = TextEditingController();
    final motivationController = TextEditingController();
    HabitType dialogType = _selectedType;
    String? selectedFactorId;
    List<int> selectedDays = [1, 2, 3, 4, 5, 6, 7]; // All days by default (scheduledDays)

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'New Habit',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(Icons.close_rounded, color: AppColors.textMuted),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Type toggle
                Row(
                  children: [
                    Expanded(
                      child: _DialogTypeChip(
                        label: 'Build',
                        icon: Icons.trending_up_rounded,
                        isSelected: dialogType == HabitType.build,
                        color: AppColors.success,
                        onTap: () => setDialogState(() => dialogType = HabitType.build),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogTypeChip(
                        label: 'Quit',
                        icon: Icons.block_rounded,
                        isSelected: dialogType == HabitType.quit,
                        color: AppColors.danger,
                        onTap: () => setDialogState(() => dialogType = HabitType.quit),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Conditional fields based on type
                if (dialogType == HabitType.build) ...[
                  Text('Trigger (If...)', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: triggerController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., I feel stressed',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Action (I will...)', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                ],
                
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: dialogType == HabitType.quit
                        ? 'e.g., Doom scrolling'
                        : 'e.g., Take 5 deep breaths',
                  ),
                ),

                const SizedBox(height: 16),

                Text('Motivation (Why?)', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                TextField(
                  controller: motivationController,
                  decoration: const InputDecoration(
                    hintText: 'Why is this habit important to you?',
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 16),

                // Days selection
                Text('Active Days', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List.generate(7, (i) {
                    final day = i + 1;
                    final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    final isSelected = selectedDays.contains(day);
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          if (isSelected && selectedDays.length > 1) {
                            selectedDays.remove(day);
                          } else if (!isSelected) {
                            selectedDays.add(day);
                          }
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withAlpha(30) : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.glassBorder,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          dayNames[i],
                          style: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textMuted,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // Factor dropdown
                Text('Link to Factor (optional)', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text('Select Factor', style: TextStyle(color: AppColors.textMuted)),
                      value: selectedFactorId,
                      dropdownColor: AppColors.surface,
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('None', style: TextStyle(color: AppColors.textMuted)),
                        ),
                        ...state.factors.map((f) => DropdownMenuItem<String>(
                          value: f.id,
                          child: Text(f.name, style: TextStyle(color: AppColors.textPrimary)),
                        )),
                      ],
                      onChanged: (v) => setDialogState(() => selectedFactorId = v),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isNotEmpty) {
                            context.read<AppState>().addHabit(Habit(
                              id: StorageService.generateId(),
                              name: nameController.text.trim(),
                              type: dialogType,
                              triggerResponse: dialogType == HabitType.build 
                                  ? triggerController.text.trim() 
                                  : null,
                              motivation: motivationController.text.trim(),
                              factorId: selectedFactorId,
                              scheduledDays: selectedDays,
                            ));
                            Navigator.pop(ctx);
                            // Update the type to match what was just created
                            setState(() => _selectedType = dialogType);
                          }
                        },
                        child: const Text('Create Habit'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditHabitDialog(BuildContext context, AppState state, Habit habit) {
    final nameController = TextEditingController(text: habit.name);
    final triggerController = TextEditingController(text: habit.triggerResponse ?? '');
    final motivationController = TextEditingController(text: habit.motivation);
    String? selectedFactorId = habit.factorId;
    List<int> selectedDays = List<int>.from(habit.scheduledDays);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Edit Habit',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(Icons.close_rounded, color: AppColors.textMuted),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Type indicator (read-only)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (habit.type == HabitType.build ? AppColors.success : AppColors.danger).withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        habit.type == HabitType.build ? Icons.trending_up_rounded : Icons.block_rounded,
                        size: 16,
                        color: habit.type == HabitType.build ? AppColors.success : AppColors.danger,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        habit.type == HabitType.build ? 'Build Habit' : 'Quit Habit',
                        style: TextStyle(
                          color: habit.type == HabitType.build ? AppColors.success : AppColors.danger,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Conditional fields based on type
                if (habit.type == HabitType.build) ...[
                  Text('Trigger (If...)', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: triggerController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., I feel stressed',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Action (I will...)', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                ],
                
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: habit.type == HabitType.quit
                        ? 'e.g., Doom scrolling'
                        : 'e.g., Take 5 deep breaths',
                  ),
                ),

                const SizedBox(height: 16),

                Text('Motivation (Why?)', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                TextField(
                  controller: motivationController,
                  decoration: const InputDecoration(
                    hintText: 'Why is this habit important to you?',
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 16),

                // Days selection
                Text('Active Days', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List.generate(7, (i) {
                    final day = i + 1;
                    final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    final isSelected = selectedDays.contains(day);
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          if (isSelected && selectedDays.length > 1) {
                            selectedDays.remove(day);
                          } else if (!isSelected) {
                            selectedDays.add(day);
                          }
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withAlpha(30) : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.glassBorder,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          dayNames[i],
                          style: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textMuted,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // Factor dropdown
                Text('Link to Factor (optional)', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text('Select Factor', style: TextStyle(color: AppColors.textMuted)),
                      value: selectedFactorId,
                      dropdownColor: AppColors.surface,
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('None', style: TextStyle(color: AppColors.textMuted)),
                        ),
                        ...state.factors.map((f) => DropdownMenuItem<String>(
                          value: f.id,
                          child: Text(f.name, style: TextStyle(color: AppColors.textPrimary)),
                        )),
                      ],
                      onChanged: (v) => setDialogState(() => selectedFactorId = v),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isNotEmpty) {
                            habit.name = nameController.text.trim();
                            habit.triggerResponse = habit.type == HabitType.build 
                                ? triggerController.text.trim() 
                                : null;
                            habit.motivation = motivationController.text.trim();
                            habit.factorId = selectedFactorId;
                            habit.scheduledDays = selectedDays;
                            context.read<AppState>().updateHabit(habit);
                            Navigator.pop(ctx);
                          }
                        },
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AppState state, Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Habit?', style: TextStyle(color: AppColors.textPrimary)),
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
              Icon(icon, size: 18, color: isSelected ? color : AppColors.textMuted),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

/// Type selection chip for dialogs
class _DialogTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _DialogTypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            Icon(icon, size: 20, color: isSelected ? color : AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : AppColors.textMuted,
              ),
            ),
          ],
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
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: habit.isLoggedToday 
                  ? (habit.todayLog?.completed == true ? AppColors.success : AppColors.danger).withAlpha(20)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: habit.isLoggedToday 
                    ? (habit.todayLog?.completed == true ? AppColors.success : AppColors.danger)
                    : AppColors.glassBorder,
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
                    size: 22,
                  )
                : Icon(
                    habit.type == HabitType.build 
                        ? Icons.trending_up_rounded 
                        : Icons.block_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
          ),
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.type == HabitType.quit ? 'No ${habit.name}' : habit.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
                    style: TextStyle(fontSize: 12, color: AppColors.warning),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      '${habit.currentStreak}d streak',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.emoji_events_rounded, size: 14, color: AppColors.info),
                    const SizedBox(width: 4),
                    Text(
                      'Best: ${habit.bestStreak}d',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Actions
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 20, color: AppColors.info),
                    const SizedBox(width: 12),
                    Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, size: 20, color: AppColors.danger),
                    const SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: AppColors.danger)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
