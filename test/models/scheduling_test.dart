import 'package:centile/models/habit.dart';
import 'package:centile/models/habit_enums.dart';
import 'package:centile/models/recurring_task.dart';
import 'package:centile/models/growth_area.dart';
import 'package:centile/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('repeat-every scheduling', () {
    test('habit compares calendar days instead of time-of-day durations', () {
      final habit = Habit(
        id: 'habit',
        name: 'Every other day',
        type: HabitType.build,
        frequencyType: HabitFrequencyType.repeatEvery,
        repeatInterval: 2,
        startDate: DateTime(2026, 7, 11, 18),
      );

      expect(habit.isScheduledFor(DateTime(2026, 7, 12)), isFalse);
      expect(habit.isScheduledFor(DateTime(2026, 7, 13)), isTrue);
    });

    test('recurring task compares normalized calendar dates', () {
      final task = RecurringTask(
        id: 'task',
        name: 'Every other day',
        categoryId: 'general',
        frequencyType: HabitFrequencyType.repeatEvery,
        repeatInterval: 2,
        startDate: DateTime(2026, 7, 11, 18),
      );

      expect(task.isScheduledFor(DateTime(2026, 7, 12)), isFalse);
      expect(task.isScheduledFor(DateTime(2026, 7, 13)), isTrue);
    });
  });

  test('flexible weekly habit stops being due after its quota', () {
    final habit = Habit(
      id: 'flexible',
      name: 'Twice weekly',
      type: HabitType.build,
      frequencyType: HabitFrequencyType.someDaysPerPeriod,
      daysPerPeriod: 2,
      startDate: DateTime(2026, 7, 6),
      logs: [
        HabitLog(date: DateTime(2026, 7, 6), completed: true),
        HabitLog(date: DateTime(2026, 7, 7), completed: true),
      ],
    );

    expect(habit.isScheduledFor(DateTime(2026, 7, 6)), isTrue);
    expect(habit.isScheduledFor(DateTime(2026, 7, 8)), isFalse);
    expect(habit.isScheduledFor(DateTime(2026, 7, 13)), isTrue);
  });

  test('editing a completed habit log does not inflate counters', () {
    final today = DateTime.now();
    final habit = Habit(id: 'counter', name: 'Practice', type: HabitType.build);

    habit.logForDate(date: today, completed: true, note: 'First');
    habit.logForDate(date: today, completed: true, note: 'Edited');

    expect(habit.completionCount, 1);
    expect(habit.currentStreak, 1);
    expect(habit.getLogFor(today)?.note, 'Edited');
  });

  test('first failed log does not remove an earlier completion', () {
    final habit = Habit(
      id: 'failed-counter',
      name: 'Practice',
      type: HabitType.build,
      completionCount: 3,
    );

    habit.logForDate(date: DateTime.now(), completed: false);

    expect(habit.completionCount, 3);
  });

  test('completed pending task stays on its completion date', () {
    final completionDate = DateTime(2026, 7, 11, 18);
    final task = Task(
      id: 'rolling-task',
      title: 'Finish report',
      isPending: true,
      scheduledDate: DateTime(2026, 7, 1),
      isCompleted: true,
      completedAt: completionDate,
    );

    expect(task.isScheduledFor(DateTime(2026, 7, 1)), isFalse);
    expect(task.isScheduledFor(DateTime(2026, 7, 11)), isTrue);
  });

  test('active factor health decays once from its stored baseline', () {
    final start = DateTime(2026, 7, 1, 9);
    final factor = GrowthArea(
      id: 'health',
      name: 'Health',
      type: GrowthAreaType.skill,
      goalId: 'goal',
      isActiveFocus: true,
      lastWorkedOn: start,
      healthPercent: 100,
    );
    final threeDaysLater = start.add(const Duration(days: 3));

    expect(factor.calculateDecayedHealth(at: threeDaysLater), 70);
    expect(factor.calculateDecayedHealth(at: threeDaysLater), 70);

    factor.logWork(at: threeDaysLater);
    expect(factor.healthPercent, 90);
    expect(factor.lastWorkedOn, threeDaysLater);
  });
}
