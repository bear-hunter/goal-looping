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
    
    // Determine tint based on health
    // We use modulate to tint the image if it's unhealthy
    final Color healthTint = health >= 75
        ? Colors.white
        : health >= 50
            ? const Color(0xFFFFF9C4) // Yellow tint
            : health >= 25
                ? const Color(0xFFFFCCBC) // Orange tint
                : const Color(0xFFBDBDBD); // Grey tint
    
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _growthController,
        curve: Curves.elasticOut,
      ),
      child: _buildCanopy(stage, healthTint, design),
    );
  }

  Widget _buildCanopy(int stage, Color tint, TreeDesign design) {
    final baseSize = widget.size * 0.4;
    // Growth factor makes the tree larger as it levels up
    final growthFactor = 1.0 + (stage * 0.2);
    final size = baseSize * growthFactor;
    
    if (!widget.area.isActiveFocus) {
      // Dormant: show sleeping emoji
      return Text('💤', style: TextStyle(fontSize: size * 0.8));
    }
    
    if (widget.area.healthStatus == 'dead') {
      // Dead tree
      return Text('💀', style: TextStyle(fontSize: size * 0.8));
    }

    // Get the appropriate asset image
    final assetPath = design.getAssetPath(stage);
    
    // Animation effects based on stage
    Widget treeImage = Image.asset(
      assetPath,
      width: size,
      fit: BoxFit.contain,
      color: tint != Colors.white ? tint : null,
      colorBlendMode: tint != Colors.white ? BlendMode.modulate : null,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to emoji if image fails
        return Text(design.emoji, style: TextStyle(fontSize: size));
      },
    );

    // Apply animations based on growth stage
    if (stage <= 1) { // Sprout
      return treeImage.animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1.seconds);
    } else if (stage == 2) { // Sapling
      return treeImage.animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.03), duration: 2.seconds);
    } else if (stage >= 3 && stage < 5) { // Mature
      return treeImage.animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 3.seconds, color: Colors.white.withAlpha(30));
    } else { // Mastered or higher
         return Stack(
          alignment: Alignment.topCenter,
          children: [
            treeImage,
            Positioned(
              top: -10,
              child: Text('👑', style: TextStyle(fontSize: size * 0.35))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 500.ms),
            ),
          ],
        ).animate()
          .shimmer(duration: 1.5.seconds, color: Colors.amber.withAlpha(80));
    }
  }

  // Helper to parse hex colors
  Color _getColorFromHex(String hex) {
    if (hex.isEmpty) return Colors.green;
    try {
      final code = hex.replaceAll('#', '');
      return Color(int.parse('FF$code', radix: 16));
    } catch (e) {
      return Colors.green;
    }
  }
}

