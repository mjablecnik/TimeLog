# SPEC — TimeLog App: Round 3

## Overview

Three enhancements to an existing Flutter time-tracking app built with Riverpod + Drift:
1. Add three new activity types with distinct colors
2. Add a project field (with autocomplete) for work-related activity types
3. Add a Statistics screen as a third navigation tab

## Technical Stack (existing)

- Flutter 3.10+, Dart
- State management: `flutter_riverpod` (providers pattern)
- Database: `drift` (SQLite) with code generation
- Persistence: `shared_preferences` for lightweight key-value storage
- Fonts: Sora (UI), JetBrainsMono (monospace)
- No i18n framework — strings are hardcoded Czech/English inline

## 1. New Activity Types

### Changes

**`lib/core/activity_types.dart`** — add 3 entries to `activityTypes` list and 3 cases to `activityTypeColor()`:

| Type | Color |
|------|-------|
| Volná práce | `Colors.teal[400]` |
| Přesun | `Colors.indigo[300]` (dark) / `Colors.indigo[400]` (light) |
| Jídlo | `Colors.orange[400]` |

Note: Přesun needs a light/dark variant similar to Spánek for legibility.

### Impact

No schema changes. All UI that iterates `activityTypes` (description_sheet, edit_sheet, history_entry_card) will automatically pick up new types.

## 2. Project Field for Work Types

### Concept

When activity type is "Práce" or "Volná práce", show an additional autocomplete text field for project name. Previously entered project names are persisted and offered as suggestions.

### Data Layer Changes

1. **Schema migration** — Add nullable `project` column to `TimeEntries` table. Bump `schemaVersion` to 4 with migration adding the column.
2. **Project storage** — Store known project names in `SharedPreferences` as a `List<String>` (key: `known_projects`). This avoids a separate DB table and keeps autocomplete fast.

### Service Layer Changes

- `DatabaseService.insertTimeEntry()` — already accepts `TimeEntriesCompanion`, no change needed (callers pass the project value).
- `DatabaseService.updateDescription()` — add optional `project` parameter.
- New: `ProjectService` (or inline logic in sheets) to load/save project names from SharedPreferences.

### UI Changes

- **`description_sheet.dart`** — Add a `RawAutocomplete<String>` or `Autocomplete<String>` widget below the activity type chips, visible only when `_selectedType` is "Práce" or "Volná práce". On save, persist new project names.
- **`edit_sheet.dart`** — Same autocomplete field, pre-populated with existing entry's project.
- **`history_entry_card.dart`** — Display project name as a small label (below description or next to activity badge) when non-null.

### Autocomplete Behavior

- Case-insensitive matching, preserves original casing
- Updates the stored list when a new (unseen) project name is submitted
- No network calls — purely local

## 3. Statistics Screen

### Navigation

- Add `StatisticsScreen` as third item in `_MainShell._screens` and `AppBottomNav`.
- Icon: `Icons.bar_chart_outlined` / `Icons.bar_chart`

### Architecture

```
lib/
  providers/
    statistics_provider.dart    — providers for aggregated stats
  services/
    database_service.dart       — new query methods for stats
  ui/
    screens/
      statistics_screen.dart    — main statistics page
    painters/
      bar_painter.dart          — custom painter for horizontal bars (or pie)
```

### Data Queries (DatabaseService)

- `getEntriesForRange(DateTime start, DateTime end)` — fetch all entries in a date range.
- Statistics computation can be done in Dart (not raw SQL aggregates) since data volume is small (max ~50 entries/day).

### Provider

- `statisticsPeriodProvider` — `StateProvider<StatsPeriod>` (enum: daily, weekly)
- `statisticsDateProvider` — `StateProvider<DateTime>` (selected date / week anchor)
- `statisticsProvider` — `FutureProvider` that queries entries for the period and computes breakdowns

### Statistics Model

```dart
class StatsData {
  final Duration totalTracked;
  final Duration untrackedTime;
  final Map<String, Duration> byActivityType;
  final Map<String, Duration> byProject; // only Práce + Volná práce
}
```

### UI Layout

1. Period toggle (Daily / Weekly) — segmented control or tab bar
2. Date navigation — reuse existing `DayNavigator` pattern for daily; similar for weekly
3. Activity type breakdown — horizontal bars with type colors, showing absolute time + percentage
4. Project breakdown — simple list with time totals (only if work entries exist in period)
5. Untracked time — displayed as "Nesledovaný čas" at the bottom

### Untracked Time Calculation

- Daily: `16h - totalTracked` (assuming 16h waking day)
- Weekly: `112h - totalTracked` (7 × 16h)
- Clamp to 0 if tracked exceeds assumed waking hours

### No external charting library

Use `CustomPainter` for simple horizontal percentage bars. The existing `ring_painter.dart` shows the project already uses custom painting.

## File Structure (new/modified files)

```
lib/
  core/
    activity_types.dart              ← MODIFY (add 3 types + colors)
  data/
    time_entry.dart                  ← MODIFY (add project column)
    database.dart                    ← MODIFY (schema v4 migration)
    database.g.dart                  ← REGENERATE (build_runner)
  services/
    database_service.dart            ← MODIFY (add project param, stats queries)
    project_service.dart             ← NEW (SharedPreferences project name storage)
  providers/
    database_provider.dart           ← MODIFY (export project service provider)
    statistics_provider.dart         ← NEW
  ui/
    screens/
      statistics_screen.dart         ← NEW
    widgets/
      description_sheet.dart         ← MODIFY (add project autocomplete)
      edit_sheet.dart                ← MODIFY (add project autocomplete)
      history_entry_card.dart        ← MODIFY (show project name)
      bottom_nav.dart                ← MODIFY (add Statistics tab)
    painters/
      bar_painter.dart               ← NEW (horizontal bar painter)
  app.dart                           ← MODIFY (add StatisticsScreen to shell)
```

## Constraints

- No external charting libraries
- Project autocomplete must be instant (local SharedPreferences)
- Statistics queries should be efficient (entries are already indexed by startTime)
- Colors must work on both light and dark themes
- All new UI text: Czech for user-facing labels, English for code
- Run `dart run build_runner build` after schema changes to regenerate drift code
