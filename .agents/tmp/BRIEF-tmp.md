# Daily Timer Reminder — Local Notification

## What We Want

Add a daily local notification that reminds the user to start the timer at a configured time (default 8:00). When the user taps the notification, the app opens and automatically starts the timer. The feature is configurable — the user can enable/disable it and change the reminder time in settings.

## Why

The user wants to build a habit of starting the timer every morning without having to remember manually. Since iOS does not allow background auto-start of app logic at a scheduled time, a local notification is the closest reliable solution.

## Behavior

1. **Default state:** Notification disabled (opt-in)
2. **When enabled:** A repeating daily notification is scheduled at the configured time (default 08:00)
3. **Notification content:** Title: "TimeLog", Body: "Time to start your timer!" (in English, matching Requirement 10)
4. **On tap:** App opens → timer starts automatically (if idle)
5. **Settings:** Toggle on/off + time picker for reminder hour/minute
6. **Persistence:** Enabled state and time are persisted locally (SharedPreferences / UserDefaults)
7. **Permission:** On first enable, request iOS notification permission. If denied, show explanation and disable the toggle.

## Implementation Plan

### Step 1: Add Dependencies

Add to `pubspec.yaml`:
- `flutter_local_notifications` — scheduling and displaying local notifications
- `flutter_timezone` — correct timezone for scheduled notifications
- `permission_handler` (optional) — if not already handling notification permissions

### Step 2: Notification Service

Create a `NotificationService` class responsible for:
- Initializing the notification plugin on app start
- Requesting notification permissions (iOS)
- Scheduling a daily repeating notification at a specific time (`zonedSchedule` with `matchDateTimeComponents: DateTimeComponents.time`)
- Cancelling the scheduled notification when disabled
- Handling notification tap callback (payload indicating "start timer")

Key method signatures:
```dart
class NotificationService {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<void> scheduleDailyReminder(TimeOfDay time);
  Future<void> cancelReminder();
  Future<void> handleNotificationTap(String? payload);
}
```

### Step 3: iOS Platform Configuration

- Add `UNUserNotificationCenter` capability in Xcode (already implicit with flutter_local_notifications)
- In `AppDelegate.swift`, configure notification categories if needed
- Ensure `Info.plist` has no missing keys for notification support

### Step 4: Settings UI

Add a "Reminder" section to settings (or a new settings screen if none exists):
- Toggle: "Daily reminder" (on/off)
- Time picker: Appears when toggle is on, defaults to 08:00
- When toggled on → request permission → schedule notification
- When toggled off → cancel notification
- When time changed → cancel old + schedule new

### Step 5: Auto-Start on Notification Tap

When the app opens via notification tap:
1. Check notification payload (e.g., `"action": "start_timer"`)
2. If timer is idle → automatically start the timer
3. If timer is already running/paused → do nothing (just open the app)

This hooks into the existing `Timer_Service` from Requirement 1.

### Step 6: Persistence

Store in SharedPreferences (or equivalent):
- `reminder_enabled` (bool)
- `reminder_hour` (int)
- `reminder_minute` (int)

On app launch, if `reminder_enabled == true`, re-schedule the notification (iOS may clear scheduled notifications after app update or reboot).

### Step 7: Edge Cases

- **Permission denied:** Disable toggle, show explanation text
- **App update / device reboot:** Re-schedule on next app launch (Step 6 handles this)
- **Time zone change:** `flutter_timezone` + `TZDateTime` ensures correct local time
- **Notification while timer running:** Notification still fires (it's a reminder, user can ignore it)

## Out of Scope

- Snooze functionality
- Multiple reminders per day
- Weekday-only scheduling (could be added later)
- Android support (project targets iOS only per Requirement 10)
