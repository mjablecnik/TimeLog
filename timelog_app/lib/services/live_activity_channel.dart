import 'package:flutter/services.dart';
import '../core/platform_channel.dart';

enum LiveActivityUpdate { paused, resumed, completed }

class LiveActivityChannel {
  static const _channel = MethodChannel(PlatformChannels.liveActivity);

  Future<bool> startActivity({
    required DateTime endAt,
    required int totalSeconds,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('startLiveActivity', {
        'endAt': endAt.millisecondsSinceEpoch,
        'totalSeconds': totalSeconds,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateActivity({required LiveActivityUpdate update}) async {
    final action = switch (update) {
      LiveActivityUpdate.paused => 'pause',
      LiveActivityUpdate.resumed => 'resume',
      LiveActivityUpdate.completed => 'complete',
    };
    try {
      await _channel.invokeMethod<void>('updateLiveActivity', {'action': action});
    } catch (_) {}
  }

  Future<void> endActivity() async {
    try {
      await _channel.invokeMethod<void>('endLiveActivity', {});
    } catch (_) {}
  }

  Future<bool> areActivitiesEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('areActivitiesEnabled', {});
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  void setLockScreenActionHandler(void Function(String action) handler) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onLockScreenAction') {
        final action = call.arguments['action'] as String?;
        if (action != null) handler(action);
      }
    });
  }
}
