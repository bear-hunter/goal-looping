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
    final colors = context.colors;
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
              colors: [colors.surface, colors.surfaceLight],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withAlpha(80),
                blurRadius: 32,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                achievement.iconEmoji,
                style: const TextStyle(fontSize: 64),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 500.ms,
                  )
                  .shimmer(
                    duration: 1.seconds,
                    color: colors.onPrimary.withAlpha(50),
                  ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: colors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events_rounded,
                      size: 14,
                      color: colors.onPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ACHIEVEMENT UNLOCKED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors.onPrimary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                achievement.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                achievement.description,
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RewardChip(
                    icon: Icons.star_rounded,
                    tint: colors.warning,
                    value: '+${achievement.xpReward} XP',
                  ),
                  const SizedBox(width: 12),
                  _RewardChip(
                    icon: Icons.savings_rounded,
                    tint: colors.accent,
                    value: '+${achievement.coinReward}',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: onDismiss,
                child: const Text('Awesome!'),
              ),
            ],
          ),
        ).animate().fadeIn(duration: AppMotion.expressive).scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: AppMotion.expressive,
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String value;

  const _RewardChip({
    required this.icon,
    required this.tint,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: colors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tint),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
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
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked
              ? colors.primary.withAlpha(15)
              : colors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isUnlocked ? colors.primary : colors.glassBorder,
            width: isUnlocked ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isUnlocked
                ? Text(
                    achievement.iconEmoji,
                    style: const TextStyle(fontSize: 32),
                  )
                : Icon(
                    Icons.lock_rounded,
                    size: 32,
                    color: colors.textMuted,
                  ),
            const SizedBox(height: 8),
            Text(
              achievement.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isUnlocked
                    ? colors.textPrimary
                    : colors.textMuted,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isUnlocked) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 12,
                    color: colors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Unlocked',
                    style: TextStyle(fontSize: 10, color: colors.success),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
