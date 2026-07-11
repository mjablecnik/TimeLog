# Specification — TimeLog App Changes (Round 2)

## Overview

Five enhancements to the existing Flutter time-tracking app: activity type colors, pre-fill description while timer runs, conditional auto-restart behavior, skip-description option, and foreground ringing bypass.

## 1. Activity Type Colors

### Goal
Each activity type renders its badge with a distinct color instead of using the generic `theme.dim` text / `theme.background` background.

### Color Mapping
| Type | Color |
|------|-------|
| Práce | Red (`Colors.red[400]`) |
| Volný čas | Green (`Colors.green[400]`) |
| Odpočinek | Blue (`Colors.blue[400]`) |
| Spánek | Dark blue/black (`Color(0xFF1A2340)` dark-bg / `Colors.blueGrey[900]` light) |
| Cvičení | Dark orange (`Colors.deepOrange[700]`) |

### Affected Files
- `lib/core/activity_types.dart` (NEW) — centralized list of types + color helper
- `lib/ui/widgets/description_sheet.dart` — use colors in chips and add "Cvičení"
- `lib/ui/widgets/edit_sheet.dart` — same chip color treatment + add "Cvičení"
- `lib/ui/widgets/history_entry_card.dart` — colored badge

### Design Decisions
- Create a single `ActivityType` utility (map from name → color) to avoid duplicating color logic.
- Colors should work on all three themes. Use the raw color for the badge text/border and a low-opacity version for the background fill.

## 2. Pre-fill Description While Timer Runs

### Goal
Allow the user to write a description and select an activity type in advance, before the timer finishes. Values persist in memory for the current session and pre-fill the description sheet when the timer ends.

### Behavior
1. A small button appears on the timer screen while status is `running` or `paused`.
2. Tapping it pauses the timer (if running) and opens the description sheet in "pre-fill" mode.
3. User fills in description + type, confirms → timer resumes, values are stored in `TimerNotifier` state.
4. When timer finishes and the real description sheet opens, the stored values are passed as initial values.
5. After the entry is saved, the pre-fill values are cleared.

### State Changes
- Add `prefillDescription` (String?) and `prefillActivityType` (String?) to `TimerState` (freezed).
- Add `savePrefill(String description, String activityType)` and `clearPrefill()` methods to `TimerNotifier`.
- Persist prefill values via SharedPreferences so they survive app kill during a session.

### UI Changes
- `timer_screen.dart` — show a small icon button (e.g., `Icons.edit_note_rounded`) below the controls when running/paused.
- `description_sheet.dart` — accept optional `initialDescription` and `initialActivityType` params. In pre-fill mode, the submit button text is "Save Draft" and it calls `savePrefill` + resumes the timer instead of inserting DB entry.

## 3. Stop Button Should Not Auto-Restart

### Goal
After the user taps Stop → confirms → submits description, the timer returns to idle. Auto-restart only occurs when the timer finishes via the flag (finishNow) or natural expiry.

### Implementation
- `DescriptionSheet` needs to know whether the session ended via stop vs. finish/expiry.
- Add a `triggeredByStop` (bool) parameter to `DescriptionSheet`.
- When `triggeredByStop == true`, after saving the entry call `notifier.stop()` (reset to idle) instead of `notifier.autoRestart()`.
- `timer_screen.dart` — pass `triggeredByStop: true` when the sheet is opened after `stopAndLog()` and `false` when opened after `finishNow()`/ringing dismiss.
- Track the trigger source in `TimerState` via a new field `logTrigger` (`LogTrigger.stop | LogTrigger.finish`).

## 4. Skip Description Option

### Goal
Add a "Skip" button to the description sheet that saves the entry with an empty description but keeps the selected activity type.

### Implementation
- Add a `TextButton` labeled "Skip" below or beside the Submit button.
- On tap: insert entry with `description: ''` and current `_selectedType`, then proceed with auto-restart or idle (same logic as submit, based on `triggeredByStop`).
- The `description` column constraint `withLength(min: 1, max: 500)` must be relaxed to `min: 0` (or use `.nullable()`). Update migration to schema version 3.

## 5. Skip Ringing Overlay When App Is in Foreground

### Goal
If the timer expires while the app is in the foreground (resumed lifecycle state), skip the ringing state entirely — go straight from running → logging.

### Implementation
- `TimerNotifier._recalculate()` — when `secondsLeft <= 0`, check if app is in foreground.
  - Foreground: transition directly to `logging` (no `ringing`, no alarm, no live-activity completed update needed since the user is present).
  - Background: existing behavior (transition to `ringing`, play alarm).
- Track foreground state via `didChangeAppLifecycleState` — store a `_isForeground` bool in `TimerNotifier`.
- On restore: if status was `ringing` already keep existing behavior (transition to logging).

## File Structure (Proposed New/Modified)

```
lib/
  core/
    activity_types.dart        ← NEW: type list, color map, helper
  data/
    time_entry.dart            ← MODIFY: relax description min length
    database.dart              ← MODIFY: schema v3 migration
  services/
    timer_service.dart         ← MODIFY: prefill state, logTrigger, foreground check
    timer_service.freezed.dart ← REGENERATE
  ui/
    screens/
      timer_screen.dart        ← MODIFY: prefill button, pass triggeredByStop
    widgets/
      description_sheet.dart   ← MODIFY: initial values, skip button, conditional restart
      edit_sheet.dart           ← MODIFY: use activity_types.dart, add Cvičení
      history_entry_card.dart   ← MODIFY: colored badge
```

## Constraints & Edge Cases
- Pre-fill values must survive `pause()` and `resume()` cycles but clear on `stop()`.
- If user opens pre-fill sheet, types something, then stops the timer (without confirming pre-fill), the pre-fill is discarded.
- "Skip" must not leave orphan entries with null description — use empty string `''`.
- Foreground detection must account for the first tick after the app resumes (the timer may expire during the same frame that detects resumed state).
- The `Cvičení` type is new — existing entries won't have it, no migration needed (it's just a new UI option).
