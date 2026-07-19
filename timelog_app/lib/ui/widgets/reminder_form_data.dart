import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../services/active_days_utils.dart';

/// UI-layer state for the Reminder_Edit_Dialog form.
class ReminderFormData {
  final String name;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int repeatIntervalMinutes;
  final Set<int> activeDays; // 1-7 (Monday-Sunday)
  final bool isActive;

  const ReminderFormData({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.repeatIntervalMinutes,
    required this.activeDays,
    required this.isActive,
  });

  bool get isValid => name.trim().isNotEmpty && activeDays.isNotEmpty;

  RecurringRemindersCompanion toCompanion() {
    return RecurringRemindersCompanion(
      name: Value(name.trim()),
      description: const Value(null),
      startTime: Value(startTime.hour * 60 + startTime.minute),
      endTime: Value(endTime.hour * 60 + endTime.minute),
      repeatInterval: Value(repeatIntervalMinutes),
      activeDays: Value(encodeDays(activeDays)),
      isActive: Value(isActive),
    );
  }
}
