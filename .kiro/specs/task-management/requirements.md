# Requirements Document

## Introduction

Task Management is a new feature for the TimeLog Flutter app that adds a dedicated "Úkoly" (Tasks) tab for managing TODO items. Users can create, edit, remove, and reorder tasks organized by projects. Each task has a required title and optional description and deadline. Tasks are manually ordered via drag-and-drop within their project group. Completed tasks are automatically archived after 12 hours. Task projects are stored in Drift (separate from existing timer projects in SharedPreferences) and also appear in the timer's project dropdown for time logging.

## Glossary

- **Task**: A TODO item stored in the Task_Database with a title, optional description, optional deadline, completion status, sort position, and optional project assignment
- **Task_Project**: A named grouping entity stored in the Task_Database, used to organize Tasks; separate from timer projects in ProjectService
- **Tasks_Screen**: The main screen displayed in the Tasks tab, showing a list of Tasks filtered by the selected Task_Project or the Unassigned group
- **Task_Edit_Dialog**: A modal dialog for creating and editing Task fields (title, description, deadline)
- **Project_Selector**: A UI control on the Tasks_Screen allowing the user to switch between Task_Projects and the Unassigned group
- **Unassigned_Group**: A virtual grouping displayed as "Nepřiřazeno" that shows all Tasks not assigned to any Task_Project
- **Task_Database**: The local Drift (SQLite) database tables storing Task and Task_Project entities
- **Task_Service**: The service responsible for Task and Task_Project CRUD operations, ordering, and archive logic
- **Archive_Timer**: The 12-hour countdown that starts when a Task is marked as completed, after which the Task is archived
- **App**: The TimeLog Flutter application

## Requirements

### Requirement 1: Navigation Integration

**User Story:** As a user, I want to access my tasks from a dedicated tab in the bottom navigation, so that task management is always one tap away.

#### Acceptance Criteria

1. THE App SHALL display five tabs in the bottom navigation in this order: Timer (index 0), Úkoly (index 1), History (index 2), Stats (index 3), Settings (index 4)
2. THE Tasks tab SHALL use a checklist icon (Icons.checklist_outlined when inactive, Icons.checklist when active) with the label "Úkoly"
3. WHEN the user taps the Tasks tab, THE App SHALL display the Tasks_Screen and set the bottom navigation selected index to 1
4. THE App SHALL preserve the state of all tabs using IndexedStack, such that navigating away from and back to the Tasks_Screen retains scroll position and any user-selected filter (e.g., project filter)
5. WHEN the user taps the Tasks tab while it is already selected, THE App SHALL perform no navigation action and retain the current scroll position and state of the Tasks_Screen

### Requirement 2: Task Project Management

**User Story:** As a user, I want to create and delete projects on the Tasks page, so that I can organize my tasks into meaningful groups.

#### Acceptance Criteria

1. THE Tasks_Screen SHALL display a Project_Selector showing all Task_Projects from the Task_Database ordered alphabetically by name, followed by the Unassigned_Group always displayed as the last entry
2. WHEN the user triggers the "create project" action, THE App SHALL display a text input dialog with a single field for the project name (required, maximum 100 characters with input prevented beyond the limit)
3. WHILE the project name field is empty or contains only whitespace, THE create project dialog SHALL disable the confirm button
4. WHEN the user confirms the create project dialog with a valid name, THE Task_Database SHALL persist a new Task_Project and THE Project_Selector SHALL update to include the new project without requiring manual refresh
5. THE Task_Database SHALL allow multiple Task_Projects with the same name
6. WHEN the user triggers the "delete project" action on a Task_Project, THE App SHALL display a confirmation dialog stating the project name and that all tasks assigned to the project will be permanently deleted
7. WHEN the user confirms project deletion, THE Task_Database SHALL permanently remove the Task_Project and all Tasks assigned to it (both completed and incomplete), and THE Project_Selector SHALL remove the entry and switch to the Unassigned_Group
8. THE Project_Selector SHALL NOT display a delete action on the Unassigned_Group, and the Unassigned_Group SHALL always remain present regardless of user actions
9. IF a database write operation fails during project creation or deletion, THEN THE App SHALL display an error message indicating the operation that failed and retain the previous state

### Requirement 3: Task CRUD Operations

**User Story:** As a user, I want to add, edit, and remove tasks, so that I can manage my TODO list within a project or the unassigned group.

#### Acceptance Criteria

1. WHEN the user presses the add task button on the Tasks_Screen, THE App SHALL display the Task_Edit_Dialog with empty fields, defaulting the project assignment to the currently selected Task_Project or Unassigned_Group
2. THE Task_Edit_Dialog SHALL contain editable fields for: title (text, required, maximum 200 characters with input prevented beyond the limit), description (text, optional, maximum 1000 characters with input prevented beyond the limit), and deadline (date picker, optional, clearable, allowing selection of today or any future date and rejecting dates in the past)
3. WHILE the title field is empty or contains only whitespace, THE Task_Edit_Dialog SHALL disable the save button
4. WHEN the user confirms the Task_Edit_Dialog with valid values for a new Task, THE Task_Database SHALL persist the Task with a sort position placing it at the end of the current group's task list
5. WHEN the user triggers the edit action on an existing Task, THE App SHALL display the Task_Edit_Dialog pre-filled with the current values of that Task
6. WHEN the user confirms the Task_Edit_Dialog with valid values for an existing Task, THE Task_Database SHALL update the Task and THE Tasks_Screen SHALL reflect the change without requiring manual refresh
7. WHEN the user triggers the delete action on a Task, THE App SHALL display a confirmation dialog indicating the task title and that deletion is permanent
8. WHEN the user confirms deletion in the confirmation dialog, THE Task_Database SHALL permanently remove the Task and THE Tasks_Screen SHALL remove it from the displayed list without requiring manual refresh
9. WHEN the user cancels the deletion confirmation dialog, THE App SHALL dismiss the dialog and leave the Task unchanged
10. IF a database write operation fails during Task creation, update, or deletion, THEN THE App SHALL display an error message indicating the operation that failed and retain the previous state
11. IF the current group contains no Tasks, THEN THE Tasks_Screen SHALL display an empty state message indicating no tasks exist in the selected group

### Requirement 4: Task Display and Ordering

**User Story:** As a user, I want to see my tasks in a manually sorted order and rearrange them via drag-and-drop, so that I can prioritize tasks the way I prefer.

#### Acceptance Criteria

1. THE Tasks_Screen SHALL display Tasks filtered by the currently selected Task_Project or the Unassigned_Group, ordered by sort position ascending
2. THE Tasks_Screen SHALL display each Task with its title, completion checkbox, and deadline (if set); WHEN the user taps on a Task row, THE Tasks_Screen SHALL expand the Task to reveal its description below the title, and a subsequent tap SHALL collapse it
3. WHEN a Task has a deadline set, THE Tasks_Screen SHALL display the deadline date formatted as "d. M. yyyy" (day without leading zero, month without leading zero, four-digit year, separated by dots and spaces, e.g., "15. 6. 2025")
4. WHEN the user initiates a long-press on a Task, THE Tasks_Screen SHALL enter drag-and-drop reorder mode allowing the user to move the Task to a different position within the same group
5. WHEN the user drops a Task at a new position, THE Task_Database SHALL update the sort position of all affected Tasks to reflect the new order, and THE Tasks_Screen SHALL display the updated order
6. THE Task_Database SHALL persist sort positions such that the order is maintained between app launches
7. IF the currently selected group contains no Tasks, THEN THE Tasks_Screen SHALL display an empty state message indicating no tasks exist with a prompt to create the first one
8. IF the sort position update fails during a drag-and-drop reorder, THEN THE Tasks_Screen SHALL revert the Task to its original position in the list and display an error message indicating the reorder was unsuccessful

### Requirement 5: Task Completion and Archiving

**User Story:** As a user, I want to check off completed tasks and have them automatically archived after 12 hours, so that my task list stays clean without requiring manual cleanup.

#### Acceptance Criteria

1. WHEN the user taps the completion checkbox on a Task, THE Task_Database SHALL update the Task's completion status to completed and record the completion timestamp
2. WHEN a Task is marked as completed, THE Archive_Timer SHALL start a 12-hour countdown from the completion timestamp
3. WHEN the Archive_Timer for a Task expires (12 hours have elapsed since the completion timestamp), THE Task_Service SHALL set the Task's status to archived in the Task_Database
4. WHEN the user unchecks a previously completed Task (within the 12-hour window), THE Task_Database SHALL clear the completion status and completion timestamp, and THE Archive_Timer for that Task SHALL be cancelled
5. THE Tasks_Screen SHALL display completed (not yet archived) Tasks with strikethrough text on the task name and reduced opacity (0.5) to visually distinguish them from incomplete Tasks
6. THE Tasks_Screen SHALL NOT display archived Tasks in the default view
7. WHEN the user selects "Zobrazit archivované úkoly" from the Tasks_Screen menu, THE Tasks_Screen SHALL display archived Tasks for the currently selected group below the active Tasks, ordered by completion timestamp descending
8. WHEN the App launches or returns to the foreground, THE Task_Service SHALL evaluate all completed Tasks and archive any whose completion timestamp is older than 12 hours
9. WHILE archived Tasks are displayed on the Tasks_Screen, THE Tasks_Screen SHALL NOT display a completion checkbox on archived Tasks and SHALL NOT allow the user to modify their completion status
10. IF the user needs to restore an archived Task, THEN THE Tasks_Screen SHALL display an unarchive action on each archived Task that sets the Task status back to incomplete, clears the completion status and completion timestamp, and returns the Task to the active list

### Requirement 6: Last Viewed Project Persistence

**User Story:** As a user, I want the Tasks page to remember which project I last viewed, so that I return to my context without extra taps.

#### Acceptance Criteria

1. WHEN the user selects a Task_Project or the Unassigned_Group in the Project_Selector, THE App SHALL immediately persist the selection to SharedPreferences, storing the Task_Project database identifier for a Task_Project or a null value for the Unassigned_Group
2. WHEN the App launches and the Tasks_Screen is displayed for the first time in that session, THE App SHALL read the persisted selection from SharedPreferences and display the corresponding Task_Project's Tasks or the Unassigned_Group's Tasks before rendering the task list
3. IF the persisted project identifier refers to a Task_Project that no longer exists in the Task_Database (deleted), THEN THE App SHALL fall back to displaying the Unassigned_Group and update the persisted selection to null
4. IF no previous selection is persisted in SharedPreferences (first use) or the persisted value is unreadable or corrupted, THEN THE App SHALL display the Unassigned_Group by default

### Requirement 7: Timer Integration

**User Story:** As a user, I want my task projects to appear in the timer's project autocomplete suggestions, so that I can log time against the same projects I organize tasks in.

#### Acceptance Criteria

1. WHEN the timer project autocomplete input displays suggestions, THE App SHALL merge all Task_Project names from the Task_Database with existing project names from ProjectService into a single unified suggestion list, with Task_Project names listed first followed by ProjectService names
2. IF a Task_Project has the same name (case-insensitive) as a project in ProjectService, THEN THE App SHALL display it only once in the suggestion list (removing the duplicate)
3. WHEN a project name is entered in the timer autocomplete input and a time entry is saved, THE App SHALL store the project name as a plain string in the TimeEntry project field and persist the name to ProjectService so it appears in recently-used projects
4. WHEN a Task_Project is deleted, THE App SHALL NOT remove historical TimeEntry records that reference the deleted project name

### Requirement 8: Task Database Schema

**User Story:** As a developer, I want a clear database schema for tasks and task projects, so that the data layer is well-defined and supports all required operations.

#### Acceptance Criteria

1. THE Task_Database SHALL store each Task_Project with the following fields: unique identifier (integer, auto-increment, primary key), name (text, required, minimum 1 character, maximum 100 characters), and created-at timestamp (datetime, default current time)
2. THE Task_Database SHALL store each Task with the following fields: unique identifier (integer, auto-increment, primary key), title (text, required, minimum 1 character, maximum 200 characters), description (text, nullable, maximum 1000 characters), deadline (text, nullable, ISO 8601 date format "YYYY-MM-DD"), project identifier (integer, nullable, foreign key to Task_Project with cascade delete), sort position (integer, required, default 0), is-completed flag (boolean, default false), completed-at timestamp (datetime, nullable), is-archived flag (boolean, default false), and created-at timestamp (datetime, default current time)
3. THE Task_Database SHALL enforce referential integrity between Tasks and Task_Projects using a foreign key constraint with cascade delete, so that deleting a Task_Project removes all associated Tasks
4. THE Task_Database SHALL allow multiple Tasks with the same title within the same project and across different projects
5. THE Task_Database SHALL allow multiple Task_Projects with the same name
6. THE Task_Database SHALL be implemented as a Drift schema migration incrementing the current schema version from 6 to 7, creating both tables in the `onUpgrade` callback when migrating from a version below 7
7. IF a Task's is-completed flag is set to true and completed-at is null, THEN THE Task_Database SHALL accept the record without constraint violation, leaving completed-at management to the application layer

### Requirement 9: Visual Design Consistency

**User Story:** As a user, I want the Tasks screen to match the existing application design, so that the feature feels like a natural part of the app.

#### Acceptance Criteria

1. THE Tasks_Screen SHALL obtain colors, typography, and spacing from the App themeProvider, using the Sora font family for UI labels and JetBrains Mono for data values (deadlines, counts), matching font sizes and weights used on the Timer_Screen and History_Screen
2. THE Task_Edit_Dialog SHALL use the same modal/bottom sheet styling (rounded top corners, drag handle, background color from theme panel token), input field appearance, and button styles as existing dialogs in the App (Description_Prompt, Reminder_Edit_Dialog)
3. THE App SHALL apply the active color theme (Ember, Midnight, or Paper) to all Task Management screens and dialogs by consuming the themeProvider, and SHALL re-render with updated colors on the next frame when the user switches theme without requiring screen re-navigation
4. THE Tasks_Screen drag-and-drop reorder handle SHALL use a grip/handle icon rendered in the theme's dim color token
5. THE Tasks_Screen SHALL display each Task inside a rounded panel using the theme's panel background color, border color, and a border-radius matching the existing History_Screen entry panels

### Requirement 10: Localization

**User Story:** As a user, I want the task management interface to be in Czech, so that it is consistent with the rest of the application.

#### Acceptance Criteria

1. THE Tasks_Screen, Task_Edit_Dialog, Project_Selector, and all related UI elements SHALL display all labels, button texts, error messages, empty state messages, and confirmation dialogs in Czech language using inline string literals, consistent with the existing App screens
2. THE Unassigned_Group SHALL be labeled "Nepřiřazeno" in the Project_Selector
3. THE archive menu option SHALL be labeled "Zobrazit archivované úkoly"
4. THE App SHALL NOT use an i18n framework for Task Management strings; all Czech text SHALL be defined as inline string constants in the widget source files, matching the existing App convention
