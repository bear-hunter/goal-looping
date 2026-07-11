import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/user_stats.dart';

/// Service for scheduling and displaying Android OS notifications
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static bool _tzInitialized = false;

  /// Platforms configured by this app for scheduled local notifications.
  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static bool get canSchedule => isSupported && _isInitialized;

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    if (!isSupported) {
      _isInitialized = true;
      return;
    }

    await initializeTimezone();

    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings (for future use)
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
  }

  /// Request notification permissions (Android 13+)
  static Future<bool> requestPermission() async {
    if (!isSupported) return false;

    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  static Future<bool> requestExactAlarmPermissionIfNeeded() async {
    if (!isSupported) return false;

    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return true;

    final canSchedule = await android.canScheduleExactNotifications();
    if (canSchedule == true) return true;
    return await android.requestExactAlarmsPermission() ?? false;
  }

  static Future<void> initializeTimezone() async {
    if (!_tzInitialized) {
      tz_data.initializeTimeZones();
      _tzInitialized = true;
    }

    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone));
    } catch (e) {
      debugPrint('Timezone init failed: $e');
    }
  }

  static const int _habitIdNamespace = 0x10000000;
  static const int _taskReminderIdNamespace = 0x20000000;
  static const int _taskDeadlineIdNamespace = 0x30000000;
  static const int _sprintIdNamespace = 0x40000000;
  static const int _goalIdNamespace = 0x50000000;
  static const int _otherDeadlineIdNamespace = 0x60000000;
  static const int _recurringTaskIdNamespace = 0x70000000;

  static int habitReminderNotificationId(String habitId, String timeString) =>
      _groupedNotificationId(_habitIdNamespace, 'habit:$habitId:$timeString');

  static int habitWeekdayReminderNotificationId(
    String habitId,
    String timeString,
    int weekday,
  ) => habitReminderNotificationId(habitId, timeString) | weekday;

  static int recurringTaskReminderNotificationId(
    String recurringTaskId,
    String timeString,
  ) => _groupedNotificationId(
    _recurringTaskIdNamespace,
    'recurring-task:$recurringTaskId:$timeString',
  );

  static int recurringTaskWeekdayReminderNotificationId(
    String recurringTaskId,
    String timeString,
    int weekday,
  ) =>
      recurringTaskReminderNotificationId(recurringTaskId, timeString) |
      weekday;

  static int taskReminderNotificationId(String taskId) =>
      _namespacedNotificationId(_taskReminderIdNamespace, 'task:$taskId');

  static int deadlineNotificationId(String entityType, String id) {
    switch (entityType) {
      case 'task':
        return taskDeadlineNotificationId(id);
      case 'sprint':
        return sprintNotificationId(id);
      case 'goal':
        return goalNotificationId(id);
      default:
        return _namespacedNotificationId(
          _otherDeadlineIdNamespace,
          '$entityType:$id',
        );
    }
  }

  static int taskDeadlineNotificationId(String taskId) =>
      _namespacedNotificationId(
        _taskDeadlineIdNamespace,
        'task-deadline:$taskId',
      );

  static int sprintNotificationId(String sprintId) =>
      _namespacedNotificationId(_sprintIdNamespace, 'sprint:$sprintId');

  static int goalNotificationId(String goalId) =>
      _namespacedNotificationId(_goalIdNamespace, 'goal:$goalId');

  static int _groupedNotificationId(int namespace, String key) =>
      namespace | ((_stableHash(key) & 0x01ffffff) << 3);

  static int _namespacedNotificationId(int namespace, String key) =>
      namespace | (_stableHash(key) & 0x0fffffff);

  static int _stableHash(String input) {
    var hash = 0x811c9dc5;
    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  /// Handle notification tap
  static void _onNotificationTap(NotificationResponse response) {
    // Can handle deep linking here based on response.payload
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Show immediate notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!canSchedule) return;

    const androidDetails = AndroidNotificationDetails(
      'marginal_gains_channel',
      'Marginal Gains',
      channelDescription: 'Notifications for marginal gains app',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // ========== REFLECTION NOTIFICATIONS ==========

  /// Check and send reflection reminder notification
  static Future<void> checkReflectionReminder(UserStats stats) async {
    if (!stats.isReflectionOverdue) return;

    final daysSince = stats.hoursSinceLastReflection ~/ 24;
    final isCritical = stats.isReflectionCriticallyOverdue;

    await showNotification(
      id: 1,
      title: isCritical ? '⚠️ Reflection Critical!' : '🔔 Time to Reflect',
      body: isCritical
          ? 'It\'s been $daysSince+ days - never go a week without reflecting!'
          : 'Your last reflection was $daysSince days ago. Take a moment to reflect.',
      payload: 'reflection',
    );
  }

  // ========== ACHIEVEMENT NOTIFICATIONS ==========

  /// Show achievement unlock notification
  static Future<void> showAchievementNotification({
    required String achievementId,
    required String title,
    required String description,
  }) async {
    await showNotification(
      id: 2,
      title: '🏆 Achievement Unlocked!',
      body: '$title - $description',
      payload: 'achievement:$achievementId',
    );
  }

  // ========== TASK DEADLINE NOTIFICATIONS ==========

  /// Show task deadline notification
  static Future<void> showTaskDeadlineNotification({
    required String taskId,
    required String taskName,
    required int daysUntilDue,
  }) async {
    final title = daysUntilDue <= 0 ? '⚠️ Task Overdue!' : '📋 Task Due Soon';

    final body = daysUntilDue <= 0
        ? '"$taskName" is overdue!'
        : '"$taskName" is due in $daysUntilDue day${daysUntilDue == 1 ? "" : "s"}';

    await showNotification(
      id: taskDeadlineNotificationId(taskId),
      title: title,
      body: body,
      payload: 'task:$taskId',
    );
  }

  // ========== SPRINT TARGET NOTIFICATIONS ==========

  /// Show sprint target overdue notification
  static Future<void> showSprintOverdueNotification({
    required String sprintId,
    required String sprintDescription,
  }) async {
    await showNotification(
      id: sprintNotificationId(sprintId),
      title: '🎯 Sprint Target Overdue',
      body: '"$sprintDescription" has expired. Mark as complete or extend?',
      payload: 'sprint:$sprintId',
    );
  }

  // ========== GOAL DEADLINE NOTIFICATIONS ==========

  /// Show goal deadline notification
  static Future<void> showGoalDeadlineNotification({
    required String goalId,
    required String goalName,
    required int daysRemaining,
  }) async {
    final title = daysRemaining <= 0
        ? '🚨 Goal Deadline Passed!'
        : '🏁 Goal Deadline Approaching';

    final body = daysRemaining <= 0
        ? '"$goalName" deadline has passed!'
        : '"$goalName" deadline in $daysRemaining day${daysRemaining == 1 ? "" : "s"}';

    await showNotification(
      id: goalNotificationId(goalId),
      title: title,
      body: body,
      payload: 'goal:$goalId',
    );
  }

  // ========== SCHEDULED HABIT/TASK REMINDERS ==========

  /// Schedule a daily reminder for a habit at a specific time
  /// [habitId] - The habit ID for payload
  /// [habitName] - The habit name for display
  /// [timeString] - Time in "HH:MM" format (24-hour)
  /// [weekdays] - List of weekdays to remind (1=Mon, 7=Sun), empty = every day
  static Future<void> scheduleHabitReminder({
    required String habitId,
    required String habitName,
    required String timeString,
    List<int>? weekdays,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'habit_reminders_channel',
      'Habit Reminders',
      channelDescription: 'Daily reminders for your habits',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _scheduleRepeatingReminder(
      entityId: habitId,
      timeString: timeString,
      weekdays: weekdays,
      notificationIdFor: habitReminderNotificationId,
      weekdayNotificationIdFor: habitWeekdayReminderNotificationId,
      title: '🔔 Habit Reminder',
      body: 'Time for: $habitName',
      payload: 'habit:$habitId',
      notificationDetails: notificationDetails,
    );
  }

  static Future<void> scheduleRecurringTaskReminder({
    required String recurringTaskId,
    required String recurringTaskName,
    required String timeString,
    List<int>? weekdays,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'recurring_task_reminders_channel',
      'Recurring Task Reminders',
      channelDescription: 'Reminders for your recurring tasks',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _scheduleRepeatingReminder(
      entityId: recurringTaskId,
      timeString: timeString,
      weekdays: weekdays,
      notificationIdFor: recurringTaskReminderNotificationId,
      weekdayNotificationIdFor: recurringTaskWeekdayReminderNotificationId,
      title: '📋 Recurring Task Reminder',
      body: recurringTaskName,
      payload: 'recurring-task:$recurringTaskId',
      notificationDetails: notificationDetails,
    );
  }

  /// Schedule a reminder for a task at a specific date and time
  static Future<void> scheduleTaskReminder({
    required String taskId,
    required String taskName,
    required DateTime scheduledDateTime,
  }) async {
    if (!canSchedule) return;

    // Don't schedule if in the past
    if (scheduledDateTime.isBefore(DateTime.now())) return;

    final notificationId = taskReminderNotificationId(taskId);

    const androidDetails = AndroidNotificationDetails(
      'task_reminders_channel',
      'Task Reminders',
      channelDescription: 'Reminders for your tasks',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    final tzScheduledDate = tz.TZDateTime.from(scheduledDateTime, tz.local);

    await _notifications.zonedSchedule(
      notificationId,
      '📋 Task Reminder',
      taskName,
      tzScheduledDate,
      notificationDetails,
      androidScheduleMode: await _scheduleMode(),
      payload: 'task:$taskId',
    );
  }

  /// Cancel a habit reminder
  static Future<void> cancelHabitReminder(
    String habitId,
    String timeString,
  ) async {
    await _cancelRepeatingReminder(
      entityId: habitId,
      timeString: timeString,
      notificationIdFor: habitReminderNotificationId,
      weekdayNotificationIdFor: habitWeekdayReminderNotificationId,
    );
  }

  /// Cancels every scheduled reminder whose payload belongs to [habitId].
  ///
  /// This also removes reminders for times that were deleted from the model,
  /// which cannot be derived from the updated habit object anymore.
  static Future<void> cancelAllHabitReminders(String habitId) async {
    await _cancelAllRemindersForPayload('habit:$habitId');
  }

  static Future<void> cancelRecurringTaskReminder(
    String recurringTaskId,
    String timeString,
  ) async {
    await _cancelRepeatingReminder(
      entityId: recurringTaskId,
      timeString: timeString,
      notificationIdFor: recurringTaskReminderNotificationId,
      weekdayNotificationIdFor: recurringTaskWeekdayReminderNotificationId,
    );
  }

  static Future<void> cancelAllRecurringTaskReminders(
    String recurringTaskId,
  ) async {
    await _cancelAllRemindersForPayload('recurring-task:$recurringTaskId');
  }

  /// Cancel a task reminder
  static Future<void> cancelTaskReminder(String taskId) async {
    final notificationId = taskReminderNotificationId(taskId);
    await cancel(notificationId);
  }

  /// Schedule all reminders for a habit (multiple times)
  static Future<void> scheduleAllHabitReminders({
    required String habitId,
    required String habitName,
    required List<String> reminderTimes,
    List<int>? weekdays,
  }) async {
    if (!canSchedule) return;

    await cancelAllHabitReminders(habitId);

    // Schedule new reminders
    for (final time in reminderTimes) {
      await scheduleHabitReminder(
        habitId: habitId,
        habitName: habitName,
        timeString: time,
        weekdays: weekdays,
      );
    }
  }

  static Future<void> scheduleAllRecurringTaskReminders({
    required String recurringTaskId,
    required String recurringTaskName,
    required List<String> reminderTimes,
    List<int>? weekdays,
  }) async {
    if (!canSchedule) return;

    await cancelAllRecurringTaskReminders(recurringTaskId);
    for (final time in reminderTimes) {
      await scheduleRecurringTaskReminder(
        recurringTaskId: recurringTaskId,
        recurringTaskName: recurringTaskName,
        timeString: time,
        weekdays: weekdays,
      );
    }
  }

  /// Clears pending reminders managed by this service without dismissing
  /// unrelated notifications that may already be visible.
  static Future<void> cancelAllScheduledReminders() async {
    if (!canSchedule) return;

    try {
      final pending = await _notifications.pendingNotificationRequests();
      for (final request in pending) {
        final payload = request.payload ?? '';
        if (payload.startsWith('habit:') ||
            payload.startsWith('task:') ||
            payload.startsWith('recurring-task:')) {
          await _notifications.cancel(request.id);
        }
      }
    } catch (error) {
      debugPrint('Unable to inspect pending reminders: $error');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    if (!canSchedule) return;
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  static Future<void> cancel(int id) async {
    if (!canSchedule) return;
    await _notifications.cancel(id);
  }

  static Future<void> _scheduleRepeatingReminder({
    required String entityId,
    required String timeString,
    required List<int>? weekdays,
    required int Function(String, String) notificationIdFor,
    required int Function(String, String, int) weekdayNotificationIdFor,
    required String title,
    required String body,
    required String payload,
    required NotificationDetails notificationDetails,
  }) async {
    if (!canSchedule) return;

    final timeParts = timeString.split(':');
    if (timeParts.length != 2) return;

    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (hour == null || hour < 0 || hour > 23) return;
    if (minute == null || minute < 0 || minute > 59) return;

    final requestedWeekdays = weekdays ?? const <int>[];
    if (requestedWeekdays.any((day) => day < 1 || day > 7)) return;
    final uniqueWeekdays = requestedWeekdays.toSet().toList()..sort();
    final isDaily = uniqueWeekdays.isEmpty || uniqueWeekdays.length == 7;

    await _cancelRepeatingReminder(
      entityId: entityId,
      timeString: timeString,
      notificationIdFor: notificationIdFor,
      weekdayNotificationIdFor: weekdayNotificationIdFor,
    );

    if (isDaily) {
      await _scheduleRepeatingOccurrence(
        notificationId: notificationIdFor(entityId, timeString),
        hour: hour,
        minute: minute,
        notificationDetails: notificationDetails,
        matchDateTimeComponents: DateTimeComponents.time,
        title: title,
        body: body,
        payload: payload,
      );
      return;
    }

    for (final weekday in uniqueWeekdays) {
      await _scheduleRepeatingOccurrence(
        notificationId: weekdayNotificationIdFor(entityId, timeString, weekday),
        hour: hour,
        minute: minute,
        weekday: weekday,
        notificationDetails: notificationDetails,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        title: title,
        body: body,
        payload: payload,
      );
    }
  }

  static Future<void> _cancelRepeatingReminder({
    required String entityId,
    required String timeString,
    required int Function(String, String) notificationIdFor,
    required int Function(String, String, int) weekdayNotificationIdFor,
  }) async {
    await cancel(notificationIdFor(entityId, timeString));
    for (var weekday = 1; weekday <= 7; weekday++) {
      await cancel(weekdayNotificationIdFor(entityId, timeString, weekday));
    }
  }

  static Future<void> _cancelAllRemindersForPayload(String payload) async {
    if (!canSchedule) return;

    try {
      final pending = await _notifications.pendingNotificationRequests();
      for (final request in pending.where((item) => item.payload == payload)) {
        await _notifications.cancel(request.id);
      }
    } catch (error) {
      debugPrint('Unable to inspect pending reminders: $error');
    }
  }

  static Future<void> _scheduleRepeatingOccurrence({
    required int notificationId,
    required int hour,
    required int minute,
    required NotificationDetails notificationDetails,
    required DateTimeComponents matchDateTimeComponents,
    required String title,
    required String body,
    required String payload,
    int? weekday,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = _nextCalendarDay(scheduledDate, hour, minute);
    }
    if (weekday != null) {
      while (scheduledDate.weekday != weekday) {
        scheduledDate = _nextCalendarDay(scheduledDate, hour, minute);
      }
    }

    await _notifications.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: await _scheduleMode(),
      matchDateTimeComponents: matchDateTimeComponents,
      payload: payload,
    );
  }

  static tz.TZDateTime _nextCalendarDay(
    tz.TZDateTime date,
    int hour,
    int minute,
  ) => tz.TZDateTime(
    tz.local,
    date.year,
    date.month,
    date.day + 1,
    hour,
    minute,
  );

  static Future<AndroidScheduleMode> _scheduleMode() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return AndroidScheduleMode.exactAllowWhileIdle;
    final canSchedule = await android.canScheduleExactNotifications();
    return canSchedule == true
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }
}
