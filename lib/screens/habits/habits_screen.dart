import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/habit.dart';
import '../../providers/app_state.dart';
import '../../services/storage_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/habit_calendar.dart';
import '../../widgets/mood_barrier_dialog.dart';

/// Module 3: Habit & Barrier Defense Screen (Phase 3 Updated)
class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Habit Defense', style: Theme.of(context).textTheme.displayMedium)
                          .animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 8),
                      Text('Track habits & defend against barriers',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),

              // Limiting Habits Section
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Limiting Habits',
                  subtitle: 'Track the absence of bad habits',
                  icon: Icons.block_rounded,
                  color: AppColors.danger,
                  onAdd: () => _showAddHabitDialog(context, state, HabitType.quit),
                ),
              ),

              if (state.quitHabits.isEmpty)
                SliverToBoxAdapter(child: _EmptyCard(
                  text: 'Add limiting habits to avoid',
                  onTap: () => _showAddHabitDialog(context, state, HabitType.quit),
                ))
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _HabitCardWithCalendar(
                      habit: state.quitHabits[index],
                      isQuit: true,
                    ),
                    childCount: state.quitHabits.length,
                  ),
                ),

              // Scripted Actions Section
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Scripted Actions',
                  subtitle: 'If X happens → I will do Y',
                  icon: Icons.code_rounded,
                  color: AppColors.success,
                  onAdd: () => _showAddHabitDialog(context, state, HabitType.build),
                ),
              ),

              if (state.buildHabits.isEmpty)
                SliverToBoxAdapter(child: _EmptyCard(
                  text: 'Add scripted responses',
                  onTap: () => _showAddHabitDialog(context, state, HabitType.build),
                ))
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _HabitCardWithCalendar(
                      habit: state.buildHabits[index],
                      isQuit: false,
                    ),
                    childCount: state.buildHabits.length,
                  ),
                ),

              // Barrier Journal Section
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Barrier Journal',
                  subtitle: 'Log unexpected barriers',
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  onAdd: () => _showAddBarrierDialog(context),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final barrier = state.barriers[index];
                    return GlassCard(
                      child: Row(
                        children: [
                          Icon(Icons.flash_on_rounded, color: AppColors.warning, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(barrier.description, style: TextStyle(color: AppColors.textPrimary)),
                                Text(_formatDate(barrier.occurredAt), style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: state.barriers.length,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddHabitDialog(BuildContext context, AppState state, HabitType type) {
    final nameController = TextEditingController();
    final motivationController = TextEditingController();
    String? selectedFactorId;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(type == HabitType.quit ? 'Add Quit Habit' : 'Add Build Habit',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: type == HabitType.quit ? 'e.g., Doom scrolling' : 'e.g., Morning exercise',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: motivationController,
                decoration: const InputDecoration(hintText: 'Why? (motivation)'),
              ),
              const SizedBox(height: 12),
              
              // Factor dropdown (mandatory linking)
              Text('Link to Factor', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
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
                      DropdownMenuItem<String>(value: null, child: Text('None', style: TextStyle(color: AppColors.textMuted))),
                      ...state.factors.map((f) => DropdownMenuItem<String>(
                        value: f.id,
                        child: Text(f.name, style: TextStyle(color: AppColors.textPrimary)),
                      )),
                    ],
                    onChanged: (v) => setDialogState(() => selectedFactorId = v),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              Row(
                children: [
                  if (selectedFactorId == null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                    ),
                  if (selectedFactorId == null)
                    Expanded(child: Text('Linking to a Factor helps track effort', style: TextStyle(fontSize: 12, color: AppColors.warning))),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        context.read<AppState>().addHabit(Habit(
                          id: StorageService.generateId(),
                          name: nameController.text,
                          type: type,
                          motivation: motivationController.text,
                          factorId: selectedFactorId,
                        ));
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBarrierDialog(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: controller, decoration: const InputDecoration(hintText: 'What barrier did you encounter?')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<AppState>().addBarrier(BarrierEntry(
                    id: StorageService.generateId(),
                    description: controller.text,
                  ));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Log Barrier'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onAdd;

  const _SectionHeader({required this.title, required this.subtitle, required this.icon, required this.color, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          if (onAdd != null) IconButton(onPressed: onAdd, icon: Icon(Icons.add_rounded, color: color)),
        ],
      ),
    );
  }
}

/// Habit card with expandable calendar view
class _HabitCardWithCalendar extends StatefulWidget {
  final Habit habit;
  final bool isQuit;

  const _HabitCardWithCalendar({required this.habit, required this.isQuit});

  @override
  State<_HabitCardWithCalendar> createState() => _HabitCardWithCalendarState();
}

class _HabitCardWithCalendarState extends State<_HabitCardWithCalendar> {
  bool _showCalendar = false;

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final isQuit = widget.isQuit;

    return GlassCard(
      child: Column(
        children: [
          // Main row
          Row(
            children: [
              StreakIndicator(streak: habit.currentStreak, size: 50),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isQuit ? 'No ${habit.name}' : habit.name,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    Row(
                      children: [
                        Text('Best: ${habit.bestStreak}d', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        if (habit.targetFrequency > 1) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.info.withAlpha(30),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${_getCompletionsThisWeek()}/${habit.targetFrequency}/wk',
                              style: TextStyle(fontSize: 10, color: AppColors.info, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (habit.motivation.isNotEmpty)
                      Text(habit.motivation, style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              
              // Actions
              if (!habit.isLoggedToday)
                Row(
                  children: [
                    _CheckButton(
                      icon: Icons.check_rounded,
                      color: AppColors.success,
                      onTap: () => _logWithMood(context, true),
                    ),
                    const SizedBox(width: 8),
                    _CheckButton(
                      icon: Icons.close_rounded,
                      color: AppColors.danger,
                      onTap: () => _logWithMood(context, false),
                    ),
                  ],
                )
              else
                Icon(
                  habit.todayLog?.completed == true ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: habit.todayLog?.completed == true ? AppColors.success : AppColors.danger,
                ),
              
              // Calendar toggle
              IconButton(
                icon: Icon(
                  _showCalendar ? Icons.expand_less_rounded : Icons.calendar_month_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _showCalendar = !_showCalendar),
              ),
            ],
          ),
          
          // Expandable calendar
          if (_showCalendar) ...[
            const SizedBox(height: 16),
            HabitCalendar(habit: habit),
          ],
        ],
      ),
    );
  }

  int _getCompletionsThisWeek() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return widget.habit.logs.where((l) => l.date.isAfter(weekAgo) && l.completed).length;
  }

  void _logWithMood(BuildContext context, bool completed) {
    MoodBarrierDialog.show(
      context,
      habitCompleted: completed,
      habitName: widget.habit.name,
      onSubmit: (mood, barrier) {
        context.read<AppState>().logHabit(
          widget.habit.id,
          completed: completed,
          mood: mood,
          barrier: barrier,
        );
      },
    );
  }
}

class _CheckButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CheckButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _EmptyCard({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Center(child: Text(text, style: TextStyle(color: AppColors.textMuted))),
    );
  }
}
