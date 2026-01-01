import 'dart:math';
import 'package:flutter/material.dart';

import '../core/theme/theme.dart';

/// A simple confetti celebration widget
/// Shows colored particles falling/floating when triggered
class ConfettiCelebration extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback? onComplete;
  final int particleCount;
  final Duration duration;

  const ConfettiCelebration({
    super.key,
    required this.isPlaying,
    this.onComplete,
    this.particleCount = 50,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  // Celebration colors
  static final List<Color> _colors = [
    AppColors.primary,
    AppColors.success,
    AppColors.warning,
    AppColors.info,
    const Color(0xFFFF6B6B), // Coral
    const Color(0xFFA855F7), // Purple
    const Color(0xFFFBBF24), // Gold
    const Color(0xFF22D3EE), // Cyan
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.isPlaying) {
      _startConfetti();
    }
  }

  @override
  void didUpdateWidget(ConfettiCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _startConfetti();
    }
  }

  void _startConfetti() {
    _particles.clear();
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_ConfettiParticle(
        color: _colors[_random.nextInt(_colors.length)],
        x: _random.nextDouble(),
        y: -_random.nextDouble() * 0.3, // Start above screen
        speedX: (_random.nextDouble() - 0.5) * 2,
        speedY: _random.nextDouble() * 2 + 1,
        rotation: _random.nextDouble() * 360,
        rotationSpeed: (_random.nextDouble() - 0.5) * 720,
        size: _random.nextDouble() * 8 + 4,
        shape: _random.nextInt(3), // 0=circle, 1=square, 2=rectangle
      ));
    }
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying && _particles.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ConfettiParticle {
  final Color color;
  final double x;
  final double y;
  final double speedX;
  final double speedY;
  final double rotation;
  final double rotationSpeed;
  final double size;
  final int shape;

  _ConfettiParticle({
    required this.color,
    required this.x,
    required this.y,
    required this.speedX,
    required this.speedY,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withAlpha((255 * (1 - progress * 0.8)).toInt())
        ..style = PaintingStyle.fill;

      // Calculate position with physics
      final x = size.width * (particle.x + particle.speedX * progress * 0.3);
      final y = size.height * (particle.y + particle.speedY * progress);
      final rotation = (particle.rotation + particle.rotationSpeed * progress) * pi / 180;

      // Skip particles that are off screen
      if (y > size.height * 1.1) continue;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      switch (particle.shape) {
        case 0: // Circle
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
        case 1: // Square
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size),
            paint,
          );
          break;
        case 2: // Rectangle (confetti strip)
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 2.5),
            paint,
          );
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

/// A convenient overlay for showing confetti over any screen
class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final GlobalKey<ConfettiOverlayState>? confettiKey;

  const ConfettiOverlay({
    super.key,
    required this.child,
    this.confettiKey,
  });

  @override
  State<ConfettiOverlay> createState() => ConfettiOverlayState();
}

class ConfettiOverlayState extends State<ConfettiOverlay> {
  bool _isPlaying = false;

  void celebrate() {
    setState(() => _isPlaying = true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isPlaying)
          Positioned.fill(
            child: IgnorePointer(
              child: ConfettiCelebration(
                isPlaying: _isPlaying,
                onComplete: () => setState(() => _isPlaying = false),
              ),
            ),
          ),
      ],
    );
  }
}
