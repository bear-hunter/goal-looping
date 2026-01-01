import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/achievement.dart';
import '../../providers/app_state.dart';
import '../../widgets/achievement_notification.dart';

/// Badge gallery screen showing all achievements
class BadgeGalleryScreen extends StatelessWidget {
  const BadgeGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Consumer<AppState>(
      builder: (context, state, _) {
        final unlockedIds = state.userStats.unlockedBadgeIds;
        final categories = ['reflection', 'habits', 'tasks', 'strategy', 'meta'];
        
        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                const Text('🏆 '),
                Text('Achievements', style: TextStyle(color: colors.textPrimary)),
              ],
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              // Stats header
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(value: '${unlockedIds.length}', label: 'Unlocked'),
                      _StatColumn(value: '${Achievements.all.length}', label: 'Total'),
                      _StatColumn(
                        value: '${((unlockedIds.length / Achievements.all.length) * 100).toInt()}%',
                        label: 'Complete',
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
              ),
              
              // Category sections
              ...categories.map((category) {
                final categoryBadges = Achievements.all.where((a) => a.category == category).toList();
                final categoryName = category[0].toUpperCase() + category.substring(1);
                
                return SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                        child: Row(
                          children: [
                            Icon(_getCategoryIcon(category), color: colors.textSecondary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              categoryName,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${categoryBadges.where((a) => unlockedIds.contains(a.id)).length}/${categoryBadges.length}',
                              style: TextStyle(fontSize: 12, color: colors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: categoryBadges.length,
                          itemBuilder: (context, index) {
                            final badge = categoryBadges[index];
                            final isUnlocked = unlockedIds.contains(badge.id);
                            return Container(
                              width: 120,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: AchievementBadgeCard(
                                achievement: badge,
                                isUnlocked: isUnlocked,
                                onTap: () => _showBadgeDetails(context, badge, isUnlocked),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'reflection': return Icons.psychology_rounded;
      case 'habits': return Icons.repeat_rounded;
      case 'tasks': return Icons.task_alt_rounded;
      case 'strategy': return Icons.flag_rounded;
      case 'meta': return Icons.stars_rounded;
      default: return Icons.emoji_events_rounded;
    }
  }

  void _showBadgeDetails(BuildContext context, Achievement badge, bool isUnlocked) {
    final colors = context.colors;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isUnlocked ? badge.iconEmoji : '🔒',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              badge.title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              style: TextStyle(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('⭐ ${badge.xpReward} XP', style: TextStyle(color: colors.textPrimary)),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('🪙 ${badge.coinReward}', style: TextStyle(color: colors.textPrimary)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isUnlocked)
              Text('✓ Unlocked', style: TextStyle(color: colors.success, fontWeight: FontWeight.w600))
            else
              Text('Not yet unlocked', style: TextStyle(color: colors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(200))),
      ],
    );
  }
}
