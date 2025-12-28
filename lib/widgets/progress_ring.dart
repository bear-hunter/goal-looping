import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// Animated circular progress ring for visualizing gaps and streaks
class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 60,
    this.strokeWidth = 6,
    this.progressColor,
    this.backgroundColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressRingPainter(
              progress: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              progressColor: progressColor ?? AppColors.primary,
              backgroundColor: backgroundColor ?? AppColors.surfaceLight,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [progressColor, progressColor.withOpacity(0.7)],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}

/// Gap indicator with color coding based on gap size
class GapIndicator extends StatelessWidget {
  final int targetLevel;
  final int currentLevel;
  final double size;

  const GapIndicator({
    super.key,
    required this.targetLevel,
    required this.currentLevel,
    this.size = 50,
  });

  int get gap => targetLevel - currentLevel;
  double get progress => targetLevel > 0 ? currentLevel / targetLevel : 0;

  Color get gapColor {
    if (gap <= 1) return AppColors.success;
    if (gap <= 3) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return ProgressRing(
      progress: progress,
      size: size,
      progressColor: gapColor,
      child: Text(
        '$currentLevel/$targetLevel',
        style: TextStyle(
          fontSize: size * 0.22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Streak flame indicator
class StreakIndicator extends StatelessWidget {
  final int streak;
  final double size;

  const StreakIndicator({
    super.key,
    required this.streak,
    this.size = 50,
  });

  Color get flameColor {
    if (streak >= 30) return AppColors.danger;
    if (streak >= 7) return AppColors.warning;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            flameColor.withOpacity(0.3),
            flameColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: flameColor,
            size: size * 0.4,
          ),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: size * 0.24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
