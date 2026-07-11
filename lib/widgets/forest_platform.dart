import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/theme.dart';
import '../models/growth_area.dart';

/// Tree Life Cycle Stages (7 stages)
enum TreeLifeStage { seed, sprout, seedling, sapling, mature, decline, snag }

TreeLifeStage getLifeStage(int level, double healthPercent, bool isDead) {
  if (isDead || healthPercent <= 0) return TreeLifeStage.snag;
  if (level >= 10 && healthPercent < 50) return TreeLifeStage.decline;
  if (level >= 8) return TreeLifeStage.mature;
  if (level >= 6) return TreeLifeStage.sapling;
  if (level >= 4) return TreeLifeStage.seedling;
  if (level >= 2) return TreeLifeStage.sprout;
  return TreeLifeStage.seed;
}

class _ForestPaintTokens {
  final Color canopyLight;
  final Color canopyMid;
  final Color canopyDark;
  final Color gridLine;
  final Color soilLeft;
  final Color soilRight;
  final Color accentDot;
  final Color trunk;
  final Color trunkDark;
  final Color dormantLeaf;
  final Color autumnLeaf;

  const _ForestPaintTokens({
    required this.canopyLight,
    required this.canopyMid,
    required this.canopyDark,
    required this.gridLine,
    required this.soilLeft,
    required this.soilRight,
    required this.accentDot,
    required this.trunk,
    required this.trunkDark,
    required this.dormantLeaf,
    required this.autumnLeaf,
  });

  factory _ForestPaintTokens.of(BuildContext context) {
    final colors = context.colors;
    final canopy = ForestTokens.canopy(context);
    final understory = ForestTokens.understory(context);
    final soil = ForestTokens.soil(context);
    return _ForestPaintTokens(
      canopyLight: Color.lerp(canopy, colors.surface, 0.35)!,
      canopyMid: canopy,
      canopyDark: Color.lerp(canopy, Colors.black, 0.25)!,
      gridLine: canopy.withAlpha(60),
      soilLeft: soil,
      soilRight: Color.lerp(soil, Colors.white, 0.12)!,
      accentDot: understory,
      trunk: ForestTokens.bark(context),
      trunkDark: Color.lerp(ForestTokens.bark(context), Colors.black, 0.3)!,
      dormantLeaf: colors.textMuted,
      autumnLeaf: colors.accent,
    );
  }
}

/// Bird's-eye isometric forest platform with token-aware colors.
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
    final tokens = _ForestPaintTokens.of(context);

    return SizedBox(
      width: width,
      height: height + 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: RepaintBoundary(
              child: CustomPaint(
                size: Size(width, height * 0.6),
                painter: _IsometricGridPainter(tokens),
              ),
            ),
          ),
          ...(() {
            final positioned =
                factors
                    .asMap()
                    .entries
                    .map(
                      (entry) => _PositionedFactor(
                        factor: entry.value,
                        position: _getTreePosition(
                          entry.key,
                          factors.length,
                          width,
                        ),
                        size: _getTreeSize(entry.value.currentLevel),
                      ),
                    )
                    .toList()
                  ..sort((a, b) => a.position.dy.compareTo(b.position.dy));
            return positioned.map((item) {
              return Positioned(
                bottom: height * 0.35 + item.position.dy,
                left: width * 0.5 + item.position.dx - item.size / 2,
                child: GestureDetector(
                  onTap: onTreeTap != null
                      ? () => onTreeTap!(item.factor)
                      : null,
                  child: _IsometricTree(
                    factor: item.factor,
                    size: item.size,
                    tokens: tokens,
                  ),
                ),
              );
            });
          })(),
        ],
      ),
    ).animate().fadeIn(duration: AppMotion.expressive);
  }

  Offset _getTreePosition(int index, int total, double platformWidth) {
    if (total <= 1) return Offset.zero;

    final spread = math.min(platformWidth * 0.28, 110.0);
    if (total <= 4) {
      final startAngle = total == 2 ? math.pi * 0.15 : -math.pi * 0.05;
      final endAngle = total == 2 ? math.pi * 0.85 : math.pi * 1.05;
      final t = total == 1 ? 0.5 : index / (total - 1);
      final angle = startAngle + (endAngle - startAngle) * t;
      return Offset(math.cos(angle) * spread, math.sin(angle) * 34 - 8);
    }

    final positions = <Offset>[];
    const rows = 3;
    const cols = 4;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final x = ((c - (cols - 1) / 2) * 42 + (r - 1) * 26).toDouble();
        final y = ((r - 1) * 28 - (c - (cols - 1) / 2) * 8).toDouble();
        positions.add(Offset(x, y));
      }
    }
    if (index < positions.length) return positions[index];
    final angle = (index / total) * math.pi * 2;
    return Offset(math.cos(angle) * spread, math.sin(angle) * 40);
  }

  double _getTreeSize(int level) => 35 + (level * 4).toDouble();
}

class _PositionedFactor {
  final Factor factor;
  final Offset position;
  final double size;

  const _PositionedFactor({
    required this.factor,
    required this.position,
    required this.size,
  });
}

class _IsometricGridPainter extends CustomPainter {
  final _ForestPaintTokens t;
  _IsometricGridPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.1)
      ..lineTo(size.width * 0.95, size.height * 0.4)
      ..lineTo(size.width * 0.5, size.height * 0.7)
      ..lineTo(size.width * 0.05, size.height * 0.4)
      ..close();

    final grassGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [t.canopyLight, t.canopyMid, t.canopyDark],
    );

    canvas.drawPath(
      path,
      Paint()
        ..shader = grassGradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height * 0.7),
        )
        ..style = PaintingStyle.fill,
    );

    final gridPaint = Paint()
      ..color = t.gridLine
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < 5; i++) {
      final startX = size.width * 0.05 + (size.width * 0.45 / 5) * i;
      final startY = size.height * 0.4 - (size.height * 0.3 / 5) * i;
      final endX = size.width * 0.5 + (size.width * 0.45 / 5) * i;
      final endY = size.height * 0.7 - (size.height * 0.3 / 5) * i;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), gridPaint);
    }

    for (int i = 1; i < 5; i++) {
      final startX = size.width * 0.5 - (size.width * 0.45 / 5) * i;
      final startY = size.height * 0.1 + (size.height * 0.3 / 5) * i;
      final endX = size.width * 0.5 + (size.width * 0.45 / 5) * (5 - i);
      final endY = size.height * 0.4 + (size.height * 0.3 / 5) * i;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), gridPaint);
    }

    final leftPath = Path()
      ..moveTo(size.width * 0.05, size.height * 0.4)
      ..lineTo(size.width * 0.5, size.height * 0.7)
      ..lineTo(size.width * 0.5, size.height)
      ..lineTo(size.width * 0.05, size.height * 0.7)
      ..close();
    canvas.drawPath(leftPath, Paint()..color = t.soilLeft);

    final rightPath = Path()
      ..moveTo(size.width * 0.95, size.height * 0.4)
      ..lineTo(size.width * 0.5, size.height * 0.7)
      ..lineTo(size.width * 0.5, size.height)
      ..lineTo(size.width * 0.95, size.height * 0.7)
      ..close();
    canvas.drawPath(rightPath, Paint()..color = t.soilRight);

    final random = math.Random(42);
    final dotPaint = Paint()..color = t.accentDot;
    for (int i = 0; i < 8; i++) {
      final x = size.width * 0.18 + random.nextDouble() * size.width * 0.64;
      final y = size.height * 0.2 + random.nextDouble() * size.height * 0.42;
      canvas.drawCircle(
        Offset(x, y),
        1.2 + random.nextDouble() * 1.4,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IsometricTree extends StatelessWidget {
  final Factor factor;
  final double size;
  final _ForestPaintTokens tokens;

  const _IsometricTree({
    required this.factor,
    required this.size,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final stage = getLifeStage(
      factor.currentLevel,
      factor.effectiveHealthPercent,
      factor.effectiveHealthPercent <= 0,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
          child: RepaintBoundary(
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _TreeLifeCyclePainter(
                  stage: stage,
                  isActive: factor.isActiveFocus,
                  healthPercent: factor.effectiveHealthPercent,
                  tokens: tokens,
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: (factor.isActiveFocus ? colors.primary : colors.surface)
                .withAlpha(220),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            factor.name.length > 6
                ? '${factor.name.substring(0, 6)}..'
                : factor.name,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: factor.isActiveFocus ? colors.onPrimary : colors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _TreeLifeCyclePainter extends CustomPainter {
  final TreeLifeStage stage;
  final bool isActive;
  final double healthPercent;
  final _ForestPaintTokens tokens;

  _TreeLifeCyclePainter({
    required this.stage,
    required this.isActive,
    required this.healthPercent,
    required this.tokens,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trunkColor = tokens.trunk;
    final leafColor = isActive
        ? (healthPercent >= 60
              ? tokens.canopyMid
              : healthPercent >= 30
              ? tokens.autumnLeaf
              : tokens.autumnLeaf.withAlpha(180))
        : tokens.dormantLeaf;

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
      ..color = tokens.trunkDark
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.75),
        width: size.width * 0.25,
        height: size.height * 0.15,
      ),
      paint,
    );

    final sproutPaint = Paint()
      ..color = tokens.canopyMid
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

    canvas.drawLine(
      Offset(centerX, bottom),
      Offset(centerX, bottom - size.height * 0.3),
      Paint()
        ..color = trunk
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    final leafPaint = Paint()
      ..color = leaf
      ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(centerX, bottom - size.height * 0.3);
    path.quadraticBezierTo(
      centerX - size.width * 0.2,
      bottom - size.height * 0.4,
      centerX - size.width * 0.1,
      bottom - size.height * 0.45,
    );
    path.quadraticBezierTo(
      centerX - size.width * 0.05,
      bottom - size.height * 0.35,
      centerX,
      bottom - size.height * 0.3,
    );
    canvas.drawPath(path, leafPaint);

    path = Path();
    path.moveTo(centerX, bottom - size.height * 0.3);
    path.quadraticBezierTo(
      centerX + size.width * 0.2,
      bottom - size.height * 0.4,
      centerX + size.width * 0.1,
      bottom - size.height * 0.45,
    );
    path.quadraticBezierTo(
      centerX + size.width * 0.05,
      bottom - size.height * 0.35,
      centerX,
      bottom - size.height * 0.3,
    );
    canvas.drawPath(path, leafPaint);
  }

  void _drawSeedling(Canvas canvas, Size size, Color trunk, Color leaf) {
    final centerX = size.width / 2;
    final bottom = size.height * 0.9;

    canvas.drawLine(
      Offset(centerX, bottom),
      Offset(centerX, bottom - size.height * 0.45),
      Paint()
        ..color = trunk
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

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

    final trunkPaint = Paint()..color = trunk;
    final trunkPath = Path()
      ..moveTo(centerX - 4, bottom)
      ..lineTo(centerX - 2, bottom - size.height * 0.4)
      ..lineTo(centerX + 2, bottom - size.height * 0.4)
      ..lineTo(centerX + 4, bottom)
      ..close();
    canvas.drawPath(trunkPath, trunkPaint);

    final leafPaint = Paint()..color = leaf;
    var path = Path()
      ..moveTo(centerX, bottom - size.height * 0.45)
      ..lineTo(centerX - size.width * 0.3, bottom - size.height * 0.35)
      ..lineTo(centerX + size.width * 0.3, bottom - size.height * 0.35)
      ..close();
    canvas.drawPath(path, leafPaint);

    path = Path()
      ..moveTo(centerX, bottom - size.height * 0.75)
      ..lineTo(centerX - size.width * 0.22, bottom - size.height * 0.45)
      ..lineTo(centerX + size.width * 0.22, bottom - size.height * 0.45)
      ..close();
    canvas.drawPath(path, leafPaint);
  }

  void _drawMatureTree(Canvas canvas, Size size, Color trunk, Color leaf) {
    final centerX = size.width / 2;
    final bottom = size.height;

    final trunkPaint = Paint()..color = trunk;
    final trunkPath = Path()
      ..moveTo(centerX - 6, bottom)
      ..lineTo(centerX - 4, bottom - size.height * 0.35)
      ..lineTo(centerX + 4, bottom - size.height * 0.35)
      ..lineTo(centerX + 6, bottom)
      ..close();
    canvas.drawPath(trunkPath, trunkPaint);

    final leafPaint = Paint()..color = leaf;
    final darkerLeaf = Paint()..color = Color.lerp(leaf, Colors.black, 0.15)!;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, bottom - size.height * 0.42),
        width: size.width * 0.7,
        height: size.height * 0.25,
      ),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, bottom - size.height * 0.58),
        width: size.width * 0.55,
        height: size.height * 0.22,
      ),
      darkerLeaf,
    );
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

    final trunkPaint = Paint()..color = trunk;
    final trunkPath = Path()
      ..moveTo(centerX - 5, bottom)
      ..lineTo(centerX - 3, bottom - size.height * 0.35)
      ..lineTo(centerX + 3, bottom - size.height * 0.35)
      ..lineTo(centerX + 5, bottom)
      ..close();
    canvas.drawPath(trunkPath, trunkPaint);

    final autumnLeaf = tokens.autumnLeaf;
    canvas.drawCircle(
      Offset(centerX - 8, bottom - size.height * 0.5),
      size.width * 0.12,
      Paint()..color = autumnLeaf,
    );
    canvas.drawCircle(
      Offset(centerX + 10, bottom - size.height * 0.45),
      size.width * 0.1,
      Paint()..color = leaf,
    );
    canvas.drawCircle(
      Offset(centerX, bottom - size.height * 0.6),
      size.width * 0.15,
      Paint()..color = autumnLeaf.withAlpha(200),
    );

    canvas.drawLine(
      Offset(centerX, bottom - size.height * 0.35),
      Offset(centerX + 12, bottom - size.height * 0.55),
      Paint()
        ..color = trunk
        ..strokeWidth = 2,
    );
  }

  void _drawSnag(Canvas canvas, Size size, Color trunk) {
    final centerX = size.width / 2;
    final bottom = size.height;

    final trunkPaint = Paint()..color = tokens.trunkDark;
    final trunkPath = Path()
      ..moveTo(centerX - 5, bottom)
      ..lineTo(centerX - 3, bottom - size.height * 0.5)
      ..lineTo(centerX + 3, bottom - size.height * 0.5)
      ..lineTo(centerX + 5, bottom)
      ..close();
    canvas.drawPath(trunkPath, trunkPaint);

    final branchPaint = Paint()
      ..color = tokens.trunk
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
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
      stage != old.stage ||
      isActive != old.isActive ||
      healthPercent != old.healthPercent;
}

/// Single tree on platform (factor detail).
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
    final colors = context.colors;
    final tokens = _ForestPaintTokens.of(context);
    final stage = getLifeStage(
      factor.currentLevel,
      factor.effectiveHealthPercent,
      factor.effectiveHealthPercent <= 0,
    );

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size * 1.2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 0,
              child: RepaintBoundary(
                child: CustomPaint(
                  size: Size(size * 0.7, size * 0.25),
                  painter: _WoodenPlatformPainter(tokens),
                ),
              ),
            ),
            Positioned(
              bottom: size * 0.2,
              child: RepaintBoundary(
                child: SizedBox(
                  width: size * 0.6,
                  height: size * 0.7,
                  child: CustomPaint(
                    painter: _TreeLifeCyclePainter(
                      stage: stage,
                      isActive: factor.isActiveFocus,
                      healthPercent: factor.effectiveHealthPercent,
                      tokens: tokens,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: size * 0.05,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  'Lv ${factor.currentLevel}',
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WoodenPlatformPainter extends CustomPainter {
  final _ForestPaintTokens t;
  _WoodenPlatformPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final plankColor = t.soilRight;
    final plankDark = t.trunkDark;
    final plankLight = Color.lerp(plankColor, Colors.white, 0.18)!;

    final plankHeight = size.height / 5;
    for (int i = 0; i < 5; i++) {
      final y = i * plankHeight;
      final color = i % 2 == 0 ? plankColor : plankDark;
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, plankHeight - 1),
        Paint()..color = color,
      );
      canvas.drawLine(
        Offset(2, y + 1),
        Offset(size.width - 2, y + 1),
        Paint()
          ..color = plankLight
          ..strokeWidth = 0.5,
      );
    }

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
