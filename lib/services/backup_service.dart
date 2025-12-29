import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../models/backup_models.dart';
import '../models/goal.dart';
import '../models/growth_area.dart';
import '../models/sprint_target.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/habit.dart';
import '../models/reflection.dart';
import '../models/reflection_group.dart';
import '../models/reflection_reminder.dart';
import '../models/experiment.dart';
import '../models/time_availability.dart';
import '../models/user_stats.dart';
import '../models/achievement.dart';
import '../models/focus_log.dart';
import 'storage_service.dart';

/// Service for backing up and restoring all user data
class BackupService {
  static const String _backupVersion = '1.0.0';
  
  /// Get the app version from pubspec (hardcoded for now)
  static const String _appVersion = '1.0.0+1';

  /// Generate a backup filename with timestamp
  static String generateBackupFilename() {
    final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
    return 'centile_backup_$timestamp.json';
  }

  /// Export all user data to a JSON file
  static Future<File> exportAllData() async {
    try {
      // Generate JSON string
      final jsonString = await generateBackupJson();
      
      // Get downloads directory
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir == null) {
        throw BackupException('Could not access storage directory');
      }

      // Create file
      final filename = generateBackupFilename();
      final file = File('${downloadsDir.path}/$filename');
      
      // Write data
      await file.writeAsString(jsonString);
      
      return file;
    } catch (e) {
      throw BackupException('Failed to export data', e);
    }
  }

  /// Generate backup JSON string
  static Future<String> generateBackupJson() async {
    try {
      // Collect all data from Hive boxes
      final goals = StorageService.getAllGoals();
      final factors = StorageService.getAllFactors();
      final sprintTargets = StorageService.getAllSprintTargets();
      final tasks = StorageService.getAllTasks();
      final subtasks = <Subtask>[];
      final habits = StorageService.getAllHabits();
      final reflections = StorageService.getAllReflections();
      final reflectionGroups = StorageService.getAllReflectionGroups();
      final experiments = StorageService.getAllExperiments();
      final barriers = StorageService.getAllBarriers();
      final userStats = StorageService.getUserStats();
      final achievements = StorageService.getAllAchievements();
      final focusLogs = StorageService.getAllFocusLogs();

      // Collect all subtasks for all tasks
      for (final task in tasks) {
        subtasks.addAll(StorageService.getSubtasksForTask(task.id));
      }

      // Get settings data
      final timeAvailability = StorageService.getTimeAvailability();
      final onboardingComplete = StorageService.hasCompletedOnboarding;
      final taskCategories = StorageService.getTaskCategories();

      // Build metadata
      final metadata = BackupMetadata(
        version: _backupVersion,
        exportedAt: DateTime.now(),
        appVersion: _appVersion,
        dataCounts: {
          'goals': goals.length,
          'growthAreas': factors.length,
          'sprintTargets': sprintTargets.length,
          'tasks': tasks.length,
          'subtasks': subtasks.length,
          'habits': habits.length,
          'reflections': reflections.length,
          'reflectionGroups': reflectionGroups.length,
          'experiments': experiments.length,
          'barriers': barriers.length,
          'achievements': achievements.length,
          'focusLogs': focusLogs.length,
        },
      );

      // Build complete backup structure
      final backup = {
        'metadata': metadata.toJson(),
        'data': {
          'goals': goals.map((g) => _goalToJson(g)).toList(),
          'growthAreas': factors.map((f) => _growthAreaToJson(f)).toList(),
          'sprintTargets': sprintTargets.map((st) => _sprintTargetToJson(st)).toList(),
          'tasks': tasks.map((t) => _taskToJson(t)).toList(),
          'subtasks': subtasks.map((st) => _subtaskToJson(st)).toList(),
          'habits': habits.map((h) => _habitToJson(h)).toList(),
          'reflections': reflections.map((r) => _reflectionToJson(r)).toList(),
          'reflectionGroups': reflectionGroups.map((rg) => _reflectionGroupToJson(rg)).toList(),
          'experiments': experiments.map((e) => _experimentToJson(e)).toList(),
          'barriers': barriers.map((b) => _barrierToJson(b)).toList(),
          'userStats': _userStatsToJson(userStats),
          'achievements': achievements.map((a) => _achievementToJson(a)).toList(),
          'focusLogs': focusLogs.map((fl) => _focusLogToJson(fl)).toList(),
          'settings': {
            'timeAvailability': timeAvailability?.index,
            'onboardingComplete': onboardingComplete,
            'taskCategories': taskCategories,
          },
        },
      };

      // Convert to JSON string with pretty formatting
      return const JsonEncoder.withIndent('  ').convert(backup);
    } catch (e) {
      throw BackupException('Failed to generate backup JSON', e);
    }
  }

  /// Preview backup data before importing
  static Future<BackupPreview> previewBackup(String jsonString) async {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Parse metadata
      final metadata = BackupMetadata.fromJson(json['metadata'] as Map<String, dynamic>);
      
      // Validate structure
      final validationErrors = <String>[];
      if (!json.containsKey('data')) {
        validationErrors.add('Missing data section');
      }
      
      final data = json['data'] as Map<String, dynamic>?;
      if (data == null) {
        validationErrors.add('Invalid data structure');
      }

      // Count data items
      final dataCounts = <String, int>{};
      final conflicts = <String>[];
      
      if (data != null) {
        dataCounts['goals'] = (data['goals'] as List?)?.length ?? 0;
        dataCounts['growthAreas'] = (data['growthAreas'] as List?)?.length ?? 0;
        dataCounts['sprintTargets'] = (data['sprintTargets'] as List?)?.length ?? 0;
        dataCounts['tasks'] = (data['tasks'] as List?)?.length ?? 0;
        dataCounts['subtasks'] = (data['subtasks'] as List?)?.length ?? 0;
        dataCounts['habits'] = (data['habits'] as List?)?.length ?? 0;
        dataCounts['reflections'] = (data['reflections'] as List?)?.length ?? 0;
        dataCounts['reflectionGroups'] = (data['reflectionGroups'] as List?)?.length ?? 0;
        dataCounts['experiments'] = (data['experiments'] as List?)?.length ?? 0;
        dataCounts['barriers'] = (data['barriers'] as List?)?.length ?? 0;
        dataCounts['achievements'] = (data['achievements'] as List?)?.length ?? 0;
        dataCounts['focusLogs'] = (data['focusLogs'] as List?)?.length ?? 0;

        // Check for ID conflicts (optional - for informational purposes)
        final existingGoals = StorageService.getAllGoals();
        if (existingGoals.isNotEmpty && dataCounts['goals']! > 0) {
          conflicts.add('${existingGoals.length} existing goals will be affected');
        }
      }

      return BackupPreview(
        metadata: metadata,
        dataCounts: dataCounts,
        conflicts: conflicts,
        validationErrors: validationErrors,
      );
    } catch (e) {
      throw BackupException('Failed to preview backup', e);
    }
  }

  /// Import data from backup JSON
  static Future<ImportResult> importData(String jsonString, ImportMode mode) async {
    final imported = <String, int>{};
    final skipped = <String, int>{};
    final failed = <String, int>{};
    final errors = <String>[];

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      // If replace mode, clear all existing data first
      if (mode == ImportMode.replace) {
        await _clearAllData();
      }

      // Import each data type
      imported['goals'] = await _importGoals(data['goals'] as List, mode);
      imported['growthAreas'] = await _importGrowthAreas(data['growthAreas'] as List, mode);
      imported['sprintTargets'] = await _importSprintTargets(data['sprintTargets'] as List, mode);
      imported['tasks'] = await _importTasks(data['tasks'] as List, mode);
      imported['subtasks'] = await _importSubtasks(data['subtasks'] as List, mode);
      imported['habits'] = await _importHabits(data['habits'] as List, mode);
      imported['reflections'] = await _importReflections(data['reflections'] as List, mode);
      imported['reflectionGroups'] = await _importReflectionGroups(data['reflectionGroups'] as List, mode);
      imported['experiments'] = await _importExperiments(data['experiments'] as List, mode);
      imported['barriers'] = await _importBarriers(data['barriers'] as List, mode);
      imported['achievements'] = await _importAchievements(data['achievements'] as List, mode);
      imported['focusLogs'] = await _importFocusLogs(data['focusLogs'] as List, mode);

      // Import user stats
      if (data.containsKey('userStats')) {
        final stats = _userStatsFromJson(data['userStats'] as Map<String, dynamic>);
        await StorageService.saveUserStats(stats);
        imported['userStats'] = 1;
      }

      // Import settings
      if (data.containsKey('settings')) {
        await _importSettings(data['settings'] as Map<String, dynamic>);
        imported['settings'] = 1;
      }

      return ImportResult(
        success: true,
        imported: imported,
        skipped: skipped,
        failed: failed,
        errors: errors,
      );
    } catch (e) {
      errors.add('Import failed: $e');
      return ImportResult(
        success: false,
        imported: imported,
        skipped: skipped,
        failed: failed,
        errors: errors,
      );
    }
  }

  // ========== PRIVATE HELPER METHODS ==========

  /// Clear all data (for replace mode)
  static Future<void> _clearAllData() async {
    // Delete all items from all boxes
    final goals = StorageService.getAllGoals();
    for (final goal in goals) {
      await StorageService.deleteGoal(goal.id);
    }

    final factors = StorageService.getAllFactors();
    for (final factor in factors) {
      await StorageService.deleteFactor(factor.id);
    }

    final sprintTargets = StorageService.getAllSprintTargets();
    for (final target in sprintTargets) {
      await StorageService.deleteSprintTarget(target.id);
    }

    final tasks = StorageService.getAllTasks();
    for (final task in tasks) {
      await StorageService.deleteTask(task.id);
    }

    final habits = StorageService.getAllHabits();
    for (final habit in habits) {
      await StorageService.deleteHabit(habit.id);
    }

    final reflections = StorageService.getAllReflections();
    for (final reflection in reflections) {
      await StorageService.deleteReflection(reflection.id);
    }

    final reflectionGroups = StorageService.getAllReflectionGroups();
    for (final group in reflectionGroups) {
      await StorageService.deleteReflectionGroup(group.id);
    }

    final experiments = StorageService.getAllExperiments();
    for (final experiment in experiments) {
      await StorageService.deleteExperiment(experiment.id);
    }

    final barriers = StorageService.getAllBarriers();
    for (final barrier in barriers) {
      await StorageService.deleteBarrier(barrier.id);
    }

    // Reset user stats to default
    await StorageService.saveUserStats(UserStats());
  }

  // ========== CONVERSION METHODS (TO JSON) ==========

  static Map<String, dynamic> _goalToJson(Goal goal) => {
    'id': goal.id,
   'title': goal.title,
    'description': goal.description,
    'targetDate': goal.targetDate.toIso8601String(),
    'createdAt': goal.createdAt.toIso8601String(),
    'factorIds': goal.factorIds,
  };

  static Map<String, dynamic> _growthAreaToJson(GrowthArea area) => {
    'id': area.id,
    'name': area.name,
    'type': area.type.index,
    'targetLevel': area.targetLevel,
    'currentLevel': area.currentLevel,
    'description': area.description,
    'goalId': area.goalId,
    'lastUpdated': area.lastUpdated.toIso8601String(),
    'targetDescription': area.targetDescription,
    'currentDescription': area.currentDescription,
    'linkedHabitIds': area.linkedHabitIds,
    'isActiveFocus': area.isActiveFocus,
    'lastWorkedOn': area.lastWorkedOn?.toIso8601String(),
    'healthPercent': area.healthPercent,
    'treeDesignId': area.treeDesignId,
  };

  static Map<String, dynamic> _sprintTargetToJson(SprintTarget target) => {
    'id': target.id,
    'title': target.title,
    'description': target.description,
    'duration': target.duration.index,
    'isCompleted': target.isCompleted,
    'createdAt': target.createdAt.toIso8601String(),
    'targetDate': target.targetDate.toIso8601String(),
    'linkedFactorIds': target.linkedFactorIds,
  };

  static Map<String, dynamic> _taskToJson(Task task) => {
    'id': task.id,
    'title': task.title,
    'description': task.description,
    'isPriority': task.isPriority,
    'isCompleted': task.isCompleted,
    'source': task.source.index,
    'createdAt': task.createdAt.toIso8601String(),
    'completedAt': task.completedAt?.toIso8601String(),
    'linkedFactorIds': task.linkedFactorIds,
    'experimentId': task.experimentId,
    'sortOrder': task.sortOrder,
    'effort': task.effort.index,
    'impact': task.impact.index,
    'addedToPriorityAt': task.addedToPriorityAt?.toIso8601String(),
    'abandonReason': task.abandonReason?.index,
    'blockedByTaskId': task.blockedByTaskId,
    'category': task.category,
    'deadline': task.deadline?.toIso8601String(),
    'customTag': task.customTag,
  };

  static Map<String, dynamic> _subtaskToJson(Subtask subtask) => {
    'id': subtask.id,
    'title': subtask.title,
    'isCompleted': subtask.isCompleted,
    'parentTaskId': subtask.parentTaskId,
    'sortOrder': subtask.sortOrder,
  };

  static Map<String, dynamic> _habitToJson(Habit habit) => {
    'id': habit.id,
    'name': habit.name,
    'type': habit.type.index,
    'triggerResponse': habit.triggerResponse,
    'currentStreak': habit.currentStreak,
    'bestStreak': habit.bestStreak,
    'completionCount': habit.completionCount,
    'logs': habit.logs.map((log) => {
      'date': log.date.toIso8601String(),
      'completed': log.completed,
      'note': log.note,
      'moodRating': log.moodRating,
      'barrierTag': log.barrierTag,
    }).toList(),
    'createdAt': habit.createdAt.toIso8601String(),
    'isActive': habit.isActive,
    'factorId': habit.factorId,
    'scheduledDays': habit.scheduledDays,
    'targetFrequency': habit.targetFrequency,
    'motivation': habit.motivation,
    'timerMinutes': habit.timerMinutes,
    'streakFreezes': habit.streakFreezes,
    'freezesUsed': habit.freezesUsed,
  };

  static Map<String, dynamic> _reflectionToJson(Reflection reflection) => {
    'id': reflection.id,
    'experience': reflection.experience,
    'reflection': reflection.reflection,
    'abstraction': reflection.abstraction,
    'experimentIds': reflection.experimentIds,
    'linkedFactorIds': reflection.linkedFactorIds,
    'isFollowUp': reflection.isFollowUp,
    'previousReflectionId': reflection.previousReflectionId,
    'createdAt': reflection.createdAt.toIso8601String(),
    'rawMarkdown': reflection.rawMarkdown,
    'targetFactorId': reflection.targetFactorId,
    'previousExperimentId': reflection.previousExperimentId,
    'groupId': reflection.groupId,
    'marginalGainDescription': reflection.marginalGainDescription,
    'eventSequence': reflection.eventSequence,
    'feelings': reflection.feelings,
    'difficulties': reflection.difficulties,
    'challengeResponse': reflection.challengeResponse,
    'triggers': reflection.triggers,
    'whyBehavior': reflection.whyBehavior,
    'crossLifePatterns': reflection.crossLifePatterns,
    'isManualEntry': reflection.isManualEntry,
  };

  static Map<String, dynamic> _reflectionGroupToJson(ReflectionGroup group) => {
    'id': group.id,
    'title': group.title,
    'reflectionIds': group.reflectionIds,
    'createdAt': group.createdAt.toIso8601String(),
    'archivedAt': group.archivedAt?.toIso8601String(),
    'targetFactorId': group.targetFactorId,
  };

  static Map<String, dynamic> _experimentToJson(Experiment experiment) => {
    'id': experiment.id,
    'description': experiment.description,
    'status': experiment.status.index,
    'reflectionId': experiment.reflectionId,
    'createdAt': experiment.createdAt.toIso8601String(),
    'groupId': experiment.groupId,
    'cycleCount': experiment.cycleCount,
    'startedAt': experiment.startedAt?.toIso8601String(),
    'completedAt': experiment.completedAt?.toIso8601String(),
    'notes': experiment.notes,
  };

  static Map<String, dynamic> _barrierToJson(BarrierEntry barrier) => {
    'id': barrier.id,
    'description': barrier.description,
    'occurredAt': barrier.occurredAt.toIso8601String(),
    'response': barrier.response,
    'wasHandled': barrier.wasHandled,
    'factorId': barrier.factorId,
  };

  static Map<String, dynamic> _userStatsToJson(UserStats stats) => {
    'totalXP': stats.totalXP,
    'coins': stats.coins,
    'currentStreak': stats.currentStreak,
    'longestStreak': stats.longestStreak,
    'lastActiveDate': stats.lastActiveDate?.toIso8601String(),
    'freezeTokens': stats.freezeTokens,
    'unlockedBadgeIds': stats.unlockedBadgeIds,
    'createdAt': stats.createdAt.toIso8601String(),
    'xpEarnedToday': stats.xpEarnedToday,
    'coinsEarnedToday': stats.coinsEarnedToday,
    'actionsToday': stats.actionsToday,
    'lastResetDate': stats.lastResetDate?.toIso8601String(),
    'lastReflectionAt': stats.lastReflectionAt?.toIso8601String(),
    'reminderFrequency': stats.reminderFrequency.index,
  };

  static Map<String, dynamic> _focusLogToJson(FocusLog log) => {
    'id': log.id,
    'taskId': log.taskId,
    'taskTitle': log.taskTitle,
    'startTime': log.startTime.toIso8601String(),
    'duration': log.duration.inMinutes,
    'completedPomodoros': log.completedPomodoros,
    'distractions': log.distractions,
  };

  static Map<String, dynamic> _achievementToJson(Achievement achievement) => {
    'id': achievement.id,
    'title': achievement.title,
    'description': achievement.description,
    'iconEmoji': achievement.iconEmoji,
    'xpReward': achievement.xpReward,
    'coinReward': achievement.coinReward,
    'category': achievement.category,
    'unlockedAt': achievement.unlockedAt?.toIso8601String(),
  };

  static Future<int> _importGoals(List data, ImportMode mode) async {
    int count = 0;
    for (final item in data) {
      try {
        final goal = Goal(
          id: item['id'] as String,
          title: item['title'] as String? ?? item['description'] as String, // Fallback to description for old backups
          targetDate: item['targetDate'] != null 
              ? DateTime.parse(item['targetDate'] as String)
              : DateTime.parse(item['createdAt'] as String).add(const Duration(days: 90)),
          description: item['description'] as String? ?? '',
          createdAt: DateTime.parse(item['createdAt'] as String),
          factorIds: List<String>.from(item['factorIds'] as List? ?? []),
        );
        await StorageService.saveGoal(goal);
        count++;
      } catch (e) {
        // Skip invalid items
      }
    }
    return count;
  }

  static Future<int> _importGrowthAreas(List data, ImportMode mode) async {
    int count = 0;
    for (final item in data) {
      try {
        final area = GrowthArea(
          id: item['id'] as String,
          name: item['name'] as String,
          type: GrowthAreaType.values[item['type'] as int],
          targetLevel: item['targetLevel'] as int,
          currentLevel: item['currentLevel'] as int,
          description: item['description'] as String,
          goalId: item['goalId'] as String,
          lastUpdated: DateTime.parse(item['lastUpdated'] as String),
          targetDescription: item['targetDescription'] as String? ?? '',
          currentDescription: item['currentDescription'] as String? ?? '',
          linkedHabitIds: List<String>.from(item['linkedHabitIds'] as List? ?? []),
          isActiveFocus: item['isActiveFocus'] as bool? ?? false,
          lastWorkedOn: item['lastWorkedOn'] != null ? DateTime.parse(item['lastWorkedOn'] as String) : null,
          healthPercent: (item['healthPercent'] as num?)?.toDouble() ?? 100.0,
          treeDesignId: item['treeDesignId'] as String? ?? 'oak',
        );
        await StorageService.saveFactor(area);
        count++;
      } catch (e) {
        // Skip invalid items
      }
    }
    return count;
  }

  static Future<int> _importSprintTargets(List data, ImportMode mode) async {
    int count = 0;
    for (final item in data) {
      try {
        final target = SprintTarget(
          id: item['id'] as String,
          title: item['title'] as String,
          description: item['description'] as String? ?? '',
          duration: SprintDuration.values[item['duration'] as int],
          isCompleted: item['isCompleted'] as bool? ?? false,
          createdAt: DateTime.parse(item['createdAt'] as String),
          targetDate: DateTime.parse(item['targetDate'] as String),
          linkedFactorIds: List<String>.from(item['linkedFactorIds'] as List? ?? []),
        );
        await StorageService.saveSprintTarget(target);
        count++;
      } catch (e) {
        // Skip invalid items
      }
    }
    return count;
  }

  static Future<int> _importTasks(List data, ImportMode mode) async {
    int count = 0;
    for (final item in data) {
      try {
        final task = Task(
          id: item['id'] as String,
          title: item['title'] as String,
          description: item['description'] as String? ?? '',
          isPriority: item['isPriority'] as bool,
          isCompleted: item['isCompleted'] as bool,
          source: TaskSource.values[item['source'] as int],
          createdAt: DateTime.parse(item['createdAt'] as String),
          completedAt: item['completedAt'] != null ? DateTime.parse(item['completedAt'] as String) : null,
          linkedFactorIds: List<String>.from(item['linkedFactorIds'] as List? ?? []),
          experimentId: item['experimentId'] as String?,
          sortOrder: item['sortOrder'] as int? ?? 0,
          effort: TaskEffort.values[item['effort'] as int? ?? 0],
          impact: TaskImpact.values[item['impact'] as int? ?? 0],
          addedToPriorityAt: item['addedToPriorityAt'] != null ? DateTime.parse(item['addedToPriorityAt'] as String) : null,
          abandonReason: item['abandonReason'] != null ? TaskAbandonReason.values[item['abandonReason'] as int] : null,
          blockedByTaskId: item['blockedByTaskId'] as String?,
          category: item['category'] as String? ?? 'General',
          deadline: item['deadline'] != null ? DateTime.parse(item['deadline'] as String) : null,
          customTag: item['customTag'] as String?,
        );
        await StorageService.saveTask(task);
        count++;
      } catch (e) {
        // Skip invalid items
      }
    }
    return count;
  }

  static Future<int> _importSubtasks(List data, ImportMode mode) async {
    int count = 0;
    for (final item in data) {
      try {
        final subtask = Subtask(
          id: item['id'] as String,
          title: item['title'] as String,
          isCompleted: item['isCompleted'] as bool,
          parentTaskId: item['parentTaskId'] as String,
          sortOrder: item['sortOrder'] as int? ?? 0,
        );
        await StorageService.saveSubtask(subtask);
        count++;
      } catch (e) {
        // Skip invalid items
      }
    }
    return count;
  }

  static Future<int> _importHabits(List data, ImportMode mode) async {
    int count = 0;
    for (final item in data) {
      try {
        final logs = (item['logs'] as List? ?? []).map((logData) {
          return HabitLog(
            date: DateTime.parse(logData['date'] as String),
            completed: logData['completed'] as bool,
            note: logData['note'] as String?,
            moodRating: logData['moodRating'] as int?,
            barrierTag: logData['barrierTag'] as String?,
          );
        }).toList();

        final habit = Habit(
          id: item['id'] as String,
          name: item['name'] as String,
          type: HabitType.values[item['type'] as int],
          triggerResponse: item['triggerResponse'] as String?,
          currentStreak: item['currentStreak'] as int? ?? 0,
          bestStreak: item['bestStreak'] as int? ?? 0,
          completionCount: item['completionCount'] as int? ?? 0,
          logs: logs,
          createdAt: DateTime.parse(item['createdAt'] as String),
          isActive: item['isActive'] as bool? ?? true,
          factorId: item['factorId'] as String?,
          scheduledDays: List<int>.from(item['scheduledDays'] as List? ?? [1, 2, 3, 4, 5, 6, 7]),
          targetFrequency: item['targetFrequency'] as int? ?? 1,
          motivation: item['motivation'] as String? ?? '',
          timerMinutes: item['timerMinutes'] as int?,
          streakFreezes: item['streakFreezes'] as int? ?? 0,
          freezesUsed: item['freezesUsed'] as int? ?? 0,
        );
        await StorageService.saveHabit(habit);
        count++;
      } catch (e) {
        // Skip invalid items
      }
    }
    return count;
  }

  static Future<int> _importReflections(List data, ImportMode mode) async {
    int count = 0;
    for (final item in data) {
      try {
        final reflection = Reflection(
          id: item['id'] as String,
          experience: item['experience'] as String? ?? '',
          reflection: item['reflection'] as String? ?? '',
          abstraction: item['abstraction'] as String? ?? '',
          experimentIds: List<String>.from(item['experimentIds'] as List? ?? []),
          linkedFactorIds: List<String>.from(item['linkedFactorIds'] as List? ?? []),
          isFollowUp: item['isFollowUp'] as bool? ?? false,
          previousReflectionId: item['previousReflectionId'] as String?,
          createdAt: DateTime.parse(item['createdAt'] as String),
          rawMarkdown: item['rawMarkdown'] as String?,
          targetFactorId: item['targetFactorId'] as String?,
          previousExperimentId: item['previousExperimentId'] as String?,
          groupId: item['groupId'] as String?,
          marginalGainDescription: item['marginalGainDescription'] as String?,
          eventSequence: item['eventSequence'] as String?,
          feelings: item['feelings'] as String?,
          difficulties: item['difficulties'] as String?,
          challengeResponse: item['challengeResponse'] as String?,
          triggers: item['triggers'] as String?,
          whyBehavior: item['whyBehavior'] as String?,
          crossLifePatterns: item['crossLifePatterns'] as String?,
          isManualEntry: item['isManualEntry'] as bool? ?? false,
        );
        await StorageService.saveReflection(reflection);
        count++;
      } catch (e) {
        // Skip invalid items
      }
    }
    return count;
  }

  static Future<int> _importReflectionGroups(List data, ImportMode mode) async {
    int count = 0;
    for (final item in data) {
      try {
        final group = ReflectionGroup(
          id: item['id'] as String,
          title: item['title'] as String,
          reflectionIds: List<String>.from(item['reflectionIds'] as List? ?? []),
          createdAt: DateTime.parse(item['createdAt'] as String),
          archivedAt: item['archivedAt'] != null ? DateTime.parse(item['archivedAt'] as String) : null,
          targetFactorId: item['targetFactorId'] as String?,
        );
        await StorageService.saveReflectionGroup(group);
        count++;
      } catch (e) {
        // Skip invalid items
      }
    }
    return count;
  }

  static Future<int> _importExperiments(List data, ImportMode mode) async {
    int count = 0;
    for (final item in data) {
      try {
        final experiment = Experiment(
          id: item['id'] as String,
          description: item['description'] as String,
          status: ExperimentStatus.values[item['status'] as int],
          reflectionId: item['reflectionId'] as String,
          createdAt: DateTime.parse(item['createdAt'] as String),
          groupId: item['groupId'] as String?,
          cycleCount: item['cycleCount'] as int? ?? 0,
          startedAt: item['startedAt'] != null ? DateTime.parse(item['startedAt'] as String) : null,
          completedAt: item['completedAt'] != null ? DateTime.parse(item['completedAt'] as String) : null,
          notes: item['notes'] as String?,
        );
        await StorageService.saveExperiment(experiment);
        count++;
      } catch (e) {
        // Skip invalid items
      }
    }
    return count;
  }

  static Future<int> _importBarriers(List data, ImportMode mode) async {
    int count = 0;
    for (final item in data) {
      try {
        final barrier = BarrierEntry(
          id: item['id'] as String,
          description: item['description'] as String,
          occurredAt: DateTime.parse(item['occurredAt'] as String),
          response: item['response'] as String?,
          wasHandled: item['wasHandled'] as bool? ?? false,
          factorId: item['factorId'] as String?,
        );
        await StorageService.saveBarrier(barrier);
        count++;
      } catch (e) {
        // Skip invalid items
      }
    }
    return count;
  }

  static Future<int> _importAchievements(List data, ImportMode mode) async {
    int count = 0;
    for (final item in data) {
      try {
        final achievement = Achievement(
          id: item['id'] as String,
          title: item['title'] as String,
          description: item['description'] as String,
          iconEmoji: item['iconEmoji'] as String,
          xpReward: item['xpReward'] as int? ?? 0,
          coinReward: item['coinReward'] as int? ?? 0,
          category: item['category'] as String,
          unlockedAt: item['unlockedAt'] != null ? DateTime.parse(item['unlockedAt'] as String) : null,
        );
        await StorageService.saveAchievement(achievement);
        count++;
      } catch (e) {
        // Skip invalid items
      }
    }
    return count;
  }

  static Future<int> _importFocusLogs(List data, ImportMode mode) async {
    int count = 0;
    for (final item in data) {
      try {
        final log = FocusLog(
          id: item['id'] as String,
          taskId: item['taskId'] as String,
          taskTitle: item['taskTitle'] as String,
          startTime: DateTime.parse(item['startTime'] as String),
          duration: Duration(minutes: item['duration'] as int),
          completedPomodoros: item['completedPomodoros'] as int? ?? 0,
          distractions: List<String>.from(item['distractions'] as List? ?? []),
        );
        await StorageService.saveFocusLog(log);
        count++;
      } catch (e) {
        // Skip invalid items
      }
    }
    return count;
  }

  static UserStats _userStatsFromJson(Map<String, dynamic> json) {
    return UserStats(
      totalXP: json['totalXP'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] != null ? DateTime.parse(json['lastActiveDate'] as String) : null,
      freezeTokens: json['freezeTokens'] as int? ?? 0,
      unlockedBadgeIds: List<String>.from(json['unlockedBadgeIds'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      xpEarnedToday: json['xpEarnedToday'] as int? ?? 0,
      coinsEarnedToday: json['coinsEarnedToday'] as int? ?? 0,
      actionsToday: json['actionsToday'] as int? ?? 0,
      lastResetDate: json['lastResetDate'] != null ? DateTime.parse(json['lastResetDate'] as String) : null,
      lastReflectionAt: json['lastReflectionAt'] != null ? DateTime.parse(json['lastReflectionAt'] as String) : null,
      reminderFrequency: ReflectionReminderFrequency.values[json['reminderFrequency'] as int? ?? 0],
    );
  }

  static Future<void> _importSettings(Map<String, dynamic> settings) async {
    if (settings.containsKey('timeAvailability') && settings['timeAvailability'] != null) {
      await StorageService.setTimeAvailability(TimeAvailability.values[settings['timeAvailability'] as int]);
    }
    if (settings.containsKey('onboardingComplete')) {
      await StorageService.setOnboardingComplete(settings['onboardingComplete'] as bool);
    }
    if (settings.containsKey('taskCategories')) {
      await StorageService.saveTaskCategories(List<String>.from(settings['taskCategories'] as List));
    }
  }
}
