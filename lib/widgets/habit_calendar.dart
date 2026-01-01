import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/theme.dart';
import '../models/habit.dart';

/// Calendar widget for visualizing habit streaks (HabitNow style)
class HabitCalendar extends StatefulWidget {
  final Habit habit;
  final Function(DateTime)? onDayTap;
  /// Callback when user wants to log with score for a date
  final Function(DateTime, bool, int?)? onLogWithScore;

  const HabitCalendar({
    super.key,
    required this.habit,
    this.onDayTap,
    this.onLogWithScore,
  });

  @override
  State<HabitCalendar> createState() => _HabitCalendarState();
}

class _HabitCalendarState extends State<HabitCalendar> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          // Month header with navigation
          _buildMonthHeader(),
          const SizedBox(height: 16),
          
          // Day labels
          _buildDayLabels(),
          const SizedBox(height: 8),
          
          // Calendar grid
          _buildCalendarGrid(),
          
          // Legend
          const SizedBox(height: 12),
          _buildLegend(),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildMonthHeader() {
    final monthName = _getMonthName(_currentMonth.month);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
        ),
        Text(
          '$monthName ${_currentMonth.year}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: _nextMonth,
          icon: Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDayLabels() {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((d) => SizedBox(
        width: 32,
        child: Center(
          child: Text(d, style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Monday
    
    final today = DateTime.now();
    final cells = <Widget>[];
    
    // Empty cells for days before the 1st
    for (var i = 1; i < startingWeekday; i++) {
      cells.add(const SizedBox(width: 32, height: 32));
    }
    
    // Day cells
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final status = _getStatusForDate(date);
      final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
      final isFuture = date.isAfter(today);
      final log = widget.habit.getLogFor(date);
      
      cells.add(_DayCell(
        day: day,
        status: status,
        isToday: isToday,
        isFuture: isFuture,
        score: log?.score,
        scoringEnabled: widget.habit.scoringEnabled,
        onTap: widget.onDayTap != null ? () => widget.onDayTap!(date) : null,
      ));
    }
    
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 4,
      runSpacing: 4,
      children: cells,
    );
  }

  Widget _buildLegend() {
    final showScoring = widget.habit.scoringEnabled;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        _LegendItem(color: AppColors.success, label: showScoring ? 'Done (100%)' : 'Done'),
        _LegendItem(color: AppColors.danger, label: showScoring ? 'Missed (0%)' : 'Missed'),
        if (showScoring)
          _LegendItem(color: AppColors.warning, label: 'Partial'),
        _LegendItem(color: AppColors.surfaceLight, label: 'No data'),
      ],
    );
  }

  _DayStatus _getStatusForDate(DateTime date) {
    // Check if habit was scheduled for this day
    if (!widget.habit.scheduledDays.contains(date.weekday)) {
      return _DayStatus.notScheduled;
    }
    
    // Check logs for this date
    final log = widget.habit.logs.where((l) => 
      l.date.year == date.year && 
      l.date.month == date.month && 
      l.date.day == date.day
    ).firstOrNull;
    
    if (log == null) return _DayStatus.noData;
    return log.completed ? _DayStatus.completed : _DayStatus.missed;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    if (nextMonth.isBefore(DateTime(now.year, now.month + 1))) {
      setState(() {
        _currentMonth = nextMonth;
      });
    }
  }

  String _getMonthName(int month) {
    const months = ['', 'January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month];
  }
}

enum _DayStatus { completed, missed, noData, notScheduled }

class _DayCell extends StatelessWidget {
  final int day;
  final _DayStatus status;
  final bool isToday;
  final bool isFuture;
  final int? score;
  final bool scoringEnabled;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.status,
    required this.isToday,
    required this.isFuture,
    this.score,
    this.scoringEnabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    bool showCheckmark = false;
    bool showX = false;
    
    if (isFuture) {
      bgColor = Colors.transparent;
      textColor = AppColors.textMuted;
    } else if (scoringEnabled && score != null) {
      // Score-based coloring: interpolate between red (0) and green (100)
      final normalizedScore = score!.clamp(0, 100) / 100.0;
      if (normalizedScore >= 0.7) {
        bgColor = AppColors.success;
        showCheckmark = true;
      } else if (normalizedScore >= 0.4) {
        bgColor = AppColors.warning;
      } else {
        bgColor = AppColors.danger;
        if (normalizedScore < 0.1) showX = true;
      }
      textColor = Colors.white;
    } else {
      switch (status) {
        case _DayStatus.completed:
          bgColor = AppColors.success;
          textColor = Colors.white;
          showCheckmark = true;
        case _DayStatus.missed:
          bgColor = AppColors.danger;
          textColor = Colors.white;
          showX = true;
        case _DayStatus.noData:
          bgColor = AppColors.surfaceLight;
          textColor = AppColors.textMuted;
        case _DayStatus.notScheduled:
          bgColor = Colors.transparent;
          textColor = AppColors.textMuted;
      }
    }
    
    Widget content;
    if (scoringEnabled && score != null) {
      // Show score percentage
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$score',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          if (showCheckmark)
            Icon(Icons.check, size: 8, color: textColor.withAlpha(200)),
        ],
      );
    } else if (showCheckmark) {
      content = Stack(
        children: [
          Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
          Positioned(
            right: 2,
            top: 2,
            child: Icon(Icons.check, size: 10, color: textColor.withAlpha(200)),
          ),
        ],
      );
    } else if (showX) {
      content = Stack(
        children: [
          Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
          Positioned(
            right: 2,
            top: 2,
            child: Icon(Icons.close, size: 10, color: textColor.withAlpha(200)),
          ),
        ],
      );
    } else {
      content = Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      );
    }
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: isToday 
              ? Border.all(color: AppColors.primary, width: 2) 
              : null,
          boxShadow: (status == _DayStatus.completed || (scoringEnabled && score != null && score! >= 70))
              ? [BoxShadow(color: bgColor.withAlpha(100), blurRadius: 4, spreadRadius: 1)]
              : null,
        ),
        child: content,
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}
