import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/theme.dart';

enum EmptyStateAccent { primary, success, info, warning, accent, muted }

/// A reusable empty state widget with illustration and action button
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EmptyStateAccent accent;
  final bool animate;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.accent = EmptyStateAccent.primary,
    this.animate = true,
  });

  Color _accentColor(BuildContext context) {
    final colors = context.colors;
    switch (accent) {
      case EmptyStateAccent.primary:
        return colors.primary;
      case EmptyStateAccent.success:
        return colors.success;
      case EmptyStateAccent.info:
        return colors.info;
      case EmptyStateAccent.warning:
        return colors.warning;
      case EmptyStateAccent.accent:
        return colors.accent;
      case EmptyStateAccent.muted:
        return colors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tint = _accentColor(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconContainer(tint),
            const SizedBox(height: 24),
            _buildTitle(context),
            const SizedBox(height: 8),
            _buildSubtitle(context),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              _buildActionButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(Color tint) {
    final container = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: tint.withAlpha(20),
        shape: BoxShape.circle,
        border: Border.all(color: tint.withAlpha(40), width: 2),
      ),
      child: Icon(icon, size: 48, color: tint),
    );

    if (!animate) return container;
    return container
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          duration: 500.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: AppMotion.expressive);
  }

  Widget _buildTitle(BuildContext context) {
    final colors = context.colors;
    final text = Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );

    if (!animate) return text;
    return text
        .animate()
        .fadeIn(duration: AppMotion.expressive, delay: 100.ms)
        .slideY(begin: 0.2, end: 0, duration: AppMotion.expressive);
  }

  Widget _buildSubtitle(BuildContext context) {
    final colors = context.colors;
    final text = Text(
      subtitle,
      style: TextStyle(fontSize: 14, color: colors.textMuted, height: 1.4),
      textAlign: TextAlign.center,
    );

    if (!animate) return text;
    return text
        .animate()
        .fadeIn(duration: AppMotion.expressive, delay: 200.ms)
        .slideY(begin: 0.2, end: 0, duration: AppMotion.expressive);
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
        .fadeIn(duration: AppMotion.expressive, delay: 300.ms)
        .slideY(begin: 0.2, end: 0, duration: AppMotion.expressive);
  }

  factory EmptyState.tasks({VoidCallback? onAdd}) {
    return EmptyState(
      icon: Icons.task_alt_rounded,
      title: 'No Tasks Yet',
      subtitle:
          'Add your first priority task to get started on your most important work.',
      actionLabel: 'Add Task',
      onAction: onAdd,
      accent: EmptyStateAccent.primary,
    );
  }

  factory EmptyState.habits({VoidCallback? onAdd}) {
    return EmptyState(
      icon: Icons.auto_awesome_rounded,
      title: 'No Habits Yet',
      subtitle:
          'Build positive habits or break limiting ones to support your goals.',
      actionLabel: 'Add First Habit',
      onAction: onAdd,
      accent: EmptyStateAccent.success,
    );
  }

  factory EmptyState.reflections({VoidCallback? onAdd}) {
    return EmptyState(
      icon: Icons.psychology_rounded,
      title: 'Start Reflecting',
      subtitle:
          'Use the Kolb cycle to learn from experiences and continuously improve.',
      actionLabel: 'New Reflection',
      onAction: onAdd,
      accent: EmptyStateAccent.info,
    );
  }

  factory EmptyState.goals({VoidCallback? onAdd}) {
    return EmptyState(
      icon: Icons.flag_rounded,
      title: 'Set Your Direction',
      subtitle:
          'Define a goal to anchor your work and create a clear path forward.',
      actionLabel: 'Add Goal',
      onAction: onAdd,
      accent: EmptyStateAccent.warning,
    );
  }

  factory EmptyState.noResults({String query = ''}) {
    return EmptyState(
      icon: Icons.search_off_rounded,
      title: 'No Results Found',
      subtitle: query.isEmpty
          ? 'Try adjusting your filters to find what you\'re looking for.'
          : 'No matches for "$query". Try a different search term.',
      accent: EmptyStateAccent.muted,
    );
  }

  factory EmptyState.allDone() {
    return EmptyState(
      icon: Icons.celebration_rounded,
      title: 'All Done!',
      subtitle:
          'You\'ve completed everything. Take a break or add more tasks.',
      accent: EmptyStateAccent.success,
    );
  }
}
