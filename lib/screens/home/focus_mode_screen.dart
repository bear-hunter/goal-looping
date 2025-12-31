import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/task.dart';
import '../../models/habit.dart';
import '../../models/subtask.dart';
import '../../providers/app_state.dart';
import '../../services/storage_service.dart';
import '../../models/focus_log.dart';

/// Focus Mode - Full screen execution view for a task
/// Features: Timer, Distraction Pad, "I'm Stuck" button
class FocusModeScreen extends StatefulWidget {
  final Task task;

  const FocusModeScreen({super.key, required this.task});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  // Pomodoro Timer
  int _initialSeconds = 25 * 60;
  int _secondsRemaining = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;

  // Distraction Pad
  final _distractionController = TextEditingController();
  final List<String> _distractions = [];

  @override
  void dispose() {
    _timer?.cancel();
    _distractionController.dispose();
    super.dispose();
  }

  void _showAdjustTimerDialog() {
    if (_isRunning) return;

    int selectedMins = _initialSeconds ~/ 60;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Focus Duration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [25, 50, 90]
                    .map(
                      (m) => ChoiceChip(
                        label: Text('$m min'),
                        selected: selectedMins == m,
                        onSelected: (s) =>
                            setModalState(() => selectedMins = m),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              Slider(
                value: selectedMins.toDouble(),
                min: 5,
                max: 120,
                divisions: 23,
                label: '$selectedMins min',
                onChanged: (v) => setModalState(() => selectedMins = v.round()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _initialSeconds = selectedMins * 60;
                      _secondsRemaining = _initialSeconds;
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Set Timer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            if (_secondsRemaining > 0) {
              _secondsRemaining--;
            } else {
              _isRunning = false;
              timer.cancel();
              _showTimerComplete();
            }
          });
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _timer?.cancel();
      _isRunning = false;
      _secondsRemaining = _initialSeconds;
    });
  }

  void _showTimerComplete() {
    // Save Focus Session Log
    final state = context.read<AppState>();
    final sessionLog = FocusLog(
      id: StorageService.generateId(),
      taskId: widget.task.id,
      taskTitle: widget.task.title,
      startTime: DateTime.now().subtract(Duration(seconds: _initialSeconds)),
      duration: Duration(seconds: _initialSeconds),
      completedPomodoros: 1,
      distractions: List.from(_distractions),
    );
    state.saveFocusSession(sessionLog);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Icon(Icons.celebration_rounded, color: AppColors.success),
            const SizedBox(width: 8),
            const Text('Focus Session Complete!'),
          ],
        ),
        content: Text(
          'Great work! You focused for ${_initialSeconds ~/ 60} minutes.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _secondsRemaining = 5 * 60); // 5 min break
            },
            child: const Text('Start Break'),
          ),
        ],
      ),
    );
  }

  void _addDistraction() {
    final text = _distractionController.text.trim();
    if (text.isNotEmpty) {
      setState(() => _distractions.add(text));
      _distractionController.clear();

      // Add to backlog as a new task
      final state = context.read<AppState>();
      final newTask = Task(
        id: StorageService.generateId(),
        title: text,
        isPriority: false,
        linkedFactorIds: widget.task.linkedFactorIds,
      );
      state.addTask(newTask);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📝 Added to backlog: $text'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.info,
        ),
      );
    }
  }

  void _showStuckDialog() {
    final state = context.read<AppState>();
    // Get build habits (scripted actions)
    final scriptedActions = state.habits
        .where((h) => h.type == HabitType.build)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology_rounded, color: AppColors.warning),
                const SizedBox(width: 8),
                Text(
                  'You\'re Stuck?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Your Scripted Actions:',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            if (scriptedActions.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No scripted actions yet. Add them in the Habits screen!',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              )
            else
              ...scriptedActions
                  .take(5)
                  .map(
                    (action) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.success.withAlpha(50),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '✓',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              action.name,
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
            Text('Quick Tips:', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            _QuickTip(icon: Icons.air_rounded, text: 'Take 3 deep breaths'),
            _QuickTip(
              icon: Icons.directions_walk_rounded,
              text: 'Stand up and stretch',
            ),
            _QuickTip(
              icon: Icons.edit_note_rounded,
              text: 'Break into smaller steps',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Got it!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final subtasks = state.getSubtasksForTask(widget.task.id);
        final completedSubtasks = subtasks.where((s) => s.isCompleted).length;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Minimal header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Focus Mode',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Timer
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withAlpha(30),
                                AppColors.success.withAlpha(20),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _formatTime(_secondsRemaining),
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.textPrimary,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _TimerButton(
                                    icon: _isRunning
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: AppColors.primary,
                                    onTap: _toggleTimer,
                                  ),
                                  const SizedBox(width: 16),
                                  _TimerButton(
                                    icon: Icons.replay_rounded,
                                    color: AppColors.textMuted,
                                    onTap: _resetTimer,
                                  ),
                                  const SizedBox(width: 16),
                                  _TimerButton(
                                    icon: Icons.timer_outlined,
                                    color: AppColors.info,
                                    onTap: _showAdjustTimerDialog,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms),

                        const SizedBox(height: 24),

                        // Task Title - Hero animation target
                        Hero(
                          tag: 'task-${widget.task.id}',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.glassBorder,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        widget.task.effortEmoji,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.task.impactEmoji,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (subtasks.isNotEmpty)
                                        Text(
                                          '$completedSubtasks/${subtasks.length}',
                                          style: TextStyle(
                                            color: AppColors.textMuted,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.task.title,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  if (widget.task.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.task.description,
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Subtasks
                        if (subtasks.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ...subtasks.map(
                            (st) => _SubtaskItem(
                              subtask: st,
                              onToggle: () {
                                st.isCompleted = !st.isCompleted;
                                state.updateSubtask(st);
                              },
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Distraction Pad
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withAlpha(15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.warning.withAlpha(40),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline_rounded,
                                    size: 18,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Distraction Pad',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Offload thoughts here → auto-adds to backlog',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _distractionController,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Got distracted by...',
                                        hintStyle: TextStyle(
                                          color: AppColors.textMuted,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: AppColors.surface,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                      ),
                                      onSubmitted: (_) => _addDistraction(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      Icons.add_rounded,
                                      color: AppColors.warning,
                                    ),
                                    onPressed: _addDistraction,
                                  ),
                                ],
                              ),
                              if (_distractions.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: _distractions
                                      .map(
                                        (d) => Chip(
                                          label: Text(
                                            d,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                          backgroundColor:
                                              AppColors.surfaceLight,
                                          padding: EdgeInsets.zero,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),

                // Bottom action bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.glassBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showStuckDialog,
                          icon: Icon(
                            Icons.help_outline_rounded,
                            color: AppColors.warning,
                          ),
                          label: Text(
                            'I\'m Stuck',
                            style: TextStyle(color: AppColors.warning),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.warning),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            widget.task.complete();
                            state.updateTask(widget.task);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🎉 Task completed!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Complete'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TimerButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TimerButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}

class _SubtaskItem extends StatelessWidget {
  final Subtask subtask;
  final VoidCallback onToggle;

  const _SubtaskItem({required this.subtask, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: subtask.isCompleted
              ? AppColors.success.withAlpha(20)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: subtask.isCompleted
                ? AppColors.success.withAlpha(50)
                : AppColors.glassBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              subtask.isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: subtask.isCompleted
                  ? AppColors.success
                  : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                subtask.title,
                style: TextStyle(
                  color: subtask.isCompleted
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                  decoration: subtask.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickTip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _QuickTip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.info),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
