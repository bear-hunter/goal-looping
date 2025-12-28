import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/theme.dart';
import '../models/habit.dart';

/// Dialog for mood rating and barrier logging (Proddy-style)
class MoodBarrierDialog extends StatefulWidget {
  final bool habitCompleted;
  final String habitName;
  final Function(int? mood, String? barrier) onSubmit;

  const MoodBarrierDialog({
    super.key,
    required this.habitCompleted,
    required this.habitName,
    required this.onSubmit,
  });

  @override
  State<MoodBarrierDialog> createState() => _MoodBarrierDialogState();

  /// Show the dialog and return mood + barrier
  static Future<void> show(
    BuildContext context, {
    required bool habitCompleted,
    required String habitName,
    required Function(int? mood, String? barrier) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => MoodBarrierDialog(
        habitCompleted: habitCompleted,
        habitName: habitName,
        onSubmit: (mood, barrier) {
          onSubmit(mood, barrier);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _MoodBarrierDialogState extends State<MoodBarrierDialog> {
  int? _selectedMood;
  String? _selectedBarrier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            widget.habitCompleted 
                ? '${widget.habitName} ✓' 
                : '${widget.habitName} ✗',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: widget.habitCompleted ? AppColors.success : AppColors.danger,
            ),
          ).animate().fadeIn(duration: 200.ms),
          
          const SizedBox(height: 8),
          Text(
            widget.habitCompleted 
                ? 'How are you feeling?' 
                : 'What got in the way?',
            style: TextStyle(color: AppColors.textSecondary),
          ),

          const SizedBox(height: 20),

          // Mood selector (always shown)
          Text('Mood', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final mood = index + 1;
              return _MoodButton(
                mood: mood,
                isSelected: _selectedMood == mood,
                onTap: () => setState(() => _selectedMood = mood),
              );
            }),
          ),

          // Barrier tags (shown for missed habits or optionally for completed)
          const SizedBox(height: 20),
          Text('Barrier (optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BarrierTags.common.map((tag) => _BarrierChip(
              tag: tag,
              isSelected: _selectedBarrier == tag,
              onTap: () => setState(() => _selectedBarrier = _selectedBarrier == tag ? null : tag),
            )).toList(),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => widget.onSubmit(null, null),
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => widget.onSubmit(_selectedMood, _selectedBarrier),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  final int mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodButton({required this.mood, required this.isSelected, required this.onTap});

  String get _emoji {
    switch (mood) {
      case 1: return '😢';
      case 2: return '😕';
      case 3: return '😐';
      case 4: return '🙂';
      case 5: return '😄';
      default: return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(30) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(_emoji, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}

class _BarrierChip extends StatelessWidget {
  final String tag;
  final bool isSelected;
  final VoidCallback onTap;

  const _BarrierChip({required this.tag, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.warning.withAlpha(30) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.warning : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.warning : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
