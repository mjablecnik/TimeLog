import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../data/database.dart';
import '../services/recurring_reminder_service.dart';
import 'database_provider.dart';
import 'reminder_provider.dart';

/// Thrown when creating or activating a Recurring_Reminder would exceed the
/// global scheduled-notification cap (Requirement 4.8).
class InsufficientNotificationCapacityError implements Exception {
  final int available;
  final int required;

  const InsufficientNotificationCapacityError({
    required this.available,
    required this.required,
  });

  @override
  String toString() =>
      'Dostupných slotů: $available, potřeba: $required — překročení o ${required - available}';
}

/// Shares the `FlutterLocalNotificationsPlugin` instance owned by
/// [ReminderService] so `flutter_local_notifications` is only initialized once.
final recurringReminderServiceProvider = Provider<RecurringReminderService>((ref) {
  final plugin = ref.watch(reminderServiceProvider).plugin;
  final db = ref.watch(appDatabaseProvider);
  return RecurringReminderService(plugin, db);
});

class RecurringRemindersNotifier extends AsyncNotifier<List<RecurringReminder>> {
  @override
  Future<List<RecurringReminder>> build() async {
    final db = ref.watch(appDatabaseProvider);
    final subscription = db.watchAllReminders().listen((reminders) {
      state = AsyncData(reminders);
    });
    ref.onDispose(subscription.cancel);
    return db.getAllReminders();
  }

  Future<void> _ensureCapacity(
    RecurringRemindersCompanion data, {
    int? excludingReminderId,
  }) async {
    if (!(data.isActive.present ? data.isActive.value : true)) return;
    final required = RecurringReminderService.requiredNotificationSlots(
      startMinutes: data.startTime.value,
      endMinutes: data.endTime.value,
      intervalMinutes: data.repeatInterval.value,
      activeDays: data.activeDays.value,
      now: tz.TZDateTime.now(tz.local),
    );
    if (required == 0) return;
    final service = ref.read(recurringReminderServiceProvider);
    final available = await service.availableNotificationSlots(
      excludingReminderId: excludingReminderId,
    );
    if (required > available) {
      throw InsufficientNotificationCapacityError(available: available, required: required);
    }
  }

  /// Creates a new reminder and schedules its first notifications. Throws
  /// [InsufficientNotificationCapacityError] without persisting anything if
  /// there isn't enough notification capacity.
  Future<void> addReminder(RecurringRemindersCompanion data) async {
    await _ensureCapacity(data);
    final db = ref.read(appDatabaseProvider);
    final id = await db.insertReminder(data);
    final reminder = await db.getReminderById(id);
    if (reminder != null && reminder.isActive) {
      await ref.read(recurringReminderServiceProvider).scheduleUpcoming(reminder);
    }
  }

  /// Updates an existing reminder and reschedules its notifications. Throws
  /// [InsufficientNotificationCapacityError] without persisting anything if
  /// the updated schedule would exceed notification capacity.
  Future<void> updateReminder(int id, RecurringRemindersCompanion data) async {
    await _ensureCapacity(data, excludingReminderId: id);
    final db = ref.read(appDatabaseProvider);
    final service = ref.read(recurringReminderServiceProvider);
    final ok = await db.updateReminder(data.copyWith(id: Value(id)));
    if (!ok) throw StateError('Recurring reminder $id not found');
    await service.cancelReminder(id);
    final reminder = await db.getReminderById(id);
    if (reminder != null && reminder.isActive) {
      await service.scheduleUpcoming(reminder);
    }
  }

  /// Deletes a reminder (cascading its completion records) and cancels its
  /// pending notifications.
  Future<void> deleteReminder(int id) async {
    final db = ref.read(appDatabaseProvider);
    await db.deleteReminder(id);
    await ref.read(recurringReminderServiceProvider).cancelReminder(id);
  }

  /// Toggles a reminder's active/inactive status. Throws
  /// [InsufficientNotificationCapacityError] without persisting the change
  /// if activating would exceed notification capacity (Requirement 3.5, 4.8).
  Future<void> toggleActive(int id) async {
    final db = ref.read(appDatabaseProvider);
    final service = ref.read(recurringReminderServiceProvider);
    final reminder = await db.getReminderById(id);
    if (reminder == null) return;
    final activating = !reminder.isActive;
    final updated = reminder.copyWith(isActive: activating);
    if (activating) {
      await _ensureCapacity(updated.toCompanion(true), excludingReminderId: id);
    }
    final ok = await db.updateReminder(updated.toCompanion(true));
    if (!ok) throw StateError('Recurring reminder $id not found');
    if (activating) {
      await service.scheduleUpcoming(updated);
    } else {
      await service.cancelReminder(id);
    }
  }

  /// Manually marks a reminder as done for today and cancels its remaining
  /// notifications for the day. A pre-existing completion for today is a
  /// no-op (Data Integrity: treat as already done).
  Future<void> markDoneForToday(int id) async {
    final db = ref.read(appDatabaseProvider);
    final now = tz.TZDateTime.now(tz.local);
    final today = isoDateString(now);
    if (await db.hasCompletionForToday(id, today)) return;
    await db.insertCompletionRecord(CompletionRecordsCompanion.insert(
      reminderId: id,
      completionDate: today,
      completionTimestamp: isoDateTimeString(now),
    ));
    await ref.read(recurringReminderServiceProvider).cancelReminder(id);
  }

  /// Undoes a manual completion for today and reschedules notifications
  /// within the 6-hour lookahead.
  Future<void> undoCompletionForToday(int id) async {
    final db = ref.read(appDatabaseProvider);
    await db.deleteCompletionForToday(id, isoDateString(tz.TZDateTime.now(tz.local)));
    final reminder = await db.getReminderById(id);
    if (reminder != null && reminder.isActive) {
      await ref.read(recurringReminderServiceProvider).scheduleUpcoming(reminder);
    }
  }
}

final recurringRemindersProvider =
    AsyncNotifierProvider<RecurringRemindersNotifier, List<RecurringReminder>>(
  RecurringRemindersNotifier.new,
);
