import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/habit.dart';
import '../../providers/app_state.dart';

/// Full-screen countdown timer for timed habits
class HabitTimerScreen extends StatefulWidget {
  final Habit habit;
  final DateTime? date;

  const HabitTimerScreen({super.key, required this.habit, this.date});

  @override
  State<HabitTimerScreen> createState() => _HabitTimerScreenState();
}

class _HabitTimerScreenState extends State<HabitTimerScreen> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _targetMinutes * 60;
  }

  int get _targetMinutes {
    final configured = widget.habit.timerMinutes ?? widget.habit.targetValue;
    return configured == null || configured < 1 ? 10 : configured;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totalSeconds = _targetMinutes * 60;
    final progress = 1 - (_remainingSeconds / totalSeconds);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.habit.name),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Motivation
              if (widget.habit.motivation.isNotEmpty)
                Text(
                  '"${widget.habit.motivation}"',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 48),

              // Timer circle
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: colors.surfaceLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isComplete ? colors.success : colors.primary,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(_remainingSeconds),
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: _isComplete
                              ? colors.success
                              : colors.textPrimary,
                        ),
                      ),
                      Text(
                        _isComplete
                            ? 'Complete!'
                            : (_isRunning ? 'Focus...' : 'Ready'),
                        style: TextStyle(fontSize: 16, color: colors.textMuted),
                      ),
                    ],
                  ),
                ],
              ).animate().scale(
                begin: const Offset(0.9, 0.9),
                duration: 400.ms,
              ),

              const SizedBox(height: 48),

              // Controls
              if (!_isComplete)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Reset button
                    _ControlButton(
                      icon: Icons.refresh_rounded,
                      color: colors.textMuted,
                      onTap: _reset,
                    ),
                    const SizedBox(width: 24),

                    // Play/Pause button
                    _ControlButton(
                      icon: _isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: colors.primary,
                      size: 80,
                      iconSize: 40,
                      onTap: _isRunning ? _pause : _start,
                    ),
                    const SizedBox(width: 24),

                    // Skip button
                    _ControlButton(
                      icon: Icons.skip_next_rounded,
                      color: colors.textMuted,
                      onTap: _skip,
                    ),
                  ],
                )
              else
                ElevatedButton.icon(
                      onPressed: _finishAndLog,
                      icon: Icon(Icons.check_circle_rounded),
                      label: Text('Complete Habit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.success,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .scale(begin: const Offset(0.9, 0.9)),

              const SizedBox(height: 48),

              // Duration info
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_targetMinutes minute session',
                  style: TextStyle(fontSize: 13, color: colors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = (seconds / 60).floor();
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _start() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
          _isComplete = true;
        });
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _targetMinutes * 60;
      _isRunning = false;
      _isComplete = false;
    });
  }

  void _skip() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 0;
      _isRunning = false;
      _isComplete = true;
    });
  }

  void _finishAndLog() {
    final colors = context.colors;
    context.read<AppState>().logHabit(
      widget.habit.id,
      date: widget.date,
      completed: true,
      timerSeconds: _targetMinutes * 60,
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.habit.name} completed!'),
        backgroundColor: colors.success,
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.color,
    this.size = 56,
    this.iconSize = 28,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          shape: BoxShape.circle,
          border: Border.all(color: color.withAlpha(100), width: 2),
        ),
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }
}
