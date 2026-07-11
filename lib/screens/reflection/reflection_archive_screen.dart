import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/reflection_group.dart';
import '../../providers/app_state.dart';
import '../../widgets/glass_card.dart';
import 'reflection_detail_screen.dart';

/// Archive Screen - View and restore archived reflection groups
class ReflectionArchiveScreen extends StatelessWidget {
  const ReflectionArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Consumer<AppState>(
      builder: (context, state, _) {
        final archivedGroups = state.archivedReflectionGroups;

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            title: const Text('Archived Reflections'),
            backgroundColor: Colors.transparent,
          ),
          body: archivedGroups.isEmpty
              ? _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: archivedGroups.length,
                  itemBuilder: (ctx, i) => _ArchivedGroupCard(
                    group: archivedGroups[i],
                    reflections: archivedGroups[i].reflectionIds
                        .map((id) => state.getReflectionById(id))
                        .where((r) => r != null)
                        .toList(),
                    onRestore: () => state.restoreReflectionGroup(archivedGroups[i].id),
                    onViewReflection: (reflectionId) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReflectionDetailScreen(reflectionId: reflectionId),
                      ),
                    ),
                  ).animate(delay: (i * 50).ms).fadeIn().slideX(begin: 0.1),
                ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.archive_outlined, size: 64, color: colors.textMuted),
          const SizedBox(height: 16),
          Text(
            'No Archived Reflections',
            style: TextStyle(color: colors.textMuted, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Finished cycles will appear here',
            style: TextStyle(color: colors.textMuted.withAlpha(150), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ArchivedGroupCard extends StatelessWidget {
  final ReflectionGroup group;
  final List<dynamic> reflections;
  final VoidCallback onRestore;
  final Function(String) onViewReflection;

  const _ArchivedGroupCard({
    required this.group,
    required this.reflections,
    required this.onRestore,
    required this.onViewReflection,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.textMuted.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Text('📦', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      '${group.cycleCount} cycles • Archived ${_formatDate(group.archivedAt!)}',
                      style: TextStyle(fontSize: 12, color: colors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Cycle chain preview
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: reflections.length,
              itemBuilder: (ctx, i) => Padding(
                padding: EdgeInsets.only(right: i < reflections.length - 1 ? 8 : 0),
                child: GestureDetector(
                  onTap: () {
                    final r = reflections[i];
                    if (r != null) onViewReflection(r.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.glassBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Cycle ${i + 1}',
                          style: TextStyle(fontSize: 12, color: colors.textSecondary),
                        ),
                        if (i < reflections.length - 1) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 12, color: colors.textMuted),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Restore button
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onRestore,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: colors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.primary.withAlpha(50)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restore_rounded, size: 18, color: colors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Restore Cycle',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
