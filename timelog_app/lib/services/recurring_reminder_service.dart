import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/app_locale.dart';
import '../data/database.dart';
import '../l10n/generated/app_localizations.dart';
import 'active_days_utils.dart';

/// Prefix for the notification payload identifying a recurring reminder tap.
/// Full payload format: `recurring_reminder:` followed by the reminder ID.
const String recurringReminderPayloadPrefix = 'recurring_reminder:';

/// Extracts the reminder ID from a notification [payload], or `null` if the
/// payload is missing or does not belong to a recurring reminder.
int? parseReminderIdFromPayload(String? payload) {
  if (payload == null || !payload.startsWith(recurringReminderPayloadPrefix)) {
    return null;
  }
  return int.tryParse(payload.substring(recurringReminderPayloadPrefix.length));
}

/// Formats [date] as an ISO 8601 date string ("YYYY-MM-DD"), used for
/// completion-record lookups and inserts.
String isoDateString(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Formats [dateTime] as an ISO 8601 datetime string ("YYYY-MM-DDTHH:mm:ss").
String isoDateTimeString(DateTime dateTime) {
  final h = dateTime.hour.toString().padLeft(2, '0');
  final min = dateTime.minute.toString().padLeft(2, '0');
  final s = dateTime.second.toString().padLeft(2, '0');
  return '${isoDateString(dateTime)}T$h:$min:$s';
}

/// Handles a notification response dispatched to a background isolate (e.g.
/// Android delivering a tap while the app is not in the foreground). This
/// entry point has no guaranteed Flutter/database bindings, so it cannot
/// navigate directly — the actual routing to the Reminder_Action_Screen
/// happens once the main isolate resumes, via the foreground tap callback
/// or `getNotificationAppLaunchDetails` on cold launch. It must still be
/// registered (Requirement 15.1) so terminated-app taps are delivered at all.
@pragma('vm:entry-point')
void recurringReminderBackgroundHandler(NotificationResponse response) {}

/// A single computed notification occurrence for a reminder: the moment it
/// should fire, and its position within that occurrence's interval grid
/// (used to derive a stable notification ID for deduplication).
typedef ReminderNotificationSlot = ({DateTime time, int slotIndex});

/// Scheduling engine for Recurring_Reminders: computes notification times,
/// schedules/cancels them via [FlutterLocalNotificationsPlugin], and enforces
/// the daily completion/day-active/notification-count rules.
class RecurringReminderService {
  static const String channelId = 'recurring_reminders';
  static const String channelName = 'Recurring Reminders';
  static const int notificationIdOffset = 2000;
  static const int maxScheduledNotifications = 50;
  static const Duration lookahead = Duration(hours: 6);

  static const String reminderSoundFileName = 'reminder_sound.wav';
  static const String reminderSoundResourceName = 'reminder_sound';

  final FlutterLocalNotificationsPlugin _plugin;
  final AppDatabase _db;

  RecurringReminderService(this._plugin, this._db);

  /// Notification ID for a specific scheduled time slot of a reminder.
  /// Supports up to 100 notifications per reminder per day and avoids
  /// collision with the existing timer/daily-reminder notification (1001).
  static int getNotificationId(int reminderId, int slotIndex) =>
      (reminderId * 100) + slotIndex + notificationIdOffset;

  /// Whether [weekday] (1=Monday, 7=Sunday) is active in [activeDaysBitmask].
  static bool isActiveDay(int activeDaysBitmask, int weekday) =>
      isDayActive(activeDaysBitmask, weekday);

  /// Builds the notification body: the description, or a localized
  /// placeholder text (via [l10n]) if the description is null or blank.
  static String buildNotificationBody(String? description, AppLocalizations l10n) {
    if (description == null || description.trim().isEmpty) {
      return l10n.recurringReminderDefaultNotificationBody;
    }
    return description;
  }

  /// Computes all notification times within the next 6 hours, aligned to
  /// the interval grid (start, start + interval, start + 2*interval, ...).
  /// Returns an empty list if the reminder is inactive, already completed
  /// for today, the window has ended, or no active-day window falls within
  /// the lookahead.
  static List<DateTime> computeUpcomingNotificationTimes({
    required int startMinutes,
    required int endMinutes,
    required int intervalMinutes,
    required int activeDays,
    required bool isActive,
    required DateTime now,
    required bool hasCompletionToday,
  }) {
    return _computeUpcomingSlots(
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      intervalMinutes: intervalMinutes,
      activeDays: activeDays,
      isActive: isActive,
      now: now,
      hasCompletionToday: hasCompletionToday,
    ).map((slot) => slot.time).toList();
  }

  /// Number of notification occurrences a reminder with the given
  /// configuration would need scheduled right now — used by callers (e.g.
  /// the reminders provider) to check capacity before persisting a new or
  /// newly-activated reminder.
  static int requiredNotificationSlots({
    required int startMinutes,
    required int endMinutes,
    required int intervalMinutes,
    required int activeDays,
    required DateTime now,
  }) {
    return computeUpcomingNotificationTimes(
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      intervalMinutes: intervalMinutes,
      activeDays: activeDays,
      isActive: true,
      now: now,
      hasCompletionToday: false,
    ).length;
  }

  static List<ReminderNotificationSlot> _computeUpcomingSlots({
    required int startMinutes,
    required int endMinutes,
    required int intervalMinutes,
    required int activeDays,
    required bool isActive,
    required DateTime now,
    required bool hasCompletionToday,
  }) {
    if (!isActive) return [];

    final lookaheadEnd = now.add(lookahead);
    final overnight = startMinutes >= endMinutes;
    final durationMinutes =
        overnight ? (1440 - startMinutes) + endMinutes : endMinutes - startMinutes;
    final today = DateTime(now.year, now.month, now.day);
    final slots = <ReminderNotificationSlot>[];

    // Scan yesterday..tomorrow+1: an overnight window may have started the
    // day before and still be running (dayOffset -1), and the next active
    // day's window may need to be found if today is inactive or already
    // completed (up to a couple of days ahead, bounded by the 6h lookahead).
    for (int dayOffset = -1; dayOffset <= 2; dayOffset++) {
      final dayStart = today.add(Duration(days: dayOffset));
      if (!isDayActive(activeDays, dayStart.weekday)) continue;
      // A completion recorded for "today" blocks only the occurrence that
      // starts today; an overnight occurrence carried over from yesterday
      // (dayOffset == -1) belongs to yesterday's cycle and isn't affected.
      if (dayOffset == 0 && hasCompletionToday) continue;

      final windowStart = dayStart.add(Duration(minutes: startMinutes));
      final windowEnd = windowStart.add(Duration(minutes: durationMinutes));
      if (!windowEnd.isAfter(now)) continue;
      if (!windowStart.isBefore(lookaheadEnd)) continue;

      var t = windowStart;
      var slotIndex = 0;
      while (t.isBefore(windowEnd)) {
        if (!t.isBefore(now) && t.isBefore(lookaheadEnd)) {
          slots.add((time: t, slotIndex: slotIndex));
        }
        t = t.add(Duration(minutes: intervalMinutes));
        slotIndex++;
      }
    }

    slots.sort((a, b) => a.time.compareTo(b.time));
    return slots;
  }

  /// Number of recurring-reminder notifications currently pending across all
  /// reminders (identified by payload prefix, distinct from other app
  /// notifications like the daily reminder).
  Future<int> countScheduledNotifications() async {
    final pending = await _safeGetPendingRequests();
    return pending
        .where((p) => p.payload?.startsWith(recurringReminderPayloadPrefix) ?? false)
        .length;
  }

  /// How many more recurring-reminder notifications can be scheduled before
  /// hitting [maxScheduledNotifications]. If [excludingReminderId] is given,
  /// that reminder's own currently-pending slots are not counted as "used"
  /// (they are about to be cancelled and rescheduled by the caller).
  Future<int> availableNotificationSlots({int? excludingReminderId}) async {
    final pending = await _safeGetPendingRequests();
    final excludedMarker = excludingReminderId == null
        ? null
        : '$recurringReminderPayloadPrefix$excludingReminderId';
    final used = pending.where((p) {
      if (!(p.payload?.startsWith(recurringReminderPayloadPrefix) ?? false)) {
        return false;
      }
      return p.payload != excludedMarker;
    }).length;
    return (maxScheduledNotifications - used).clamp(0, maxScheduledNotifications);
  }

  /// Wraps [pendingNotificationRequests] with a try-catch to guard against
  /// platform-channel errors caused by native notifications that were not
  /// scheduled via this plugin (they may lack a numeric ID in userInfo).
  Future<List<PendingNotificationRequest>> _safeGetPendingRequests() async {
    try {
      return await _plugin.pendingNotificationRequests();
    } catch (_) {
      return [];
    }
  }

  /// Schedules all upcoming (within the 6h lookahead) notifications for
  /// [reminder], skipping any time slot already pending (deduplication) and
  /// stopping once the global [maxScheduledNotifications] cap is reached.
  Future<void> scheduleUpcoming(RecurringReminder reminder) async {
    if (!reminder.isActive) return;

    final l10n = await loadAppLocalizations();
    final now = tz.TZDateTime.now(tz.local);
    final hasCompletion =
        await _db.hasCompletionForToday(reminder.id, isoDateString(now));
    final slots = _computeUpcomingSlots(
      startMinutes: reminder.startTime,
      endMinutes: reminder.endTime,
      intervalMinutes: reminder.repeatInterval,
      activeDays: reminder.activeDays,
      isActive: reminder.isActive,
      now: now,
      hasCompletionToday: hasCompletion,
    );
    if (slots.isEmpty) return;

    final pending = await _safeGetPendingRequests();
    final pendingIds = pending.map((p) => p.id).toSet();
    final usedSlots = pending
        .where((p) => p.payload?.startsWith(recurringReminderPayloadPrefix) ?? false)
        .length;
    var remainingCapacity = maxScheduledNotifications - usedSlots;

    for (final slot in slots) {
      if (remainingCapacity <= 0) break;
      final id = getNotificationId(reminder.id, slot.slotIndex);
      if (pendingIds.contains(id)) continue;
      await _scheduleOne(reminder: reminder, id: id, time: slot.time, l10n: l10n);
      remainingCapacity--;
    }
  }

  Future<void> _scheduleOne({
    required RecurringReminder reminder,
    required int id,
    required DateTime time,
    required AppLocalizations l10n,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: tz.TZDateTime.from(time, tz.local),
      title: reminder.name,
      body: buildNotificationBody(reminder.description, l10n),
      payload: '$recurringReminderPayloadPrefix${reminder.id}',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound(reminderSoundResourceName),
        ),
        iOS: DarwinNotificationDetails(
          sound: reminderSoundFileName,
          presentAlert: true,
          presentSound: true,
          presentBadge: false,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Cancels all pending notifications for [reminderId] (e.g. on manual
  /// "done", deactivation, or deletion).
  Future<void> cancelReminder(int reminderId) async {
    final marker = '$recurringReminderPayloadPrefix$reminderId';
    final pending = await _safeGetPendingRequests();
    for (final p in pending) {
      if (p.payload == marker) {
        await _plugin.cancel(id: p.id);
      }
    }
  }

  /// Reschedules all active reminders (called on app launch). Reminders are
  /// processed in start-time-ascending order (as returned by
  /// [AppDatabase.getAllReminders]), so the earliest-starting reminders are
  /// naturally prioritized if the global notification cap is reached.
  Future<void> rescheduleAll() async {
    final reminders = await _db.getAllReminders();
    for (final reminder in reminders) {
      if (!reminder.isActive) continue;
      await scheduleUpcoming(reminder);
    }
  }

  /// Requests notification permission. Returns true if granted (or if the
  /// current platform has no runtime permission model, e.g. desktop).
  Future<bool> requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  /// Checks current permission status without prompting.
  Future<bool> hasPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final enabled = await androidPlugin.areNotificationsEnabled();
      return enabled ?? false;
    }
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final settings = await iosPlugin.checkPermissions();
      return settings?.isEnabled ?? false;
    }
    return true;
  }
}
