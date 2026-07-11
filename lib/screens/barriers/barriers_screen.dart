import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/barrier_tag.dart';
import '../../models/habit.dart';
import '../../providers/app_state.dart';
import '../../widgets/log_barrier_sheet.dart';
import '../today/habit_detail_screen.dart';

/// Standalone Barriers screen — an insights dashboard over a unified,
/// tag-based barrier log. Tracks obstacles, surfaces patterns, and lets the
/// user create, edit and delete barriers.
class BarriersScreen extends StatefulWidget {
  const BarriersScreen({super.key});

  @override
  State<BarriersScreen> createState() => _BarriersScreenState();
}

class _BarriersScreenState extends State<BarriersScreen> {
  /// Active tag-key filter; null means "All".
  String? _filterKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Barriers',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          final barriers = state.barriers;
          if (barriers.isEmpty) {
            return _buildEmptyState(colors);
          }

          // Tag keys actually present, in canonical order — drives the filter.
          final presentKeys = [
            for (final t in BarrierTags.all)
              if (barriers.any((b) => (b.tag ?? 'other') == t.key)) t.key,
          ];
          // A stale filter (its tag no longer has entries) falls back to All.
          final activeFilter =
              presentKeys.contains(_filterKey) ? _filterKey : null;

          final filtered =
              (activeFilter == null
                  ? List<BarrierEntry>.from(barriers)
                  : barriers
                        .where((b) => (b.tag ?? 'other') == activeFilter)
                        .toList())
                ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              _buildDashboard(context, state),
              const SizedBox(height: 16),
              if (presentKeys.length > 1) ...[
                _FilterChips(
                  presentKeys: presentKeys,
                  selected: activeFilter,
                  onSelect: (key) => setState(() => _filterKey = key),
                ),
                const SizedBox(height: 12),
              ],
              for (var i = 0; i < filtered.length; i++)
                _BarrierCard(
                  barrier: filtered[i],
                  habitName: _habitName(state, filtered[i].linkedHabitId),
                  taskTitle: _taskTitle(state, filtered[i].linkedTaskId),
                  onTap: () =>
                      LogBarrierSheet.show(context, existing: filtered[i]),
                  onDelete: () => _deleteBarrier(context, state, filtered[i]),
                ).animate().fadeIn(
                  duration: 200.ms,
                  delay: Duration(milliseconds: i * 40),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => LogBarrierSheet.show(context),
        backgroundColor: colors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Barrier'),
      ),
    );
  }

  // --- Dashboard ---------------------------------------------------------

  Widget _buildDashboard(BuildContext context, AppState state) {
    final colors = context.colors;
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 7));
    final monthStart = now.subtract(const Duration(days: 30));
    final weekCount = state.barriersInRange(weekStart, now).length;
    final monthCount = state.barriersInRange(monthStart, now).length;
    final handledPct = (state.barrierHandledRate() * 100).round();

    final counts = state.barrierCountsByTag();
    final topTags =
        counts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = topTags.isEmpty ? 1 : topTags.first.value;

    final blockedId = state.mostBlockedHabitId();
    final blockedHabit = _habitById(state, blockedId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: '$weekCount',
                label: 'This week',
                icon: Icons.calendar_view_week_rounded,
                color: colors.info,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                value: '$monthCount',
                label: 'This month',
                icon: Icons.calendar_month_rounded,
                color: colors.warning,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                value: '$handledPct%',
                label: 'Handled',
                icon: Icons.shield_rounded,
                color: colors.success,
              ),
            ),
          ],
        ),
        if (topTags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Top barriers',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (final entry in topTags.take(5))
                  _TagBar(
                    info: BarrierTags.byKeyOrOther(entry.key),
                    count: entry.value,
                    maxCount: maxCount,
                  ),
              ],
            ),
          ),
        ],
        if (blockedHabit != null) ...[
          const SizedBox(height: 16),
          _MostBlockedTile(
            habitName: blockedHabit.name,
            barrierCount: state.barriersForHabit(blockedHabit.id).length,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    HabitDetailScreen(habitId: blockedHabit.id),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(AppColorsTheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shield_rounded,
            size: 64,
            color: colors.textSecondary.withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            'No barriers logged',
            style: TextStyle(color: colors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Log obstacles when they arise\nto spot patterns over time.',
            style: TextStyle(
              color: colors.textSecondary.withAlpha(150),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => LogBarrierSheet.show(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Log your first barrier'),
          ),
        ],
      ),
    );
  }

  // --- Actions -----------------------------------------------------------

  void _deleteBarrier(
    BuildContext context,
    AppState state,
    BarrierEntry barrier,
  ) {
    state.deleteBarrier(barrier.id);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Barrier deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => state.addBarrier(barrier),
        ),
      ),
    );
  }

  // --- Link resolution (never throws on a dangling id) -------------------

  Habit? _habitById(AppState state, String? id) {
    if (id == null) return null;
    for (final h in state.habits) {
      if (h.id == id) return h;
    }
    return null;
  }

  String? _habitName(AppState state, String? id) => _habitById(state, id)?.name;

  String? _taskTitle(AppState state, String? id) {
    if (id == null) return null;
    for (final t in state.tasks) {
      if (t.id == id) return t.title;
    }
    return null;
  }
}

/// A compact dashboard stat tile.
class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: colors.textSecondary, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// One row in the "Top barriers" list: icon, label, proportional bar, count.
class _TagBar extends StatelessWidget {
  final BarrierTagInfo info;
  final int count;
  final int maxCount;

  const _TagBar({
    required this.info,
    required this.count,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = BarrierTags.resolveColor(context, info.key);
    final fraction = maxCount == 0 ? 0.0 : count / maxCount;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(info.icon, size: 16, color: color),
          const SizedBox(width: 8),
          SizedBox(
            width: 92,
            child: Text(
              info.label,
              style: TextStyle(color: colors.textPrimary, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                backgroundColor: colors.glassBorder,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tappable tile highlighting the habit blocked by the most barriers.
class _MostBlockedTile extends StatelessWidget {
  final String habitName;
  final int barrierCount;
  final VoidCallback onTap;

  const _MostBlockedTile({
    required this.habitName,
    required this.barrierCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.danger.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.danger.withAlpha(60)),
        ),
        child: Row(
          children: [
            Icon(Icons.report_problem_rounded, color: colors.danger),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Most blocked habit',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    habitName,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              '$barrierCount',
              style: TextStyle(
                color: colors.danger,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrolling tag filter (All + one chip per present tag).
class _FilterChips extends StatelessWidget {
  final List<String> presentKeys;
  final String? selected;
  final ValueChanged<String?> onSelect;

  const _FilterChips({
    required this.presentKeys,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(context, label: 'All', key: null),
          for (final key in presentKeys)
            _chip(
              context,
              label: BarrierTags.byKeyOrOther(key).label,
              key: key,
            ),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required String? key,
  }) {
    final colors = context.colors;
    final isSelected = selected == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelect(key),
        labelStyle: TextStyle(
          color: isSelected ? colors.onPrimary : colors.textSecondary,
          fontSize: 13,
        ),
        selectedColor: colors.primary,
        backgroundColor: colors.surfaceLight,
        side: BorderSide(color: colors.glassBorder),
      ),
    );
  }
}

/// A single barrier row: tag, note, links, date, handled badge, mood.
class _BarrierCard extends StatelessWidget {
  final BarrierEntry barrier;
  final String? habitName;
  final String? taskTitle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BarrierCard({
    required this.barrier,
    required this.habitName,
    required this.taskTitle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final info = BarrierTags.byKeyOrOther(barrier.tag);
    final color = BarrierTags.resolveColor(context, barrier.tag);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: colors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(info.icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          info.label,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (barrier.moodRating != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            _moodEmoji(barrier.moodRating!),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                        const Spacer(),
                        if (barrier.wasHandled)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.success.withAlpha(30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Handled',
                              style: TextStyle(
                                color: colors.success,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if ((barrier.note ?? '').isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        barrier.note!,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 10,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _meta(
                          context,
                          Icons.access_time_rounded,
                          _formatDate(barrier.occurredAt),
                        ),
                        if (habitName != null)
                          _meta(
                            context,
                            Icons.loop_rounded,
                            habitName!,
                          ),
                        if (taskTitle != null)
                          _meta(
                            context,
                            Icons.check_circle_outline_rounded,
                            taskTitle!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: colors.textMuted,
                ),
                onPressed: onDelete,
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meta(BuildContext context, IconData icon, String text) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: colors.textSecondary),
        const SizedBox(width: 3),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textSecondary, fontSize: 11),
          ),
        ),
      ],
    );
  }

  String _moodEmoji(int mood) {
    const emojis = ['😢', '😕', '😐', '🙂', '😄'];
    return emojis[(mood - 1).clamp(0, 4)];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final d = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff > 1 && diff < 7) return '$diff days ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}
