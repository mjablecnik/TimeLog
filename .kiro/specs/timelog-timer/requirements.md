# Requirements Document

## Introduction

TimeLog is a Flutter iOS application that provides a 20-minute countdown timer with time tracking capabilities. Users start the timer, work for 20 minutes, and upon completion describe what they accomplished. All time entries are stored locally and can be reviewed in a history log. The timer integrates with iOS Live Activities to display countdown progress on the lock screen and Dynamic Island.

## Glossary

- **Timer_Service**: The core countdown timer engine responsible for managing timer state, counting down, and triggering completion events
- **Live_Activity_Manager**: The iOS native component that manages Live Activities for lock screen and Dynamic Island display
- **Alarm_Service**: The component responsible for playing continuous alarm sound when the timer reaches zero
- **Time_Entry**: A data record consisting of a start time, end time, and user-provided description
- **Local_Database**: The on-device SQLite database storing all time entries persistently
- **Timer_Screen**: The main application screen displaying the countdown and timer controls
- **History_Screen**: The screen displaying a chronological list of all past time entries
- **Description_Prompt**: The screen or modal that appears after alarm dismissal, requiring the user to enter a description of completed work
- **Timer_Duration**: The configurable countdown duration value stored in application settings, currently set to 20 minutes
- **App**: The TimeLog Flutter iOS application as a whole

## Requirements

### Requirement 1: Timer Display and Controls

**User Story:** As a user, I want to see a countdown timer with play, pause, and stop controls, so that I can manage my 20-minute work intervals.

#### Acceptance Criteria

1. WHEN the user opens the App, THE Timer_Screen SHALL display the Timer_Duration value as the initial countdown time in MM:SS format
2. WHEN the user presses the play button, THE Timer_Service SHALL start counting down from the displayed time
3. WHILE the Timer_Service is running, THE Timer_Screen SHALL update the displayed remaining time every second
4. WHEN the user presses the pause button, THE Timer_Service SHALL pause the countdown and retain the current remaining time
5. WHEN the user presses the play button after a pause, THE Timer_Service SHALL resume counting down from the paused time
6. WHEN the user presses the stop button, THE Timer_Service SHALL reset the countdown to the Timer_Duration value and display the play button as the only enabled control
7. WHILE the Timer_Service is in the idle state, THE Timer_Screen SHALL enable only the play button and disable the pause and stop buttons
8. WHILE the Timer_Service is running, THE Timer_Screen SHALL enable the pause and stop buttons and disable the play button
9. WHILE the Timer_Service is paused, THE Timer_Screen SHALL enable the play and stop buttons and disable the pause button

### Requirement 2: Configurable Timer Duration

**User Story:** As a developer, I want the timer duration stored in a configuration setting, so that the value can be changed in the future without modifying timer logic.

#### Acceptance Criteria

1. THE App SHALL read the countdown duration from a configuration setting named Timer_Duration, where the value represents a whole number of minutes between 1 and 1440
2. THE Timer_Duration setting SHALL default to 20 minutes
3. WHEN the Timer_Service resets, THE Timer_Service SHALL use the current Timer_Duration value as the new countdown starting point
4. IF Timer_Duration contains a value that is not a whole number or falls outside the range of 1 to 1440, THEN THE App SHALL use the default value of 20 minutes as the countdown duration

### Requirement 3: Background Timer Execution

**User Story:** As a user, I want the timer to continue counting down when the app is in the background, so that I do not need to keep the app open.

#### Acceptance Criteria

1. WHILE the App is in the background, THE Timer_Service SHALL continue counting down with no more than 1 second of drift from the expected remaining time
2. WHEN the user returns to the App, THE Timer_Screen SHALL display the remaining time recalculated from elapsed wall-clock time within 500 milliseconds of the App entering the foreground
3. WHEN the timer reaches zero while the App is in the background, THE Timer_Service SHALL trigger the alarm notification
4. IF the user returns to the App after the timer has already expired in the background, THEN THE Timer_Screen SHALL display the timer as completed and indicate that the alarm has fired

### Requirement 4: Lock Screen and Dynamic Island Display

**User Story:** As a user, I want to see the timer countdown on the iOS lock screen and Dynamic Island, so that I can check remaining time without unlocking the phone.

#### Acceptance Criteria

1. WHEN the Timer_Service starts counting down, THE Live_Activity_Manager SHALL start a Live Activity displaying the remaining time using an ActivityKit countdown date so the system renders live updates without requiring frequent push updates
2. WHILE the Timer_Service is running, THE Live_Activity_Manager SHALL display pause and stop controls on the lock screen widget
3. WHILE the Timer_Service is paused, THE Live_Activity_Manager SHALL update the Live Activity to show the frozen remaining time and display resume and stop controls on the lock screen widget
4. WHEN the user presses pause on the lock screen widget, THE Timer_Service SHALL pause the countdown
5. WHEN the user presses the resume control on the lock screen widget, THE Timer_Service SHALL resume the countdown from the paused time
6. WHEN the user presses stop on the lock screen widget, THE Timer_Service SHALL reset the countdown
7. WHILE the Timer_Service is running, THE Live_Activity_Manager SHALL display the remaining time in the Dynamic Island compact and expanded views
8. WHEN the Timer_Service stops or resets, THE Live_Activity_Manager SHALL end the Live Activity within 1 second of the state change
9. IF the Live_Activity_Manager fails to start a Live Activity due to denied permission or system limits, THEN THE Timer_Service SHALL continue counting down normally without the Live Activity and the App SHALL not display an error to the user

### Requirement 5: Timer Completion Alarm

**User Story:** As a user, I want the app to alarm continuously when the timer reaches zero, so that I am clearly notified that my work interval is complete.

#### Acceptance Criteria

1. WHEN the Timer_Service countdown reaches zero, THE Alarm_Service SHALL play an alarm sound in a repeating loop with no silence gap exceeding 1 second between repetitions
2. WHILE the Alarm_Service is playing, THE Timer_Screen SHALL display a stop-alarm button with a minimum tap target of 60×60 logical points, centered horizontally on screen
3. WHILE the Alarm_Service is playing, THE Live_Activity_Manager SHALL display on the lock screen that the timer has completed and show a dismiss control
4. WHEN the user presses the stop-alarm button or the lock screen dismiss control, THE Alarm_Service SHALL stop playing the alarm sound within 200ms and THE Timer_Screen SHALL return to the idle state
5. WHILE the app is in the background or the device is locked, THE Alarm_Service SHALL continue playing the alarm sound and THE Live_Activity_Manager SHALL remain visible on the lock screen until the user dismisses it
6. WHEN the user dismisses the alarm, THE Live_Activity_Manager SHALL remove the timer completion Live Activity from the lock screen

### Requirement 6: Description Entry After Alarm Dismissal

**User Story:** As a user, I want to describe what I did during the timer interval after dismissing the alarm, so that I can keep a log of my activities.

#### Acceptance Criteria

1. WHEN the user stops the alarm, THE App SHALL display the Description_Prompt
2. THE Description_Prompt SHALL contain a text input field for the user to enter a description of up to 500 characters
3. THE Description_Prompt SHALL contain a submit button to confirm the description
4. WHILE the description text field is empty or contains only whitespace characters, THE Description_Prompt SHALL keep the submit button disabled
5. WHEN the user submits a non-empty description, THE App SHALL save the Time_Entry to the Local_Database with the timer's original start time, the time the timer reached zero as the end time, and the entered description trimmed of leading and trailing whitespace
6. WHILE the Description_Prompt is displayed, THE App SHALL NOT allow the user to dismiss, close, or navigate away from the Description_Prompt without submitting a description

### Requirement 7: Auto-Restart After Description Submission

**User Story:** As a user, I want the timer to automatically restart after I submit my description, so that I can continue working without manual interaction.

#### Acceptance Criteria

1. WHEN the user submits the description in the Description_Prompt and the Time_Entry is successfully saved to the Local_Database, THE Timer_Service SHALL reset the countdown to the Timer_Duration value
2. WHEN the Timer_Service resets after description submission, THE Timer_Service SHALL automatically start counting down without requiring user interaction
3. WHEN the auto-restart occurs, THE App SHALL dismiss the Description_Prompt and return to the Timer_Screen within 500 milliseconds of the submission
4. IF the Time_Entry fails to save to the Local_Database during submission, THEN THE App SHALL NOT restart the timer and SHALL display an error message on the Description_Prompt while preserving the user's entered description

### Requirement 8: Time Log History

**User Story:** As a user, I want to view a history of all my past timer entries, so that I can review what I accomplished.

#### Acceptance Criteria

1. THE History_Screen SHALL display a list of all Time_Entry records from the Local_Database ordered by start time descending
2. THE History_Screen SHALL display each Time_Entry with its start time and end time formatted as "yyyy-MM-dd HH:mm", and its description truncated to a single line with a maximum visible length of 50 characters followed by an ellipsis if longer
3. WHEN the user taps on a Time_Entry description in the History_Screen, THE App SHALL present an inline editable text field pre-filled with the current description, allowing the user to modify the text up to a maximum of 500 characters
4. WHEN the user saves an edited description, THE Local_Database SHALL update the Time_Entry with the new description and the History_Screen SHALL reflect the updated text immediately
5. IF the user attempts to save a description that is empty or contains only whitespace, THEN THE App SHALL prevent the save and display an inline error message indicating that a description is required
6. IF a description save to the Local_Database fails, THEN THE App SHALL retain the edited text in the input field and display an inline error message indicating the save was unsuccessful
7. THE History_Screen SHALL NOT allow modification of start time or end time values

### Requirement 9: Local Database Storage

**User Story:** As a user, I want my time entries stored locally on my device, so that my data persists between app sessions.

#### Acceptance Criteria

1. THE Local_Database SHALL store each Time_Entry with a start time (ISO 8601 datetime), end time (ISO 8601 datetime), and description (text, maximum 500 characters)
2. THE Local_Database SHALL persist data between app launches
3. WHEN the App launches, THE Local_Database SHALL be initialized and ready for read and write operations within 3 seconds of app start
4. IF a database write operation fails, THEN THE App SHALL display an error message indicating the write failure and retain the unsaved Time_Entry data in memory so the user can retry the save manually
5. IF the Local_Database fails to initialize on app launch, THEN THE App SHALL display an error message indicating the database is unavailable and prevent navigation to screens that require database access

### Requirement 10: iOS Platform and Language

**User Story:** As a developer, I want the app to target iOS on iPhone 16, so that platform-specific features like Live Activities work correctly.

#### Acceptance Criteria

1. THE App SHALL target iOS as the sole deployment platform with a minimum deployment target of iOS 18.0
2. THE App SHALL render its layout at the iPhone 16 native screen resolution (393×852 logical points at 3x scale factor) without cropping or letterboxing
3. THE App SHALL display all user interface text in English
4. THE App SHALL be built using Flutter with iOS-specific platform channel support enabled for Live Activities

### Requirement 11: Visual Design Compliance

**User Story:** As a user, I want the app to look and feel exactly like the HTML/JS design prototype, so that the final product matches the approved visual design.

#### Acceptance Criteria

1. THE App SHALL replicate the visual design defined in the HTML/JS prototype located at #[[file:timelog_app/.design/Pomodoro.dc.html]] including layout, spacing, typography, colors, and component shapes
2. THE Timer_Screen SHALL display the countdown inside a circular SVG-style progress ring with a 288×288 logical point diameter, stroke width of 9, rounded stroke caps, and a glow drop-shadow on the progress arc
3. THE Timer_Screen SHALL use the JetBrains Mono font at 64pt weight 300 for the countdown digits, and Sora font for all other UI text
4. THE App SHALL implement the "Ember" color theme as the default: background #1A1310, text #EEE6DC, accent #E88A66, panels with rgba(255,255,255,0.045) background and rgba(255,255,255,0.08) border
5. THE App SHALL use a bottom tab navigation bar with two tabs: "Timer" and "History", styled identically to the prototype (icon + label, accent color when active, faint color when inactive)
6. THE Timer_Screen controls SHALL consist of a circular reset button (52×52), a large circular play/pause button (80×80) with the accent color fill and box-shadow glow, and a circular finish-now button (52×52)
7. THE Description_Prompt SHALL be presented as a bottom sheet with rounded top corners (24px radius), a drag handle indicator, textarea input, and action buttons matching the prototype styling
8. THE History_Screen SHALL display each Time_Entry inside a rounded panel (15px radius) with time range in accent-colored JetBrains Mono, duration label, description text, and edit/delete icon buttons
9. WHEN the timer completes, THE ringing overlay SHALL display a fullscreen overlay with a pulsing circular badge (120×120, accent-colored with glow animation) and a large dismiss button matching the prototype
10. THE App SHALL support three color themes (Ember, Midnight, Paper) selectable via theme dots in the header, with each theme applying its complete color palette as defined in the prototype

### Requirement 12: Day-Based History Filtering

**User Story:** As a user, I want to filter the history view by day, so that I can review what I accomplished on a specific date.

#### Acceptance Criteria

1. WHEN the user opens the History_Screen, THE History_Screen SHALL display Time_Entry records for the current day (today) as the default selected day
2. THE History_Screen SHALL display the currently selected day as a formatted date label using the following rules: "Today" for the current date, "Yesterday" for the previous date, and "yyyy-MM-dd" format for all other dates
3. WHEN the user navigates to the previous day, THE History_Screen SHALL display only Time_Entry records whose start time falls within that calendar day, with no restriction on how far back the user may navigate
4. WHEN the user navigates to the next day, THE History_Screen SHALL display only Time_Entry records whose start time falls within that calendar day
5. WHILE the selected day is the current day (today), THE History_Screen SHALL disable the next-day navigation control
6. WHEN the selected day contains no Time_Entry records, THE History_Screen SHALL display an empty state message indicating no entries exist for that day
7. THE History_Screen SHALL determine day boundaries using the device local time zone (midnight to midnight)
8. THE History_Screen SHALL display the filtered Time_Entry records for the selected day ordered by start time descending

### Requirement 13: Delete Time Entry

**User Story:** As a user, I want to delete individual time entries from the history, so that I can remove entries that are no longer relevant or were logged in error.

#### Acceptance Criteria

1. THE History_Screen SHALL display a delete button for each Time_Entry in the list
2. WHEN the user presses the delete button on a Time_Entry, THE App SHALL display a confirmation dialog asking the user to confirm the deletion
3. WHEN the user confirms the deletion, THE Local_Database SHALL permanently remove the Time_Entry record
4. WHEN the Time_Entry is successfully deleted from the Local_Database, THE History_Screen SHALL immediately remove the entry from the displayed list without requiring a manual refresh
5. WHEN the user cancels the deletion confirmation, THE App SHALL dismiss the confirmation dialog and leave the Time_Entry unchanged
6. IF the deletion from the Local_Database fails, THEN THE App SHALL display an inline error message indicating the deletion was unsuccessful and retain the Time_Entry in the list

### Requirement 14: Finish Timer Early

**User Story:** As a user, I want to finish the current timer session early before it reaches zero, so that I can log my work and move on when I complete a task ahead of schedule.

#### Acceptance Criteria

1. WHILE the Timer_Service is running or paused, THE Timer_Screen SHALL display a finish-now button
2. WHEN the user presses the finish-now button, THE Timer_Service SHALL stop the countdown immediately
3. WHEN the Timer_Service stops via the finish-now button, THE App SHALL display the Description_Prompt identical to the flow triggered when the timer reaches zero naturally
4. WHEN the user submits a description after finishing early, THE App SHALL save the Time_Entry to the Local_Database with the timer's original start time as the start time and the moment the user pressed the finish-now button as the end time
5. WHEN the finish-now flow completes with a submitted description, THE Timer_Service SHALL auto-restart the countdown following the same behavior defined in Requirement 7

### Requirement 15: Duration Adjuster in UI

**User Story:** As a user, I want to adjust the timer duration before starting a session, so that I can work in shorter or longer intervals depending on my current task.

#### Acceptance Criteria

1. WHILE the Timer_Service is in the idle state, THE Timer_Screen SHALL display a duration adjustment control
2. WHILE the Timer_Service is running or paused, THE Timer_Screen SHALL hide or disable the duration adjustment control
3. WHEN the user increases the duration via the adjustment control, THE Timer_Screen SHALL increment the displayed duration by 5 minutes
4. WHEN the user decreases the duration via the adjustment control, THE Timer_Screen SHALL decrement the displayed duration by 5 minutes
5. THE duration adjustment control SHALL enforce a minimum value of 5 minutes and a maximum value of 60 minutes
6. WHEN the user adjusts the duration, THE Timer_Service SHALL use the adjusted value as the countdown starting point for the next timer run
7. THE adjusted duration value SHALL NOT modify the Timer_Duration configuration default, which remains at 20 minutes
8. THE App SHALL persist the adjusted duration value across app launches so that the previously adjusted value is restored on the next app start

### Requirement 16: Timer State Persistence Across App Termination

**User Story:** As a user, I want the timer to resume correctly after the app is force-killed or terminated by the system, so that I do not lose my current timer session.

#### Acceptance Criteria

1. WHILE the Timer_Service is running or paused, THE App SHALL persist the timer state including session start time, scheduled end time, and current status to local storage
2. WHEN the App launches and a persisted timer state exists with a scheduled end time in the future, THE Timer_Service SHALL restore the countdown and resume from the correct remaining time
3. WHEN the App launches and a persisted timer state exists with a scheduled end time in the past, THE App SHALL display the ringing or completion state so the user can dismiss the alarm and enter a description
4. WHEN the user completes or stops the timer, THE App SHALL clear the persisted timer state from local storage
5. IF the persisted timer state is corrupted or unreadable on app launch, THEN THE App SHALL discard the invalid state and start with the timer in the idle state
