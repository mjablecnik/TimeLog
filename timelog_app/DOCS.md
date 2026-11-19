# TimeLog — Developer Documentation

## Configuration

TimeLog has no environment variables and no server-side configuration — it's a fully local,
offline Flutter app. Runtime configuration lives in code and in on-device storage:

- `lib/core/config.dart` (`TimerConfig`) — hard limits for the timer duration (1–1440 minutes,
  default 20). Note that the Timer screen's UI further restricts adjustment to 5–60 minutes
  in 5-minute steps (`_minDurationMinutes` / `_maxDurationMinutes` / `_durationStep` in
  `lib/ui/screens/timer_screen.dart`) — the two ranges are independent.
- `shared_preferences` keys (device-local, no cloud sync): selected theme, in-progress timer
  state (for restoring a running/paused timer after app restart), last-used activity type and
  the last-used subtype of each type (`last_activity_type`, `last_subtype_<type>`),
  pre-filled description/type/subtype/name for the next log entry, the name suggestions
  (`known_names_v3_<scope>`: one list per category — paid work, unpaid work, housework, other),
  and daily-reminder settings (`reminder_enabled`, `reminder_hour`, `reminder_minute` — see
  `lib/providers/reminder_provider.dart`).

## Project Structure

```
timelog_app/
  lib/
    app.dart                       # Root widget: MaterialApp + bottom-nav shell (Timer, Tasks, Stats, Settings)
    main.dart                      # Entry point, requests notification permission
    core/
      activity_types.dart          # Activity registry: 12 types, subtypes, labels, colours, suggestion scopes
      config.dart                  # TimerConfig (duration limits)
      extensions.dart              # DateTime/Duration/int formatting helpers
      platform_channel.dart        # MethodChannel name constants
      theme.dart                   # AppThemeData + Ember/Midnight/Paper theme definitions
    data/
      time_entry.dart              # Drift TimeEntries table definition (project, subtype, customName columns)
      database.dart                # AppDatabase (Drift), schema migrations (schemaVersion 8)
      database.g.dart              # Generated (build_runner) — do not hand-edit
      stats_data.dart              # StatsPeriod enum + StatsData aggregation model (by type, subtype, project, custom name)
    providers/
      database_provider.dart       # AppDatabase / DatabaseService providers
      history_provider.dart        # Selected day + day's entries stream
      reminder_provider.dart       # ReminderSettings state, persistence, and scheduling via ReminderService
      statistics_provider.dart     # Selected period/date state + computed StatsData for the range
      theme_provider.dart          # Persisted theme selection
      timer_provider.dart          # Wires TimerNotifier with its service dependencies
    services/
      timer_service.dart           # TimerNotifier/TimerState — core timer state machine
      timer_service.freezed.dart   # Generated (build_runner) — do not hand-edit
      database_service.dart        # CRUD + queries against the Drift database
      alarm_service.dart           # Alarm sound playback (audioplayers)
      notification_service.dart   # Native local notification channel (timer-completion alert)
      reminder_service.dart        # Daily reminder scheduling via flutter_local_notifications
      live_activity_channel.dart  # iOS Live Activity channel
      project_service.dart         # Stores/retrieves remembered names per suggestion category (shared_preferences)
    ui/
      screens/
        timer_screen.dart          # Countdown timer, duration adjuster, ringing overlay
        history_screen.dart        # Day navigator + list of logged entries
        statistics_screen.dart     # Daily/weekly period toggle, timeline, activity-type and project breakdowns
        settings_screen.dart       # Daily reminder toggle + time picker
      widgets/                     # bottom_nav, day_navigator, day_summary, description_sheet,
                                    # duration_adjuster, edit_sheet, empty_state,
                                    # history_entry_card, manual_entry_sheet, ringing_overlay,
                                    # theme_dots, timer_controls, project_selector, ...
        activity_picker/           # Shared type picker of the entry sheets: type chips, subtype
                                    # block, project / custom name field with suggestions
      painters/
        ring_painter.dart          # CustomPainter for the countdown progress ring
        bar_painter.dart           # CustomPainters for the statistics bars (plain and stacked by subtype)
        timeline_painter.dart      # CustomPainter for the statistics daily/weekly entry timeline
  test/
    timer_service_test.dart        # TimerNotifier state-machine unit tests
    widget_test.dart               # App smoke test
  android/, ios/, linux/, macos/, windows/, web/   # Platform embedding shells
  ios/Runner/LiveActivityManager.swift             # Live Activity lifecycle (iOS side)
  ios/TimeLogWidgetExtension/                      # Live Activity / Dynamic Island UI (WidgetKit)
  assets/                          # Alarm sound (audio/alarm.mp3), Sora + JetBrainsMono fonts,
                                    # app icon source images (icon/)
```

## Architecture

- **State management**: `flutter_riverpod`. `StateNotifierProvider`s (`timerProvider`,
  `themeProvider`) hold mutable app state; plain `Provider`/`FutureProvider`s wire up
  services (database, alarm, notifications, live activity).
- **Persistence**: `drift` (SQLite) for time entries (`lib/data/database.dart`), and
  `shared_preferences` for lightweight key-value state (theme, in-flight timer state, known
  project names).
- **Activity types and subtypes**: `lib/core/activity_types.dart` holds the registry that
  defines every type, its subtypes, labels and colours — see "Activity Types" below.
- **Projects, names & statistics**: `Práce` and `Domácí práce` entries carry an optional
  `project`; `Ostatní` entries carry a `customName`. `StatisticsScreen` aggregates entries over
  a daily/weekly range (`statisticsProvider`) into totals by activity type (with a stacked bar
  and one row per subtype), by project and by custom name, plus an untracked-time figure derived
  from an assumed 16 waking hours/day. It also renders a `TimelinePainter` bar showing
  entries laid out against a (self-widening) hour range, for the day or week in view.
- **Daily reminder**: `ReminderService` (`lib/services/reminder_service.dart`) schedules a
  repeating local notification via `flutter_local_notifications` + `timezone`, independent of
  the native `NotificationService` used for timer-completion alerts. `ReminderProvider`
  persists the enabled flag and time-of-day to `SharedPreferences` and drives scheduling;
  `SettingsScreen` exposes the toggle and time picker. On launch, `main.dart` re-schedules the
  reminder if it was left enabled, and auto-starts the timer if the app was cold-launched by
  tapping the reminder notification (payload `ReminderService.startTimerPayload`).
- **Timer state machine**: `TimerNotifier` (`lib/services/timer_service.dart`) drives
  `TimerStatus` (`idle → running ⇄ paused → ringing/logging → idle`) and persists enough
  state to `SharedPreferences` to restore a running/paused timer after the app is killed
  and relaunched, recalculating remaining time from a stored `endAt` timestamp.
- **Native platform channels** — the app talks to native (Swift/Kotlin) code over two
  `MethodChannel`s (defined in `lib/core/platform_channel.dart`); see "Platform Channels"
  below for details.

## Activity Types

Entries are classified by one of twelve main types, each with an optional list of subtypes
(`lib/core/activity_types.dart`, the `activityRegistry`):

| Type (stored key) | Subtypes | Extra field |
|---|---|---|
| Work (`Práce`) | paid, unpaid | project |
| Housework (`Domácí práce`) | – | project |
| Meeting (`Meeting`) | – | – |
| Communication (`Komunikace`) | – | – |
| Travel (`Přesun`, formerly "Commute") | – | – |
| Entertainment (`Zábava`) | active, passive | – |
| Exercise (`Cvičení`) | walk, running, gym | – |
| Self-development (`Seberozvoj`) | books, study, AI consultation | – |
| Rest (`Odpočinek`) | active, passive | – |
| Hygiene (`Hygiena`) | general, toilet | – |
| Meal (`Jídlo`) | breakfast, lunch, dinner, snack | – |
| Other (`Ostatní`) | – | custom name |

- The stored keys (`time_entries.activity_type`, `time_entries.subtype`) are stable identifiers
  and are never translated; labels come from the localization files (`activityTypeLabel`,
  `subtypeLabel`).
- Colours are never stored. `activityEntryColor(type, subtype, isDark:)` gives the subtype colour,
  falling back to the type colour and then to grey. Subtypes share the hue of their type and
  differ in shade. Paper (the light theme) uses its own, darker values.
- A subtype is always preselected in the entry sheets (the last used one for that type, otherwise
  the first), so saving is never blocked by a missing choice.
- Name suggestions are separate for four categories — paid work, unpaid work, housework and other
  (`SuggestionScope`). The Timer tab (entry sheets) and the Tasks tab (the project dialog) read
  the same lists through `suggestionsProvider`. A Tasks project carries a category chosen when it
  is created; long-press on a project chip opens a menu to change it or to delete the project.
- To add a type or subtype: add it to the registry, add its labels to `app_en.arb` and
  `app_cs.arb`, run `flutter gen-l10n`, and keep the preview pages in `.design/` in sync.

## Platform Channels

There is no network API — the app is fully offline. The only "API surface" is the
`MethodChannel` boundary between Dart and native platform code.

### `com.jablecnik.timelog/notifications`

Used by `lib/services/notification_service.dart` to fire a local notification when the
timer finishes, so the alarm still surfaces while the app is backgrounded.

| Method | Arguments | Returns | Purpose |
|---|---|---|---|
| `requestPermission` | — | `bool` | Request OS notification permission (call once at startup) |
| `scheduleNotification` | `{ endAtMs: int }` | — | Schedule a notification to fire at the given epoch-ms timestamp |
| `cancelNotification` | — | — | Cancel any pending timer notification (on pause/stop) |

### `com.jablecnik.timelog/live_activity`

Used by `lib/services/live_activity_channel.dart`. iOS-only; implemented in
`ios/Runner/LiveActivityManager.swift` (requires iOS 16.2+, guarded by
`ActivityAuthorizationInfo().areActivitiesEnabled`). Calls no-op on unsupported platforms.

| Method | Arguments | Returns | Purpose |
|---|---|---|---|
| `startLiveActivity` | `{ endAt: int, totalSeconds: int }` | `bool` | Start a Live Activity showing the countdown |
| `updateLiveActivity` | `{ action: 'pause'\|'resume'\|'complete', endAt?: int }` | — | Update the running activity's state |
| `endLiveActivity` | `{}` | — | End the current Live Activity |
| `areActivitiesEnabled` | `{}` | `bool` | Check whether the user has Live Activities enabled |

The native side calls back into Dart via `onLockScreenAction` (`{ action, endAtMs? }`) when
the user taps a pause/resume/stop button on the lock-screen widget.

## Deployment

There is no hosted backend to deploy — "deployment" means producing a release build per
platform:

```sh
flutter build apk --release          # Android APK
flutter build appbundle --release    # Android App Bundle (Play Store)
flutter build ios --release          # iOS (requires Xcode + signing setup)
flutter build linux --release        # Linux desktop bundle
flutter build macos --release        # macOS app bundle
flutter build windows --release      # Windows desktop bundle
flutter build web --release          # Web bundle
```

iOS builds that include the Live Activity widget extension (`TimeLogWidgetExtension`) must
be archived/signed through Xcode (`ios/Runner.xcworkspace`) rather than the CLI alone.

App launcher icons (Android + iOS) are generated from `assets/icon/app_icon.png` /
`app_icon_foreground.png` via `flutter_launcher_icons` (config in `pubspec.yaml`). Re-run
after changing the source images:

```sh
dart run flutter_launcher_icons
```

## Testing

Run the full test suite:

```sh
flutter test
```

Run a single test file:

```sh
flutter test test/timer_service_test.dart
```

- `test/timer_service_test.dart` — unit tests for the `TimerNotifier` state machine
  (start/pause/resume/stop/finish transitions), with platform channels mocked.
- `test/widget_test.dart` — smoke test that boots `TimeLogApp` against an in-memory Drift
  database and asserts the bottom navigation renders.
- `test/edit_sheet_time_validation_test.dart` — validates end-time-after-start-time on the
  edit sheet and that a valid edit persists.
- `test/description_sheet_prefill_cancel_test.dart` — canceling the description-prefill sheet
  discards text and resumes the timer without leaving stale state.
- `test/settings_screen_permission_test.dart` — denying the notification permission keeps the
  reminder toggle off and never schedules a reminder.
- `test/reminder_provider_test.dart` — unit tests for `ReminderProvider` state, persistence to
  `SharedPreferences`, and scheduling/canceling via `ReminderService`.
- `test/manual_entry_sheet_test.dart` — validates the manual history entry sheet's default
  times, time-order validation, and that a successful submission inserts a `TimeEntries` row.

## Troubleshooting

- **App crashes on startup on Linux when the timer finishes / alarm plays**: install the
  GStreamer runtime plugins (`gstreamer1.0-plugins-base`, `gstreamer1.0-plugins-good`), not
  just the `-dev` headers. See Prerequisites in [README.md](README.md).
- **Live Activity / Dynamic Island never appears on iOS**: requires iOS 16.2+ and the user
  must have Live Activities enabled for the app in Settings. `startLiveActivity` returns
  `false` and the app silently continues without it — this is expected, not an error.
- **Timer doesn't resume correctly after force-quitting the app**: `TimerNotifier` restores
  state from `SharedPreferences` on next launch by recalculating remaining time from the
  persisted `endAt` timestamp; if the timer had already elapsed while the app was closed, it
  comes back in the `ringing` state instead of `running`.
- **Schema changes to `TimeEntries` don't take effect**: bump `schemaVersion` and add an
  `onUpgrade` migration step in `lib/data/database.dart`, then regenerate with
  `dart run build_runner build --delete-conflicting-outputs`. Tables created by an earlier
  step (`createTable`) already contain the current columns, so a later step must not add such a
  column again (see the guard for `task_projects.scope` in the version 8 step).
- **App crashes on startup on desktop (Linux/Windows/macOS) when a reminder is scheduled**:
  `flutter_local_notifications` requires per-platform `InitializationSettings` (Linux, Windows,
  macOS, not just Android/iOS) to be passed to `ReminderService.initialize`; all five are
  configured. On Linux, `getNotificationAppLaunchDetails()` isn't implemented and throws
  `UnimplementedError` instead of returning null — `ReminderService.getLaunchPayload` catches
  this and treats it as "no launch payload".
