# CLAUDE.md

## Project overview

TimeLog — a Flutter countdown timer + time-tracking app with per-entry project tracking, a
statistics tab, and a daily reminder notification. State management: `flutter_riverpod`. Local
persistence: `drift` (SQLite) for time entries, `shared_preferences` for lightweight state. Dart
SDK `^3.10.4`. Fully offline, no backend, no environment variables.

## Key commands

```sh
flutter pub get                                              # install deps
dart run build_runner build --delete-conflicting-outputs     # regenerate Drift/Freezed/Riverpod code
flutter gen-l10n                                              # regenerate AppLocalizations from lib/l10n/*.arb
flutter run -d linux                                          # run (or macos/windows/chrome/<device-id>)
flutter test                                                  # run all tests
flutter test test/timer_service_test.dart                     # run one test file
flutter analyze                                                # lint
flutter build linux --release                                  # release build (see DOCS.md for other platforms)
dart run flutter_launcher_icons                                # regenerate app launcher icons from assets/icon/
```

## Project structure

See [DOCS.md](DOCS.md#project-structure) for the full annotated tree. Summary:
- `lib/core/` — constants, theme, small helpers (no Flutter widgets)
- `lib/data/` — Drift table (`time_entry.dart`) + database (`database.dart`); `.g.dart` is generated
- `lib/services/` — business logic (timer state machine, alarm, notifications, daily reminder, live activity, DB access, known-project storage)
- `lib/providers/` — Riverpod wiring between services and UI
- `lib/ui/screens/`, `lib/ui/widgets/`, `lib/ui/painters/` — presentation layer (Timer, Tasks,
  Statistics, Settings tabs; History is reached from Statistics, see Conventions below)
- `ios/Runner/LiveActivityManager.swift` + `ios/TimeLogWidgetExtension/` — native iOS Live Activity

## Conventions

- Activity types, subtypes, labels and colours are defined once in the `activityRegistry` in
  `lib/core/activity_types.dart`; every widget reads it (no parallel lists). The type and subtype
  keys are Czech/ASCII identifiers persisted in the database and are never translated — use
  `activityTypeLabel()` / `subtypeLabel()` for display. To add a type or subtype, add it to the
  registry, add its labels to both `.arb` files and run `flutter gen-l10n`.
- Colours are computed, not stored: `activityEntryColor(type, subtype, isDark:)`. Paper (the
  light theme) has its own values in the registry.
- A type's extra field comes from the registry (`TypeExtra`): `Práce` and `Domácí práce` have a
  project, `Ostatní` has a free-text custom name (own column `custom_name`).
- All three entry sheets (`DescriptionSheet`, `EditSheet`, `ManualEntrySheet`) use the shared
  `ActivityPicker` (`lib/ui/widgets/activity_picker/`); change the type/subtype UI there, once.
- Name suggestions are per category (`SuggestionScope`: paid work, unpaid work, housework,
  other), stored by `ProjectService` and read through `suggestionsProvider(scope)`, which also
  merges the Tasks-tab projects of that category. A Tasks project has a `scope` column.
- Riverpod: `StateNotifierProvider` for mutable app state (`timerProvider`, `themeProvider`),
  plain `Provider`/`FutureProvider` for service singletons. Read theme via
  `ref.watch(themeProvider)` and use `AppThemeData` fields — never hardcode colors.
- Any change to the `TimeEntries` table (`lib/data/time_entry.dart`) requires bumping
  `schemaVersion` (currently 8) and adding an `onUpgrade` step in `lib/data/database.dart`, then
  regenerating with `build_runner`.
- Generated files (`database.g.dart`, `timer_service.freezed.dart`) are committed — always
  regenerate and commit them together with the source change that triggered them. The same
  applies to `lib/l10n/generated/app_localizations*.dart`: whenever `lib/l10n/app_en.arb` or
  `lib/l10n/app_cs.arb` changes, run `flutter gen-l10n` and commit the regenerated output.
- i18n: every user-facing string goes through generated `AppLocalizations` (`AppLocalizations.of
  (context)!`), backed by `lib/l10n/app_en.arb` (template/source of truth) and `lib/l10n/app_cs.arb`.
  Internal identifiers persisted in the DB or compared via `==`/`switch` (the `activityTypes` /
  `subtype` keys in `lib/core/activity_types.dart`) are never translated in
  place — use `activityTypeLabel()`/`subtypeLabel()` to get a localized display string
  for one of those keys. Background code with no `BuildContext` (notification builders in
  `reminder_service.dart`/`recurring_reminder_service.dart`) reads the persisted language via
  `loadAppLocalizations()` (`lib/core/app_locale.dart`). The active language is
  `localeProvider` (`lib/providers/locale_provider.dart`), persisted to SharedPreferences under
  `app_language` (`'en'`/`'cs'`, absent = follow system locale).
- Bottom nav has 4 tabs (Timer, Tasks, Statistics, Settings) — `statsTabIndex` in
  `lib/core/config.dart`. `HistoryScreen` isn't one of them; it's pushed via `Navigator` from
  the history icon in Statistics' top-right corner and keeps the Stats tab highlighted while
  open (`AppBottomNav` on `HistoryScreen`'s own `Scaffold` is given `selectedIndex:
  statsTabIndex`). The selected main-shell tab lives in `mainTabIndexProvider`
  (`lib/providers/main_tab_provider.dart`) rather than local `State`, so `HistoryScreen` can
  switch tabs (pop + set the provider) without a callback back into `_MainShell`.

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
- `ReminderService` (daily reminder notification, `lib/services/reminder_service.dart`) is a
  separate mechanism from `NotificationService` (timer-completion alert, native MethodChannel):
  it uses `flutter_local_notifications` directly and needs `InitializationSettings` for every
  desktop platform (Linux/Windows/macOS), not just Android/iOS, or it crashes on startup.
  `getNotificationAppLaunchDetails()` throws `UnimplementedError` on Linux — always call it
  through `getLaunchPayload()`, which already catches that.
- iOS Live Activity code requires iOS 16.2+ and is guarded by
  `ActivityAuthorizationInfo().areActivitiesEnabled`; it no-ops (returns `false`) rather than
  throwing when unsupported/disabled — don't add error handling around it, that's by design.
- The Statistics screen's "untracked time" figure assumes 16 waking hours/day (hardcoded in
  `_computeStats` in `lib/providers/statistics_provider.dart`) — it's `16 * days_in_period`
  minus tracked time, not derived from any user setting.

## Reference

See [DOCS.md](DOCS.md) for architecture, platform channel details, deployment, and testing.
