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
    final colors = context.colors;
    final stage = getLifeStage(
      factor.currentLevel,
      factor.effectiveHealthPercent,
      factor.effectiveHealthPercent <= 0,
    );

    final progressToNextLevel = (effortUnits % 10) / 10;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.surfaceVariant,
            colors.surface,
            Color.alphaBlend(colors.primary.withAlpha(8), colors.surface),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Level ',
                style: TextStyle(fontSize: 14, color: colors.textMuted),
              ),
              Text(
                '${factor.currentLevel}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              if (factor.currentLevel < factor.targetLevel) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: colors.textMuted,
                  ),
                ),
                Text(
                  '${factor.currentLevel + 1}',
                  style: TextStyle(fontSize: 18, color: colors.textMuted),
                ),
              ],
            ],
          ).animate().fadeIn(duration: AppMotion.expressive),

          const SizedBox(height: 8),

          Container(
            height: 10,
            width: 220,
            decoration: BoxDecoration(
              color: colors.surfaceVariant.withAlpha(180),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progressToNextLevel.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.primary, colors.success],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${effortUnits % 10}/10 effort to next stage',
            style: TextStyle(fontSize: 11, color: colors.textMuted),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 10,
                  child: Container(
                    width: 120,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          colors.textPrimary.withAlpha(40),
                          colors.textPrimary.withAlpha(15),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 15,
                  child:
                      SizedBox(
                            width: 150,
                            height: 150,
                            child: Image.asset(
                              _getTreeAssetPath(stage),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    factor.treeEmoji,
                                    style: const TextStyle(fontSize: 60),
                                  ),
                                );
                              },
                            ),
                          )
                          .animate()
                          .fadeIn(duration: AppMotion.celebration)
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            duration: 800.ms,
                            curve: Curves.elasticOut,
                          ),
                ),

                Positioned(
                  bottom: 25,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _stageColor(context, stage),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: [
                        BoxShadow(
                          color: _stageColor(context, stage).withAlpha(100),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _stageName(stage),
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface.withAlpha(200),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.glassBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _EffortStat(
                  icon: Icons.bolt_rounded,
                  value: '$effortUnits',
                  label: 'Effort',
                  color: colors.warning,
                ),
                Container(width: 1, height: 30, color: colors.glassBorder),
                _EffortStat(
                  icon: Icons.task_alt_rounded,
                  value: '$tasksCompleted',
                  label: 'Tasks',
                  color: colors.info,
                ),
                Container(width: 1, height: 30, color: colors.glassBorder),
                _EffortStat(
                  icon: Icons.repeat_rounded,
                  value: '$habitsLogged',
                  label: 'Habits',
                  color: colors.success,
                ),
                Container(width: 1, height: 30, color: colors.glassBorder),
                _EffortStat(
                  icon: Icons.psychology_rounded,
                  value: '$reflections',
                  label: 'Reflect',
                  color: colors.primary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.surface.withAlpha(150),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              _quote(stage),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _stageName(TreeLifeStage stage) {
    switch (stage) {
      case TreeLifeStage.seed:
        return 'Seed';
      case TreeLifeStage.sprout:
        return 'Sprout';
      case TreeLifeStage.seedling:
        return 'Seedling';
      case TreeLifeStage.sapling:
        return 'Sapling';
      case TreeLifeStage.mature:
        return 'Mature';
      case TreeLifeStage.decline:
        return 'Declining';
      case TreeLifeStage.snag:
        return 'Snag';
    }
  }

  Color _stageColor(BuildContext context, TreeLifeStage stage) {
    final colors = context.colors;
    switch (stage) {
      case TreeLifeStage.seed:
        return ForestTokens.soil(context);
      case TreeLifeStage.sprout:
        return Color.lerp(colors.primary, colors.success, 0.4)!;
      case TreeLifeStage.seedling:
        return Color.lerp(colors.primary, colors.success, 0.25)!;
      case TreeLifeStage.sapling:
        return colors.primary;
      case TreeLifeStage.mature:
        return ForestTokens.canopy(context);
      case TreeLifeStage.decline:
        return colors.warning;
      case TreeLifeStage.snag:
        return ForestTokens.bark(context);
    }
  }

  String _quote(TreeLifeStage stage) {
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

  String _getTreeAssetPath(TreeLifeStage stage) {
    final design = TreeDesigns.getById(factor.treeDesignId);

    int assetStage;
    switch (stage) {
      case TreeLifeStage.seed:
      case TreeLifeStage.sprout:
        assetStage = 0;
        break;
      case TreeLifeStage.seedling:
      case TreeLifeStage.sapling:
        assetStage = 2;
        break;
      case TreeLifeStage.mature:
      case TreeLifeStage.decline:
      case TreeLifeStage.snag:
        assetStage = 5;
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

  const _EffortStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 9, color: colors.textMuted)),
      ],
    );
  }
}
