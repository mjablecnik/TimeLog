import 'package:flutter/services.dart';
import '../core/platform_channel.dart';

/// Schedules/cancels a native local notification for timer completion.
/// This ensures the alarm sound plays even when the app is in background.
class NotificationService {
  static const _channel = MethodChannel(PlatformChannels.notifications);

  /// Request notification permission (call once at app start).
  Future<bool> requestPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Schedule a notification to fire at [endAt].
  Future<void> scheduleTimerNotification({required DateTime endAt}) async {
    try {
      await _channel.invokeMethod<void>('scheduleNotification', {
        'endAtMs': endAt.millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  /// Cancel any pending timer notification (on pause/stop).
  Future<void> cancelTimerNotification() async {
    try {
      await _channel.invokeMethod<void>('cancelNotification');
    } catch (_) {}
  }
}
