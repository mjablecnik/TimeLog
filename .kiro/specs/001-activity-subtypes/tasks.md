# Implementation Plan: Activity Subtypes

## Overview

Replace the `Zábava`-only sub-classification with a general model of twelve Main_Types and their Subtypes in `timelog_app/`. The work starts at the bottom: the Activity_Registry and the localization, then schema version 8 with the Migration, then the scoped Suggestion_Store and the Timer_Service prefill, then the shared Activity_Picker and the three Entry_Sheets, and finally the History_Card, the Day_Timeline and the Statistics_Screen. Tests are interleaved with the code they cover. Property tests use the hand-rolled seeded loop already used in `test/task_service_*_property_test.dart`, because `glados` cannot be added. The work ends with a visual check on the three themes, the documentation sync and the `1.1.0` release change.

## Tasks

- [x] 1. Activity_Registry
  - [x] 1.1 Add the registry data structures and the twelve Main_Types to `lib/core/activity_types.dart`
    - Add `TypeExtra`, `SuggestionScope`, `ActivitySubtype`, `ActivityType` and the `const activityRegistry` list exactly as in the Data Models section of the design (Type_Keys, Subtype_Keys, order, extra fields, all Dark_Themes and Light_Theme colours)
    - Keep the persisted Type_Key `Přesun`; add the Type_Keys `Meeting`, `Komunikace` and `Ostatní`
    - Keep `activityTypes` as a `List<String>` derived from the registry
    - _Requirements: 1.1, 1.2, 1.6, 2.1, 2.3, 2.7, 2.8, 2.9, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 4.1, 4.7_

  - [x] 1.2 Add the registry helper functions to `lib/core/activity_types.dart`
    - Implement `activityTypeOf`, `subtypeOf`, `activityEntryColor`, `activityMainColor`, `defaultSubtypeKey`, `suggestionScopeOf`, `suggestionScopeColor`, `suggestionScopeLabel`, `hasProjectField`, `hasCustomNameField`, `activityTypeLabel`, `subtypeLabel` and `entryMetaLine` with the signatures from the design
    - `activityEntryColor` falls back from Subtype colour to Main_Color to neutral grey `#BDBDBD` and never throws
    - Remove `workActivityTypes`, `isWorkActivityType`, `isHouseworkActivityType`, `entertainmentTypes`, `isEntertainmentActivityType`, `entertainmentTypeLabel` and `activityTypeColor`, and update every caller to read the registry
    - _Requirements: 1.3, 1.4, 1.5, 4.2, 4.3, 4.4, 4.5, 4.6, 8.1, 8.2, 8.3, 10.2, 13.3, 13.4, 13.5, 13.6_

  - [x]* 1.3 Write unit tests in `test/core/activity_types_test.dart`
    - Test the twelve Main_Types in order, the Subtypes of each type, no Subtypes for the five types that have none, and the extra field of each type
    - Test that the `paid` colour is darker than the `unpaid` colour on every theme
    - Test `entryMetaLine` for the five cases of Requirement 13 and `subtypeLabel` for English and Czech
    - _Requirements: 2.1, 2.7, 2.8, 2.9, 3.1, 3.8, 4.7, 13.3, 13.4, 13.5, 13.6_

  - [x]* 1.4 Write property test for registry integrity in `test/core/activity_types_test.dart`
    - **Property 1: Registry integrity**
    - For every Main_Type and Subtype in the registry, keys are unique within their level and every colour is defined for Dark_Themes and the Light_Theme
    - **Validates: Requirements 1.1, 1.2, 2.1, 3.9, 4.1**

  - [x]* 1.5 Write property test for entry colour resolution in `test/core/activity_types_test.dart`
    - **Property 2: Entry colour resolution**
    - For random Type_Keys (valid and random strings), random Subtype_Keys (valid, invalid, null) and both brightnesses, the result follows the fallback chain and never throws
    - **Validates: Requirements 4.2, 4.3, 4.4, 4.5, 4.6, 17.2, 17.3**

  - [x]* 1.6 Write property tests for preselection and scope mapping in `test/core/activity_types_test.dart`
    - **Property 6: Subtype preselection is always valid**
    - For every Main_Type and random remembered values, `defaultSubtypeKey` returns a valid Subtype_Key for types with Subtypes and null for the others
    - **Property 8: Suggestion scope mapping**
    - `suggestionScopeOf` returns a scope exactly for `Práce` with `paid` or `unpaid`, for `Domácí práce` and for `Ostatní`
    - **Validates: Requirements 7.9, 8.1, 8.2, 8.3, 10.2**

- [x] 2. Localization
  - [x] 2.1 Update the Localization_Files and regenerate `AppLocalizations`
    - In `lib/l10n/app_en.arb` and `lib/l10n/app_cs.arb` add every key of the localization table in the design (including the four category names and the Tasks tab caption); change the values of `activityCommute` to "Travel" and "Cestování"; rename `entertainmentActive` and `entertainmentPassive` to `subtypeEntertainmentActive` and `subtypeEntertainmentPassive` and update their references
    - The key `pickerSubtypeHeading` takes a `type` placeholder
    - Run `flutter gen-l10n` and commit the regenerated files with the source change
    - _Requirements: 2.2, 2.4, 2.5, 2.6, 3.10, 6.2, 7.5, 7.6, 9.4, 9.5, 15.10, 16.1, 16.2, 16.3, 16.4, 17.4, 18.2_

- [x] 3. Data layer and Migration
  - [x] 3.1 Add the columns and the Migration in `lib/data/time_entry.dart` and `lib/data/database.dart`
    - Add `subtype` (nullable text) and `customName` (nullable text, max 200) to `TimeEntries`; keep `entertainmentType` declared and add a comment that it is legacy and never written
    - Set `schemaVersion` to 8 and add the `from < 8` step: two `addColumn` calls and the three `customStatement` updates from the design; declare the `scope` text column (default `workUnpaid`) in `lib/data/task_project.dart` and add it to `task_projects` in the same step, but only when `from >= 7`, because the `from < 7` step creates the task tables from the current definition and already includes it
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 5.10, 5.11, 5.12, 5.13, 5.14, 5.15, 5.16, 5.17_

  - [x] 3.2 Regenerate Drift code
    - Run `dart run build_runner build --delete-conflicting-outputs` and commit `database.g.dart` with the source change
    - _Requirements: 5.2, 5.3_

  - [x] 3.3 Update `lib/services/database_service.dart`
    - Replace the `entertainmentType` parameter of `updateDescription` with `subtype` and add `customName`; `insertTimeEntry` keeps its signature and callers set `subtype` and `customName` in the companion
    - Ensure no code path writes the `entertainment_type` column
    - _Requirements: 5.10, 11.1, 11.5, 11.6, 11.7, 11.8_

  - [x]* 3.4 Write migration tests in `test/data/migration_v8_test.dart`
    - Build an in-memory version 7 database with `PRAGMA user_version = 7`, fill it with random Legacy_Entries and task projects, open it through `AppDatabase.forTesting` and check the result; add tests that start from the shape of schema versions 6 and 5 (the installed iOS build may be that old) and prove that every earlier step runs and `scope` is not added twice; add a test for a fresh database
    - **Property 3: Migration mapping**
    - For random sets of Legacy_Entries, every `Práce` row becomes `unpaid`, `Zábava` rows map to `active` or `passive` by their `entertainment_type`, all other rows get no Subtype, the row count and all other columns are unchanged; every existing Task_Project gets the scope `workUnpaid` and keeps its other columns
    - **Validates: Requirements 5.5, 5.6, 5.7, 5.8, 5.9, 5.12, 17.1**

- [x] 4. Checkpoint — data layer
  - Ensure `flutter analyze` is clean for the touched files and the new tests pass; ask the user if questions arise

- [x] 5. Suggestion_Store
  - [x] 5.1 Make `ProjectService` scoped in `lib/services/project_service.dart`
    - Replace `getKnownProjects` and `saveProject` with `getKnownNames(scope)` and `saveName(scope, name)`, stored under `known_names_v3_<scope name>` with the same 30-day expiry and newest-first order
    - Add `seedFromEntries`: derive the scope of each entry from the registry, use the latest end time of a name as its last-used time, skip names older than 30 days, set `known_names_v3_seeded`, remove the legacy keys `known_projects` and `known_projects_v2`, and run at most once
    - Treat an unparsable stored list as empty
    - _Requirements: 10.1, 10.3, 10.4, 10.5, 10.6, 10.10, 10.11, 10.12_

  - [x] 5.2 Replace `autocompleteProjectsProvider` in `lib/providers/task_providers.dart`
    - Add `suggestionsProvider` as a `FutureProvider.family<List<String>, SuggestionScope>`: seed once from the Database entries, then return the stored names; put the Task_Project_Names of the same scope in front for every scope and remove duplicates ignoring letter case; never offer a Task_Project name in another scope
    - Remove `autocompleteProjectsProvider` and update `test/task_providers_autocomplete_merge_property_test.dart`
    - _Requirements: 10.7, 10.8, 10.9, 10.13_

  - [x]* 5.3 Write tests in `test/services/project_service_scoped_test.dart`
    - Use `SharedPreferences.setMockInitialValues`; test expiry, newest-first order, case-insensitive de-duplication, seeding from entries, removal of legacy keys, seeding at most once, the merge of Task_Project names of the same scope and the absence of a merge across scopes
    - **Property 5: Suggestion isolation**
    - For random sequences of saves into random scopes and random Task_Projects with scopes, a scope lists a name only if it was saved into that scope or belongs to a Task_Project of that scope, and no list holds two names equal ignoring letter case
    - **Validates: Requirements 10.1, 10.3, 10.4, 10.8, 10.9, 18.10, 18.11**

- [x] 6. Timer prefill
  - [x] 6.1 Update `lib/services/timer_service.dart` and `lib/ui/screens/timer_screen.dart`
    - Replace `prefillEntertainmentType` with `prefillSubtype` and add `prefillCustomName`; extend `savePrefill` with `subtype` and `customName`; persist under `timer_prefillSubtype` and `timer_prefillCustomName`; remove both on clear
    - On load, map a legacy `timer_prefillEntertainmentType` value to `active` or `passive` for `Zábava` and remove the legacy key; ignore a Subtype_Key that is not defined for the type
    - Regenerate `timer_service.freezed.dart` with `dart run build_runner build --delete-conflicting-outputs`
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

  - [x]* 6.2 Update and extend `test/timer_service_test.dart`
    - Test persistence and clearing of the Subtype and Custom_Name, the legacy-key mapping and the ignored invalid Subtype_Key
    - _Requirements: 12.1, 12.3, 12.4, 12.5_

- [x] 7. Activity_Picker
  - [x] 7.1 Add `ActivitySelection` in `lib/ui/widgets/activity_picker/activity_picker.dart`
    - Implement the immutable selection with `copyWith` and `toRowValues`, which returns a project only for `TypeExtra.project`, a Custom_Name only for `TypeExtra.customName` and a Subtype_Key only when it is defined for the type
    - _Requirements: 9.9, 9.10, 11.2, 11.3, 11.4_

  - [x] 7.2 Add `SubtypeBlock` in `lib/ui/widgets/activity_picker/subtype_block.dart`
    - Draw the framed block with the heading `pickerSubtypeHeading`, the hint `pickerSubtypeHint` and one chip per Subtype in the Subtype colour, with the layout constants from the design (26 px top gap, border `Main_Color` at 55 percent alpha, fill at 9 percent)
    - _Requirements: 7.3, 7.4, 7.5, 7.6, 7.7_

  - [x] 7.3 Add `SuggestionField` in `lib/ui/widgets/activity_picker/suggestion_field.dart`
    - Move the project `Autocomplete<String>` code of the sheets into one widget that reads `suggestionsProvider(scope)` and reports text changes; keep the typed text when the scope changes
    - _Requirements: 9.4, 9.5, 9.6, 10.7_

  - [x] 7.4 Implement `ActivityPicker` in `lib/ui/widgets/activity_picker/activity_picker.dart`
    - Show the caption `pickerTypeCaption`, one chip per Main_Type in registry order (selected state in the Main_Color with a 20 percent fill, `Ostatní` with a dashed border), the `SubtypeBlock` while the type has Subtypes, and the `SuggestionField` for the project or the Custom_Name according to `TypeExtra`
    - Resolve the initial Subtype from `initial`, then from `last_subtype_<typeKey>`, then from the first Subtype; remember the last selected Main_Type (`last_activity_type`) and Subtype; on a Main_Type change replace the Subtype with the preselected one of the new type
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 7.1, 7.2, 7.8, 7.9, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 9.1, 9.2, 9.3, 10.7_

  - [x]* 7.5 Write widget tests in `test/ui/activity_picker_test.dart`
    - Test that the `SubtypeBlock` appears for `Cvičení` and not for `Meeting`, shows its heading and hint, preselects the remembered or the first Subtype, resets on a type change, and that the `Ostatní` chip and the Custom_Name field appear
    - **Property 7: Saved row is normalised**
    - For random selections, `toRowValues` returns a project, a Custom_Name and a Subtype_Key only where the Main_Type allows them
    - **Validates: Requirements 9.9, 9.10, 11.2, 11.3, 11.4**

- [x] 8. Entry_Sheets
  - [x] 8.1 Move `DescriptionSheet` to the `ActivityPicker`
    - Hold one `ActivitySelection` in the state; replace the entertainment preferences with `last_submitted_subtype` and `last_submitted_custom_name`; disable submit only for an empty description or an empty `Ostatní` name; keep Skip working with an empty name
    - Save with `toRowValues`, call `saveName` for the scope of the entry when a name is present, and save the prefill with Subtype and Custom_Name
    - _Requirements: 8.7, 9.7, 9.8, 11.1, 11.2, 11.3, 11.4, 12.1, 12.2_

  - [x] 8.2 Move `EditSheet` to the `ActivityPicker`
    - Initialise the selection from the stored entry (a missing Subtype of a type with Subtypes becomes the first Subtype); update the Type_Key, Subtype_Key, project and Custom_Name together; call `saveName` only on save
    - _Requirements: 8.5, 8.6, 8.7, 9.7, 10.13, 11.5_

  - [x] 8.3 Move `ManualEntrySheet` to the `ActivityPicker`
    - Same changes as in 8.1 for the manual entry flow
    - _Requirements: 8.7, 9.7, 11.1, 11.2, 11.3, 11.4_

  - [x]* 8.4 Update and extend the sheet tests
    - Update `test/description_sheet_prefill_cancel_test.dart`, `test/manual_entry_sheet_test.dart` and `test/edit_sheet_time_validation_test.dart` for the new parameters; add cases for saved row values of a `Práce` `paid` entry, a `Cvičení` `walk` entry and an `Ostatní` entry, and for the disabled submit of an empty `Ostatní` name
    - _Requirements: 8.7, 9.7, 9.8, 11.1, 11.2, 11.3, 11.5_

- [x] 9. Checkpoint — entry flow
  - Ensure `flutter analyze` and all tests pass; ask the user if questions arise

- [x] 10. Tasks tab categories
  - [x] 10.1 Add the category to Task_Projects in `lib/data/task_project.dart`, `lib/services/task_service.dart` and `lib/data/database.dart`
    - Give `createProject` an optional `scope` parameter that defaults to `workUnpaid`; replace `getProjectNames()` with `getProjectNames(scope)` and the matching `getTaskProjectNames(scope)` query; add `updateProjectScope(id, scope)` with the matching `updateTaskProjectScope` database method that changes the `scope` column only; treat an unknown stored scope as `workUnpaid`
    - The `scope` column and its migration come from tasks 3.1 and 3.2
    - _Requirements: 18.1, 18.7, 18.8, 18.11, 18.16, 18.18_

  - [x] 10.2 Update the Tasks tab in `lib/ui/widgets/project_selector.dart`
    - In the create-project dialog add the caption `taskProjectCategoryCaption` and one chip per Suggestion_Scope (label from `suggestionScopeLabel`), preselected from `last_task_project_scope` or `workUnpaid`; use the shared `SuggestionField` for the name with the selected scope; keep the typed text when the category changes; create the project with the selected scope and remember it
    - Show a dot in `suggestionScopeColor(project.scope)` before the label of every project chip and give each chip a `Semantics` label from `taskProjectChipSemantics`
    - Change the long press on a chip, which today opens the delete confirmation directly, to a bottom sheet with the actions `taskProjectEditCategory` and `commonDelete`; "Delete" shows the existing confirmation; the delete button on the chip stays as it is
    - Add the edit mode of the dialog: title `taskProjectEditCategory`, the project name as plain text, the four category chips with the current category selected, Save calls `updateProjectScope`, Cancel changes nothing; renaming is not offered
    - _Requirements: 18.2, 18.3, 18.4, 18.5, 18.6, 18.7, 18.9, 18.10, 18.12, 18.13, 18.14, 18.15, 18.16, 18.19, 18.20, 18.21_

  - [x]* 10.3 Write tests in `test/ui/activity_picker_test.dart` and `test/services/project_service_scoped_test.dart`
    - Widget tests: the dialog shows the four category chips and the remembered preselection, lists the suggestions of the selected category, keeps the typed text, creates the project with the selected category; the chips show the category dot
    - Widget tests also cover the long-press menu with its two actions, the edit mode (name shown as plain text, current category preselected, Save changes only the category, Cancel changes nothing) and the chip accessibility label
    - Service tests: `createProject` default scope, `getProjectNames(scope)` per scope, `updateProjectScope` moves the name between suggestion lists and leaves tasks and time entries unchanged, a deleted project's name disappears from the suggestions; update the existing `test/task_service_*_property_test.dart` files only where the changed signatures require it
    - _Requirements: 18.2, 18.3, 18.5, 18.6, 18.7, 18.8, 18.9, 18.11, 18.12, 18.13, 18.14, 18.15, 18.16, 18.17, 18.18, 18.19, 18.20_

- [x] 11. History, timeline and statistics
  - [x] 11.1 Update `lib/ui/widgets/history_entry_card.dart`
    - Badge text from `activityTypeLabel`, badge colour from `activityEntryColor`, the line below the description from `entryMetaLine`; delete the project and entertainment lines
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 13.6, 13.7, 17.4_

  - [x] 11.2 Update `lib/ui/painters/timeline_painter.dart`
    - Paint each block with `activityEntryColor(entry.activityType, entry.subtype, isDark: isDark)`
    - _Requirements: 14.1, 14.2_

  - [x] 11.3 Update `lib/data/stats_data.dart` and `lib/providers/statistics_provider.dart`
    - Replace `byEntertainmentType` with `bySubtype` and add `byCustomName` and `NameStat`; use `hasProjectField` for the project breakdown; sum custom names ignoring letter case and sort by duration, longest first
    - _Requirements: 15.1, 15.2, 15.9, 15.11, 15.12, 15.13_

  - [x] 11.4 Update `lib/ui/screens/statistics_screen.dart`
    - Draw each Main_Type as a header (label, time, share), a stacked bar of Subtype segments in registry order plus a Main_Color segment for time without a Subtype, scaled to the longest Main_Type, and always-visible indented Subtype rows with a coloured dot; add the section `statsByCustomName` after "By project", shown only when `byCustomName` is not empty
    - Draw the dot of each "By project" row in `activityMainColor` of the project's Main_Type
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6, 15.7, 15.8, 15.9, 15.10, 15.11, 15.12, 15.14_

  - [x]* 11.5 Write tests in `test/providers/statistics_subtypes_test.dart`
    - Test the "By project" sum regardless of Subtype, the "Other by name" grouping and ordering, and the daily and weekly periods
    - **Property 4: Statistics partition**
    - For random lists of entries, the sum of the Main_Type totals equals the total tracked time, and per Main_Type the Subtype totals plus the time without a Subtype equal its total
    - **Validates: Requirements 15.2, 15.3, 15.4, 15.13**

- [x] 12. Checkpoint — full test run
  - Ensure `flutter analyze` is clean and `flutter test` passes with no skipped new tests; ask the user if questions arise

- [x] 13. Visual verification
  - [x] 13.1 Check the App on three themes
    - Run the App on Linux desktop under Xvfb (see `timelog_app/.agents/MEMORY.md` for the Flutter setup in the sandbox) and take screenshots of the entry sheet for `Práce`, `Zábava`, `Seberozvoj`, `Jídlo` and `Ostatní`, of the history and of the statistics on Midnight, Ember and Paper
    - Compare them with the approved previews; fix any difference in colour, spacing or the Subtype_Block; report the Paper colours of the three `Seberozvoj` shades, which are the least certain
    - _Requirements: 4.1, 4.6, 6.4, 7.3, 7.4, 7.7, 14.2, 15.3_

- [x] 14. Documentation and release
  - [x] 14.1 Sync the documentation
    - Update `README.md` (repository root; it still lists the old types), `timelog_app/DOCS.md` and `timelog_app/CLAUDE.md` (its conventions section describes the parallel lists and the work-type rule): describe the twelve Main_Types, their Subtypes, the Custom_Name of `Ostatní`, the separated suggestions, the category of Task_Projects and schema version 8; run every command that the documents contain
    - Correct the bottom-tab line in `.kiro/steering/flutter-timelog.md` (it still lists History as a tab and omits Tasks) and mark the implemented items in `ROADMAP.md`
    - Replace the screenshots in `README.md` with the ones taken in task 13.1 only if the user agrees
    - _Requirements: 19.4, 19.5_

  - [x] 14.2 Prepare the release change
    - Change `version` in `timelog_app/pubspec.yaml` to `1.1.0+2` as a change of its own, separate from all other changes, so that it can be committed alone
    - After that commit exists, create the git tag `v1.1.0` on it
    - _Requirements: 19.1, 19.2, 19.3_

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "2.1"] },
    { "id": 1, "tasks": ["1.2", "3.1"] },
    { "id": 2, "tasks": ["1.3", "1.4", "1.5", "1.6", "3.2"] },
    { "id": 3, "tasks": ["3.3", "3.4", "5.1", "6.1"] },
    { "id": 4, "tasks": ["5.2", "5.3", "6.2", "7.1", "7.2", "7.3"] },
    { "id": 5, "tasks": ["7.4", "10.1", "11.1", "11.2", "11.3"] },
    { "id": 6, "tasks": ["7.5", "8.1", "8.2", "8.3", "10.2", "11.4", "11.5"] },
    { "id": 7, "tasks": ["8.4", "10.3"] },
    { "id": 8, "tasks": ["13.1", "14.1"] },
    { "id": 9, "tasks": ["14.2"] }
  ]
}
```

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP; the test tasks still protect the migration and the statistics, so skipping `3.4` and `10.5` is not recommended
- Run Flutter through `/opt/flutter/bin` and with the ad-hoc `GIT_CONFIG_*` override described in `timelog_app/.agents/MEMORY.md`; `fvm` does not work in the sandbox and `build/` may need to be removed if a stale CMake cache breaks a Linux build
- Before the first task, run `flutter analyze` and `flutter test` once and record which tests already fail, so that a failure caused by this work can be told apart from an existing one
- With the sandbox's Flutter 3.47 (Dart 3.13), `build_runner` fails because the locked `analyzer` 7.6 cannot read Dart's dot-shorthand syntax (`Missing implementation of visitDotShorthandPropertyAccess`). The Drift code was generated in a scratch copy of the project with a newer `drift_dev`, the two table-manager relation helpers that the newer generator emits were put back to the form of the locked `drift` 2.28, and `timer_service.freezed.dart` was edited by hand to the same shape the generator produces. Regenerate both with the pinned Flutter 3.44.6 when it is available; the result should be identical or differ only in formatting
- The visual check (task 13.1) was done by rendering the real screens with `flutter test` on Linux (a system font stands in for Sora, because the font files in `assets/fonts` are empty in this checkout), since the Linux desktop build needs GStreamer headers that cannot be downloaded offline
- Generated files (`database.g.dart`, `timer_service.freezed.dart`, `lib/l10n/generated/*`) are committed together with the source change that triggers them
- The legacy `entertainment_type` column stays in the table on purpose; do not drop it and do not write to it
- The Type_Keys are Czech identifiers persisted in the Database and are never translated or renamed; the rename of `Přesun` to "Travel" / "Cestování" is a label change only
- Existing Legacy_Entries of `Práce` become unpaid work in the Migration; that was decided by the user
- The Tasks tab and the Timer tab share one suggestion list per category. A Task_Project gets its category when it is created (existing ones become unpaid work) and can be changed later from a menu on a long press of the chip (that gesture used to delete directly); this is an interpretation of the request to review
- The create-project dialog is the only place of the Tasks tab with a free-text project field; the project chips get a coloured dot and the long-press menu; renaming a project is deliberately not added, because time entries store the project name as text
- Colours and labels come from the approved previews described in `ROADMAP.md`; if a colour is changed during the visual check, change it in the registry and in the design's colour table together
- The `lib/ui/widgets/` directory is already over the flat-directory ceiling; new widgets go into `lib/ui/widgets/activity_picker/` and the existing ones are not moved by this spec
- Commits use the author identity from the global git standard, follow the conventional format and carry no tool attribution (no `Co-Authored-By` or session trailers); the version change is its own commit, and the dependency or generated-code changes are not mixed into behaviour commits where avoidable
