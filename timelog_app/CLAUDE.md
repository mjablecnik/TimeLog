# CLAUDE.md

## Project overview

TimeLog — a Flutter countdown timer + time-tracking app. State management: `flutter_riverpod`.
Local persistence: `drift` (SQLite) for time entries, `shared_preferences` for lightweight
state. Dart SDK `^3.10.4`. Fully offline, no backend, no environment variables.

## Key commands

```sh
flutter pub get                                              # install deps
dart run build_runner build --delete-conflicting-outputs     # regenerate Drift/Freezed/Riverpod code
flutter run -d linux                                          # run (or macos/windows/chrome/<device-id>)
flutter test                                                  # run all tests
flutter test test/timer_service_test.dart                     # run one test file
flutter analyze                                                # lint
flutter build linux --release                                  # release build (see DOCS.md for other platforms)
```

## Project structure

See [DOCS.md](DOCS.md#project-structure) for the full annotated tree. Summary:
- `lib/core/` — constants, theme, small helpers (no Flutter widgets)
- `lib/data/` — Drift table (`time_entry.dart`) + database (`database.dart`); `.g.dart` is generated
- `lib/services/` — business logic (timer state machine, alarm, notifications, live activity, DB access)
- `lib/providers/` — Riverpod wiring between services and UI
- `lib/ui/screens/`, `lib/ui/widgets/`, `lib/ui/painters/` — presentation layer
- `ios/Runner/LiveActivityManager.swift` + `ios/TimeLogWidgetExtension/` — native iOS Live Activity

## Conventions

- Activity types are hardcoded Czech strings in `lib/core/activity_types.dart` — the
  `activityTypes` list and the `activityTypeColor()` switch must be updated together; all UI
  (description sheet, edit sheet, history cards) iterates `activityTypes` so it picks up
  changes automatically.
- Riverpod: `StateNotifierProvider` for mutable app state (`timerProvider`, `themeProvider`),
  plain `Provider`/`FutureProvider` for service singletons. Read theme via
  `ref.watch(themeProvider)` and use `AppThemeData` fields — never hardcode colors.
- Any change to the `TimeEntries` table (`lib/data/time_entry.dart`) requires bumping
  `schemaVersion` and adding an `onUpgrade` step in `lib/data/database.dart`, then
  regenerating with `build_runner`.
- Generated files (`database.g.dart`, `timer_service.freezed.dart`) are committed — always
  regenerate and commit them together with the source change that triggered them.

## Important notes

- Two independent duration ranges exist: `TimerConfig` (`lib/core/config.dart`) allows
  1–1440 minutes, but the Timer screen's adjustable UI clamps to 5–60 minutes in 5-minute
  steps (`_minDurationMinutes`/`_maxDurationMinutes`/`_durationStep` constants local to
  `lib/ui/screens/timer_screen.dart`). Changing one does not change the other.
- `ThemeDots` (in-app theme switcher widget, `lib/ui/widgets/theme_dots.dart`) is currently
  unused — its `Row` in `timer_screen.dart` is commented out, and `Midnight` is the hardcoded
  default in `theme_provider.dart`. Re-enabling theme switching means uncommenting that row.
- Linux desktop needs GStreamer *runtime* plugins installed (not just `-dev` headers) or the
  app crashes when `audioplayers` tries to play the alarm sound — see DOCS.md Troubleshooting.
- iOS Live Activity code requires iOS 16.2+ and is guarded by
  `ActivityAuthorizationInfo().areActivitiesEnabled`; it no-ops (returns `false`) rather than
  throwing when unsupported/disabled — don't add error handling around it, that's by design.
- A prior commit ("feat: add new activity types and project field with statistics screen")
  only added planning docs (BRIEF.md/SPEC.md/TASKS.md, stored under `../.agents/tmp/` at the
  repo root, outside `timelog_app/`) — no corresponding code was ever written. The codebase
  still has just the original 5 activity types, no `project` field on time entries, and only
  two tabs (Timer, History). Don't assume that feature exists without checking the code.

## Reference

See [DOCS.md](DOCS.md) for architecture, platform channel details, deployment, and testing.
