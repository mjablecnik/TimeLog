# Requirements Document

## Introduction

TimeLog (`timelog_app/`, Flutter) tags every logged time entry with one of nine flat activity types. Only `Zábava` has a sub-classification (active / passive), stored in a dedicated column and special-cased in three entry sheets, the statistics provider and the history card. This feature turns that special case into a general model: twelve main types, each with an optional fixed list of subtypes, a free-text name for a catch-all `Ostatní` type, a redesigned colour palette that gives every type and subtype its own colour, and name suggestions that are kept separate per category and shared between the Timer tab and the Tasks tab.

The scope covers: the type registry in `lib/core/activity_types.dart`; the `TimeEntries` table and a schema migration from version 7 to 8 in `lib/data/`; `DatabaseService` and the timer prefill in `lib/services/`; the project suggestion store (`ProjectService`) and its provider; the `TaskProjects` table, `TaskService` and the project selector of the Tasks tab; the three entry sheets (`DescriptionSheet`, `EditSheet`, `ManualEntrySheet`) in `lib/ui/widgets/`; the history card, the day timeline painter and the statistics screen; the English and Czech localization files; and the project documentation and version. The visual contract for the palette and the screens is the pair of approved preview pages `timelog_app/.design/activity-palette.html` (types, subtypes and colours on the three themes) and `timelog_app/.design/activity-types-ux.html` (entry sheet, history, statistics and the Tasks tab); `ROADMAP.md` at the repository root records every decision this specification implements.

Four decisions carry the whole design. First, paid versus unpaid work is a subtype of `Práce`, not a separate type, so one mechanism serves every type that has subtypes. Second, a subtype is always preselected in an entry sheet, so a missing subtype can never block saving. Third, the new `Ostatní` type stores its name in its own column, separate from the project column, so the two never mix in storage, suggestions or statistics. Fourth, colours are never stored: they are computed from the type and subtype, so the new palette applies to all existing entries at once.

## Glossary

- **App**: The TimeLog Flutter application in `timelog_app/`.
- **Database**: The Drift `AppDatabase` in `lib/data/database.dart`.
- **Time_Entry**: One row of the `TimeEntries` table: a logged interval with description, Main_Type, optional Subtype, optional project and optional Custom_Name.
- **Legacy_Entry**: A Time_Entry written by an App version before this feature (schema version 7 or older).
- **Activity_Registry**: The single data structure in `lib/core/activity_types.dart` that defines every Main_Type, its Subtypes, labels and colours, and the helper functions that read it.
- **Main_Type**: One of the twelve top-level activity types, identified by a Type_Key.
- **Type_Key**: The stable identifier of a Main_Type that is persisted in `time_entries.activity_type` and never translated.
- **Subtype**: A refinement of a Main_Type, identified by a Subtype_Key that is unique within its Main_Type.
- **Subtype_Key**: The stable identifier of a Subtype that is persisted in `time_entries.subtype` and never translated.
- **Main_Color**: The colour of a Main_Type, used for its chip and as the fallback colour of an entry without a Subtype.
- **Entry_Color**: The colour computed for a Time_Entry: the Subtype colour when the entry has a valid Subtype, otherwise the Main_Color.
- **Dark_Themes**: The Ember and Midnight themes of `AppThemeData`.
- **Light_Theme**: The Paper theme of `AppThemeData`.
- **Entry_Sheet**: Any of `DescriptionSheet`, `EditSheet` and `ManualEntrySheet`.
- **Activity_Picker**: The shared widget that every Entry_Sheet uses to choose a Main_Type, its Subtype and its extra field.
- **Subtype_Block**: The framed section of the Activity_Picker that holds the Subtype chips of the selected Main_Type.
- **Custom_Name**: The free-text name of a `Ostatní` Time_Entry, stored in `time_entries.custom_name`.
- **Project_Field**: The optional project text field shown for `Práce` and `Domácí práce`.
- **Suggestion_Scope**: One of `workPaid`, `workUnpaid`, `housework` and `other`; each has its own list of suggested names. It is shown to the user as a category named "Paid work", "Unpaid work", "Housework" and "Other" (Czech "Placená práce", "Neplacená práce", "Domácí práce", "Ostatní").
- **Suggestion_Store**: The `ProjectService` in `lib/services/project_service.dart`, extended to keep one list per Suggestion_Scope.
- **Task_Project**: A project of the Tasks tab (a row of the `TaskProjects` table) that groups tasks; it now also carries a Suggestion_Scope.
- **Task_Project_Names**: The names of the Task_Projects of one Suggestion_Scope, returned by `TaskService.getProjectNames(scope)`.
- **Task_Project_Dialog**: The dialog of the project selector in which the user creates a Task_Project or, in edit mode, changes the category of an existing one.
- **Project_Selector**: The `ProjectSelector` chip bar of the Tasks tab.
- **Task_Service**: The `TaskService` in `lib/services/task_service.dart`.
- **Prefill**: The draft description, type, Subtype, project and Custom_Name that the Timer_Service keeps between a timer pause and the Entry_Sheet.
- **Timer_Service**: The `TimerService` in `lib/services/timer_service.dart`.
- **History_Card**: The `HistoryEntryCard` widget.
- **Day_Timeline**: The `TimelinePainter` strip drawn on the statistics screen.
- **Statistics_Screen**: The `StatisticsScreen` and the `statisticsProvider` that feeds it.
- **Migration**: The Drift `onUpgrade` step that moves the Database from schema version 7 to 8.
- **Localization_Files**: `lib/l10n/app_en.arb` and `lib/l10n/app_cs.arb` and the generated `AppLocalizations` classes.

## Requirements

### Requirement 1: Single Activity Registry

**User Story:** As a developer, I want every type, subtype, label and colour defined in one place, so that the picker, the cards, the timeline and the statistics can never disagree.

#### Acceptance Criteria

1. THE Activity_Registry SHALL define each Main_Type with a Type_Key, a localized label, a Main_Color for Dark_Themes, a Main_Color for the Light_Theme, an ordered list of Subtypes and the kind of extra field the Main_Type shows
2. THE Activity_Registry SHALL define each Subtype with a Subtype_Key, a localized label, a colour for Dark_Themes and a colour for the Light_Theme
3. THE Activity_Registry SHALL provide a function that returns the Entry_Color for a Type_Key, an optional Subtype_Key and a theme brightness
4. THE Activity_Registry SHALL provide a function that returns the Suggestion_Scope for a Type_Key and an optional Subtype_Key
5. THE App SHALL read the list of Main_Types, Subtypes, labels and colours only from the Activity_Registry
6. THE Activity_Registry SHALL keep every Type_Key listed in the Time_Entry data of previous versions unchanged

### Requirement 2: Main Types

**User Story:** As a user, I want a type for every common kind of activity, so that I rarely have to describe an entry as something it is not.

#### Acceptance Criteria

1. THE Activity_Registry SHALL define exactly these twelve Main_Types in this order: `Práce`, `Domácí práce`, `Meeting`, `Komunikace`, `Přesun`, `Zábava`, `Cvičení`, `Seberozvoj`, `Odpočinek`, `Hygiena`, `Jídlo`, `Ostatní`
2. THE Activity_Registry SHALL show the `Přesun` Main_Type with the English label "Travel" and the Czech label "Cestování"
3. THE Activity_Registry SHALL keep the persisted Type_Key `Přesun` unchanged
4. THE Activity_Registry SHALL show `Meeting` with the English label "Meeting" and the Czech label "Meeting"
5. THE Activity_Registry SHALL show `Komunikace` with the English label "Communication" and the Czech label "Komunikace"
6. THE Activity_Registry SHALL show `Ostatní` with the English label "Other" and the Czech label "Ostatní"
7. THE Activity_Registry SHALL show the Project_Field for `Práce` and `Domácí práce`
8. THE Activity_Registry SHALL show the Custom_Name field for `Ostatní`
9. THE Activity_Registry SHALL show neither the Project_Field nor the Custom_Name field for every other Main_Type

### Requirement 3: Subtypes

**User Story:** As a user, I want to refine an entry, for example paid or unpaid work, so that my statistics tell these apart.

#### Acceptance Criteria

1. THE Activity_Registry SHALL define the Subtypes `paid` and `unpaid`, in this order, for `Práce`
2. THE Activity_Registry SHALL define the Subtypes `active` and `passive`, in this order, for `Zábava`
3. THE Activity_Registry SHALL define the Subtypes `walk`, `running` and `gym`, in this order, for `Cvičení`
4. THE Activity_Registry SHALL define the Subtypes `books`, `study` and `ai`, in this order, for `Seberozvoj`
5. THE Activity_Registry SHALL define the Subtypes `active` and `passive`, in this order, for `Odpočinek`
6. THE Activity_Registry SHALL define the Subtypes `general` and `toilet`, in this order, for `Hygiena`
7. THE Activity_Registry SHALL define the Subtypes `breakfast`, `lunch`, `dinner` and `snack`, in this order, for `Jídlo`
8. THE Activity_Registry SHALL define no Subtypes for `Domácí práce`, `Meeting`, `Komunikace`, `Přesun` and `Ostatní`
9. THE Activity_Registry SHALL keep every Subtype_Key unique within its Main_Type
10. THE Activity_Registry SHALL define the English and Czech labels of every Subtype as listed in the design document

### Requirement 4: Colours

**User Story:** As a user, I want every type and subtype to have its own colour that is readable on every theme, so that the timeline and the statistics are easy to read at a glance.

#### Acceptance Criteria

1. THE Activity_Registry SHALL give every Main_Type and every Subtype the colour values listed in the design document for Dark_Themes and for the Light_Theme
2. WHEN a Time_Entry has a Subtype that the Activity_Registry defines for its Main_Type, THE Activity_Registry SHALL return the Subtype colour as the Entry_Color
3. WHEN a Time_Entry has no Subtype, THE Activity_Registry SHALL return the Main_Color as the Entry_Color
4. IF a Time_Entry has a Subtype_Key that the Activity_Registry does not define for its Main_Type, THEN THE Activity_Registry SHALL return the Main_Color as the Entry_Color
5. IF a Time_Entry has a Type_Key that the Activity_Registry does not define, THEN THE Activity_Registry SHALL return a neutral grey as the Entry_Color
6. THE Activity_Registry SHALL choose the Light_Theme colours when the active theme is the Light_Theme, and the Dark_Themes colours otherwise
7. THE Activity_Registry SHALL make the `paid` colour of `Práce` darker than the `unpaid` colour on every theme

### Requirement 5: Database Schema and Migration

**User Story:** As a user, I want my existing entries to keep working after the update, so that I lose no history.

#### Acceptance Criteria

1. THE Database SHALL report schema version 8
2. THE Database SHALL store the Subtype_Key of a Time_Entry in a nullable text column `subtype`
3. THE Database SHALL store the Custom_Name of a Time_Entry in a nullable text column `custom_name` limited to 200 characters
4. WHEN the Migration runs, THE Migration SHALL add the columns `subtype` and `custom_name` to the `time_entries` table
5. WHEN the Migration runs, THE Migration SHALL set `subtype` to `unpaid` for every Legacy_Entry whose activity type is `Práce`
6. WHEN the Migration runs, THE Migration SHALL set `subtype` to `active` for every Legacy_Entry whose activity type is `Zábava` and whose `entertainment_type` is `Aktivní zábava`
7. WHEN the Migration runs, THE Migration SHALL set `subtype` to `passive` for every Legacy_Entry whose activity type is `Zábava` and whose `entertainment_type` is `Pasivní zábava`
8. WHEN the Migration runs, THE Migration SHALL leave `subtype` empty for every other Legacy_Entry
9. WHEN the Migration runs, THE Migration SHALL leave every other column of every Legacy_Entry unchanged
10. THE Migration SHALL keep the legacy `entertainment_type` column in the table and THE App SHALL NOT write to it
11. WHEN the Database is created on a device without a previous version, THE Database SHALL create the table with the new columns and run no data update
12. THE Migration SHALL keep the number of rows in `time_entries` unchanged
13. WHEN the Migration runs, THE Migration SHALL add to the `task_projects` table a text column `scope` that holds the name of a Suggestion_Scope
14. WHEN the Migration runs, THE Migration SHALL set `scope` to `workUnpaid` for every existing Task_Project
15. THE Migration SHALL keep the number of rows and every other column of `task_projects` unchanged
16. WHEN the Migration runs on a Database of schema version 6 or older, THE Migration SHALL create the task tables with the column `scope` and SHALL NOT add the column a second time
17. WHEN the Migration runs on a Database of schema version 5 or older, THE Migration SHALL complete every earlier upgrade step before the steps of schema version 8

### Requirement 6: Type Selection in the Entry Sheets

**User Story:** As a user, I want to pick the type of an entry in the same way everywhere, so that adding, editing and manually logging an entry feel the same.

#### Acceptance Criteria

1. THE Activity_Picker SHALL be the only widget that the Entry_Sheets use to select a Main_Type, a Subtype and the extra field
2. THE Activity_Picker SHALL show a caption "Type" in English and "Typ" in Czech above the Main_Type chips
3. THE Activity_Picker SHALL show one chip for each Main_Type of the Activity_Registry, in registry order
4. WHEN a Main_Type is selected, THE Activity_Picker SHALL draw its chip with the Main_Color as border and text colour and a 20 percent tint of the Main_Color as background
5. THE Activity_Picker SHALL draw the chip of `Ostatní` with a dashed border
6. WHEN the user taps a Main_Type chip, THE Activity_Picker SHALL select that Main_Type and remember it as the last selected Main_Type
7. THE Activity_Picker SHALL let the Main_Type chips wrap onto as many rows as the screen width requires

### Requirement 7: Subtype Block

**User Story:** As a user, I want the subtype choice to be clearly separated from the type choice, so that I never overlook it.

#### Acceptance Criteria

1. WHILE the selected Main_Type has at least one Subtype, THE Activity_Picker SHALL show a Subtype_Block below the Main_Type chips
2. WHILE the selected Main_Type has no Subtype, THE Activity_Picker SHALL NOT show a Subtype_Block
3. THE Subtype_Block SHALL be separated from the Main_Type chips by a vertical gap of at least 24 logical pixels
4. THE Subtype_Block SHALL be drawn as a framed block with a border in the Main_Color of the selected Main_Type and a faint tint of the Main_Color as background
5. THE Subtype_Block SHALL show a heading "Refine: <type label>" in English and "Upřesni: <type label>" in Czech
6. THE Subtype_Block SHALL show the hint "Choose one" in English and "Vyber jednu možnost" in Czech next to the heading
7. THE Subtype_Block SHALL show one chip for each Subtype of the selected Main_Type, in registry order, drawn with the Subtype colour
8. WHEN the user taps a Subtype chip, THE Activity_Picker SHALL select that Subtype and remember it as the last selected Subtype of its Main_Type
9. WHEN the user selects a different Main_Type, THE Activity_Picker SHALL replace the selected Subtype with the preselected Subtype of the new Main_Type, or with no Subtype when the new Main_Type has none

### Requirement 8: Subtype Preselection

**User Story:** As a user, I want a sensible subtype to be chosen for me, so that saving is never blocked and repeated entries need no extra taps.

#### Acceptance Criteria

1. WHEN a Main_Type with Subtypes becomes selected in a new entry, THE Activity_Picker SHALL preselect the Subtype that the user last selected for that Main_Type
2. IF the user never selected a Subtype for that Main_Type, THEN THE Activity_Picker SHALL preselect the first Subtype of the Main_Type in registry order
3. IF the remembered Subtype_Key is not defined for the Main_Type in the Activity_Registry, THEN THE Activity_Picker SHALL preselect the first Subtype of the Main_Type
4. THE Activity_Picker SHALL remember the last selected Subtype separately for each Main_Type
5. WHEN an existing Time_Entry is opened in the `EditSheet`, THE Activity_Picker SHALL preselect the stored Subtype of the entry
6. IF an existing Time_Entry of a Main_Type with Subtypes has no Subtype, THEN THE Activity_Picker SHALL preselect the first Subtype of the Main_Type in the `EditSheet`
7. THE Entry_Sheet SHALL NOT disable its save, submit or skip actions because of the Subtype selection

### Requirement 9: Project Field and Custom Name

**User Story:** As a user, I want to enter a project for work and my own name for anything else, so that the statistics can show what I really spent time on.

#### Acceptance Criteria

1. WHILE the selected Main_Type is `Práce` or `Domácí práce`, THE Activity_Picker SHALL show the Project_Field
2. WHILE the selected Main_Type is `Ostatní`, THE Activity_Picker SHALL show the Custom_Name field instead of the Project_Field
3. WHILE the selected Main_Type has no extra field, THE Activity_Picker SHALL show neither field
4. THE Activity_Picker SHALL show the hint "Project name..." in the Project_Field in English and "Název projektu..." in Czech
5. THE Activity_Picker SHALL show the hint "What did you do?" in the Custom_Name field in English and "Co jsi dělal?" in Czech
6. WHILE the Custom_Name field is shown, THE Activity_Picker SHALL list the suggestions of the Suggestion_Scope `other` below the field
7. WHILE the selected Main_Type is `Ostatní` and the trimmed Custom_Name is empty, THE Entry_Sheet SHALL disable its submit and save actions
8. WHEN the Skip action of the `DescriptionSheet` saves an entry of `Ostatní`, THE Entry_Sheet SHALL save the entry even when the Custom_Name is empty
9. WHEN the user selects a Main_Type without the Project_Field, THE Entry_Sheet SHALL discard the project text of the form before saving
10. WHEN the user selects a Main_Type other than `Ostatní`, THE Entry_Sheet SHALL discard the Custom_Name text of the form before saving

### Requirement 10: Separate Name Suggestions

**User Story:** As a user, I want the suggestions for paid work, unpaid work, housework and other activities to be separate, so that a name I enter in one is not offered in the others.

#### Acceptance Criteria

1. THE Suggestion_Store SHALL keep a separate list of names for each of the Suggestion_Scopes `workPaid`, `workUnpaid`, `housework` and `other`
2. THE Activity_Registry SHALL map `Práce` with the Subtype `paid` to `workPaid`, `Práce` with the Subtype `unpaid` to `workUnpaid`, `Domácí práce` to `housework` and `Ostatní` to `other`
3. WHEN an Entry_Sheet saves a Time_Entry with a non-empty project or Custom_Name, THE Suggestion_Store SHALL add the name to the list of the Suggestion_Scope of that entry only
4. WHEN a name already exists in a list ignoring letter case, THE Suggestion_Store SHALL update its last-used time and keep the casing of the latest input instead of adding a duplicate
5. THE Suggestion_Store SHALL return the names of one Suggestion_Scope sorted by last-used time, newest first
6. THE Suggestion_Store SHALL remove a name that has not been used for 30 days from its list
7. WHEN the user changes the Subtype of `Práce` in an Entry_Sheet, THE Activity_Picker SHALL show the suggestions of the Suggestion_Scope of the newly selected Subtype and keep the text already typed in the field
8. WHEN the suggestions of a Suggestion_Scope are listed, THE Suggestion_Store SHALL merge the Task_Project_Names of that same Suggestion_Scope in front of the stored names and remove duplicates ignoring letter case
9. THE Suggestion_Store SHALL NOT offer the name of a Task_Project in the suggestions of any other Suggestion_Scope than its own
10. WHEN the App starts the first time after the update, THE Suggestion_Store SHALL fill the lists of `workUnpaid` and `housework` from the project names of the Legacy_Entries of `Práce` and `Domácí práce`, with the latest end time of each name as last-used time
11. WHEN the lists were filled from the Legacy_Entries, THE Suggestion_Store SHALL remove the previous combined list from the stored preferences
12. THE Suggestion_Store SHALL perform the filling of the lists at most once
13. WHEN the user changes the Subtype of an existing Time_Entry in the `EditSheet`, THE Suggestion_Store SHALL add the name to the new Suggestion_Scope only when the entry is saved

### Requirement 11: Saving and Editing Entries

**User Story:** As a user, I want the type, subtype and name I picked to be saved with the entry, so that they appear in the history and the statistics.

#### Acceptance Criteria

1. WHEN an Entry_Sheet saves a new Time_Entry, THE Database SHALL store the Type_Key, the Subtype_Key and the Custom_Name of the entry in their columns
2. WHEN an Entry_Sheet saves a Time_Entry of a Main_Type without Subtypes, THE Database SHALL store no Subtype_Key
3. WHEN an Entry_Sheet saves a Time_Entry whose Main_Type is not `Ostatní`, THE Database SHALL store no Custom_Name
4. WHEN an Entry_Sheet saves a Time_Entry whose Main_Type has no Project_Field, THE Database SHALL store no project
5. WHEN the `EditSheet` saves an existing Time_Entry, THE Database SHALL update the Type_Key, the Subtype_Key, the project and the Custom_Name of the entry together with the other edited fields
6. THE `DatabaseService` SHALL accept a `subtype` and a `customName` in its `updateDescription` method in place of the `entertainmentType` parameter
7. WHEN an Entry_Sheet inserts a Time_Entry, THE Entry_Sheet SHALL pass the Subtype_Key and the Custom_Name in the `TimeEntriesCompanion` given to `insertTimeEntry`
8. THE App SHALL NOT write the `entertainment_type` column of any Time_Entry

### Requirement 12: Timer Prefill

**User Story:** As a user, I want a draft I started while the timer was paused to keep its type, subtype and name, so that I do not choose them again.

#### Acceptance Criteria

1. WHEN the user saves a draft in the `DescriptionSheet`, THE Timer_Service SHALL persist the Type_Key, the Subtype_Key, the project and the Custom_Name of the draft
2. WHEN the `DescriptionSheet` opens with a persisted draft, THE Activity_Picker SHALL show the persisted Main_Type, Subtype, project and Custom_Name
3. WHEN the draft is cleared, THE Timer_Service SHALL remove the persisted Subtype_Key and Custom_Name
4. IF a draft persisted by a previous version contains the legacy value `Aktivní zábava` or `Pasivní zábava`, THEN THE Timer_Service SHALL read it as the Subtype `active` or `passive` of `Zábava` and remove the legacy key
5. IF a persisted Subtype_Key is not defined for the persisted Main_Type, THEN THE Timer_Service SHALL ignore the Subtype_Key

### Requirement 13: History Card

**User Story:** As a user, I want every entry in the history to show its type and its subtype, so that I recognise it quickly.

#### Acceptance Criteria

1. THE History_Card SHALL show a badge with the localized label of the Main_Type of the entry
2. THE History_Card SHALL draw the badge with the Entry_Color of the entry
3. WHEN the entry has a Subtype and a project, THE History_Card SHALL show one line "<project> · <Subtype label>" below the description, with a dot in the Entry_Color before it
4. WHEN the entry has a Subtype and no project, THE History_Card SHALL show one line with the Subtype label below the description, with a dot in the Entry_Color before it
5. WHEN the entry has no Subtype and a project, THE History_Card SHALL show one line with the project below the description
6. WHEN the entry is of `Ostatní` and has a Custom_Name, THE History_Card SHALL show one line with the Custom_Name below the description, with a dot in the Entry_Color before it
7. THE History_Card SHALL NOT show the legacy `entertainment_type` value

### Requirement 14: Day Timeline

**User Story:** As a user, I want the day strip in the statistics to be coloured by subtype, so that the day's rhythm is visible in detail.

#### Acceptance Criteria

1. THE Day_Timeline SHALL draw each Time_Entry block with the Entry_Color of the entry
2. THE Day_Timeline SHALL choose the Light_Theme colours when the active theme is the Light_Theme

### Requirement 15: Statistics

**User Story:** As a user, I want the statistics to break time down by type, subtype, project and name, so that I see where my time goes.

#### Acceptance Criteria

1. THE Statistics_Screen SHALL list every Main_Type that has tracked time in the selected period, sorted by tracked time, longest first
2. THE Statistics_Screen SHALL show for each listed Main_Type its label, its tracked time and its share of the total tracked time
3. THE Statistics_Screen SHALL draw the bar of a Main_Type as stacked segments, one for each Subtype with tracked time, in registry order, each in its Subtype colour
4. WHEN a Main_Type with Subtypes has tracked time of entries without a Subtype, THE Statistics_Screen SHALL draw that time as a segment in the Main_Color
5. THE Statistics_Screen SHALL draw the bar of a Main_Type without Subtypes as one segment in its Main_Color
6. THE Statistics_Screen SHALL show below the bar of a Main_Type one indented row for each of its Subtypes with tracked time, with a dot in the Subtype colour, the Subtype label and the tracked time
7. THE Statistics_Screen SHALL keep these Subtype rows visible without any user action
8. THE Statistics_Screen SHALL scale every bar to the Main_Type with the longest tracked time
9. THE Statistics_Screen SHALL keep the section "By project" for the entries of `Práce` and `Domácí práce` with a non-empty project, summed by project name regardless of Subtype
10. WHEN at least one entry of `Ostatní` with a non-empty Custom_Name exists in the period, THE Statistics_Screen SHALL show a section "Other by name" in English and "Ostatní podle názvu" in Czech
11. THE Statistics_Screen SHALL list in the section "Other by name" one row for each Custom_Name, summed by name ignoring letter case, sorted by tracked time, longest first
12. THE Statistics_Screen SHALL apply all of the above to the daily and the weekly period
13. THE Statistics_Screen SHALL keep the sum of the tracked time of all Subtype rows and Main_Color segments of a Main_Type equal to the tracked time of that Main_Type
14. THE Statistics_Screen SHALL draw the dot of a row of the section "By project" in the Main_Color of the Main_Type of that project

### Requirement 16: Localization

**User Story:** As a user, I want every new label in English and Czech, so that the App stays fully localized.

#### Acceptance Criteria

1. THE Localization_Files SHALL contain an English and a Czech label for every Main_Type and every Subtype of the Activity_Registry
2. THE Localization_Files SHALL contain English and Czech texts for the caption "Type", the heading of the Subtype_Block with a `type` placeholder, the hint of the Subtype_Block, the hint of the Custom_Name field and the heading of the section "Other by name"
3. THE App SHALL show no hard-coded user-facing text for any Main_Type, Subtype or new caption
4. THE App SHALL translate only the labels of the Activity_Registry and never the Type_Keys and Subtype_Keys

### Requirement 17: Legacy Entries Display

**User Story:** As a user, I want my old entries to look correct under the new palette, so that the history stays readable.

#### Acceptance Criteria

1. WHEN a Legacy_Entry of `Práce` is shown, THE App SHALL show it as unpaid work with the colour of the Subtype `unpaid`
2. WHEN a Legacy_Entry of `Zábava` without an `entertainment_type` is shown, THE App SHALL show it with the Main_Color of `Zábava`
3. WHEN a Legacy_Entry of any other Main_Type is shown, THE App SHALL show it with the Main_Color of its Main_Type
4. THE App SHALL show every Legacy_Entry of `Přesun` under the label "Travel" in English and "Cestování" in Czech

### Requirement 18: Task Project Categories and Shared Suggestions

**User Story:** As a user, I want the Tasks tab to use the same categories and the same name suggestions as the Timer tab, so that a project I know from one place is offered in the other.

#### Acceptance Criteria

1. THE Database SHALL store the Suggestion_Scope of each Task_Project in the column `task_projects.scope`
2. WHEN the user opens the Task_Project_Dialog, THE Task_Project_Dialog SHALL show a caption "Category" in English and "Kategorie" in Czech with one chip for each Suggestion_Scope, labelled with its category name
3. WHEN the user opens the Task_Project_Dialog, THE Task_Project_Dialog SHALL preselect the Suggestion_Scope that the user last selected there, or `workUnpaid` when none was selected
4. THE Task_Project_Dialog SHALL show the name field as the same `SuggestionField` widget that the Activity_Picker uses
5. THE Task_Project_Dialog SHALL list in the name field the suggestions of the selected Suggestion_Scope
6. WHEN the user selects another Suggestion_Scope in the Task_Project_Dialog, THE Task_Project_Dialog SHALL list the suggestions of that scope and keep the text already typed
7. WHEN the user confirms the Task_Project_Dialog, THE Task_Service SHALL create the Task_Project with the typed name and the selected Suggestion_Scope
8. WHERE no Suggestion_Scope is given, THE Task_Service SHALL create a Task_Project with the Suggestion_Scope `workUnpaid`
9. THE Project_Selector SHALL show before the name on the chip of each Task_Project a dot in the colour of its Suggestion_Scope
10. THE Suggestion_Store and the Tasks tab SHALL read the suggestions of a Suggestion_Scope through the same provider
11. WHEN a Task_Project is deleted, THE Suggestion_Store SHALL no longer offer its name, unless an Entry_Sheet saved the same name for the same Suggestion_Scope
12. WHEN the user long-presses the chip of a Task_Project, THE Project_Selector SHALL open a menu with the actions "Edit category" and "Delete"
13. WHEN the user chooses "Delete" in the menu, THE Project_Selector SHALL show the existing confirmation for deleting the Task_Project
14. WHEN the user chooses "Edit category" in the menu, THE Project_Selector SHALL open the Task_Project_Dialog in edit mode for that Task_Project
15. WHILE the Task_Project_Dialog is in edit mode, THE Task_Project_Dialog SHALL show the title "Edit category", the name of the Task_Project as text that cannot be edited, the caption "Category" and the four category chips with the current Suggestion_Scope selected
16. WHEN the user confirms the Task_Project_Dialog in edit mode, THE Task_Service SHALL change the Suggestion_Scope of that Task_Project and leave its name and its tasks unchanged
17. WHEN the Suggestion_Scope of a Task_Project changes, THE Suggestion_Store SHALL offer its name in the suggestions of the new Suggestion_Scope and no longer in those of the old one, unless an Entry_Sheet saved the same name for the old scope
18. WHEN the Suggestion_Scope of a Task_Project changes, THE Database SHALL leave every Time_Entry unchanged
19. IF the user cancels the Task_Project_Dialog, THEN THE Task_Project_Dialog SHALL change nothing
20. THE Project_Selector SHALL give the chip of each Task_Project an accessibility label made of its name and its category name
21. THE Project_Selector SHALL keep the existing delete button on the chip of each Task_Project unchanged

### Requirement 19: Release and Documentation

**User Story:** As the maintainer, I want the release to be recorded properly, so that the version history stays traceable.

#### Acceptance Criteria

1. WHEN the feature is complete, THE App SHALL declare the version `1.1.0+2` in `pubspec.yaml`
2. THE App SHALL change the version in a commit that contains no other change
3. WHEN the version commit exists, THE repository SHALL carry a git tag `v1.1.0` on that commit
4. THE documentation SHALL describe the twelve Main_Types, their Subtypes, the Custom_Name of `Ostatní`, the separated suggestions and the schema version 8 in `README.md`, `DOCS.md` and `timelog_app/CLAUDE.md`
5. THE `README.md` SHALL list the types that the App really offers, as defined by the Activity_Registry
