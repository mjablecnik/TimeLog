# TimeLog Flutter App — Project Steering

## Overview

TimeLog is a Flutter iOS countdown timer app with time tracking. Users work in configurable intervals (default 20 min), describe what they did on completion, and review logged entries in history. The app also supports recurring daily reminders for habits/tasks.

## Technology Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.44.6 (pinned via FVM — always use `fvm flutter` commands) |
| Language | Dart (SDK ^3.10.4) |
| State management | Riverpod (`StateNotifier`, `AsyncNotifier`, `ConsumerWidget`) |
| Database | Drift (SQLite) with code generation |
| Immutable state | Freezed |
| Notifications | flutter_local_notifications |
| Audio | audioplayers |
| Persistence | SharedPreferences (timer state), Drift (time entries, reminders) |
| Fonts | Sora (UI text), JetBrains Mono (timer digits, data values) |
| Platform | iOS-primary, Live Activities via platform channels |

## Project Structure

```
timelog_app/
├── lib/
│   ├── main.dart              # Entry point, ProviderContainer, notification init
│   ├── app.dart               # MaterialApp, bottom nav shell, navigator key
│   ├── core/                  # Config, theme, extensions, platform channels
│   ├── data/                  # Drift tables, database class, generated code
│   ├── providers/             # Riverpod providers (state layer)
│   ├── services/              # Business logic, scheduling, alarm, notifications
│   └── ui/
│       ├── painters/          # CustomPainter for ring, charts
│       ├── screens/           # Full-page screens
│       └── widgets/           # Reusable UI components
├── test/                      # Unit and widget tests
├── ios/                       # iOS native (AppDelegate, Live Activity widget)
├── assets/                    # Fonts, audio, icons
└── .fvmrc                     # Flutter version pin: 3.44.6
```

## Architecture Conventions

### State Management

- Use `StateNotifier` for synchronous, real-time state (e.g., timer countdown)
- Use `AsyncNotifier` for async/database-backed state (e.g., reminder list)
- Use `ConsumerWidget` / `ConsumerStatefulWidget` for UI that reads providers
- Expose services via `Provider` (singleton) and override in `ProviderContainer` for DI

### Data Layer (Drift)

- Tables are defined as separate files in `lib/data/` (one table per file)
- All tables registered in `@DriftDatabase(tables: [...])` in `database.dart`
- CRUD methods live directly in `AppDatabase` (no separate repository class)
- Increment `schemaVersion` and add migration in `onUpgrade` for every schema change
- After modifying table definitions or database class: run `fvm flutter pub run build_runner build --delete-conflicting-outputs`
- Foreign keys enabled via PRAGMA in `_openConnection()`

### Theme System

- Three themes: Ember (default, warm dark), Midnight (cool dark), Paper (light)
- `AppThemeData` holds all color tokens: `background`, `text`, `accent`, `ink`, `panel`, `border`, `track`, `dim`, `faint`, `glow`, `glowSoft`
- Access via `ref.watch(themeProvider)` in consuming widgets
- Widgets receive theme as constructor parameter when inside non-Consumer parents (e.g., dialog content)
- Never hardcode colors — always use theme tokens

### Navigation

- Bottom tabs: Timer, History, Statistics, Settings (via `IndexedStack`)
- Sub-screens pushed with `MaterialPageRoute`
- Global `navigatorKey` in `app.dart` for navigation from outside widget tree (notification taps)

### Notifications

- Single shared `FlutterLocalNotificationsPlugin` instance (initialized once in `ReminderService`)
- Other services receive the shared plugin via constructor injection
- iOS AppDelegate must set `UNUserNotificationCenter.current().delegate = self`
- Notification tap routing: persist payload to SharedPreferences + set in-memory provider (triple-path: callback, resume, cold-launch)

### Code Generation

- Freezed for immutable state classes (timer state)
- Drift codegen for database (`database.g.dart`)
- Riverpod generator available but not exclusively used (manual providers also present)
- Build command: `fvm flutter pub run build_runner build --delete-conflicting-outputs`

## Coding Conventions

### Language

- All code (names, comments, constants) in English
- User-facing UI text in Czech (this app targets Czech users)
- No i18n framework — Czech strings are inline in widgets

### Naming

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables, functions: `camelCase`
- Constants: `camelCase` (Dart convention, not UPPER_SNAKE)
- Private members: prefix with `_`
- Providers: `camelCaseProvider` suffix (e.g., `timerProvider`, `themeProvider`)
- Services: `PascalCaseService` (e.g., `RecurringReminderService`)

### Style

- Do NOT run `dart format` / `flutter format` on this repo — the codebase uses a pre-tall-style format that the current SDK's formatter would rewrite
- Match the existing code style: single-line when it fits, manual formatting
- Trailing commas on multi-line widget trees (Flutter convention)
- Use `const` constructors where possible
- Prefer named parameters for widget constructors

### Logical Day Boundary

- A "logical day" starts at 03:00 (defined in `core/config.dart` as `dayStartHour = 3`)
- Entries between 00:00–02:59 are counted toward the previous calendar day
- This applies to history filtering and statistics

## Database Schema (Current: v6)

| Table | Purpose |
|-------|---------|
| `TimeEntries` | Logged time entries (start, end, description, activityType, project, entertainmentType) |
| `RecurringReminders` | Reminder definitions (name, time window, interval, active days bitmask, active flag) |
| `CompletionRecords` | Daily completion tracking for reminders (FK to reminder, date, timestamp) |

## Testing

- Framework: `flutter_test` (built-in)
- Run with: `fvm flutter test`
- Tests in `timelog_app/test/` directory
- Drift tests use `NativeDatabase.memory()` with `AppDatabase.forTesting(e)` constructor
- Timer tests must explicitly call `.stop()` / `.pause()` before test ends to avoid "Timer still pending" errors
- Widget tests that need providers: use explicit `ProviderContainer` + `UncontrolledProviderScope`

## Build & Run

- Always use FVM: `fvm flutter pub get`, `fvm flutter build ios`, `fvm flutter test`, `fvm flutter analyze`
- Code generation: `fvm flutter pub run build_runner build --delete-conflicting-outputs`
- Target platform: iOS (iPhone, minimum iOS 18.0)

## Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Timer persistence | SharedPreferences (endAt timestamp) | Survives app termination, simple restore on launch |
| Reminder scheduling | 6-hour lookahead batch via flutter_local_notifications | Stays within iOS 64-notification limit, fires without app being open |
| Active days | 7-bit bitmask integer | Compact, no join table, easy bitwise checks |
| Notification ID scheme | `(reminderId × 100) + slotIndex + 2000` | Supports batch scheduling, avoids collision with timer notification (1001) |
| Theme | Custom `AppThemeData` (not Material ThemeData) | Full control over design tokens, matches HTML/JS prototype |

## Important Notes

- `dart_check` (property-based testing) does not exist on pub.dev — skip property tests or use a different library
- `dart pub get` (without `flutter`) breaks plugin registrant files — always use `fvm flutter pub get`
- The app uses a custom alarm sound (`assets/audio/alarm.mp3`) and a separate reminder notification sound (`ios/Runner/reminder_sound.wav`)
- Live Activities are managed via a platform channel to native Swift code (`ios/`)
