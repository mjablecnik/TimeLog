# Manual History Entry — Specification

## Overview

Add the ability to manually create a time entry from the History screen by tapping a "+" (plus) button in the top-right corner. This opens a form similar to the existing `DescriptionSheet` but with all fields blank — the user must fill in the description, activity type, project (if applicable), start time, and end time manually. The entry is saved to the currently viewed day.

## Goals

- Allow users to log activities that were not tracked by the timer (e.g., forgot to start it).
- The entry is always associated with the currently selected day on the History screen.
- Reuse as much existing UI and logic as possible (activity type chips, project autocomplete, description field, time pickers).

## Technical Approach

### New Widget: `ManualEntrySheet`

A new bottom sheet widget at `lib/ui/widgets/manual_entry_sheet.dart`. It combines elements from both `DescriptionSheet` (activity type selection, project field, description field) and `EditSheet` (start/end time pickers).

**Why a new widget instead of reusing `DescriptionSheet` or `EditSheet`:**
- `DescriptionSheet` is tightly coupled to the timer lifecycle (it receives `sessionStart`/`endedAt` from the timer, triggers `stop()`/`autoRestart()`, has prefill/skip modes).
- `EditSheet` is designed for editing an existing entry (requires a `TimeEntry` object).
- A dedicated `ManualEntrySheet` is simpler and avoids flag/mode complexity in existing widgets.

### Form Fields

1. **Start time** — TimePicker, defaults to current time minus 30 minutes (clamped to day start).
2. **End time** — TimePicker, defaults to current time (clamped to day end).
3. **Activity type** — Chip selector (same as `DescriptionSheet`), defaults to first type.
4. **Project** — Autocomplete field, shown only for work activity types (same logic as existing sheets).
5. **Description** — Multi-line text field, max 500 chars.

### Validation

- Description cannot be empty.
- End time must be after start time.
- Both times must fall within the selected day (00:00–23:59).

### Save Behavior

- Inserts a new `TimeEntriesCompanion` into the database via `DatabaseService.insertTimeEntry()`.
- Saves the project to known projects (if provided).
- Does NOT interact with the timer provider at all.
- On success, pops the sheet. The `dayEntriesProvider` stream auto-updates the History list.

### History Screen Changes

- Add a `+` IconButton (or FloatingActionButton) in the top-right area of the History screen header.
- Tapping it opens `ManualEntrySheet` as a modal bottom sheet.
- The selected day from `selectedDayProvider` is passed to the sheet for date context.

## File Structure

```
lib/ui/widgets/manual_entry_sheet.dart   (NEW)
lib/ui/screens/history_screen.dart       (MODIFIED — add + button)
```

No database schema changes. No new providers needed — uses existing `databaseServiceProvider`, `projectServiceProvider`, and `selectedDayProvider`.

## Constraints & Edge Cases

- If the selected day is today, default times should be "now minus 30 min" → "now". If the selected day is in the past, default to 12:00–12:30 (reasonable midday default).
- Time pickers should constrain to the selected day (not allow cross-day entries).
- The sheet should be dismissible via swipe-down or Cancel button (non-blocking, unlike `DescriptionSheet` which uses `PopScope(canPop: false)`).
- The form does NOT load/save "last submitted" preferences — it always starts blank.
- No interaction with `timerProvider` — this is purely a database insert.
