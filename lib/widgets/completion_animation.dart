import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/theme.dart';

/// Celebratory animation for task completion
/// Shows particle explosion + XP orb that flies toward a target
class CompletionAnimation extends StatefulWidget {
  /// Key of the XP bar widget to fly the orb toward
  final GlobalKey? xpBarKey;

  /// Amount of XP to display
  final int xpAmount;

  /// Called when animation completes
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

    // Generate particles
    final random = math.Random();
    for (int i = 0; i < 12; i++) {
      _particles.add(
        _Particle(
          angle: (2 * math.pi * i) / 12 + random.nextDouble() * 0.3,
          distance: 40 + random.nextDouble() * 30,
          size: 4 + random.nextDouble() * 4,
          color: [
            AppColors.success,
            AppColors.primary,
            AppColors.warning,
            Colors.white,
          ][random.nextInt(4)],
        ),
      );
    }

    // Start particle animation
    _particleController.forward();

    // Delay orb flight slightly
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _calculateOrbPath();
        _orbController.forward().then((_) {
          widget.onComplete?.call();
        });
      }
    });
  }

  void _calculateOrbPath() {
    // Get the center of this widget as start
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _orbStart = renderBox.localToGlobal(
      Offset(renderBox.size.width / 2, renderBox.size.height / 2),
    );

    // Get the XP bar position as end
    if (widget.xpBarKey?.currentContext != null) {
      final xpBox =
          widget.xpBarKey!.currentContext!.findRenderObject() as RenderBox?;
      if (xpBox != null) {
        _orbEnd = xpBox.localToGlobal(
          Offset(xpBox.size.width / 2, xpBox.size.height / 2),
        );
      }
    }

    // Fallback to top of screen if no XP bar
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Particles
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

        // XP Orb
        if (_orbStart != null && _orbEnd != null)
          AnimatedBuilder(
            animation: _orbController,
            builder: (context, child) {
              final progress = Curves.easeInOut.transform(_orbController.value);
              final currentPos = Offset.lerp(_orbStart!, _orbEnd!, progress)!;

              // Arc the path upward
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
                                AppColors.warning,
                                AppColors.warning.withAlpha(200),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.warning.withAlpha(128),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '+${widget.xpAmount}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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

  /// Show completion animation at the given global position
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
