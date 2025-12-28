import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/experiment.dart';
import '../../providers/app_state.dart';
import '../../widgets/glass_card.dart';

/// Experiment Management Screen - View and manage experiments separately from tasks
class ExperimentScreen extends StatefulWidget {
  const ExperimentScreen({super.key});

  @override
  State<ExperimentScreen> createState() => _ExperimentScreenState();
}

class _ExperimentScreenState extends State<ExperimentScreen> {
  ExperimentFilter _filter = ExperimentFilter.active;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final experiments = _getFilteredExperiments(state);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Experiments'),
            backgroundColor: Colors.transparent,
            actions: [
              PopupMenuButton<ExperimentFilter>(
                icon: Icon(Icons.filter_list_rounded, color: AppColors.textSecondary),
                onSelected: (filter) => setState(() => _filter = filter),
                itemBuilder: (ctx) => [
                  _buildFilterItem(ExperimentFilter.all, 'All', Icons.list_rounded),
                  _buildFilterItem(ExperimentFilter.active, 'Active', Icons.play_arrow_rounded),
                  _buildFilterItem(ExperimentFilter.pending, 'Pending', Icons.hourglass_empty_rounded),
                  _buildFilterItem(ExperimentFilter.completed, 'Completed', Icons.check_circle_rounded),
                  _buildFilterItem(ExperimentFilter.archived, 'Archived', Icons.archive_rounded),
                ],
              ),
            ],
          ),
          body: experiments.isEmpty
              ? _EmptyState(filter: _filter)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: experiments.length,
                  itemBuilder: (ctx, i) => _ExperimentCard(
                    experiment: experiments[i],
                    onStart: () => state.startExperiment(experiments[i].id),
                    onComplete: () => state.completeExperiment(experiments[i].id),
                    onCycle: () => state.cycleExperiment(experiments[i].id),
                    onArchive: () => state.archiveExperiment(experiments[i].id),
                  ).animate(delay: (i * 50).ms).fadeIn().slideX(begin: 0.1),
                ),
        );
      },
    );
  }

  List<Experiment> _getFilteredExperiments(AppState state) {
    switch (_filter) {
      case ExperimentFilter.all:
        return state.experiments;
      case ExperimentFilter.active:
        return state.experiments.where((e) => e.isActionable).toList();
      case ExperimentFilter.pending:
        return state.experiments.where((e) => e.status == ExperimentStatus.pending).toList();
      case ExperimentFilter.completed:
        return state.experiments.where((e) => e.status == ExperimentStatus.completed).toList();
      case ExperimentFilter.archived:
        return state.experiments.where((e) => e.status == ExperimentStatus.archived).toList();
    }
  }

  PopupMenuItem<ExperimentFilter> _buildFilterItem(
    ExperimentFilter value,
    String label,
    IconData icon,
  ) {
    final isSelected = _filter == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? AppColors.primary : AppColors.textMuted),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          )),
        ],
      ),
    );
  }
}

enum ExperimentFilter { all, active, pending, completed, archived }

class _EmptyState extends StatelessWidget {
  final ExperimentFilter filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final (icon, message) = switch (filter) {
      ExperimentFilter.all => (Icons.science_outlined, 'No experiments yet'),
      ExperimentFilter.active => (Icons.play_circle_outline_rounded, 'No active experiments'),
      ExperimentFilter.pending => (Icons.hourglass_empty_rounded, 'No pending experiments'),
      ExperimentFilter.completed => (Icons.celebration_rounded, 'No completed experiments'),
      ExperimentFilter.archived => (Icons.archive_outlined, 'No archived experiments'),
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            'Experiments come from your reflections',
            style: TextStyle(color: AppColors.textMuted.withAlpha(150), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ExperimentCard extends StatelessWidget {
  final Experiment experiment;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onCycle;
  final VoidCallback onArchive;

  const _ExperimentCard({
    required this.experiment,
    required this.onStart,
    required this.onComplete,
    required this.onCycle,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              Text(
                experiment.statusEmoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  experiment.description,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Status badge and cycle count
          Row(
            children: [
              _StatusChip(status: experiment.status),
              if (experiment.cycleCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '🔁 ${experiment.cycleCount}x cycled',
                    style: TextStyle(fontSize: 11, color: AppColors.primary),
                  ),
                ),
              ],
            ],
          ),

          // Action buttons based on status
          if (experiment.isActionable) ...[
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    switch (experiment.status) {
      case ExperimentStatus.pending:
        return Row(
          children: [
            _ActionButton(
              label: 'Start',
              icon: Icons.play_arrow_rounded,
              color: AppColors.primary,
              onTap: onStart,
            ),
            const SizedBox(width: 8),
            _ActionButton(
              label: 'Archive',
              icon: Icons.archive_outlined,
              color: AppColors.textMuted,
              onTap: onArchive,
            ),
          ],
        );
      case ExperimentStatus.inProgress:
        return Row(
          children: [
            _ActionButton(
              label: 'Complete',
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
              onTap: onComplete,
            ),
            const SizedBox(width: 8),
            _ActionButton(
              label: 'Cycle Forward',
              icon: Icons.replay_rounded,
              color: AppColors.info,
              onTap: onCycle,
            ),
            const SizedBox(width: 8),
            _ActionButton(
              label: 'Archive',
              icon: Icons.archive_outlined,
              color: AppColors.textMuted,
              onTap: onArchive,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _StatusChip extends StatelessWidget {
  final ExperimentStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ExperimentStatus.pending => ('Pending', AppColors.warning),
      ExperimentStatus.inProgress => ('In Progress', AppColors.info),
      ExperimentStatus.completed => ('Completed', AppColors.success),
      ExperimentStatus.cycled => ('Cycled', AppColors.primary),
      ExperimentStatus.archived => ('Archived', AppColors.textMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
