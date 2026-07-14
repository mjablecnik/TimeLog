# Tasks

- [x] 1. [HIGH] Rename "Volný čas" to "Seberozvoj" and "Volná práce" to "Domácí práce" in `lib/core/activity_types.dart` (update `activityTypes` list, `activityTypeColor()` switch cases, remove "Domácí práce" from `workActivityTypes`)
- [x] 2. [HIGH] Add `entertainmentTypes` constant list and `isEntertainmentActivityType()` helper to `lib/core/activity_types.dart`
- [x] 3. [HIGH] Add nullable `entertainmentType` text column to `TimeEntries` table in `lib/data/time_entry.dart`
- [x] 4. [HIGH] Bump `schemaVersion` to 5 in `lib/data/database.dart` and add migration: rename activity types in existing rows + add `entertainment_type` column
- [x] 5. [HIGH] Regenerate Drift code with `dart run build_runner build --delete-conflicting-outputs`
- [x] 6. [HIGH] Add entertainment type two-option chip selector to `DescriptionSheet` — shown when "Zábava" is selected, mandatory before submit, persists selection to `entertainment_type` column and SharedPreferences
- [x] 7. [HIGH] Add entertainment type two-option chip selector to `EditSheet` — shown when "Zábava" is selected, pre-populated from existing entry's `entertainment_type`, saved on update
- [x] 8. [HIGH] Add entertainment type two-option chip selector to `ManualEntrySheet` — shown when "Zábava" is selected, mandatory before submit
- [x] 9. [MEDIUM] Display entertainment type in `HistoryEntryCard` below activity type (similar to project display for work entries)
- [x] 10. [MEDIUM] Update `TimerNotifier` prefill to support `entertainmentType` field — ensure draft save/restore carries the entertainment type through pause/resume cycle
- [x] 11. [MEDIUM] Update `stats_data.dart` doc comment to reference "Domácí práce" instead of "Volná práce", and optionally add `byEntertainmentType` breakdown map
- [x] 12. [MEDIUM] Update `statistics_provider.dart` to aggregate entertainment time by sub-type (if byEntertainmentType is added to StatsData)
- [x] 13. [LOW] Verify all tests still pass after changes (update test fixtures referencing old activity type names if any)
