import 'dart:math';
import 'package:hive/hive.dart';
import 'reflection_reminder.dart';

part 'user_stats.g.dart';

/// User statistics for gamification system
@HiveType(typeId: 20)
class UserStats extends HiveObject {
  @HiveField(0)
  int totalXP;

  @HiveField(1)
  int coins;

  @HiveField(2)
  int currentStreak;

  @HiveField(3)
  int longestStreak;

  @HiveField(4)
  DateTime? lastActiveDate;

  @HiveField(5)
  int freezeTokens; // Skip days without breaking streak

  @HiveField(6)
  List<String> unlockedBadgeIds;

  @HiveField(7)
  DateTime createdAt;

  // Phase 6: Anti-cheat tracking
  @HiveField(8)
  int xpEarnedToday;

  @HiveField(9)
  int coinsEarnedToday;

  @HiveField(10)
  int actionsToday;

  @HiveField(11)
  DateTime? lastResetDate;

  // Reflection reminder system
  @HiveField(12)
  DateTime? lastReflectionAt;

  @HiveField(13)
  ReflectionReminderFrequency reminderFrequency;

  UserStats({
    this.totalXP = 0,
    this.coins = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.freezeTokens = 0,
    List<String>? unlockedBadgeIds,
    DateTime? createdAt,
    this.xpEarnedToday = 0,
    this.coinsEarnedToday = 0,
    this.actionsToday = 0,
    this.lastResetDate,
    this.lastReflectionAt,
    this.reminderFrequency = ReflectionReminderFrequency.daily,
  })  : unlockedBadgeIds = unlockedBadgeIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// Current level based on XP (sqrt progression)
  int get level => (sqrt(totalXP / 100)).floor() + 1;

  /// XP required for next level
  int get xpForNextLevel => (pow(level, 2) * 100).toInt();

  /// XP required for current level
  int get xpForCurrentLevel => (pow(level - 1, 2) * 100).toInt();

  /// Progress percentage to next level (0.0 - 1.0)
  double get levelProgress {
    final xpInLevel = totalXP - xpForCurrentLevel;
    final xpNeeded = xpForNextLevel - xpForCurrentLevel;
    return xpInLevel / xpNeeded;
  }

  /// Check and reset daily counters if new day
  void _checkDailyReset() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (lastResetDate == null || 
        DateTime(lastResetDate!.year, lastResetDate!.month, lastResetDate!.day) != today) {
      xpEarnedToday = 0;
      coinsEarnedToday = 0;
      actionsToday = 0;
      lastResetDate = now;
    }
  }

  /// Calculate diminishing returns multiplier based on actions today
  double get _diminishingMultiplier {
    // First 10 actions: 100%
    // 10-20 actions: 50%
    // 20+ actions: 20%
    if (actionsToday < 10) return 1.0;
    if (actionsToday < 20) return 0.5;
    if (actionsToday < 30) return 0.2;
    return 0.1; // Nearly capped at 30+ actions
  }

  /// Add XP and coins with diminishing returns, update streak
  void earnReward({required int xp, required int coinReward}) {
    _checkDailyReset();
    
    // Apply diminishing returns
    final adjustedXP = (xp * _diminishingMultiplier).round();
    final adjustedCoins = (coinReward * _diminishingMultiplier).round();
    
    totalXP += adjustedXP;
    coins += adjustedCoins;
    xpEarnedToday += adjustedXP;
    coinsEarnedToday += adjustedCoins;
    actionsToday++;
    
    _updateStreak();
    save();
  }

  /// Spend coins (returns false if not enough)
  bool spendCoins(int amount) {
    if (coins >= amount) {
      coins -= amount;
      save();
      return true;
    }
    return false;
  }

  /// Buy a freeze token
  bool buyFreezeToken() {
    if (coins >= 30 && freezeTokens < 3) {
      coins -= 30;
      freezeTokens++;
      save();
      return true;
    }
    return false;
  }

  /// Use a freeze token (returns false if none available)
  bool useFreezeToken() {
    if (freezeTokens > 0) {
      freezeTokens--;
      save();
      return true;
    }
    return false;
  }

  /// Update streak based on last active date
  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (lastActiveDate != null) {
      final lastActive = DateTime(lastActiveDate!.year, lastActiveDate!.month, lastActiveDate!.day);
      final daysDiff = today.difference(lastActive).inDays;
      
      if (daysDiff == 0) {
        // Same day, no change
        return;
      } else if (daysDiff == 1) {
        // Consecutive day, increment streak
        currentStreak++;
      } else if (daysDiff == 2 && freezeTokens > 0) {
        // Missed one day but have freeze
        useFreezeToken();
        currentStreak++;
      } else {
        // Streak broken
        currentStreak = 1;
      }
    } else {
      // First activity
      currentStreak = 1;
    }
    
    // Update longest streak
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
    
    lastActiveDate = now;
  }

  /// Check if streak is at risk (no activity today)
  bool get isStreakAtRisk {
    if (lastActiveDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActive = DateTime(lastActiveDate!.year, lastActiveDate!.month, lastActiveDate!.day);
    return today.difference(lastActive).inDays >= 1;
  }

  /// Unlock an achievement badge
  void unlockBadge(String badgeId) {
    if (!unlockedBadgeIds.contains(badgeId)) {
      unlockedBadgeIds.add(badgeId);
      save();
    }
  }

  // === REFLECTION REMINDER METHODS ===

  /// Record that a reflection was completed
  void recordReflection() {
    lastReflectionAt = DateTime.now();
    save();
  }

  /// Check if reflection is overdue based on reminder frequency
  bool get isReflectionOverdue {
    if (reminderFrequency == ReflectionReminderFrequency.disabled) return false;
    if (lastReflectionAt == null) return true;

    final hoursSinceLastReflection =
        DateTime.now().difference(lastReflectionAt!).inHours;
    return hoursSinceLastReflection >= reminderFrequency.maxHoursBetweenReflections;
  }

  /// Check if a week has passed without reflection (critical warning)
  bool get isReflectionCriticallyOverdue {
    if (lastReflectionAt == null) return true;
    return DateTime.now().difference(lastReflectionAt!).inDays >= 7;
  }

  /// Hours since last reflection
  int get hoursSinceLastReflection {
    if (lastReflectionAt == null) return 999;
    return DateTime.now().difference(lastReflectionAt!).inHours;
  }

  /// Set reminder frequency
  void setReminderFrequency(ReflectionReminderFrequency frequency) {
    reminderFrequency = frequency;
    save();
  }
}

/// XP Reward definitions
class XPRewards {
  static const int completePriorityTask = 50;
  static const int completeBacklogTask = 20;
  static const int logHabitCompleted = 15;
  static const int logHabitFailed = 5; // Still tried to track
  static const int completeReflection = 100;
  static const int improveFactorLevel = 200;
  static const int dailyStreakBonus = 10; // Multiplied by streak days
  
  // Coin rewards
  static const int coinsPriorityTask = 10;
  static const int coinsBacklogTask = 5;
  static const int coinsHabitCompleted = 3;
  static const int coinsReflection = 25;
  static const int coinsFactorLevelUp = 50;
  static const int coinsStreakBonus = 5; // Multiplied by streak days
}
