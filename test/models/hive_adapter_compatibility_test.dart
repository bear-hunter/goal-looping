import 'dart:collection';

import 'package:centile/models/experiment.dart';
import 'package:centile/models/growth_area.dart';
import 'package:centile/models/habit.dart';
import 'package:centile/models/habit_enums.dart';
import 'package:centile/models/recurring_task.dart';
import 'package:centile/models/reflection.dart';
import 'package:centile/models/reflection_reminder.dart';
import 'package:centile/models/sprint_target.dart';
import 'package:centile/models/task.dart';
import 'package:centile/models/user_stats.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('Hive adapter compatibility', () {
    test('evolved models apply defaults when old fields are absent', () {
      final createdAt = DateTime(2025, 12, 28);

      final area = GrowthAreaAdapter().read(
        _FieldMapReader({
          0: 'area',
          1: 'Skill',
          2: GrowthAreaType.skill,
          3: 7,
          4: 3,
          5: '',
          6: 'goal',
          7: createdAt,
        }),
      );
      expect(area.targetDescription, isEmpty);
      expect(area.isActiveFocus, isFalse);
      expect(area.healthPercent, 100);
      expect(area.treeDesignId, 'oak');
      expect(area.confidenceLevel, 3);
      expect(area.needsResearch, isFalse);

      final sprint = SprintTargetAdapter().read(
        _FieldMapReader({
          0: 'sprint',
          1: 'Sprint',
          2: '',
          3: SprintDuration.thirtyDays,
          4: false,
          5: createdAt,
          6: createdAt.add(const Duration(days: 30)),
          7: <String>[],
        }),
      );
      expect(sprint.isFailed, isFalse);

      final task = TaskAdapter().read(
        _FieldMapReader({
          0: 'task',
          1: 'Task',
          2: '',
          3: false,
          4: false,
          5: TaskSource.newEntry,
          6: createdAt,
          7: null,
          8: <String>[],
          9: null,
          10: 0,
        }),
      );
      expect(task.effort, TaskEffort.quick);
      expect(task.impact, TaskImpact.high);
      expect(task.category, 'General');
      expect(task.priorityLevel, PriorityLevel.none);
      expect(task.isArchived, isFalse);
      expect(task.priority, 0);
      expect(task.quadrant, EisenhowerQuadrant.inbox);

      final habit = HabitAdapter().read(
        _FieldMapReader({
          0: 'habit',
          1: 'Habit',
          2: HabitType.build,
          3: null,
          4: 0,
          5: 0,
          6: 0,
          7: <HabitLog>[],
          8: createdAt,
          9: true,
        }),
      );
      expect(habit.targetFrequency, 1);
      expect(habit.motivation, isEmpty);
      expect(habit.streakFreezes, 0);
      expect(habit.isArchived, isFalse);
      expect(habit.sortOrder, 0);
      expect(habit.scoringEnabled, isFalse);
      expect(habit.priority, 0);

      final reflection = ReflectionAdapter().read(
        _FieldMapReader({
          0: 'reflection',
          1: '',
          2: '',
          3: '',
          4: <String>[],
          5: <String>[],
          6: false,
          7: null,
          8: createdAt,
          9: null,
        }),
      );
      expect(reflection.isManualEntry, isFalse);

      final stats = UserStatsAdapter().read(
        _FieldMapReader({
          0: 10,
          1: 5,
          2: 1,
          3: 2,
          4: null,
          5: 0,
          6: <String>[],
          7: createdAt,
          8: 0,
          9: 0,
          10: 0,
          11: null,
        }),
      );
      expect(stats.reminderFrequency, ReflectionReminderFrequency.daily);
      expect(stats.totalTasksCompleted, 0);
      expect(stats.tasksCompletedToday, 0);

      final recurring = RecurringTaskAdapter().read(
        _FieldMapReader({
          0: 'recurring',
          1: 'Recurring',
          2: 'personal',
          3: HabitEvaluationType.yesNo,
          4: null,
          5: HabitFrequencyType.everyday,
          6: <int>[1, 2, 3, 4, 5, 6, 7],
          7: null,
          8: null,
          9: null,
          10: createdAt,
          11: null,
          12: <String>[],
          13: PriorityLevel.none,
          14: <String>[],
          15: <RecurringTaskLog>[],
          16: null,
          17: createdAt,
          18: false,
          19: 0,
        }),
      );
      expect(recurring.priority, 0);
    });

    test('HabitAdapter migrates original limiting and scripted wires', () {
      final createdAt = DateTime(2025, 12, 28);
      final adapter = HabitAdapter();

      final limiting = adapter.read(
        _FieldMapReader({
          0: 'limiting',
          1: 'No doom scrolling',
          2: HabitType.build, // Original wire 0 decoded by the current enum.
          3: null,
          4: 3,
          5: 5,
          6: 0,
          7: <HabitLog>[
            HabitLog(date: createdAt, completed: true, note: 'Succumbed'),
            HabitLog(
              date: createdAt.add(const Duration(days: 1)),
              completed: false,
            ),
          ],
          8: createdAt,
          9: true,
        }),
      );

      expect(limiting.type, HabitType.quit);
      expect(limiting.logs.map((log) => log.completed), [false, true]);
      expect(limiting.logs.first.note, 'Succumbed');
      expect(limiting.currentStreak, 3);
      expect(limiting.bestStreak, 5);

      final scripted = adapter.read(
        _FieldMapReader({
          0: 'scripted',
          1: 'Take three breaths',
          2: HabitType.quit, // Original wire 1 decoded by the current enum.
          3: 'If distracted, breathe',
          4: 0,
          5: 0,
          6: 7,
          7: <HabitLog>[
            HabitLog(date: createdAt, completed: true),
            HabitLog(
              date: createdAt.add(const Duration(days: 1)),
              completed: false,
            ),
          ],
          8: createdAt,
          9: true,
        }),
      );

      expect(scripted.type, HabitType.build);
      expect(scripted.completionCount, 7);
      expect(scripted.logs.map((log) => log.completed), [true, false]);
    });

    test('HabitAdapter preserves the current read and write layout', () {
      final createdAt = DateTime(2025, 12, 28);
      final adapter = HabitAdapter();
      final current = adapter.read(
        _FieldMapReader({
          0: 'current',
          1: 'Current habit',
          2: HabitType.build,
          3: null,
          4: 2,
          5: 4,
          6: 6,
          7: <HabitLog>[HabitLog(date: createdAt, completed: true)],
          8: createdAt,
          9: true,
          10: 'factor',
        }),
      );

      expect(current.type, HabitType.build);
      expect(current.logs.single.completed, isTrue);
      expect(current.completionCount, 6);
      expect(current.factorId, 'factor');

      final writer = _RecordingWriter();
      adapter.write(writer, current);
      expect(writer.values.take(7), [
        37,
        0,
        'current',
        1,
        'Current habit',
        2,
        HabitType.build,
      ]);
    });

    test('ExperimentAdapter reads both legacy and current field layouts', () {
      final createdAt = DateTime(2025, 12, 28);
      final adapter = ExperimentAdapter();

      final legacy = adapter.read(
        _FieldMapReader({
          0: 'legacy',
          1: 'Legacy experiment',
          2: ExperimentStatus.inProgress,
          3: true, // promotedToPriority in the original layout
          4: 'reflection',
          5: 'legacy-task',
          6: createdAt,
        }),
      );
      expect(legacy.reflectionId, 'reflection');
      expect(legacy.createdAt, createdAt);
      expect(legacy.cycleCount, 0);
      expect(legacy.groupId, isNull);

      final current = adapter.read(
        _FieldMapReader({
          0: 'current',
          1: 'Current experiment',
          2: ExperimentStatus.cycled,
          3: 'reflection',
          4: createdAt,
          5: 'group',
          6: 2,
          7: createdAt,
          8: null,
          9: 'Notes',
        }),
      );
      expect(current.reflectionId, 'reflection');
      expect(current.groupId, 'group');
      expect(current.cycleCount, 2);
      expect(current.notes, 'Notes');
    });
  });
}

class _FieldMapReader implements BinaryReader {
  final ListQueue<dynamic> _values;

  _FieldMapReader(Map<int, dynamic> fields)
    : _values = ListQueue<dynamic>.of([
        fields.length,
        for (final entry in fields.entries) ...[entry.key, entry.value],
      ]);

  @override
  int readByte() => _values.removeFirst() as int;

  @override
  dynamic read([int? typeId]) => _values.removeFirst();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Unexpected BinaryReader call: $invocation');
}

class _RecordingWriter implements BinaryWriter {
  final values = <dynamic>[];

  @override
  void writeByte(int byte) => values.add(byte);

  @override
  void write<T>(T value, {bool writeTypeId = true}) => values.add(value);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Unexpected BinaryWriter call: $invocation');
}
