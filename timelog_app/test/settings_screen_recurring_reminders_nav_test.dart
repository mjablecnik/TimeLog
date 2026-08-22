import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/l10n/generated/app_localizations.dart';
import 'package:timelog_app/providers/database_provider.dart';
import 'package:timelog_app/ui/screens/reminder_settings_screen.dart';
import 'package:timelog_app/ui/screens/settings_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'tapping "Opakované připomínky" in Settings navigates to ReminderSettingsScreen',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
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

      expect(find.byType(ReminderSettingsScreen), findsNothing);

      await tester.tap(find.text('Opakované připomínky'));
      await tester.pumpAndSettle();

      expect(find.byType(ReminderSettingsScreen), findsOneWidget);
    },
  );
}
