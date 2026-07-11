# SPEC — TimeLog App: Round 4

## Overview

Four improvements to the TimeLog Flutter app: (1) cancel button for prefill sheet, (2) time editing in history, (3) auto-prefill from last submission with reset button, (4) daily timeline graph on statistics screen.

## Architecture Context

- Flutter app using Riverpod for state management, Drift for database, SharedPreferences for lightweight persistence
- UI in `lib/ui/` (screens, widgets, painters), services in `lib/services/`, providers in `lib/providers/`, data/models in `lib/data/`, shared config/utils in `lib/core/`
- Timer logic in `TimerNotifier` (StateNotifier + Freezed state)
- Database: Drift with `TimeEntries` table (id, startTime, endTime, description, activityType, project, createdAt)
- Theming via `AppThemeData` with named color properties

---

## Feature 1: Close Prefill Sheet Without Saving

### Problem
`DescriptionSheet` in prefill mode (`isPrefillMode: true`) has no cancel/close button. The only exit is saving a draft.

### Solution
- Add a "Cancel" text button (or X icon) to the prefill mode UI in `DescriptionSheet`
- On tap: dismiss sheet without saving, discard typed text
- Timer must resume after dismissal (it was paused when prefill sheet opened)
- Implementation: in `_showPrefillSheet` on `TimerScreen`, the `whenComplete` callback should check if timer is still paused and resume it. Alternatively, the cancel action in `DescriptionSheet` calls `notifier.resume()` before `Navigator.pop()`.

### Affected Files
- `lib/ui/widgets/description_sheet.dart` — add cancel button in prefill mode
- `lib/ui/screens/timer_screen.dart` — ensure timer resumes on sheet dismissal without save (safety net in `whenComplete`)

---

## Feature 2: Edit Entry Times in History

### Problem
`EditSheet` allows changing description, activity type, and project — but not start/end times.

### Solution
- Display current start time and end time in `EditSheet` (HH:mm format)
- Each time is tappable → opens `showTimePicker`
- Validation: end must be after start
- Save persists updated times to database

### Database Change
- Add `updateEntry` method to `DatabaseService` (or extend `updateDescription`) that accepts optional `startTime` and `endTime` values

### Affected Files
- `lib/ui/widgets/edit_sheet.dart` — add time display rows with tap-to-edit
- `lib/services/database_service.dart` — support updating start/end time fields

---

## Feature 3: Auto-Prefill From Last Submission

### Problem
When no draft exists during session, the description sheet opens empty even though the user often repeats the same entry.

### Solution
- After each successful entry save, persist the submitted values (description, activityType, project) to SharedPreferences under keys like `last_submitted_description`, `last_submitted_activity_type`, `last_submitted_project`
- When `DescriptionSheet` opens in non-prefill mode with no draft values (`initialDescription == null`), load last-submitted values from SharedPreferences and use as initial form values
- Add a clearly visible reset (X) button that clears all form fields in one tap:
  - Description → empty
  - Activity type → first item (`Práce`)
  - Project → empty
- Reset button always visible (not just when prefilled), placed in top-right corner or next to the title

### Priority of Pre-fill
1. Draft (prefill saved during session) — passed as `initialDescription`/`initialActivityType`/`initialProject`
2. Last submitted entry — loaded from SharedPreferences when no draft
3. Empty form — only if no history at all

### Affected Files
- `lib/ui/widgets/description_sheet.dart` — load last-submitted on open, add reset button, save last-submitted on successful save
- (SharedPreferences interaction stays within the widget — no service needed)

---

## Feature 4: Timeline Graph on Statistics Screen

### Problem
Statistics screen only shows aggregated totals, no visibility into when activities happened during the day.

### Solution
- Add a timeline widget below the date nav / above the stats body (or at the top of the stats list)
- **Daily mode**: single horizontal bar representing the day. Each entry is a colored block (color from `activityTypeColor()`). Width proportional to duration. Gaps shown as empty/dark space.
- **Weekly mode**: 7 horizontal bars stacked vertically (Monday–Sunday), each labeled with Czech day abbreviations (Po, Út, St, Čt, Pá, So, Ne)
- Hour markers below each bar for reference
- Dynamic time range based on earliest/latest entry (or 6:00–24:00 default)
- Implemented using `CustomPainter` — no external charting libraries

### Data Requirement
- The `statisticsProvider` already fetches raw `TimeEntry` list via `getEntriesForRange`. Need to expose those raw entries alongside the aggregated `StatsData` so the timeline painter can use them.
- Create a new provider or extend the existing one to provide raw entries grouped by day.

### New Files
- `lib/ui/painters/timeline_painter.dart` — CustomPainter for the timeline bar(s)

### Affected Files
- `lib/ui/screens/statistics_screen.dart` — add timeline widget
- `lib/providers/statistics_provider.dart` — expose raw entries for timeline

---

## File Structure (New/Modified)

```
lib/
├── core/
│   └── activity_types.dart            (no change)
├── data/
│   ├── database.dart                  (no change)
│   ├── stats_data.dart                (extend with raw entries field)
│   └── time_entry.dart                (no change)
├── providers/
│   └── statistics_provider.dart       (expose raw entries)
├── services/
│   ├── database_service.dart          (add time update support)
│   └── timer_service.dart             (no change)
├── ui/
│   ├── painters/
│   │   └── timeline_painter.dart      (NEW)
│   ├── screens/
│   │   ├── statistics_screen.dart     (add timeline widget)
│   │   └── timer_screen.dart          (ensure resume on prefill cancel)
│   └── widgets/
│       ├── description_sheet.dart     (cancel button, auto-prefill, reset)
│       └── edit_sheet.dart            (time editing)
```

---

## Constraints

- Reset button: minimum 44×44px touch target
- Time editing: must validate end > start before saving
- Prefill cancel: timer must not remain paused after sheet dismissal
- UI text: Czech for user-facing labels (consistent with existing app)
- Timeline graph: additive — existing stats UI unchanged
- No external charting libraries for timeline (use `CustomPainter`)
