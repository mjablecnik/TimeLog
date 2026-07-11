import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timelog_app/providers/reminder_provider.dart';
import 'package:timelog_app/services/reminder_service.dart';

class _FakeReminderService extends ReminderService {
  int scheduleCalls = 0;
  int cancelCalls = 0;
  TimeOfDay? lastScheduledTime;

  @override
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    scheduleCalls++;
    lastScheduledTime = time;
  }

  @override
  Future<void> cancelReminder() async {
    cancelCalls++;
  }
}

void main() {
  ReminderNotifier createNotifier(_FakeReminderService service) {
    return ReminderNotifier(service);
  }

  test('loads default values when nothing is stored', () async {
    SharedPreferences.setMockInitialValues({});
    final notifier = createNotifier(_FakeReminderService());
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state.enabled, isFalse);
    expect(notifier.state.hour, 8);
    expect(notifier.state.minute, 0);
  });

  test('reflects stored values on init', () async {
    SharedPreferences.setMockInitialValues({
      'reminder_enabled': true,
      'reminder_hour': 7,
      'reminder_minute': 30,
    });
    final notifier = createNotifier(_FakeReminderService());
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state.enabled, isTrue);
    expect(notifier.state.hour, 7);
    expect(notifier.state.minute, 30);
  });

  test('toggleEnabled flips state, persists to SharedPreferences, and schedules the service', () async {
    SharedPreferences.setMockInitialValues({});
    final service = _FakeReminderService();
    final notifier = createNotifier(service);
    await Future<void>.delayed(Duration.zero);

    await notifier.toggleEnabled();

    expect(notifier.state.enabled, isTrue);
    expect(service.scheduleCalls, 1);
    expect(service.cancelCalls, 0);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('reminder_enabled'), isTrue);
  });

  test('toggleEnabled off persists to SharedPreferences and cancels the service', () async {
    SharedPreferences.setMockInitialValues({'reminder_enabled': true});
    final service = _FakeReminderService();
    final notifier = createNotifier(service);
    await Future<void>.delayed(Duration.zero);

    await notifier.toggleEnabled();

    expect(notifier.state.enabled, isFalse);
    expect(service.cancelCalls, 1);
    expect(service.scheduleCalls, 0);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('reminder_enabled'), isFalse);
  });

  test('setTime persists hour/minute to SharedPreferences and reschedules when enabled', () async {
    SharedPreferences.setMockInitialValues({'reminder_enabled': true});
    final service = _FakeReminderService();
    final notifier = createNotifier(service);
    await Future<void>.delayed(Duration.zero);

    await notifier.setTime(const TimeOfDay(hour: 9, minute: 15));

    expect(notifier.state.hour, 9);
    expect(notifier.state.minute, 15);
    expect(service.cancelCalls, 1);
    expect(service.scheduleCalls, 1);
    expect(service.lastScheduledTime, const TimeOfDay(hour: 9, minute: 15));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('reminder_hour'), 9);
    expect(prefs.getInt('reminder_minute'), 15);
  });

  test('setTime persists but does not schedule when reminder is disabled', () async {
    SharedPreferences.setMockInitialValues({});
    final service = _FakeReminderService();
    final notifier = createNotifier(service);
    await Future<void>.delayed(Duration.zero);

    await notifier.setTime(const TimeOfDay(hour: 6, minute: 45));

    expect(notifier.state.hour, 6);
    expect(notifier.state.minute, 45);
    expect(service.scheduleCalls, 0);
    expect(service.cancelCalls, 0);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('reminder_hour'), 6);
    expect(prefs.getInt('reminder_minute'), 45);
  });
}
