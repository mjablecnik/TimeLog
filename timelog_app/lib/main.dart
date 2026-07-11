import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'providers/reminder_provider.dart';
import 'providers/timer_provider.dart';
import 'services/notification_service.dart';
import 'services/reminder_service.dart';

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
    container.read(timerProvider.notifier).start();
  }

  await reminderService.initialize(
    onNotificationTap: (payload) {
      if (payload == ReminderService.startTimerPayload) {
        autoStartIfIdle();
      }
    },
  );

  final launchPayload = await reminderService.getLaunchPayload();
  if (launchPayload == ReminderService.startTimerPayload) {
    await container.read(timerProvider.notifier).restored;
    autoStartIfIdle();
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TimeLogApp(),
    ),
  );
}
