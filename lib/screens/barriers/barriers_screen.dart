import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/theme.dart';
import '../../models/habit.dart';
import '../../providers/app_state.dart';

/// Standalone Barriers Screen - Track and manage obstacles
class BarriersScreen extends StatefulWidget {
  const BarriersScreen({super.key});

  @override
  State<BarriersScreen> createState() => _BarriersScreenState();
}

class _BarriersScreenState extends State<BarriersScreen> {
  String _filterTag = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.background : LightColors.background;
    final textPrimary = isDark ? AppColors.textPrimary : LightColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : LightColors.textSecondary;
    final surfaceColor = isDark ? AppColors.surfaceLight : LightColors.surfaceLight;

    return Consumer<AppState>(
      builder: (context, state, _) {
        final barriers = state.barriers;
        
        // Filter by tag if not "All"
        final filteredBarriers = _filterTag == 'All'
            ? barriers
            : barriers.where((b) => 
                b.description.toLowerCase().contains(_filterTag.toLowerCase())
              ).toList();
        
        // Sort by date (newest first)
        filteredBarriers.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Barriers',
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.filter_list_rounded, color: textPrimary),
                onPressed: () => _showFilterSheet(context, isDark),
              ),
            ],
          ),
          body: filteredBarriers.isEmpty
              ? _buildEmptyState(textSecondary)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredBarriers.length,
                  itemBuilder: (context, index) {
                    final barrier = filteredBarriers[index];
                    return _BarrierCard(
                      barrier: barrier,
                      isDark: isDark,
                      onTap: () => _showBarrierDetails(context, barrier, state),
                      onToggleHandled: () => _toggleHandled(barrier, state),
                    ).animate().fadeIn(
                      duration: 200.ms,
                      delay: Duration(milliseconds: index * 50),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddBarrierSheet(context, state),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Log Barrier'),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(Color textSecondary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shield_rounded,
            size: 64,
            color: textSecondary.withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            'No barriers logged',
            style: TextStyle(
              color: textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log obstacles when they arise\nto identify patterns',
            style: TextStyle(
              color: textSecondary.withAlpha(150),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, bool isDark) {
    final surfaceColor = isDark ? AppColors.surface : LightColors.surface;
    final textPrimary = isDark ? AppColors.textPrimary : LightColors.textPrimary;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Tag',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _filterTag == 'All',
                  onSelected: (selected) {
                    setState(() => _filterTag = 'All');
                    Navigator.pop(ctx);
                  },
                ),
                ...BarrierTags.common.map((tag) => ChoiceChip(
                  label: Text(tag),
                  selected: _filterTag == tag,
                  onSelected: (selected) {
                    setState(() => _filterTag = tag);
                    Navigator.pop(ctx);
                  },
                )),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAddBarrierSheet(BuildContext context, AppState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surface : LightColors.surface;
    final textPrimary = isDark ? AppColors.textPrimary : LightColors.textPrimary;

    String? selectedTag;
    final descriptionController = TextEditingController();
    final responseController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20, 20, 20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log a Barrier',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Quick tag selection
                Text(
                  'What got in the way?',
                  style: TextStyle(color: textPrimary.withAlpha(180)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: BarrierTags.common.map((tag) => ChoiceChip(
                    label: Text(tag),
                    selected: selectedTag == tag,
                    onSelected: (selected) {
                      setModalState(() => selectedTag = selected ? tag : null);
                    },
                  )).toList(),
                ),
                const SizedBox(height: 16),

                // Description
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe what happened...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                // Response (optional)
                TextField(
                  controller: responseController,
                  decoration: InputDecoration(
                    labelText: 'How did you handle it? (optional)',
                    hintText: 'What did you do to overcome it?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final description = selectedTag ?? descriptionController.text.trim();
                      if (description.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select or describe a barrier')),
                        );
                        return;
                      }

                      final barrier = BarrierEntry(
                        id: const Uuid().v4(),
                        description: description,
                        response: responseController.text.trim().isNotEmpty
                            ? responseController.text.trim()
                            : null,
                        wasHandled: responseController.text.trim().isNotEmpty,
                      );

                      state.addBarrier(barrier);
                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Barrier logged: $description'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Log Barrier'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBarrierDetails(BuildContext context, BarrierEntry barrier, AppState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surface : LightColors.surface;
    final textPrimary = isDark ? AppColors.textPrimary : LightColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : LightColors.textSecondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getBarrierColor(barrier.description).withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: _getBarrierColor(barrier.description),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barrier.description,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(barrier.occurredAt),
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (barrier.wasHandled)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Handled',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
              ],
            ),
            if (barrier.response != null && barrier.response!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'How you handled it:',
                style: TextStyle(color: textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  barrier.response!,
                  style: TextStyle(color: textPrimary),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showEditBarrierSheet(context, barrier, state);
                    },
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _deleteBarrier(barrier, state);
                    },
                    icon: const Icon(Icons.delete_rounded, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBarrierSheet(BuildContext context, BarrierEntry barrier, AppState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surface : LightColors.surface;
    final textPrimary = isDark ? AppColors.textPrimary : LightColors.textPrimary;

    final responseController = TextEditingController(text: barrier.response ?? '');
    bool wasHandled = barrier.wasHandled;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20, 20, 20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Barrier',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                barrier.description,
                style: TextStyle(color: textPrimary.withAlpha(180)),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: responseController,
                decoration: InputDecoration(
                  labelText: 'How did you handle it?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              CheckboxListTile(
                value: wasHandled,
                onChanged: (v) => setModalState(() => wasHandled = v ?? false),
                title: const Text('Mark as handled'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    barrier.response = responseController.text.trim().isNotEmpty
                        ? responseController.text.trim()
                        : null;
                    barrier.wasHandled = wasHandled;
                    state.updateBarrier(barrier);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleHandled(BarrierEntry barrier, AppState state) {
    barrier.wasHandled = !barrier.wasHandled;
    state.updateBarrier(barrier);
  }

  void _deleteBarrier(BarrierEntry barrier, AppState state) {
    // For now just remove from list - would need deleteBarrier method in AppState
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted: ${barrier.description}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => state.addBarrier(barrier),
        ),
      ),
    );
  }

  Color _getBarrierColor(String barrier) {
    switch (barrier.toLowerCase()) {
      case 'tired':
        return Colors.purple;
      case 'no time':
        return Colors.blue;
      case 'stressed':
        return Colors.red;
      case 'distracted':
        return Colors.orange;
      case 'unmotivated':
        return Colors.grey;
      case 'sick':
        return Colors.teal;
      case 'social pressure':
        return Colors.pink;
      case 'forgot':
        return Colors.amber;
      default:
        return Colors.blueGrey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}

/// Barrier Card Widget
class _BarrierCard extends StatelessWidget {
  final BarrierEntry barrier;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onToggleHandled;

  const _BarrierCard({
    required this.barrier,
    required this.isDark,
    required this.onTap,
    required this.onToggleHandled,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark ? AppColors.surfaceLight : LightColors.surfaceLight;
    final textPrimary = isDark ? AppColors.textPrimary : LightColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : LightColors.textSecondary;
    final barrierColor = _getBarrierColor(barrier.description);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: barrierColor, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Handled checkbox
              GestureDetector(
                onTap: onToggleHandled,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: barrier.wasHandled
                        ? Colors.green.withAlpha(30)
                        : Colors.transparent,
                    border: Border.all(
                      color: barrier.wasHandled ? Colors.green : textSecondary,
                      width: 2,
                    ),
                  ),
                  child: barrier.wasHandled
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.green)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      barrier.description,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        decoration: barrier.wasHandled
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 12, color: textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(barrier.occurredAt),
                          style: TextStyle(color: textSecondary, fontSize: 11),
                        ),
                        if (barrier.response != null && barrier.response!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.comment_rounded, size: 12, color: textSecondary),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Chevron
              Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBarrierColor(String barrier) {
    switch (barrier.toLowerCase()) {
      case 'tired':
        return Colors.purple;
      case 'no time':
        return Colors.blue;
      case 'stressed':
        return Colors.red;
      case 'distracted':
        return Colors.orange;
      case 'unmotivated':
        return Colors.grey;
      case 'sick':
        return Colors.teal;
      case 'social pressure':
        return Colors.pink;
      case 'forgot':
        return Colors.amber;
      default:
        return Colors.blueGrey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}
