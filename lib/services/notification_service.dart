import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../models/user_stats.dart';

/// Service for scheduling and displaying Android OS notifications
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static bool _isInitialized = false;

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
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
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
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
    const androidDetails = AndroidNotificationDetails(
      'marginal_gains_channel',
      'Marginal Gains',
      channelDescription: 'Notifications for marginal gains app',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

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
    final title = daysUntilDue <= 0 
        ? '⚠️ Task Overdue!' 
        : '📋 Task Due Soon';
    
    final body = daysUntilDue <= 0
        ? '"$taskName" is overdue!'
        : '"$taskName" is due in $daysUntilDue day${daysUntilDue == 1 ? "" : "s"}';
    
    await showNotification(
      id: 3 + taskId.hashCode % 100,
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
      id: 200 + sprintId.hashCode % 100,
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
      id: 300 + goalId.hashCode % 100,
      title: title,
      body: body,
      payload: 'goal:$goalId',
    );
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}
