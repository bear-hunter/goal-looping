import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/theme.dart';
import '../models/growth_area.dart';
import 'forest_platform.dart';

/// Individual tree on a wooden platform
/// Used in Factor Detail screens - shows level progress and effort invested
class TreePlatform extends StatelessWidget {
  final Factor factor;
  final int effortUnits;
  final int tasksCompleted;
  final int habitsLogged;
  final int reflections;

  const TreePlatform({
    super.key,
    required this.factor,
    this.effortUnits = 0,
    this.tasksCompleted = 0,
    this.habitsLogged = 0,
    this.reflections = 0,
  });

  @override
  Widget build(BuildContext context) {
    final stage = getLifeStage(
      factor.currentLevel,
      factor.healthPercent,
      factor.healthPercent <= 0,
    );
    
    // Calculate progress to next level (each level needs ~10 effort units)
    final progressToNextLevel = (effortUnits % 10) / 10;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFE8F5E9),
            const Color(0xFFC8E6C9),
            const Color(0xFFA5D6A7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Level Progress Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Level ',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              Text(
                '${factor.currentLevel}',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              if (factor.currentLevel < factor.targetLevel) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.textMuted),
                ),
                Text(
                  '${factor.currentLevel + 1}',
                  style: TextStyle(fontSize: 18, color: AppColors.textMuted),
                ),
              ],
            ],
          ).animate().fadeIn(duration: 400.ms),
          
          const SizedBox(height: 8),
          
          // Progress bar to next level
          Container(
            height: 10,
            width: 220,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(180),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progressToNextLevel.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.success],
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Text(
            '${(progressToNextLevel * 100).toInt()}% to next level',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          
          const SizedBox(height: 20),
          
          // Tree on wooden platform
          SizedBox(
            height: 200,
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
                    height: 140,
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
                
                // Decorative elements
                Positioned(bottom: 42, left: 30, child: Text('🌿', style: TextStyle(fontSize: 14))),
                Positioned(bottom: 42, right: 35, child: Text('🌱', style: TextStyle(fontSize: 12))),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Effort Stats Row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _EffortStat(icon: Icons.bolt_rounded, value: '$effortUnits', label: 'Effort', color: AppColors.warning),
                Container(width: 1, height: 30, color: AppColors.glassBorder),
                _EffortStat(icon: Icons.task_alt_rounded, value: '$tasksCompleted', label: 'Tasks', color: AppColors.info),
                Container(width: 1, height: 30, color: AppColors.glassBorder),
                _EffortStat(icon: Icons.repeat_rounded, value: '$habitsLogged', label: 'Habits', color: AppColors.success),
                Container(width: 1, height: 30, color: AppColors.glassBorder),
                _EffortStat(icon: Icons.psychology_rounded, value: '$reflections', label: 'Reflect', color: AppColors.primary),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Inspirational quote
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(150),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _getQuote(stage),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
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
        return '"Growth is never by mere chance."';
      case TreeLifeStage.mature:
        return '"The strongest trees have the deepest roots."';
      case TreeLifeStage.decline:
        return '"Even in decline, we provide shelter to others."';
      case TreeLifeStage.snag:
        return '"In the end, we give back to the earth."';
    }
  }
}

class _EffortStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _EffortStat({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
      ],
    );
  }
}

/// Wooden deck platform (isometric style)
class _WoodenDeckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final topPath = Path();
    topPath.moveTo(size.width * 0.5, 0);
    topPath.lineTo(size.width, size.height * 0.4);
    topPath.lineTo(size.width * 0.5, size.height * 0.8);
    topPath.lineTo(0, size.height * 0.4);
    topPath.close();
    
    final plankPaint = Paint()..color = const Color(0xFFA1887F)..style = PaintingStyle.fill;
    canvas.drawPath(topPath, plankPaint);
    
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
    final trunkColor = const Color(0xFF5D4037);
    final leafColor = isActive
        ? (healthPercent >= 60 ? const Color(0xFF4CAF50) : 
           healthPercent >= 30 ? const Color(0xFFFFC107) : const Color(0xFFFF5722))
        : const Color(0xFF78909C);

    switch (stage) {
      case TreeLifeStage.seed:
        _drawSeed(canvas, size);
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
        _drawMature(canvas, size, trunkColor, leafColor);
        break;
      case TreeLifeStage.decline:
        _drawDecline(canvas, size, trunkColor, leafColor);
        break;
      case TreeLifeStage.snag:
        _drawSnag(canvas, size, trunkColor);
        break;
    }
  }

  void _drawSeed(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.8);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width * 0.2, height: size.height * 0.1),
      Paint()..color = const Color(0xFF8D6E63),
    );
    
    final sproutPath = Path();
    sproutPath.moveTo(center.dx, center.dy - size.height * 0.05);
    sproutPath.quadraticBezierTo(center.dx + 5, center.dy - size.height * 0.12, center.dx, center.dy - size.height * 0.15);
    canvas.drawPath(sproutPath, Paint()..color = const Color(0xFF81C784)..strokeWidth = 2..style = PaintingStyle.stroke);
  }

  void _drawSprout(Canvas canvas, Size size, Color trunk, Color leaf) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.85;
    
    canvas.drawLine(Offset(centerX, bottom), Offset(centerX, bottom - size.height * 0.25),
      Paint()..color = trunk..strokeWidth = 3..strokeCap = StrokeCap.round);
    
    canvas.drawCircle(Offset(centerX - 8, bottom - size.height * 0.28), 8, Paint()..color = leaf);
    canvas.drawCircle(Offset(centerX + 8, bottom - size.height * 0.28), 8, Paint()..color = leaf);
    canvas.drawCircle(Offset(centerX, bottom - size.height * 0.32), 10, Paint()..color = leaf);
  }

  void _drawSeedling(Canvas canvas, Size size, Color trunk, Color leaf) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.9;
    
    canvas.drawLine(Offset(centerX, bottom), Offset(centerX, bottom - size.height * 0.4),
      Paint()..color = trunk..strokeWidth = 4..strokeCap = StrokeCap.round);
    
    canvas.drawCircle(Offset(centerX, bottom - size.height * 0.45), 15, Paint()..color = leaf);
    canvas.drawCircle(Offset(centerX - 12, bottom - size.height * 0.38), 10, Paint()..color = leaf);
    canvas.drawCircle(Offset(centerX + 12, bottom - size.height * 0.40), 12, Paint()..color = leaf);
  }

  void _drawSapling(Canvas canvas, Size size, Color trunk, Color leaf) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.95;
    
    final trunkPath = Path();
    trunkPath.moveTo(centerX - 5, bottom);
    trunkPath.lineTo(centerX - 3, bottom - size.height * 0.4);
    trunkPath.lineTo(centerX + 3, bottom - size.height * 0.4);
    trunkPath.lineTo(centerX + 5, bottom);
    trunkPath.close();
    canvas.drawPath(trunkPath, Paint()..color = trunk);
    
    for (int i = 0; i < 3; i++) {
      final tierY = bottom - size.height * (0.4 + i * 0.12);
      final tierWidth = size.width * (0.35 - i * 0.07);
      final tierPath = Path();
      tierPath.moveTo(centerX, tierY - size.height * 0.1);
      tierPath.lineTo(centerX - tierWidth, tierY);
      tierPath.lineTo(centerX + tierWidth, tierY);
      tierPath.close();
      canvas.drawPath(tierPath, Paint()..color = i % 2 == 0 ? leaf : Color.lerp(leaf, Colors.black, 0.1)!);
    }
  }

  void _drawMature(Canvas canvas, Size size, Color trunk, Color leaf) {
    final centerX = size.width / 2;
    final bottom = size.height;
    
    final trunkPath = Path();
    trunkPath.moveTo(centerX - 8, bottom);
    trunkPath.lineTo(centerX - 5, bottom - size.height * 0.35);
    trunkPath.lineTo(centerX + 5, bottom - size.height * 0.35);
    trunkPath.lineTo(centerX + 8, bottom);
    trunkPath.close();
    canvas.drawPath(trunkPath, Paint()..color = trunk);
    
    canvas.drawOval(Rect.fromCenter(center: Offset(centerX, bottom - size.height * 0.55), width: size.width * 0.8, height: size.height * 0.35), Paint()..color = leaf);
    canvas.drawOval(Rect.fromCenter(center: Offset(centerX - 8, bottom - size.height * 0.65), width: size.width * 0.45, height: size.height * 0.22), Paint()..color = Color.lerp(leaf, Colors.black, 0.1)!);
    canvas.drawOval(Rect.fromCenter(center: Offset(centerX + 10, bottom - size.height * 0.7), width: size.width * 0.35, height: size.height * 0.18), Paint()..color = leaf);
  }

  void _drawDecline(Canvas canvas, Size size, Color trunk, Color leaf) {
    final centerX = size.width / 2;
    final bottom = size.height;
    
    final trunkPath = Path();
    trunkPath.moveTo(centerX - 6, bottom);
    trunkPath.quadraticBezierTo(centerX - 8, bottom - size.height * 0.2, centerX - 4, bottom - size.height * 0.4);
    trunkPath.lineTo(centerX + 4, bottom - size.height * 0.4);
    trunkPath.quadraticBezierTo(centerX + 6, bottom - size.height * 0.2, centerX + 6, bottom);
    trunkPath.close();
    canvas.drawPath(trunkPath, Paint()..color = trunk);
    
    canvas.drawLine(Offset(centerX, bottom - size.height * 0.4), Offset(centerX - 20, bottom - size.height * 0.55), Paint()..color = trunk..strokeWidth = 2);
    canvas.drawLine(Offset(centerX, bottom - size.height * 0.4), Offset(centerX + 15, bottom - size.height * 0.52), Paint()..color = trunk..strokeWidth = 2);
    
    final autumnColors = [const Color(0xFFFF8A65), const Color(0xFFFFCA28), leaf];
    for (int i = 0; i < 4; i++) {
      final x = centerX + (i - 2) * 12.0;
      final y = bottom - size.height * (0.48 + i * 0.04);
      canvas.drawCircle(Offset(x, y), 6, Paint()..color = autumnColors[i % 3]);
    }
  }

  void _drawSnag(Canvas canvas, Size size, Color trunk) {
    final centerX = size.width / 2;
    final bottom = size.height;
    
    final trunkPath = Path();
    trunkPath.moveTo(centerX - 6, bottom);
    trunkPath.lineTo(centerX - 4, bottom - size.height * 0.5);
    trunkPath.lineTo(centerX + 4, bottom - size.height * 0.5);
    trunkPath.lineTo(centerX + 6, bottom);
    trunkPath.close();
    canvas.drawPath(trunkPath, Paint()..color = const Color(0xFF6D4C41));
    
    final branchPaint = Paint()..color = const Color(0xFF5D4037)..strokeWidth = 2..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(centerX, bottom - size.height * 0.4), Offset(centerX - 18, bottom - size.height * 0.55), branchPaint);
    canvas.drawLine(Offset(centerX, bottom - size.height * 0.45), Offset(centerX + 15, bottom - size.height * 0.58), branchPaint);
    
    canvas.drawOval(Rect.fromCenter(center: Offset(centerX + 2, bottom - size.height * 0.3), width: 6, height: 10), Paint()..color = const Color(0xFF3E2723));
  }

  @override
  bool shouldRepaint(covariant _DetailedTreePainter old) =>
      stage != old.stage || isActive != old.isActive || healthPercent != old.healthPercent;
}
