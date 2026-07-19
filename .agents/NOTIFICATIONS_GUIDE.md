# Flutter Local Notifications — iOS Setup Guide & Troubleshooting

This document describes the full notification pipeline in this Flutter app, common pitfalls on iOS, and what must be in place for notification taps to work reliably.

---

## Architecture Overview

The app uses `flutter_local_notifications` for scheduling recurring reminder notifications. When a user taps a notification, the app should show a modal (ReminderActionSheet) regardless of whether the app was:

- In the **foreground** (active)
- In the **background** (suspended)
- **Terminated** (cold launch)

### The Flow

```
Notification tap (iOS native)
  → UNUserNotificationCenterDelegate.didReceive (AppDelegate.swift)
    → FlutterAppDelegate forwards to plugin
      → flutter_local_notifications calls onDidReceiveNotificationResponse (Dart)
        → Sets pendingReminderActionProvider
          → ref.listen in _MainShell triggers showModalBottomSheet
```

---

## Critical iOS Native Setup (AppDelegate.swift)

### 1. Set the delegate explicitly

```swift
UNUserNotificationCenter.current().delegate = self
```

**Where:** In `application(_:didFinishLaunchingWithOptions:)`, BEFORE `super.application(...)`.

**Why:** Without this, iOS has no delegate to deliver notification events to. Taps simply get swallowed. This is the #1 cause of "notification tap does nothing."

### 2. Implement willPresent (foreground display)

```swift
override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
) {
    completionHandler([.banner, .sound])
}
```

**Why:** iOS does NOT show notification banners when the app is in the foreground by default. Without this override, scheduled notifications are silently delivered but invisible to the user.

### 3. Implement didReceive (tap forwarding)

```swift
override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
) {
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
}
```

**Why:** This forwards the tap event to `FlutterAppDelegate`, which then passes it to `flutter_local_notifications` plugin. The plugin calls the Dart `onDidReceiveNotificationResponse` callback. Without `super`, the plugin never receives the tap.

---

## Dart-Side Setup (main.dart)

### Plugin Initialization

```dart
await reminderService.initialize(
  onNotificationTap: (payload) {
    final reminderId = parseReminderIdFromPayload(payload);
    if (reminderId != null) {
      // Persist so the value survives even if Dart is mid-resume
      SharedPreferences.getInstance().then((prefs) {
        prefs.setInt(kPendingReminderIdKey, reminderId);
      });
      // Also set provider for immediate foreground handling
      container.read(pendingReminderActionProvider.notifier).state = reminderId;
    }
  },
);
```

### Key Points

- The callback fires on the **main isolate** for foreground and background taps (iOS keeps Dart alive when backgrounded).
- For cold launch, use `getNotificationAppLaunchDetails()` to retrieve the payload.
- Always persist to SharedPreferences as a safety net — the provider alone may not survive edge cases.

---

## UI-Side Setup (app.dart — _MainShell)

### Showing the modal

The app uses two complementary mechanisms:

1. **`ref.listen`** on `pendingReminderActionProvider` — catches state changes when the widget tree is active.
2. **`didChangeAppLifecycleState(resumed)`** — reads from SharedPreferences on resume (covers case where provider change was missed during suspension).

### Why modal instead of Navigator.push?

`Navigator.push` requires `navigatorKey.currentState` to be non-null. When the app returns from background, there's a timing window where the navigator isn't ready. `showModalBottomSheet` uses the widget's own `context` which is always available — same pattern the timer uses for its description sheet.

---

## Common Pitfalls

| Problem | Cause | Fix |
|---------|-------|-----|
| Notification tap does nothing | `UNUserNotificationCenter.delegate` not set | Add `UNUserNotificationCenter.current().delegate = self` in AppDelegate |
| Notification doesn't show in foreground | Missing `willPresent` override | Implement it returning `[.banner, .sound]` |
| Tap works in foreground but not background | `didReceive` not calling `super` | Ensure `super.userNotificationCenter(center, didReceive:...)` is called |
| Navigator.push silently fails | `navigatorKey.currentState` is null during resume | Use `showModalBottomSheet` with widget context instead |
| Provider state change missed on resume | Widget tree inactive when state was set | Also persist to SharedPreferences + check on `resumed` lifecycle event |
| `getNotificationAppLaunchDetails` returns false | App was backgrounded, not terminated | This API only works for cold launch. Use `onDidReceiveNotificationResponse` for background |

---

## Differences: Timer vs Recurring Reminders

The timer "works from background" but uses a completely different mechanism:

- Timer has its own `Timer.periodic` running in Dart
- On resume, `TimerNotifier.didChangeAppLifecycleState(resumed)` recalculates time from persisted `endAt`
- Timer changes state to `logging` internally — no notification tap needed
- `TimerScreen` uses `ref.listen` on `timerProvider` to show the description sheet

The timer does NOT rely on notification tap callbacks at all. Its notification is just an alert — the state transition happens internally.

Recurring reminders have no internal timer. The ONLY trigger is the notification tap → callback → modal. That's why the native delegate setup is absolutely critical for them.

---

## Testing Checklist

When modifying notification behavior, verify ALL these scenarios:

- [ ] App in foreground → notification banner appears
- [ ] App in foreground → tap banner → modal appears
- [ ] App in background → tap notification → app resumes + modal appears
- [ ] App terminated → tap notification → app launches + modal appears
- [ ] Multiple rapid taps → only one modal opens (deduplication)
- [ ] Modal "Hotovo" → marks done, cancels remaining notifications for today
- [ ] Modal "Odložit" → dismisses modal, next scheduled notification still fires

### Quick Test Button

Settings screen has "Testovací notifikace (za 5 sekund)" for rapid iteration. Also "Zobrazit modal přímo (debug)" to verify the modal works independently of the notification pipeline.

---

## File Locations

| File | Responsibility |
|------|---------------|
| `ios/Runner/AppDelegate.swift` | Native notification delegate setup |
| `lib/services/reminder_service.dart` | Plugin initialization, `onNotificationTap` callback registration |
| `lib/services/recurring_reminder_service.dart` | Scheduling logic, payload format |
| `lib/main.dart` | Wires callback → provider + SharedPreferences |
| `lib/app.dart` | `_MainShell` — lifecycle observer + `ref.listen` → shows modal |
| `lib/ui/widgets/reminder_action_sheet.dart` | The modal UI (Done/Snooze) |
| `lib/providers/reminder_action_provider.dart` | `pendingReminderActionProvider` + action state |

---

## TL;DR

If notification taps stop working on iOS, check AppDelegate.swift first:

1. Is `UNUserNotificationCenter.current().delegate = self` set?
2. Is `willPresent` implemented (for foreground)?
3. Is `didReceive` calling `super` (for tap forwarding)?

These three lines are the foundation. Everything else is secondary.
