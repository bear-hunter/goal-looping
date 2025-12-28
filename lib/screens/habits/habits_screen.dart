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
import 'habit_detail_screen.dart';

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
                      onTap: () => _showEditBarrierDialog(context, barrier),
                      child: Row(
                        children: [
                          Icon(
                            barrier.wasHandled ? Icons.check_circle_rounded : Icons.flash_on_rounded, 
                            color: barrier.wasHandled ? AppColors.success : AppColors.warning, 
                            size: 20
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(barrier.description, style: TextStyle(color: AppColors.textPrimary)),
                                if (barrier.response != null && barrier.response!.isNotEmpty)
                                  Text('Response: ${barrier.response}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
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
    final nameController = TextEditingController(); // Action (I will Y)
    final triggerController = TextEditingController(); // Trigger (If X)
    final motivationController = TextEditingController();
    String? selectedFactorId;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type == HabitType.quit ? 'Add Quit Habit' : 'Add Build Habit',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                if (type == HabitType.build) ...[
                  Text('Trigger:', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: triggerController,
                    decoration: const InputDecoration(hintText: 'If [this happens]... (e.g., I feel stressed)'),
                  ),
                  const SizedBox(height: 12),
                  Text('Action:', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: 'I will [do this]... (e.g., breathe for 1 min)'),
                  ),
                ] else ...[
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: type == HabitType.quit ? 'e.g., Doom scrolling' : 'e.g., Morning exercise',
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: motivationController,
                  decoration: const InputDecoration(hintText: 'Why? (motivation)'),
                ),
                const SizedBox(height: 12),
                
                // Factor dropdown
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
                
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: (selectedFactorId == null) 
                        ? Text('Linking to a Factor helps track effort', style: TextStyle(fontSize: 12, color: AppColors.warning))
                        : const SizedBox(),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          context.read<AppState>().addHabit(Habit(
                            id: StorageService.generateId(),
                            name: nameController.text.trim(),
                            type: type,
                            triggerResponse: type == HabitType.build ? triggerController.text.trim() : null,
                            motivation: motivationController.text.trim(),
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
      ),
    );
  }

  void _showAddBarrierDialog(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Log Barrier', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: controller, 
              autofocus: true,
              decoration: const InputDecoration(hintText: 'What barrier did you encounter?'),
            ),
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

  void _showEditBarrierDialog(BuildContext context, BarrierEntry barrier) {
    final controller = TextEditingController(text: barrier.description);
    final responseController = TextEditingController(text: barrier.response);
    bool handled = barrier.wasHandled;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Barrier', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: responseController,
                decoration: const InputDecoration(labelText: 'How did you handle it?'),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Handled successfully?'),
                value: handled,
                onChanged: (v) => setModalState(() => handled = v),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      context.read<AppState>().updateBarrier(barrier); // Placeholder for delete if needed
                      Navigator.pop(ctx);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      barrier.description = controller.text.trim();
                      barrier.response = responseController.text.trim();
                      barrier.wasHandled = handled;
                      context.read<AppState>().updateBarrier(barrier);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
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

/// Habit card with swipe-to-reveal actions and expandable calendar
class _HabitCardWithCalendar extends StatefulWidget {
  final Habit habit;
  final bool isQuit;

  const _HabitCardWithCalendar({required this.habit, required this.isQuit});

  @override
  State<_HabitCardWithCalendar> createState() => _HabitCardWithCalendarState();
}

class _HabitCardWithCalendarState extends State<_HabitCardWithCalendar> 
    with SingleTickerProviderStateMixin {
  bool _showCalendar = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isRevealed = false;
  static const double _revealWidth = 100.0;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.22, 0), // Slide left to reveal buttons
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _toggleReveal() {
    if (_isRevealed) {
      _slideController.reverse();
    } else {
      _slideController.forward();
    }
    setState(() => _isRevealed = !_isRevealed);
  }

  void _closeReveal() {
    if (_isRevealed) {
      _slideController.reverse();
      setState(() => _isRevealed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final isQuit = widget.isQuit;

    return GlassCard(
      child: Column(
        children: [
          // Swipeable row with action buttons behind
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Action buttons (revealed on swipe)
                if (!habit.isLoggedToday)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: _revealWidth,
                        padding: const EdgeInsets.only(left: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _SwipeActionButton(
                              icon: Icons.check_rounded,
                              color: AppColors.success,
                              onTap: () {
                                _closeReveal();
                                _logWithMood(context, true);
                              },
                            ),
                            const SizedBox(width: 8),
                            _SwipeActionButton(
                              icon: Icons.close_rounded,
                              color: AppColors.danger,
                              onTap: () {
                                _closeReveal();
                                _logWithMood(context, false);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                
                // Main content (slides left on swipe)
                GestureDetector(
                  onHorizontalDragEnd: habit.isLoggedToday ? null : (details) {
                    if (details.primaryVelocity != null) {
                      if (details.primaryVelocity! < -100) {
                        // Swipe left - reveal actions
                        if (!_isRevealed) _toggleReveal();
                      } else if (details.primaryVelocity! > 100) {
                        // Swipe right - hide actions
                        if (_isRevealed) _toggleReveal();
                      }
                    }
                  },
                  onTap: _isRevealed 
                      ? _closeReveal 
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => HabitDetailScreen(habitId: habit.id)),
                        ),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      color: AppColors.surface, // Background to cover buttons
                      child: Row(
                        children: [
                          StreakIndicator(streak: habit.currentStreak, size: 44),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isQuit ? 'No ${habit.name}' : habit.name,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    Text('🔥 ${habit.currentStreak}d', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                    Text(' • ', style: TextStyle(color: AppColors.textMuted)),
                                    Text('Best: ${habit.bestStreak}d', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                    if (habit.targetFrequency > 1) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: AppColors.info.withAlpha(30),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${_getCompletionsThisWeek()}/${habit.targetFrequency}/wk',
                                          style: TextStyle(fontSize: 9, color: AppColors.info, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Status or swipe hint
                          if (habit.isLoggedToday)
                            Icon(
                              habit.todayLog?.completed == true ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              color: habit.todayLog?.completed == true ? AppColors.success : AppColors.danger,
                              size: 22,
                            )
                          else if (!_isRevealed)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.chevron_left_rounded, size: 16, color: AppColors.textMuted.withAlpha(100)),
                                Text('swipe', style: TextStyle(fontSize: 10, color: AppColors.textMuted.withAlpha(100))),
                              ],
                            ),
                          
                          // Calendar toggle
                          IconButton(
                            icon: Icon(
                              _showCalendar ? Icons.expand_less_rounded : Icons.calendar_month_rounded,
                              color: AppColors.textMuted,
                              size: 18,
                            ),
                            onPressed: () => setState(() => _showCalendar = !_showCalendar),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Expandable calendar
          if (_showCalendar) ...[
            const SizedBox(height: 12),
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

/// Swipe action button for habit cards (used in swipe-to-reveal pattern)
class _SwipeActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SwipeActionButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: color.withAlpha(80), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 22),
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
