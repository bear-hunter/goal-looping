import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/reflection.dart';
import '../../models/experiment.dart';
import '../../models/task.dart';
import '../../providers/app_state.dart';
import '../../services/storage_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/factor_chip.dart';

/// Module 5: Reflection Detail Screen - Read-only view of a saved reflection
class ReflectionDetailScreen extends StatelessWidget {
  final String reflectionId;

  const ReflectionDetailScreen({super.key, required this.reflectionId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final reflection = state.getReflectionById(reflectionId);
        
        if (reflection == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Reflection')),
            body: const Center(child: Text('Reflection not found')),
          );
        }

        final experiments = state.getExperimentsForReflection(reflectionId);
        final linkedFactors = reflection.linkedFactorIds
            .map((id) => state.factors.where((f) => f.id == id).firstOrNull)
            .whereType<dynamic>()
            .toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Reflection'),
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => _confirmDelete(context, state, reflectionId),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date & Completion
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, color: AppColors.textMuted, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(reflection.createdAt),
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const Spacer(),
                    _CompletionBadge(percent: reflection.completionPercent),
                  ],
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 24),

                // Linked Factors
                if (linkedFactors.isNotEmpty) ...[
                  _SectionLabel(label: 'Linked Factors'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: linkedFactors.map((f) => FactorChip(factor: f)).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Step 1: Experience
                _KolbSection(
                  step: 1,
                  title: 'Experience',
                  subtitle: 'What happened?',
                  content: reflection.experience,
                  color: AppColors.primary,
                ),

                // Step 2: Reflection
                _KolbSection(
                  step: 2,
                  title: 'Reflection',
                  subtitle: 'How did you feel?',
                  content: reflection.reflection,
                  color: AppColors.info,
                ),

                // Step 3: Abstraction
                _KolbSection(
                  step: 3,
                  title: 'Abstraction',
                  subtitle: 'Patterns identified',
                  content: reflection.abstraction,
                  color: AppColors.warning,
                ),

                // Step 4: Experiments
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _StepNumber(step: 4, color: AppColors.success),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Experiments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                Text('Actions to try', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (experiments.isEmpty)
                        GlassCard(
                          child: Center(
                            child: Text('No experiments extracted', style: TextStyle(color: AppColors.textMuted)),
                          ),
                        )
                      else
                        ...experiments.map((exp) => _ExperimentCard(
                          experiment: exp,
                          onResurrect: () => _resurrectExperiment(context, state, exp),
                          canPromote: state.canAddPriorityTask,
                          onPromoteToTop2: exp.status == ExperimentStatus.pending
                              ? () => state.promoteExperimentToTask(exp.id, toPriority: true)
                              : null,
                          onPromoteToBacklog: exp.status == ExperimentStatus.pending
                              ? () => state.promoteExperimentToTask(exp.id, toPriority: false)
                              : null,
                        )),
                    ],
                  ),
                ),

                // Raw Markdown (if present)
                if (reflection.rawMarkdown != null && reflection.rawMarkdown!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ExpansionTile(
                    title: Text('Raw Markdown', style: TextStyle(color: AppColors.textSecondary)),
                    tilePadding: EdgeInsets.zero,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          reflection.rawMarkdown!,
                          style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],

                // Cycle Group Info
                if (reflection.groupId != null) ...[
                  const SizedBox(height: 24),
                  _CycleGroupBanner(
                    group: state.getReflectionGroup(reflection.groupId!),
                    currentReflectionId: reflectionId,
                  ),
                ],

                // Cycling Actions
                const SizedBox(height: 24),
                _CyclingActionsSection(
                  reflection: reflection,
                  onCycleAgain: () => _handleCycleAgain(context, state, reflectionId),
                  onFinishArchive: reflection.groupId != null
                      ? () => _handleArchive(context, state, reflection.groupId!)
                      : null,
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleCycleAgain(BuildContext context, AppState state, String reflectionId) async {
    try {
      final newReflection = await state.cycleReflection(reflectionId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('New cycle created! Fill in your next reflection.'),
            backgroundColor: AppColors.success,
          ),
        );
        // Navigate to the new reflection
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReflectionDetailScreen(reflectionId: newReflection.id),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  void _handleArchive(BuildContext context, AppState state, String groupId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Finish & Archive?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'This will archive the entire cycle chain. You can restore it later from the archive.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              state.archiveReflectionGroup(groupId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cycle archived successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text('Archive', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmDelete(BuildContext context, AppState state, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Reflection?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('This cannot be undone.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              state.deleteReflection(id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _resurrectExperiment(BuildContext context, AppState state, Experiment exp) {
    // Clone experiment as new pending experiment
    final newExp = Experiment(
      id: StorageService.generateId(),
      description: exp.description,
      reflectionId: exp.reflectionId,
    );
    state.addExperiment(newExp);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Experiment resurrected!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1.2),
    );
  }
}

class _CompletionBadge extends StatelessWidget {
  final double percent;
  const _CompletionBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    final color = percent >= 1.0 ? AppColors.success : (percent >= 0.5 ? AppColors.warning : AppColors.textMuted);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${(percent * 100).toInt()}% complete',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _StepNumber extends StatelessWidget {
  final int step;
  final Color color;
  const _StepNumber({required this.step, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text('$step', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }
}

class _KolbSection extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;
  final String content;
  final Color color;

  const _KolbSection({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StepNumber(step: step, color: color),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: content.isEmpty
                ? Center(child: Text('Not filled', style: TextStyle(color: AppColors.textMuted)))
                : Text(content, style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _ExperimentCard extends StatelessWidget {
  final Experiment experiment;
  final VoidCallback onResurrect;
  final bool canPromote;
  final VoidCallback? onPromoteToTop2;
  final VoidCallback? onPromoteToBacklog;

  const _ExperimentCard({
    required this.experiment,
    required this.onResurrect,
    required this.canPromote,
    this.onPromoteToTop2,
    this.onPromoteToBacklog,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(experiment.description, style: TextStyle(color: AppColors.textPrimary)),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: experiment.status),
            ],
          ),
          if (experiment.status == ExperimentStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _ActionButton(
                  label: 'Top 2',
                  color: AppColors.primary,
                  enabled: canPromote,
                  onTap: onPromoteToTop2,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: 'Backlog',
                  color: AppColors.textMuted,
                  onTap: onPromoteToBacklog,
                ),
              ],
            ),
          ],
          if (experiment.status == ExperimentStatus.completed) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onResurrect,
              icon: Icon(Icons.replay_rounded, size: 16, color: AppColors.info),
              label: Text('Resurrect', style: TextStyle(color: AppColors.info)),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ExperimentStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ExperimentStatus.pending => ('Pending', AppColors.warning),
      ExperimentStatus.inProgress => ('In Progress', AppColors.info),
      ExperimentStatus.completed => ('Done', AppColors.success),
      ExperimentStatus.cycled => ('Cycled', AppColors.primary),
      ExperimentStatus.archived => ('Archived', AppColors.textMuted),
    };
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback? onTap;

  const _ActionButton({required this.label, required this.color, this.enabled = true, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: (enabled ? color : AppColors.surfaceLight).withAlpha(30),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: (enabled ? color : AppColors.glassBorder).withAlpha(80)),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: enabled ? color : AppColors.textMuted)),
      ),
    );
  }
}

/// Banner showing cycle group information
class _CycleGroupBanner extends StatelessWidget {
  final dynamic group; // ReflectionGroup?
  final String currentReflectionId;

  const _CycleGroupBanner({
    required this.group,
    required this.currentReflectionId,
  });

  @override
  Widget build(BuildContext context) {
    if (group == null) return const SizedBox.shrink();

    final cycleNumber = group.reflectionIds.indexOf(currentReflectionId) + 1;
    final totalCycles = group.cycleCount;
    final isArchived = group.isArchived;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withAlpha(30),
            AppColors.info.withAlpha(20),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Text(
              '🔁',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cycle $cycleNumber of $totalCycles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isArchived ? 'This cycle chain is archived' : 'Part of an active reflection chain',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          if (isArchived)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.textMuted.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Archived',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}

/// Section with cycling action buttons
class _CyclingActionsSection extends StatelessWidget {
  final dynamic reflection;
  final VoidCallback onCycleAgain;
  final VoidCallback? onFinishArchive;

  const _CyclingActionsSection({
    required this.reflection,
    required this.onCycleAgain,
    this.onFinishArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACTIONS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _CycleActionButton(
                icon: Icons.replay_rounded,
                label: 'Cycle Again',
                subtitle: 'Continue the chain',
                color: AppColors.primary,
                onTap: onCycleAgain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CycleActionButton(
                icon: Icons.archive_rounded,
                label: 'Finish & Archive',
                subtitle: 'Complete this chain',
                color: AppColors.success,
                onTap: onFinishArchive,
                enabled: onFinishArchive != null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CycleActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final bool enabled;

  const _CycleActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : AppColors.textMuted;
    
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: effectiveColor.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: effectiveColor.withAlpha(40)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: effectiveColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: effectiveColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
