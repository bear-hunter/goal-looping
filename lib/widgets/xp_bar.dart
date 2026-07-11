import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/theme.dart';
import '../models/user_stats.dart';

/// XP bar showing level progress
class XPBar extends StatelessWidget {
  final UserStats stats;
  final bool compact;

  const XPBar({super.key, required this.stats, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact(context);
    }
    return _buildFull(context);
  }

  Widget _buildCompact(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceLight.withAlpha(180),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: colors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colors.primary.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${stats.level}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 45,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: stats.levelProgress,
                backgroundColor: colors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${stats.coins}',
                style: TextStyle(
                  fontSize: 13,
                  color: colors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.monetization_on_rounded,
                size: 14,
                color: colors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    final colors = context.colors;
    final onPrimary = colors.onPrimary;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: colors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.primaryGlow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: onPrimary.withAlpha(30),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: onPrimary.withAlpha(100),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${stats.level}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${stats.level}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: onPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: stats.levelProgress,
                              backgroundColor: onPrimary.withAlpha(50),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                onPrimary,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${stats.totalXP}/${stats.xpForNextLevel}',
                          style: TextStyle(
                            fontSize: 12,
                            color: onPrimary.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.monetization_on_rounded,
                value: '${stats.coins}',
                label: 'Coins',
              ),
              _StatItem(
                icon: Icons.local_fire_department_rounded,
                value: '${stats.currentStreak}',
                label: 'Streak',
              ),
              _StatItem(
                icon: Icons.ac_unit_rounded,
                value: '${stats.freezeTokens}',
                label: 'Freezes',
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 320.ms).slideY(begin: -0.05, duration: 320.ms);
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final onPrimary = context.colors.onPrimary;
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: onPrimary),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: onPrimary,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: onPrimary.withAlpha(180)),
        ),
      ],
    );
  }
}

/// Streak indicator widget
class StreakBadge extends StatelessWidget {
  final int streak;
  final bool isAtRisk;

  const StreakBadge({super.key, required this.streak, this.isAtRisk = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = isAtRisk ? colors.danger : colors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tint.withAlpha(30),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: tint),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, size: 14, color: tint),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: tint,
            ),
          ),
          if (isAtRisk) ...[
            const SizedBox(width: 4),
            Icon(Icons.warning_rounded, size: 12, color: colors.danger),
          ],
        ],
      ),
    );
  }
}
