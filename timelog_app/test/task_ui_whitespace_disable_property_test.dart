import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/core/theme.dart';
import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/providers/database_provider.dart';
import 'package:timelog_app/ui/widgets/project_selector.dart';
import 'package:timelog_app/ui/widgets/task_edit_dialog.dart';

// Feature: task-management, Property 2: Whitespace-only input disables action buttons
//
// glados (the property-based testing library named in the design doc) can't be added
// without a disruptive freezed major-version bump — see .agents/MEMORY.md. This
// hand-rolled randomized loop (100+ iterations, seeded for reproducibility) exercises
// the same property without adding that dependency.
//
// For any string composed entirely of whitespace characters, both the project
// creation confirm button (ProjectSelector's "+" dialog) and the task save button
// (TaskEditDialog) must remain disabled.

const _whitespaceChars = [' ', '\t', '\n'];

String _randomWhitespace(Random random) {
  final length = random.nextInt(15); // 0..14 chars, including the empty string
  return List.generate(
    length,
    (_) => _whitespaceChars[random.nextInt(_whitespaceChars.length)],
  ).join();
}

String _describe(String text) =>
    text.replaceAll('\n', '\\n').replaceAll('\t', '\\t');

void main() {
  testWidgets(
    'Property 2a: TaskEditDialog disables the save button for whitespace-only titles',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TaskEditDialog(theme: AppThemeData.midnight)),
        ),
      );
      await tester.pumpAndSettle();

      final random = Random(20260820);
      for (var iteration = 0; iteration < 100; iteration++) {
        final text = _randomWhitespace(random);

        await tester.enterText(find.byType(TextField).first, text);
        await tester.pump();

        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNull,
          reason:
              'iteration $iteration: whitespace-only title '
              '"${_describe(text)}" must keep Save disabled',
        );
      }
    },
  );

  testWidgets(
    'Property 2b: ProjectSelector disables the create-project confirm button for '
    'whitespace-only names',
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
            home: Scaffold(body: ProjectSelector(theme: AppThemeData.midnight)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final random = Random(20260820);
      for (var iteration = 0; iteration < 100; iteration++) {
        final text = _randomWhitespace(random);

        await tester.enterText(find.byType(TextField), text);
        await tester.pump();

        expect(
          tester
              .widget<TextButton>(find.widgetWithText(TextButton, 'Vytvořit'))
              .onPressed,
          isNull,
          reason:
              'iteration $iteration: whitespace-only project name '
              '"${_describe(text)}" must keep the confirm button disabled',
        );
      }

      await tester.tap(find.text('Zrušit'));
      await tester.pumpAndSettle();
    },
  );
}
