import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'providers/reminder_action_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/recurring_reminders_provider.dart';
import 'providers/timer_provider.dart';
import 'services/notification_service.dart';
import 'services/reminder_service.dart';
import 'services/recurring_reminder_service.dart';
import 'services/timer_service.dart';

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
        container.read(pendingReminderActionProvider.notifier).state = reminderId;
      }
    },
  );

  // Determine if the app was cold-launched by tapping a recurring reminder
  // notification. If so, we set the pending provider so the UI picks it up
  // once the widget tree is mounted.
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
