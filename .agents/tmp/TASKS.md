# Tasks

- [x] 1. [HIGH] Rename "Volný čas" to "Seberozvoj" and "Volná práce" to "Domácí práce" in `lib/core/activity_types.dart` (update `activityTypes` list, `activityTypeColor()` switch cases, remove "Domácí práce" from `workActivityTypes`)
- [x] 2. [HIGH] Add `entertainmentTypes` constant list and `isEntertainmentActivityType()` helper to `lib/core/activity_types.dart`
- [ ] 3. [HIGH] Add nullable `entertainmentType` text column to `TimeEntries` table in `lib/data/time_entry.dart`
- [ ] 4. [HIGH] Bump `schemaVersion` to 5 in `lib/data/database.dart` and add migration: rename activity types in existing rows + add `entertainment_type` column
- [ ] 5. [HIGH] Regenerate Drift code with `dart run build_runner build --delete-conflicting-outputs`
- [ ] 6. [HIGH] Add entertainment type two-option chip selector to `DescriptionSheet` — shown when "Zábava" is selected, mandatory before submit, persists selection to `entertainment_type` column and SharedPreferences
- [ ] 7. [HIGH] Add entertainment type two-option chip selector to `EditSheet` — shown when "Zábava" is selected, pre-populated from existing entry's `entertainment_type`, saved on update
- [ ] 8. [HIGH] Add entertainment type two-option chip selector to `ManualEntrySheet` — shown when "Zábava" is selected, mandatory before submit
- [ ] 9. [MEDIUM] Display entertainment type in `HistoryEntryCard` below activity type (similar to project display for work entries)
- [ ] 10. [MEDIUM] Update `TimerNotifier` prefill to support `entertainmentType` field — ensure draft save/restore carries the entertainment type through pause/resume cycle
- [ ] 11. [MEDIUM] Update `stats_data.dart` doc comment to reference "Domácí práce" instead of "Volná práce", and optionally add `byEntertainmentType` breakdown map
- [ ] 12. [MEDIUM] Update `statistics_provider.dart` to aggregate entertainment time by sub-type (if byEntertainmentType is added to StatsData)
- [ ] 13. [LOW] Verify all tests still pass after changes (update test fixtures referencing old activity type names if any)
