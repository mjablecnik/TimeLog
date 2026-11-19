// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonBack => 'Back';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonUnassigned => 'Unassigned';

  @override
  String get errorDatabaseUnavailable =>
      'Database unavailable. Please try again.';

  @override
  String get errorSaveEntryFailed => 'Failed to save entry. Please try again.';

  @override
  String get errorSaveFailed => 'Failed to save. Please try again.';

  @override
  String get errorDescriptionEmpty => 'Description cannot be empty.';

  @override
  String get errorEndBeforeStart => 'End time must be after start time.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get projectNameHint => 'Project name...';

  @override
  String get projectNameFieldHint => 'Project name';

  @override
  String get descriptionHint => 'Describe what you worked on...';

  @override
  String get timeFieldStart => 'Start';

  @override
  String get timeFieldEnd => 'End';

  @override
  String durationMinutesLabel(int minutes) {
    return '$minutes min';
  }

  @override
  String durationMinutesOnly(int minutes) {
    return '${minutes}m';
  }

  @override
  String durationHoursOnly(int hours) {
    return '${hours}h';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get weekdayMon => 'Mo';

  @override
  String get weekdayTue => 'Tu';

  @override
  String get weekdayWed => 'We';

  @override
  String get weekdayThu => 'Th';

  @override
  String get weekdayFri => 'Fr';

  @override
  String get weekdaySat => 'Sa';

  @override
  String get weekdaySun => 'Su';

  @override
  String get activityWork => 'Work';

  @override
  String get activityHousework => 'Housework';

  @override
  String get activityCommute => 'Travel';

  @override
  String get activityEntertainment => 'Entertainment';

  @override
  String get activityExercise => 'Exercise';

  @override
  String get activitySelfDevelopment => 'Self-development';

  @override
  String get activityRest => 'Rest';

  @override
  String get activityHygiene => 'Hygiene';

  @override
  String get activityMeal => 'Meal';

  @override
  String get activityMeeting => 'Meeting';

  @override
  String get activityCommunication => 'Communication';

  @override
  String get activityOther => 'Other';

  @override
  String get subtypePaid => 'Paid';

  @override
  String get subtypeUnpaid => 'Unpaid';

  @override
  String get subtypeEntertainmentActive => 'Active entertainment';

  @override
  String get subtypeEntertainmentPassive => 'Passive entertainment';

  @override
  String get subtypeWalk => 'Walk';

  @override
  String get subtypeRunning => 'Running';

  @override
  String get subtypeGym => 'Gym';

  @override
  String get subtypeBooks => 'Reading books';

  @override
  String get subtypeStudy => 'Study';

  @override
  String get subtypeAi => 'AI consultation';

  @override
  String get subtypeRestActive => 'Active rest';

  @override
  String get subtypeRestPassive => 'Passive rest';

  @override
  String get subtypeGeneral => 'General';

  @override
  String get subtypeToilet => 'Toilet';

  @override
  String get subtypeBreakfast => 'Breakfast';

  @override
  String get subtypeLunch => 'Lunch';

  @override
  String get subtypeDinner => 'Dinner';

  @override
  String get subtypeSnack => 'Snack';

  @override
  String get scopeWorkPaid => 'Paid work';

  @override
  String get scopeWorkUnpaid => 'Unpaid work';

  @override
  String get scopeHousework => 'Housework';

  @override
  String get scopeOther => 'Other';

  @override
  String get pickerTypeCaption => 'Type';

  @override
  String pickerSubtypeHeading(String type) {
    return 'Refine: $type';
  }

  @override
  String get pickerSubtypeHint => 'Choose one';

  @override
  String get customNameHint => 'What did you do?';

  @override
  String get statsByCustomName => 'Other by name';

  @override
  String get taskProjectCategoryCaption => 'Category';

  @override
  String get taskProjectEditCategory => 'Edit category';

  @override
  String taskProjectChipSemantics(String name, String category) {
    return '$name, $category';
  }

  @override
  String get timerPrefillTooltip => 'Pre-fill description';

  @override
  String get timerPhaseReady => 'READY';

  @override
  String get timerPhaseFocus => 'FOCUS';

  @override
  String get timerPhasePaused => 'PAUSED';

  @override
  String get timerPhaseTimeUp => 'TIME UP';

  @override
  String get timerPhaseLogging => 'LOGGING';

  @override
  String get timerResetTitle => 'Reset timer?';

  @override
  String get timerResetBody => 'Do you really want to reset the timer?';

  @override
  String get timerTimeUpTitle => 'Time is up!';

  @override
  String get ringingDismiss => 'Dismiss';

  @override
  String get descriptionClearFormTooltip => 'Clear form';

  @override
  String get descriptionTitle => 'What did you accomplish?';

  @override
  String get prefillSaveDraft => 'Save Draft';

  @override
  String get editSheetTitle => 'Edit description';

  @override
  String get manualEntryTitle => 'Add entry';

  @override
  String get historyTitle => 'History';

  @override
  String get historyLoadError => 'Failed to load entries.';

  @override
  String historyEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '$count entry',
    );
    return '$_temp0';
  }

  @override
  String historyTotalLabel(String duration) {
    return 'Total: $duration';
  }

  @override
  String get historyDeleteEntryTitle => 'Delete entry?';

  @override
  String get historyDeleteEntryBody => 'This action cannot be undone.';

  @override
  String get historyDbUnavailableShort => 'Database unavailable.';

  @override
  String get historyDeleteEntryFailed => 'Failed to delete entry.';

  @override
  String get historyEmptyTitle => 'No entries for this day';

  @override
  String get historyEmptySubtitle => 'Start a timer to log your work';

  @override
  String get dayToday => 'Today';

  @override
  String get dayYesterday => 'Yesterday';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get taskCreateFailed => 'Failed to create task.';

  @override
  String get taskReorderFailed => 'Failed to move task.';

  @override
  String get tasksShowArchived => 'Show archived tasks';

  @override
  String get tasksLoadFailed => 'Failed to load tasks.';

  @override
  String get tasksEmptyTitle => 'No tasks yet';

  @override
  String get tasksEmptySubtitle => 'Tap + to create your first task';

  @override
  String get tasksArchivedHeader => 'Archived';

  @override
  String get taskToggleFailed => 'Failed to update task status.';

  @override
  String get taskUnarchiveFailed => 'Failed to restore task.';

  @override
  String get taskSaveFailed => 'Failed to save task.';

  @override
  String get taskDeleteTitle => 'Delete task?';

  @override
  String taskDeleteBody(String title) {
    return '\"$title\" will be permanently removed.';
  }

  @override
  String get taskDeleteFailed => 'Failed to delete task.';

  @override
  String get taskEditTitle => 'Edit task';

  @override
  String get taskNewTitle => 'New task';

  @override
  String get taskTitleHint => 'Task title';

  @override
  String get taskDescriptionHint => 'Description (optional)';

  @override
  String get taskDeadlineHint => 'Deadline (optional)';

  @override
  String get projectCreateFailed => 'Failed to create project.';

  @override
  String projectDeleteTitle(String name) {
    return 'Delete project \"$name\"?';
  }

  @override
  String get projectDeleteBody =>
      'All tasks in this project will be permanently deleted.';

  @override
  String get projectDeleteFailed => 'Failed to delete project.';

  @override
  String get projectCreateTitle => 'New project';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsPeriodDay => 'Day';

  @override
  String get statsPeriodWeek => 'Week';

  @override
  String get statsLoadFailed => 'Failed to load statistics.';

  @override
  String get statsThisWeek => 'This week';

  @override
  String get statsNoEntriesPeriod => 'No entries for this period';

  @override
  String get statsByActivityType => 'By activity type';

  @override
  String get statsByProject => 'By project';

  @override
  String get statsTotalTracked => 'Total tracked';

  @override
  String get statsUntrackedTime => 'Untracked time';

  @override
  String get navStats => 'Stats';

  @override
  String get navTimer => 'Timer';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsDailyReminderSection => 'Daily reminder';

  @override
  String get settingsReminderToggleLabel => 'Remind me to start the timer';

  @override
  String get settingsReminderTimeLabel => 'Reminder time';

  @override
  String get settingsRecurringRemindersLabel => 'Recurring reminders';

  @override
  String get settingsTestingSection => 'Testing';

  @override
  String get settingsTestNotificationButton => 'Test notification (in 5 s)';

  @override
  String get settingsShowModalDebugButton => 'Show modal directly (debug)';

  @override
  String get settingsNotificationsDisabled =>
      'Notifications are disabled. Enable them in your phone\'s settings.';

  @override
  String get settingsNoRemindersYet =>
      'First create at least one recurring reminder.';

  @override
  String settingsTestNotificationTitle(String name) {
    return '🧪 Test: $name';
  }

  @override
  String get settingsTestNotificationScheduled =>
      'Test notification will arrive in 5 seconds.';

  @override
  String get settingsNoReminder => 'No reminder.';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get reminderDeleteTitle => 'Delete reminder?';

  @override
  String reminderDeleteBody(String name) {
    return 'Reminder \"$name\" will be permanently deleted.';
  }

  @override
  String get reminderDeleteFailed => 'Failed to delete reminder.';

  @override
  String get remindersEmptyTitle => 'You don\'t have any reminders yet';

  @override
  String get remindersEmptySubtitle => 'Tap + to create your first reminder';

  @override
  String get remindersLoadFailed => 'Failed to load reminders.';

  @override
  String get reminderSnooze => 'Snooze';

  @override
  String get reminderDone => 'Done';

  @override
  String get reminderCompletionUpdateFailed =>
      'Failed to update completion status.';

  @override
  String get reminderActiveToggleFailed => 'Failed to update reminder.';

  @override
  String reminderCapacityError(int available, int required) {
    return 'Not enough notification slots: $available available, $required needed.';
  }

  @override
  String get reminderDiscardTitle => 'Discard changes?';

  @override
  String get reminderDiscardBody => 'Unsaved changes will be lost.';

  @override
  String get reminderDiscardConfirm => 'Discard';

  @override
  String get reminderEditTitle => 'Edit reminder';

  @override
  String get reminderNewTitle => 'New reminder';

  @override
  String get reminderNameHint => 'Name';

  @override
  String get reminderFromLabel => 'From';

  @override
  String get reminderToLabel => 'To';

  @override
  String get reminderOvernightNote =>
      'Window spans past midnight into the next day.';

  @override
  String get reminderIntervalLabel => 'Repeat interval';

  @override
  String get reminderActiveDaysLabel => 'Active days';

  @override
  String get reminderActiveLabel => 'Active';

  @override
  String get reminderEditBarrierLabel => 'Reminder edit dialog';

  @override
  String get reminderDailyNotificationBody => 'Time to start your timer!';

  @override
  String get recurringReminderDefaultNotificationBody => 'Tap to open';
}
