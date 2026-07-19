import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'providers/reminder_provider.dart';
import 'providers/recurring_reminders_provider.dart';
import 'providers/timer_provider.dart';
import 'services/notification_service.dart';
import 'services/reminder_service.dart';
import 'services/recurring_reminder_service.dart';
import 'services/timer_service.dart';

/// Stream controller that broadcasts reminder IDs to open when a notification
/// is tapped. The app widget subscribes and performs the navigation when it
/// receives an event — this guarantees the navigator is mounted and ready.
final reminderActionStreamController = StreamController<int>.broadcast();

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
        reminderActionStreamController.add(reminderId);
      }
    },
  );

  // Determine if the app was cold-launched by tapping a recurring reminder
  // notification. If so, we pass the reminder ID to the app widget so it can
  // show the ReminderActionScreen immediately as an overlay on first build,
  // avoiding a race with navigatorKey not yet being attached.
  int? coldLaunchReminderId;
  final launchPayload = await reminderService.getLaunchPayload();
  if (launchPayload == ReminderService.startTimerPayload) {
    await container.read(timerProvider.notifier).restored;
    autoStartIfIdle();
  } else {
    coldLaunchReminderId = parseReminderIdFromPayload(launchPayload);
  }

  await rescheduleReminderIfEnabled(reminderService);
  await container.read(recurringReminderServiceProvider).rescheduleAll();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: TimeLogApp(coldLaunchReminderId: coldLaunchReminderId),
    ),
  );
}
