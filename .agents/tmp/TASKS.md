# TASKS — Daily Timer Reminder

- [x] 1. [HIGH] Add dependencies to pubspec.yaml — add `flutter_local_notifications` and `timezone` packages with pinned versions
- [x] 2. [HIGH] Create ReminderService (`lib/services/reminder_service.dart`) — initialize flutter_local_notifications plugin with iOS settings, implement `initialize()`, `requestPermission()`, `scheduleDailyReminder(TimeOfDay)`, `cancelReminder()`, and notification tap callback that exposes the payload
- [x] 3. [HIGH] Create ReminderSettings data class and ReminderProvider (`lib/providers/reminder_provider.dart`) — StateNotifier holding `{enabled, hour, minute}`, loads from SharedPreferences, exposes `toggleEnabled()` and `setTime(TimeOfDay)`, calls ReminderService to schedule/cancel
- [x] 4. [HIGH] Create SettingsScreen (`lib/ui/screens/settings_screen.dart`) — 4th tab screen with "Daily Reminder" toggle and time picker row; request permission on enable, show snackbar if denied, cancel/reschedule on time change
- [x] 5. [HIGH] Add Settings tab to bottom navigation — add 4th nav item (gear/settings icon) to `bottom_nav.dart` and wire `SettingsScreen` into `_MainShell` in `app.dart`
- [x] 6. [HIGH] Initialize ReminderService on app start (`main.dart`) — call `ReminderService.initialize()` before `runApp`, handle launch notification payload to detect "start_timer" action
- [x] 7. [HIGH] Auto-start timer on notification tap — when app opens via reminder notification (payload == "start_timer"), check if timer is idle and call `timerNotifier.start()`; handle both cold-launch and foreground-tap scenarios
- [x] 8. [HIGH] Re-schedule reminder on app launch — in `main.dart`, after initialization, if `reminder_enabled == true` in SharedPreferences, call `scheduleDailyReminder` to re-register the notification (survives reboot/update)
- [x] 9. [MEDIUM] Handle permission denied gracefully — in SettingsScreen, if `requestPermission()` returns false, revert toggle to off and show explanatory SnackBar; prevent scheduling without permission
- [x] 10. [MEDIUM] Configure timezone for correct local scheduling — initialize `timezone` package with device local timezone in `ReminderService.initialize()`, use `TZDateTime` for `zonedSchedule` calls
- [x] 11. [MEDIUM] Write unit test for ReminderProvider — test that toggling enabled/disabled updates SharedPreferences, that setTime persists correctly, and that provider state reflects stored values on init
