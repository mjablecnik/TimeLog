# Implementation Plan: Task Management

## Overview

This plan implements a Task Management feature for the TimeLog Flutter app, adding a dedicated "Úkoly" tab with TODO items organized by projects. The approach is bottom-up: database tables and migration first, then service layer, then providers, then UI components, then navigation wiring and timer integration. Each task builds on the previous, ensuring no orphaned code. Property-based tests validate correctness properties from the design using `glados`.

## Tasks

- [ ] 1. Set up database tables and migration
  - [ ] 1.1 Create TaskProjects and Tasks Drift table definitions
    - Create `lib/data/task_project.dart` with the `TaskProjects` table class (id auto-increment PK, name text 1–100 chars, createdAt dateTime default now)
    - Create `lib/data/task.dart` with the `Tasks` table class (id auto-increment PK, title text 1–200 chars, description text nullable 0–1000 chars, deadline text nullable, projectId integer nullable FK to TaskProjects with cascade delete, sortPosition integer default 0, isCompleted boolean default false, completedAt dateTime nullable, isArchived boolean default false, createdAt dateTime default now)
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

  - [ ] 1.2 Register tables and add migration to AppDatabase
    - Add both new tables to the `@DriftDatabase(tables: [..., TaskProjects, Tasks])` annotation in `lib/data/database.dart`
    - Increment `schemaVersion` from 6 to 7
    - Add migration logic in `onUpgrade`: if `from < 7`, create `taskProjects` table first, then `tasks` table (FK dependency order)
    - Run `fvm flutter pub run build_runner build --delete-conflicting-outputs` to regenerate Drift code
    - _Requirements: 8.6_

  - [ ] 1.3 Implement Task and TaskProject CRUD methods in AppDatabase
    - Add TaskProject methods: `getAllTaskProjects()` ordered alphabetically by name, `watchAllTaskProjects()` stream, `insertTaskProject()`, `deleteTaskProject()`
    - Add Task methods: `getTasksForProject(int? projectId, {bool includeArchived})` ordered by sortPosition ascending, `watchTasksForProject(int? projectId, {bool includeArchived})` stream, `insertTask()`, `updateTaskFields()`, `deleteTask()`
    - Add ordering method: `updateTaskSortPositions(List<TaskItem> tasks)` batch update
    - Add completion/archive methods: `markTaskCompleted(int id, DateTime completedAt)`, `unmarkTaskCompleted(int id)`, `archiveTask(int id)`, `unarchiveTask(int id, int newSortPosition)`, `getExpiredCompletedTasks()` (completed, not archived, completedAt > 12h ago)
    - Add helper: `getTaskProjectNames()` returning `List<String>` of all project names
    - _Requirements: 2.4, 2.7, 3.4, 3.6, 3.8, 4.1, 4.5, 5.1, 5.3, 5.8, 5.10, 7.1, 8.3_

  - [ ]* 1.4 Write property test: Cascade delete removes project and all tasks
    - **Property 4: Cascade delete removes project and all associated tasks**
    - **Validates: Requirements 2.7, 8.3**

  - [ ]* 1.5 Write property test: New task sort position at end of group
    - **Property 5: New task sort position at end of group**
    - **Validates: Requirements 3.4**

  - [ ]* 1.6 Write property test: Task update persistence
    - **Property 6: Task update persistence**
    - **Validates: Requirements 3.6**

  - [ ]* 1.7 Write property test: Task list filtering and ordering
    - **Property 7: Task list filtering and ordering**
    - **Validates: Requirements 4.1**

  - [ ]* 1.8 Write property test: Default view excludes archived tasks
    - **Property 13: Default view excludes archived tasks**
    - **Validates: Requirements 5.6**

- [ ] 2. Implement TaskService
  - [ ] 2.1 Create TaskService with project and task CRUD operations
    - Create `lib/services/task_service.dart`
    - Constructor takes `AppDatabase` instance
    - Implement project methods: `getAllProjects()`, `watchAllProjects()`, `createProject(String name)`, `deleteProject(int projectId)`, `getProjectNames()`
    - Implement task methods: `getTasksForProject(int? projectId, {bool includeArchived})`, `watchTasksForProject(int? projectId, {bool includeArchived})`, `createTask({title, description, deadline, projectId})` — queries max sortPosition in group and assigns max + 1, `updateTask(int taskId, {title, description, deadline})`, `deleteTask(int taskId)`
    - _Requirements: 2.4, 2.7, 3.4, 3.6, 3.8, 7.1_

  - [ ] 2.2 Implement reorder, completion, and archive logic in TaskService
    - Implement `reorder(int taskId, int newPosition, int? projectId)`: fetch all tasks in group ordered by sortPosition, remove moved task, insert at new index, batch-update sortPositions as contiguous integers (0, 1, 2, ...)
    - Implement `toggleComplete(int taskId)`: if incomplete → set isCompleted=true, completedAt=DateTime.now(); if completed (not archived) → set isCompleted=false, completedAt=null
    - Implement `archiveExpiredTasks()`: query completed+non-archived tasks with completedAt not null, archive those where now - completedAt >= 12 hours
    - Implement `unarchiveTask(int taskId)`: set isCompleted=false, completedAt=null, isArchived=false, assign sortPosition at end of group
    - _Requirements: 4.5, 5.1, 5.3, 5.4, 5.8, 5.10_

  - [ ]* 2.3 Write property test: Reorder produces valid contiguous positions
    - **Property 9: Reorder produces valid contiguous positions**
    - **Validates: Requirements 4.5**

  - [ ]* 2.4 Write property test: Mark complete sets status and timestamp
    - **Property 10: Mark complete sets status and timestamp**
    - **Validates: Requirements 5.1**

  - [ ]* 2.5 Write property test: Archive check archives expired tasks
    - **Property 11: Archive check archives expired tasks**
    - **Validates: Requirements 5.3**

  - [ ]* 2.6 Write property test: Restoring tasks clears completion fields
    - **Property 12: Restoring tasks clears completion fields**
    - **Validates: Requirements 5.4, 5.10**

  - [ ]* 2.7 Write property test: Archived tasks ordered by completion timestamp descending
    - **Property 14: Archived tasks ordered by completion timestamp descending**
    - **Validates: Requirements 5.7**

- [ ] 3. Implement date formatting utility
  - [ ] 3.1 Create deadline date formatter
    - Create `lib/core/date_format_utils.dart` (or add to existing utils file)
    - Implement `formatDeadline(String isoDate)` → returns string in "d. M. yyyy" format (day without leading zero, dot, space, month without leading zero, dot, space, four-digit year)
    - Example: "2025-06-15" → "15. 6. 2025"
    - _Requirements: 4.3_

  - [ ]* 3.2 Write property test: Date formatting
    - **Property 8: Date formatting**
    - **Validates: Requirements 4.3**

- [ ] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Implement Riverpod providers
  - [ ] 5.1 Create TaskService provider and task state providers
    - Create `lib/providers/task_providers.dart`
    - Implement `taskServiceProvider` as `Provider<TaskService>` using `appDatabaseProvider`
    - Implement `taskProjectsProvider` as `StreamProvider<List<TaskProject>>` watching `service.watchAllProjects()`
    - Implement `selectedTaskProjectProvider` as `StateProvider<int?>` (null = Unassigned)
    - Implement `showArchivedTasksProvider` as `StateProvider<bool>` (default false)
    - Implement `taskListProvider` as `StreamProvider<List<TaskItem>>` watching `service.watchTasksForProject(projectId, includeArchived: showArchived)`
    - _Requirements: 2.1, 4.1, 5.6, 5.7_

  - [ ] 5.2 Create autocomplete projects provider
    - Implement `autocompleteProjectsProvider` as `FutureProvider<List<String>>` in `lib/providers/task_providers.dart`
    - Merge task project names (from TaskService.getProjectNames()) with timer projects (from ProjectService.getKnownProjects())
    - Deduplication: case-insensitive, task project names listed first, then ProjectService names
    - _Requirements: 7.1, 7.2_

  - [ ]* 5.3 Write property test: Merged autocomplete list dedup and ordering
    - **Property 15: Merged autocomplete list — unique names, task projects first**
    - **Validates: Requirements 7.1, 7.2**

  - [ ] 5.4 Implement last-viewed project persistence
    - Add logic to persist selected project to SharedPreferences (`last_task_project_id` key) when `selectedTaskProjectProvider` changes
    - On TasksScreen first display: read from SharedPreferences, validate project still exists in DB, set provider (fallback to null/Unassigned if not found or invalid)
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

  - [ ]* 5.5 Write property test: Project selection round-trip persistence
    - **Property 17: Project selection round-trip persistence**
    - **Validates: Requirements 6.1**

- [ ] 6. Implement UI screens and widgets
  - [ ] 6.1 Create ProjectSelector widget
    - Create `lib/ui/widgets/project_selector.dart`
    - Horizontal scrollable chip/tab bar showing projects alphabetically + "Nepřiřazeno" as last entry
    - Add project button (+ icon) opens a text input dialog (project name, required, max 100 chars, input prevented beyond limit, confirm disabled while empty/whitespace)
    - Long-press or trailing icon on project chip triggers delete confirmation dialog (states project name, warns all tasks will be permanently deleted)
    - On delete confirm: call TaskService.deleteProject(), switch selection to Unassigned
    - No delete action on "Nepřiřazeno" chip
    - Reads `taskProjectsProvider`, writes `selectedTaskProjectProvider`
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9_

  - [ ]* 6.2 Write property test: Project selector ordering
    - **Property 1: Project selector ordering**
    - **Validates: Requirements 2.1**

  - [ ]* 6.3 Write property test: Whitespace-only input disables action buttons
    - **Property 2: Whitespace-only input disables action buttons**
    - **Validates: Requirements 2.3, 3.3**

  - [ ]* 6.4 Write property test: Project creation persists to database
    - **Property 3: Project creation persists to database**
    - **Validates: Requirements 2.4**

  - [ ] 6.5 Create TaskEditDialog widget
    - Create `lib/ui/widgets/task_edit_dialog.dart`
    - Modal bottom sheet with same styling as existing dialogs (rounded top corners, drag handle, panel background)
    - Fields: title TextField (maxLength: 200, input prevented beyond limit), description TextField (maxLength: 1000, multiline, input prevented beyond limit), deadline date picker (clearable, firstDate: today, no past dates)
    - Save button disabled while title is empty/whitespace
    - Returns entered values; caller handles create/update via TaskService
    - Pre-fill values when editing an existing task
    - _Requirements: 3.1, 3.2, 3.3, 3.5, 3.6, 9.2_

  - [ ] 6.6 Create TaskCard widget
    - Create `lib/ui/widgets/task_card.dart`
    - Rounded panel using theme.panel background, theme.border, borderRadius matching History screen entry panels
    - Leading: completion checkbox (toggle complete on tap)
    - Title row with deadline formatted as "d. M. yyyy" (using formatDeadline utility)
    - Tap on card row: expand to show description, subsequent tap collapses
    - Completed tasks: strikethrough text + opacity 0.5
    - Archived tasks: no checkbox, show unarchive action
    - Trailing: drag handle icon (Icons.drag_handle, color: theme.dim)
    - Edit action (opens TaskEditDialog), delete action (shows confirmation dialog)
    - _Requirements: 4.2, 4.3, 5.5, 5.9, 9.5_

  - [ ] 6.7 Create TasksScreen
    - Create `lib/ui/screens/tasks_screen.dart`
    - `ConsumerStatefulWidget` with `WidgetsBindingObserver` to trigger `archiveExpiredTasks()` on resume
    - Call `archiveExpiredTasks()` in `initState` via post-frame callback
    - Layout: ProjectSelector at top, task list body using `ReorderableListView.builder` (long-press initiates drag), FAB for add task
    - On drag-and-drop: call TaskService.reorder(), revert on failure with error SnackBar
    - Menu action "Zobrazit archivované úkoly" toggles `showArchivedTasksProvider`
    - When showArchived=true, display archived tasks below active tasks ordered by completedAt descending
    - Empty state widget when task list is empty (message + prompt to create first task)
    - Load last-viewed project on init from SharedPreferences
    - Error handling: show Czech SnackBar errors on failed operations
    - _Requirements: 3.1, 3.7, 3.8, 3.9, 3.10, 3.11, 4.1, 4.2, 4.4, 4.5, 4.6, 4.7, 4.8, 5.2, 5.3, 5.5, 5.6, 5.7, 5.8, 5.9, 5.10, 9.1, 9.5, 10.1, 10.2, 10.3, 10.4_

- [ ] 7. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 8. Navigation integration and timer autocomplete
  - [ ] 8.1 Update bottom navigation to include Tasks tab
    - In `lib/ui/widgets/bottom_nav.dart`: insert new `_NavItem` at index 1 with `icon: Icons.checklist_outlined`, `activeIcon: Icons.checklist`, `label: 'Úkoly'`
    - Shift existing History/Stats/Settings indices to 2/3/4
    - _Requirements: 1.1, 1.2_

  - [ ] 8.2 Update app.dart to wire TasksScreen into IndexedStack
    - In `lib/app.dart`: add `TasksScreen()` at index 1 in `_screens` list
    - Update statistics invalidation check from `index == 2` to `index == 3`
    - Ensure IndexedStack preserves state of all 5 tabs (scroll position, project filter)
    - _Requirements: 1.3, 1.4, 1.5_

  - [ ] 8.3 Integrate autocomplete provider into timer sheets
    - In `description_sheet.dart`, `edit_sheet.dart`, and `manual_entry_sheet.dart`: replace direct `ProjectService.getKnownProjects()` calls with reading `autocompleteProjectsProvider`
    - The save flow remains unchanged — project name stored as plain string in TimeEntry and persisted to ProjectService
    - Deleting a TaskProject does NOT remove historical TimeEntry records
    - _Requirements: 7.1, 7.2, 7.3, 7.4_

  - [ ]* 8.4 Write property test: Deleting task project does not affect time entries
    - **Property 16: Deleting a task project does not affect time entries**
    - **Validates: Requirements 7.4**

- [ ] 9. Apply theme consistency and localization
  - [ ] 9.1 Verify all task screens consume themeProvider correctly
    - Verify TasksScreen, TaskEditDialog, ProjectSelector, TaskCard all consume colors from `themeProvider`
    - Validate Sora font for UI labels, JetBrains Mono for data values (deadlines)
    - Validate immediate re-render on theme switch (Ember, Midnight, Paper) without re-navigation
    - Confirm all Czech strings are inline (no i18n framework)
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 10.1, 10.2, 10.3, 10.4_

- [ ] 10. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document using `glados`
- Unit tests validate specific examples and edge cases
- The implementation language is Dart (Flutter) as specified in the design
- Database tests use `AppDatabase.forTesting(NativeDatabase.memory())`
- SharedPreferences tests use `SharedPreferences.setMockInitialValues({})`
- Always run `fvm flutter pub run build_runner build --delete-conflicting-outputs` after modifying Drift tables
- Do NOT run `dart format` / `flutter format` on this repo

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["1.2"] },
    { "id": 2, "tasks": ["1.3"] },
    { "id": 3, "tasks": ["1.4", "1.5", "1.6", "1.7", "1.8", "2.1"] },
    { "id": 4, "tasks": ["2.2", "3.1"] },
    { "id": 5, "tasks": ["2.3", "2.4", "2.5", "2.6", "2.7", "3.2"] },
    { "id": 6, "tasks": ["5.1", "5.2"] },
    { "id": 7, "tasks": ["5.3", "5.4"] },
    { "id": 8, "tasks": ["5.5", "6.1"] },
    { "id": 9, "tasks": ["6.2", "6.3", "6.4", "6.5", "6.6"] },
    { "id": 10, "tasks": ["6.7"] },
    { "id": 11, "tasks": ["8.1", "8.2"] },
    { "id": 12, "tasks": ["8.3", "8.4"] },
    { "id": 13, "tasks": ["9.1"] }
  ]
}
```
