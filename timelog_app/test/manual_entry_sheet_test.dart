import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timelog_app/core/theme.dart';
import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/l10n/generated/app_localizations.dart';
import 'package:timelog_app/providers/database_provider.dart';
import 'package:timelog_app/ui/widgets/manual_entry_sheet.dart';

Future<void> _setTimeViaPicker(
  WidgetTester tester, {
  required String currentTimeText,
  required int hour,
  required int minute,
}) async {
  await tester.tap(find.text(currentTimeText));
  await tester.pumpAndSettle();

  // Switch from the dial to manual hour/minute entry.
  await tester.tap(find.byIcon(Icons.keyboard_outlined));
  await tester.pumpAndSettle();

  final timeFields = find.descendant(
    of: find.byType(Dialog),
    matching: find.byType(TextField),
  );
  await tester.enterText(timeFields.at(0), hour.toString());
  await tester.enterText(timeFields.at(1), minute.toString());

  await tester.tap(find.widgetWithText(TextButton, 'OK'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'ManualEntrySheet starts blank, blocks empty submission, validates time order, and inserts on success',
    (tester) async {
      // The sheet got taller (type caption, subtype block); a tall window keeps
      // the whole ListView built so the assertions below can see every widget.
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      // Resolve the database service ahead of time so the sheet's
      // `ref.read(databaseServiceProvider).valueOrNull` isn't still loading
      // the first time Submit is tapped.
      await container.read(databaseServiceProvider.future);

      final selectedDay = DateTime(2026, 1, 15);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            ),
            home: Scaffold(
              body: ManualEntrySheet(
                theme: AppThemeData.midnight,
                selectedDay: selectedDay,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // A past day defaults to a blank 12:00-12:30 window.
      expect(find.text('12:00'), findsOneWidget);
      expect(find.text('12:30'), findsOneWidget);

      // Description starts blank, so Submit is disabled.
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );

      // Make the end time precede the start time.
      await _setTimeViaPicker(
        tester,
        currentTimeText: '12:30',
        hour: 11,
        minute: 0,
      );
      expect(find.text('End time must be after start time.'), findsOneWidget);

      // Fix the end time so it is after start again.
      await _setTimeViaPicker(
        tester,
        currentTimeText: '11:00',
        hour: 14,
        minute: 0,
      );
      expect(find.text('End time must be after start time.'), findsNothing);

      // Fill in the description; Submit becomes enabled.
      await tester.enterText(
        find.byType(TextField).last,
        'Test description',
      );
      await tester.pump();
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );

      // Submit sits below the fold once the error text and description are
      // filled in, so scroll it into the ListView's viewport before tapping.
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Sheet closed after a successful save.
      expect(find.byType(ManualEntrySheet), findsNothing);

      final entries = await db.select(db.timeEntries).get();
      expect(entries, hasLength(1));
      final saved = entries.single;
      expect(saved.description, 'Test description');
      expect(saved.activityType, 'Práce');
      expect(saved.project, isNull);
      // A new entry defaults to paid work.
      expect(saved.subtype, 'paid');
      expect(saved.customName, isNull);
      expect(DateTime.parse(saved.startTime).toLocal(), DateTime(2026, 1, 15, 12, 0));
      expect(DateTime.parse(saved.endTime).toLocal(), DateTime(2026, 1, 15, 14, 0));
    },
  );
}
