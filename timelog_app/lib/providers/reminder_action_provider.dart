import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import 'database_provider.dart';
import 'recurring_reminders_provider.dart';

/// Holds the reminder ID that should be opened via ReminderActionScreen.
/// Set by the notification tap handler, consumed (reset to null) by the UI
/// once navigation is performed — same reactive pattern as the timer's
/// status-based sheet trigger.
final pendingReminderActionProvider = StateProvider<int?>((ref) => null);

/// State backing the Reminder_Action_Screen.
class ReminderActionState {
  final RecurringReminder? reminder;
  final bool isLoading;
  final String? error;

  const ReminderActionState({this.reminder, this.isLoading = false, this.error});
}

class ReminderActionNotifier extends StateNotifier<ReminderActionState> {
  final Ref _ref;

  ReminderActionNotifier(this._ref) : super(const ReminderActionState());

  /// Loads the reminder to display (name, description) on the screen.
  Future<void> load(int reminderId) async {
    state = ReminderActionState(reminder: state.reminder, isLoading: true);
    final reminder = await _ref.read(appDatabaseProvider).getReminderById(reminderId);
    state = ReminderActionState(reminder: reminder);
  }

  /// Marks the reminder as done for today: creates a Completion_Record and
  /// cancels its remaining notifications for today. On failure, surfaces the
  /// error via [ReminderActionState.error] without discarding the loaded
  /// reminder, so the screen stays open (Requirement 6.5).
  Future<void> markDone(int reminderId) async {
    state = ReminderActionState(reminder: state.reminder, isLoading: true);
    try {
      await _ref.read(recurringRemindersProvider.notifier).markDoneForToday(reminderId);
      state = ReminderActionState(reminder: state.reminder);
    } catch (e) {
      state = ReminderActionState(reminder: state.reminder, error: e.toString());
    }
  }

  /// Snoozes the reminder: no scheduling action is needed since subsequent
  /// notifications are already pre-scheduled via the 6-hour lookahead batch
  /// (Requirement 7.2). Dismissing the screen is the caller's responsibility.
  Future<void> snooze(int reminderId) async {}
}

final reminderActionProvider =
    StateNotifierProvider<ReminderActionNotifier, ReminderActionState>((ref) {
  return ReminderActionNotifier(ref);
});
