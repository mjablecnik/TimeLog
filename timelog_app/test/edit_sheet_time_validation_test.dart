import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timelog_app/core/theme.dart';
import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/l10n/generated/app_localizations.dart';
import 'package:timelog_app/providers/database_provider.dart';
import 'package:timelog_app/ui/widgets/edit_sheet.dart';

Future<void> _setTimeViaPicker(
  WidgetTester tester, {
  required String currentTimeText,
  required int hour,
  required int minute,
}) async {
  final timeField = find.text(currentTimeText, skipOffstage: false);
  await tester.ensureVisible(timeField);
  await tester.pumpAndSettle();
  await tester.tap(timeField);
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
    'editing times validates end > start and persists the update, preserving the original date',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final originalStart = DateTime(2026, 1, 15, 9, 0);
      final originalEnd = DateTime(2026, 1, 15, 10, 0);

      final insertedId = await db.into(db.timeEntries).insert(
            TimeEntriesCompanion.insert(
              startTime: originalStart.toIso8601String(),
              endTime: originalEnd.toIso8601String(),
              description: 'Original description',
            ),
          );
      final entry = await (db.select(db.timeEntries)
            ..where((t) => t.id.equals(insertedId)))
          .getSingle();

      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      // Resolve the database service ahead of time so the sheet's
      // `ref.read(databaseServiceProvider).valueOrNull` isn't still loading
      // the first time Save is tapped.
      await container.read(databaseServiceProvider.future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(alwaysUse24HourFormat: true),
              child: child!,
            ),
            home: Scaffold(
              body: EditSheet(theme: AppThemeData.midnight, entry: entry),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Times render as HH:mm and are tappable.
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);

      // Move start time to 11:15 — now after the (unchanged) end time of 10:00.
      await _setTimeViaPicker(
        tester,
        currentTimeText: '09:00',
        hour: 11,
        minute: 15,
      );
      expect(find.text('11:15'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);

      // Saving with end before start must be rejected.
      final saveButton =
          find.widgetWithText(ElevatedButton, 'Save', skipOffstage: false);
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pump();
      expect(find.text('End time must be after start time.', skipOffstage: false),
          findsOneWidget);

      // Sheet stays open and nothing was written to the database.
      expect(find.text('Edit description', skipOffstage: false), findsOneWidget);
      final afterRejectedSave = await (db.select(db.timeEntries)
            ..where((t) => t.id.equals(insertedId)))
          .getSingle();
      expect(afterRejectedSave.startTime, entry.startTime);
      expect(afterRejectedSave.endTime, entry.endTime);

      // Fix end time to 12:00 — same day, after the new start time.
      await _setTimeViaPicker(
        tester,
        currentTimeText: '10:00',
        hour: 12,
        minute: 0,
      );
      expect(find.text('12:00'), findsOneWidget);

      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Sheet closed, no validation error left behind.
      expect(find.text('Edit description'), findsNothing);
      expect(find.text('End time must be after start time.'), findsNothing);

      final updated = await (db.select(db.timeEntries)
            ..where((t) => t.id.equals(insertedId)))
          .getSingle();
      final updatedStart = DateTime.parse(updated.startTime).toLocal();
      final updatedEnd = DateTime.parse(updated.endTime).toLocal();
      expect(updatedStart, DateTime(2026, 1, 15, 11, 15));
      expect(updatedEnd, DateTime(2026, 1, 15, 12, 0));
    },
  );
}
