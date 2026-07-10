import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/alarm_service.dart';
import '../services/live_activity_channel.dart';
import '../services/timer_service.dart';

final alarmServiceProvider = Provider<AlarmService>((ref) {
  final service = AlarmService();
  ref.onDispose(service.dispose);
  return service;
});

final liveActivityChannelProvider = Provider<LiveActivityChannel>((ref) {
  return LiveActivityChannel();
});

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  final alarm = ref.watch(alarmServiceProvider);
  final liveActivity = ref.watch(liveActivityChannelProvider);
  return TimerNotifier(alarm, liveActivity);
});
