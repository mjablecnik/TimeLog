import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/reminder_service.dart';

const _kReminderEnabled = 'reminder_enabled';
const _kReminderHour = 'reminder_hour';
const _kReminderMinute = 'reminder_minute';

const _kDefaultHour = 8;
const _kDefaultMinute = 0;

class ReminderSettings {
  final bool enabled;
  final int hour;
  final int minute;

  const ReminderSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  ReminderSettings copyWith({bool? enabled, int? hour, int? minute}) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }
}

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService();
});

class ReminderNotifier extends StateNotifier<ReminderSettings> {
  final ReminderService _service;

  ReminderNotifier(this._service)
      : super(const ReminderSettings(
          enabled: false,
          hour: _kDefaultHour,
          minute: _kDefaultMinute,
        )) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = ReminderSettings(
      enabled: prefs.getBool(_kReminderEnabled) ?? false,
      hour: prefs.getInt(_kReminderHour) ?? _kDefaultHour,
      minute: prefs.getInt(_kReminderMinute) ?? _kDefaultMinute,
    );
  }

  Future<void> toggleEnabled() async {
    final enabled = !state.enabled;
    state = state.copyWith(enabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReminderEnabled, enabled);
    if (enabled) {
      await _service.scheduleDailyReminder(state.timeOfDay);
    } else {
      await _service.cancelReminder();
    }
  }

  Future<void> setTime(TimeOfDay time) async {
    state = state.copyWith(hour: time.hour, minute: time.minute);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kReminderHour, time.hour);
    await prefs.setInt(_kReminderMinute, time.minute);
    if (state.enabled) {
      await _service.cancelReminder();
      await _service.scheduleDailyReminder(time);
    }
  }
}

final reminderProvider =
    StateNotifierProvider<ReminderNotifier, ReminderSettings>((ref) {
  final service = ref.watch(reminderServiceProvider);
  return ReminderNotifier(service);
});
