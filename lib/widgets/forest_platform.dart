import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/theme.dart';
import '../models/growth_area.dart';

/// Isometric Forest Platform Widget
/// Displays trees growing on a 3D platform based on their level
class ForestPlatform extends StatelessWidget {
  final List<Factor> factors;
  final Function(Factor)? onTreeTap;
  final double platformWidth;
  final double platformHeight;

  const ForestPlatform({
    super.key,
    required this.factors,
    this.onTreeTap,
    this.platformWidth = 300,
    this.platformHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: platformWidth,
      height: platformHeight + 60, // Extra space for trees above platform
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Platform base
          Positioned(
            bottom: 0,
            child: _IsometricPlatform(
              width: platformWidth,
              height: platformHeight * 0.4,
            ),
          ),
          // Trees on platform
          ...factors.asMap().entries.map((entry) {
            final index = entry.key;
            final factor = entry.value;
            final position = _getTreePosition(index, factors.length);
            
            return Positioned(
              bottom: platformHeight * 0.35 + position.dy,
              left: platformWidth * 0.5 + position.dx - 25,
              child: GestureDetector(
                onTap: onTreeTap != null ? () => onTreeTap!(factor) : null,
                child: _GrowingTree(
                  factor: factor,
                  size: 50 + (factor.currentLevel * 3).toDouble(),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Offset _getTreePosition(int index, int total) {
    // Arrange trees in a natural-looking pattern on the platform
    if (total == 1) return Offset.zero;
    
    final patterns = [
      [Offset.zero], // 1 tree
      [const Offset(-40, 0), const Offset(40, 0)], // 2 trees
      [const Offset(-50, -10), Offset.zero, const Offset(50, -10)], // 3 trees
      [const Offset(-60, 0), const Offset(-20, -15), const Offset(20, -15), const Offset(60, 0)], // 4 trees
      [const Offset(-60, 5), const Offset(-30, -10), Offset.zero, const Offset(30, -10), const Offset(60, 5)], // 5 trees
    ];
    
    if (total <= patterns.length && index < patterns[total - 1].length) {
      return patterns[total - 1][index];
    }
    
    // For more than 5 trees, use a grid pattern
    final row = index ~/ 3;
    final col = index % 3;
    return Offset((col - 1) * 50.0, -row * 25.0);
  }
}

/// Isometric platform base with grass texture
class _IsometricPlatform extends StatelessWidget {
  final double width;
  final double height;

  const _IsometricPlatform({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _IsometricPlatformPainter(),
    );
  }
}

class _IsometricPlatformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Top grass layer
    final topPath = Path();
    topPath.moveTo(size.width * 0.5, 0);
    topPath.lineTo(size.width, size.height * 0.35);
    topPath.lineTo(size.width * 0.5, size.height * 0.7);
    topPath.lineTo(0, size.height * 0.35);
    topPath.close();
    
    final topGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF7CB342), // Light green
        const Color(0xFF558B2F), // Darker green
      ],
    );
    
    canvas.drawPath(
      topPath,
      Paint()
        ..shader = topGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.7))
        ..style = PaintingStyle.fill,
    );
    
    // Left dirt side
    final leftPath = Path();
    leftPath.moveTo(0, size.height * 0.35);
    leftPath.lineTo(size.width * 0.5, size.height * 0.7);
    leftPath.lineTo(size.width * 0.5, size.height);
    leftPath.lineTo(0, size.height * 0.65);
    leftPath.close();
    
    canvas.drawPath(
      leftPath,
      Paint()
        ..color = const Color(0xFF5D4037) // Brown dirt
        ..style = PaintingStyle.fill,
    );
    
    // Right dirt side (slightly lighter)
    final rightPath = Path();
    rightPath.moveTo(size.width, size.height * 0.35);
    rightPath.lineTo(size.width * 0.5, size.height * 0.7);
    rightPath.lineTo(size.width * 0.5, size.height);
    rightPath.lineTo(size.width, size.height * 0.65);
    rightPath.close();
    
    canvas.drawPath(
      rightPath,
      Paint()
        ..color = const Color(0xFF795548) // Lighter brown
        ..style = PaintingStyle.fill,
    );
    
    // Add grass texture dots on top
    final random = math.Random(42); // Fixed seed for consistency
    final grassPaint = Paint()
      ..color = const Color(0xFF8BC34A)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 20; i++) {
      final x = size.width * 0.2 + random.nextDouble() * size.width * 0.6;
      final y = size.height * 0.1 + random.nextDouble() * size.height * 0.5;
      canvas.drawCircle(Offset(x, y), 2 + random.nextDouble() * 2, grassPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Tree that grows based on factor level
class _GrowingTree extends StatelessWidget {
  final Factor factor;
  final double size;

  const _GrowingTree({required this.factor, required this.size});

  @override
  Widget build(BuildContext context) {
    final stage = _getGrowthStage(factor.currentLevel);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tree visualization
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _TreeStagePainter(
              stage: stage,
              healthPercent: factor.isActiveFocus ? factor.healthPercent : 100,
              isActive: factor.isActiveFocus,
            ),
          ),
        ).animate().fadeIn(duration: 400.ms).scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.elasticOut,
        ),
        const SizedBox(height: 4),
        // Tree name label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: factor.isActiveFocus 
                ? AppColors.primary.withAlpha(200)
                : AppColors.surface.withAlpha(200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            factor.name.length > 8 ? '${factor.name.substring(0, 8)}...' : factor.name,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: factor.isActiveFocus ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  int _getGrowthStage(int level) {
    if (level <= 2) return 0; // Seed
    if (level <= 4) return 1; // Sprout
    if (level <= 6) return 2; // Sapling
    if (level <= 8) return 3; // Young tree
    return 4; // Full tree
  }
}

class _TreeStagePainter extends CustomPainter {
  final int stage;
  final double healthPercent;
  final bool isActive;

  _TreeStagePainter({
    required this.stage,
    required this.healthPercent,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final bottom = size.height;
    
    // Determine tree color based on health
    Color trunkColor = const Color(0xFF5D4037);
    Color leafColor = isActive
        ? (healthPercent >= 50 ? const Color(0xFF2E7D32) : const Color(0xFFF9A825))
        : const Color(0xFF455A64);
    
    switch (stage) {
      case 0: // Seed
        _drawSeed(canvas, size, leafColor);
        break;
      case 1: // Sprout
        _drawSprout(canvas, size, trunkColor, leafColor);
        break;
      case 2: // Sapling
        _drawSapling(canvas, size, trunkColor, leafColor);
        break;
      case 3: // Young tree
        _drawYoungTree(canvas, size, trunkColor, leafColor);
        break;
      case 4: // Full tree
        _drawFullTree(canvas, size, trunkColor, leafColor);
        break;
    }
  }

  void _drawSeed(Canvas canvas, Size size, Color color) {
    final paint = Paint()
      ..color = const Color(0xFF795548)
      ..style = PaintingStyle.fill;
    
    // Draw seed shape
    final center = Offset(size.width / 2, size.height * 0.7);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width * 0.3, height: size.height * 0.2),
      paint,
    );
    
    // Small sprout coming out
    final sproutPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    path.moveTo(center.dx, center.dy - size.height * 0.1);
    path.quadraticBezierTo(
      center.dx + 5, center.dy - size.height * 0.2,
      center.dx, center.dy - size.height * 0.25,
    );
    canvas.drawPath(path, sproutPaint);
  }

  void _drawSprout(Canvas canvas, Size size, Color trunkColor, Color leafColor) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.85;
    
    // Stem
    final stemPaint = Paint()
      ..color = trunkColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(centerX, bottom),
      Offset(centerX, bottom - size.height * 0.35),
      stemPaint,
    );
    
    // Two leaves
    final leafPaint = Paint()
      ..color = leafColor
      ..style = PaintingStyle.fill;
    
    final leafPath = Path();
    leafPath.moveTo(centerX, bottom - size.height * 0.35);
    leafPath.quadraticBezierTo(
      centerX - size.width * 0.25, bottom - size.height * 0.5,
      centerX - size.width * 0.15, bottom - size.height * 0.6,
    );
    leafPath.quadraticBezierTo(
      centerX, bottom - size.height * 0.45,
      centerX, bottom - size.height * 0.35,
    );
    
    leafPath.moveTo(centerX, bottom - size.height * 0.35);
    leafPath.quadraticBezierTo(
      centerX + size.width * 0.25, bottom - size.height * 0.5,
      centerX + size.width * 0.15, bottom - size.height * 0.6,
    );
    leafPath.quadraticBezierTo(
      centerX, bottom - size.height * 0.45,
      centerX, bottom - size.height * 0.35,
    );
    
    canvas.drawPath(leafPath, leafPaint);
  }

  void _drawSapling(Canvas canvas, Size size, Color trunkColor, Color leafColor) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.9;
    
    // Trunk
    final trunkPaint = Paint()
      ..color = trunkColor
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(centerX, bottom),
      Offset(centerX, bottom - size.height * 0.45),
      trunkPaint,
    );
    
    // Small triangular foliage
    final leafPaint = Paint()
      ..color = leafColor
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(centerX, bottom - size.height * 0.8);
    path.lineTo(centerX - size.width * 0.25, bottom - size.height * 0.35);
    path.lineTo(centerX + size.width * 0.25, bottom - size.height * 0.35);
    path.close();
    
    canvas.drawPath(path, leafPaint);
  }

  void _drawYoungTree(Canvas canvas, Size size, Color trunkColor, Color leafColor) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.95;
    
    // Trunk
    final trunkPaint = Paint()
      ..color = trunkColor
      ..style = PaintingStyle.fill;
    
    final trunkPath = Path();
    trunkPath.moveTo(centerX - 4, bottom);
    trunkPath.lineTo(centerX - 3, bottom - size.height * 0.4);
    trunkPath.lineTo(centerX + 3, bottom - size.height * 0.4);
    trunkPath.lineTo(centerX + 4, bottom);
    trunkPath.close();
    canvas.drawPath(trunkPath, trunkPaint);
    
    // Two-tier foliage
    final leafPaint = Paint()
      ..color = leafColor
      ..style = PaintingStyle.fill;
    
    // Lower tier
    var path = Path();
    path.moveTo(centerX, bottom - size.height * 0.45);
    path.lineTo(centerX - size.width * 0.35, bottom - size.height * 0.3);
    path.lineTo(centerX + size.width * 0.35, bottom - size.height * 0.3);
    path.close();
    canvas.drawPath(path, leafPaint);
    
    // Upper tier
    path = Path();
    path.moveTo(centerX, bottom - size.height * 0.85);
    path.lineTo(centerX - size.width * 0.25, bottom - size.height * 0.45);
    path.lineTo(centerX + size.width * 0.25, bottom - size.height * 0.45);
    path.close();
    canvas.drawPath(path, leafPaint);
  }

  void _drawFullTree(Canvas canvas, Size size, Color trunkColor, Color leafColor) {
    final centerX = size.width / 2;
    final bottom = size.height;
    
    // Thick trunk
    final trunkPaint = Paint()
      ..color = trunkColor
      ..style = PaintingStyle.fill;
    
    final trunkPath = Path();
    trunkPath.moveTo(centerX - 6, bottom);
    trunkPath.lineTo(centerX - 4, bottom - size.height * 0.35);
    trunkPath.lineTo(centerX + 4, bottom - size.height * 0.35);
    trunkPath.lineTo(centerX + 6, bottom);
    trunkPath.close();
    canvas.drawPath(trunkPath, trunkPaint);
    
    // Three-tier foliage
    final leafPaint = Paint()
      ..color = leafColor
      ..style = PaintingStyle.fill;
    
    // Lower tier
    var path = Path();
    path.moveTo(centerX, bottom - size.height * 0.4);
    path.lineTo(centerX - size.width * 0.45, bottom - size.height * 0.25);
    path.lineTo(centerX + size.width * 0.45, bottom - size.height * 0.25);
    path.close();
    canvas.drawPath(path, leafPaint);
    
    // Middle tier
    path = Path();
    path.moveTo(centerX, bottom - size.height * 0.65);
    path.lineTo(centerX - size.width * 0.35, bottom - size.height * 0.4);
    path.lineTo(centerX + size.width * 0.35, bottom - size.height * 0.4);
    path.close();
    canvas.drawPath(path, leafPaint);
    
    // Top tier
    path = Path();
    path.moveTo(centerX, bottom - size.height * 0.9);
    path.lineTo(centerX - size.width * 0.2, bottom - size.height * 0.65);
    path.lineTo(centerX + size.width * 0.2, bottom - size.height * 0.65);
    path.close();
    canvas.drawPath(path, leafPaint);
  }

  @override
  bool shouldRepaint(covariant _TreeStagePainter oldDelegate) =>
      stage != oldDelegate.stage || 
      healthPercent != oldDelegate.healthPercent ||
      isActive != oldDelegate.isActive;
}

/// Single tree on a small platform (for detail screens)
class SingleTreePlatform extends StatelessWidget {
  final Factor factor;
  final double size;
  final VoidCallback? onTap;

  const SingleTreePlatform({
    super.key,
    required this.factor,
    this.size = 150,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size + 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Small platform
            Positioned(
              bottom: 0,
              child: CustomPaint(
                size: Size(size * 0.8, size * 0.3),
                painter: _IsometricPlatformPainter(),
              ),
            ),
            // Tree
            Positioned(
              bottom: size * 0.2,
              child: _GrowingTree(
                factor: factor,
                size: size * 0.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
