import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/theme.dart';
import '../models/achievement.dart';

/// Achievement unlock notification overlay
class AchievementNotification extends StatelessWidget {
  final String achievementId;
  final VoidCallback onDismiss;

  const AchievementNotification({
    super.key,
    required this.achievementId,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final achievement = Achievements.getById(achievementId);
    if (achievement == null) return const SizedBox();

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface,
                AppColors.surfaceLight,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(80),
                blurRadius: 32,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy animation
              Text(
                achievement.iconEmoji,
                style: const TextStyle(fontSize: 64),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 500.ms)
                .shimmer(duration: 1.seconds, color: Colors.white.withAlpha(50)),
              
              const SizedBox(height: 16),
              
              // "Achievement Unlocked!" label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '🏆 ACHIEVEMENT UNLOCKED!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Achievement title
              Text(
                achievement.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Description
              Text(
                achievement.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Rewards
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RewardChip(icon: '⭐', value: '+${achievement.xpReward} XP'),
                  const SizedBox(width: 12),
                  _RewardChip(icon: '🪙', value: '+${achievement.coinReward}'),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Dismiss button
              ElevatedButton(
                onPressed: onDismiss,
                child: const Text('Awesome!'),
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 300.ms)
          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 300.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  final String icon;
  final String value;

  const _RewardChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

/// Badge card for gallery view
class AchievementBadgeCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AchievementBadgeCard({
    super.key,
    required this.achievement,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked ? AppColors.primary.withAlpha(15) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked ? AppColors.primary : AppColors.glassBorder,
            width: isUnlocked ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isUnlocked ? achievement.iconEmoji : '🔒',
              style: TextStyle(
                fontSize: 32,
                color: isUnlocked ? null : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isUnlocked ? AppColors.textPrimary : AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isUnlocked) ...[
              const SizedBox(height: 4),
              Text(
                '✓ Unlocked',
                style: TextStyle(fontSize: 10, color: AppColors.success),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
