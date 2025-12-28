import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/habit.dart';
import '../../providers/app_state.dart';
import '../../services/storage_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/progress_ring.dart';

/// Module 3: Habit & Barrier Defense Screen
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
                  onAdd: () => _showAddHabitDialog(context, HabitType.limiting),
                ),
              ),

              if (state.limitingHabits.isEmpty)
                SliverToBoxAdapter(child: _EmptyCard(
                  text: 'Add habits to avoid',
                  onTap: () => _showAddHabitDialog(context, HabitType.limiting),
                ))
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _HabitCard(habit: state.limitingHabits[index]),
                    childCount: state.limitingHabits.length,
                  ),
                ),

              // Scripted Actions Section
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Scripted Actions',
                  subtitle: 'If X happens → I will do Y',
                  icon: Icons.code_rounded,
                  color: AppColors.success,
                  onAdd: () => _showAddHabitDialog(context, HabitType.scripted),
                ),
              ),

              if (state.scriptedActions.isEmpty)
                SliverToBoxAdapter(child: _EmptyCard(
                  text: 'Add scripted responses',
                  onTap: () => _showAddHabitDialog(context, HabitType.scripted),
                ))
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ScriptedCard(habit: state.scriptedActions[index]),
                    childCount: state.scriptedActions.length,
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
                          Expanded(child: Text(barrier.description, style: TextStyle(color: AppColors.textPrimary))),
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

  void _showAddHabitDialog(BuildContext context, HabitType type) {
    final nameController = TextEditingController();
    final triggerController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(type == HabitType.limiting ? 'Add Limiting Habit' : 'Add Scripted Action',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: type == HabitType.limiting ? 'e.g., Doom scrolling' : 'e.g., Take 3 deep breaths',
              ),
            ),
            if (type == HabitType.scripted) ...[
              const SizedBox(height: 12),
              TextField(
                controller: triggerController,
                decoration: const InputDecoration(hintText: 'Trigger: When I feel...'),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  context.read<AppState>().addHabit(Habit(
                    id: StorageService.generateId(),
                    name: nameController.text,
                    type: type,
                    triggerResponse: triggerController.text.isNotEmpty ? triggerController.text : null,
                  ));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
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
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
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

class _HabitCard extends StatelessWidget {
  final Habit habit;

  const _HabitCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          StreakIndicator(streak: habit.currentStreak, size: 50),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No ${habit.name}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text('Best: ${habit.bestStreak} days', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          if (!habit.isLoggedToday)
            Row(
              children: [
                _CheckButton(
                  icon: Icons.check_rounded,
                  color: AppColors.success,
                  onTap: () => context.read<AppState>().logHabit(habit.id, succumbed: false),
                ),
                const SizedBox(width: 8),
                _CheckButton(
                  icon: Icons.close_rounded,
                  color: AppColors.danger,
                  onTap: () => context.read<AppState>().logHabit(habit.id, succumbed: true),
                ),
              ],
            )
          else
            Icon(
              habit.todayLog?.succumbed == true ? Icons.close_rounded : Icons.check_rounded,
              color: habit.todayLog?.succumbed == true ? AppColors.danger : AppColors.success,
            ),
        ],
      ),
    );
  }
}

class _ScriptedCard extends StatelessWidget {
  final Habit habit;

  const _ScriptedCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text('${habit.scriptedUseCount}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.success)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                if (habit.triggerResponse != null)
                  Text('When: ${habit.triggerResponse}', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.read<AppState>().logHabit(habit.id, succumbed: true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, padding: const EdgeInsets.symmetric(horizontal: 16)),
            child: const Text('Used'),
          ),
        ],
      ),
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
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
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
