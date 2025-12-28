import 'package:hive/hive.dart';

part 'achievement.g.dart';

/// Achievement badge for gamification
@HiveType(typeId: 21)
class Achievement extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String iconEmoji;

  @HiveField(4)
  int xpReward;

  @HiveField(5)
  int coinReward;

  @HiveField(6)
  String category; // reflection, habits, tasks, strategy, meta

  @HiveField(7)
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    this.xpReward = 0,
    this.coinReward = 0,
    required this.category,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;
}

/// Predefined achievements
class Achievements {
  static final List<Achievement> all = [
    // Reflection achievements
    Achievement(id: 'first_reflection', title: 'First Cycle', description: 'Complete your first Kolb\'s reflection', iconEmoji: '🔄', xpReward: 50, coinReward: 20, category: 'reflection'),
    Achievement(id: 'reflection_10', title: 'Deep Thinker', description: 'Complete 10 reflections', iconEmoji: '🧠', xpReward: 200, coinReward: 100, category: 'reflection'),
    Achievement(id: 'experiments_100', title: 'Mad Scientist', description: 'Create 100 experiments', iconEmoji: '🔬', xpReward: 500, coinReward: 250, category: 'reflection'),
    
    // Habit achievements
    Achievement(id: 'streak_7', title: 'Week Warrior', description: '7-day streak', iconEmoji: '🔥', xpReward: 100, coinReward: 50, category: 'habits'),
    Achievement(id: 'streak_30', title: 'Monthly Master', description: '30-day streak', iconEmoji: '🏆', xpReward: 500, coinReward: 200, category: 'habits'),
    Achievement(id: 'streak_100', title: 'Century Champion', description: '100-day streak', iconEmoji: '👑', xpReward: 2000, coinReward: 1000, category: 'habits'),
    Achievement(id: 'barrier_buster', title: 'Barrier Buster', description: 'Log 10 barriers', iconEmoji: '🛡️', xpReward: 100, coinReward: 50, category: 'habits'),
    Achievement(id: 'perfect_week', title: 'Perfect Week', description: 'Complete all habits for 7 days', iconEmoji: '⭐', xpReward: 300, coinReward: 150, category: 'habits'),
    
    // Task achievements
    Achievement(id: 'first_top2', title: 'Priority Focus', description: 'Complete your first Top 2 task', iconEmoji: '🎯', xpReward: 50, coinReward: 20, category: 'tasks'),
    Achievement(id: 'tasks_50', title: 'Task Crusher', description: 'Complete 50 tasks', iconEmoji: '💪', xpReward: 250, coinReward: 100, category: 'tasks'),
    Achievement(id: 'zero_backlog', title: 'Inbox Zero', description: 'Clear the entire backlog', iconEmoji: '✨', xpReward: 150, coinReward: 75, category: 'tasks'),
    
    // Strategy achievements
    Achievement(id: 'first_goal', title: 'Goal Setter', description: 'Set your first goal', iconEmoji: '🚀', xpReward: 50, coinReward: 20, category: 'strategy'),
    Achievement(id: 'factor_master', title: 'Factor Master', description: 'Create 5 Factors', iconEmoji: '🎓', xpReward: 100, coinReward: 50, category: 'strategy'),
    Achievement(id: 'level_10', title: 'Mastery', description: 'Reach Level 10 on any Factor', iconEmoji: '🏅', xpReward: 1000, coinReward: 500, category: 'strategy'),
    
    // Meta achievements
    Achievement(id: 'xp_1000', title: 'Rising Star', description: 'Earn 1000 XP', iconEmoji: '⭐', xpReward: 100, coinReward: 50, category: 'meta'),
    Achievement(id: 'xp_10000', title: 'Superstar', description: 'Earn 10,000 XP', iconEmoji: '🌟', xpReward: 500, coinReward: 250, category: 'meta'),
    Achievement(id: 'resurrection', title: 'Phoenix', description: 'Resurrect a dead Factor', iconEmoji: '🔥', xpReward: 50, coinReward: 25, category: 'meta'),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
