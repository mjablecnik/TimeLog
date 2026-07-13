# Tasks

- [x] 1. [HIGH] Replace 'Spánek' with 'Zábava' in `activityTypes` list and `activityTypeColor` switch in `lib/core/activity_types.dart`
- [x] 2. [HIGH] Fix statistics refresh: in `_MainShellState.onTap` callback in `lib/app.dart`, invalidate `statisticsProvider` when `index == 2` is selected (import the provider)
- [x] 3. [HIGH] Make `_initDefaultTimes` in `lib/ui/widgets/manual_entry_sheet.dart` async — query `DatabaseService.getEntriesForDay(selectedDay)` and set `_startTime` to the latest entry's `endTime` if entries exist; fall back to current defaults if no entries
- [x] 4. [MEDIUM] Add swipe gesture to statistics screen: wrap the `Expanded` content area in `StatisticsScreen` with a `GestureDetector` using `onHorizontalDragEnd` to navigate to previous/next day or week (same logic as the chevron buttons in `_DateNav`)
- [x] 5. [LOW] Verify no regressions — ensure statistics screen refreshes on tab switch, swipe respects the "cannot go past today" constraint, manual entry start time correctly picks latest end time from sorted entries
