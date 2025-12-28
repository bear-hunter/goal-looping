import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/theme.dart';
import '../models/growth_area.dart';
import '../models/tree_design.dart';

/// Animated tree widget that grows based on level and health
class AnimatedTreeWidget extends StatefulWidget {
  final GrowthArea area;
  final double size;
  final bool showDetails;
  final VoidCallback? onTap;

  const AnimatedTreeWidget({
    super.key,
    required this.area,
    this.size = 150,
    this.showDetails = true,
    this.onTap,
  });

  @override
  State<AnimatedTreeWidget> createState() => _AnimatedTreeWidgetState();
}

class _AnimatedTreeWidgetState extends State<AnimatedTreeWidget>
    with TickerProviderStateMixin {
  late AnimationController _swayController;
  late AnimationController _growthController;
  late Animation<double> _swayAnimation;

  @override
  void initState() {
    super.initState();
    
    _swayController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _growthController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    
    _swayAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _swayController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _swayController.dispose();
    _growthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final design = TreeDesigns.getById(widget.area.treeDesignId);
    final color = _getColorFromHex(design.colorHex);
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.size,
        height: widget.size * 1.3,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background glow for active areas
            if (widget.area.isActiveFocus)
              Container(
                width: widget.size * 0.8,
                height: widget.size * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withAlpha(30),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            
            // The tree
            AnimatedBuilder(
              animation: _swayAnimation,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..rotateZ(_swayAnimation.value * (widget.area.isActiveFocus ? 1 : 0)),
                  child: child,
                );
              },
              child: _buildTree(design, color),
            ),
            
            // Level badge
            if (widget.showDetails)
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withAlpha(100)),
                  ),
                  child: Text(
                    'Lv ${widget.area.currentLevel}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTree(TreeDesign design, Color color) {
    final stage = widget.area.growthStage;
    final health = widget.area.healthPercent;
    
    // Determine tree appearance based on health
    final healthColor = health >= 75
        ? color
        : health >= 50
            ? Color.lerp(color, Colors.yellow, 0.3)!
            : health >= 25
                ? Color.lerp(color, Colors.orange, 0.5)!
                : Colors.grey;
    
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _growthController,
        curve: Curves.elasticOut,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tree canopy
          _buildCanopy(stage, healthColor, design),
          // Trunk
          _buildTrunk(stage),
        ],
      ),
    );
  }

  Widget _buildCanopy(int stage, Color color, TreeDesign design) {
    final baseSize = widget.size * 0.3;
    final growthFactor = 1 + (stage * 0.15);
    final size = baseSize * growthFactor;
    
    if (!widget.area.isActiveFocus) {
      // Dormant: show sleeping emoji
      return Text('💤', style: TextStyle(fontSize: size * 0.8));
    }
    
    if (widget.area.healthStatus == 'dead') {
      // Dead tree
      return Text('💀', style: TextStyle(fontSize: size * 0.8));
    }
    
    // Growth stages with custom shapes
    switch (stage) {
      case 0: // Seed
        return Container(
          width: size * 0.5,
          height: size * 0.5,
          child: CustomPaint(
            painter: _SeedPainter(color: color),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1.seconds);
      
      case 1: // Sprout
        return Container(
          width: size * 0.6,
          height: size * 0.8,
          child: CustomPaint(
            painter: _SproutPainter(color: color),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.03), duration: 2.seconds);
      
      case 2: // Sapling
        return Container(
          width: size * 0.8,
          height: size,
          child: CustomPaint(
            painter: _SaplingPainter(color: color),
          ),
        );
      
      case 3: // Growing
        return Container(
          width: size,
          height: size * 1.2,
          child: CustomPaint(
            painter: _TreePainter(color: color, fullness: 0.6),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 3.seconds, color: Colors.white.withAlpha(30));
      
      case 4: // Mature
        return Container(
          width: size * 1.1,
          height: size * 1.3,
          child: CustomPaint(
            painter: _TreePainter(color: color, fullness: 0.85),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 2.seconds, color: Colors.white.withAlpha(50));
      
      case 5: // Mastered
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: size * 1.2,
              height: size * 1.4,
              child: CustomPaint(
                painter: _TreePainter(color: color, fullness: 1.0, hasGlow: true),
              ),
            ),
            Positioned(
              top: -10,
              child: Text('👑', style: TextStyle(fontSize: size * 0.35))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 500.ms),
            ),
          ],
        ).animate()
          .shimmer(duration: 1.5.seconds, color: Colors.amber.withAlpha(80));
      
      default:
        return Text(design.emoji, style: TextStyle(fontSize: size));
    }
  }

  Widget _buildTrunk(int stage) {
    final height = 10.0 + (stage * 5);
    final width = 4.0 + (stage * 1.5);
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF8B4513),
            const Color(0xFF5D3A1A),
          ],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Color _getColorFromHex(String hex) {
    final code = hex.replaceAll('#', '');
    return Color(int.parse('FF$code', radix: 16));
  }
}

// Custom painters for tree shapes
class _SeedPainter extends CustomPainter {
  final Color color;
  _SeedPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.8,
        height: size.height * 0.6,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SproutPainter extends CustomPainter {
  final Color color;
  _SproutPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.3, size.width / 2, size.height);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.3, size.width / 2, 0);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SaplingPainter extends CustomPainter {
  final Color color;
  _SaplingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width * 0.85, size.height * 0.5);
    path.quadraticBezierTo(size.width / 2, size.height * 0.7, size.width * 0.15, size.height * 0.5);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Second layer
    final paint2 = Paint()
      ..color = color.withAlpha(200)
      ..style = PaintingStyle.fill;
    
    final path2 = Path();
    path2.moveTo(size.width / 2, size.height * 0.15);
    path2.lineTo(size.width * 0.75, size.height * 0.6);
    path2.quadraticBezierTo(size.width / 2, size.height * 0.75, size.width * 0.25, size.height * 0.6);
    path2.close();
    
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TreePainter extends CustomPainter {
  final Color color;
  final double fullness;
  final bool hasGlow;
  
  _TreePainter({required this.color, this.fullness = 0.5, this.hasGlow = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (hasGlow) {
      final glowPaint = Paint()
        ..color = color.withAlpha(40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.4 * fullness, glowPaint);
    }
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Multiple layers for full tree
    for (int i = 0; i < 3; i++) {
      final layerOffset = i * size.height * 0.15;
      final layerWidth = size.width * (0.9 - i * 0.1) * fullness;
      final layerHeight = size.height * (0.4 + i * 0.1) * fullness;
      
      final path = Path();
      path.moveTo(size.width / 2, layerOffset);
      path.quadraticBezierTo(
        size.width / 2 + layerWidth / 2,
        layerOffset + layerHeight * 0.5,
        size.width / 2,
        layerOffset + layerHeight,
      );
      path.quadraticBezierTo(
        size.width / 2 - layerWidth / 2,
        layerOffset + layerHeight * 0.5,
        size.width / 2,
        layerOffset,
      );
      
      final layerPaint = Paint()
        ..color = color.withAlpha(255 - i * 30)
        ..style = PaintingStyle.fill;
      
      canvas.drawPath(path, layerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
