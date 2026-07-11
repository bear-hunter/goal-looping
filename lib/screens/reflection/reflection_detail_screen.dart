import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/reflection.dart';
import '../../models/experiment.dart';
import '../../providers/app_state.dart';
import '../../services/storage_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/factor_chip.dart';
import '../../models/reflection_group.dart';
import '../../services/pdf_export_service.dart';
import 'new_reflection_sheet.dart';

/// Module 5: Reflection Detail Screen - Read-only view of a saved reflection
class ReflectionDetailScreen extends StatefulWidget {
  final String reflectionId;

  const ReflectionDetailScreen({super.key, required this.reflectionId});

  @override
  State<ReflectionDetailScreen> createState() => _ReflectionDetailScreenState();
}

class _ReflectionDetailScreenState extends State<ReflectionDetailScreen> {
  late PageController _pageController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Consumer<AppState>(
      builder: (context, state, _) {
        final reflection = state.getReflectionById(widget.reflectionId);

        if (reflection == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Reflection')),
            body: const Center(child: Text('Reflection not found')),
          );
        }

        // Determine the collection of reflections (the "book")
        List<Reflection> bookReflections = [];
        if (reflection.groupId != null) {
          bookReflections = state.reflections
              .where((r) => r.groupId == reflection.groupId)
              .toList();
          // Sort by creation time to maintain the chain order
          bookReflections.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        } else {
          bookReflections = [reflection];
        }

        // Jump to the initial reflection on first load
        if (!_initialized) {
          final initialIndex = bookReflections.indexWhere((r) => r.id == widget.reflectionId);
          if (initialIndex != -1) {
            _pageController = PageController(initialPage: initialIndex);
          }
          _initialized = true;
        }

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            title: ListenableBuilder(
              listenable: _pageController,
              builder: (context, _) {
                final page = (_pageController.hasClients ? _pageController.page?.round() : null) ?? _pageController.initialPage;
                if (bookReflections.length > 1) {
                  return Column(
                    children: [
                      const Text('Reflection Chain', style: TextStyle(fontSize: 16)),
                      Text(
                        'Cycle ${page + 1} of ${bookReflections.length}',
                        style: TextStyle(fontSize: 12, color: colors.textMuted),
                      ),
                    ],
                  );
                }
                return const Text('Reflection');
              },
            ),
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: () => _handleExportPdf(context, state, bookReflections),
                tooltip: 'Export to PDF',
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => _handleEdit(context, state, bookReflections),
                tooltip: 'Edit Reflection',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () {
                  final page = _pageController.page?.round() ?? 0;
                  _confirmDelete(context, state, bookReflections[page].id);
                },
              ),
            ],
          ),
          body: PageView.builder(
            controller: _pageController,
            itemCount: bookReflections.length,
            itemBuilder: (context, index) {
              return _ReflectionPage(
                reflection: bookReflections[index],
                state: state,
                onCycleAgain: () => _handleCycleAgain(context, state, bookReflections[index].id, _pageController),
                onArchive: () => _handleArchive(context, state, bookReflections[index]),
                onResurrect: (exp) => _resurrectExperiment(context, state, exp),
              );
            },
          ),
        );
      },
    );
  }

  void _handleExportPdf(BuildContext context, AppState state, List<Reflection> reflections) async {
    final colors = context.colors;
    if (reflections.isEmpty) return;

    final reflection = reflections.first;
    final group = reflection.groupId != null ? state.getReflectionGroup(reflection.groupId!) : null;

    // Create a dummy group if none exists for a single reflection
    final effectiveGroup = group ?? ReflectionGroup(
      id: 'single',
      title: 'Reflection - ${_formatDate(reflection.createdAt)}',
    );

    try {
      await PdfExportService.exportGroup(effectiveGroup, reflections, state);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: colors.danger),
        );
      }
    }

  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}';
  }

  void _handleCycleAgain(BuildContext context, AppState state, String reflectionId, PageController controller) async {
    final reflection = state.getReflectionById(reflectionId);
    if (reflection == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => NewReflectionSheet(
          previousReflection: reflection,
          groupId: reflection.groupId,
        ),
      ),
    );
    // Note: State updates will trigger rebuilds automatically via Consumer
  }

  void _handleEdit(BuildContext context, AppState state, List<Reflection> bookReflections) {
    if (!_pageController.hasClients) return;
    final page = _pageController.page?.round() ?? 0;
    if (page >= bookReflections.length) return;
    
    final reflection = bookReflections[page];
    
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => NewReflectionSheet(
          reflectionToEdit: reflection,
        ),
      ),
    );
  }

  void _handleArchive(BuildContext context, AppState state, Reflection reflection) {
    showDialog(
      context: context,
      builder: (ctx) {
        final colors = ctx.colors;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text('Finish & Archive?', style: TextStyle(color: colors.textPrimary)),
          content: Text(
            'This will archive the reflection. You can restore it later from the archive.',
            style: TextStyle(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await state.archiveReflection(reflection.id);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: const Text('Archived successfully!'),
                    backgroundColor: colors.success,
                  ),
                );
                Navigator.pop(ctx); // Go back after archiving
              },
              child: Text('Archive', style: TextStyle(color: colors.primary)),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, AppState state, String id) {
    showDialog(
      context: context,
      builder: (ctx) {
        final colors = ctx.colors;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text('Delete Reflection?', style: TextStyle(color: colors.textPrimary)),
          content: Text('This cannot be undone.', style: TextStyle(color: colors.textSecondary)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
            TextButton(
              onPressed: () {
                state.deleteReflection(id);
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: colors.danger)),
            ),
          ],
        );
      },
    );
  }

  void _resurrectExperiment(BuildContext context, AppState state, Experiment exp) {
    final colors = context.colors;
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
        backgroundColor: colors.success,
      ),
    );
  }
}

/// A single page in the reflection book
class _ReflectionPage extends StatelessWidget {
  final Reflection reflection;
  final AppState state;
  final VoidCallback onCycleAgain;
  final VoidCallback onArchive;
  final Function(Experiment) onResurrect;

  const _ReflectionPage({
    required this.reflection,
    required this.state,
    required this.onCycleAgain,
    required this.onArchive,
    required this.onResurrect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final experiments = state.getExperimentsForReflection(reflection.id);
    final linkedFactors = reflection.linkedFactorIds
        .map((id) => state.factors.where((f) => f.id == id).firstOrNull)
        .whereType<dynamic>()
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & Completion
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: colors.textMuted, size: 16),
              const SizedBox(width: 8),
              Text(
                _formatDate(reflection.createdAt),
                style: TextStyle(color: colors.textMuted),
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
            color: colors.primary,
          ),

          // Step 2: Reflection
          _KolbSection(
            step: 2,
            title: 'Reflection',
            subtitle: 'How did you feel?',
            content: reflection.reflection,
            color: colors.info,
          ),

          // Step 3: Abstraction
          _KolbSection(
            step: 3,
            title: 'Abstraction',
            subtitle: 'Patterns identified',
            content: reflection.abstraction,
            color: colors.warning,
          ),

          // Step 4: Experiments
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _StepNumber(step: 4, color: colors.success),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Experiments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                          Text('Actions to try', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (experiments.isEmpty)
                  GlassCard(
                    child: Center(
                      child: Text('No experiments extracted', style: TextStyle(color: colors.textMuted)),
                    ),
                  )
                else
                  ...experiments.map((exp) => _ExperimentCard(
                    experiment: exp,
                    onResurrect: () => onResurrect(exp),
                    canPromote: state.canAddPriorityTask,
                    onPromoteToTop2: exp.status == ExperimentStatus.pending
                        ? () => state.startExperiment(exp.id)
                        : null,
                    onPromoteToBacklog: exp.status == ExperimentStatus.pending
                        ? () => state.startExperiment(exp.id)
                        : null,
                  )),
              ],
            ),
          ),

          // Raw Markdown (if present)
          if (reflection.rawMarkdown != null && reflection.rawMarkdown!.isNotEmpty) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: Text('Raw Markdown', style: TextStyle(color: colors.textSecondary)),
              tilePadding: EdgeInsets.zero,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    reflection.rawMarkdown!,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: colors.textSecondary),
                  ),
                ),
              ],
            ),
          ],

          // Cycle Group Info - Removed because title already shows "Cycle X of Y"
          // and we want a clean "page" look.
          /*
          if (reflection.groupId != null) ...[
            const SizedBox(height: 24),
            _CycleGroupBanner(
              group: state.getReflectionGroup(reflection.groupId!),
              currentReflectionId: reflection.id,
            ),
          ],
          */

          // Cycling Actions
          const SizedBox(height: 24),
          _CyclingActionsSection(
            reflection: reflection,
            onCycleAgain: onCycleAgain,
            onFinishArchive: onArchive,
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(
      label.toUpperCase(),
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textMuted, letterSpacing: 1.2),
    );
  }
}

class _CompletionBadge extends StatelessWidget {
  final double percent;
  const _CompletionBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = percent >= 1.0 ? colors.success : (percent >= 0.5 ? colors.warning : colors.textMuted);
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
    final colors = context.colors;
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
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: colors.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: content.isEmpty
                ? Center(child: Text('Not filled', style: TextStyle(color: colors.textMuted)))
                : Text(content, style: TextStyle(color: colors.textSecondary, height: 1.5)),
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
    final colors = context.colors;
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(experiment.description, style: TextStyle(color: colors.textPrimary)),
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
                  color: colors.primary,
                  enabled: canPromote,
                  onTap: onPromoteToTop2,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: 'Backlog',
                  color: colors.textMuted,
                  onTap: onPromoteToBacklog,
                ),
              ],
            ),
          ],
          if (experiment.status == ExperimentStatus.completed) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onResurrect,
              icon: Icon(Icons.replay_rounded, size: 16, color: colors.info),
              label: Text('Resurrect', style: TextStyle(color: colors.info)),
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
    final colors = context.colors;
    final (label, color) = switch (status) {
      ExperimentStatus.pending => ('Pending', colors.warning),
      ExperimentStatus.inProgress => ('In Progress', colors.info),
      ExperimentStatus.completed => ('Done', colors.success),
      ExperimentStatus.cycled => ('Cycled', colors.primary),
      ExperimentStatus.archived => ('Archived', colors.textMuted),
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
    final colors = context.colors;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: (enabled ? color : colors.surfaceLight).withAlpha(30),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: (enabled ? color : colors.glassBorder).withAlpha(80)),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: enabled ? color : colors.textMuted)),
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
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACTIONS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colors.textMuted,
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
                color: colors.primary,
                onTap: onCycleAgain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CycleActionButton(
                icon: Icons.archive_rounded,
                label: 'Finish & Archive',
                subtitle: 'Complete this chain',
                color: colors.success,
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
    final colors = context.colors;
    final effectiveColor = enabled ? color : colors.textMuted;

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
              style: TextStyle(fontSize: 10, color: colors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
