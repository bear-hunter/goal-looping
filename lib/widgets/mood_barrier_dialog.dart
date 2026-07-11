import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/theme.dart';
import '../models/barrier_tag.dart';

/// Bottom sheet for capturing mood and a barrier tag in-context (e.g. right
/// after a habit is marked failed on the Today screen).
///
/// Presentation-only: it never writes data. [onSubmit] receives the chosen
/// mood (1-5, nullable) and a barrier tag *key* (see [BarrierTags], nullable);
/// the caller decides what to persist. Tapping "Skip" submits `(null, null)`.
class MoodBarrierDialog extends StatefulWidget {
  final bool habitCompleted;
  final String habitName;
  final void Function(int? mood, String? barrierKey) onSubmit;

  const MoodBarrierDialog({
    super.key,
    required this.habitCompleted,
    required this.habitName,
    required this.onSubmit,
  });

  @override
  State<MoodBarrierDialog> createState() => _MoodBarrierDialogState();

  static Future<void> show(
    BuildContext context, {
    required bool habitCompleted,
    required String habitName,
    required void Function(int? mood, String? barrierKey) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => MoodBarrierDialog(
        habitCompleted: habitCompleted,
        habitName: habitName,
        onSubmit: (mood, barrierKey) {
          onSubmit(mood, barrierKey);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _MoodBarrierDialogState extends State<MoodBarrierDialog> {
  int? _selectedMood;
  String? _selectedBarrierKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Icon(
                widget.habitCompleted
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: widget.habitCompleted ? colors.success : colors.danger,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.habitName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: widget.habitCompleted
                        ? colors.success
                        : colors.danger,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: AppMotion.micro),

          const SizedBox(height: 8),
          Text(
            widget.habitCompleted
                ? 'How are you feeling?'
                : 'What got in the way?',
            style: TextStyle(color: colors.textSecondary),
          ),

          const SizedBox(height: 20),

          Text(
            'Mood',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textMuted,
            ),
          ),
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

          const SizedBox(height: 20),
          Text(
            'Barrier (optional)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BarrierTags.all
                .map(
                  (info) => _BarrierChip(
                    info: info,
                    isSelected: _selectedBarrierKey == info.key,
                    onTap: () => setState(
                      () => _selectedBarrierKey =
                          _selectedBarrierKey == info.key ? null : info.key,
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 24),

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
                  onPressed: () =>
                      widget.onSubmit(_selectedMood, _selectedBarrierKey),
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

  const _MoodButton({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  String get _emoji {
    switch (mood) {
      case 1:
        return '😢';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.standard,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withAlpha(30)
              : colors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? colors.primary : colors.glassBorder,
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
  final BarrierTagInfo info;
  final bool isSelected;
  final VoidCallback onTap;

  const _BarrierChip({
    required this.info,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.standard,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.warning.withAlpha(30)
              : colors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? colors.warning : colors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              info.icon,
              size: 15,
              color: isSelected ? colors.warning : colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              info.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? colors.warning : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
