import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Schedules/cancels the daily "start your timer" reminder notification via
/// `flutter_local_notifications`. Separate from [NotificationService], which
/// handles one-shot timer-completion alerts through a native method channel.
class ReminderService {
  static const int notificationId = 1001;
  static const String channelId = 'daily_reminder';
  static const String channelName = 'Daily Reminder';
  static const String startTimerPayload = 'start_timer';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize the plugin. Must be called before any other method.
  /// [onNotificationTap] is invoked with the notification payload whenever
  /// the user taps a notification while the app is running.
  Future<void> initialize({
    required void Function(String? payload) onNotificationTap,
  }) async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) =>
          onNotificationTap(response.payload),
    );
  }

  /// Request notification permission on iOS. Returns true if granted.
  Future<bool> requestPermission() async {
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin == null) return true;
    final granted = await iosPlugin.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return granted ?? false;
  }

  /// Schedule (or reschedule) a daily repeating notification at [time].
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    await _plugin.zonedSchedule(
      id: notificationId,
      scheduledDate: _nextInstanceOf(time),
      title: 'TimeLog',
      body: 'Time to start your timer!',
      payload: startTimerPayload,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel the scheduled daily reminder, if any.
  Future<void> cancelReminder() async {
    await _plugin.cancel(id: notificationId);
  }

  /// If the app was cold-launched by tapping the reminder notification,
  /// returns its payload; otherwise returns null.
  Future<String?> getLaunchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details?.notificationResponse?.payload;
    }
    return null;
  }

  tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
