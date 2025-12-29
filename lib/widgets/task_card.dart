import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/theme.dart';
import '../models/task.dart';

/// Premium task card with smart features:
/// - Effort/Impact tags
/// - Staleness detection
/// - Focus Mode entry
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;
  final VoidCallback? onPromote;
  final VoidCallback? onDemote;
  final VoidCallback? onFocusMode; // NEW: Enter focus mode
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
    this.onFocusMode,
    this.subtaskCount = 0,
    this.subtaskCompleted = 0,
    this.showActions = true,
  });

  Color getSourceColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (task.source) {
      case TaskSource.newEntry:
        return AppColors.primary;
      case TaskSource.experiment:
        return AppColors.warning;
      case TaskSource.backlog:
        return isDark ? AppColors.textMuted : LightColors.textMuted;
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
    final isStale = task.isStale;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surface : LightColors.surface;
    final surfaceLight = isDark ? AppColors.surfaceLight : LightColors.surfaceLight;
    final glassBorder = isDark ? AppColors.glassBorder : LightColors.glassBorder;
    final textPrimary = isDark ? AppColors.textPrimary : LightColors.textPrimary;
    final textMuted = isDark ? AppColors.textMuted : LightColors.textMuted;
    final sourceColor = getSourceColor(context);
    
    // Build semantic label for screen readers
    final semanticLabel = _buildSemanticLabel();
    
    return Semantics(
      label: semanticLabel,
      button: true,
      child: Container(
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
                        isStale
                            ? AppColors.warning.withAlpha(30)
                            : AppColors.primary.withAlpha(30),
                        isStale
                            ? AppColors.warning.withAlpha(12)
                            : AppColors.primary.withAlpha(12),
                      ]
                    : [
                        surfaceColor,
                        surfaceColor.withAlpha(isDark ? 200 : 255),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isStale
                    ? AppColors.warning.withAlpha(100)
                    : task.isPriority 
                        ? AppColors.primary.withAlpha(100) 
                        : glassBorder,
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
                                : textMuted,
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
                              ? textMuted 
                              : textPrimary,
                          decoration: task.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                        ),
                      ),
                    ),

                    // Effort/Impact tags
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: surfaceLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${task.effortEmoji} ${task.impactEmoji}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    
                    const SizedBox(width: 6),

                    // Source indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: sourceColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        sourceIcon,
                        size: 16,
                        color: sourceColor,
                      ),
                    ),

                    if (task.customTag != null && task.customTag!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primary.withAlpha(50)),
                        ),
                        child: Text(
                          task.customTag!,
                          style: TextStyle(
                            fontSize: 11, 
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Staleness warning
                if (isStale && task.isPriority && !task.isCompleted) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warning.withAlpha(60)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hourglass_bottom_rounded, size: 14, color: AppColors.warning),
                        const SizedBox(width: 6),
                        Text(
                          '⚡ Stuck for ${task.hoursInPriority}h - Break it down?',
                          style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],

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
                            backgroundColor: surfaceLight,
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
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ],

                // Deadline Indicator
                if (task.deadline != null && !task.isCompleted) ...[
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final deadlineDate = DateTime(task.deadline!.year, task.deadline!.month, task.deadline!.day);
                      final daysRemaining = deadlineDate.difference(today).inDays;
                      
                      Color deadlineColor;
                      if (daysRemaining < 0) {
                        deadlineColor = AppColors.danger;
                      } else if (daysRemaining <= 2) {
                        deadlineColor = AppColors.warning;
                      } else {
                        deadlineColor = AppColors.info;
                      }
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: deadlineColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: deadlineColor.withAlpha(40)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event_note_rounded, size: 14, color: deadlineColor),
                            const SizedBox(width: 6),
                            Text(
                              daysRemaining < 0 
                                  ? 'Overdue (${daysRemaining.abs()}d)' 
                                  : (daysRemaining == 0 ? 'Due Today' : '$daysRemaining days left'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: deadlineColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],

                // Action buttons
                if (showActions && !task.isCompleted) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Focus Mode button (only for priority tasks)
                      if (task.isPriority && onFocusMode != null)
                        _ActionButton(
                          icon: Icons.center_focus_strong_rounded,
                          label: 'Focus',
                          color: AppColors.success,
                          onTap: onFocusMode,
                        ),
                      if (task.isPriority && onFocusMode != null)
                        const SizedBox(width: 8),
                      
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
                          color: textMuted,
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
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.02, end: 0);
  }

  /// Build a comprehensive semantic label for screen readers
  String _buildSemanticLabel() {
    final buffer = StringBuffer();
    
    // Task status
    if (task.isCompleted) {
      buffer.write('Completed task. ');
    } else if (task.isPriority) {
      buffer.write('Priority task. ');
    } else {
      buffer.write('Backlog task. ');
    }
    
    // Task title
    buffer.write('${task.title}. ');
    
    // Effort and impact
    buffer.write('Effort: ${task.effort.name}. ');
    buffer.write('Impact: ${task.impact.name}. ');
    
    // Category
    buffer.write('Category: ${task.category}. ');
    
    // Deadline
    if (task.deadline != null) {
      final now = DateTime.now();
      final difference = task.deadline!.difference(now).inDays;
      if (difference < 0) {
        buffer.write('Overdue by ${difference.abs()} days. ');
      } else if (difference == 0) {
        buffer.write('Due today. ');
      } else {
        buffer.write('Due in $difference days. ');
      }
    }
    
    // Staleness
    if (task.isStale) {
      buffer.write('Has been in priority for ${task.hoursInPriority} hours. ');
    }
    
    // Subtasks
    if (subtaskCount > 0) {
      buffer.write('$subtaskCompleted of $subtaskCount subtasks complete. ');
    }
    
    // Available actions
    if (showActions && !task.isCompleted) {
      buffer.write('Double tap to edit. ');
    }
    
    return buffer.toString();
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44), // WCAG minimum touch target
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
