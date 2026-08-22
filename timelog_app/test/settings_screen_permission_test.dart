import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timelog_app/l10n/generated/app_localizations.dart';
import 'package:timelog_app/providers/reminder_provider.dart';
import 'package:timelog_app/services/reminder_service.dart';
import 'package:timelog_app/ui/screens/settings_screen.dart';

class _DeniedReminderService extends ReminderService {
  int scheduleCalls = 0;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    scheduleCalls++;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'denying notification permission keeps the reminder toggle off, shows a snackbar, and never schedules',
    (tester) async {
      final fakeService = _DeniedReminderService();
      final container = ProviderContainer(
        overrides: [reminderServiceProvider.overrideWithValue(fakeService)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('cs'),
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(container.read(reminderProvider).enabled, isFalse);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(
        find.text('Oznámení jsou zakázána. Povolte je v nastavení telefonu.'),
        findsOneWidget,
      );
      expect(container.read(reminderProvider).enabled, isFalse);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      expect(fakeService.scheduleCalls, 0);
    },
  );
}
