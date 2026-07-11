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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startConfetti();
      });
    }
  }

  @override
  void didUpdateWidget(ConfettiCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _startConfetti();
    }
  }

  List<Color> _delightPalette(BuildContext context) {
    final colors = context.colors;
    final palette = CategoryPalette.of(context);
    return [
      colors.primary,
      colors.success,
      colors.accent,
      palette[2], // wisteria
      palette[5], // gold
      palette[6], // sage
    ];
  }

  void _startConfetti() {
    final colors = _delightPalette(context);
    _particles.clear();
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(
        _ConfettiParticle(
          color: colors[_random.nextInt(colors.length)],
          x: _random.nextDouble(),
          y: -_random.nextDouble() * 0.3,
          speedX: (_random.nextDouble() - 0.5) * 2,
          speedY: _random.nextDouble() * 2 + 1,
          rotation: _random.nextDouble() * 360,
          rotationSpeed: (_random.nextDouble() - 0.5) * 720,
          size: _random.nextDouble() * 8 + 4,
          shape: _random.nextInt(3),
        ),
      );
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
        ..color = particle.color
            .withAlpha((255 * (1 - progress * 0.8)).toInt())
        ..style = PaintingStyle.fill;

      final x = size.width * (particle.x + particle.speedX * progress * 0.3);
      final y = size.height * (particle.y + particle.speedY * progress);
      final rotation =
          (particle.rotation + particle.rotationSpeed * progress) * pi / 180;

      if (y > size.height * 1.1) continue;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      switch (particle.shape) {
        case 0:
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
        case 1:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size,
            ),
            paint,
          );
          break;
        case 2:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size * 2.5,
            ),
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

  const ConfettiOverlay({super.key, required this.child, this.confettiKey});

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
