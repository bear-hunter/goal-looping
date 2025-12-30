import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task.dart';
import 'task_card.dart';
import '../core/theme/theme.dart';

/// Swipeable wrapper for TaskCard with progressive disclosure gestures
/// - Swipe Right: Focus Mode (priority tasks) or Complete (all tasks)
/// - Swipe Left: Delete or Demote to backlog
class SwipeableTaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;
  final VoidCallback? onPromote;
  final VoidCallback? onDemote;
  final VoidCallback? onFocusMode;
  final int subtaskCount;
  final int subtaskCompleted;

  const SwipeableTaskCard({
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
  });

  @override
  State<SwipeableTaskCard> createState() => _SwipeableTaskCardState();
}

class _SwipeableTaskCardState extends State<SwipeableTaskCard>
    with SingleTickerProviderStateMixin {
  double _dragExtent = 0.0;
  bool _rightActionTriggered = false;
  bool _leftActionTriggered = false;

  // Threshold for triggering action (40% of card width)
  static const double _actionThreshold = 0.4;

  // Maximum drag extent (80% of card width)
  static const double _maxDragExtent = 0.8;

  late AnimationController _resetController;
  late Animation<double> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _resetAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(parent: _resetController, curve: Curves.easeOut));
    _resetController.addListener(() {
      setState(() => _dragExtent = _resetAnimation.value);
    });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      final delta = details.primaryDelta ?? 0;
      _dragExtent = (_dragExtent + delta).clamp(
        -MediaQuery.of(context).size.width * _maxDragExtent,
        MediaQuery.of(context).size.width * _maxDragExtent,
      );

      final threshold = MediaQuery.of(context).size.width * _actionThreshold;

      // Haptic feedback at threshold crossing
      if (_dragExtent > threshold && !_rightActionTriggered) {
        HapticFeedback.mediumImpact();
        _rightActionTriggered = true;
      } else if (_dragExtent <= threshold && _rightActionTriggered) {
        HapticFeedback.selectionClick();
        _rightActionTriggered = false;
      }

      if (_dragExtent < -threshold && !_leftActionTriggered) {
        HapticFeedback.mediumImpact();
        _leftActionTriggered = true;
      } else if (_dragExtent >= -threshold && _leftActionTriggered) {
        HapticFeedback.selectionClick();
        _leftActionTriggered = false;
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final threshold = MediaQuery.of(context).size.width * _actionThreshold;

    if (_dragExtent > threshold) {
      // Right swipe action
      HapticFeedback.heavyImpact();
      if (widget.task.isPriority && widget.onFocusMode != null) {
        widget.onFocusMode!();
      } else if (widget.onComplete != null) {
        widget.onComplete!();
      }
    } else if (_dragExtent < -threshold) {
      // Left swipe action
      HapticFeedback.heavyImpact();
      if (widget.task.isPriority && widget.onDemote != null) {
        widget.onDemote!();
      } else if (widget.onDelete != null) {
        widget.onDelete!();
      }
    }

    // Reset position
    _resetToCenter();
  }

  void _resetToCenter() {
    _resetAnimation = Tween<double>(
      begin: _dragExtent,
      end: 0,
    ).animate(CurvedAnimation(parent: _resetController, curve: Curves.easeOut));
    _resetController.forward(from: 0);
    _rightActionTriggered = false;
    _leftActionTriggered = false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardWidth = MediaQuery.of(context).size.width;
    final threshold = cardWidth * _actionThreshold;
    final rightProgress = (_dragExtent / threshold).clamp(0.0, 1.0);
    final leftProgress = (-_dragExtent / threshold).clamp(0.0, 1.0);

    return Stack(
      children: [
        // Right swipe background (green - Focus/Complete)
        if (_dragExtent > 0)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success.withAlpha((rightProgress * 200).toInt()),
                    AppColors.success.withAlpha((rightProgress * 100).toInt()),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.task.isPriority
                            ? Icons.center_focus_strong_rounded
                            : Icons.check_rounded,
                        color: Colors.white,
                        size: 28 * rightProgress,
                      ),
                      if (rightProgress > 0.5) ...[
                        const SizedBox(width: 8),
                        Text(
                          widget.task.isPriority ? 'Focus' : 'Complete',
                          style: TextStyle(
                            color: Colors.white.withAlpha(
                              (rightProgress * 255).toInt(),
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Left swipe background (red/gray - Delete/Demote)
        if (_dragExtent < 0)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.task.isPriority
                      ? [
                          (isDark ? AppColors.textMuted : LightColors.textMuted)
                              .withAlpha((leftProgress * 150).toInt()),
                          (isDark ? AppColors.textMuted : LightColors.textMuted)
                              .withAlpha((leftProgress * 80).toInt()),
                        ]
                      : [
                          AppColors.danger.withAlpha(
                            (leftProgress * 200).toInt(),
                          ),
                          AppColors.danger.withAlpha(
                            (leftProgress * 100).toInt(),
                          ),
                        ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (leftProgress > 0.5) ...[
                        Text(
                          widget.task.isPriority ? 'Demote' : 'Delete',
                          style: TextStyle(
                            color: Colors.white.withAlpha(
                              (leftProgress * 255).toInt(),
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Icon(
                        widget.task.isPriority
                            ? Icons.arrow_downward_rounded
                            : Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: 28 * leftProgress,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // The actual card (translated by drag)
        Transform.translate(
          offset: Offset(_dragExtent, 0),
          child: GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: TaskCard(
              task: widget.task,
              subtaskCount: widget.subtaskCount,
              subtaskCompleted: widget.subtaskCompleted,
              showActions: false, // Hide persistent buttons - swipe handles it
              onTap: widget.onTap,
              onComplete: widget.onComplete,
              onDelete: widget.onDelete,
              onPromote: widget.onPromote,
              onDemote: widget.onDemote,
              onFocusMode: widget.onFocusMode,
            ),
          ),
        ),
      ],
    );
  }
}
