import 'package:flutter/material.dart';

import '../core/theme/theme.dart';
import '../models/task.dart';

/// Dialog to ask why a task is being abandoned/demoted
Future<TaskAbandonReason?> showWhyDialog(BuildContext context, Task task) async {
  final colors = context.colors;
  return showModalBottomSheet<TaskAbandonReason>(
    context: context,
    backgroundColor: colors.surface,
    builder: (ctx) {
      final innerColors = ctx.colors;
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why are you removing this?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'This helps identify patterns in your Weekly Audit.',
              style: TextStyle(color: innerColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),

            _WhyOption(
              icon: Icons.access_time_rounded,
              tint: innerColors.warning,
              title: 'Ran out of time',
              subtitle: 'Planning issue — need better estimation',
              reason: TaskAbandonReason.noTime,
              onTap: () => Navigator.pop(ctx, TaskAbandonReason.noTime),
            ),

            _WhyOption(
              icon: Icons.terrain_rounded,
              tint: innerColors.info,
              title: 'Too hard',
              subtitle: 'Skill gap — break down or learn',
              reason: TaskAbandonReason.tooHard,
              onTap: () => Navigator.pop(ctx, TaskAbandonReason.tooHard),
            ),

            _WhyOption(
              icon: Icons.close_rounded,
              tint: innerColors.danger,
              title: 'Not important anymore',
              subtitle: 'Priority changed — focus shifted',
              reason: TaskAbandonReason.notImportant,
              onTap: () => Navigator.pop(ctx, TaskAbandonReason.notImportant),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: innerColors.textMuted),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Warning dialog when promoting a heavy task with low time
Future<bool> showRealityCheckDialog(
  BuildContext context,
  Task task,
  String availability,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final colors = ctx.colors;
      return AlertDialog(
        backgroundColor: colors.surface,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colors.warning),
            const SizedBox(width: 8),
            const Text('Reality Check'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This is a deep-work task, but you have "$availability" time available today.',
              style: TextStyle(color: colors.textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              'Consider:',
              style: TextStyle(color: colors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 8),
            const _SuggestionRow(
              icon: Icons.call_split_rounded,
              text: 'Break it into smaller tasks',
            ),
            const _SuggestionRow(
              icon: Icons.swap_horiz_rounded,
              text: 'Choose a quick task instead',
            ),
            const _SuggestionRow(
              icon: Icons.calendar_today_rounded,
              text: 'Save it for a day with more time',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Choose Different',
              style: TextStyle(color: colors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add Anyway'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

class _WhyOption extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String title;
  final String subtitle;
  final TaskAbandonReason reason;
  final VoidCallback onTap;

  const _WhyOption({
    required this.icon,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.reason,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tint.withAlpha(30),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 18, color: tint),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SuggestionRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: colors.textPrimary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
