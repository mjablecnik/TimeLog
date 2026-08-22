import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timelog_app/core/platform_channel.dart';
import 'package:timelog_app/l10n/generated/app_localizations.dart';
import 'package:timelog_app/providers/timer_provider.dart';
import 'package:timelog_app/services/timer_service.dart';
import 'package:timelog_app/ui/screens/timer_screen.dart';

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

  testWidgets(
    'canceling the prefill sheet discards text, resumes the timer, and leaves no stale prefill state',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('cs'),
            home: TimerScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      container.read(timerProvider.notifier).start();
      await tester.pump();
      expect(container.read(timerProvider).status, TimerStatus.running);

      // Open the prefill sheet; this pauses the running timer.
      await tester.tap(find.byTooltip('Předvyplnit popis'));
      await tester.pumpAndSettle();
      expect(container.read(timerProvider).status, TimerStatus.paused);

      // Type a draft description that should never be persisted.
      await tester.enterText(find.byType(TextField).first, 'Some throwaway text');
      await tester.pump();

      // Cancel instead of saving.
      final cancelButton = find.text('Zrušit', skipOffstage: false);
      await tester.ensureVisible(cancelButton);
      await tester.pumpAndSettle();
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // Sheet is gone.
      expect(find.text('Zrušit'), findsNothing);

      // Timer resumed rather than staying paused.
      expect(container.read(timerProvider).status, TimerStatus.running);

      // No prefill state was saved from the discarded text.
      final state = container.read(timerProvider);
      expect(state.prefillDescription, isNull);
      expect(state.prefillActivityType, isNull);
      expect(state.prefillProject, isNull);

      // Stop the resumed timer so its periodic ticker doesn't outlive the test.
      container.read(timerProvider.notifier).stop();
    },
  );
}
