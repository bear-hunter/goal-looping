import 'dart:convert';
import 'dart:io';

import 'package:centile/models/achievement.dart';
import 'package:centile/models/backup_models.dart';
import 'package:centile/models/focus_log.dart';
import 'package:centile/models/reflection_reminder.dart';
import 'package:centile/models/time_availability.dart';
import 'package:centile/models/user_stats.dart';
import 'package:centile/services/backup_service.dart';
import 'package:centile/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory hiveDirectory;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp(
      'centile-backup-test-',
    );
    Hive.init(hiveDirectory.path);
    Hive.registerAdapter(ReflectionReminderFrequencyAdapter());
    Hive.registerAdapter(UserStatsAdapter());
    Hive.registerAdapter(AchievementAdapter());
    Hive.registerAdapter(DurationAdapter());
    Hive.registerAdapter(FocusLogAdapter());
    await Future.wait([
      Hive.openBox<UserStats>(StorageService.userStatsBox),
      Hive.openBox<Achievement>(StorageService.achievementsBox),
      Hive.openBox<FocusLog>(StorageService.focusLogsBox),
      Hive.openBox(StorageService.settingsBox),
    ]);
  });

  setUp(() async {
    await Future.wait([
      Hive.box<UserStats>(StorageService.userStatsBox).clear(),
      Hive.box<Achievement>(StorageService.achievementsBox).clear(),
      Hive.box<FocusLog>(StorageService.focusLogsBox).clear(),
      Hive.box(StorageService.settingsBox).clear(),
    ]);
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  test(
    'replace removes stale achievements, focus logs, and settings',
    () async {
      await StorageService.saveAchievement(_achievement(title: 'Stale'));
      await StorageService.saveFocusLog(
        FocusLog(
          id: 'focus',
          taskId: 'task',
          taskTitle: 'Task',
          startTime: DateTime(2026, 7, 11),
          duration: const Duration(minutes: 10),
        ),
      );
      await StorageService.setTimeAvailability(TimeAvailability.free);

      final result = await BackupService.importData(
        _backupJson(),
        ImportMode.replace,
      );

      expect(result.success, isTrue);
      expect(StorageService.getAllAchievements(), isEmpty);
      expect(StorageService.getAllFocusLogs(), isEmpty);
      expect(StorageService.getTimeAvailability(), isNull);
    },
  );

  test(
    'merge preserves records and user stats with matching identities',
    () async {
      await StorageService.saveAchievement(_achievement(title: 'Local'));
      await StorageService.saveUserStats(UserStats(totalXP: 42));

      final result = await BackupService.importData(
        _backupJson(
          achievements: [_achievementJson(title: 'Imported')],
          userStats: {'totalXP': 999},
        ),
        ImportMode.merge,
      );

      expect(result.success, isTrue);
      expect(StorageService.getAchievement('achievement')?.title, 'Local');
      expect(StorageService.getUserStats().totalXP, 42);
      expect(result.skipped['achievements'], 1);
      expect(result.skipped['userStats'], 1);
    },
  );
}

Achievement _achievement({required String title}) => Achievement(
  id: 'achievement',
  title: title,
  description: 'Description',
  iconEmoji: '*',
  category: 'meta',
);

Map<String, dynamic> _achievementJson({required String title}) => {
  'id': 'achievement',
  'title': title,
  'description': 'Description',
  'iconEmoji': '*',
  'xpReward': 0,
  'coinReward': 0,
  'category': 'meta',
};

String _backupJson({
  List<Map<String, dynamic>> achievements = const [],
  Map<String, dynamic>? userStats,
}) => jsonEncode({
  'metadata': {
    'version': '1.1.0',
    'exportedAt': DateTime(2026, 7, 11).toIso8601String(),
    'appVersion': '1.0.0+1',
    'dataCounts': <String, int>{},
  },
  'data': {
    'achievements': achievements,
    if (userStats != null) 'userStats': userStats,
    'settings': <String, dynamic>{},
  },
});
