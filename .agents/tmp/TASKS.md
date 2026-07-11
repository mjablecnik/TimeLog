# Tasks

- [x] 1. [HIGH] Add `activityType` column to `TimeEntries` table in `lib/data/time_entry.dart` — `TextColumn get activityType => text().withDefault(const Constant('Práce'))();`
- [x] 2. [HIGH] Bump `schemaVersion` to 2 in `lib/data/database.dart` and add migration strategy to add the `activity_type` column to existing databases
- [x] 3. [HIGH] Run `dart run build_runner build --delete-conflicting-outputs` to regenerate `database.g.dart` with the new column
- [x] 4. [HIGH] Modify `finishNow()` in `lib/services/timer_service.dart` — transition to `TimerStatus.logging` instead of `ringing`, do NOT call `_alarm.play()`, set `endAt` to `DateTime.now()`, keep `sessionStart`
- [x] 5. [HIGH] Add `stopAndLog()` method to `TimerNotifier` in `lib/services/timer_service.dart` — stop ticker, cancel notifications/live activity, capture `endAt = DateTime.now()`, transition to `logging` state (preserving `sessionStart` and `endAt`)
- [x] 6. [HIGH] Modify `_restoreState()` in `lib/services/timer_service.dart` — when restoring `ringing` status, transition directly to `logging` instead of playing alarm (auto-dismiss on app open)
- [x] 7. [HIGH] Modify `didChangeAppLifecycleState` in `lib/services/timer_service.dart` — when app resumes and state is `ringing`, call `dismissRinging()` immediately
- [x] 8. [HIGH] Add confirmation dialog to Stop button in `lib/ui/widgets/timer_controls.dart` — show AlertDialog "Do you really want to reset the timer?", on confirm call `notifier.stopAndLog()`, on cancel do nothing
- [x] 9. [HIGH] Add activity type selector to `lib/ui/widgets/description_sheet.dart` — row of 4 selectable chips (`Práce`, `Volný čas`, `Odpočinek`, `Spánek`), load last selection from SharedPreferences, save on change, include in `TimeEntriesCompanion` on submit
- [x] 10. [MEDIUM] Add activity type selector to `lib/ui/widgets/edit_sheet.dart` — same chip row, pre-select the entry's current type, update on save
- [x] 11. [MEDIUM] Display activity type in `lib/ui/widgets/history_entry_card.dart` — show a small styled label/badge with `entry.activityType` next to the time range
- [x] 12. [MEDIUM] Change date format in `lib/ui/widgets/day_navigator.dart` — update `_dayLabel()` fallback format from `YYYY-MM-DD` to `d. M. yyyy` (e.g., `9. 7. 2026`)
- [x] 13. [MEDIUM] Update `toDateLabel()` in `lib/core/extensions.dart` — match the new `d. M. yyyy` format for consistency
- [x] 14. [MEDIUM] Remove `ThemeDots` widget from `lib/ui/screens/history_screen.dart` — delete the widget and its surrounding spacing, keep it only on `TimerScreen`
- [x] 15. [LOW] Verify `timer_screen.dart` listener handles the new `stopAndLog()` → `logging` transition correctly (the existing `prev?.status != TimerStatus.logging && next.status == TimerStatus.logging` check should trigger `_showDescriptionSheet` with correct `sessionStart` and `endAt`)
- [x] 16. [LOW] Run `flutter analyze` and fix any lint issues introduced by the changes
- [x] 17. [LOW] Build the app (`flutter build linux --release`) to verify no compile errors
