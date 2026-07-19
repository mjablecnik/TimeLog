# Flutter Local Notifications on iOS — Complete Setup Guide

A practical guide for setting up `flutter_local_notifications` on iOS so that:

- Notifications display when the app is in the foreground
- Tapping a notification triggers a Dart callback regardless of app state (foreground, background, terminated)

---

## The iOS Notification Delivery Model

iOS distinguishes three app states when a notification arrives or is tapped:

| App State | Notification Banner | Tap Delivery Mechanism |
|-----------|-------------------|----------------------|
| **Foreground** | NOT shown by default | `willPresent` delegate method |
| **Background** (suspended) | Shown | `didReceive` delegate method → Dart callback |
| **Terminated** | Shown | `getNotificationAppLaunchDetails()` on next launch |

Understanding this is critical. Most issues come from assuming all three states behave the same way.

---

## Required iOS Native Setup (AppDelegate.swift)

### 1. Set the notification center delegate

```swift
override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    UNUserNotificationCenter.current().delegate = self

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
```

**This is the most common source of bugs.** Without explicitly setting `delegate = self`, iOS has no object to deliver notification events to. Taps will silently do nothing.

### 2. Show notifications in foreground

```swift
override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
) {
    completionHandler([.banner, .sound])
}
```

Without this, scheduled notifications are delivered silently when the app is active — the user sees nothing.

### 3. Forward taps to the Flutter plugin

```swift
override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
) {
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
}
```

Calling `super` passes the tap event to `FlutterAppDelegate`, which routes it to `flutter_local_notifications`. The plugin then calls your Dart `onDidReceiveNotificationResponse` callback.

**If you forget `super`, the Dart callback will never fire for taps from background.**

---

## Dart-Side Plugin Initialization

```dart
await flutterLocalNotificationsPlugin.initialize(
  settings,
  onDidReceiveNotificationResponse: (response) {
    // Called when user taps notification (foreground + background)
    handleNotificationTap(response.payload);
  },
  onDidReceiveBackgroundNotificationResponse: backgroundHandler,
);
```

### Key rules:

- `onDidReceiveNotificationResponse` fires on the **main isolate** for both foreground and background taps (on iOS, the Dart isolate stays alive when backgrounded)
- `onDidReceiveBackgroundNotificationResponse` must be a **top-level function** — it runs in a separate isolate on Android (on iOS it's less relevant but still required to be registered)
- For **terminated app** taps, use `getNotificationAppLaunchDetails()` after initialization

---

## Handling the Terminated App Case

```dart
final details = await plugin.getNotificationAppLaunchDetails();
if (details?.didNotificationLaunchApp ?? false) {
  final payload = details!.notificationResponse?.payload;
  // Process the tap
}
```

### Warning: `getNotificationAppLaunchDetails` quirks on iOS

- Returns the same launch details on **every call** until the app is relaunched with a different intent
- Only returns `didNotificationLaunchApp = true` when the app was **terminated** — NOT when it was merely backgrounded
- You must deduplicate: track the last processed payload to avoid re-processing on hot restart or subsequent calls

---

## Common Pitfalls & Solutions

### Notification tap does nothing

**Cause:** `UNUserNotificationCenter.current().delegate` is not set.

**Fix:** Add `UNUserNotificationCenter.current().delegate = self` in `didFinishLaunchingWithOptions`, before `super.application(...)`.

### Notification doesn't appear when app is in foreground

**Cause:** iOS suppresses notification banners for the active app by default.

**Fix:** Implement `willPresent` returning `[.banner, .sound]`.

### Tap works in foreground but not from background

**Cause:** `didReceive` override is missing or doesn't call `super`.

**Fix:** Add the `didReceive` override and ensure it calls `super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)`.

### Callback fires but UI doesn't react

**Cause:** The Dart isolate may have been suspended when the callback fires. State changes to in-memory objects (providers, streams, variables) may be lost or arrive before the widget tree resumes rendering.

**Fix:** Persist the payload to `SharedPreferences` in the callback. On app resume (`didChangeAppLifecycleState == resumed`), read from SharedPreferences with `prefs.reload()` to get fresh data.

### Notification action triggers twice

**Cause:** Multiple detection paths (callback + lifecycle resume + launch details) all fire for the same tap.

**Fix:** Use a boolean guard (e.g. `_actionInProgress`) that blocks duplicate processing. Clear it when the resulting action completes (e.g. when a screen is popped).

### `getNotificationAppLaunchDetails` fires on every app start

**Cause:** iOS caches the launch intent. The API returns the same result repeatedly.

**Fix:** Store the last processed payload ID in SharedPreferences. Skip processing if it matches.

---

## Recommended Architecture

```
Notification tap (iOS native)
  → AppDelegate.didReceive (calls super)
    → FlutterAppDelegate forwards to plugin
      → onDidReceiveNotificationResponse (Dart callback)
        → Persist payload to SharedPreferences (safety net)
        → Set in-memory state (provider/stream/variable)
          → UI reacts and shows appropriate screen

App resume from background:
  → didChangeAppLifecycleState(resumed)
    → Read SharedPreferences (with reload())
      → If pending payload exists → clear it → show screen

Cold launch:
  → getNotificationAppLaunchDetails()
    → If didNotificationLaunchApp → process payload (deduplicated)
```

This triple-path approach covers all edge cases:
- **Provider/stream** handles the instant foreground case
- **SharedPreferences on resume** handles the case where the callback fires but UI doesn't react
- **Launch details** handles the terminated app case

---

## Comparing Internal Timers vs Notification Taps

If your app has features triggered by internal timers (countdown, alarms), those will "just work" from background because:

- The Dart `Timer` keeps running (or state is restored from persisted `endAt` on resume)
- State changes happen internally — no external callback dependency
- The notification is just an alert; the logic doesn't depend on the user tapping it

Features that rely **solely** on notification taps (like "confirm task completion") are fundamentally different:
- There is no internal trigger — the ONLY entry point is the tap callback
- If the native delegate setup is broken, there is zero fallback
- This makes the `AppDelegate.swift` setup absolutely critical for these features

---

## Minimal AppDelegate.swift Template

```swift
import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        UNUserNotificationCenter.current().delegate = self
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Show notification banners even when app is in foreground
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    // Forward notification taps to flutter_local_notifications plugin
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }
}
```

---

## Quick Checklist

- [ ] `UNUserNotificationCenter.current().delegate = self` in AppDelegate
- [ ] `willPresent` override returns `[.banner, .sound]`
- [ ] `didReceive` override calls `super`
- [ ] Dart plugin initialized with `onDidReceiveNotificationResponse`
- [ ] Cold launch handled via `getNotificationAppLaunchDetails()`
- [ ] Launch details deduplicated (not processed twice)
- [ ] Payload persisted to SharedPreferences as fallback
- [ ] Resume lifecycle checks SharedPreferences with `reload()`
- [ ] Guard against duplicate action triggers

---

## TL;DR

If notification taps aren't working on iOS, check `AppDelegate.swift` first. Three lines solve 90% of problems:

1. `UNUserNotificationCenter.current().delegate = self`
2. `willPresent` → `completionHandler([.banner, .sound])`
3. `didReceive` → `super.userNotificationCenter(...)`

Everything else is secondary.
