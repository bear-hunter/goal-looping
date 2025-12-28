import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/theme.dart';
import '../models/task.dart';

/// Premium task card with subtask expansion
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;
  final VoidCallback? onPromote;
  final VoidCallback? onDemote;
  final int subtaskCount;
  final int subtaskCompleted;
  final bool showActions;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onComplete,
    this.onDelete,
    this.onPromote,
    this.onDemote,
    this.subtaskCount = 0,
    this.subtaskCompleted = 0,
    this.showActions = true,
  });

  Color get sourceColor {
    switch (task.source) {
      case TaskSource.newEntry:
        return AppColors.primary;
      case TaskSource.experiment:
        return AppColors.warning;
      case TaskSource.backlog:
        return AppColors.textMuted;
    }
  }

  IconData get sourceIcon {
    switch (task.source) {
      case TaskSource.newEntry:
        return Icons.add_circle_outline_rounded;
      case TaskSource.experiment:
        return Icons.science_rounded;
      case TaskSource.backlog:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: task.isPriority
                    ? [
                        AppColors.primary.withOpacity(0.12),
                        AppColors.primary.withOpacity(0.05),
                      ]
                    : [
                        AppColors.surface,
                        AppColors.surface.withOpacity(0.8),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: task.isPriority 
                    ? AppColors.primary.withOpacity(0.4) 
                    : AppColors.glassBorder,
                width: task.isPriority ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Checkbox
                    GestureDetector(
                      onTap: onComplete,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: task.isCompleted 
                              ? AppColors.success 
                              : Colors.transparent,
                          border: Border.all(
                            color: task.isCompleted 
                                ? AppColors.success 
                                : AppColors.textMuted,
                            width: 2,
                          ),
                        ),
                        child: task.isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Title
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: task.isCompleted 
                              ? AppColors.textMuted 
                              : AppColors.textPrimary,
                          decoration: task.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                        ),
                      ),
                    ),

                    // Source indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: sourceColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        sourceIcon,
                        size: 16,
                        color: sourceColor,
                      ),
                    ),
                  ],
                ),

                // Subtask progress
                if (subtaskCount > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: subtaskCount > 0 
                                ? subtaskCompleted / subtaskCount 
                                : 0,
                            backgroundColor: AppColors.surfaceLight,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              task.isPriority 
                                  ? AppColors.primary 
                                  : AppColors.success,
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$subtaskCompleted/$subtaskCount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],

                // Action buttons
                if (showActions && !task.isCompleted) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (!task.isPriority)
                        _ActionButton(
                          icon: Icons.arrow_upward_rounded,
                          label: 'Promote',
                          color: AppColors.primary,
                          onTap: onPromote,
                        ),
                      if (task.isPriority)
                        _ActionButton(
                          icon: Icons.arrow_downward_rounded,
                          label: 'To Backlog',
                          color: AppColors.textMuted,
                          onTap: onDemote,
                        ),
                      const Spacer(),
                      _ActionButton(
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete',
                        color: AppColors.danger,
                        onTap: onDelete,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.02, end: 0);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
