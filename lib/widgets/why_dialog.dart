import 'package:flutter/material.dart';

import '../core/theme/theme.dart';
import '../models/task.dart';

/// Dialog to ask why a task is being abandoned/demoted
Future<TaskAbandonReason?> showWhyDialog(BuildContext context, Task task) async {
  return showModalBottomSheet<TaskAbandonReason>(
    context: context,
    backgroundColor: AppColors.surface,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Why are you removing this?', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'This helps identify patterns in your Weekly Audit.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          
          _WhyOption(
            emoji: '🕐',
            title: 'Ran out of time',
            subtitle: 'Planning issue - need better estimation',
            reason: TaskAbandonReason.noTime,
            onTap: () => Navigator.pop(ctx, TaskAbandonReason.noTime),
          ),
          
          _WhyOption(
            emoji: '🧗',
            title: 'Too hard',
            subtitle: 'Skill gap - need to break down or learn',
            reason: TaskAbandonReason.tooHard,
            onTap: () => Navigator.pop(ctx, TaskAbandonReason.tooHard),
          ),
          
          _WhyOption(
            emoji: '❌',
            title: 'Not important anymore',
            subtitle: 'Priority changed - focus shifted',
            reason: TaskAbandonReason.notImportant,
            onTap: () => Navigator.pop(ctx, TaskAbandonReason.notImportant),
          ),
          
          const SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Warning dialog when promoting a heavy task with low time
Future<bool> showRealityCheckDialog(BuildContext context, Task task, String availability) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          const SizedBox(width: 8),
          const Text('Reality Check'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This is a 🐘 Deep Work task, but you have "$availability" time available today.',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'Consider:',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 8),
          _SuggestionRow(icon: Icons.call_split_rounded, text: 'Break it into smaller tasks'),
          _SuggestionRow(icon: Icons.swap_horiz_rounded, text: 'Choose a ⚡ Quick task instead'),
          _SuggestionRow(icon: Icons.calendar_today_rounded, text: 'Save it for a day with more time'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('Choose Different', style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Add Anyway'),
        ),
      ],
    ),
  );
  return result ?? false;
}

class _WhyOption extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final TaskAbandonReason reason;
  final VoidCallback onTap;

  const _WhyOption({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.reason,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
        ],
      ),
    );
  }
}
