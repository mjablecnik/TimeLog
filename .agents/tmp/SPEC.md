# SPEC: Daily Timer Reminder — Local Notification

## Overview

Add a daily local notification that reminds the user to start the timer at a configurable time (default 08:00). Tapping the notification opens the app and auto-starts the timer if idle. The feature is opt-in, configurable via a new Settings screen.

## Goals

1. Schedule a repeating daily local notification at a user-chosen time
2. Auto-start the timer when the notification is tapped (if timer is idle)
3. Provide a Settings screen with enable/disable toggle and time picker
4. Persist reminder preferences locally
5. Handle iOS notification permissions gracefully
6. Re-schedule on app launch to survive reboots/updates

## Technical Approach

### Package Choice

Use `flutter_local_notifications` for cross-platform local notification scheduling with `zonedSchedule` and `matchDateTimeComponents: DateTimeComponents.time` for daily repeats. Use `timezone` (bundled with flutter_local_notifications) for TZDateTime conversion.

**Why not extend the existing native method channel approach?** The existing `NotificationService` uses a method channel for one-shot timer-completion notifications. Daily repeating scheduled notifications are better handled by `flutter_local_notifications` which provides `zonedSchedule` with repeating support, permission handling, and tap callbacks — all from Dart without additional Swift code.

### Architecture

- New service: `ReminderService` (separate from existing `NotificationService` which handles timer-completion alerts via method channel)
- New screen: `SettingsScreen` added as a 4th tab in bottom nav
- State management: Riverpod provider for reminder settings
- Persistence: SharedPreferences (already a dependency)

## Key Components

### 1. ReminderService (`lib/services/reminder_service.dart`)

Responsibilities:
- Initialize `flutter_local_notifications` plugin
- Request iOS notification permission (returns bool)
- Schedule daily notification at a specific `TimeOfDay` using `zonedSchedule`
- Cancel scheduled notification
- Handle notification tap via callback (sets a flag/stream that the app reads)

Notification details:
- ID: `1001` (distinct from timer notification which uses native channel)
- Channel: `daily_reminder`
- Title: "TimeLog"
- Body: "Time to start your timer!"
- Payload: `"start_timer"`

### 2. ReminderProvider (`lib/providers/reminder_provider.dart`)

A `StateNotifier<ReminderSettings>` with Riverpod:
- `ReminderSettings`: `{enabled: bool, hour: int, minute: int}`
- Loads from SharedPreferences on init
- Exposes `toggleEnabled()`, `setTime(TimeOfDay)`
- Calls `ReminderService` to schedule/cancel as needed

SharedPreferences keys:
- `reminder_enabled` (bool)
- `reminder_hour` (int)
- `reminder_minute` (int)

### 3. SettingsScreen (`lib/ui/screens/settings_screen.dart`)

New screen accessible as the 4th tab (gear icon):
- "Daily Reminder" section with:
  - Toggle switch (enable/disable)
  - Time picker row (tappable, shows current time, opens `showTimePicker`)
- When toggling on: request permission → if granted, schedule; if denied, show snackbar and revert toggle
- When changing time: cancel old → schedule new

### 4. Auto-Start on Tap (`main.dart` / `app.dart`)

When the app launches from a notification tap:
1. `ReminderService` initialization captures the launch notification payload
2. If payload == `"start_timer"` and timer is idle → call `timerNotifier.start()`
3. If timer is already running/paused → do nothing

### 5. Re-schedule on Launch (`main.dart`)

On every app launch:
- If `reminder_enabled == true` in SharedPreferences, re-schedule the notification
- This handles the case where iOS cleared the scheduled notification after reboot/update

## File Structure

New files:
```
lib/services/reminder_service.dart    — notification scheduling logic
lib/providers/reminder_provider.dart  — state management for settings
lib/ui/screens/settings_screen.dart   — settings UI (4th tab)
```

Modified files:
```
pubspec.yaml                          — add flutter_local_notifications, timezone
lib/main.dart                         — initialize ReminderService, handle launch payload
lib/app.dart                          — add SettingsScreen as 4th tab
lib/ui/widgets/bottom_nav.dart        — add 4th nav item (Settings/gear icon)
ios/Runner/Info.plist                  — (if needed) no additional keys required for flutter_local_notifications
```

## Constraints & Edge Cases

1. **Permission denied**: Revert toggle to off, show explanation via SnackBar
2. **App reboot/update**: Re-schedule on next launch if enabled
3. **Time zone changes**: Use `timezone` package with `TZDateTime` for correct local scheduling
4. **Notification while timer running**: Notification still fires (reminder only), tapping just opens app without restarting
5. **Existing NotificationService conflict**: The existing service uses a different method channel (`com.jablecnik.timelog/notifications`) and native notification ID (`timelog_timer_alarm`). The new `ReminderService` uses `flutter_local_notifications` plugin with a different notification ID (`1001`). No conflict.
6. **iOS-only target**: The brief states iOS only. Use iOS-specific initialization settings. Android config included minimally for compilation but not tested.
7. **First launch after enabling**: If user enables reminder at 09:00 for 08:00, the first notification fires the next day at 08:00 (expected behavior of daily repeat).
