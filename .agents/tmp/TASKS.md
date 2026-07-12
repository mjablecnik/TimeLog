# TASKS — Manual History Entry

- [x] 1. [HIGH] Create `ManualEntrySheet` widget (`lib/ui/widgets/manual_entry_sheet.dart`) — bottom sheet with start/end time pickers (defaulting based on selected day), activity type chip selector, conditional project autocomplete field, description text field, and Submit/Cancel buttons
- [x] 2. [HIGH] Implement save logic in `ManualEntrySheet` — validate description non-empty and end > start, insert `TimeEntriesCompanion` via `DatabaseService.insertTimeEntry()`, save project to known projects if provided, pop sheet on success, show error on failure
- [x] 3. [HIGH] Add "+" button to `HistoryScreen` header — place an IconButton (Icons.add) in the top-right corner of the History screen title area, on tap open `ManualEntrySheet` as a modal bottom sheet passing the current `selectedDayProvider` value and theme
- [x] 4. [MEDIUM] Implement smart default times — if selected day is today, default start to `now - 30 min` and end to `now`; if selected day is in the past, default to 12:00–12:30; clamp times to stay within the selected day boundaries (00:00–23:59)
- [x] 5. [MEDIUM] Add time validation constraints — ensure picked start/end times stay within the selected day, show error message if end time is not after start time, prevent submission with invalid times
- [x] 6. [LOW] Write widget test for `ManualEntrySheet` — verify form starts blank, submit is disabled when description is empty, time validation error appears when end ≤ start, successful submission calls database insert with correct values
