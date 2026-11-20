import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('en'),
  ];

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get commonUnassigned;

  /// No description provided for @errorDatabaseUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Database unavailable. Please try again.'**
  String get errorDatabaseUnavailable;

  /// No description provided for @errorSaveEntryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save entry. Please try again.'**
  String get errorSaveEntryFailed;

  /// No description provided for @errorSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save. Please try again.'**
  String get errorSaveFailed;

  /// No description provided for @errorDescriptionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Description cannot be empty.'**
  String get errorDescriptionEmpty;

  /// No description provided for @errorEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time.'**
  String get errorEndBeforeStart;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @projectNameHint.
  ///
  /// In en, this message translates to:
  /// **'Project name...'**
  String get projectNameHint;

  /// No description provided for @projectNameFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get projectNameFieldHint;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what you worked on...'**
  String get descriptionHint;

  /// No description provided for @timeFieldStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get timeFieldStart;

  /// No description provided for @timeFieldEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get timeFieldEnd;

  /// No description provided for @durationMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutesLabel(int minutes);

  /// No description provided for @durationMinutesOnly.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationMinutesOnly(int minutes);

  /// No description provided for @durationHoursOnly.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String durationHoursOnly(int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mo'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tu'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'We'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Th'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fr'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sa'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Su'**
  String get weekdaySun;

  /// No description provided for @activityWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get activityWork;

  /// No description provided for @activityHousework.
  ///
  /// In en, this message translates to:
  /// **'Housework'**
  String get activityHousework;

  /// No description provided for @activityCommute.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get activityCommute;

  /// No description provided for @activityEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get activityEntertainment;

  /// No description provided for @activityExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get activityExercise;

  /// No description provided for @activitySelfDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Self-development'**
  String get activitySelfDevelopment;

  /// No description provided for @activityRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get activityRest;

  /// No description provided for @activityHygiene.
  ///
  /// In en, this message translates to:
  /// **'Hygiene'**
  String get activityHygiene;

  /// No description provided for @activityMeal.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get activityMeal;

  /// No description provided for @activityMeeting.
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get activityMeeting;

  /// No description provided for @activityCommunication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get activityCommunication;

  /// No description provided for @activityOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get activityOther;

  /// No description provided for @subtypePaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get subtypePaid;

  /// No description provided for @subtypeUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get subtypeUnpaid;

  /// No description provided for @subtypeEntertainmentActive.
  ///
  /// In en, this message translates to:
  /// **'Active entertainment'**
  String get subtypeEntertainmentActive;

  /// No description provided for @subtypeEntertainmentPassive.
  ///
  /// In en, this message translates to:
  /// **'Passive entertainment'**
  String get subtypeEntertainmentPassive;

  /// No description provided for @subtypeWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get subtypeWalk;

  /// No description provided for @subtypeRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get subtypeRunning;

  /// No description provided for @subtypeGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get subtypeGym;

  /// No description provided for @subtypeBooks.
  ///
  /// In en, this message translates to:
  /// **'Reading books'**
  String get subtypeBooks;

  /// No description provided for @subtypeStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get subtypeStudy;

  /// No description provided for @subtypeAi.
  ///
  /// In en, this message translates to:
  /// **'AI consultation'**
  String get subtypeAi;

  /// No description provided for @subtypeRestActive.
  ///
  /// In en, this message translates to:
  /// **'Active rest'**
  String get subtypeRestActive;

  /// No description provided for @subtypeRestPassive.
  ///
  /// In en, this message translates to:
  /// **'Passive rest'**
  String get subtypeRestPassive;

  /// No description provided for @subtypeGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get subtypeGeneral;

  /// No description provided for @subtypeToilet.
  ///
  /// In en, this message translates to:
  /// **'Toilet'**
  String get subtypeToilet;

  /// No description provided for @subtypeBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get subtypeBreakfast;

  /// No description provided for @subtypeLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get subtypeLunch;

  /// No description provided for @subtypeDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get subtypeDinner;

  /// No description provided for @subtypeSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get subtypeSnack;

  /// No description provided for @subtypeShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get subtypeShopping;

  /// No description provided for @scopeWorkPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid work'**
  String get scopeWorkPaid;

  /// No description provided for @scopeWorkUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid work'**
  String get scopeWorkUnpaid;

  /// No description provided for @scopeHousework.
  ///
  /// In en, this message translates to:
  /// **'Housework'**
  String get scopeHousework;

  /// No description provided for @scopeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get scopeOther;

  /// No description provided for @pickerTypeCaption.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get pickerTypeCaption;

  /// No description provided for @pickerSubtypeHeading.
  ///
  /// In en, this message translates to:
  /// **'Refine: {type}'**
  String pickerSubtypeHeading(String type);

  /// No description provided for @pickerSubtypeHint.
  ///
  /// In en, this message translates to:
  /// **'Choose one'**
  String get pickerSubtypeHint;

  /// No description provided for @customNameHint.
  ///
  /// In en, this message translates to:
  /// **'What did you do?'**
  String get customNameHint;

  /// No description provided for @statsByCustomName.
  ///
  /// In en, this message translates to:
  /// **'Other by name'**
  String get statsByCustomName;

  /// No description provided for @taskProjectCategoryCaption.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get taskProjectCategoryCaption;

  /// No description provided for @taskProjectEditCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get taskProjectEditCategory;

  /// No description provided for @taskProjectChipSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, {category}'**
  String taskProjectChipSemantics(String name, String category);

  /// No description provided for @timerPrefillTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pre-fill description'**
  String get timerPrefillTooltip;

  /// No description provided for @timerPhaseReady.
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get timerPhaseReady;

  /// No description provided for @timerPhaseFocus.
  ///
  /// In en, this message translates to:
  /// **'FOCUS'**
  String get timerPhaseFocus;

  /// No description provided for @timerPhasePaused.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get timerPhasePaused;

  /// No description provided for @timerPhaseTimeUp.
  ///
  /// In en, this message translates to:
  /// **'TIME UP'**
  String get timerPhaseTimeUp;

  /// No description provided for @timerPhaseLogging.
  ///
  /// In en, this message translates to:
  /// **'LOGGING'**
  String get timerPhaseLogging;

  /// No description provided for @timerResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset timer?'**
  String get timerResetTitle;

  /// No description provided for @timerResetBody.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to reset the timer?'**
  String get timerResetBody;

  /// No description provided for @timerTimeUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Time is up!'**
  String get timerTimeUpTitle;

  /// No description provided for @ringingDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get ringingDismiss;

  /// No description provided for @descriptionClearFormTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear form'**
  String get descriptionClearFormTooltip;

  /// No description provided for @descriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'What did you accomplish?'**
  String get descriptionTitle;

  /// No description provided for @prefillSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get prefillSaveDraft;

  /// No description provided for @editSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit description'**
  String get editSheetTitle;

  /// No description provided for @manualEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get manualEntryTitle;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load entries.'**
  String get historyLoadError;

  /// No description provided for @historyEntryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} entry} other{{count} entries}}'**
  String historyEntryCount(int count);

  /// No description provided for @historyTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: {duration}'**
  String historyTotalLabel(String duration);

  /// No description provided for @historyDeleteEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get historyDeleteEntryTitle;

  /// No description provided for @historyDeleteEntryBody.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get historyDeleteEntryBody;

  /// No description provided for @historyDbUnavailableShort.
  ///
  /// In en, this message translates to:
  /// **'Database unavailable.'**
  String get historyDbUnavailableShort;

  /// No description provided for @historyDeleteEntryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete entry.'**
  String get historyDeleteEntryFailed;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No entries for this day'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a timer to log your work'**
  String get historyEmptySubtitle;

  /// No description provided for @dayToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dayToday;

  /// No description provided for @dayYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dayYesterday;

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @taskCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create task.'**
  String get taskCreateFailed;

  /// No description provided for @taskReorderFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to move task.'**
  String get taskReorderFailed;

  /// No description provided for @tasksShowArchived.
  ///
  /// In en, this message translates to:
  /// **'Show archived tasks'**
  String get tasksShowArchived;

  /// No description provided for @tasksLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load tasks.'**
  String get tasksLoadFailed;

  /// No description provided for @tasksEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get tasksEmptyTitle;

  /// No description provided for @tasksEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first task'**
  String get tasksEmptySubtitle;

  /// No description provided for @tasksArchivedHeader.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get tasksArchivedHeader;

  /// No description provided for @taskToggleFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update task status.'**
  String get taskToggleFailed;

  /// No description provided for @taskUnarchiveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore task.'**
  String get taskUnarchiveFailed;

  /// No description provided for @taskSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save task.'**
  String get taskSaveFailed;

  /// No description provided for @taskDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete task?'**
  String get taskDeleteTitle;

  /// No description provided for @taskDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be permanently removed.'**
  String taskDeleteBody(String title);

  /// No description provided for @taskDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete task.'**
  String get taskDeleteFailed;

  /// No description provided for @taskEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get taskEditTitle;

  /// No description provided for @taskNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get taskNewTitle;

  /// No description provided for @taskTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get taskTitleHint;

  /// No description provided for @taskDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get taskDescriptionHint;

  /// No description provided for @taskDeadlineHint.
  ///
  /// In en, this message translates to:
  /// **'Deadline (optional)'**
  String get taskDeadlineHint;

  /// No description provided for @projectCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create project.'**
  String get projectCreateFailed;

  /// No description provided for @projectDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete project \"{name}\"?'**
  String projectDeleteTitle(String name);

  /// No description provided for @projectDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'All tasks in this project will be permanently deleted.'**
  String get projectDeleteBody;

  /// No description provided for @projectDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete project.'**
  String get projectDeleteFailed;

  /// No description provided for @projectCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New project'**
  String get projectCreateTitle;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @statsPeriodDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get statsPeriodDay;

  /// No description provided for @statsPeriodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get statsPeriodWeek;

  /// No description provided for @statsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load statistics.'**
  String get statsLoadFailed;

  /// No description provided for @statsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get statsThisWeek;

  /// No description provided for @statsNoEntriesPeriod.
  ///
  /// In en, this message translates to:
  /// **'No entries for this period'**
  String get statsNoEntriesPeriod;

  /// No description provided for @statsByActivityType.
  ///
  /// In en, this message translates to:
  /// **'By activity type'**
  String get statsByActivityType;

  /// No description provided for @statsByProject.
  ///
  /// In en, this message translates to:
  /// **'By project'**
  String get statsByProject;

  /// No description provided for @statsTotalTracked.
  ///
  /// In en, this message translates to:
  /// **'Total tracked'**
  String get statsTotalTracked;

  /// No description provided for @statsUntrackedTime.
  ///
  /// In en, this message translates to:
  /// **'Untracked time'**
  String get statsUntrackedTime;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get navTimer;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsDailyReminderSection.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get settingsDailyReminderSection;

  /// No description provided for @settingsReminderToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'Remind me to start the timer'**
  String get settingsReminderToggleLabel;

  /// No description provided for @settingsReminderTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get settingsReminderTimeLabel;

  /// No description provided for @settingsRecurringRemindersLabel.
  ///
  /// In en, this message translates to:
  /// **'Recurring reminders'**
  String get settingsRecurringRemindersLabel;

  /// No description provided for @settingsDataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsDataSection;

  /// No description provided for @settingsExportButton.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get settingsExportButton;

  /// No description provided for @settingsExportHint.
  ///
  /// In en, this message translates to:
  /// **'Saves all data into one file you can move elsewhere.'**
  String get settingsExportHint;

  /// No description provided for @settingsExportFailed.
  ///
  /// In en, this message translates to:
  /// **'The export failed. Please try again.'**
  String get settingsExportFailed;

  /// No description provided for @settingsTestingSection.
  ///
  /// In en, this message translates to:
  /// **'Testing'**
  String get settingsTestingSection;

  /// No description provided for @settingsTestNotificationButton.
  ///
  /// In en, this message translates to:
  /// **'Test notification (in 5 s)'**
  String get settingsTestNotificationButton;

  /// No description provided for @settingsShowModalDebugButton.
  ///
  /// In en, this message translates to:
  /// **'Show modal directly (debug)'**
  String get settingsShowModalDebugButton;

  /// No description provided for @settingsNotificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled. Enable them in your phone\'s settings.'**
  String get settingsNotificationsDisabled;

  /// No description provided for @settingsNoRemindersYet.
  ///
  /// In en, this message translates to:
  /// **'First create at least one recurring reminder.'**
  String get settingsNoRemindersYet;

  /// No description provided for @settingsTestNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'🧪 Test: {name}'**
  String settingsTestNotificationTitle(String name);

  /// No description provided for @settingsTestNotificationScheduled.
  ///
  /// In en, this message translates to:
  /// **'Test notification will arrive in 5 seconds.'**
  String get settingsTestNotificationScheduled;

  /// No description provided for @settingsNoReminder.
  ///
  /// In en, this message translates to:
  /// **'No reminder.'**
  String get settingsNoReminder;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSection;

  /// No description provided for @reminderDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete reminder?'**
  String get reminderDeleteTitle;

  /// No description provided for @reminderDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Reminder \"{name}\" will be permanently deleted.'**
  String reminderDeleteBody(String name);

  /// No description provided for @reminderDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete reminder.'**
  String get reminderDeleteFailed;

  /// No description provided for @remindersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any reminders yet'**
  String get remindersEmptyTitle;

  /// No description provided for @remindersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first reminder'**
  String get remindersEmptySubtitle;

  /// No description provided for @remindersLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load reminders.'**
  String get remindersLoadFailed;

  /// No description provided for @reminderSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get reminderSnooze;

  /// No description provided for @reminderDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get reminderDone;

  /// No description provided for @reminderCompletionUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update completion status.'**
  String get reminderCompletionUpdateFailed;

  /// No description provided for @reminderActiveToggleFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update reminder.'**
  String get reminderActiveToggleFailed;

  /// No description provided for @reminderCapacityError.
  ///
  /// In en, this message translates to:
  /// **'Not enough notification slots: {available} available, {required} needed.'**
  String reminderCapacityError(int available, int required);

  /// No description provided for @reminderDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get reminderDiscardTitle;

  /// No description provided for @reminderDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes will be lost.'**
  String get reminderDiscardBody;

  /// No description provided for @reminderDiscardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get reminderDiscardConfirm;

  /// No description provided for @reminderEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get reminderEditTitle;

  /// No description provided for @reminderNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get reminderNewTitle;

  /// No description provided for @reminderNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get reminderNameHint;

  /// No description provided for @reminderFromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get reminderFromLabel;

  /// No description provided for @reminderToLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get reminderToLabel;

  /// No description provided for @reminderOvernightNote.
  ///
  /// In en, this message translates to:
  /// **'Window spans past midnight into the next day.'**
  String get reminderOvernightNote;

  /// No description provided for @reminderIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat interval'**
  String get reminderIntervalLabel;

  /// No description provided for @reminderActiveDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get reminderActiveDaysLabel;

  /// No description provided for @reminderActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get reminderActiveLabel;

  /// No description provided for @reminderEditBarrierLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder edit dialog'**
  String get reminderEditBarrierLabel;

  /// No description provided for @reminderDailyNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Time to start your timer!'**
  String get reminderDailyNotificationBody;

  /// No description provided for @recurringReminderDefaultNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Tap to open'**
  String get recurringReminderDefaultNotificationBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['cs', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
