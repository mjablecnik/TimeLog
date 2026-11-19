import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timelog_app/core/activity_types.dart';
import 'package:timelog_app/core/platform_channel.dart';
import 'package:timelog_app/core/theme.dart';
import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/l10n/generated/app_localizations.dart';
import 'package:timelog_app/providers/database_provider.dart';
import 'package:timelog_app/ui/widgets/activity_picker/activity_picker.dart';
import 'package:timelog_app/ui/widgets/description_sheet.dart';
import 'package:timelog_app/ui/widgets/edit_sheet.dart';
import 'package:timelog_app/ui/widgets/manual_entry_sheet.dart';
import 'package:timelog_app/ui/widgets/project_selector.dart';

// Feature: activity-subtypes

Future<ProviderContainer> _pump(
  WidgetTester tester,
  Widget child, {
  AppDatabase? database,
  String locale = 'en',
  bool scrollable = true,
}) async {
  // A tall window, so that the whole (long) sheet is built and visible.
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final db = database ?? AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final container = ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
  );
  addTearDown(container.dispose);
  await container.read(databaseServiceProvider.future);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(locale),
        home: Scaffold(body: scrollable ? SingleChildScrollView(child: child) : child),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Widget _picker({
  ActivitySelection? initial,
  required ValueChanged<ActivitySelection> onChanged,
  Key? key,
}) {
  return ActivityPicker(
    key: key,
    theme: AppThemeData.midnight,
    initial: initial,
    onChanged: onChanged,
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('ActivityPicker', () {
    testWidgets('shows the caption, twelve chips and the paid / unpaid block for Práce',
        (tester) async {
      ActivitySelection? latest;
      await _pump(tester, _picker(onChanged: (s) => latest = s));

      expect(find.text('TYPE'), findsOneWidget);
      for (final type in activityRegistry) {
        expect(find.byKey(ValueKey('type-chip-${type.key}')), findsOneWidget);
      }
      expect(find.text('↳ Refine: Work'), findsOneWidget);
      expect(find.text('Choose one'), findsOneWidget);
      expect(find.byKey(const ValueKey('subtype-chip-paid')), findsOneWidget);
      expect(find.byKey(const ValueKey('subtype-chip-unpaid')), findsOneWidget);
      // The first subtype is preselected.
      expect(latest, const ActivitySelection(typeKey: 'Práce', subtypeKey: 'paid'));
    });

    testWidgets('uses the Czech texts', (tester) async {
      await _pump(tester, _picker(onChanged: (_) {}), locale: 'cs');
      expect(find.text('TYP'), findsOneWidget);
      expect(find.text('↳ Upřesni: Práce'), findsOneWidget);
      expect(find.text('Vyber jednu možnost'), findsOneWidget);
      expect(find.text('Placená'), findsOneWidget);
    });

    testWidgets('the subtype block appears and disappears with the type', (tester) async {
      ActivitySelection? latest;
      await _pump(tester, _picker(onChanged: (s) => latest = s));

      await tester.tap(find.byKey(const ValueKey('type-chip-Cvičení')));
      await tester.pumpAndSettle();
      expect(find.text('↳ Refine: Exercise'), findsOneWidget);
      expect(find.byKey(const ValueKey('subtype-chip-walk')), findsOneWidget);
      expect(find.byKey(const ValueKey('subtype-chip-gym')), findsOneWidget);
      expect(latest!.subtypeKey, 'walk');

      await tester.tap(find.byKey(const ValueKey('type-chip-Meeting')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Refine'), findsNothing);
      expect(latest, const ActivitySelection(typeKey: 'Meeting'));
    });

    testWidgets('remembers the last subtype per type', (tester) async {
      ActivitySelection? latest;
      await _pump(tester, _picker(onChanged: (s) => latest = s));

      await tester.tap(find.byKey(const ValueKey('type-chip-Jídlo')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('subtype-chip-dinner')));
      await tester.pumpAndSettle();
      expect(latest!.subtypeKey, 'dinner');

      // Switch away and back: the remembered subtype is preselected.
      await tester.tap(find.byKey(const ValueKey('type-chip-Meeting')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('type-chip-Jídlo')));
      await tester.pumpAndSettle();
      expect(latest!.subtypeKey, 'dinner');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('last_subtype_Jídlo'), 'dinner');
      expect(prefs.getString('last_activity_type'), 'Jídlo');
    });

    testWidgets('restores the last used type and subtype in a new picker', (tester) async {
      SharedPreferences.setMockInitialValues({
        'last_activity_type': 'Odpočinek',
        'last_subtype_Odpočinek': 'passive',
      });
      ActivitySelection? latest;
      await _pump(tester, _picker(onChanged: (s) => latest = s));
      expect(latest, const ActivitySelection(typeKey: 'Odpočinek', subtypeKey: 'passive'));
    });

    testWidgets('an invalid remembered subtype falls back to the first one', (tester) async {
      SharedPreferences.setMockInitialValues({
        'last_activity_type': 'Hygiena',
        'last_subtype_Hygiena': 'bogus',
      });
      ActivitySelection? latest;
      await _pump(tester, _picker(onChanged: (s) => latest = s));
      expect(latest!.subtypeKey, 'general');
    });

    testWidgets('an initial selection wins; a missing subtype is preselected', (tester) async {
      ActivitySelection? latest;
      await _pump(
        tester,
        _picker(
          initial: const ActivitySelection(typeKey: 'Zábava'),
          onChanged: (s) => latest = s,
        ),
      );
      expect(latest, const ActivitySelection(typeKey: 'Zábava', subtypeKey: 'active'));

      await _pump(
        tester,
        _picker(
          key: UniqueKey(),
          initial: const ActivitySelection(typeKey: 'Zábava', subtypeKey: 'passive'),
          onChanged: (s) => latest = s,
        ),
      );
      expect(latest!.subtypeKey, 'passive');
    });

    testWidgets('Ostatní shows the custom name field, Práce the project field', (tester) async {
      ActivitySelection? latest;
      await _pump(tester, _picker(onChanged: (s) => latest = s));
      expect(find.text('Project name...'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'App');
      expect(latest!.project, 'App');

      await tester.tap(find.byKey(const ValueKey('type-chip-Ostatní')));
      await tester.pumpAndSettle();
      expect(find.text('What did you do?'), findsOneWidget);
      expect(find.textContaining('Refine'), findsNothing);
      await tester.enterText(find.byType(TextField), 'Guitar');
      expect(latest!.customName, 'Guitar');
      // The project text is kept in the selection but not stored for this type.
      expect(latest!.toRowValues(), (subtype: null, project: null, customName: 'Guitar'));

      await tester.tap(find.byKey(const ValueKey('type-chip-Meeting')));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('changing paid / unpaid keeps the typed project text', (tester) async {
      ActivitySelection? latest;
      await _pump(tester, _picker(onChanged: (s) => latest = s));
      await tester.enterText(find.byType(TextField), 'Kept');
      await tester.tap(find.byKey(const ValueKey('subtype-chip-unpaid')));
      await tester.pumpAndSettle();
      expect(latest, const ActivitySelection(typeKey: 'Práce', subtypeKey: 'unpaid', project: 'Kept'));
      expect(find.text('Kept'), findsOneWidget);
    });
  });

  test('Property 7: saved row values are normalised', () {
    final random = Random(20261124);
    const subtypePool = <String?>[null, 'paid', 'unpaid', 'active', 'walk', 'bogus'];
    for (var i = 0; i < 300; i++) {
      final typeKey = activityTypes[random.nextInt(activityTypes.length)];
      final selection = ActivitySelection(
        typeKey: typeKey,
        subtypeKey: subtypePool[random.nextInt(subtypePool.length)],
        project: random.nextBool() ? '  proj ' : '  ',
        customName: random.nextBool() ? ' name  ' : '',
      );
      final values = selection.toRowValues();
      if (values.project != null) {
        expect(hasProjectField(typeKey), isTrue);
        expect(values.project, 'proj');
      }
      if (values.customName != null) {
        expect(hasCustomNameField(typeKey), isTrue);
        expect(values.customName, 'name');
      }
      if (values.subtype != null) {
        expect(subtypeOf(typeKey, values.subtype), isNotNull);
      }
      if (hasProjectField(typeKey) && selection.project.trim().isNotEmpty) {
        expect(values.project, isNotNull);
      }
    }
  });

  group('ManualEntrySheet saves the picked type, subtype and names', () {
    Future<void> openAndSave(
      WidgetTester tester,
      AppDatabase db, {
      required Future<void> Function() fill,
    }) async {
      await _pump(
        tester,
        ManualEntrySheet(theme: AppThemeData.midnight, selectedDay: DateTime(2026, 1, 15)),
        database: db,
        scrollable: false,
      );
      await fill();
      await tester.enterText(find.byType(TextField).last, 'Some description');
      await tester.pump();
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
    }

    testWidgets('Práce paid with a project', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await openAndSave(tester, db, fill: () async {
        await tester.enterText(find.byType(TextField).first, 'Client');
        await tester.pump();
      });
      final row = (await db.select(db.timeEntries).get()).single;
      expect(row.activityType, 'Práce');
      expect(row.subtype, 'paid');
      expect(row.project, 'Client');
      expect(row.customName, isNull);
      expect(row.entertainmentType, isNull);
    });

    testWidgets('Cvičení walk without a project', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await openAndSave(tester, db, fill: () async {
        await tester.enterText(find.byType(TextField).first, 'discarded project');
        await tester.tap(find.byKey(const ValueKey('type-chip-Cvičení')));
        await tester.pumpAndSettle();
      });
      final row = (await db.select(db.timeEntries).get()).single;
      expect(row.activityType, 'Cvičení');
      expect(row.subtype, 'walk');
      expect(row.project, isNull);
    });

    testWidgets('Ostatní needs a name before it can be submitted', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await _pump(
        tester,
        ManualEntrySheet(theme: AppThemeData.midnight, selectedDay: DateTime(2026, 1, 15)),
        database: db,
        scrollable: false,
      );
      await tester.tap(find.byKey(const ValueKey('type-chip-Ostatní')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Some description');
      await tester.pump();
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNull);

      await tester.enterText(find.byType(TextField).first, 'Guitar');
      await tester.pump();
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNotNull);

      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      final row = (await db.select(db.timeEntries).get()).single;
      expect(row.activityType, 'Ostatní');
      expect(row.customName, 'Guitar');
      expect(row.project, isNull);
      expect(row.subtype, isNull);
    });
  });

  group('EditSheet', () {
    Future<TimeEntry> insert(AppDatabase db, {required String type, String? subtype, String? project, String? customName}) async {
      final id = await db.into(db.timeEntries).insert(
            TimeEntriesCompanion.insert(
              startTime: DateTime(2026, 1, 15, 9).toIso8601String(),
              endTime: DateTime(2026, 1, 15, 10).toIso8601String(),
              description: 'Original',
              activityType: Value(type),
              project: Value(project),
              subtype: Value(subtype),
              customName: Value(customName),
            ),
          );
      return (db.select(db.timeEntries)..where((t) => t.id.equals(id))).getSingle();
    }

    testWidgets('a legacy entry without a subtype gets the first one preselected and saves it',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final entry = await insert(db, type: 'Zábava');
      await _pump(tester, EditSheet(theme: AppThemeData.midnight, entry: entry),
          database: db, scrollable: false);

      // Preselected: the first subtype; switch to passive and save.
      await tester.tap(find.byKey(const ValueKey('subtype-chip-passive')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final row = (await db.select(db.timeEntries).get()).single;
      expect(row.activityType, 'Zábava');
      expect(row.subtype, 'passive');
      expect(row.description, 'Original');
    });

    testWidgets('changing the type clears the project and stores the new subtype and name',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final entry = await insert(db, type: 'Práce', subtype: 'unpaid', project: 'App');
      await _pump(tester, EditSheet(theme: AppThemeData.midnight, entry: entry),
          database: db, scrollable: false);
      // The stored subtype and project are shown.
      expect(find.text('App'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('type-chip-Ostatní')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Guitar');
      await tester.pump();
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final row = (await db.select(db.timeEntries).get()).single;
      expect(row.activityType, 'Ostatní');
      expect(row.customName, 'Guitar');
      expect(row.project, isNull);
      expect(row.subtype, isNull);
      // The name is remembered for the "other" category only.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('known_names_v3_other'), contains('Guitar'));
      expect(prefs.getString('known_names_v3_workUnpaid'), isNull);
    });

    testWidgets('editing a subtype entry saves its project name in the matching category',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final entry = await insert(db, type: 'Práce', subtype: 'unpaid', project: 'App');
      await _pump(tester, EditSheet(theme: AppThemeData.midnight, entry: entry),
          database: db, scrollable: false);

      await tester.tap(find.byKey(const ValueKey('subtype-chip-paid')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final row = (await db.select(db.timeEntries).get()).single;
      expect(row.subtype, 'paid');
      expect(row.project, 'App');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('known_names_v3_workPaid'), contains('App'));
      expect(prefs.getString('known_names_v3_workUnpaid'), isNull);
    });
  });

  group('DescriptionSheet', () {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();

    setUp(() {
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

    Widget sheet() => DescriptionSheet(
          theme: AppThemeData.midnight,
          sessionStart: DateTime(2026, 1, 15, 9),
          endedAt: DateTime(2026, 1, 15, 10),
          triggeredByStop: true,
        );

    testWidgets('Ostatní cannot be submitted without a name, but Skip still saves',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await _pump(tester, sheet(), database: db, scrollable: false);

      await tester.tap(find.byKey(const ValueKey('type-chip-Ostatní')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Some text');
      await tester.pump();
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNull);

      await tester.ensureVisible(find.text('Skip'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      final row = (await db.select(db.timeEntries).get()).single;
      expect(row.activityType, 'Ostatní');
      expect(row.customName, isNull);
      expect(row.description, '');
    });

    testWidgets('submitting stores the subtype, remembers the name and restores it next time',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await _pump(tester, sheet(), database: db, scrollable: false);

      await tester.tap(find.byKey(const ValueKey('type-chip-Seberozvoj')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('subtype-chip-ai')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Asked about ABAP');
      await tester.pump();
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final row = (await db.select(db.timeEntries).get()).single;
      expect(row.activityType, 'Seberozvoj');
      expect(row.subtype, 'ai');
      expect(row.project, isNull);

      // A new sheet restores the last submitted type, subtype and description.
      // (The sheet popped the only route of the test app, so start a fresh one.)
      await tester.pumpWidget(const SizedBox.shrink());
      await _pump(tester, sheet(), database: db, scrollable: false);
      expect(find.text('Asked about ABAP'), findsOneWidget);
      final chip = tester.widget<Semantics>(find.descendant(
        of: find.byKey(const ValueKey('subtype-chip-ai')),
        matching: find.byType(Semantics),
      ).first);
      expect(chip.properties.selected, isTrue);
    });
  });

  group('Tasks tab', () {
    testWidgets('create dialog offers the four categories and creates the project with one',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await _pump(tester, ProjectSelector(theme: AppThemeData.midnight), database: db);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('CATEGORY'), findsOneWidget);
      for (final label in ['Paid work', 'Unpaid work', 'Housework', 'Other']) {
        expect(find.text(label), findsOneWidget);
      }

      await tester.tap(find.byKey(const ValueKey('scope-chip-housework')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Garage');
      await tester.pump();
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      final projects = await db.getAllTaskProjects();
      expect(projects.single.name, 'Garage');
      expect(projects.single.scope, 'housework');
      expect((await SharedPreferences.getInstance()).getString('last_task_project_scope'),
          'housework');
    });

    testWidgets('the dialog preselects unpaid work, then the last used category', (tester) async {
      await _pump(tester, ProjectSelector(theme: AppThemeData.midnight));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Semantics>(find.descendant(
          of: find.byKey(const ValueKey('scope-chip-workUnpaid')),
          matching: find.byType(Semantics),
        ).first).properties.selected,
        isTrue,
      );
    });

    testWidgets('a project chip shows its category dot and a screen reader label', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.insertTaskProject(
        TaskProjectsCompanion.insert(name: 'Client').copyWith(scope: const Value('workPaid')),
      );
      final handle = tester.ensureSemantics();
      await _pump(tester, ProjectSelector(theme: AppThemeData.midnight), database: db);

      expect(find.bySemanticsLabel('Client, Paid work'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('long press opens a menu; edit changes only the category; cancel changes nothing',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final id = await db.insertTaskProject(TaskProjectsCompanion.insert(name: 'Mover'));
      await _pump(tester, ProjectSelector(theme: AppThemeData.midnight), database: db);

      await tester.longPress(find.text('Mover'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('project-menu-edit')), findsOneWidget);
      expect(find.byKey(const ValueKey('project-menu-delete')), findsOneWidget);

      // Edit mode: the name is plain text, the current category is selected.
      await tester.tap(find.byKey(const ValueKey('project-menu-edit')));
      await tester.pumpAndSettle();
      expect(find.text('Edit category'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      // Cancel leaves the project unchanged.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect((await db.getAllTaskProjects()).single.scope, 'workUnpaid');

      await tester.longPress(find.text('Mover'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('project-menu-edit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('scope-chip-workPaid')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final project = (await db.getAllTaskProjects()).single;
      expect(project.id, id);
      expect(project.name, 'Mover');
      expect(project.scope, 'workPaid');
    });

    testWidgets('the menu delete action shows the existing confirmation', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.insertTaskProject(TaskProjectsCompanion.insert(name: 'Doomed'));
      await _pump(tester, ProjectSelector(theme: AppThemeData.midnight), database: db);

      await tester.longPress(find.text('Doomed'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('project-menu-delete')));
      await tester.pumpAndSettle();
      expect(find.text('Delete project "Doomed"?'), findsOneWidget);
      expect(find.text('All tasks in this project will be permanently deleted.'), findsOneWidget);
      // Nothing is deleted before confirming.
      expect(await db.getAllTaskProjects(), hasLength(1));
    });

    testWidgets('the delete button on the chip still works', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.insertTaskProject(TaskProjectsCompanion.insert(name: 'Close me'));
      await _pump(tester, ProjectSelector(theme: AppThemeData.midnight), database: db);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Delete project "Close me"?'), findsOneWidget);
    });
  });
}
