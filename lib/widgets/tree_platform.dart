import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/theme.dart';
import '../models/growth_area.dart';
import 'forest_platform.dart';

/// Individual tree on a wooden platform
/// Used in Factor Detail screens - inspired by the reference image
class TreePlatform extends StatelessWidget {
  final Factor factor;
  final int dayNumber;
  final int totalDays;
  final VoidCallback? onWater;
  final VoidCallback? onPrune;

  const TreePlatform({
    super.key,
    required this.factor,
    this.dayNumber = 0,
    this.totalDays = 100,
    this.onWater,
    this.onPrune,
  });

  @override
  Widget build(BuildContext context) {
    final stage = getLifeStage(
      factor.currentLevel,
      factor.healthPercent,
      factor.healthPercent <= 0,
    );
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFE8F5E9), // Light green sky
            const Color(0xFFC8E6C9),
            const Color(0xFFA5D6A7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Day counter
          if (dayNumber > 0 || totalDays > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Day ',
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                ),
                Text(
                  '$dayNumber',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text(
                  '/$totalDays',
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),
          
          const SizedBox(height: 8),
          
          // Progress bar
          Container(
            height: 8,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(150),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: totalDays > 0 ? (dayNumber / totalDays).clamp(0, 1) : 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Tree on wooden platform
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Wooden deck platform
                Positioned(
                  bottom: 0,
                  child: CustomPaint(
                    size: const Size(180, 50),
                    painter: _WoodenDeckPainter(),
                  ),
                ),
                
                // Tree
                Positioned(
                  bottom: 45,
                  child: SizedBox(
                    width: 140,
                    height: 160,
                    child: CustomPaint(
                      painter: _DetailedTreePainter(
                        stage: stage,
                        isActive: factor.isActiveFocus,
                        healthPercent: factor.healthPercent,
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(
                    begin: const Offset(0.9, 0.9),
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  ),
                ),
                
                // Life stage label
                Positioned(
                  bottom: 55,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStageColor(stage),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStageName(stage),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                
                // Decorative grass
                Positioned(
                  bottom: 42,
                  left: 20,
                  child: Text('🌿', style: TextStyle(fontSize: 16)),
                ),
                Positioned(
                  bottom: 42,
                  right: 25,
                  child: Text('🌱', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons (optional)
          if (onWater != null || onPrune != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onWater != null)
                  _ActionButton(
                    label: 'Water',
                    icon: Icons.water_drop_rounded,
                    color: AppColors.info,
                    onTap: onWater!,
                  ),
                if (onWater != null && onPrune != null)
                  const SizedBox(width: 16),
                if (onPrune != null)
                  _ActionButton(
                    label: 'Prune',
                    icon: Icons.content_cut_rounded,
                    color: AppColors.warning,
                    onTap: onPrune!,
                  ),
              ],
            ),
          
          const SizedBox(height: 16),
          
          // Inspirational quote
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(180),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getQuote(stage),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStageName(TreeLifeStage stage) {
    switch (stage) {
      case TreeLifeStage.seed: return 'Seed';
      case TreeLifeStage.sprout: return 'Sprout';
      case TreeLifeStage.seedling: return 'Seedling';
      case TreeLifeStage.sapling: return 'Sapling';
      case TreeLifeStage.mature: return 'Mature';
      case TreeLifeStage.decline: return 'Declining';
      case TreeLifeStage.snag: return 'Snag';
    }
  }

  Color _getStageColor(TreeLifeStage stage) {
    switch (stage) {
      case TreeLifeStage.seed: return const Color(0xFF8D6E63);
      case TreeLifeStage.sprout: return const Color(0xFF81C784);
      case TreeLifeStage.seedling: return const Color(0xFF66BB6A);
      case TreeLifeStage.sapling: return const Color(0xFF4CAF50);
      case TreeLifeStage.mature: return const Color(0xFF2E7D32);
      case TreeLifeStage.decline: return const Color(0xFFFF8A65);
      case TreeLifeStage.snag: return const Color(0xFF6D4C41);
    }
  }

  String _getQuote(TreeLifeStage stage) {
    switch (stage) {
      case TreeLifeStage.seed:
        return '"Every mighty oak was once a nut that held its ground."';
      case TreeLifeStage.sprout:
        return '"The creation of a thousand forests is in one acorn."';
      case TreeLifeStage.seedling:
        return '"Patience is the companion of wisdom."';
      case TreeLifeStage.sapling:
        return '"Growth is never by mere chance; it is the result of forces working together."';
      case TreeLifeStage.mature:
        return '"The strongest trees have the deepest roots."';
      case TreeLifeStage.decline:
        return '"Even in decline, we provide shelter to others."';
      case TreeLifeStage.snag:
        return '"In the end, we give back to the earth that nurtured us."';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: color.withAlpha(100), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// Wooden deck platform (isometric style)
class _WoodenDeckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Deck top
    final topPath = Path();
    topPath.moveTo(size.width * 0.5, 0);
    topPath.lineTo(size.width, size.height * 0.4);
    topPath.lineTo(size.width * 0.5, size.height * 0.8);
    topPath.lineTo(0, size.height * 0.4);
    topPath.close();
    
    // Wood plank effect
    final plankPaint = Paint()..color = const Color(0xFFA1887F)..style = PaintingStyle.fill;
    canvas.drawPath(topPath, plankPaint);
    
    // Plank lines
    final linePaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    for (int i = 1; i < 5; i++) {
      final yOffset = size.height * 0.4 * (i / 5);
      canvas.drawLine(
        Offset(size.width * 0.1 + yOffset, size.height * 0.08 + yOffset),
        Offset(size.width * 0.9 - yOffset, size.height * 0.08 + yOffset),
        linePaint,
      );
    }
    
    // Left side
    final leftPath = Path();
    leftPath.moveTo(0, size.height * 0.4);
    leftPath.lineTo(size.width * 0.5, size.height * 0.8);
    leftPath.lineTo(size.width * 0.5, size.height);
    leftPath.lineTo(0, size.height * 0.6);
    leftPath.close();
    canvas.drawPath(leftPath, Paint()..color = const Color(0xFF8D6E63));
    
    // Right side
    final rightPath = Path();
    rightPath.moveTo(size.width, size.height * 0.4);
    rightPath.lineTo(size.width * 0.5, size.height * 0.8);
    rightPath.lineTo(size.width * 0.5, size.height);
    rightPath.lineTo(size.width, size.height * 0.6);
    rightPath.close();
    canvas.drawPath(rightPath, Paint()..color = const Color(0xFF795548));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Detailed tree painter for single tree view
class _DetailedTreePainter extends CustomPainter {
  final TreeLifeStage stage;
  final bool isActive;
  final double healthPercent;

  _DetailedTreePainter({
    required this.stage,
    required this.isActive,
    required this.healthPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final bottom = size.height;
    
    final trunkColor = const Color(0xFF5D4037);
    final leafColor = isActive
        ? (healthPercent >= 60 ? const Color(0xFF4CAF50) : 
           healthPercent >= 30 ? const Color(0xFFFFC107) : const Color(0xFFFF5722))
        : const Color(0xFF78909C);

    switch (stage) {
      case TreeLifeStage.seed:
        _drawDetailedSeed(canvas, size);
        break;
      case TreeLifeStage.sprout:
        _drawDetailedSprout(canvas, size, trunkColor, leafColor);
        break;
      case TreeLifeStage.seedling:
        _drawDetailedSeedling(canvas, size, trunkColor, leafColor);
        break;
      case TreeLifeStage.sapling:
        _drawDetailedSapling(canvas, size, trunkColor, leafColor);
        break;
      case TreeLifeStage.mature:
        _drawDetailedMature(canvas, size, trunkColor, leafColor);
        break;
      case TreeLifeStage.decline:
        _drawDetailedDecline(canvas, size, trunkColor, leafColor);
        break;
      case TreeLifeStage.snag:
        _drawDetailedSnag(canvas, size, trunkColor);
        break;
    }
  }

  void _drawDetailedSeed(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.8);
    
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width * 0.2, height: size.height * 0.1),
      Paint()..color = const Color(0xFF8D6E63),
    );
    
    // Tiny sprout
    final sproutPath = Path();
    sproutPath.moveTo(center.dx, center.dy - size.height * 0.05);
    sproutPath.quadraticBezierTo(
      center.dx + 5, center.dy - size.height * 0.12,
      center.dx, center.dy - size.height * 0.15,
    );
    canvas.drawPath(
      sproutPath,
      Paint()..color = const Color(0xFF81C784)..strokeWidth = 2..style = PaintingStyle.stroke,
    );
  }

  void _drawDetailedSprout(Canvas canvas, Size size, Color trunk, Color leaf) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.85;
    
    // Stem
    canvas.drawLine(
      Offset(centerX, bottom),
      Offset(centerX, bottom - size.height * 0.25),
      Paint()..color = trunk..strokeWidth = 3..strokeCap = StrokeCap.round,
    );
    
    // Leaves
    _drawLeaf(canvas, Offset(centerX, bottom - size.height * 0.25), -30, size.width * 0.15, leaf);
    _drawLeaf(canvas, Offset(centerX, bottom - size.height * 0.25), 30, size.width * 0.15, leaf);
    _drawLeaf(canvas, Offset(centerX, bottom - size.height * 0.2), 0, size.width * 0.12, leaf);
  }

  void _drawDetailedSeedling(Canvas canvas, Size size, Color trunk, Color leaf) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.9;
    
    // Thin trunk
    canvas.drawLine(
      Offset(centerX, bottom),
      Offset(centerX, bottom - size.height * 0.4),
      Paint()..color = trunk..strokeWidth = 4..strokeCap = StrokeCap.round,
    );
    
    // Small branches
    canvas.drawLine(
      Offset(centerX, bottom - size.height * 0.25),
      Offset(centerX - 15, bottom - size.height * 0.35),
      Paint()..color = trunk..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(centerX, bottom - size.height * 0.3),
      Offset(centerX + 12, bottom - size.height * 0.38),
      Paint()..color = trunk..strokeWidth = 2,
    );
    
    // Leaf clusters
    canvas.drawCircle(Offset(centerX, bottom - size.height * 0.45), 15, Paint()..color = leaf);
    canvas.drawCircle(Offset(centerX - 18, bottom - size.height * 0.38), 10, Paint()..color = leaf);
    canvas.drawCircle(Offset(centerX + 15, bottom - size.height * 0.4), 12, Paint()..color = leaf);
  }

  void _drawDetailedSapling(Canvas canvas, Size size, Color trunk, Color leaf) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.95;
    
    // Trunk
    final trunkPath = Path();
    trunkPath.moveTo(centerX - 6, bottom);
    trunkPath.lineTo(centerX - 4, bottom - size.height * 0.4);
    trunkPath.lineTo(centerX + 4, bottom - size.height * 0.4);
    trunkPath.lineTo(centerX + 6, bottom);
    trunkPath.close();
    canvas.drawPath(trunkPath, Paint()..color = trunk);
    
    // Multiple branch/leaf tiers
    for (int i = 0; i < 3; i++) {
      final tierY = bottom - size.height * (0.4 + i * 0.15);
      final tierWidth = size.width * (0.4 - i * 0.08);
      
      final tierPath = Path();
      tierPath.moveTo(centerX, tierY - size.height * 0.12);
      tierPath.lineTo(centerX - tierWidth, tierY);
      tierPath.lineTo(centerX + tierWidth, tierY);
      tierPath.close();
      canvas.drawPath(tierPath, Paint()..color = i % 2 == 0 ? leaf : Color.lerp(leaf, Colors.black, 0.1)!);
    }
  }

  void _drawDetailedMature(Canvas canvas, Size size, Color trunk, Color leaf) {
    final centerX = size.width / 2;
    final bottom = size.height;
    
    // Thick trunk with texture
    final trunkPath = Path();
    trunkPath.moveTo(centerX - 10, bottom);
    trunkPath.lineTo(centerX - 6, bottom - size.height * 0.35);
    trunkPath.lineTo(centerX + 6, bottom - size.height * 0.35);
    trunkPath.lineTo(centerX + 10, bottom);
    trunkPath.close();
    canvas.drawPath(trunkPath, Paint()..color = trunk);
    
    // Main branches
    canvas.drawLine(
      Offset(centerX, bottom - size.height * 0.35),
      Offset(centerX - 25, bottom - size.height * 0.5),
      Paint()..color = trunk..strokeWidth = 4,
    );
    canvas.drawLine(
      Offset(centerX, bottom - size.height * 0.35),
      Offset(centerX + 20, bottom - size.height * 0.55),
      Paint()..color = trunk..strokeWidth = 3,
    );
    
    // Full leafy canopy
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, bottom - size.height * 0.55), width: size.width * 0.85, height: size.height * 0.35),
      Paint()..color = leaf,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX - 10, bottom - size.height * 0.65), width: size.width * 0.5, height: size.height * 0.25),
      Paint()..color = Color.lerp(leaf, Colors.black, 0.15)!,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX + 15, bottom - size.height * 0.72), width: size.width * 0.4, height: size.height * 0.2),
      Paint()..color = leaf,
    );
  }

  void _drawDetailedDecline(Canvas canvas, Size size, Color trunk, Color leaf) {
    final centerX = size.width / 2;
    final bottom = size.height;
    
    // Gnarled trunk
    final trunkPath = Path();
    trunkPath.moveTo(centerX - 8, bottom);
    trunkPath.quadraticBezierTo(centerX - 10, bottom - size.height * 0.2, centerX - 5, bottom - size.height * 0.4);
    trunkPath.lineTo(centerX + 5, bottom - size.height * 0.4);
    trunkPath.quadraticBezierTo(centerX + 8, bottom - size.height * 0.2, centerX + 8, bottom);
    trunkPath.close();
    canvas.drawPath(trunkPath, Paint()..color = trunk);
    
    // Bare branches
    canvas.drawLine(
      Offset(centerX, bottom - size.height * 0.4),
      Offset(centerX - 30, bottom - size.height * 0.6),
      Paint()..color = trunk..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(centerX, bottom - size.height * 0.4),
      Offset(centerX + 25, bottom - size.height * 0.55),
      Paint()..color = trunk..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(centerX, bottom - size.height * 0.45),
      Offset(centerX - 10, bottom - size.height * 0.65),
      Paint()..color = trunk..strokeWidth = 2,
    );
    
    // Sparse autumn leaves
    final autumnColors = [const Color(0xFFFF8A65), const Color(0xFFFFCA28), leaf];
    for (int i = 0; i < 5; i++) {
      final x = centerX + (i - 2) * 15.0;
      final y = bottom - size.height * (0.5 + i * 0.05);
      canvas.drawCircle(Offset(x, y), 8, Paint()..color = autumnColors[i % 3]);
    }
  }

  void _drawDetailedSnag(Canvas canvas, Size size, Color trunk) {
    final centerX = size.width / 2;
    final bottom = size.height;
    
    // Dead trunk
    final trunkPath = Path();
    trunkPath.moveTo(centerX - 8, bottom);
    trunkPath.lineTo(centerX - 6, bottom - size.height * 0.55);
    trunkPath.lineTo(centerX + 6, bottom - size.height * 0.55);
    trunkPath.lineTo(centerX + 8, bottom);
    trunkPath.close();
    canvas.drawPath(trunkPath, Paint()..color = const Color(0xFF6D4C41));
    
    // Broken branches
    final branchPaint = Paint()..color = const Color(0xFF5D4037)..strokeWidth = 3..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX, bottom - size.height * 0.45),
      Offset(centerX - 25, bottom - size.height * 0.6),
      branchPaint,
    );
    canvas.drawLine(
      Offset(centerX, bottom - size.height * 0.5),
      Offset(centerX + 20, bottom - size.height * 0.65),
      branchPaint,
    );
    canvas.drawLine(
      Offset(centerX, bottom - size.height * 0.55),
      Offset(centerX - 8, bottom - size.height * 0.7),
      Paint()..color = const Color(0xFF5D4037)..strokeWidth = 2,
    );
    
    // Woodpecker hole
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX + 3, bottom - size.height * 0.35), width: 8, height: 12),
      Paint()..color = const Color(0xFF3E2723),
    );
  }

  void _drawLeaf(Canvas canvas, Offset base, double angle, double length, Color color) {
    final radians = angle * 3.14159 / 180;
    final endX = base.dx + length * -0.5;
    final endY = base.dy - length;
    
    final path = Path();
    path.moveTo(base.dx, base.dy);
    path.quadraticBezierTo(
      base.dx + length * 0.3 * (angle > 0 ? 1 : -1),
      base.dy - length * 0.5,
      endX + (angle > 0 ? -5 : 5),
      endY,
    );
    path.quadraticBezierTo(
      base.dx - length * 0.2 * (angle > 0 ? 1 : -1),
      base.dy - length * 0.3,
      base.dx,
      base.dy,
    );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _DetailedTreePainter old) =>
      stage != old.stage || isActive != old.isActive || healthPercent != old.healthPercent;
}
