import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/theme.dart';
import '../../providers/app_state.dart';
import '../../models/spaced_repetition_subject.dart';
import '../../models/spaced_repetition_topic.dart';

/// Spaced Repetition Scheduling Screen
///
/// Japanese minimalist design principles:
/// - High information density: compact rows, minimal padding
/// - Flat hierarchy: single-level visual treatment with subtle dividers
/// - Efficient space usage: no unnecessary whitespace
/// - Touch accessible: minimum 48px tap targets
class SpacedRepetitionScreen extends StatelessWidget {
  const SpacedRepetitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Fukushū',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '📚✍️',
              style: TextStyle(fontSize: 14, color: colors.textMuted),
            ),
          ],
        ),
        actions: [
          Consumer<AppState>(
            builder: (context, state, _) {
              final dueCount = state.dueTopicsCount;
              return dueCount > 0
                  ? Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$dueCount due',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.warning,
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddSubjectDialog(context),
            tooltip: 'Add Subject',
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (state.srSubjects.isEmpty) {
            return _buildEmptyState(context, colors);
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 100),
            itemCount: state.srSubjects.length,
            itemBuilder: (context, index) {
              final subject = state.srSubjects[index];
              return _SubjectCard(
                subject: subject,
                topics: state.getTopicsForSubject(subject.id),
                dueCount: state.getDueCountForSubject(subject.id),
                onToggleExpand: () => state.toggleSubjectExpanded(subject.id),
                onAddTopic: () => _showAddTopicDialog(context, subject.id),
                onEditSubject: () => _showEditSubjectDialog(context, subject),
                onDeleteSubject: () => _confirmDeleteSubject(context, subject),
              ).animate().fadeIn(duration: 200.ms, delay: (index * 50).ms);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppColorsTheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: colors.textMuted.withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            'No subjects yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a subject to start scheduling reviews',
            style: TextStyle(fontSize: 13, color: colors.textMuted),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddSubjectDialog(context),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Subject'),
          ),
        ],
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    IconData selectedIcon = Icons.school_rounded;
    Color selectedColor = DefaultSubjects.availableColors.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final colors = context.colors;
          return Container(
            margin: const EdgeInsets.all(16),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'New Subject',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Subject name',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                ),
                const SizedBox(height: 16),
                // Icon picker
                Text(
                  'Icon',
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: DefaultSubjects.availableIcons.length,
                    itemBuilder: (context, index) {
                      final icon = DefaultSubjects.availableIcons[index];
                      final isSelected = icon == selectedIcon;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedIcon = icon),
                        child: Container(
                          width: 44,
                          height: 44,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? selectedColor.withAlpha(30)
                                : colors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: selectedColor, width: 2)
                                : null,
                          ),
                          child: Icon(
                            icon,
                            color: isSelected
                                ? selectedColor
                                : colors.textMuted,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Color picker
                Text(
                  'Color',
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: DefaultSubjects.availableColors.length,
                    itemBuilder: (context, index) {
                      final color = DefaultSubjects.availableColors[index];
                      final isSelected = color == selectedColor;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedColor = color),
                        child: Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: colors.textPrimary,
                                    width: 3,
                                  )
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    final subject = SpacedRepetitionSubject.create(
                      id: const Uuid().v4(),
                      name: nameController.text.trim(),
                      icon: selectedIcon,
                      color: selectedColor,
                      sortOrder: context.read<AppState>().srSubjects.length,
                    );
                    context.read<AppState>().addSubject(subject);
                    Navigator.pop(context);
                  },
                  child: const Text('Create Subject'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditSubjectDialog(
    BuildContext context,
    SpacedRepetitionSubject subject,
  ) {
    final nameController = TextEditingController(text: subject.name);
    IconData selectedIcon = subject.icon;
    Color selectedColor = subject.color;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final colors = context.colors;
          return Container(
            margin: const EdgeInsets.all(16),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Edit Subject',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Subject name',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Icon',
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: DefaultSubjects.availableIcons.length,
                    itemBuilder: (context, index) {
                      final icon = DefaultSubjects.availableIcons[index];
                      final isSelected = icon == selectedIcon;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedIcon = icon),
                        child: Container(
                          width: 44,
                          height: 44,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? selectedColor.withAlpha(30)
                                : colors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: selectedColor, width: 2)
                                : null,
                          ),
                          child: Icon(
                            icon,
                            color: isSelected
                                ? selectedColor
                                : colors.textMuted,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Color',
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: DefaultSubjects.availableColors.length,
                    itemBuilder: (context, index) {
                      final color = DefaultSubjects.availableColors[index];
                      final isSelected = color == selectedColor;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedColor = color),
                        child: Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: colors.textPrimary,
                                    width: 3,
                                  )
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    final updated = subject.copyWith(
                      name: nameController.text.trim(),
                      icon: selectedIcon,
                      color: selectedColor,
                    );
                    context.read<AppState>().updateSubject(updated);
                    Navigator.pop(context);
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddTopicDialog(BuildContext context, String subjectId) {
    final nameController = TextEditingController();
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'New Topic',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Topic name',
                prefixIcon: Icon(Icons.article_outlined),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                final topic = SpacedRepetitionTopic(
                  id: const Uuid().v4(),
                  subjectId: subjectId,
                  name: nameController.text.trim(),
                  sortOrder: context
                      .read<AppState>()
                      .getTopicsForSubject(subjectId)
                      .length,
                );
                context.read<AppState>().addTopic(topic);
                Navigator.pop(context);
              },
              child: const Text('Add Topic'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteSubject(
    BuildContext context,
    SpacedRepetitionSubject subject,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Subject?'),
        content: Text(
          'This will also delete all topics in "${subject.name}". This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().deleteSubject(subject.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Subject card with expandable topic list
class _SubjectCard extends StatelessWidget {
  final SpacedRepetitionSubject subject;
  final List<SpacedRepetitionTopic> topics;
  final int dueCount;
  final VoidCallback onToggleExpand;
  final VoidCallback onAddTopic;
  final VoidCallback onEditSubject;
  final VoidCallback onDeleteSubject;

  const _SubjectCard({
    required this.subject,
    required this.topics,
    required this.dueCount,
    required this.onToggleExpand,
    required this.onAddTopic,
    required this.onEditSubject,
    required this.onDeleteSubject,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.glassBorder.withAlpha(15), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subject header - tap to expand/collapse
          InkWell(
            onTap: onToggleExpand,
            onLongPress: () => _showSubjectOptions(context),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Expand/collapse icon
                  Icon(
                    subject.isExpanded
                        ? Icons.expand_more_rounded
                        : Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  // Subject icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: subject.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(subject.icon, size: 18, color: subject.color),
                  ),
                  const SizedBox(width: 10),
                  // Subject name
                  Expanded(
                    child: Text(
                      subject.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  // Due count badge
                  if (dueCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$dueCount',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  // Topic count
                  const SizedBox(width: 8),
                  Text(
                    '${topics.length}',
                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          // Topics list (when expanded)
          if (subject.isExpanded) ...[
            Divider(height: 1, thickness: 1, color: colors.divider),
            if (topics.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No topics yet',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ...topics.map(
                (topic) => _TopicRow(topic: topic, subjectColor: subject.color),
              ),
            // Add topic button
            InkWell(
              onTap: onAddTopic,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: colors.divider, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_rounded, size: 16, color: colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Add topic',
                      style: TextStyle(fontSize: 13, color: colors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSubjectOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Subject'),
              onTap: () {
                Navigator.pop(ctx);
                onEditSubject();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.danger),
              title: Text(
                'Delete Subject',
                style: TextStyle(color: AppColors.danger),
              ),
              onTap: () {
                Navigator.pop(ctx);
                onDeleteSubject();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Topic row with review status and interval selection
class _TopicRow extends StatelessWidget {
  final SpacedRepetitionTopic topic;
  final Color subjectColor;

  const _TopicRow({required this.topic, required this.subjectColor});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDue = topic.isDue;
    final isNew = topic.isNew;

    return InkWell(
      onTap: () => _showIntervalPicker(context),
      onLongPress: () => _showTopicOptions(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.divider, width: 1)),
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isNew
                    ? colors.textMuted
                    : isDue
                    ? AppColors.warning
                    : AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            // Topic name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (topic.reviewCount > 0)
                    Text(
                      '${topic.reviewCount} reviews',
                      style: TextStyle(fontSize: 11, color: colors.textMuted),
                    ),
                ],
              ),
            ),
            // Status label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    (isNew
                            ? colors.textMuted
                            : isDue
                            ? AppColors.warning
                            : AppColors.success)
                        .withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                topic.statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isNew
                      ? colors.textSecondary
                      : isDue
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIntervalPicker(BuildContext context) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Schedule Next Review',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              topic.name,
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
            const SizedBox(height: 20),
            // Interval chips - 2 rows of 3
            Row(
              children: [
                _IntervalChip(
                  label: '1d',
                  fullLabel: '1 Day',
                  days: 1,
                  topicId: topic.id,
                  color: subjectColor,
                ),
                const SizedBox(width: 8),
                _IntervalChip(
                  label: '2d',
                  fullLabel: '2 Days',
                  days: 2,
                  topicId: topic.id,
                  color: subjectColor,
                ),
                const SizedBox(width: 8),
                _IntervalChip(
                  label: '3d',
                  fullLabel: '3 Days',
                  days: 3,
                  topicId: topic.id,
                  color: subjectColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _IntervalChip(
                  label: '1w',
                  fullLabel: '1 Week',
                  days: 7,
                  topicId: topic.id,
                  color: subjectColor,
                ),
                const SizedBox(width: 8),
                _IntervalChip(
                  label: '1m',
                  fullLabel: '1 Month',
                  days: 30,
                  topicId: topic.id,
                  color: subjectColor,
                ),
                const SizedBox(width: 8),
                _IntervalChip(
                  label: '1y',
                  fullLabel: '1 Year',
                  days: 365,
                  topicId: topic.id,
                  color: subjectColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopicOptions(BuildContext context) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Topic'),
              onTap: () {
                Navigator.pop(ctx);
                _showEditTopicDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.danger),
              title: Text(
                'Delete Topic',
                style: TextStyle(color: AppColors.danger),
              ),
              onTap: () {
                Navigator.pop(ctx);
                context.read<AppState>().deleteTopic(topic.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTopicDialog(BuildContext context) {
    final nameController = TextEditingController(text: topic.name);
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit Topic',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Topic name',
                prefixIcon: Icon(Icons.article_outlined),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                final updated = topic.copyWith(
                  name: nameController.text.trim(),
                );
                context.read<AppState>().updateTopic(updated);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Interval selection chip
class _IntervalChip extends StatelessWidget {
  final String label;
  final String fullLabel;
  final int days;
  final String topicId;
  final Color color;

  const _IntervalChip({
    required this.label,
    required this.fullLabel,
    required this.days,
    required this.topicId,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.read<AppState>().completeTopic(topicId, days);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Scheduled review in $fullLabel'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withAlpha(40), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  fullLabel,
                  style: TextStyle(fontSize: 10, color: colors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
