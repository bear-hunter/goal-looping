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
    return _buildFull();
  }

  Widget _buildCompact(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceLight = isDark ? AppColors.surfaceLight : LightColors.surfaceLight;
    final glassBorder = isDark ? AppColors.glassBorder : LightColors.glassBorder;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Text('${stats.level}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: stats.levelProgress,
                backgroundColor: surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${stats.coins}', style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600)),
          const SizedBox(width: 2),
          Text('🪙', style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildFull() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Level badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withAlpha(100), width: 2),
                ),
                child: Center(
                  child: Text('${stats.level}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Level ${stats.level}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: stats.levelProgress,
                              backgroundColor: Colors.white.withAlpha(50),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('${stats.totalXP}/${stats.xpForNextLevel}', style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(200))),
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
              _StatItem(icon: '🪙', value: '${stats.coins}', label: 'Coins'),
              _StatItem(icon: '🔥', value: '${stats.currentStreak}', label: 'Streak'),
              _StatItem(icon: '🧊', value: '${stats.freezeTokens}', label: 'Freezes'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, duration: 400.ms);
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _StatItem({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(180))),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceLight = isDark ? AppColors.surfaceLight : LightColors.surfaceLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAtRisk 
            ? AppColors.danger.withAlpha(30) 
            : (isDark ? AppColors.warning.withAlpha(30) : AppColors.warning.withAlpha(20)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isAtRisk ? AppColors.danger : AppColors.warning),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text('$streak', style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isAtRisk ? AppColors.danger : AppColors.warning,
          )),
          if (isAtRisk) ...[
            const SizedBox(width: 4),
            Icon(Icons.warning_rounded, size: 12, color: AppColors.danger),
          ],
        ],
      ),
    );
  }
}
