import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/alarm_service.dart';
import '../services/live_activity_channel.dart';
import '../services/notification_service.dart';
import '../services/timer_service.dart';

final alarmServiceProvider = Provider<AlarmService>((ref) {
  final service = AlarmService();
  ref.onDispose(service.dispose);
  return service;
});

final liveActivityChannelProvider = Provider<LiveActivityChannel>((ref) {
  return LiveActivityChannel();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  final alarm = ref.watch(alarmServiceProvider);
  final liveActivity = ref.watch(liveActivityChannelProvider);
  final notifications = ref.watch(notificationServiceProvider);
  return TimerNotifier(alarm, liveActivity, notifications);
});
