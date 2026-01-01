import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/theme.dart';

/// A reusable empty state widget with illustration and action button
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final bool animate;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon container
            _buildIconContainer(),
            const SizedBox(height: 24),
            
            // Title
            _buildTitle(),
            const SizedBox(height: 8),
            
            // Subtitle
            _buildSubtitle(),
            
            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              _buildActionButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer() {
    final container = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: (iconColor ?? AppColors.primary).withAlpha(20),
        shape: BoxShape.circle,
        border: Border.all(
          color: (iconColor ?? AppColors.primary).withAlpha(40),
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        size: 48,
        color: iconColor ?? AppColors.primary,
      ),
    );
    
    if (!animate) return container;
    return container
      .animate()
      .scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.elasticOut)
      .fadeIn(duration: 300.ms);
  }

  Widget _buildTitle() {
    final text = Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
    
    if (!animate) return text;
    return text
      .animate()
      .fadeIn(duration: 300.ms, delay: 100.ms)
      .slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  Widget _buildSubtitle() {
    final text = Text(
      subtitle,
      style: TextStyle(
        fontSize: 14,
        color: AppColors.textMuted,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
    
    if (!animate) return text;
    return text
      .animate()
      .fadeIn(duration: 300.ms, delay: 200.ms)
      .slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  Widget _buildActionButton() {
    final button = ElevatedButton.icon(
      onPressed: onAction,
      icon: const Icon(Icons.add_rounded, size: 20),
      label: Text(actionLabel!),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
    
    if (!animate) return button;
    return button
      .animate()
      .fadeIn(duration: 300.ms, delay: 300.ms)
      .slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  /// Factory for task-related empty states
  factory EmptyState.tasks({VoidCallback? onAdd}) {
    return EmptyState(
      icon: Icons.task_alt_rounded,
      title: 'No Tasks Yet',
      subtitle: 'Add your first priority task to get started on your most important work.',
      actionLabel: 'Add Task',
      onAction: onAdd,
      iconColor: AppColors.primary,
    );
  }

  /// Factory for habits empty state
  factory EmptyState.habits({VoidCallback? onAdd}) {
    return EmptyState(
      icon: Icons.auto_awesome_rounded,
      title: 'No Habits Yet',
      subtitle: 'Build positive habits or break limiting ones to support your goals.',
      actionLabel: 'Add First Habit',
      onAction: onAdd,
      iconColor: AppColors.success,
    );
  }

  /// Factory for reflections empty state
  factory EmptyState.reflections({VoidCallback? onAdd}) {
    return EmptyState(
      icon: Icons.psychology_rounded,
      title: 'Start Reflecting',
      subtitle: 'Use the Kolb cycle to learn from experiences and continuously improve.',
      actionLabel: 'New Reflection',
      onAction: onAdd,
      iconColor: AppColors.info,
    );
  }

  /// Factory for goals empty state
  factory EmptyState.goals({VoidCallback? onAdd}) {
    return EmptyState(
      icon: Icons.flag_rounded,
      title: 'Set Your Direction',
      subtitle: 'Define a goal to anchor your work and create a clear path forward.',
      actionLabel: 'Add Goal',
      onAction: onAdd,
      iconColor: AppColors.warning,
    );
  }

  /// Factory for search results empty state
  factory EmptyState.noResults({String query = ''}) {
    return EmptyState(
      icon: Icons.search_off_rounded,
      title: 'No Results Found',
      subtitle: query.isEmpty 
          ? 'Try adjusting your filters to find what you\'re looking for.'
          : 'No matches for "$query". Try a different search term.',
      iconColor: AppColors.textMuted,
    );
  }

  /// Factory for completed items empty state
  factory EmptyState.allDone() {
    return EmptyState(
      icon: Icons.celebration_rounded,
      title: 'All Done!',
      subtitle: 'You\'ve completed everything. Take a break or add more tasks.',
      iconColor: AppColors.success,
    );
  }
}
