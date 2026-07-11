# BRIEF — TimeLog App: Round 4

## Overview

Three UX improvements to the description/edit workflow:
1. Allow closing the prefill sheet without saving
2. Allow editing entry times in history
3. Auto-prefill description from last submission with easy reset

---

## 1. Close Prefill Sheet Without Saving

### Current Behavior
When the user opens the description form during a running timer (prefill mode), the only way to exit is to save the draft. There's no way to dismiss the sheet without filling it in.

### Desired Behavior
- Add a close/cancel button (X icon or "Cancel" text button) to the prefill sheet.
- Tapping it dismisses the sheet **without** saving any prefill values.
- The timer resumes automatically (same as if the user had never opened the sheet).
- Any text already typed in the form is discarded on cancel.

### Affected Files
- `lib/ui/widgets/description_sheet.dart` — add cancel/close action in prefill mode
- `lib/ui/screens/timer_screen.dart` — ensure timer resumes on sheet dismissal without save

---

## 2. Edit Entry Time in History

### Current Behavior
The edit sheet allows changing the description, activity type, and project — but NOT the start/end time.

### Desired Behavior
- In the edit sheet, show the current start time and end time of the entry.
- Both times should be editable (tap to open a time picker).
- Validation: end time must be after start time.
- Save updates the entry's start/end time in the database.

### Implementation Notes
- Use Flutter's `showTimePicker` or a custom time picker consistent with the app design.
- The date portion stays the same (only hours:minutes are editable) — entries don't span multiple days.
- Update `DatabaseService.updateDescription()` (or create a new method) to accept optional start/end time updates.

### Affected Files
- `lib/ui/widgets/edit_sheet.dart` — add time display + time picker triggers
- `lib/services/database_service.dart` — support updating start/end time

---

## 3. Auto-Prefill Description From Last Submission

### Current Behavior
When the timer finishes and the description sheet opens:
- If a draft (prefill) was saved during the session, it pre-fills those values.
- If no draft exists, the form is empty.

### Desired Behavior
- If **no draft** was saved during the session, the form auto-fills with the **last submitted entry's** values (description, activity type, project).
- This makes it easy for the user to repeat the same entry without retyping.
- A clearly visible **reset button (X icon)** is present that clears ALL form fields (description, activity type back to default, project cleared) in one tap.
- The reset button should be always visible (not just when prefilled) so the user can quickly clear everything at any time.

### Priority of Pre-fill Values
1. **Draft (prefill saved during session)** — highest priority, used as-is
2. **Last submitted entry** — used when no draft exists
3. **Empty form** — only if no history exists at all

### Implementation Notes
- On sheet open (non-prefill mode, no draft): query the most recent entry from the database and use its description, activityType, and project as initial values.
- Store "last submitted" values in SharedPreferences (simpler than querying DB every time) — update them after every successful entry save.
- The reset (X) button appears in the top-right corner or next to the title. Tapping it:
  - Clears the description text field
  - Resets activity type to the first item (Práce)
  - Clears the project field
- The reset is purely visual/in-memory — it doesn't delete any persisted data.

### Affected Files
- `lib/ui/widgets/description_sheet.dart` — load last-submitted values, add reset button
- `lib/services/timer_service.dart` or SharedPreferences — persist last-submitted values

---

## 4. Timeline Graph on Statistics Screen

### Current Behavior
The statistics screen shows aggregated totals — how much time was spent on each activity type and project overall. But there's no visibility into **when** during the day those activities happened.

### Desired Behavior
- Add a **daily timeline graph** to the statistics screen (in addition to existing stats — don't change/remove anything).
- The graph represents a full day (e.g., 6:00–24:00 or dynamically based on first/last entry).
- Each tracked entry is shown as a colored block on a horizontal (or vertical) timeline bar.
- The color of each block corresponds to the activity type color (from `activityTypeColor()`).
- Gaps (untracked time) are shown as empty/dark space.
- The user can see at a glance:
  - What they did in the morning vs afternoon vs evening
  - How work, rest, food, exercise, etc. are distributed throughout the day
  - Where the gaps are (untracked time)

### Design Notes
- A **horizontal bar** spanning the full width of the screen works well — similar to a Gantt chart or a stacked timeline.
- Hour markers (6, 8, 10, 12, 14, 16, 18, 20, 22, 24) below/above for reference.
- Each entry block has width proportional to its duration.
- No external charting libraries — use `CustomPainter`.
- Only shown in **daily** mode as a single bar. In **weekly** mode, show **7 bars stacked vertically** (one per day, Monday at top, Sunday at bottom), each with a day label (Po, Út, St, Čt, Pá, So, Ne). This gives a clear week-at-a-glance view showing patterns across days.
- Tapping a block could optionally show a tooltip with the entry details (nice-to-have, not required).

### Affected Files
- `lib/ui/screens/statistics_screen.dart` — add the timeline widget
- `lib/ui/painters/timeline_painter.dart` — NEW: CustomPainter for the timeline bar
- `lib/providers/statistics_provider.dart` — may need to expose raw entries (not just aggregated) for the daily view

---

## Constraints
- The reset (X) button must be clearly visible and easy to tap (min 44×44px touch target).
- Time editing must validate that end > start.
- Closing the prefill sheet must not leave the timer in a paused state — it must resume.
- All new UI text should be consistent with the existing app language (Czech labels where user-facing).
- The timeline graph is additive — existing statistics UI stays unchanged.
