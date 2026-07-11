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
    final colors = context.colors;
    final design = TreeDesigns.getById(widget.area.treeDesignId);
    final color = CategoryPalette.snap(context, _hexToColor(design.colorHex));

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size * 1.3,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.area.isActiveFocus)
              Container(
                width: widget.size * 0.8,
                height: widget.size * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [color.withAlpha(30), Colors.transparent],
                  ),
                ),
              ),

            AnimatedBuilder(
              animation: _swayAnimation,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..rotateZ(
                      _swayAnimation.value *
                          (widget.area.isActiveFocus ? 1 : 0),
                    ),
                  child: child,
                );
              },
              child: _buildTree(context, design, color),
            ),

            if (widget.showDetails)
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
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

  Widget _buildTree(BuildContext context, TreeDesign design, Color color) {
    final colors = context.colors;
    final stage = widget.area.growthStage;
    final health = widget.area.effectiveHealthPercent;

    final Color? healthTint = health >= 75
        ? null
        : health >= 50
        ? Color.lerp(Colors.white, colors.warning, 0.25)
        : health >= 25
        ? Color.lerp(Colors.white, colors.danger, 0.3)
        : Color.lerp(Colors.white, colors.textMuted, 0.45);

    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _growthController,
        curve: Curves.elasticOut,
      ),
      child: _buildCanopy(context, stage, healthTint, design),
    );
  }

  Widget _buildCanopy(
    BuildContext context,
    int stage,
    Color? tint,
    TreeDesign design,
  ) {
    final colors = context.colors;
    final baseSize = widget.size * 0.4;
    final growthFactor = 1.0 + (stage * 0.2);
    final size = baseSize * growthFactor;

    if (!widget.area.isActiveFocus) {
      return Icon(
        Icons.bedtime_rounded,
        size: size * 0.8,
        color: colors.textMuted,
      );
    }

    if (widget.area.healthStatus == 'dead') {
      return Opacity(
        opacity: 0.4,
        child: Image.asset(
          design.getAssetPath(stage),
          width: size,
          fit: BoxFit.contain,
          color: colors.textMuted,
          colorBlendMode: BlendMode.modulate,
          errorBuilder: (context, error, stackTrace) =>
              Text(design.emoji, style: TextStyle(fontSize: size)),
        ),
      );
    }

    final assetPath = design.getAssetPath(stage);

    Widget treeImage = Image.asset(
      assetPath,
      width: size,
      fit: BoxFit.contain,
      color: tint,
      colorBlendMode: tint != null ? BlendMode.modulate : null,
      errorBuilder: (context, error, stackTrace) =>
          Text(design.emoji, style: TextStyle(fontSize: size)),
    );

    if (stage <= 1) {
      return treeImage
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 1.seconds,
          );
    } else if (stage == 2) {
      return treeImage
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.02, 1.03),
            duration: 2.seconds,
          );
    } else if (stage >= 3 && stage < 5) {
      return treeImage
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 3.seconds, color: colors.onPrimary.withAlpha(30));
    } else {
      return Stack(
        alignment: Alignment.topCenter,
        children: [
          treeImage,
          Positioned(
            top: -10,
            child:
                Icon(
                      Icons.workspace_premium_rounded,
                      size: size * 0.35,
                      color: colors.accent,
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                      duration: 500.ms,
                    ),
          ),
        ],
      ).animate().shimmer(
        duration: 1500.ms,
        color: colors.accent.withAlpha(80),
      );
    }
  }

  Color _hexToColor(String hex) {
    if (hex.isEmpty) return CategoryPalette.light[0];
    try {
      final code = hex.replaceAll('#', '');
      return Color(int.parse('FF$code', radix: 16));
    } catch (e) {
      return CategoryPalette.light[0];
    }
  }
}
