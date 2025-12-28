import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/theme.dart';
import '../models/growth_area.dart';
import '../models/tree_design.dart';
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
          
          // Tree with ground glow (no more wooden deck)
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ground glow/shadow effect
                Positioned(
                  bottom: 10,
                  child: Container(
                    width: 120,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.black.withAlpha(40),
                          Colors.black.withAlpha(15),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                
                // Tree image
                Positioned(
                  bottom: 15,
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.asset(
                      _getTreeAssetPath(stage),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to emoji
                        return Center(
                          child: Text(factor.treeEmoji, style: const TextStyle(fontSize: 60)),
                        );
                      },
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(
                    begin: const Offset(0.9, 0.9),
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  ),
                ),
                
                // Life stage label
                Positioned(
                  bottom: 25,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getStageColor(stage),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _getStageColor(stage).withAlpha(100),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _getStageName(stage),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
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

  /// Map TreeLifeStage to asset path using TreeDesigns
  String _getTreeAssetPath(TreeLifeStage stage) {
    // Get the tree design for this factor
    final design = TreeDesigns.getById(factor.treeDesignId);
    
    // Map life stage to asset stage (0-5 for sprout/sapling/mature)
    int assetStage;
    switch (stage) {
      case TreeLifeStage.seed:
      case TreeLifeStage.sprout:
        assetStage = 0; // sprout
        break;
      case TreeLifeStage.seedling:
      case TreeLifeStage.sapling:
        assetStage = 2; // sapling
        break;
      case TreeLifeStage.mature:
      case TreeLifeStage.decline:
      case TreeLifeStage.snag:
        assetStage = 5; // mature
        break;
    }
    
    return design.getAssetPath(assetStage);
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
