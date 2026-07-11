import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/theme.dart';

/// Celebratory animation for task completion
/// Shows particle explosion + XP orb that flies toward a target
class CompletionAnimation extends StatefulWidget {
  final GlobalKey? xpBarKey;
  final int xpAmount;
  final VoidCallback? onComplete;

  const CompletionAnimation({
    super.key,
    this.xpBarKey,
    required this.xpAmount,
    this.onComplete,
  });

  @override
  State<CompletionAnimation> createState() => _CompletionAnimationState();
}

class _CompletionAnimationState extends State<CompletionAnimation>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _orbController;

  final List<_Particle> _particles = [];
  Offset? _orbStart;
  Offset? _orbEnd;
  bool _particlesSeeded = false;

  @override
  void initState() {
    super.initState();

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _orbController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _calculateOrbPath();
        _orbController.forward().then((_) {
          widget.onComplete?.call();
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_particlesSeeded) {
      _seedParticles();
      _particlesSeeded = true;
      _particleController.forward();
    }
  }

  void _seedParticles() {
    final colors = context.colors;
    final palette = CategoryPalette.of(context);
    final swatches = [
      colors.success,
      colors.primary,
      colors.accent,
      palette[5], // gold
    ];
    final random = math.Random();
    for (int i = 0; i < 12; i++) {
      _particles.add(
        _Particle(
          angle: (2 * math.pi * i) / 12 + random.nextDouble() * 0.3,
          distance: 40 + random.nextDouble() * 30,
          size: 4 + random.nextDouble() * 4,
          color: swatches[random.nextInt(swatches.length)],
        ),
      );
    }
  }

  void _calculateOrbPath() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _orbStart = renderBox.localToGlobal(
      Offset(renderBox.size.width / 2, renderBox.size.height / 2),
    );

    if (widget.xpBarKey?.currentContext != null) {
      final xpBox =
          widget.xpBarKey!.currentContext!.findRenderObject() as RenderBox?;
      if (xpBox != null) {
        _orbEnd = xpBox.localToGlobal(
          Offset(xpBox.size.width / 2, xpBox.size.height / 2),
        );
      }
    }

    _orbEnd ??= const Offset(100, 50);
  }

  @override
  void dispose() {
    _particleController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ...List.generate(_particles.length, (i) {
          final particle = _particles[i];
          return AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              final progress = Curves.easeOut.transform(
                _particleController.value,
              );
              final opacity =
                  1.0 - Curves.easeIn.transform(_particleController.value);

              return Positioned(
                left: progress * particle.distance * math.cos(particle.angle),
                top: progress * particle.distance * math.sin(particle.angle),
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: particle.size,
                    height: particle.size,
                    decoration: BoxDecoration(
                      color: particle.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: particle.color.withAlpha(128),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),

        if (_orbStart != null && _orbEnd != null)
          AnimatedBuilder(
            animation: _orbController,
            builder: (context, child) {
              final progress = Curves.easeInOut.transform(
                _orbController.value,
              );
              final currentPos = Offset.lerp(_orbStart!, _orbEnd!, progress)!;
              final arcHeight = -60.0 * (1 - (2 * progress - 1).abs());

              return Positioned(
                left: currentPos.dx - 16,
                top: currentPos.dy + arcHeight - 16,
                child:
                    Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colors.warning,
                                colors.warning.withAlpha(200),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colors.warning.withAlpha(128),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '+${widget.xpAmount}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colors.onPrimary,
                              ),
                            ),
                          ),
                        )
                        .animate(onComplete: (_) {})
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1.0, 1.0),
                          duration: 200.ms,
                          curve: Curves.elasticOut,
                        ),
              );
            },
          ),
      ],
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final double size;
  final Color color;

  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
  });
}

/// Overlay helper to show completion animation at a specific position
class CompletionOverlay {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required Offset position,
    GlobalKey? xpBarKey,
    int xpAmount = 15,
  }) {
    _currentEntry?.remove();

    _currentEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 50,
        top: position.dy - 50,
        child: SizedBox(
          width: 100,
          height: 100,
          child: CompletionAnimation(
            xpBarKey: xpBarKey,
            xpAmount: xpAmount,
            onComplete: () {
              _currentEntry?.remove();
              _currentEntry = null;
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentEntry!);
  }
}
