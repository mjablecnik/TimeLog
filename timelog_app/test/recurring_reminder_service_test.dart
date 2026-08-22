import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/l10n/generated/app_localizations.dart';
import 'package:timelog_app/services/active_days_utils.dart';
import 'package:timelog_app/services/recurring_reminder_service.dart';

void main() {
  // computeUpcomingNotificationTimes/getNotificationId/isoDateString are
  // pure functions with no plugin/database dependency, so they're testable
  // directly without a live FlutterLocalNotificationsPlugin or sqlite3.
  final allDays = encodeDays({1, 2, 3, 4, 5, 6, 7});

  test('grid-aligned times start at the window start when now is before it', () {
    final now = DateTime(2026, 7, 20, 6, 0); // Monday 06:00
    final times = RecurringReminderService.computeUpcomingNotificationTimes(
      startMinutes: 8 * 60, // 08:00
      endMinutes: 12 * 60, // 12:00
      intervalMinutes: 60,
      activeDays: allDays,
      isActive: true,
      now: now,
      hasCompletionToday: false,
    );
    expect(times, [
      DateTime(2026, 7, 20, 8, 0),
      DateTime(2026, 7, 20, 9, 0),
      DateTime(2026, 7, 20, 10, 0),
      DateTime(2026, 7, 20, 11, 0),
    ]);
  });

  test('only future times within the 6h lookahead are returned mid-window', () {
    final now = DateTime(2026, 7, 20, 9, 30); // Monday 09:30
    final times = RecurringReminderService.computeUpcomingNotificationTimes(
      startMinutes: 8 * 60,
      endMinutes: 18 * 60,
      intervalMinutes: 60,
      activeDays: allDays,
      isActive: true,
      now: now,
      hasCompletionToday: false,
    );
    // Grid: 08,09,10,...17. now=09:30 -> next is 10:00. Lookahead ends 15:30.
    expect(times, [
      DateTime(2026, 7, 20, 10, 0),
      DateTime(2026, 7, 20, 11, 0),
      DateTime(2026, 7, 20, 12, 0),
      DateTime(2026, 7, 20, 13, 0),
      DateTime(2026, 7, 20, 14, 0),
      DateTime(2026, 7, 20, 15, 0),
    ]);
  });

  test('overnight window spans across midnight', () {
    final now = DateTime(2026, 7, 20, 22, 0); // Monday 22:00
    final times = RecurringReminderService.computeUpcomingNotificationTimes(
      startMinutes: 22 * 60, // 22:00
      endMinutes: 2 * 60, // 02:00 next day
      intervalMinutes: 60,
      activeDays: allDays,
      isActive: true,
      now: now,
      hasCompletionToday: false,
    );
    expect(times, [
      DateTime(2026, 7, 20, 22, 0),
      DateTime(2026, 7, 20, 23, 0),
      DateTime(2026, 7, 21, 0, 0),
      DateTime(2026, 7, 21, 1, 0),
    ]);
  });

  test('overnight window still running from yesterday is picked up after midnight', () {
    final now = DateTime(2026, 7, 21, 0, 30); // Tuesday 00:30
    final times = RecurringReminderService.computeUpcomingNotificationTimes(
      startMinutes: 22 * 60,
      endMinutes: 2 * 60,
      intervalMinutes: 60,
      activeDays: allDays,
      isActive: true,
      now: now,
      hasCompletionToday: false,
    );
    expect(times, [
      DateTime(2026, 7, 21, 1, 0),
    ]);
  });

  test('returns empty once the window has ended for today', () {
    final now = DateTime(2026, 7, 20, 19, 0); // Monday 19:00, window ended 18:00
    final times = RecurringReminderService.computeUpcomingNotificationTimes(
      startMinutes: 8 * 60,
      endMinutes: 18 * 60,
      intervalMinutes: 60,
      activeDays: allDays,
      isActive: true,
      now: now,
      hasCompletionToday: false,
    );
    expect(times, isEmpty);
  });

  test('returns empty for an inactive reminder', () {
    final now = DateTime(2026, 7, 20, 9, 0);
    final times = RecurringReminderService.computeUpcomingNotificationTimes(
      startMinutes: 8 * 60,
      endMinutes: 18 * 60,
      intervalMinutes: 60,
      activeDays: allDays,
      isActive: false,
      now: now,
      hasCompletionToday: false,
    );
    expect(times, isEmpty);
  });

  test('returns empty when already completed today', () {
    final now = DateTime(2026, 7, 20, 9, 0);
    final times = RecurringReminderService.computeUpcomingNotificationTimes(
      startMinutes: 8 * 60,
      endMinutes: 18 * 60,
      intervalMinutes: 60,
      activeDays: allDays,
      isActive: true,
      now: now,
      hasCompletionToday: true,
    );
    expect(times, isEmpty);
  });

  test('skips today when it is not an active day but finds tomorrow if active', () {
    // Monday is not active; Tuesday is. now is Monday 07:00 (before Tuesday's
    // 08:00 start, and within the 6h lookahead since it's only 25h away)
    // -- 25h > 6h, so Tuesday's window should NOT appear.
    final tuesdayOnly = encodeDays({2});
    final now = DateTime(2026, 7, 20, 7, 0); // Monday
    final times = RecurringReminderService.computeUpcomingNotificationTimes(
      startMinutes: 8 * 60,
      endMinutes: 18 * 60,
      intervalMinutes: 60,
      activeDays: tuesdayOnly,
      isActive: true,
      now: now,
      hasCompletionToday: false,
    );
    expect(times, isEmpty);

    // Now check that a close-enough next active day IS picked up: Monday
    // 23:00 with only Tuesday active, window 00:00-06:00 (Tuesday morning).
    final closeNow = DateTime(2026, 7, 20, 23, 0);
    final closeTimes = RecurringReminderService.computeUpcomingNotificationTimes(
      startMinutes: 0,
      endMinutes: 6 * 60,
      intervalMinutes: 60,
      activeDays: tuesdayOnly,
      isActive: true,
      now: closeNow,
      hasCompletionToday: false,
    );
    expect(closeTimes, [
      DateTime(2026, 7, 21, 0, 0),
      DateTime(2026, 7, 21, 1, 0),
      DateTime(2026, 7, 21, 2, 0),
      DateTime(2026, 7, 21, 3, 0),
      DateTime(2026, 7, 21, 4, 0),
    ]);
  });

  test('getNotificationId is unique per reminder/slot and matches the formula', () {
    expect(RecurringReminderService.getNotificationId(1, 0), 1 * 100 + 0 + 2000);
    expect(RecurringReminderService.getNotificationId(1, 1), 2101);
    expect(RecurringReminderService.getNotificationId(2, 0), 2200);
    final ids = <int>{};
    for (var reminderId = 1; reminderId <= 5; reminderId++) {
      for (var slot = 0; slot < 10; slot++) {
        expect(ids.add(RecurringReminderService.getNotificationId(reminderId, slot)), isTrue);
      }
    }
  });

  test('buildNotificationBody falls back to the localized default text', () {
    final csL10n = lookupAppLocalizations(const Locale('cs'));
    expect(RecurringReminderService.buildNotificationBody(null, csL10n), 'Klepni pro otevření');
    expect(RecurringReminderService.buildNotificationBody('   ', csL10n), 'Klepni pro otevření');
    expect(
      RecurringReminderService.buildNotificationBody('Vezmi si prášky', csL10n),
      'Vezmi si prášky',
    );

    final enL10n = lookupAppLocalizations(const Locale('en'));
    expect(RecurringReminderService.buildNotificationBody(null, enL10n), 'Tap to open');
  });

  test('parseReminderIdFromPayload extracts the id or returns null', () {
    expect(parseReminderIdFromPayload('recurring_reminder:42'), 42);
    expect(parseReminderIdFromPayload('recurring_reminder:'), isNull);
    expect(parseReminderIdFromPayload('start_timer'), isNull);
    expect(parseReminderIdFromPayload(null), isNull);
  });

  test('isoDateString and isoDateTimeString format with zero-padding', () {
    expect(isoDateString(DateTime(2026, 1, 5)), '2026-01-05');
    expect(isoDateTimeString(DateTime(2026, 1, 5, 8, 3, 9)), '2026-01-05T08:03:09');
  });
}
