# Specification — TimeLog App Changes (Batch 2)

## Overview

Six UI/UX improvements to the TimeLog Flutter app: confirmation dialogs on stop/reset, smarter ringing behavior when app is opened, activity type selection on the description input, date format fix in history, flag button behavior change (no beep), and theme switcher relocation.

## Architecture Context

- **State management**: Riverpod + Freezed (`TimerNotifier` extends `StateNotifier<TimerState>`)
- **Persistence**: SharedPreferences for timer state; Drift (SQLite) for time entries
- **Timer states**: `idle → running → paused → ringing → logging → idle` (cycle)
- **Key files**:
  - `lib/services/timer_service.dart` — core state machine
  - `lib/ui/screens/timer_screen.dart` — main screen, listens to state transitions
  - `lib/ui/widgets/timer_controls.dart` — start/stop/pause/flag buttons
  - `lib/ui/widgets/description_sheet.dart` — post-session input dialog
  - `lib/ui/widgets/ringing_overlay.dart` — pulsating alarm overlay
  - `lib/ui/screens/history_screen.dart` — history list
  - `lib/ui/widgets/day_navigator.dart` — date navigation + label formatting
  - `lib/ui/widgets/history_entry_card.dart` — single entry card
  - `lib/data/time_entry.dart` — Drift table definition
  - `lib/core/extensions.dart` — DateTime/Duration helpers

---

## 1. Confirmation Dialog on Stop/Reset

**Current**: Tapping Stop immediately calls `notifier.stop()` which resets to idle without saving.

**Required**:
1. When user taps Stop (while running/paused), show a confirmation dialog: "Do you really want to reset the timer?"
2. If confirmed → transition to `logging` state and show `DescriptionSheet` so the user can log what they worked on (same as natural timer finish). The entry should record `sessionStart` → `DateTime.now()` as the time range.
3. If cancelled → do nothing, timer continues.

**Implementation**:
- Add a `stopWithConfirmation(BuildContext context)` flow in `timer_controls.dart` that shows an `AlertDialog`.
- On confirm: capture the current `sessionStart` and `endAt = DateTime.now()`, call `notifier.stop()` BUT before resetting, transition through `logging` state. Alternatively, add a new method `stopAndLog()` on `TimerNotifier` that goes to `logging` state (stopping the ticker and alarm) without resetting `sessionStart`/`endAt`.
- Then show `DescriptionSheet` with the captured times.
- After description submission, `autoRestart()` is called as usual.

**New method on `TimerNotifier`**: `stopAndLog()` — stops ticker, cancels notifications, captures end time, transitions to `logging` state (keeps `sessionStart`).

---

## 2. Ringing Behavior When App is Opened

**Current**: When timer is ringing, the `RingingOverlay` is shown and user must tap "Dismiss" to stop beeping and proceed to description input.

**Required**: Opening the app while ringing should immediately:
1. Stop the beeping
2. Skip the ringing overlay entirely
3. Show the description input right away

**Implementation**:
- In `timer_service.dart` `_restoreState()`: when restoring a `ringing` state, instead of playing the alarm and staying in `ringing`, immediately transition to `logging`.
- Also in `didChangeAppLifecycleState(resumed)`: if current state is `ringing`, call `dismissRinging()` immediately.
- This ensures that whenever the app comes to foreground while ringing, it auto-dismisses.

---

## 3. Activity Type on Description Input

**Current**: `DescriptionSheet` only has a text field + submit button.

**Required**:
- Add a type selector with options: `Práce`, `Volný čas`, `Odpočinek`, `Spánek`
- Selected type is persisted (SharedPreferences) so it's pre-selected next time
- Type is stored with the time entry in the database
- Type is displayed in history cards next to the description

**Implementation**:

### Data layer
- Add `TextColumn get activityType => text().withDefault(const Constant('Práce'))();` to `TimeEntries` table in `time_entry.dart`.
- Bump `schemaVersion` to 2 in `database.dart` and add migration to add the column.
- Re-run `build_runner` to regenerate `database.g.dart`.

### UI — DescriptionSheet
- Add a row of selectable chips/buttons for the 4 activity types above the text field.
- Load last selected type from SharedPreferences on init, default to `Práce`.
- On submit, include the selected type in the `TimeEntriesCompanion`.
- Save the selected type to SharedPreferences on each selection change.

### UI — HistoryEntryCard
- Display `entry.activityType` as a small badge/label next to the time range or description.

### UI — EditSheet
- Add the same activity type selector so existing entries can be edited.

---

## 4. Date Format in History

**Current**: `_dayLabel` in `DayNavigator` returns `YYYY-MM-DD` for dates beyond yesterday.

**Required**: Display dates as `9. 7. 2026` (day. month. year with spaces after dots, no leading zeros on day/month).

**Implementation**:
- Change the fallback format in `DayNavigator._dayLabel()` from `'$y-$m-$d'` to `'${day.day}. ${day.month}. ${day.year}'`.
- Also update `DateTimeExtensions.toDateLabel()` in `extensions.dart` to match (if used elsewhere).

---

## 5. Flag Button Behavior Change

**Current**: `finishNow()` transitions to `ringing` state + plays alarm.

**Required**: Flag button should NOT start beeping. It should immediately show the description input dialog. Beeping only happens when timer expires naturally (the user is away).

**Implementation**:
- Modify `finishNow()` in `TimerNotifier`: instead of transitioning to `ringing` and playing the alarm, transition directly to `logging` state. Keep `sessionStart` and set `endAt` to now.
- Remove the `_alarm.play()` call from `finishNow()`.
- The existing listener in `timer_screen.dart` already reacts to `logging` state by showing `DescriptionSheet`.

---

## 6. Theme Switcher Location

**Current**: `ThemeDots` widget is shown on both `TimerScreen` and `HistoryScreen`.

**Required**: Remove it from `HistoryScreen`. Keep it only on `TimerScreen`.

**Implementation**:
- Remove the `ThemeDots()` widget and its spacing from `history_screen.dart`.

---

## File Changes Summary

| File | Change |
|------|--------|
| `lib/services/timer_service.dart` | Add `stopAndLog()`, modify `finishNow()` (no alarm), modify `_restoreState()` and `didChangeAppLifecycleState` for auto-dismiss |
| `lib/ui/widgets/timer_controls.dart` | Add confirmation dialog to Stop button, call `stopAndLog()` on confirm |
| `lib/ui/screens/timer_screen.dart` | Adjust listener if needed for new `stopAndLog` flow |
| `lib/ui/widgets/description_sheet.dart` | Add activity type selector, persist selection, include type in DB insert |
| `lib/ui/widgets/edit_sheet.dart` | Add activity type selector for editing |
| `lib/data/time_entry.dart` | Add `activityType` column |
| `lib/data/database.dart` | Bump schema version, add migration |
| `lib/ui/widgets/history_entry_card.dart` | Display activity type badge |
| `lib/ui/widgets/day_navigator.dart` | Change date format to `d. M. yyyy` |
| `lib/core/extensions.dart` | Update `toDateLabel()` format |
| `lib/ui/screens/history_screen.dart` | Remove `ThemeDots` |
| `lib/ui/widgets/ringing_overlay.dart` | No changes (still used for natural timer expiry when app is already open) |

---

## Constraints & Edge Cases

- **Migration**: Existing entries won't have `activityType`. Default to `'Práce'` for backward compatibility.
- **Stop + Log flow**: If user has only been running for a few seconds, still allow logging (no minimum duration).
- **Ringing auto-dismiss on resume**: The `_restoreState` path handles cold start; `didChangeAppLifecycleState` handles warm resume. Both should transition to `logging`.
- **Flag during paused state**: `finishNow()` already accepts `paused` state — now it goes to `logging` instead of `ringing`.
- **DescriptionSheet endedAt**: When called from `stopAndLog()`, use the captured end time (now stored in `state.endAt`).
