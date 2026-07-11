import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'providers/reminder_provider.dart';
import 'services/notification_service.dart';
import 'services/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().requestPermission();

  final reminderService = ReminderService();
  await reminderService.initialize(onNotificationTap: (payload) {});
  final launchPayload = await reminderService.getLaunchPayload();
  final launchedWithStartTimer =
      launchPayload == ReminderService.startTimerPayload;

  runApp(
    ProviderScope(
      overrides: [
        reminderServiceProvider.overrideWithValue(reminderService),
        launchedWithStartTimerProvider.overrideWithValue(
          launchedWithStartTimer,
        ),
      ],
      child: const TimeLogApp(),
    ),
  );
}
