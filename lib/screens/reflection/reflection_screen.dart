import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/reflection.dart';

import '../../providers/app_state.dart';

import '../../widgets/glass_card.dart';

import 'reflection_detail_screen.dart';
import 'reflection_archive_screen.dart';
import '../experiment/experiment_screen.dart';
import '../../services/pdf_export_service.dart';
import 'new_reflection_sheet.dart';

/// Module 5: Reflection Forge - Kolb's Cycles with Markdown parsing
class ReflectionScreen extends StatelessWidget {
  const ReflectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Consumer<AppState>(
      builder: (context, state, _) {
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Reflection Forge',
                              style: Theme.of(context).textTheme.displayMedium,
                            ).animate().fadeIn(duration: 400.ms),
                          ),
                          // Experiments button - meets 44x44dp touch target
                          Tooltip(
                            message: 'Pending Experiments',
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ExperimentScreen(),
                                  ),
                                ),
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 44,
                                    minWidth: 44,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: colors.warning.withAlpha(30),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.science_rounded,
                                        size: 20,
                                        color: colors.warning,
                                      ),
                                      if (state
                                          .pendingExperiments
                                          .isNotEmpty) ...[
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colors.warning,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            '${state.pendingExperiments.length}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Archive button - meets 44x44dp touch target
                          Tooltip(
                            message: 'Reflection Archive',
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ReflectionArchiveScreen(),
                                  ),
                                ),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: colors.textMuted.withAlpha(30),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.archive_outlined,
                                    size: 20,
                                    color: colors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Transform reflections into actions',
                              style: TextStyle(color: colors.textSecondary),
                            ),
                          ),
                          if (state.activeReflectionGroups.isNotEmpty)
                            TextButton.icon(
                              onPressed: () => _handleExportAll(context, state),
                              icon: const Icon(
                                Icons.picture_as_pdf_outlined,
                                size: 18,
                              ),
                              label: const Text(
                                'Export All',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: colors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Reflection Reminder Banner (when overdue)
              if (state.userStats.isReflectionOverdue)
                SliverToBoxAdapter(
                  child: _ReflectionReminderBanner(
                    isCritical: state.userStats.isReflectionCriticallyOverdue,
                    hoursSince: state.userStats.hoursSinceLastReflection,
                  ),
                ),

              // New Reflection Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () => _showNewReflectionDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: colors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withAlpha(76),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_rounded, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            'New Kolb\'s Cycle',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Active Cycle Chains (grouped reflections)
              if (state.activeReflectionGroups.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.replay_circle_filled_rounded,
                          color: colors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Active Cycle Chains',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withAlpha(51),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${state.activeReflectionGroups.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final group = state.activeReflectionGroups[index];
                    return _CycleChainCard(
                      group: group,
                      reflections: group.reflectionIds
                          .map((id) => state.getReflectionById(id))
                          .where((r) => r != null)
                          .toList(),
                      onViewReflection: (reflectionId) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReflectionDetailScreen(
                            reflectionId: reflectionId,
                          ),
                        ),
                      ),
                      // Pass the LAST reflection as the previous one for the cycle
                      onQuickCycle: () => _showNewReflectionDialog(
                        context,
                        previousReflection: group.reflectionIds.isNotEmpty
                            ? state.getReflectionById(group.reflectionIds.last)
                            : null,
                        groupId: group.id,
                      ),
                    );
                  }, childCount: state.activeReflectionGroups.length),
                ),
              ],

              // Recent Reflections (ungrouped)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        color: colors.info,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Recent Cycles',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (state.reflections.isEmpty)
                SliverToBoxAdapter(
                  child: GlassCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.psychology_rounded,
                              size: 48,
                              color: colors.textMuted.withAlpha(127),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Start your first reflection cycle',
                              style: TextStyle(color: colors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final visibleReflections = state.reflections
                          .where((r) => r.groupId == null)
                          .toList();
                      final reflection = visibleReflections[index];
                      return _ReflectionCard(
                        reflection: reflection,
                        cycleNumber: null, // Standalone always null
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReflectionDetailScreen(
                              reflectionId: reflection.id,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: state.reflections
                        .where((r) => r.groupId == null)
                        .length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  void _handleExportAll(BuildContext context, AppState state) async {
    final colors = context.colors;
    final groups = state.activeReflectionGroups;
    if (groups.isEmpty) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              CircularProgressIndicator(color: colors.primary),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exporting PDF...',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${groups.length} reflection chain(s)',
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      await PdfExportService.exportMultipleGroups(groups, state);
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text('Export completed successfully!'),
              ],
            ),
            backgroundColor: colors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: colors.danger,
          ),
        );
      }
    }
  }

  void _showNewReflectionDialog(
    BuildContext context, {
    Reflection? previousReflection,
    String? groupId,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => NewReflectionSheet(
          previousReflection: previousReflection,
          groupId: groupId,
        ),
      ),
    );
  }
}

/// Cycle chain card showing timeline
class _CycleChainCard extends StatelessWidget {
  final dynamic group;
  final List<dynamic> reflections;
  final Function(String) onViewReflection;
  final VoidCallback? onQuickCycle;

  const _CycleChainCard({
    required this.group,
    required this.reflections,
    required this.onViewReflection,
    this.onQuickCycle,
  });

  void _handleExportGroup(BuildContext context) async {
    final colors = context.colors;
    final state = Provider.of<AppState>(context, listen: false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Preparing chain export...')));

    try {
      await PdfExportService.exportGroup(
        group,
        reflections.cast<Reflection>(),
        state,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: colors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Text('🔁', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.title ?? 'Reflection Cycle',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      '${reflections.length} cycles',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 20,
                  color: colors.primary.withAlpha(204),
                ),
                onPressed: () => _handleExportGroup(context),
                tooltip: 'Export Chain to PDF',
              ),
              if (onQuickCycle != null)
                IconButton(
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    size: 22,
                    color: colors.primary,
                  ),
                  onPressed: onQuickCycle,
                  tooltip: 'Quick Cycle',
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Timeline
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: reflections.length,
              itemBuilder: (ctx, i) {
                final r = reflections[i];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => onViewReflection(r.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: i == reflections.length - 1
                              ? colors.primary.withAlpha(30)
                              : colors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: i == reflections.length - 1
                                ? colors.primary
                                : colors.glassBorder,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: i == reflections.length - 1
                                    ? colors.primary
                                    : colors.textSecondary,
                              ),
                            ),
                            Text(
                              'cycle',
                              style: TextStyle(
                                fontSize: 9,
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (i < reflections.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: colors.textMuted,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  final Reflection reflection;
  final VoidCallback? onTap;
  final int? cycleNumber;

  const _ReflectionCard({
    required this.reflection,
    this.onTap,
    this.cycleNumber,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_rounded, color: colors.info, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reflection.experience.isNotEmpty
                      ? reflection.experience
                      : 'Untitled Reflection',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (cycleNumber != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '🔁 $cycleNumber',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                _formatDate(reflection.createdAt),
                style: TextStyle(fontSize: 12, color: colors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: reflection.completionPercent,
            backgroundColor: colors.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            minHeight: 4,
          ),
          const SizedBox(height: 8),
          Text(
            '${(reflection.completionPercent * 100).toInt()}% complete • ${reflection.experimentIds.length} experiments',
            style: TextStyle(fontSize: 12, color: colors.textMuted),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}';
  }
}

/// Reflection reminder banner when overdue
class _ReflectionReminderBanner extends StatelessWidget {
  final bool isCritical;
  final int hoursSince;

  const _ReflectionReminderBanner({
    required this.isCritical,
    required this.hoursSince,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = isCritical ? colors.danger : colors.warning;
    final daysSince = hoursSince ~/ 24;

    return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: GestureDetector(
            onTap: () => _showNewReflectionDialog(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCritical
                          ? Icons.warning_rounded
                          : Icons.psychology_rounded,
                      color: color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCritical
                              ? '⚠️ Reflection Critical!'
                              : '🔔 Time to Reflect',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isCritical
                              ? '$daysSince+ days without reflection - never go a week!'
                              : 'It\'s been ${daysSince > 0 ? "$daysSince days" : "$hoursSince hours"} since your last reflection',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: color, size: 20),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .shimmer(
          delay: 500.ms,
          duration: 1500.ms,
          color: color.withValues(alpha: 0.1),
        );
  }

  void _showNewReflectionDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const NewReflectionSheet(),
      ),
    );
  }
}
