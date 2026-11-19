import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timelog_app/core/platform_channel.dart';
import 'package:timelog_app/services/alarm_service.dart';
import 'package:timelog_app/services/live_activity_channel.dart';
import 'package:timelog_app/services/notification_service.dart';
import 'package:timelog_app/services/timer_service.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    for (final channel in const [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
      PlatformChannels.liveActivity,
      PlatformChannels.notifications,
    ]) {
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        MethodChannel(channel),
        (call) async => null,
      );
    }
  });

  TimerNotifier createNotifier() {
    return TimerNotifier(AlarmService(), LiveActivityChannel(), NotificationService());
  }

  test('stop() clears logTrigger set by stopAndLog()', () async {
    final notifier = createNotifier();
    await Future<void>.delayed(Duration.zero);

    notifier.start();
    notifier.stopAndLog();
    expect(notifier.state.logTrigger, LogTrigger.stop);

    notifier.stop();
    expect(notifier.state.status, TimerStatus.idle);
    expect(notifier.state.logTrigger, isNull);
  });

  test('stop() clears logTrigger set by finishNow()', () async {
    final notifier = createNotifier();
    await Future<void>.delayed(Duration.zero);

    notifier.start();
    notifier.finishNow();
    expect(notifier.state.logTrigger, LogTrigger.finish);

    notifier.stop();
    expect(notifier.state.status, TimerStatus.idle);
    expect(notifier.state.logTrigger, isNull);
  });

  group('prefill with subtype and custom name', () {
    Future<Map<String, Object?>> prefsOf(List<String> keys) async {
      final prefs = await SharedPreferences.getInstance();
      return {for (final k in keys) k: prefs.get(k)};
    }

    test('savePrefill persists subtype and custom name, clearPrefill removes them', () async {
      final notifier = createNotifier();
      await notifier.restored;

      notifier.savePrefill('draft', 'Cvičení', subtype: 'walk', customName: 'x');
      await Future<void>.delayed(Duration.zero);
      expect(notifier.state.prefillSubtype, 'walk');
      expect(notifier.state.prefillCustomName, 'x');
      expect(
        await prefsOf(['timer_prefillSubtype', 'timer_prefillCustomName']),
        {'timer_prefillSubtype': 'walk', 'timer_prefillCustomName': 'x'},
      );

      notifier.clearPrefill();
      await Future<void>.delayed(Duration.zero);
      expect(notifier.state.prefillSubtype, isNull);
      expect(notifier.state.prefillCustomName, isNull);
      expect(
        await prefsOf(['timer_prefillSubtype', 'timer_prefillCustomName']),
        {'timer_prefillSubtype': null, 'timer_prefillCustomName': null},
      );
    });

    test('restores a persisted subtype and custom name', () async {
      SharedPreferences.setMockInitialValues({
        'timer_status': 'paused',
        'timer_prefillActivityType': 'Ostatní',
        'timer_prefillCustomName': 'Guitar',
        'timer_prefillDescription': 'chords',
      });
      final notifier = createNotifier();
      await notifier.restored;
      expect(notifier.state.prefillActivityType, 'Ostatní');
      expect(notifier.state.prefillCustomName, 'Guitar');
    });

    test('reads a legacy entertainment value as the matching subtype and removes the key', () async {
      SharedPreferences.setMockInitialValues({
        'timer_status': 'paused',
        'timer_prefillActivityType': 'Zábava',
        'timer_prefillEntertainmentType': 'Pasivní zábava',
      });
      final notifier = createNotifier();
      await notifier.restored;
      expect(notifier.state.prefillSubtype, 'passive');
      expect(
        (await SharedPreferences.getInstance()).containsKey('timer_prefillEntertainmentType'),
        isFalse,
      );
    });

    test('ignores a persisted subtype that the type does not define', () async {
      SharedPreferences.setMockInitialValues({
        'timer_status': 'paused',
        'timer_prefillActivityType': 'Meeting',
        'timer_prefillSubtype': 'paid',
      });
      final notifier = createNotifier();
      await notifier.restored;
      expect(notifier.state.prefillSubtype, isNull);
    });
  });
}
