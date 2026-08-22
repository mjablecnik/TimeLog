// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get commonCancel => 'Zrušit';

  @override
  String get commonBack => 'Zpět';

  @override
  String get commonSave => 'Uložit';

  @override
  String get commonDelete => 'Smazat';

  @override
  String get commonSubmit => 'Uložit';

  @override
  String get commonSkip => 'Přeskočit';

  @override
  String get commonReset => 'Resetovat';

  @override
  String get commonCreate => 'Vytvořit';

  @override
  String get commonUnassigned => 'Nepřiřazeno';

  @override
  String get errorDatabaseUnavailable =>
      'Databáze není dostupná. Zkuste to prosím znovu.';

  @override
  String get errorSaveEntryFailed =>
      'Uložení záznamu se nezdařilo. Zkuste to prosím znovu.';

  @override
  String get errorSaveFailed => 'Uložení se nezdařilo. Zkuste to prosím znovu.';

  @override
  String get errorDescriptionEmpty => 'Popis nesmí být prázdný.';

  @override
  String get errorEndBeforeStart => 'Konec musí být po začátku.';

  @override
  String get errorGeneric => 'Něco se pokazilo. Zkuste to prosím znovu.';

  @override
  String get projectNameHint => 'Název projektu...';

  @override
  String get projectNameFieldHint => 'Název projektu';

  @override
  String get descriptionHint => 'Popiš, na čem jsi pracoval/a...';

  @override
  String get timeFieldStart => 'Začátek';

  @override
  String get timeFieldEnd => 'Konec';

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
  String get weekdayMon => 'Po';

  @override
  String get weekdayTue => 'Út';

  @override
  String get weekdayWed => 'St';

  @override
  String get weekdayThu => 'Čt';

  @override
  String get weekdayFri => 'Pá';

  @override
  String get weekdaySat => 'So';

  @override
  String get weekdaySun => 'Ne';

  @override
  String get activityWork => 'Práce';

  @override
  String get activityHousework => 'Domácí práce';

  @override
  String get activityCommute => 'Přesun';

  @override
  String get activityEntertainment => 'Zábava';

  @override
  String get activityExercise => 'Cvičení';

  @override
  String get activitySelfDevelopment => 'Seberozvoj';

  @override
  String get activityRest => 'Odpočinek';

  @override
  String get activityHygiene => 'Hygiena';

  @override
  String get activityMeal => 'Jídlo';

  @override
  String get entertainmentActive => 'Aktivní zábava';

  @override
  String get entertainmentPassive => 'Pasivní zábava';

  @override
  String get timerPrefillTooltip => 'Předvyplnit popis';

  @override
  String get timerPhaseReady => 'PŘIPRAVENO';

  @override
  String get timerPhaseFocus => 'SOUSTŘEDĚNÍ';

  @override
  String get timerPhasePaused => 'PAUZA';

  @override
  String get timerPhaseTimeUp => 'ČAS VYPRŠEL';

  @override
  String get timerPhaseLogging => 'UKLÁDÁNÍ';

  @override
  String get timerResetTitle => 'Resetovat časovač?';

  @override
  String get timerResetBody => 'Opravdu chcete resetovat časovač?';

  @override
  String get timerTimeUpTitle => 'Čas vypršel!';

  @override
  String get ringingDismiss => 'Zavřít';

  @override
  String get descriptionClearFormTooltip => 'Vymazat formulář';

  @override
  String get descriptionTitle => 'Co se ti podařilo?';

  @override
  String get prefillSaveDraft => 'Uložit koncept';

  @override
  String get editSheetTitle => 'Upravit popis';

  @override
  String get manualEntryTitle => 'Přidat záznam';

  @override
  String get historyTitle => 'Historie';

  @override
  String get historyLoadError => 'Načtení záznamů se nezdařilo.';

  @override
  String historyEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count záznamů',
      few: '$count záznamy',
      one: '$count záznam',
    );
    return '$_temp0';
  }

  @override
  String historyTotalLabel(String duration) {
    return 'Celkem: $duration';
  }

  @override
  String get historyDeleteEntryTitle => 'Smazat záznam?';

  @override
  String get historyDeleteEntryBody => 'Tuto akci nelze vrátit zpět.';

  @override
  String get historyDbUnavailableShort => 'Databáze není dostupná.';

  @override
  String get historyDeleteEntryFailed => 'Smazání záznamu se nezdařilo.';

  @override
  String get historyEmptyTitle => 'Pro tento den nejsou žádné záznamy';

  @override
  String get historyEmptySubtitle =>
      'Spusť časovač a začni sledovat svou práci';

  @override
  String get dayToday => 'Dnes';

  @override
  String get dayYesterday => 'Včera';

  @override
  String get tasksTitle => 'Úkoly';

  @override
  String get taskCreateFailed => 'Vytvoření úkolu se nezdařilo.';

  @override
  String get taskReorderFailed => 'Přesunutí úkolu se nezdařilo.';

  @override
  String get tasksShowArchived => 'Zobrazit archivované úkoly';

  @override
  String get tasksLoadFailed => 'Načtení úkolů se nezdařilo.';

  @override
  String get tasksEmptyTitle => 'Zatím žádné úkoly';

  @override
  String get tasksEmptySubtitle => 'Klepnutím na + vytvoř první úkol';

  @override
  String get tasksArchivedHeader => 'Archivováno';

  @override
  String get taskToggleFailed => 'Nepodařilo se aktualizovat stav úkolu.';

  @override
  String get taskUnarchiveFailed => 'Nepodařilo se obnovit úkol.';

  @override
  String get taskSaveFailed => 'Nepodařilo se uložit úkol.';

  @override
  String get taskDeleteTitle => 'Smazat úkol?';

  @override
  String taskDeleteBody(String title) {
    return '\"$title\" bude trvale odstraněn.';
  }

  @override
  String get taskDeleteFailed => 'Nepodařilo se smazat úkol.';

  @override
  String get taskEditTitle => 'Upravit úkol';

  @override
  String get taskNewTitle => 'Nový úkol';

  @override
  String get taskTitleHint => 'Název úkolu';

  @override
  String get taskDescriptionHint => 'Popis (volitelné)';

  @override
  String get taskDeadlineHint => 'Termín (volitelné)';

  @override
  String get projectCreateFailed => 'Vytvoření projektu se nezdařilo.';

  @override
  String projectDeleteTitle(String name) {
    return 'Smazat projekt \"$name\"?';
  }

  @override
  String get projectDeleteBody =>
      'Všechny úkoly v tomto projektu budou trvale smazány.';

  @override
  String get projectDeleteFailed => 'Smazání projektu se nezdařilo.';

  @override
  String get projectCreateTitle => 'Nový projekt';

  @override
  String get statsTitle => 'Statistiky';

  @override
  String get statsPeriodDay => 'Den';

  @override
  String get statsPeriodWeek => 'Týden';

  @override
  String get statsLoadFailed => 'Nepodařilo se načíst statistiky.';

  @override
  String get statsThisWeek => 'Tento týden';

  @override
  String get statsNoEntriesPeriod => 'Žádné záznamy pro toto období';

  @override
  String get statsByActivityType => 'Podle typu aktivity';

  @override
  String get statsByProject => 'Podle projektu';

  @override
  String get statsTotalTracked => 'Celkem sledováno';

  @override
  String get statsUntrackedTime => 'Nesledovaný čas';

  @override
  String get navStats => 'Statistiky';

  @override
  String get navTimer => 'Časovač';

  @override
  String get settingsTitle => 'Nastavení';

  @override
  String get settingsDailyReminderSection => 'Denní připomínka';

  @override
  String get settingsReminderToggleLabel => 'Připomínat spuštění časovače';

  @override
  String get settingsReminderTimeLabel => 'Čas připomínky';

  @override
  String get settingsRecurringRemindersLabel => 'Opakované připomínky';

  @override
  String get settingsTestingSection => 'Testování';

  @override
  String get settingsTestNotificationButton => 'Testovací notifikace (za 5 s)';

  @override
  String get settingsShowModalDebugButton => 'Zobrazit modal přímo (debug)';

  @override
  String get settingsNotificationsDisabled =>
      'Oznámení jsou zakázána. Povolte je v nastavení telefonu.';

  @override
  String get settingsNoRemindersYet =>
      'Nejdříve vytvořte alespoň jednu opakovanou připomínku.';

  @override
  String settingsTestNotificationTitle(String name) {
    return '🧪 Test: $name';
  }

  @override
  String get settingsTestNotificationScheduled =>
      'Testovací notifikace přijde za 5 sekund.';

  @override
  String get settingsNoReminder => 'Žádná připomínka.';

  @override
  String get settingsLanguageSection => 'Jazyk';

  @override
  String get reminderDeleteTitle => 'Smazat připomínku?';

  @override
  String reminderDeleteBody(String name) {
    return 'Připomínka „$name“ bude trvale smazána.';
  }

  @override
  String get reminderDeleteFailed => 'Smazání připomínky se nezdařilo.';

  @override
  String get remindersEmptyTitle => 'Zatím nemáte žádné připomínky';

  @override
  String get remindersEmptySubtitle => 'Klepnutím na + vytvoř první připomínku';

  @override
  String get remindersLoadFailed => 'Nepodařilo se načíst připomínky.';

  @override
  String get reminderSnooze => 'Odložit';

  @override
  String get reminderDone => 'Hotovo';

  @override
  String get reminderCompletionUpdateFailed =>
      'Nepodařilo se aktualizovat stav dokončení.';

  @override
  String get reminderActiveToggleFailed =>
      'Nepodařilo se aktualizovat připomínku.';

  @override
  String reminderCapacityError(int available, int required) {
    return 'Nedostatek volných oznámení: k dispozici $available, potřeba $required.';
  }

  @override
  String get reminderDiscardTitle => 'Zahodit změny?';

  @override
  String get reminderDiscardBody => 'Neuložené změny budou ztraceny.';

  @override
  String get reminderDiscardConfirm => 'Zahodit';

  @override
  String get reminderEditTitle => 'Upravit připomínku';

  @override
  String get reminderNewTitle => 'Nová připomínka';

  @override
  String get reminderNameHint => 'Název';

  @override
  String get reminderFromLabel => 'Od';

  @override
  String get reminderToLabel => 'Do';

  @override
  String get reminderOvernightNote =>
      'Okno přesahuje přes půlnoc do dalšího dne.';

  @override
  String get reminderIntervalLabel => 'Interval opakování';

  @override
  String get reminderActiveDaysLabel => 'Aktivní dny';

  @override
  String get reminderActiveLabel => 'Aktivní';

  @override
  String get reminderEditBarrierLabel => 'Dialog pro úpravu připomínky';

  @override
  String get reminderDailyNotificationBody => 'Čas spustit časovač!';

  @override
  String get recurringReminderDefaultNotificationBody => 'Klepni pro otevření';
}
