import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'providers/reminder_action_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/recurring_reminders_provider.dart';
import 'providers/timer_provider.dart';
import 'services/notification_service.dart';
import 'services/reminder_service.dart';
import 'services/recurring_reminder_service.dart';
import 'services/timer_service.dart';

/// SharedPreferences key used to persist the reminder ID from a notification
/// tap so the UI can pick it up on resume (the Dart callback may fire while
/// the widget tree is suspended on iOS).
const String kPendingReminderIdKey = 'pending_reminder_action_id';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().requestPermission();

  final reminderService = ReminderService();
  final container = ProviderContainer(
    overrides: [
      reminderServiceProvider.overrideWithValue(reminderService),
    ],
  );

  void autoStartIfIdle() {
    final state = container.read(timerProvider);
    if (state.status == TimerStatus.idle) {
      container.read(timerProvider.notifier).start();
    }
  }

  await reminderService.initialize(
    onNotificationTap: (payload) {
      if (payload == ReminderService.startTimerPayload) {
        autoStartIfIdle();
        return;
      }
      final reminderId = parseReminderIdFromPayload(payload);
      if (reminderId != null) {
        // Persist to SharedPreferences so the value survives even if the
        // Dart isolate is suspended (iOS background). The UI reads it on
        // resume via didChangeAppLifecycleState.
        SharedPreferences.getInstance().then((prefs) {
          prefs.setInt(kPendingReminderIdKey, reminderId);
        });
        // Also set provider for the case when app is in foreground.
        container.read(pendingReminderActionProvider.notifier).state = reminderId;
      }
    },
  );

  // Check if there's a persisted pending reminder from a previous tap
  // (e.g. app was killed after the tap was persisted, or cold launch).
  final prefs = await SharedPreferences.getInstance();
  final persistedReminderId = prefs.getInt(kPendingReminderIdKey);
  if (persistedReminderId != null) {
    container.read(pendingReminderActionProvider.notifier).state = persistedReminderId;
    await prefs.remove(kPendingReminderIdKey);
  }

  final launchPayload = await reminderService.getLaunchPayload();
  if (launchPayload == ReminderService.startTimerPayload) {
    await container.read(timerProvider.notifier).restored;
    autoStartIfIdle();
  } else {
    final launchReminderId = parseReminderIdFromPayload(launchPayload);
    if (launchReminderId != null) {
      container.read(pendingReminderActionProvider.notifier).state = launchReminderId;
    }
  }

  await rescheduleReminderIfEnabled(reminderService);
  await container.read(recurringReminderServiceProvider).rescheduleAll();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TimeLogApp(),
    ),
  );
}
