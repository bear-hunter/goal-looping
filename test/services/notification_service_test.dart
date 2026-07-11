import 'package:centile/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationService stable IDs', () {
    test('habit reminder IDs are deterministic', () {
      final first = NotificationService.habitReminderNotificationId(
        'habit-1',
        '08:30',
      );
      final second = NotificationService.habitReminderNotificationId(
        'habit-1',
        '08:30',
      );

      expect(first, second);
      expect(first, inInclusiveRange(0x10000000, 0x1fffffff));
    });

    test('ID ranges do not overlap across reminder types', () {
      expect(
        NotificationService.habitReminderNotificationId('same-id', '09:00'),
        inInclusiveRange(0x10000000, 0x1fffffff),
      );
      expect(
        NotificationService.taskReminderNotificationId('same-id'),
        inInclusiveRange(0x20000000, 0x2fffffff),
      );
      expect(
        NotificationService.taskDeadlineNotificationId('same-id'),
        inInclusiveRange(0x30000000, 0x3fffffff),
      );
      expect(
        NotificationService.sprintNotificationId('same-id'),
        inInclusiveRange(0x40000000, 0x4fffffff),
      );
      expect(
        NotificationService.goalNotificationId('same-id'),
        inInclusiveRange(0x50000000, 0x5fffffff),
      );
      expect(
        NotificationService.recurringTaskReminderNotificationId(
          'same-id',
          '09:00',
        ),
        inInclusiveRange(0x70000000, 0x7fffffff),
      );
    });

    test('different reminder keys produce different sample IDs', () {
      final ids = {
        NotificationService.habitReminderNotificationId('habit-1', '08:30'),
        NotificationService.habitReminderNotificationId('habit-1', '09:30'),
        NotificationService.habitReminderNotificationId('habit-2', '08:30'),
      };

      expect(ids, hasLength(3));
    });

    test('IDs do not collapse known small-range hash collisions', () {
      expect(
        NotificationService.habitReminderNotificationId(
          '00000000-0000-4000-8000-000000000124',
          '09:00',
        ),
        isNot(
          NotificationService.habitReminderNotificationId(
            '00000000-0000-4000-8000-0000000001ea',
            '09:00',
          ),
        ),
      );
      expect(
        NotificationService.taskReminderNotificationId(
          '00000000-0000-4000-8000-0000000002ba',
        ),
        isNot(
          NotificationService.taskReminderNotificationId(
            '00000000-0000-4000-8000-000000000409',
          ),
        ),
      );
    });

    test('specific weekdays use distinct deterministic IDs', () {
      final ids = {
        for (var weekday = 1; weekday <= 7; weekday++)
          NotificationService.habitWeekdayReminderNotificationId(
            'habit-1',
            '08:30',
            weekday,
          ),
      };

      expect(ids, hasLength(7));
      expect(
        ids,
        isNot(
          contains(
            NotificationService.habitReminderNotificationId('habit-1', '08:30'),
          ),
        ),
      );
      expect(
        NotificationService.habitWeekdayReminderNotificationId(
          'habit-1',
          '08:30',
          DateTime.monday,
        ),
        NotificationService.habitWeekdayReminderNotificationId(
          'habit-1',
          '08:30',
          DateTime.monday,
        ),
      );
    });

    test('recurring task weekdays use a distinct ID namespace', () {
      final ids = {
        for (var weekday = 1; weekday <= 7; weekday++)
          NotificationService.recurringTaskWeekdayReminderNotificationId(
            'recurring-1',
            '08:30',
            weekday,
          ),
      };

      expect(ids, hasLength(7));
      expect(ids, everyElement(inInclusiveRange(0x70000000, 0x7fffffff)));
    });
  });
}
