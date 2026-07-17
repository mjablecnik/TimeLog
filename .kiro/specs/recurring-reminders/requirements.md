# Requirements Document

## Introduction

Recurring Reminders is a feature for the TimeLog Flutter app that enables users to create daily recurring reminders for habits and tasks (e.g., take medication, exercise, practice English). Each reminder has a configurable time window during which notifications repeat at a set interval until the user marks the task as done or the window expires. The cycle resets daily. Users manage reminders via a settings screen and interact with triggered reminders via a dedicated action screen launched from notifications.

## Glossary

- **Recurring_Reminder**: A persistent entity representing a recurring task with a name, description, active days, time window, repeat interval, and active/inactive status
- **Reminder_Settings_Screen**: The screen displaying a list of all Recurring_Reminders where users can add, edit, delete, activate, and deactivate reminders
- **Reminder_Action_Screen**: The screen displayed when the user taps a reminder notification, showing the reminder details and action buttons (Done, Snooze)
- **Reminder_Edit_Dialog**: A modal dialog for creating and editing Recurring_Reminder fields
- **Time_Window**: The daily period (start time to end time) during which notifications for a Recurring_Reminder are allowed to fire
- **Repeat_Interval**: The configurable duration between consecutive notifications within the Time_Window (e.g., every 1 hour, every 2 hours)
- **Completion_Record**: A database entry recording that a specific Recurring_Reminder was marked as done on a specific date and time
- **Recurring_Reminder_Service**: The service responsible for scheduling, rescheduling, and cancelling local notifications for Recurring_Reminders
- **Reminder_Database**: The local SQLite database (Drift) storing Recurring_Reminder definitions and Completion_Records
- **Reminder_Sound**: The custom notification sound file played when a recurring reminder notification fires, distinct from the timer alarm sound
- **App**: The TimeLog Flutter application

## Requirements

### Requirement 1: Reminder Management (CRUD)

**User Story:** As a user, I want to create, view, edit, and delete recurring reminders, so that I can manage my daily habits and tasks.

#### Acceptance Criteria

1. THE Reminder_Settings_Screen SHALL display a list of all Recurring_Reminders stored in the Reminder_Database, ordered by start time of the Time_Window ascending
2. THE Reminder_Settings_Screen SHALL display each Recurring_Reminder with its name, Time_Window formatted as "HH:mm – HH:mm", Repeat_Interval displayed in minutes, active days as abbreviated weekday names (e.g., "Mon, Wed, Fri"), active/inactive status, and today's completion status (visually indicating whether the reminder has been completed for the current day)
3. THE Reminder_Settings_Screen SHALL display a checkbox or tap target on each Recurring_Reminder allowing the user to manually mark it as done for the current day, regardless of whether the Time_Window has started or a notification has been received
4. WHEN the user manually marks a Recurring_Reminder as done on the Reminder_Settings_Screen, THE Reminder_Database SHALL create a Completion_Record for the current day and THE Recurring_Reminder_Service SHALL cancel all remaining scheduled notifications for that reminder for the current day
5. WHEN the user unchecks a previously completed Recurring_Reminder on the Reminder_Settings_Screen (within the same day), THE Reminder_Database SHALL delete the Completion_Record for the current day and THE Recurring_Reminder_Service SHALL reschedule notifications for the remaining Time_Window within the 6-hour lookahead
6. WHEN the user presses the add button, THE App SHALL display the Reminder_Edit_Dialog with default values: Time_Window 08:00–00:00, Repeat_Interval of 60 minutes, all days selected, and active status enabled
7. WHEN the user presses the edit button on a Recurring_Reminder, THE App SHALL display the Reminder_Edit_Dialog pre-filled with the current values of that reminder
8. WHEN the user confirms the Reminder_Edit_Dialog with valid values, THE Reminder_Database SHALL persist the new or updated Recurring_Reminder and the Reminder_Settings_Screen SHALL update the displayed list to reflect the change without requiring manual refresh or navigation
9. WHEN the user presses the delete button on a Recurring_Reminder, THE App SHALL display a confirmation dialog stating the reminder name and that deletion is permanent
10. WHEN the user confirms deletion, THE Reminder_Database SHALL permanently remove the Recurring_Reminder and all associated Completion_Records, and the Reminder_Settings_Screen SHALL remove the entry from the displayed list without requiring manual refresh or navigation
11. IF a database write operation fails during create, update, delete, or manual completion toggle, THEN THE App SHALL display an error message indicating the operation that failed and retain the previous state of the Reminder_Settings_Screen and Reminder_Database
12. IF the Reminder_Database contains no Recurring_Reminders, THEN THE Reminder_Settings_Screen SHALL display an empty state with a message indicating no reminders exist and a prompt to create the first one

### Requirement 2: Reminder Edit Dialog

**User Story:** As a user, I want to configure reminder details in a simple modal dialog, so that I can quickly set up or modify a reminder without navigating away from the settings screen.

#### Acceptance Criteria

1. THE Reminder_Edit_Dialog SHALL contain editable fields for: name (text, required, maximum 100 characters with input prevented beyond the limit), description (text, optional, maximum 300 characters with input prevented beyond the limit), start time (time picker), end time (time picker), Repeat_Interval (selection in minutes: 30, 60, 120, 180, 240), active days (multi-select for Monday through Sunday with at least one day required), and active/inactive toggle
2. WHILE the name field is empty or contains only whitespace, THE Reminder_Edit_Dialog SHALL disable the save button
3. WHEN the user selects a start time equal to or later than the end time, THE Reminder_Edit_Dialog SHALL treat the end time as belonging to the following calendar day (allowing overnight windows such as 22:00–02:00)
4. THE Reminder_Edit_Dialog SHALL default the Repeat_Interval to 60 minutes for new reminders
5. THE Reminder_Edit_Dialog SHALL default active days to all seven days for new reminders
6. WHEN the user presses cancel or taps outside the dialog and the form contains unsaved changes, THE App SHALL display a confirmation prompt before dismissing the Reminder_Edit_Dialog without saving changes
7. WHILE no active days are selected, THE Reminder_Edit_Dialog SHALL disable the save button

### Requirement 3: Activate and Deactivate Reminders

**User Story:** As a user, I want to activate or deactivate reminders without deleting them, so that I can temporarily pause reminders I do not need right now.

#### Acceptance Criteria

1. THE Reminder_Settings_Screen SHALL display a toggle control for each Recurring_Reminder indicating its active or inactive status
2. WHEN the user toggles a Recurring_Reminder to inactive, THE Recurring_Reminder_Service SHALL cancel all pending notifications for that reminder and THE Reminder_Database SHALL persist the inactive status
3. WHEN the user toggles a Recurring_Reminder to active, THE Recurring_Reminder_Service SHALL schedule the next notification according to the reminder's Time_Window and Repeat_Interval (respecting any existing Completion_Record for the current day and whether today is an active day) and THE Reminder_Database SHALL persist the active status
4. WHILE a Recurring_Reminder is inactive, THE Recurring_Reminder_Service SHALL NOT schedule or fire any notifications for that reminder
5. IF a toggle operation fails due to a database or scheduling error, THEN THE App SHALL revert the toggle to its previous state and display an error message

### Requirement 4: Notification Scheduling Within Time Window

**User Story:** As a user, I want notifications to repeat at a set interval within my configured time window even if I ignore them, so that I am reminded throughout the day until I complete the task.

#### Acceptance Criteria

1. WHEN the App launches or a Recurring_Reminder is activated or created, THE Recurring_Reminder_Service SHALL schedule notifications for the next 6 hours from the current time, at times aligned to the Time_Window start time plus multiples of the Repeat_Interval (i.e., start, start + interval, start + 2×interval, ...), including only those that fall within the Time_Window and within the 6-hour lookahead window
2. WHEN the current time is before the Time_Window start on an active day, THE Recurring_Reminder_Service SHALL schedule notifications starting from the Time_Window start time (if it falls within the 6-hour lookahead)
3. WHEN the current time is within the Time_Window on an active day, THE Recurring_Reminder_Service SHALL schedule only the remaining future notifications within the 6-hour lookahead
4. THE Recurring_Reminder_Service SHALL NOT schedule a notification if an identical notification (same reminder ID and same scheduled time) is already pending, preventing duplicate notifications
5. WHEN the current day is not an active day for a Recurring_Reminder, THE Recurring_Reminder_Service SHALL NOT schedule any notifications for that reminder on that day
6. THE Recurring_Reminder_Service SHALL use the device's local time zone for all Time_Window calculations
7. IF a Recurring_Reminder has an overnight Time_Window (start time is equal to or later than end time, e.g., 22:00–02:00), THEN THE Recurring_Reminder_Service SHALL treat the window as starting on the active day and ending on the following calendar day, and SHALL schedule notifications spanning across midnight within the 6-hour lookahead
8. THE total number of scheduled notifications across all active Recurring_Reminders SHALL NOT exceed 50 at any given time (respecting iOS platform limit of 64 scheduled local notifications per app, with buffer for other app notifications); IF creating or activating a Recurring_Reminder would cause the total to exceed 50, THEN:
   - During creation: THE Reminder_Edit_Dialog SHALL remain open and display an error message stating how many notification slots are available and how many the new reminder would require (e.g., "Dostupných slotů: 4, potřeba: 6 — překročení o 2")
   - During activation (toggle to active): THE App SHALL revert the toggle to inactive and display an error message with the same slot information
   - THE Reminder_Database SHALL NOT persist the new reminder (during creation) or the active status change (during activation) until sufficient capacity is available

### Requirement 5: Notification Content and Tap Behavior

**User Story:** As a user, I want to tap a reminder notification and see what I need to do with clear action options, so that I can quickly respond to the reminder.

#### Acceptance Criteria

1. THE Recurring_Reminder_Service SHALL display each notification with the Recurring_Reminder name as the title and the description as the body text; IF the description is empty, THEN the notification body SHALL display a default text "Klepni pro otevření"
2. WHEN the user taps a reminder notification, THE App SHALL open the Reminder_Action_Screen displaying the reminder name, description, and action buttons
3. THE Reminder_Action_Screen SHALL display a "Done" button and a "Snooze" button
4. WHEN the App is cold-launched by tapping a reminder notification, THE App SHALL navigate directly to the Reminder_Action_Screen for the tapped reminder after initialization completes
5. WHEN the App is already running in the foreground or background and a notification is tapped, THE App SHALL navigate to the Reminder_Action_Screen for the tapped reminder
6. IF the user taps a notification for a Recurring_Reminder that has been deleted since the notification was scheduled, THEN THE App SHALL navigate to the Reminder_Settings_Screen instead of the Reminder_Action_Screen

### Requirement 6: Mark Reminder as Done

**User Story:** As a user, I want to mark a reminder as done for today so that I stop receiving notifications for it until the next day.

#### Acceptance Criteria

1. WHEN the user presses the "Done" button on the Reminder_Action_Screen, THE Recurring_Reminder_Service SHALL cancel all remaining scheduled notifications for that Recurring_Reminder for the current day
2. WHEN the user presses the "Done" button, THE Reminder_Database SHALL create a Completion_Record with the Recurring_Reminder identifier and the current date and time
3. WHEN the user presses the "Done" button, THE Reminder_Action_Screen SHALL dismiss and return the user to the previous screen or the Timer_Screen if no navigation history exists
4. WHILE a Recurring_Reminder has a Completion_Record for the current day, THE Recurring_Reminder_Service SHALL NOT schedule further notifications for that reminder until the next active day
5. IF the database write for the Completion_Record fails, THEN THE App SHALL display an error message on the Reminder_Action_Screen without dismissing it, and SHALL NOT cancel the pending notifications

### Requirement 7: Snooze Reminder

**User Story:** As a user, I want to snooze a reminder so that the notification screen dismisses and I continue with my work, knowing the next notification is already scheduled.

#### Acceptance Criteria

1. WHEN the user presses the "Snooze" button on the Reminder_Action_Screen, THE Reminder_Action_Screen SHALL dismiss and return the user to the previous screen or the Timer_Screen if no navigation history exists
2. THE Recurring_Reminder_Service SHALL NOT schedule any additional notification on snooze because subsequent notifications are already pre-scheduled via the 6-hour lookahead batch scheduling
3. IF no further notifications are scheduled for the current day (all remaining time slots are past or the Time_Window has ended), THEN pressing "Snooze" SHALL behave identically to dismissing the screen (no completion record is created, the reminder remains incomplete for the day)

### Requirement 8: Completion History Persistence

**User Story:** As a user, I want my reminder completion history stored in the database, so that completion data is available for future features like streaks and statistics.

#### Acceptance Criteria

1. THE Reminder_Database SHALL store each Completion_Record with a reference to the Recurring_Reminder, the completion date (date only, no time component for day-level queries), and the completion timestamp (full datetime for precise ordering), enforcing a uniqueness constraint of one Completion_Record per Recurring_Reminder per completion date
2. THE Reminder_Database SHALL persist Completion_Records between app launches such that terminating and relaunching the App does not lose any previously stored records
3. WHEN a Recurring_Reminder is deleted, THE Reminder_Database SHALL also delete all associated Completion_Records via cascade delete
4. THE Reminder_Database SHALL support querying Completion_Records by Recurring_Reminder identifier and by date range where both the start date and end date are inclusive, returning results ordered by completion date ascending

### Requirement 9: Reminder Database Schema

**User Story:** As a developer, I want a clear database schema for reminders and completion history, so that the data layer is well-defined and extensible.

#### Acceptance Criteria

1. THE Reminder_Database SHALL store each Recurring_Reminder with the following fields: unique identifier (integer, auto-increment, primary key), name (text, required, maximum 100 characters), description (text, nullable, maximum 300 characters), start time (integer, minutes from midnight, range 0–1439), end time (integer, minutes from midnight, range 0–1439), repeat interval in minutes (integer, constrained to values 30, 60, 120, 180, or 240), active days (integer, stored as a 7-bit bitmask where bit 0 represents Monday and bit 6 represents Sunday), and is-active flag (boolean, default true)
2. THE Reminder_Database SHALL store each Completion_Record with the following fields: unique identifier (integer, auto-increment, primary key), reminder identifier (integer, foreign key to Recurring_Reminder), completion date (text, ISO 8601 date format "YYYY-MM-DD"), and completion timestamp (text, ISO 8601 datetime format "YYYY-MM-DDTHH:mm:ss")
3. THE Reminder_Database SHALL enforce referential integrity between Completion_Records and Recurring_Reminders using a foreign key constraint with cascade delete
4. THE Reminder_Database SHALL allow multiple Recurring_Reminders with the same name

### Requirement 10: Notification Rescheduling on App Launch

**User Story:** As a user, I want my reminders to continue working correctly after the device restarts or the app is terminated, so that I never miss a reminder.

#### Acceptance Criteria

1. WHEN the App launches, THE Recurring_Reminder_Service SHALL schedule notifications for the next 6 hours for all active Recurring_Reminders whose Time_Window has not yet ended and that have no Completion_Record for the current day, skipping any notification times that already have a pending notification scheduled (deduplication)
2. WHEN the App launches, THE Recurring_Reminder_Service SHALL NOT schedule notifications for Recurring_Reminders that already have a Completion_Record for the current day
3. IF the App launches after the Time_Window has ended for an active Recurring_Reminder on the current day and no Completion_Record exists, THEN THE Recurring_Reminder_Service SHALL schedule notifications for the next active day's Time_Window (if within the 6-hour lookahead)
4. WHEN the App launches, THE Recurring_Reminder_Service SHALL complete all rescheduling operations within 5 seconds of the app initialization completing

### Requirement 11: Notification Channel Configuration

**User Story:** As a developer, I want recurring reminder notifications to use a dedicated notification channel, so that they are distinguishable from the existing timer reminder notification.

#### Acceptance Criteria

1. THE Recurring_Reminder_Service SHALL use a dedicated Android notification channel with identifier "recurring_reminders" and name "Recurring Reminders", separate from the existing "daily_reminder" channel
2. THE Recurring_Reminder_Service SHALL configure notifications with high importance and high priority to ensure timely delivery
3. THE Recurring_Reminder_Service SHALL assign unique notification identifiers for each scheduled notification using the formula `(reminder database ID × 100) + slot index + 2000`, where slot index is the zero-based position within the day's interval grid, supporting up to 100 notifications per reminder per day and avoiding collision with the existing timer notification identifier (1001)
4. WHEN the first active Recurring_Reminder is saved or toggled active, THE Recurring_Reminder_Service SHALL request notification permissions; IF the user denies permission, THEN THE service SHALL NOT schedule any notifications and SHALL display a message indicating that notifications are disabled
5. WHEN the App launches, THE Recurring_Reminder_Service SHALL verify notification permission status before scheduling; IF permission was previously denied but is now granted (user re-enabled in system settings), THEN THE service SHALL proceed with scheduling normally
6. THE Recurring_Reminder_Service SHALL share the same FlutterLocalNotificationsPlugin instance as the existing ReminderService, receiving it as a constructor dependency rather than creating a new instance, to ensure a single plugin initialization across the entire App

### Requirement 12: Visual Design Consistency

**User Story:** As a user, I want the recurring reminders screens and dialogs to match the existing application design, so that the feature feels like a natural part of the app.

#### Acceptance Criteria

1. THE Reminder_Settings_Screen SHALL obtain colors, typography, and spacing from the App themeProvider, using the Sora font family for UI labels and JetBrains Mono for data values (times, intervals), matching font sizes and weights used on the Timer_Screen and History_Screen
2. THE Reminder_Edit_Dialog SHALL use the same modal/bottom sheet styling, input field appearance, and button styles as existing dialogs in the App
3. THE Reminder_Action_Screen SHALL use the same background color, card styling (panel color, border, border-radius), and button appearance as the existing Timer_Screen and History_Screen
4. THE Reminder_Settings_Screen SHALL be accessible as a sub-screen within the existing Settings tab in the bottom navigation
5. THE App SHALL apply the active color theme (Ember, Midnight, or Paper) to all Recurring Reminder screens and dialogs by consuming the themeProvider, and SHALL update the displayed colors immediately when the user switches theme without requiring screen re-navigation
6. WHEN the user switches the active color theme while viewing a Recurring Reminder screen or dialog, THE App SHALL re-render that screen or dialog with the newly selected theme colors without dismissing or navigating away from the current view


### Requirement 13: Development Dependencies

**User Story:** As a developer, I want the project to include all necessary testing libraries, so that property-based tests can be executed.

#### Acceptance Criteria

1. THE App project SHALL include `dart_check` as a dev dependency in `pubspec.yaml` for property-based testing support

### Requirement 14: Foreground Notification Behavior

**User Story:** As a user, I want to receive reminder notifications even when the app is in the foreground, so that I do not miss reminders while using other app features.

#### Acceptance Criteria

1. WHEN the App is in the foreground and a recurring reminder notification fires, THE App SHALL display the notification as a system heads-up banner (standard OS notification behavior)
2. WHEN the user taps the foreground notification banner, THE App SHALL navigate to the Reminder_Action_Screen for the corresponding Recurring_Reminder

### Requirement 15: Background Notification Response Handling

**User Story:** As a user, I want to be able to tap reminder notifications that arrived while the app was terminated, so that I can respond to reminders regardless of the app state.

#### Acceptance Criteria

1. THE App SHALL register a top-level background notification response handler (annotated with `@pragma('vm:entry-point')`) to handle notification taps when the app is fully terminated
2. WHEN the user taps a recurring reminder notification that arrived while the app was terminated, THE App SHALL launch and navigate to the Reminder_Action_Screen for the corresponding Recurring_Reminder after initialization completes

### Requirement 16: Localization

**User Story:** As a user, I want the recurring reminders interface to be in Czech, so that it is consistent with the rest of the application.

#### Acceptance Criteria

1. THE Reminder_Settings_Screen, Reminder_Edit_Dialog, and Reminder_Action_Screen SHALL display all UI labels, button texts, error messages, and empty state messages in Czech language, consistent with the existing App screens
2. THE notification default body text SHALL be "Klepni pro otevření" (Czech equivalent of "Tap to open") when the Recurring_Reminder description is empty


### Requirement 17: Custom Notification Sound for Recurring Reminders

**User Story:** As a user, I want recurring reminder notifications to play a custom sound distinct from the timer alarm, so that I can distinguish reminder notifications from timer completions by ear without looking at the screen.

#### Acceptance Criteria

1. WHEN a recurring reminder notification fires on iOS, THE Recurring_Reminder_Service SHALL play the Reminder_Sound as the notification sound
2. THE Reminder_Sound SHALL be a custom audio file bundled in the iOS app bundle as a project asset, in one of the iOS-supported local notification sound formats (AIFF, WAV, or CAF)
3. THE Reminder_Sound audio file SHALL have a duration of 30 seconds or less, as required by the iOS local notification sound limit
4. THE Reminder_Sound SHALL be audibly distinct from the alarm sound used by the Alarm_Service when the timer reaches zero, such that a user can differentiate between the two sounds without visual confirmation
5. WHEN configuring the Android notification channel with identifier "recurring_reminders", THE Recurring_Reminder_Service SHALL reference a custom sound resource distinct from the timer alarm sound, for future Android platform support
6. IF the iOS system fails to load the Reminder_Sound file at notification time, THEN THE Recurring_Reminder_Service SHALL fall back to the iOS default notification sound
