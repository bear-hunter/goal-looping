import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/theme.dart';
import '../models/growth_area.dart';

/// Tree Life Cycle Stages (7 stages)
enum TreeLifeStage {
  seed,      // Level 0-1: Dormant seed
  sprout,    // Level 2-3: First leaves emerging
  seedling,  // Level 4-5: Young flexible plant
  sapling,   // Level 6-7: Teenage tree, sturdier
  mature,    // Level 8-9: Full grown, peak health
  decline,   // Level 10 with low health: Aging
  snag,      // Dead: Bare trunk
}

TreeLifeStage getLifeStage(int level, double healthPercent, bool isDead) {
  if (isDead || healthPercent <= 0) return TreeLifeStage.snag;
  if (level >= 10 && healthPercent < 50) return TreeLifeStage.decline;
  if (level >= 8) return TreeLifeStage.mature;
  if (level >= 6) return TreeLifeStage.sapling;
  if (level >= 4) return TreeLifeStage.seedling;
  if (level >= 2) return TreeLifeStage.sprout;
  return TreeLifeStage.seed;
}

/// Bird's Eye Isometric Forest Platform
/// Large grid-based platform with trees positioned naturally
class ForestPlatform extends StatelessWidget {
  final List<Factor> factors;
  final Function(Factor)? onTreeTap;
  final double? platformWidth;
  final double? platformHeight;

  const ForestPlatform({
    super.key,
    required this.factors,
    this.onTreeTap,
    this.platformWidth,
    this.platformHeight,
  });

  @override
  Widget build(BuildContext context) {
    final width = platformWidth ?? 320;
    final height = platformHeight ?? (width * 0.7);
    
    return SizedBox(
      width: width,
      height: height + 80, // Extra space for trees
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Isometric platform base
          Positioned(
            bottom: 0,
            child: CustomPaint(
              size: Size(width, height * 0.6),
              painter: _IsometricGridPainter(),
            ),
          ),
          // Trees positioned on platform
          ...factors.asMap().entries.map((entry) {
            final index = entry.key;
            final factor = entry.value;
            final pos = _getTreePosition(index, factors.length, width);
            final treeSize = _getTreeSize(factor.currentLevel);
            
            return Positioned(
              bottom: height * 0.35 + pos.dy,
              left: width * 0.5 + pos.dx - treeSize / 2,
              child: GestureDetector(
                onTap: onTreeTap != null ? () => onTreeTap!(factor) : null,
                child: _IsometricTree(
                  factor: factor,
                  size: treeSize,
                ),
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Offset _getTreePosition(int index, int total, double platformWidth) {
    // Grid positions on isometric platform (back to front, left to right)
    final positions = <Offset>[];
    
    // Create natural grid positions
    const rows = 3;
    const cols = 4;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // Isometric transformation
        final x = ((c - cols/2) * 45 + (r - rows/2) * 45).toDouble();
        final y = (r * 30 - c * 10).toDouble();
        positions.add(Offset(x, y));
      }
    }
    
    if (index < positions.length) {
      return positions[index];
    }
    // Fallback for extra trees
    return Offset.zero;
  }

  double _getTreeSize(int level) {
    // Trees grow larger with level
    return 35 + (level * 4).toDouble();
  }
}

/// Isometric grid platform painter with grass and grid lines
class _IsometricGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    
    // Diamond-shaped isometric platform
    path.moveTo(size.width * 0.5, size.height * 0.1);  // Top
    path.lineTo(size.width * 0.95, size.height * 0.4); // Right
    path.lineTo(size.width * 0.5, size.height * 0.7);  // Bottom
    path.lineTo(size.width * 0.05, size.height * 0.4); // Left
    path.close();
    
    // Grass gradient
    final grassGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF8BC34A), // Light green
        const Color(0xFF689F38), // Medium green
        const Color(0xFF558B2F), // Dark green
      ],
    );
    
    canvas.drawPath(
      path,
      Paint()
        ..shader = grassGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.7))
        ..style = PaintingStyle.fill,
    );
    
    // Draw grid lines on grass
    final gridPaint = Paint()
      ..color = const Color(0xFF7CB342).withAlpha(100)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Horizontal-ish grid lines (isometric)
    for (int i = 1; i < 5; i++) {
      final startX = size.width * 0.05 + (size.width * 0.45 / 5) * i;
      final startY = size.height * 0.4 - (size.height * 0.3 / 5) * i;
      final endX = size.width * 0.5 + (size.width * 0.45 / 5) * i;
      final endY = size.height * 0.7 - (size.height * 0.3 / 5) * i;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), gridPaint);
    }
    
    // Vertical-ish grid lines (isometric)
    for (int i = 1; i < 5; i++) {
      final startX = size.width * 0.5 - (size.width * 0.45 / 5) * i;
      final startY = size.height * 0.1 + (size.height * 0.3 / 5) * i;
      final endX = size.width * 0.5 + (size.width * 0.45 / 5) * (5 - i);
      final endY = size.height * 0.4 + (size.height * 0.3 / 5) * i;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), gridPaint);
    }
    
    // Left side (dirt)
    final leftPath = Path();
    leftPath.moveTo(size.width * 0.05, size.height * 0.4);
    leftPath.lineTo(size.width * 0.5, size.height * 0.7);
    leftPath.lineTo(size.width * 0.5, size.height);
    leftPath.lineTo(size.width * 0.05, size.height * 0.7);
    leftPath.close();
    
    canvas.drawPath(
      leftPath,
      Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.fill,
    );
    
    // Right side (lighter dirt)
    final rightPath = Path();
    rightPath.moveTo(size.width * 0.95, size.height * 0.4);
    rightPath.lineTo(size.width * 0.5, size.height * 0.7);
    rightPath.lineTo(size.width * 0.5, size.height);
    rightPath.lineTo(size.width * 0.95, size.height * 0.7);
    rightPath.close();
    
    canvas.drawPath(
      rightPath,
      Paint()
        ..color = const Color(0xFF795548)
        ..style = PaintingStyle.fill,
    );
    
    // Grass texture (random dots)
    final random = math.Random(42);
    final grassDotPaint = Paint()
      ..color = const Color(0xFF9CCC65)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 30; i++) {
      final x = size.width * 0.15 + random.nextDouble() * size.width * 0.7;
      final y = size.height * 0.15 + random.nextDouble() * size.height * 0.5;
      canvas.drawCircle(Offset(x, y), 1.5 + random.nextDouble() * 2, grassDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Isometric tree with life cycle stages
class _IsometricTree extends StatelessWidget {
  final Factor factor;
  final double size;

  const _IsometricTree({required this.factor, required this.size});

  @override
  Widget build(BuildContext context) {
    final stage = getLifeStage(
      factor.currentLevel, 
      factor.healthPercent,
      factor.healthPercent <= 0,
    );
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Shadow
        Container(
          width: size * 0.6,
          height: size * 0.15,
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(30),
            borderRadius: BorderRadius.circular(size),
          ),
        ),
        Transform.translate(
          offset: Offset(0, -size * 0.1),
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _TreeLifeCyclePainter(
                stage: stage,
                isActive: factor.isActiveFocus,
                healthPercent: factor.healthPercent,
              ),
            ),
          ),
        ),
        // Name label
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: (factor.isActiveFocus ? AppColors.primary : AppColors.surface).withAlpha(220),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            factor.name.length > 6 ? '${factor.name.substring(0, 6)}..' : factor.name,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: factor.isActiveFocus ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

/// Painter for 7-stage tree life cycle
class _TreeLifeCyclePainter extends CustomPainter {
  final TreeLifeStage stage;
  final bool isActive;
  final double healthPercent;

  _TreeLifeCyclePainter({
    required this.stage,
    required this.isActive,
    required this.healthPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final bottom = size.height;
    
    // Colors based on health
    final trunkColor = const Color(0xFF5D4037);
    final leafColor = isActive
        ? (healthPercent >= 60 ? const Color(0xFF4CAF50) : 
           healthPercent >= 30 ? const Color(0xFFFFC107) : const Color(0xFFFF5722))
        : const Color(0xFF78909C);

    switch (stage) {
      case TreeLifeStage.seed:
        _drawSeed(canvas, size, trunkColor);
        break;
      case TreeLifeStage.sprout:
        _drawSprout(canvas, size, trunkColor, leafColor);
        break;
      case TreeLifeStage.seedling:
        _drawSeedling(canvas, size, trunkColor, leafColor);
        break;
      case TreeLifeStage.sapling:
        _drawSapling(canvas, size, trunkColor, leafColor);
        break;
      case TreeLifeStage.mature:
        _drawMatureTree(canvas, size, trunkColor, leafColor);
        break;
      case TreeLifeStage.decline:
        _drawDecliningTree(canvas, size, trunkColor, leafColor);
        break;
      case TreeLifeStage.snag:
        _drawSnag(canvas, size, trunkColor);
        break;
    }
  }

  void _drawSeed(Canvas canvas, Size size, Color color) {
    final paint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.75),
        width: size.width * 0.25,
        height: size.height * 0.15,
      ),
      paint,
    );
    
    // Tiny sprout hint
    final sproutPaint = Paint()
      ..color = const Color(0xFF81C784)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.68),
      Offset(size.width / 2, size.height * 0.62),
      sproutPaint,
    );
  }

  void _drawSprout(Canvas canvas, Size size, Color trunk, Color leaf) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.85;
    
    // Thin stem
    canvas.drawLine(
      Offset(centerX, bottom),
      Offset(centerX, bottom - size.height * 0.3),
      Paint()..color = trunk..strokeWidth = 2..strokeCap = StrokeCap.round,
    );
    
    // Two small leaves
    final leafPaint = Paint()..color = leaf..style = PaintingStyle.fill;
    
    // Left leaf
    var path = Path();
    path.moveTo(centerX, bottom - size.height * 0.3);
    path.quadraticBezierTo(
      centerX - size.width * 0.2, bottom - size.height * 0.4,
      centerX - size.width * 0.1, bottom - size.height * 0.45,
    );
    path.quadraticBezierTo(
      centerX - size.width * 0.05, bottom - size.height * 0.35,
      centerX, bottom - size.height * 0.3,
    );
    canvas.drawPath(path, leafPaint);
    
    // Right leaf
    path = Path();
    path.moveTo(centerX, bottom - size.height * 0.3);
    path.quadraticBezierTo(
      centerX + size.width * 0.2, bottom - size.height * 0.4,
      centerX + size.width * 0.1, bottom - size.height * 0.45,
    );
    path.quadraticBezierTo(
      centerX + size.width * 0.05, bottom - size.height * 0.35,
      centerX, bottom - size.height * 0.3,
    );
    canvas.drawPath(path, leafPaint);
  }

  void _drawSeedling(Canvas canvas, Size size, Color trunk, Color leaf) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.9;
    
    // Thin trunk
    canvas.drawLine(
      Offset(centerX, bottom),
      Offset(centerX, bottom - size.height * 0.45),
      Paint()..color = trunk..strokeWidth = 3..strokeCap = StrokeCap.round,
    );
    
    // Small oval canopy
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, bottom - size.height * 0.55),
        width: size.width * 0.35,
        height: size.height * 0.3,
      ),
      Paint()..color = leaf,
    );
  }

  void _drawSapling(Canvas canvas, Size size, Color trunk, Color leaf) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.95;
    
    // Trunk (thicker)
    final trunkPaint = Paint()..color = trunk..style = PaintingStyle.fill;
    final trunkPath = Path();
    trunkPath.moveTo(centerX - 4, bottom);
    trunkPath.lineTo(centerX - 2, bottom - size.height * 0.4);
    trunkPath.lineTo(centerX + 2, bottom - size.height * 0.4);
    trunkPath.lineTo(centerX + 4, bottom);
    trunkPath.close();
    canvas.drawPath(trunkPath, trunkPaint);
    
    // Triangle-ish foliage (2 tiers)
    final leafPaint = Paint()..color = leaf;
    
    // Lower tier
    var path = Path();
    path.moveTo(centerX, bottom - size.height * 0.45);
    path.lineTo(centerX - size.width * 0.3, bottom - size.height * 0.35);
    path.lineTo(centerX + size.width * 0.3, bottom - size.height * 0.35);
    path.close();
    canvas.drawPath(path, leafPaint);
    
    // Upper tier
    path = Path();
    path.moveTo(centerX, bottom - size.height * 0.75);
    path.lineTo(centerX - size.width * 0.22, bottom - size.height * 0.45);
    path.lineTo(centerX + size.width * 0.22, bottom - size.height * 0.45);
    path.close();
    canvas.drawPath(path, leafPaint);
  }

  void _drawMatureTree(Canvas canvas, Size size, Color trunk, Color leaf) {
    final centerX = size.width / 2;
    final bottom = size.height;
    
    // Thick trunk with base
    final trunkPaint = Paint()..color = trunk..style = PaintingStyle.fill;
    final trunkPath = Path();
    trunkPath.moveTo(centerX - 6, bottom);
    trunkPath.lineTo(centerX - 4, bottom - size.height * 0.35);
    trunkPath.lineTo(centerX + 4, bottom - size.height * 0.35);
    trunkPath.lineTo(centerX + 6, bottom);
    trunkPath.close();
    canvas.drawPath(trunkPath, trunkPaint);
    
    // Full 3-tier foliage
    final leafPaint = Paint()..color = leaf;
    final darkerLeaf = Paint()..color = Color.lerp(leaf, Colors.black, 0.15)!;
    
    // Lower tier
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, bottom - size.height * 0.42),
        width: size.width * 0.7,
        height: size.height * 0.25,
      ),
      leafPaint,
    );
    
    // Middle tier
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, bottom - size.height * 0.58),
        width: size.width * 0.55,
        height: size.height * 0.22,
      ),
      darkerLeaf,
    );
    
    // Top tier
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, bottom - size.height * 0.72),
        width: size.width * 0.35,
        height: size.height * 0.18,
      ),
      leafPaint,
    );
  }

  void _drawDecliningTree(Canvas canvas, Size size, Color trunk, Color leaf) {
    final centerX = size.width / 2;
    final bottom = size.height;
    
    // Trunk
    final trunkPaint = Paint()..color = trunk..style = PaintingStyle.fill;
    final trunkPath = Path();
    trunkPath.moveTo(centerX - 5, bottom);
    trunkPath.lineTo(centerX - 3, bottom - size.height * 0.35);
    trunkPath.lineTo(centerX + 3, bottom - size.height * 0.35);
    trunkPath.lineTo(centerX + 5, bottom);
    trunkPath.close();
    canvas.drawPath(trunkPath, trunkPaint);
    
    // Sparse foliage (autumn colors)
    final autumnLeaf = const Color(0xFFFF8A65);
    
    // Fewer, smaller clusters
    canvas.drawCircle(Offset(centerX - 8, bottom - size.height * 0.5), size.width * 0.12, Paint()..color = autumnLeaf);
    canvas.drawCircle(Offset(centerX + 10, bottom - size.height * 0.45), size.width * 0.1, Paint()..color = leaf);
    canvas.drawCircle(Offset(centerX, bottom - size.height * 0.6), size.width * 0.15, Paint()..color = autumnLeaf.withAlpha(200));
    
    // Bare branch
    canvas.drawLine(
      Offset(centerX, bottom - size.height * 0.35),
      Offset(centerX + 12, bottom - size.height * 0.55),
      Paint()..color = trunk..strokeWidth = 2,
    );
  }

  void _drawSnag(Canvas canvas, Size size, Color trunk) {
    final centerX = size.width / 2;
    final bottom = size.height;
    
    // Dead trunk
    final trunkPaint = Paint()..color = const Color(0xFF6D4C41)..style = PaintingStyle.fill;
    final trunkPath = Path();
    trunkPath.moveTo(centerX - 5, bottom);
    trunkPath.lineTo(centerX - 3, bottom - size.height * 0.5);
    trunkPath.lineTo(centerX + 3, bottom - size.height * 0.5);
    trunkPath.lineTo(centerX + 5, bottom);
    trunkPath.close();
    canvas.drawPath(trunkPath, trunkPaint);
    
    // Bare broken branches
    final branchPaint = Paint()..color = const Color(0xFF5D4037)..strokeWidth = 2..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX, bottom - size.height * 0.4),
      Offset(centerX - 10, bottom - size.height * 0.55),
      branchPaint,
    );
    canvas.drawLine(
      Offset(centerX, bottom - size.height * 0.45),
      Offset(centerX + 12, bottom - size.height * 0.6),
      branchPaint,
    );
    canvas.drawLine(
      Offset(centerX, bottom - size.height * 0.5),
      Offset(centerX - 5, bottom - size.height * 0.65),
      branchPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TreeLifeCyclePainter old) =>
      stage != old.stage || isActive != old.isActive || healthPercent != old.healthPercent;
}

/// Single tree on platform (for Factor Detail)
class SingleTreePlatform extends StatelessWidget {
  final Factor factor;
  final double size;
  final VoidCallback? onTap;

  const SingleTreePlatform({
    super.key,
    required this.factor,
    this.size = 200,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final stage = getLifeStage(
      factor.currentLevel,
      factor.healthPercent,
      factor.healthPercent <= 0,
    );
    
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size * 1.2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Wooden platform
            Positioned(
              bottom: 0,
              child: CustomPaint(
                size: Size(size * 0.7, size * 0.25),
                painter: _WoodenPlatformPainter(),
              ),
            ),
            // Tree
            Positioned(
              bottom: size * 0.2,
              child: SizedBox(
                width: size * 0.6,
                height: size * 0.7,
                child: CustomPaint(
                  painter: _TreeLifeCyclePainter(
                    stage: stage,
                    isActive: factor.isActiveFocus,
                    healthPercent: factor.healthPercent,
                  ),
                ),
              ),
            ),
            // Level badge
            Positioned(
              bottom: size * 0.05,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Lv ${factor.currentLevel}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wooden deck/platform painter
class _WoodenPlatformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final plankColor = const Color(0xFFA1887F);
    final plankDark = const Color(0xFF8D6E63);
    final plankLight = const Color(0xFFBCAAA4);
    
    // Draw planks
    final plankHeight = size.height / 5;
    for (int i = 0; i < 5; i++) {
      final y = i * plankHeight;
      final color = i % 2 == 0 ? plankColor : plankDark;
      
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, plankHeight - 1),
        Paint()..color = color,
      );
      
      // Plank highlight
      canvas.drawLine(
        Offset(2, y + 1),
        Offset(size.width - 2, y + 1),
        Paint()..color = plankLight..strokeWidth = 0.5,
      );
    }
    
    // Side edges
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 3, size.height),
      Paint()..color = plankDark,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width - 3, 0, 3, size.height),
      Paint()..color = plankDark,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
