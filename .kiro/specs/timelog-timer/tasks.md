# Implementation Plan: TimeLog Timer

## Overview

Implement a Flutter iOS countdown timer app with local SQLite persistence, Live Activity support via platform channels, and a polished UI matching the HTML/JS prototype. The app uses Riverpod for state management, Drift for the database, audioplayers for alarm sound, and a native Swift Widget Extension for lock screen / Dynamic Island display.

## Tasks

- [x] 1. Project setup and core infrastructure
  - [x] 1.1 Configure pubspec.yaml with all dependencies
    - Add flutter_riverpod, drift, sqlite3_flutter_libs, path_provider, path, audioplayers, freezed, freezed_annotation, build_runner, drift_dev, json_annotation, json_serializable, dart_check (dev)
    - Add flutter_test and dart_check under dev_dependencies
    - Configure font assets (Sora, JetBrains Mono) and alarm.mp3 asset
    - _Requirements: 10.4, 11.3_

  - [x] 1.2 Create core configuration and constants
    - Create `lib/core/config.dart` with `TimerConfig` class (validation: 1–1440 minutes, default 20)
    - Create `lib/core/platform_channel.dart` with channel name constants
    - Create `lib/core/extensions.dart` with DateTime/Duration helper extensions
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

  - [x] 1.3 Create theme definitions
    - Create `lib/core/theme.dart` with `AppThemeData` class and all three theme presets (Ember, Midnight, Paper)
    - Define all color tokens: background, text, accent, ink, panel, border, track, dim, faint, glow, glowSoft
    - Ember as default theme
    - _Requirements: 11.4, 11.10_

  - [x] 1.4 Set up app entry point and routing
    - Create `lib/main.dart` with ProviderScope and app initialization
    - Create `lib/app.dart` with MaterialApp, theme application, and bottom tab navigation (Timer, History)
    - _Requirements: 11.5, 10.4_

- [x] 2. Database layer
  - [x] 2.1 Define Drift database and TimeEntry table
    - Create `lib/data/time_entry.dart` with TimeEntries table definition (id, startTime, endTime, description, createdAt)
    - Create `lib/data/database.dart` with Drift database class, migration strategy
    - Run build_runner to generate `database.g.dart`
    - _Requirements: 9.1, 9.2_

  - [x] 2.2 Implement DatabaseService
    - Create `lib/services/database_service.dart` with initialize, insertTimeEntry, getEntriesForDay, updateDescription, deleteEntry, watchEntriesForDay
    - Implement day boundary filtering using device local time zone (midnight to midnight)
    - Handle initialization timeout (3 seconds)
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 12.7_

  - [x] 2.3 Create database provider
    - Create `lib/providers/database_provider.dart` with Riverpod provider for DatabaseService instance
    - Handle async initialization with error state
    - _Requirements: 9.3, 9.5_

  - [ ]* 2.4 Write property test for database round-trip preservation
    - **Property 7: Database round-trip preservation**
    - **Validates: Requirements 9.1**

- [x] 3. Timer service and state management
  - [x] 3.1 Implement TimerService with state machine
    - Create `lib/services/timer_service.dart` with TimerState (freezed), TimerStatus enum, and TimerNotifier
    - Implement state transitions: idle → running → paused → running, running → ringing, ringing → logging
    - Store absolute `endAt` timestamp, recalculate `secondsLeft` from wall clock
    - Implement WidgetsBindingObserver for app lifecycle (foreground recalculation)
    - Implement start(), pause(), resume(), stop(), finishNow(), autoRestart()
    - _Requirements: 1.2, 1.3, 1.4, 1.5, 1.6, 3.1, 3.2, 3.3, 3.4, 7.1, 7.2, 7.3_

  - [x] 3.2 Create timer provider
    - Create `lib/providers/timer_provider.dart` with StateNotifierProvider for TimerNotifier
    - Wire to AlarmService and LiveActivityChannel for side effects
    - _Requirements: 1.2, 1.3, 1.4, 1.5, 1.6_

  - [ ]* 3.3 Write property test for timer configuration validation
    - **Property 1: Timer configuration validation**
    - **Validates: Requirements 2.1, 2.4**

  - [ ]* 3.4 Write property test for time recalculation correctness
    - **Property 2: Time recalculation correctness**
    - **Validates: Requirements 3.1**

- [x] 4. Alarm service
  - [x] 4.1 Implement AlarmService
    - Create `lib/services/alarm_service.dart` using audioplayers package
    - Implement play() with ReleaseMode.loop, stop() within 200ms
    - Bundle alarm.mp3 as asset
    - Handle playback errors gracefully (log, don't crash)
    - _Requirements: 5.1, 5.4, 5.5_

- [x] 5. Checkpoint - Core services
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Timer UI
  - [x] 6.1 Implement circular progress ring with CustomPainter
    - Create `lib/ui/painters/ring_painter.dart` with CustomPainter
    - 288×288 logical points diameter, stroke width 9, rounded stroke caps
    - Glow drop-shadow on progress arc, track circle behind
    - Animate stroke-dashoffset based on progress fraction
    - _Requirements: 11.2_

  - [x] 6.2 Implement timer screen
    - Create `lib/ui/screens/timer_screen.dart` with timer ring, countdown text (JetBrains Mono 64pt weight 300), phase label, hint text
    - Duration adjuster (±5 min stepper) visible only in idle state
    - Wire to timerProvider for reactive state display
    - Update displayed time every second while running
    - _Requirements: 1.1, 1.3, 1.7, 1.8, 1.9, 11.2, 11.3_

  - [x] 6.3 Implement timer controls
    - Create `lib/ui/widgets/timer_controls.dart` with reset (52×52), play/pause (80×80 accent fill + glow shadow), finish-now (52×52)
    - Enable/disable buttons per state: idle → play only, running → pause + stop, paused → play + stop
    - _Requirements: 1.6, 1.7, 1.8, 1.9, 11.6_

  - [x] 6.4 Implement ringing overlay
    - Create `lib/ui/widgets/ringing_overlay.dart` with fullscreen overlay
    - Pulsing circular badge (120×120, accent-colored with glow animation)
    - Dismiss button with minimum 60×60 tap target, centered horizontally
    - _Requirements: 5.2, 5.4, 11.9_

  - [x] 6.5 Implement description bottom sheet
    - Create `lib/ui/widgets/description_sheet.dart` as non-dismissible bottom sheet
    - Rounded top corners (24px radius), drag handle, textarea (max 500 chars), submit button
    - Disable submit when empty or whitespace-only
    - On submit: trim description, save TimeEntry, trigger auto-restart
    - Show error message on DB save failure, preserve input text
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 7.1, 7.2, 7.3, 7.4, 11.7_

  - [ ]* 6.6 Write property test for whitespace-only description rejection
    - **Property 3: Whitespace-only description rejection**
    - **Validates: Requirements 6.4, 8.5**

  - [ ]* 6.7 Write property test for description trimming on save
    - **Property 4: Description trimming on save**
    - **Validates: Requirements 6.5**

- [x] 7. History UI
  - [x] 7.1 Implement day navigator widget
    - Create `lib/ui/widgets/day_navigator.dart` with prev/next arrows and date label
    - Display "Today" / "Yesterday" / "yyyy-MM-dd" based on selected date
    - Disable next-day when selected day is today
    - Include hidden date picker overlay for direct date selection
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

  - [x] 7.2 Implement history screen
    - Create `lib/ui/screens/history_screen.dart` with day navigator, summary stats, entry list
    - Create `lib/ui/widgets/history_entry_card.dart` with time range (accent JetBrains Mono), duration, description (truncated to 50 chars + ellipsis), edit/delete buttons
    - Create `lib/ui/widgets/day_summary.dart` with entry count and total time
    - Create `lib/ui/widgets/empty_state.dart` for days with no entries
    - _Requirements: 8.1, 8.2, 8.7, 11.8, 12.1, 12.6, 12.8_

  - [x] 7.3 Implement history providers
    - Create `lib/providers/history_provider.dart` with selectedDayProvider and dayEntriesProvider (StreamProvider)
    - Wire reactive day-based filtering via DatabaseService.watchEntriesForDay
    - _Requirements: 12.3, 12.4, 12.7, 12.8_

  - [x] 7.4 Implement edit sheet for history entries
    - Create `lib/ui/widgets/edit_sheet.dart` as bottom sheet for editing descriptions
    - Pre-fill with current description, validate non-empty, max 500 chars
    - Show inline error on empty save attempt or DB failure
    - _Requirements: 8.3, 8.4, 8.5, 8.6_

  - [ ]* 7.5 Write property test for history sorting
    - **Property 5: History entries sorted by start time descending**
    - **Validates: Requirements 8.1, 12.8**

  - [ ]* 7.6 Write property test for description truncation
    - **Property 6: Description display truncation**
    - **Validates: Requirements 8.2**

  - [ ]* 7.7 Write property test for date label formatting
    - **Property 8: Date label formatting**
    - **Validates: Requirements 12.2**

  - [ ]* 7.8 Write property test for day-based entry filtering
    - **Property 9: Day-based entry filtering**
    - **Validates: Requirements 12.3, 12.4, 12.7**

- [x] 8. Checkpoint - UI complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 9. Theme system and visual polish
  - [x] 9.1 Implement theme provider and theme dots
    - Create `lib/providers/theme_provider.dart` with StateNotifierProvider for active theme
    - Create `lib/ui/widgets/theme_dots.dart` with three color dots in header for theme selection
    - Persist selected theme across app launches
    - _Requirements: 11.10_

  - [x] 9.2 Implement bottom navigation bar
    - Create `lib/ui/widgets/bottom_nav.dart` with Timer and History tabs
    - Style: icon + label, accent color when active, faint color when inactive
    - Match prototype styling (border-top, safe area padding)
    - _Requirements: 11.5_

- [x] 10. Live Activity platform channel (Flutter side)
  - [x] 10.1 Implement LiveActivityChannel
    - Create `lib/services/live_activity_channel.dart` with MethodChannel bridge
    - Implement startActivity, updateActivity, endActivity, areActivitiesEnabled
    - Handle incoming `onLockScreenAction` calls from iOS (pause/resume/stop)
    - Gracefully handle permission denied / system limit failures (silent fallback)
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9_

- [x] 11. iOS native Live Activity implementation
  - [x] 11.1 Configure iOS project for Live Activities
    - Update `ios/Runner/Info.plist` with `NSSupportsLiveActivities = YES`
    - Set minimum deployment target to iOS 18.0
    - Create Widget Extension target `TimeLogWidgetExtension`
    - _Requirements: 10.1, 4.1_

  - [x] 11.2 Implement Swift LiveActivityManager
    - Create `ios/Runner/LiveActivityManager.swift` with ActivityKit wrapper
    - Implement startLiveActivity, updateLiveActivity, endLiveActivity
    - Handle MethodChannel communication from Flutter
    - _Requirements: 4.1, 4.8, 4.9_

  - [x] 11.3 Implement AppDelegate platform channel setup
    - Update `ios/Runner/AppDelegate.swift` with MethodChannel handler
    - Route method calls to LiveActivityManager
    - Send lock screen button actions back to Flutter via reverse channel
    - _Requirements: 4.4, 4.5, 4.6, 10.4_

  - [x] 11.4 Implement Widget Extension views
    - Create `ios/TimeLogWidgetExtension/TimeLogAttributes.swift` with ActivityAttributes
    - Create `ios/TimeLogWidgetExtension/TimeLogLiveActivity.swift` with lock screen view (countdown using Text(timerInterval:)), Dynamic Island compact/expanded views
    - Include pause/resume/stop button controls on lock screen
    - Show completion state with dismiss control
    - _Requirements: 4.2, 4.3, 4.7, 5.3, 5.6_

- [x] 12. Checkpoint - Full feature integration
  - Ensure all tests pass, ask the user if questions arise.

- [x] 13. Integration and final wiring
  - [x] 13.1 Wire timer completion flow end-to-end
    - Connect timer reaching zero → alarm plays → ringing overlay shows → Live Activity updates to completed
    - Connect dismiss alarm → alarm stops → description sheet appears → submit saves entry → auto-restart begins → new Live Activity starts
    - Verify background timer expiry triggers alarm and correct UI state on foreground return
    - _Requirements: 3.3, 3.4, 5.1, 5.4, 5.5, 6.1, 6.5, 7.1, 7.2, 7.3_

  - [x] 13.2 Wire history editing and deletion
    - Connect edit button → edit sheet → save updates DB → list refreshes
    - Connect delete button → confirmation → remove entry → list refreshes
    - Ensure day navigation updates reactive stream correctly
    - _Requirements: 8.3, 8.4, 8.5, 8.6_

  - [x] 13.3 Configure iOS build settings
    - Set deployment target iOS 18.0 in Xcode project
    - Configure screen resolution for iPhone 16 (393×852 @ 3x)
    - Ensure no cropping or letterboxing
    - Set display language to English
    - _Requirements: 10.1, 10.2, 10.3_

  - [ ]* 13.4 Write integration tests for timer flow
    - Test full cycle: start → ring → describe → auto-restart
    - Test pause/resume flow
    - Test stop/reset flow
    - _Requirements: 1.2, 1.4, 1.5, 1.6, 5.1, 5.4, 6.5, 7.1, 7.2_

  - [ ]* 13.5 Write integration tests for history flow
    - Test day navigation and filtering
    - Test edit and save flow
    - Test empty state display
    - _Requirements: 8.1, 8.3, 8.4, 12.1, 12.3, 12.5, 12.6_

- [x] 14. Final checkpoint - All integration complete
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- The iOS Widget Extension (task 11) requires Xcode and macOS for building — platform channel Flutter code can be developed/tested independently
- Font files (Sora, JetBrains Mono) and alarm.mp3 must be added to the assets directory before task 1.1 is complete

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["1.2", "1.3", "1.4"] },
    { "id": 2, "tasks": ["2.1", "4.1"] },
    { "id": 3, "tasks": ["2.2", "2.3", "3.1"] },
    { "id": 4, "tasks": ["2.4", "3.2", "3.3", "3.4"] },
    { "id": 5, "tasks": ["6.1", "6.2", "6.3", "7.3", "9.1", "10.1"] },
    { "id": 6, "tasks": ["6.4", "6.5", "7.1", "7.2", "9.2"] },
    { "id": 7, "tasks": ["6.6", "6.7", "7.4", "7.5", "7.6", "7.7", "7.8"] },
    { "id": 8, "tasks": ["11.1"] },
    { "id": 9, "tasks": ["11.2", "11.3"] },
    { "id": 10, "tasks": ["11.4"] },
    { "id": 11, "tasks": ["13.1", "13.2", "13.3"] },
    { "id": 12, "tasks": ["13.4", "13.5"] }
  ]
}
```
