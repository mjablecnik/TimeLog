# TASKS — TimeLog App: Round 4

- [x] 1. [HIGH] Add cancel button to DescriptionSheet in prefill mode — add a "Zrušit" TextButton (or X IconButton) visible only when `isPrefillMode == true`, that calls `Navigator.of(context).pop()` without saving any data
- [x] 2. [HIGH] Ensure timer resumes after prefill sheet cancel — in `timer_screen.dart` `_showPrefillSheet`, add logic in `whenComplete` to resume timer if it's still paused (safety net for cancel path)
- [x] 3. [HIGH] Extend DatabaseService to support updating entry times — add `startTime` and `endTime` optional parameters to `updateDescription` (or create a new `updateEntry` method) that writes updated ISO8601 time strings
- [x] 4. [HIGH] Add time display and editing to EditSheet — show current start/end times as tappable HH:mm fields, open `showTimePicker` on tap, store selected times in local state
- [x] 5. [HIGH] Add time validation in EditSheet — validate that end time is after start time before saving, show error message if invalid
- [x] 6. [HIGH] Save updated times in EditSheet._save() — pass the (possibly modified) start/end times to the database service update method
- [x] 7. [HIGH] Save last-submitted values after successful entry save — in DescriptionSheet._saveEntry(), after successful insert, persist description, activityType, and project to SharedPreferences (keys: `last_submitted_description`, `last_submitted_activity_type`, `last_submitted_project`)
- [x] 8. [HIGH] Load last-submitted values as fallback in DescriptionSheet — in `initState`, when no draft is provided (`initialDescription == null` and `!isPrefillMode`), load last-submitted values from SharedPreferences and use them as initial form values
- [x] 9. [HIGH] Add reset (X) button to DescriptionSheet — always-visible IconButton (close/clear icon) in the header row that clears description text, resets activity type to `activityTypes.first`, and clears the project field; minimum 44×44px touch target
- [x] 10. [HIGH] Extend StatsData to include raw entries — add a `List<TimeEntry> entries` field to `StatsData` and pass the raw entries through from the statistics provider
- [x] 11. [HIGH] Create TimelinePainter CustomPainter — new file `lib/ui/painters/timeline_painter.dart` that paints a single horizontal bar with colored blocks for each entry, gaps as empty space, and hour markers below
- [x] 12. [HIGH] Implement daily timeline in statistics screen — add a timeline widget (using TimelinePainter) above the stats body in daily mode, showing one bar for the selected day
- [x] 13. [HIGH] Implement weekly timeline in statistics screen — in weekly mode, show 7 stacked timeline bars (one per day, Mon–Sun) with Czech day labels (Po, Út, St, Čt, Pá, So, Ne)
- [x] 14. [MEDIUM] Handle edge cases in timeline painter — dynamic time range based on first/last entry (fallback 6:00–24:00), handle entries with zero duration, handle overlapping entries gracefully
- [ ] 15. [MEDIUM] Test prefill cancel flow — verify that canceling the prefill sheet discards text, resumes the timer, and doesn't leave stale prefill state
- [ ] 16. [MEDIUM] Test time editing validation — verify end > start validation works, that the time picker respects the same-day constraint, and that the database is updated correctly
