# Implementation Plan: Recurring Reminders

## Overview

This plan implements a Recurring Reminders system for the TimeLog Flutter app. The approach is bottom-up: database layer first, then scheduling service, then state management (providers), then UI screens. Each task builds on the previous, ensuring no orphaned code. Property-based tests validate correctness properties from the design using `dart_check`.

## Tasks

- [x] 1. Set up database tables and migration
  - [x] 1.1 Create RecurringReminders and CompletionRecords Drift table definitions
    - Create `lib/data/recurring_reminder.dart` with the `RecurringReminders` table class (id, name, description, startTime, endTime, repeatInterval, activeDays, isActive)
    - Create `lib/data/completion_record.dart` with the `CompletionRecords` table class (id, reminderId as FK to RecurringReminders with cascade delete, completionDate, completionTimestamp)
    - _Requirements: 9.1, 9.2, 9.3_

  - [x] 1.2 Register tables and add migration to AppDatabase
    - Add both new tables to the `@DriftDatabase(tables: [...])` annotation in `lib/data/database.dart`
    - Increment `schemaVersion` from 5 to 6
    - Add migration logic in `onUpgrade`: if `from < 6`, create `recurringReminders` and `completionRecords` tables
    - Run `dart run build_runner build` to regenerate Drift code
    - _Requirements: 9.1, 9.2, 9.3_

  - [x] 1.3 Implement database CRUD and query methods
    - Add to AppDatabase: `getAllReminders()` returning ordered by startTime ascending, `watchAllReminders()` stream, `insertReminder()`, `updateReminder()`, `deleteReminder()`, `getReminderById()`
    - Add completion record methods: `insertCompletionRecord()`, `hasCompletionForToday()`, `deleteCompletionForToday()`, `getCompletionsByReminder()`, `getCompletionsByDateRange()`
    - Enforce uniqueness constraint of one completion record per reminder per date
    - _Requirements: 1.1, 1.5, 1.7, 8.1, 8.2, 8.3, 8.4, 9.4_

  - [ ]* 1.4 Write property test: Reminder list ordering by start time
    - **Property 1: Reminder list ordering by start time**
    - **Validates: Requirements 1.1**

  - [ ]* 1.5 Write property test: Reminder data round-trip preservation
    - **Property 2: Reminder data round-trip preservation**
    - **Validates: Requirements 1.5, 9.1**

  - [ ]* 1.6 Write property test: Cascade delete removes all associated completion records
    - **Property 3: Cascade delete removes all associated completion records**
    - **Validates: Requirements 1.7, 8.3, 9.3**

  - [ ]* 1.7 Write property test: Date range query returns correct records in order
    - **Property 15: Date range query returns correct records in order**
    - **Validates: Requirements 8.4**

- [x] 2. Implement active days bitmask utilities and form validation
  - [x] 2.1 Create bitmask encode/decode helpers and form validation
    - Add `dart_check` to `dev_dependencies` in `pubspec.yaml`
    - Create `lib/services/active_days_utils.dart` with `encodeDays()`, `decodeDays()`, and `isDayActive()` functions as defined in the design
    - Create `lib/ui/widgets/reminder_form_data.dart` with `ReminderFormData` class including `isValid` getter (name not blank, activeDays not empty) and `toCompanion()` method
    - _Requirements: 2.1, 2.2, 2.5, 2.7, 9.1, 13.1_
    - Note: skipped adding `dart_check` to `pubspec.yaml` — it does not exist on pub.dev (see `.agents/MEMORY.md`), so 2.2's property test is also skipped (both are optional, marked `*`).

  - [ ]* 2.2 Write property test: Whitespace-only name invalidates form
    - **Property 4: Whitespace-only name invalidates form**
    - **Validates: Requirements 2.2**

- [x] 3. Implement RecurringReminderService (scheduling engine)
  - [x] 3.1 Create RecurringReminderService with notification time computation
    - Create `lib/services/recurring_reminder_service.dart`
    - Implement `computeUpcomingNotificationTimes()` with interval-grid alignment logic that returns all notification times within the next 6 hours from current time (within the Time_Window)
    - Implement `isActiveDay()` using bitmask utility
    - Define `notificationIdOffset = 2000` and `getNotificationId(reminderId, slotIndex)` using formula `(reminderId × 100) + slotIndex + 2000`
    - _Requirements: 4.1, 4.2, 4.3, 4.5, 4.6, 4.7_

  - [x] 3.2 Implement notification scheduling, cancellation, and rescheduling
    - Implement `scheduleUpcoming()` using `flutter_local_notifications` `zonedSchedule()` to batch-schedule all notifications within the next 6 hours for a reminder's Time_Window
    - Implement deduplication: before scheduling, check if a notification with the same reminder ID and time is already pending; skip if so
    - Enforce a maximum of 50 total scheduled notifications across all reminders; prioritize by earliest start time if limit exceeded
    - Implement `cancelReminder()` to cancel all pending notifications for a reminder by computed notification IDs (iterate all possible slot indices for the reminder)
    - Implement `rescheduleAll()` for app launch: query active reminders without today's completion, compute upcoming times, schedule each (with deduplication)
    - Use notification ID formula: `(reminderId × 100) + slotIndex + 2000` to support multiple notifications per reminder
    - _Requirements: 3.2, 3.3, 4.1, 4.2, 4.4, 10.1, 10.2, 10.3, 11.3, 14.1, 15.1_

  - [x] 3.3 Implement notification content construction and permission handling
    - Set notification title = reminder name, body = description or "Klepni pro otevření" if empty/null (Czech localization)
    - Configure Android notification channel: id `recurring_reminders`, name "Recurring Reminders", high importance/priority
    - Implement `requestPermission()` and `hasPermission()` methods
    - Define notification payload format: `"recurring_reminder:<id>"`
    - Implement `parseReminderIdFromPayload()` utility
    - Accept `FlutterLocalNotificationsPlugin` as a constructor dependency (shared instance from existing ReminderService)
    - Register a top-level `@pragma('vm:entry-point')` background notification response handler for taps when app is terminated
    - _Requirements: 5.1, 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 14.1, 15.1_
    - Note: `ReminderService` now exposes its `FlutterLocalNotificationsPlugin` via a `plugin` getter and registers `recurringReminderBackgroundHandler` as `onDidReceiveBackgroundNotificationResponse` in its single `initialize()` call, so the whole app still only calls `FlutterLocalNotificationsPlugin.initialize()` once. Actually constructing `RecurringReminderService(reminderService.plugin, db)` and wiring its navigation callbacks into `main.dart` is deferred to task 7 (app launch/navigation wiring), which is the task that owns that integration point.

  - [ ]* 3.4 Write property test: Overnight window duration computation
    - **Property 5: Overnight window duration computation**
    - **Validates: Requirements 2.3, 4.7**

  - [ ]* 3.5 Write property test: Notification times aligned to interval grid
    - **Property 6: Notification times aligned to interval grid**
    - **Validates: Requirements 4.1, 4.2, 4.3**

  - [ ]* 3.6 Write property test: No scheduling past window end
    - **Property 7: No scheduling past window end**
    - **Validates: Requirements 4.3**

  - [ ]* 3.7 Write property test: No scheduling on non-active day
    - **Property 8: No scheduling on non-active day**
    - **Validates: Requirements 4.5**

  - [ ]* 3.8 Write property test: No scheduling for inactive reminders
    - **Property 9: No scheduling for inactive reminders**
    - **Validates: Requirements 3.4**

  - [ ]* 3.9 Write property test: Notification content construction
    - **Property 10: Notification content construction**
    - **Validates: Requirements 5.1**

  - [ ]* 3.10 Write property test: Completion record contains correct date and timestamp
    - **Property 11: Completion record contains correct date and timestamp**
    - **Validates: Requirements 6.2, 8.1**

  - [ ]* 3.11 Write property test: Completion record blocks further scheduling
    - **Property 12: Completion record blocks further scheduling**
    - **Validates: Requirements 6.4, 10.2**

  - [ ]* 3.12 Write property test: Snooze dismisses without scheduling
    - **Property 13: Snooze dismisses without scheduling**
    - **Validates: Requirements 7.1, 7.2**

  - [ ]* 3.13 Write property test: Notification ID uniqueness across batch
    - **Property 14: Notification ID uniqueness across batch**
    - **Validates: Requirements 11.3**
    - Note: properties 5-14 (3.4-3.13) remain skipped like 2.2 — `dart_check` isn't on pub.dev (see `.agents/MEMORY.md`) and all are marked optional. Added a plain unit test suite instead (`test/recurring_reminder_service_test.dart`) covering the grid alignment, overnight-window, past-window, inactive-day/reminder, completed-today, notification ID uniqueness, and content-construction behavior these properties describe.

  - [x] 3.14 Add custom notification sound file to iOS and Android bundles
    - Place a custom reminder notification sound file (e.g., `reminder_sound.caf` or `.aiff`) in `ios/Runner/` for the iOS app bundle
    - Place the same sound (converted to supported format) in `android/app/src/main/res/raw/reminder_sound.ogg` (or `.mp3`/`.wav`) for the Android notification channel
    - Sound duration MUST be ≤ 30 seconds (iOS local notification limit)
    - Sound MUST be audibly distinct from the existing timer alarm sound used by the Alarm_Service
    - _Requirements: 17.2, 17.3, 17.4, 17.5_
    - Note: used `.wav` (an iOS-supported local-notification format alongside AIFF/CAF, generated with a stdlib-only Python script since ImageMagick/ffmpeg aren't available — see `.agents/MEMORY.md`'s icon-generation precedent) at `ios/Runner/reminder_sound.wav` and `android/app/src/main/res/raw/reminder_sound.wav`: a two-note ascending chime (~0.43s), clearly distinct from `alarm.mp3`'s continuous loop tone. Registered the iOS file in `project.pbxproj` (file reference + Runner group + Resources build phase) following the existing `alarm.caf` pattern.

  - [x] 3.15 Configure flutter_local_notifications to use custom sound for recurring reminders
    - Update `scheduleUpcoming()` in `RecurringReminderService` to set the iOS notification sound to `reminder_sound.caf` (or the chosen filename) using `DarwinNotificationDetails(sound: 'reminder_sound.caf')`
    - If the sound file fails to load at notification time, iOS will automatically fall back to the default notification sound (built-in iOS behavior)
    - Update the Android notification channel configuration (channel id `recurring_reminders`) to reference the custom sound resource (`RawResourceAndroidNotificationSound('reminder_sound')`) for future Android platform support
    - Ensure the custom sound is distinct from the timer alarm sound referenced in the Alarm_Service
    - _Requirements: 17.1, 17.5, 17.6_

- [x] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
  - Verified: `flutter test` (33/33 pass) and `flutter analyze` (no issues) both clean as of this checkpoint.

- [x] 5. Implement Riverpod providers
  - [x] 5.1 Create RecurringRemindersNotifier provider
    - Create `lib/providers/recurring_reminders_provider.dart`
    - Implement `AsyncNotifier<List<RecurringReminder>>` with `build()` watching all reminders
    - Implement `addReminder()`, `updateReminder()`, `deleteReminder()`, `toggleActive()` methods
    - Implement `markDoneForToday()`: insert CompletionRecord, cancel remaining notifications for today
    - Implement `undoCompletionForToday()`: delete CompletionRecord for today, reschedule notifications within 6-hour lookahead
    - On add/update: persist to DB then call service to schedule/reschedule
    - On delete: persist to DB then cancel notifications
    - On toggle: update DB, schedule or cancel based on new state; revert on failure
    - _Requirements: 1.1, 1.3, 1.4, 1.5, 1.7, 1.8, 1.11, 3.1, 3.2, 3.3, 3.5_

  - [x] 5.2 Create ReminderActionNotifier provider
    - Create `lib/providers/reminder_action_provider.dart`
    - Implement `StateNotifier<ReminderActionState>` with `ReminderActionState` (reminder, isLoading, error)
    - Implement `markDone()`: insert completion record, cancel today's notifications, handle DB failure by showing error without dismissing
    - Implement `snooze()`: simply dismiss the screen (next notification is already pre-scheduled via batch scheduling)
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 7.1, 7.2, 7.3_

- [ ] 6. Implement UI screens and widgets
  - [ ] 6.1 Create DaySelectorWidget
    - Create `lib/ui/widgets/day_selector.dart`
    - Multi-select weekday chips (Mon–Sun) using abbreviated names
    - Accept and emit `Set<int>` (1=Monday, 7=Sunday)
    - Use theme colors from `themeProvider`
    - _Requirements: 2.1, 2.5, 12.1_

  - [ ] 6.2 Create ReminderEditDialog
    - Create `lib/ui/widgets/reminder_edit_dialog.dart`
    - Fields: name (max 100 chars, input prevented beyond limit), description (max 300 chars, input prevented beyond limit), start time picker, end time picker, repeat interval selection (30/60/120/180/240), day selector widget, active toggle
    - Default values for new: startTime 08:00, endTime 00:00, interval 60, all days, active true
    - Pre-fill values when editing existing reminder
    - Disable save when name is blank/whitespace or no days selected
    - Show overnight window indicator when start ≥ end
    - Show unsaved-changes confirmation on cancel/outside tap
    - Use existing app dialog styling and themeProvider
    - _Requirements: 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 12.2_

  - [ ] 6.3 Create ReminderCard widget
    - Create `lib/ui/widgets/reminder_card.dart`
    - Display: name, time window "HH:mm – HH:mm", interval in minutes, abbreviated active days, active/inactive toggle
    - Display today's completion status with a checkbox (checked = done for today, unchecked = not done)
    - Checkbox tap calls provider's `markDoneForToday()` or `undoCompletionForToday()` depending on current state
    - Edit button and delete button on each card
    - Toggle calls provider's `toggleActive()`
    - Use Sora for labels, JetBrains Mono for time/interval values
    - Visually differentiate completed reminders (e.g., muted colors, strikethrough, or checkmark overlay)
    - _Requirements: 1.2, 1.3, 1.4, 1.5, 3.1, 12.1_

  - [ ] 6.4 Create ReminderSettingsScreen
    - Create `lib/ui/screens/reminder_settings_screen.dart`
    - Display list of reminders from `recurringRemindersProvider`, ordered by start time
    - Each reminder shows today's completion status (checkbox) — checked if Completion_Record exists for today
    - Checkbox tap toggles completion: mark done or undo completion
    - Empty state: message + prompt to create first reminder
    - Add button opens `ReminderEditDialog` for creation
    - Edit button opens `ReminderEditDialog` pre-filled
    - Delete button shows confirmation dialog with reminder name, on confirm calls provider's `deleteReminder()`
    - Error handling: show error messages on failed operations, retain previous state
    - Accessible as sub-screen within existing Settings tab
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 1.10, 1.11, 1.12, 12.4_

  - [ ] 6.5 Create ReminderActionScreen
    - Create `lib/ui/screens/reminder_action_screen.dart`
    - Display reminder name, description, "Done" button, "Snooze" button
    - Done: calls provider `markDone()`, dismisses screen on success, shows error without dismissing on failure
    - Snooze: calls provider `snooze()`, dismisses screen
    - If reminder was deleted: navigate to ReminderSettingsScreen
    - On dismiss with no history: navigate to Timer_Screen (home)
    - Use card styling, background color, and button appearance matching Timer_Screen
    - _Requirements: 5.2, 5.3, 5.4, 5.5, 5.6, 6.1, 6.2, 6.3, 6.5, 7.1, 7.2, 12.3_

- [ ] 7. Wire notification tap navigation and app launch rescheduling
  - [ ] 7.1 Implement notification tap routing and app launch integration
    - Configure `flutter_local_notifications` initialization to handle notification tap callbacks
    - Parse payload with `parseReminderIdFromPayload()`
    - On tap: if reminder exists in DB, navigate to ReminderActionScreen; if deleted, navigate to ReminderSettingsScreen
    - Handle cold launch: after app initialization, check for launch notification payload and navigate accordingly
    - Handle foreground/background tap: navigate to ReminderActionScreen
    - Call `rescheduleAll()` on app launch within the existing app initialization flow
    - Ensure rescheduling completes within 5 seconds
    - _Requirements: 5.4, 5.5, 5.6, 10.1, 10.2, 10.3, 10.4_

  - [ ] 7.2 Register navigation entry point in Settings
    - Add "Recurring Reminders" option to the existing Settings screen that navigates to `ReminderSettingsScreen`
    - Use Czech labels consistent with the existing Settings screen (e.g., 'Opakované připomínky' as the navigation entry)
    - _Requirements: 12.4_

- [ ] 8. Apply theme consistency
  - [ ] 8.1 Ensure all reminder screens consume themeProvider
    - Verify ReminderSettingsScreen, ReminderEditDialog, ReminderActionScreen, ReminderCard, and DaySelector all consume colors from `themeProvider`
    - Validate immediate re-render on theme switch (Ember, Midnight, Paper) without re-navigation
    - _Requirements: 12.1, 12.2, 12.3, 12.5, 12.6_

- [ ] 9. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document using `dart_check`
- Unit tests validate specific examples and edge cases
- The implementation language is Dart (Flutter) as specified in the design

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["1.2"] },
    { "id": 2, "tasks": ["1.3", "2.1"] },
    { "id": 3, "tasks": ["1.4", "1.5", "1.6", "1.7", "2.2", "3.1"] },
    { "id": 4, "tasks": ["3.2", "3.3", "3.4", "3.5", "3.6", "3.7", "3.8", "3.9", "3.10", "3.11", "3.12", "3.13", "3.14"] },
    { "id": 5, "tasks": ["3.15", "5.1", "5.2"] },
    { "id": 6, "tasks": ["6.1", "6.3"] },
    { "id": 7, "tasks": ["6.2", "6.4", "6.5"] },
    { "id": 8, "tasks": ["7.1", "7.2"] },
    { "id": 9, "tasks": ["8.1"] }
  ]
}
```
