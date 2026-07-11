# TASKS — TimeLog App: Round 3

## Feature 1: New Activity Types

- [x] 1. [HIGH] Add new activity types (Volná práce, Přesun, Jídlo) and colors to `lib/core/activity_types.dart`

## Feature 2: Project Field

- [x] 2. [HIGH] Add nullable `project` column to `TimeEntries` table in `lib/data/time_entry.dart`
- [ ] 3. [HIGH] Add schema v4 migration in `lib/data/database.dart` to add the project column
- [ ] 4. [HIGH] Run `dart run build_runner build` to regenerate `database.g.dart`
- [ ] 5. [HIGH] Create `lib/services/project_service.dart` — load/save project names via SharedPreferences
- [ ] 6. [HIGH] Add project service provider to `lib/providers/database_provider.dart`
- [ ] 7. [HIGH] Update `DatabaseService.updateDescription()` to accept and persist optional project field
- [ ] 8. [HIGH] Add project autocomplete field to `lib/ui/widgets/description_sheet.dart` (visible for Práce/Volná práce)
- [ ] 9. [HIGH] Add project autocomplete field to `lib/ui/widgets/edit_sheet.dart` (visible for Práce/Volná práce)
- [ ] 10. [MEDIUM] Display project name in `lib/ui/widgets/history_entry_card.dart` when present

## Feature 3: Statistics Screen

- [ ] 11. [HIGH] Add `getEntriesForRange(DateTime start, DateTime end)` method to `DatabaseService`
- [ ] 12. [HIGH] Create statistics data model (StatsData with breakdowns by type and project)
- [ ] 13. [HIGH] Create `lib/providers/statistics_provider.dart` with period/date state and computed stats
- [ ] 14. [HIGH] Create `lib/ui/painters/bar_painter.dart` — CustomPainter for horizontal percentage bars
- [ ] 15. [HIGH] Create `lib/ui/screens/statistics_screen.dart` — main statistics page with period toggle, breakdowns, and untracked time
- [ ] 16. [HIGH] Add Statistics tab to `lib/ui/widgets/bottom_nav.dart`
- [ ] 17. [HIGH] Add StatisticsScreen to `lib/app.dart` navigation shell

## Verification

- [ ] 18. [MEDIUM] Run `flutter analyze` and fix any lint issues
- [ ] 19. [MEDIUM] Verify the app builds successfully (`flutter build` or `flutter run`)
