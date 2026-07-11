import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../models/achievement.dart';
import '../models/backup_models.dart';
import '../models/category_model.dart';
import '../models/experiment.dart';
import '../models/focus_log.dart';
import '../models/goal.dart';
import '../models/growth_area.dart';
import '../models/habit.dart';
import '../models/habit_enums.dart';
import '../models/recurring_task.dart';
import '../models/reflection.dart';
import '../models/reflection_group.dart';
import '../models/reflection_reminder.dart';
import '../models/spaced_repetition_subject.dart';
import '../models/spaced_repetition_topic.dart';
import '../models/sprint_target.dart';
import '../models/subtask.dart';
import '../models/task.dart';
import '../models/time_availability.dart';
import '../models/user_stats.dart';
import 'storage_service.dart';

/// Service for backing up and restoring all user data.
class BackupService {
  static const String _backupVersion = '1.1.0';
  static const String _appVersion = '1.0.0+1';

  static String generateBackupFilename() {
    final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
    return 'centile_backup_$timestamp.json';
  }

  /// Export all user data to an app-private temporary file.
  static Future<File> exportAllData() => writeBackupToTemporaryFile();

  static Future<File> writeBackupToTemporaryFile() async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$generateBackupFilename()');
      await file.writeAsString(await generateBackupJson());
      return file;
    } catch (e) {
      throw BackupException('Failed to export data', e);
    }
  }

  static Future<String> generateBackupJson() async {
    try {
      final goals = StorageService.getAllGoals();
      final factors = StorageService.getAllFactors();
      final sprintTargets = StorageService.getAllSprintTargets();
      final tasks = StorageService.getAllTasks();
      final subtasks = <Subtask>[
        for (final task in tasks) ...StorageService.getSubtasksForTask(task.id),
      ];
      final habits = StorageService.getAllHabits();
      final recurringTasks = StorageService.getAllRecurringTasks();
      final reflections = StorageService.getAllReflections();
      final reflectionGroups = StorageService.getAllReflectionGroups();
      final experiments = StorageService.getAllExperiments();
      final barriers = StorageService.getAllBarriers();
      final achievements = StorageService.getAllAchievements();
      final focusLogs = StorageService.getAllFocusLogs();
      final categories = StorageService.getAllCategories();
      final srSubjects = StorageService.getAllSubjects();
      final srTopics = StorageService.getAllTopics();

      final dataCounts = <String, int>{
        'goals': goals.length,
        'growthAreas': factors.length,
        'sprintTargets': sprintTargets.length,
        'categories': categories.length,
        'tasks': tasks.length,
        'subtasks': subtasks.length,
        'habits': habits.length,
        'recurringTasks': recurringTasks.length,
        'reflections': reflections.length,
        'reflectionGroups': reflectionGroups.length,
        'experiments': experiments.length,
        'barriers': barriers.length,
        'spacedRepetitionSubjects': srSubjects.length,
        'spacedRepetitionTopics': srTopics.length,
        'achievements': achievements.length,
        'focusLogs': focusLogs.length,
      };

      final metadata = BackupMetadata(
        version: _backupVersion,
        exportedAt: DateTime.now(),
        appVersion: _appVersion,
        dataCounts: dataCounts,
      );

      final backup = {
        'metadata': metadata.toJson(),
        'data': {
          'goals': goals.map(_goalToJson).toList(),
          'growthAreas': factors.map(_growthAreaToJson).toList(),
          'sprintTargets': sprintTargets.map(_sprintTargetToJson).toList(),
          'categories': categories.map(_categoryToJson).toList(),
          'tasks': tasks.map(_taskToJson).toList(),
          'subtasks': subtasks.map(_subtaskToJson).toList(),
          'habits': habits.map(_habitToJson).toList(),
          'recurringTasks': recurringTasks.map(_recurringTaskToJson).toList(),
          'reflections': reflections.map(_reflectionToJson).toList(),
          'reflectionGroups': reflectionGroups
              .map(_reflectionGroupToJson)
              .toList(),
          'experiments': experiments.map(_experimentToJson).toList(),
          'barriers': barriers.map(_barrierToJson).toList(),
          'spacedRepetitionSubjects': srSubjects.map(_srSubjectToJson).toList(),
          'spacedRepetitionTopics': srTopics.map(_srTopicToJson).toList(),
          'userStats': _userStatsToJson(StorageService.getUserStats()),
          'achievements': achievements.map(_achievementToJson).toList(),
          'focusLogs': focusLogs.map(_focusLogToJson).toList(),
          'settings': {
            'timeAvailability': StorageService.getTimeAvailability()?.index,
            'onboardingComplete': StorageService.hasCompletedOnboarding,
            'categoriesMigrationV1Done': StorageService.categoriesMigrationDone,
          },
        },
      };

      return const JsonEncoder.withIndent('  ').convert(backup);
    } catch (e) {
      throw BackupException('Failed to generate backup JSON', e);
    }
  }

  static Future<BackupPreview> previewBackup(String jsonString) async {
    try {
      final parsed = _parseBackupData(jsonString);
      final conflicts = <String>[];
      if (parsed.goals.isNotEmpty && StorageService.getAllGoals().isNotEmpty) {
        conflicts.add(
          '${StorageService.getAllGoals().length} existing goals will be affected',
        );
      }

      return BackupPreview(
        metadata: parsed.metadata,
        dataCounts: parsed.dataCounts,
        conflicts: conflicts,
        validationErrors: const [],
      );
    } on BackupException catch (e) {
      final metadata = BackupMetadata(
        version: 'unknown',
        exportedAt: DateTime.now(),
        appVersion: 'unknown',
        dataCounts: const {},
      );
      return BackupPreview(
        metadata: metadata,
        dataCounts: const {},
        conflicts: const [],
        validationErrors: [e.toString()],
      );
    }
  }

  static Future<ImportResult> importData(
    String jsonString,
    ImportMode mode,
  ) async {
    final imported = <String, int>{};
    final skipped = <String, int>{};
    final failed = <String, int>{};
    final errors = <String>[];

    try {
      final parsed = _parseBackupData(jsonString);

      if (mode == ImportMode.replace) {
        await _clearAllData();
      }

      Future<void> saveMany<T>(
        String key,
        List<T> values,
        Future<void> Function(T value) save,
        bool Function(T value) exists,
      ) async {
        var count = 0;
        var skippedCount = 0;
        for (final value in values) {
          if (mode == ImportMode.merge && exists(value)) {
            skippedCount++;
            continue;
          }
          await save(value);
          count++;
        }
        imported[key] = count;
        if (skippedCount > 0) skipped[key] = skippedCount;
      }

      await saveMany(
        'goals',
        parsed.goals,
        StorageService.saveGoal,
        (g) => StorageService.getGoal(g.id) != null,
      );
      await saveMany(
        'growthAreas',
        parsed.growthAreas,
        StorageService.saveFactor,
        (f) => StorageService.getFactor(f.id) != null,
      );
      await saveMany(
        'sprintTargets',
        parsed.sprintTargets,
        StorageService.saveSprintTarget,
        (target) => StorageService.getAllSprintTargets().any(
          (existing) => existing.id == target.id,
        ),
      );
      await saveMany(
        'categories',
        parsed.categories,
        StorageService.saveCategory,
        (c) => StorageService.getCategory(c.id) != null,
      );
      await _importSettings(
        parsed.settings,
        preserveExisting: mode == ImportMode.merge,
      );
      await saveMany(
        'tasks',
        parsed.tasks,
        StorageService.saveTask,
        (t) => StorageService.getTask(t.id) != null,
      );
      await saveMany(
        'subtasks',
        parsed.subtasks,
        StorageService.saveSubtask,
        (subtask) => StorageService.getSubtask(subtask.id) != null,
      );
      await saveMany(
        'habits',
        parsed.habits,
        StorageService.saveHabit,
        (h) => StorageService.getAllHabits().any(
          (existing) => existing.id == h.id,
        ),
      );
      await saveMany(
        'recurringTasks',
        parsed.recurringTasks,
        StorageService.saveRecurringTask,
        (t) => StorageService.getRecurringTask(t.id) != null,
      );
      await saveMany(
        'reflections',
        parsed.reflections,
        StorageService.saveReflection,
        (r) => StorageService.getReflection(r.id) != null,
      );
      await saveMany(
        'reflectionGroups',
        parsed.reflectionGroups,
        StorageService.saveReflectionGroup,
        (group) => StorageService.getReflectionGroup(group.id) != null,
      );
      await saveMany(
        'experiments',
        parsed.experiments,
        StorageService.saveExperiment,
        (experiment) => StorageService.getAllExperiments().any(
          (existing) => existing.id == experiment.id,
        ),
      );
      await saveMany(
        'barriers',
        parsed.barriers,
        StorageService.saveBarrier,
        (barrier) => StorageService.getAllBarriers().any(
          (existing) => existing.id == barrier.id,
        ),
      );
      await saveMany(
        'spacedRepetitionSubjects',
        parsed.srSubjects,
        StorageService.saveSubject,
        (s) => StorageService.getSubject(s.id) != null,
      );
      await saveMany(
        'spacedRepetitionTopics',
        parsed.srTopics,
        StorageService.saveTopic,
        (t) => StorageService.getTopic(t.id) != null,
      );
      await saveMany(
        'achievements',
        parsed.achievements,
        StorageService.saveAchievement,
        (achievement) => StorageService.getAchievement(achievement.id) != null,
      );
      await saveMany(
        'focusLogs',
        parsed.focusLogs,
        StorageService.saveFocusLog,
        (log) => StorageService.getAllFocusLogs().any(
          (existing) => existing.id == log.id,
        ),
      );

      if (parsed.userStats != null) {
        if (mode == ImportMode.replace) {
          await StorageService.saveUserStats(parsed.userStats!);
          imported['userStats'] = 1;
        } else {
          skipped['userStats'] = 1;
        }
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

  static Future<void> _clearAllData() async {
    for (final goal in StorageService.getAllGoals()) {
      await StorageService.deleteGoal(goal.id);
    }
    for (final factor in StorageService.getAllFactors()) {
      await StorageService.deleteFactor(factor.id);
    }
    for (final target in StorageService.getAllSprintTargets()) {
      await StorageService.deleteSprintTarget(target.id);
    }
    for (final category in StorageService.getAllCategories()) {
      await StorageService.deleteCategory(category.id);
    }
    for (final task in StorageService.getAllTasks()) {
      await StorageService.deleteTask(task.id);
    }
    for (final habit in StorageService.getAllHabits()) {
      await StorageService.deleteHabit(habit.id);
    }
    for (final recurringTask in StorageService.getAllRecurringTasks()) {
      await StorageService.deleteRecurringTask(recurringTask.id);
    }
    for (final reflection in StorageService.getAllReflections()) {
      await StorageService.deleteReflection(reflection.id);
    }
    for (final group in StorageService.getAllReflectionGroups()) {
      await StorageService.deleteReflectionGroup(group.id);
    }
    for (final experiment in StorageService.getAllExperiments()) {
      await StorageService.deleteExperiment(experiment.id);
    }
    for (final barrier in StorageService.getAllBarriers()) {
      await StorageService.deleteBarrier(barrier.id);
    }
    for (final subject in StorageService.getAllSubjects()) {
      await StorageService.deleteSubject(subject.id);
    }
    for (final topic in StorageService.getAllTopics()) {
      await StorageService.deleteTopic(topic.id);
    }
    for (final achievement in StorageService.getAllAchievements()) {
      await StorageService.deleteAchievement(achievement.id);
    }
    for (final focusLog in StorageService.getAllFocusLogs()) {
      await StorageService.deleteFocusLog(focusLog.id);
    }
    await StorageService.resetBackupSettings();
    await StorageService.saveUserStats(UserStats());
  }

  static _ParsedBackup _parseBackupData(String jsonString) {
    try {
      final root = jsonDecode(jsonString);
      if (root is! Map<String, dynamic>) {
        throw BackupException('Backup root must be a JSON object');
      }
      final metadataJson = _map(root['metadata'], 'metadata');
      final data = _map(root['data'], 'data');
      final metadata = BackupMetadata.fromJson(metadataJson);

      T parseItem<T>(
        String key,
        Object? item,
        int index,
        T Function(Map<String, dynamic>) parse,
      ) {
        try {
          return parse(_map(item, '$key[$index]'));
        } catch (e) {
          throw BackupException('Invalid $key[$index]', e);
        }
      }

      List<T> parseList<T>(String key, T Function(Map<String, dynamic>) parse) {
        final raw = data[key];
        if (raw == null) return <T>[];
        if (raw is! List) throw BackupException('$key must be a list');
        return [
          for (var i = 0; i < raw.length; i++) parseItem(key, raw[i], i, parse),
        ];
      }

      final parsed = _ParsedBackup(
        metadata: metadata,
        goals: parseList('goals', _goalFromJson),
        growthAreas: parseList('growthAreas', _growthAreaFromJson),
        sprintTargets: parseList('sprintTargets', _sprintTargetFromJson),
        categories: parseList('categories', _categoryFromJson),
        tasks: parseList('tasks', _taskFromJson),
        subtasks: parseList('subtasks', _subtaskFromJson),
        habits: parseList('habits', _habitFromJson),
        recurringTasks: parseList('recurringTasks', _recurringTaskFromJson),
        reflections: parseList('reflections', _reflectionFromJson),
        reflectionGroups: parseList(
          'reflectionGroups',
          _reflectionGroupFromJson,
        ),
        experiments: parseList('experiments', _experimentFromJson),
        barriers: parseList('barriers', _barrierFromJson),
        srSubjects: parseList('spacedRepetitionSubjects', _srSubjectFromJson),
        srTopics: parseList('spacedRepetitionTopics', _srTopicFromJson),
        achievements: parseList('achievements', _achievementFromJson),
        focusLogs: parseList('focusLogs', _focusLogFromJson),
        userStats: data['userStats'] == null
            ? null
            : _userStatsFromJson(_map(data['userStats'], 'userStats')),
        settings: data['settings'] == null
            ? const {}
            : _map(data['settings'], 'settings'),
      );
      return parsed;
    } on BackupException {
      rethrow;
    } catch (e) {
      throw BackupException('Failed to parse backup', e);
    }
  }

  static Map<String, dynamic> _map(Object? value, String label) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw BackupException('$label must be an object');
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
    throw BackupException('Missing required string "$key"');
  }

  static DateTime _date(Object? value, DateTime fallback) {
    if (value is String && value.isNotEmpty) return DateTime.parse(value);
    return fallback;
  }

  static DateTime? _nullableDate(Object? value) {
    if (value is String && value.isNotEmpty) return DateTime.parse(value);
    return null;
  }

  static List<String> _strings(Object? value) =>
      value is List ? value.map((e) => e.toString()).toList() : <String>[];
  static List<int> _ints(Object? value) => value is List
      ? value.whereType<num>().map((e) => e.toInt()).toList()
      : <int>[];
  static List<bool>? _boolsOrNull(Object? value) =>
      value is List ? value.map((e) => e == true).toList() : null;
  static List<DateTime>? _datesOrNull(Object? value) => value is List
      ? value.whereType<String>().map(DateTime.parse).toList()
      : null;

  static T _enumOrDefault<T>(List<T> values, Object? raw, T defaultValue) {
    if (raw is int && raw >= 0 && raw < values.length) return values[raw];
    return defaultValue;
  }

  static Map<String, dynamic> _goalToJson(Goal goal) => {
    'id': goal.id,
    'title': goal.title,
    'description': goal.description,
    'targetDate': goal.targetDate.toIso8601String(),
    'createdAt': goal.createdAt.toIso8601String(),
    'factorIds': goal.factorIds,
  };

  static Goal _goalFromJson(Map<String, dynamic> json) => Goal(
    id: _requiredString(json, 'id'),
    title:
        (json['title'] as String?) ??
        (json['description'] as String? ?? 'Untitled Goal'),
    description: json['description'] as String? ?? '',
    targetDate: _date(
      json['targetDate'],
      _date(json['createdAt'], DateTime.now()).add(const Duration(days: 90)),
    ),
    createdAt: _date(json['createdAt'], DateTime.now()),
    factorIds: _strings(json['factorIds']),
  );

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
    'confidenceLevel': area.confidenceLevel,
    'needsResearch': area.needsResearch,
  };

  static GrowthArea _growthAreaFromJson(Map<String, dynamic> json) =>
      GrowthArea(
        id: _requiredString(json, 'id'),
        name: _requiredString(json, 'name'),
        type: _enumOrDefault(
          GrowthAreaType.values,
          json['type'],
          GrowthAreaType.knowledge,
        ),
        targetLevel: (json['targetLevel'] as num?)?.toInt() ?? 7,
        currentLevel: (json['currentLevel'] as num?)?.toInt() ?? 3,
        description: json['description'] as String? ?? '',
        goalId: json['goalId'] as String? ?? '',
        lastUpdated: _date(json['lastUpdated'], DateTime.now()),
        targetDescription: json['targetDescription'] as String? ?? '',
        currentDescription: json['currentDescription'] as String? ?? '',
        linkedHabitIds: _strings(json['linkedHabitIds']),
        isActiveFocus: json['isActiveFocus'] as bool? ?? false,
        lastWorkedOn: _nullableDate(json['lastWorkedOn']),
        healthPercent: (json['healthPercent'] as num?)?.toDouble() ?? 100.0,
        treeDesignId: json['treeDesignId'] as String? ?? 'oak',
        confidenceLevel: (json['confidenceLevel'] as num?)?.toInt() ?? 3,
        needsResearch: json['needsResearch'] as bool? ?? false,
      );

  static Map<String, dynamic> _sprintTargetToJson(SprintTarget target) => {
    'id': target.id,
    'title': target.title,
    'description': target.description,
    'duration': target.duration.index,
    'isCompleted': target.isCompleted,
    'isFailed': target.isFailed,
    'completedAt': target.completedAt?.toIso8601String(),
    'createdAt': target.createdAt.toIso8601String(),
    'targetDate': target.targetDate.toIso8601String(),
    'linkedFactorIds': target.linkedFactorIds,
  };

  static SprintTarget _sprintTargetFromJson(Map<String, dynamic> json) =>
      SprintTarget(
        id: _requiredString(json, 'id'),
        title: _requiredString(json, 'title'),
        description: json['description'] as String? ?? '',
        duration: _enumOrDefault(
          SprintDuration.values,
          json['duration'],
          SprintDuration.thirtyDays,
        ),
        isCompleted: json['isCompleted'] as bool? ?? false,
        isFailed: json['isFailed'] as bool? ?? false,
        completedAt: _nullableDate(json['completedAt']),
        createdAt: _date(json['createdAt'], DateTime.now()),
        targetDate: _nullableDate(json['targetDate']),
        linkedFactorIds: _strings(json['linkedFactorIds']),
      );

  static Map<String, dynamic> _categoryToJson(CategoryModel category) => {
    'id': category.id,
    'name': category.name,
    'iconCodePoint': category.iconCodePoint,
    'iconFontFamily': category.iconFontFamily,
    'colorValue': category.colorValue,
    'isDefault': category.isDefault,
    'createdAt': category.createdAt.toIso8601String(),
    'sortOrder': category.sortOrder,
  };

  static CategoryModel _categoryFromJson(Map<String, dynamic> json) =>
      CategoryModel(
        id: _requiredString(json, 'id'),
        name: _requiredString(json, 'name'),
        iconCodePoint: (json['iconCodePoint'] as num?)?.toInt() ?? 0xe574,
        iconFontFamily: json['iconFontFamily'] as String? ?? 'MaterialIcons',
        colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xff607d8b,
        isDefault: json['isDefault'] as bool? ?? false,
        createdAt: _date(json['createdAt'], DateTime.now()),
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      );

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
    'marginalGainDescription': task.marginalGainDescription,
    'isResearchTask': task.isResearchTask,
    'categoryId': task.categoryId,
    'checklistItems': task.checklistItems,
    'checklistCompleted': task.checklistCompleted,
    'priorityLevel': task.priorityLevel.index,
    'note': task.note,
    'isPending': task.isPending,
    'reminderTimes': task.reminderTimes,
    'scheduledDate': task.scheduledDate.toIso8601String(),
    'scheduledTime': task.scheduledTime,
    'isArchived': task.isArchived,
    'priority': task.priority,
    'quadrant': task.quadrant.index,
    'completionRewardGranted': task.completionRewardGranted,
  };

  static Task _taskFromJson(Map<String, dynamic> json) => Task(
    id: _requiredString(json, 'id'),
    title: _requiredString(json, 'title'),
    description: json['description'] as String? ?? '',
    isPriority: json['isPriority'] as bool? ?? false,
    isCompleted: json['isCompleted'] as bool? ?? false,
    source: _enumOrDefault(
      TaskSource.values,
      json['source'],
      TaskSource.newEntry,
    ),
    createdAt: _date(json['createdAt'], DateTime.now()),
    completedAt: _nullableDate(json['completedAt']),
    linkedFactorIds: _strings(json['linkedFactorIds']),
    experimentId: json['experimentId'] as String?,
    sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    effort: _enumOrDefault(TaskEffort.values, json['effort'], TaskEffort.quick),
    impact: _enumOrDefault(TaskImpact.values, json['impact'], TaskImpact.high),
    addedToPriorityAt: _nullableDate(json['addedToPriorityAt']),
    abandonReason: json['abandonReason'] == null
        ? null
        : _enumOrDefault(
            TaskAbandonReason.values,
            json['abandonReason'],
            TaskAbandonReason.noTime,
          ),
    blockedByTaskId: json['blockedByTaskId'] as String?,
    category: json['category'] as String? ?? 'General',
    deadline: _nullableDate(json['deadline']),
    customTag: json['customTag'] as String?,
    marginalGainDescription: json['marginalGainDescription'] as String?,
    isResearchTask: json['isResearchTask'] as bool? ?? false,
    categoryId: json['categoryId'] as String?,
    checklistItems: json['checklistItems'] == null
        ? null
        : _strings(json['checklistItems']),
    checklistCompleted: _boolsOrNull(json['checklistCompleted']),
    priorityLevel: _enumOrDefault(
      PriorityLevel.values,
      json['priorityLevel'],
      PriorityLevel.none,
    ),
    note: json['note'] as String?,
    isPending: json['isPending'] as bool? ?? false,
    reminderTimes: _strings(json['reminderTimes']),
    scheduledDate: _date(json['scheduledDate'], DateTime.now()),
    scheduledTime: json['scheduledTime'] as String?,
    isArchived: json['isArchived'] as bool? ?? false,
    priority: (json['priority'] as num?)?.toInt() ?? 0,
    quadrant: _enumOrDefault(
      EisenhowerQuadrant.values,
      json['quadrant'],
      EisenhowerQuadrant.inbox,
    ),
    completionRewardGranted: json['completionRewardGranted'] as bool?,
  );

  static Map<String, dynamic> _subtaskToJson(Subtask subtask) => {
    'id': subtask.id,
    'title': subtask.title,
    'isCompleted': subtask.isCompleted,
    'parentTaskId': subtask.parentTaskId,
    'sortOrder': subtask.sortOrder,
    'createdAt': subtask.createdAt.toIso8601String(),
  };

  static Subtask _subtaskFromJson(Map<String, dynamic> json) => Subtask(
    id: _requiredString(json, 'id'),
    title: _requiredString(json, 'title'),
    isCompleted: json['isCompleted'] as bool? ?? false,
    parentTaskId: _requiredString(json, 'parentTaskId'),
    sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    createdAt: _date(json['createdAt'], DateTime.now()),
  );

  static Map<String, dynamic> _habitLogToJson(HabitLog log) => {
    'date': log.date.toIso8601String(),
    'completed': log.completed,
    'note': log.note,
    'moodRating': log.moodRating,
    'barrierTag': log.barrierTag,
    'numericValue': log.numericValue,
    'checklistCompleted': log.checklistCompleted,
    'timerSeconds': log.timerSeconds,
    'score': log.score,
    'rewardGranted': log.rewardGranted,
  };

  static HabitLog _habitLogFromJson(Map<String, dynamic> json) => HabitLog(
    date: _date(json['date'], DateTime.now()),
    completed: json['completed'] as bool? ?? false,
    note: json['note'] as String?,
    moodRating: (json['moodRating'] as num?)?.toInt(),
    barrierTag: json['barrierTag'] as String?,
    numericValue: (json['numericValue'] as num?)?.toInt(),
    checklistCompleted: _boolsOrNull(json['checklistCompleted']),
    timerSeconds: (json['timerSeconds'] as num?)?.toInt(),
    score: (json['score'] as num?)?.toInt(),
    rewardGranted: json['rewardGranted'] as bool?,
  );

  static Map<String, dynamic> _habitToJson(Habit habit) => {
    'id': habit.id,
    'name': habit.name,
    'type': habit.type.index,
    'triggerResponse': habit.triggerResponse,
    'currentStreak': habit.currentStreak,
    'bestStreak': habit.bestStreak,
    'completionCount': habit.completionCount,
    'logs': habit.logs.map(_habitLogToJson).toList(),
    'createdAt': habit.createdAt.toIso8601String(),
    'isActive': habit.isActive,
    'factorId': habit.factorId,
    'linkedFactorIds': habit.linkedFactorIds,
    'scheduledDays': habit.scheduledDays,
    'targetFrequency': habit.targetFrequency,
    'motivation': habit.motivation,
    'timerMinutes': habit.timerMinutes,
    'streakFreezes': habit.streakFreezes,
    'freezesUsed': habit.freezesUsed,
    'categoryId': habit.categoryId,
    'evaluationType': habit.evaluationType?.index,
    'frequencyType': habit.frequencyType?.index,
    'targetValue': habit.targetValue,
    'unit': habit.unit,
    'checklistItems': habit.checklistItems,
    'priorityLevel': habit.priorityLevel?.index,
    'startDate': habit.startDate?.toIso8601String(),
    'endDate': habit.endDate?.toIso8601String(),
    'reminderTimes': habit.reminderTimes,
    'isArchived': habit.isArchived,
    'daysPerPeriod': habit.daysPerPeriod,
    'repeatInterval': habit.repeatInterval,
    'specificDates': habit.specificDates
        ?.map((d) => d.toIso8601String())
        .toList(),
    'description': habit.description,
    'extraGoal': habit.extraGoal,
    'sortOrder': habit.sortOrder,
    'scoringEnabled': habit.scoringEnabled,
    'priority': habit.priority,
  };

  static Habit _habitFromJson(Map<String, dynamic> json) => Habit(
    id: _requiredString(json, 'id'),
    name: _requiredString(json, 'name'),
    type: _enumOrDefault(HabitType.values, json['type'], HabitType.build),
    triggerResponse: json['triggerResponse'] as String?,
    currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
    bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
    completionCount: (json['completionCount'] as num?)?.toInt() ?? 0,
    logs: [
      for (final log in (json['logs'] as List? ?? const []))
        _habitLogFromJson(_map(log, 'habit.log')),
    ],
    createdAt: _date(json['createdAt'], DateTime.now()),
    isActive: json['isActive'] as bool? ?? true,
    factorId: json['factorId'] as String?,
    linkedFactorIds: json['linkedFactorIds'] == null
        ? null
        : _strings(json['linkedFactorIds']),
    scheduledDays: _ints(json['scheduledDays']).isEmpty
        ? null
        : _ints(json['scheduledDays']),
    targetFrequency: (json['targetFrequency'] as num?)?.toInt() ?? 1,
    motivation: json['motivation'] as String? ?? '',
    timerMinutes: (json['timerMinutes'] as num?)?.toInt(),
    streakFreezes: (json['streakFreezes'] as num?)?.toInt() ?? 0,
    freezesUsed: (json['freezesUsed'] as num?)?.toInt() ?? 0,
    categoryId: json['categoryId'] as String?,
    evaluationType: json['evaluationType'] == null
        ? null
        : _enumOrDefault(
            HabitEvaluationType.values,
            json['evaluationType'],
            HabitEvaluationType.yesNo,
          ),
    frequencyType: json['frequencyType'] == null
        ? null
        : _enumOrDefault(
            HabitFrequencyType.values,
            json['frequencyType'],
            HabitFrequencyType.specificDays,
          ),
    targetValue: (json['targetValue'] as num?)?.toInt(),
    unit: json['unit'] as String?,
    checklistItems: json['checklistItems'] == null
        ? null
        : _strings(json['checklistItems']),
    priorityLevel: json['priorityLevel'] == null
        ? null
        : _enumOrDefault(
            PriorityLevel.values,
            json['priorityLevel'],
            PriorityLevel.none,
          ),
    startDate: _nullableDate(json['startDate']),
    endDate: _nullableDate(json['endDate']),
    reminderTimes: json['reminderTimes'] == null
        ? null
        : _strings(json['reminderTimes']),
    isArchived: json['isArchived'] as bool? ?? false,
    daysPerPeriod: (json['daysPerPeriod'] as num?)?.toInt(),
    repeatInterval: (json['repeatInterval'] as num?)?.toInt(),
    specificDates: _datesOrNull(json['specificDates']),
    description: json['description'] as String?,
    extraGoal: (json['extraGoal'] as num?)?.toInt(),
    sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    scoringEnabled: json['scoringEnabled'] as bool? ?? false,
    priority: (json['priority'] as num?)?.toInt() ?? 0,
  );

  static Map<String, dynamic> _recurringTaskLogToJson(RecurringTaskLog log) => {
    'date': log.date.toIso8601String(),
    'completed': log.completed,
    'note': log.note,
    'checklistCompleted': log.checklistCompleted,
    'numericValue': log.numericValue,
    'rewardGranted': log.rewardGranted,
  };

  static RecurringTaskLog _recurringTaskLogFromJson(
    Map<String, dynamic> json,
  ) => RecurringTaskLog(
    date: _date(json['date'], DateTime.now()),
    completed: json['completed'] as bool? ?? false,
    note: json['note'] as String?,
    checklistCompleted: _boolsOrNull(json['checklistCompleted']),
    numericValue: (json['numericValue'] as num?)?.toInt(),
    rewardGranted: json['rewardGranted'] as bool?,
  );

  static Map<String, dynamic> _recurringTaskToJson(RecurringTask task) => {
    'id': task.id,
    'name': task.name,
    'title': task.name,
    'description': task.description,
    'categoryId': task.categoryId,
    'evaluationType': task.evaluationType.index,
    'checklistItems': task.checklistItems,
    'frequencyType': task.frequencyType.index,
    'scheduledDays': task.scheduledDays,
    'repeatInterval': task.repeatInterval,
    'daysPerPeriod': task.daysPerPeriod,
    'specificDates': task.specificDates
        ?.map((d) => d.toIso8601String())
        .toList(),
    'startDate': task.startDate.toIso8601String(),
    'endDate': task.endDate?.toIso8601String(),
    'reminderTimes': task.reminderTimes,
    'priorityLevel': task.priorityLevel.index,
    'linkedFactorIds': task.linkedFactorIds,
    'logs': task.logs.map(_recurringTaskLogToJson).toList(),
    'createdAt': task.createdAt.toIso8601String(),
    'sortOrder': task.sortOrder,
    'isArchived': task.isArchived,
    'priority': task.priority,
  };

  static RecurringTask _recurringTaskFromJson(Map<String, dynamic> json) =>
      RecurringTask(
        id: _requiredString(json, 'id'),
        name:
            (json['name'] as String?) ??
            (json['title'] as String? ?? 'Untitled Recurring Task'),
        categoryId: json['categoryId'] as String? ?? 'general',
        evaluationType: _enumOrDefault(
          HabitEvaluationType.values,
          json['evaluationType'],
          HabitEvaluationType.yesNo,
        ),
        checklistItems: json['checklistItems'] == null
            ? null
            : _strings(json['checklistItems']),
        frequencyType: _enumOrDefault(
          HabitFrequencyType.values,
          json['frequencyType'],
          HabitFrequencyType.everyday,
        ),
        scheduledDays: _ints(json['scheduledDays']).isEmpty
            ? null
            : _ints(json['scheduledDays']),
        daysPerPeriod: (json['daysPerPeriod'] as num?)?.toInt(),
        repeatInterval: (json['repeatInterval'] as num?)?.toInt(),
        specificDates: _datesOrNull(json['specificDates']),
        startDate: _nullableDate(json['startDate']),
        endDate: _nullableDate(json['endDate']),
        reminderTimes: _strings(json['reminderTimes']),
        priorityLevel: _enumOrDefault(
          PriorityLevel.values,
          json['priorityLevel'],
          PriorityLevel.none,
        ),
        linkedFactorIds: _strings(json['linkedFactorIds']),
        logs: [
          for (final log in (json['logs'] as List? ?? const []))
            _recurringTaskLogFromJson(_map(log, 'recurringTask.log')),
        ],
        description: json['description'] as String?,
        createdAt: _date(json['createdAt'], DateTime.now()),
        isArchived: json['isArchived'] as bool? ?? false,
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
        priority: (json['priority'] as num?)?.toInt() ?? 0,
      );

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

  static Reflection _reflectionFromJson(Map<String, dynamic> json) =>
      Reflection(
        id: _requiredString(json, 'id'),
        experience: json['experience'] as String? ?? '',
        reflection: json['reflection'] as String? ?? '',
        abstraction: json['abstraction'] as String? ?? '',
        experimentIds: _strings(json['experimentIds']),
        linkedFactorIds: _strings(json['linkedFactorIds']),
        isFollowUp: json['isFollowUp'] as bool? ?? false,
        previousReflectionId: json['previousReflectionId'] as String?,
        createdAt: _date(json['createdAt'], DateTime.now()),
        rawMarkdown: json['rawMarkdown'] as String?,
        targetFactorId: json['targetFactorId'] as String?,
        previousExperimentId: json['previousExperimentId'] as String?,
        groupId: json['groupId'] as String?,
        marginalGainDescription: json['marginalGainDescription'] as String?,
        eventSequence: json['eventSequence'] as String?,
        feelings: json['feelings'] as String?,
        difficulties: json['difficulties'] as String?,
        challengeResponse: json['challengeResponse'] as String?,
        triggers: json['triggers'] as String?,
        whyBehavior: json['whyBehavior'] as String?,
        crossLifePatterns: json['crossLifePatterns'] as String?,
        isManualEntry: json['isManualEntry'] as bool? ?? false,
      );

  static Map<String, dynamic> _reflectionGroupToJson(ReflectionGroup group) => {
    'id': group.id,
    'title': group.title,
    'reflectionIds': group.reflectionIds,
    'createdAt': group.createdAt.toIso8601String(),
    'archivedAt': group.archivedAt?.toIso8601String(),
    'targetFactorId': group.targetFactorId,
  };

  static ReflectionGroup _reflectionGroupFromJson(Map<String, dynamic> json) =>
      ReflectionGroup(
        id: _requiredString(json, 'id'),
        title: _requiredString(json, 'title'),
        reflectionIds: _strings(json['reflectionIds']),
        createdAt: _date(json['createdAt'], DateTime.now()),
        archivedAt: _nullableDate(json['archivedAt']),
        targetFactorId: json['targetFactorId'] as String?,
      );

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

  static Experiment _experimentFromJson(Map<String, dynamic> json) =>
      Experiment(
        id: _requiredString(json, 'id'),
        description: json['description'] as String? ?? '',
        status: _enumOrDefault(
          ExperimentStatus.values,
          json['status'],
          ExperimentStatus.pending,
        ),
        reflectionId: json['reflectionId'] as String? ?? '',
        createdAt: _date(json['createdAt'], DateTime.now()),
        groupId: json['groupId'] as String?,
        cycleCount: (json['cycleCount'] as num?)?.toInt() ?? 0,
        startedAt: _nullableDate(json['startedAt']),
        completedAt: _nullableDate(json['completedAt']),
        notes: json['notes'] as String?,
      );

  static Map<String, dynamic> _barrierToJson(BarrierEntry barrier) => {
    'id': barrier.id,
    'description': barrier.description,
    'occurredAt': barrier.occurredAt.toIso8601String(),
    'response': barrier.response,
    'wasHandled': barrier.wasHandled,
    'factorId': barrier.factorId,
    'tag': barrier.tag,
    'note': barrier.note,
    'linkedHabitId': barrier.linkedHabitId,
    'linkedTaskId': barrier.linkedTaskId,
    'moodRating': barrier.moodRating,
  };

  static BarrierEntry _barrierFromJson(Map<String, dynamic> json) =>
      BarrierEntry(
        id: _requiredString(json, 'id'),
        description: json['description'] as String? ?? '',
        occurredAt: _date(json['occurredAt'], DateTime.now()),
        response: json['response'] as String?,
        wasHandled: json['wasHandled'] as bool? ?? false,
        factorId: json['factorId'] as String?,
        tag: json['tag'] as String?,
        note: json['note'] as String?,
        linkedHabitId: json['linkedHabitId'] as String?,
        linkedTaskId: json['linkedTaskId'] as String?,
        moodRating: (json['moodRating'] as num?)?.toInt(),
      );

  static Map<String, dynamic> _srSubjectToJson(
    SpacedRepetitionSubject subject,
  ) => {
    'id': subject.id,
    'name': subject.name,
    'iconCodePoint': subject.iconCodePoint,
    'iconFontFamily': subject.iconFontFamily,
    'colorValue': subject.colorValue,
    'sortOrder': subject.sortOrder,
    'createdAt': subject.createdAt.toIso8601String(),
    'isExpanded': subject.isExpanded,
  };

  static SpacedRepetitionSubject _srSubjectFromJson(
    Map<String, dynamic> json,
  ) => SpacedRepetitionSubject(
    id: _requiredString(json, 'id'),
    name: _requiredString(json, 'name'),
    iconCodePoint: (json['iconCodePoint'] as num?)?.toInt() ?? 0xe574,
    iconFontFamily: json['iconFontFamily'] as String? ?? 'MaterialIcons',
    colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xff607d8b,
    sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    createdAt: _date(json['createdAt'], DateTime.now()),
    isExpanded: json['isExpanded'] as bool? ?? true,
  );

  static Map<String, dynamic> _srTopicToJson(SpacedRepetitionTopic topic) => {
    'id': topic.id,
    'subjectId': topic.subjectId,
    'name': topic.name,
    'lastReviewedAt': topic.lastReviewedAt?.toIso8601String(),
    'nextReviewAt': topic.nextReviewAt?.toIso8601String(),
    'currentIntervalDays': topic.currentIntervalDays,
    'reviewCount': topic.reviewCount,
    'sortOrder': topic.sortOrder,
    'createdAt': topic.createdAt.toIso8601String(),
    'notes': topic.notes,
  };

  static SpacedRepetitionTopic _srTopicFromJson(Map<String, dynamic> json) =>
      SpacedRepetitionTopic(
        id: _requiredString(json, 'id'),
        subjectId: _requiredString(json, 'subjectId'),
        name: _requiredString(json, 'name'),
        lastReviewedAt: _nullableDate(json['lastReviewedAt']),
        nextReviewAt: _nullableDate(json['nextReviewAt']),
        currentIntervalDays: (json['currentIntervalDays'] as num?)?.toInt(),
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
        createdAt: _date(json['createdAt'], DateTime.now()),
        notes: json['notes'] as String?,
      );

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

  static Achievement _achievementFromJson(Map<String, dynamic> json) =>
      Achievement(
        id: _requiredString(json, 'id'),
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        iconEmoji: json['iconEmoji'] as String? ?? '',
        xpReward: (json['xpReward'] as num?)?.toInt() ?? 0,
        coinReward: (json['coinReward'] as num?)?.toInt() ?? 0,
        category: json['category'] as String? ?? 'general',
        unlockedAt: _nullableDate(json['unlockedAt']),
      );

  static Map<String, dynamic> _focusLogToJson(FocusLog log) => {
    'id': log.id,
    'taskId': log.taskId,
    'taskTitle': log.taskTitle,
    'startTime': log.startTime.toIso8601String(),
    'duration': log.duration.inMinutes,
    'durationSeconds': log.duration.inSeconds,
    'completedPomodoros': log.completedPomodoros,
    'distractions': log.distractions,
  };

  static FocusLog _focusLogFromJson(Map<String, dynamic> json) => FocusLog(
    id: _requiredString(json, 'id'),
    taskId: json['taskId'] as String? ?? '',
    taskTitle: json['taskTitle'] as String? ?? '',
    startTime: _date(json['startTime'], DateTime.now()),
    duration: json['durationSeconds'] is num
        ? Duration(seconds: (json['durationSeconds'] as num).toInt())
        : Duration(minutes: (json['duration'] as num?)?.toInt() ?? 0),
    completedPomodoros: (json['completedPomodoros'] as num?)?.toInt() ?? 0,
    distractions: _strings(json['distractions']),
  );

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
    'totalTasksCompleted': stats.totalTasksCompleted,
    'priorityTasksCompleted': stats.priorityTasksCompleted,
    'backlogTasksCompleted': stats.backlogTasksCompleted,
    'tasksCompletedToday': stats.tasksCompletedToday,
    'lastTaskCompletionReset': stats.lastTaskCompletionReset?.toIso8601String(),
  };

  static UserStats _userStatsFromJson(Map<String, dynamic> json) => UserStats(
    totalXP: (json['totalXP'] as num?)?.toInt() ?? 0,
    coins: (json['coins'] as num?)?.toInt() ?? 0,
    currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
    longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
    lastActiveDate: _nullableDate(json['lastActiveDate']),
    freezeTokens: (json['freezeTokens'] as num?)?.toInt() ?? 0,
    unlockedBadgeIds: _strings(json['unlockedBadgeIds']),
    createdAt: _date(json['createdAt'], DateTime.now()),
    xpEarnedToday: (json['xpEarnedToday'] as num?)?.toInt() ?? 0,
    coinsEarnedToday: (json['coinsEarnedToday'] as num?)?.toInt() ?? 0,
    actionsToday: (json['actionsToday'] as num?)?.toInt() ?? 0,
    lastResetDate: _nullableDate(json['lastResetDate']),
    lastReflectionAt: _nullableDate(json['lastReflectionAt']),
    reminderFrequency: _enumOrDefault(
      ReflectionReminderFrequency.values,
      json['reminderFrequency'],
      ReflectionReminderFrequency.daily,
    ),
    totalTasksCompleted: (json['totalTasksCompleted'] as num?)?.toInt() ?? 0,
    priorityTasksCompleted:
        (json['priorityTasksCompleted'] as num?)?.toInt() ?? 0,
    backlogTasksCompleted:
        (json['backlogTasksCompleted'] as num?)?.toInt() ?? 0,
    tasksCompletedToday: (json['tasksCompletedToday'] as num?)?.toInt() ?? 0,
    lastTaskCompletionReset: _nullableDate(json['lastTaskCompletionReset']),
  );

  static Future<void> _importSettings(
    Map<String, dynamic> settings, {
    required bool preserveExisting,
  }) async {
    final availability = settings['timeAvailability'];
    if (!preserveExisting &&
        availability is int &&
        availability >= 0 &&
        availability < TimeAvailability.values.length) {
      await StorageService.setTimeAvailability(
        TimeAvailability.values[availability],
      );
    }
    final onboardingComplete = settings['onboardingComplete'];
    if (!preserveExisting && onboardingComplete is bool) {
      await StorageService.setOnboardingComplete(onboardingComplete);
    }

    // Categories migration flag. New backups carry the completed flag; older
    // pre-overhaul backups carry a legacy `taskCategories` string list instead.
    if (settings['taskCategories'] is List) {
      // Pre-overhaul backup: materialize any legacy string category that has
      // no matching CategoryModel, then clear the flag so loadData's migration
      // re-links imported tasks on the next launch.
      final existingNames = {
        for (final c in StorageService.getAllCategories()) c.name.toLowerCase(),
      };
      for (final raw in _strings(settings['taskCategories'])) {
        final name = raw.trim();
        final key = name.toLowerCase();
        if (name.isEmpty || key == 'general' || existingNames.contains(key)) {
          continue;
        }
        await StorageService.saveCategory(
          CategoryModel(
            id: 'imported-${key.replaceAll(RegExp(r'\s+'), '-')}',
            name: name,
            iconCodePoint: 0xe574,
            colorValue: 0xff607d8b,
            sortOrder: StorageService.getAllCategories().length,
          ),
        );
        existingNames.add(key);
      }
      await StorageService.setCategoriesMigrationDone(false);
    } else if (settings['categoriesMigrationV1Done'] == true) {
      await StorageService.setCategoriesMigrationDone(true);
    }
  }
}

class _ParsedBackup {
  final BackupMetadata metadata;
  final List<Goal> goals;
  final List<GrowthArea> growthAreas;
  final List<SprintTarget> sprintTargets;
  final List<CategoryModel> categories;
  final List<Task> tasks;
  final List<Subtask> subtasks;
  final List<Habit> habits;
  final List<RecurringTask> recurringTasks;
  final List<Reflection> reflections;
  final List<ReflectionGroup> reflectionGroups;
  final List<Experiment> experiments;
  final List<BarrierEntry> barriers;
  final List<SpacedRepetitionSubject> srSubjects;
  final List<SpacedRepetitionTopic> srTopics;
  final List<Achievement> achievements;
  final List<FocusLog> focusLogs;
  final UserStats? userStats;
  final Map<String, dynamic> settings;

  _ParsedBackup({
    required this.metadata,
    required this.goals,
    required this.growthAreas,
    required this.sprintTargets,
    required this.categories,
    required this.tasks,
    required this.subtasks,
    required this.habits,
    required this.recurringTasks,
    required this.reflections,
    required this.reflectionGroups,
    required this.experiments,
    required this.barriers,
    required this.srSubjects,
    required this.srTopics,
    required this.achievements,
    required this.focusLogs,
    required this.userStats,
    required this.settings,
  });

  Map<String, int> get dataCounts => {
    'goals': goals.length,
    'growthAreas': growthAreas.length,
    'sprintTargets': sprintTargets.length,
    'categories': categories.length,
    'tasks': tasks.length,
    'subtasks': subtasks.length,
    'habits': habits.length,
    'recurringTasks': recurringTasks.length,
    'reflections': reflections.length,
    'reflectionGroups': reflectionGroups.length,
    'experiments': experiments.length,
    'barriers': barriers.length,
    'spacedRepetitionSubjects': srSubjects.length,
    'spacedRepetitionTopics': srTopics.length,
    'achievements': achievements.length,
    'focusLogs': focusLogs.length,
    if (userStats != null) 'userStats': 1,
    if (settings.isNotEmpty) 'settings': 1,
  };
}
