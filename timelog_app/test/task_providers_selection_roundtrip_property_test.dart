import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timelog_app/providers/task_providers.dart';

// Feature: task-management, Property 17: Project selection round-trip persistence
//
// glados (the property-based testing library named in the design doc) requires
// analyzer ^8.0.0+ transitively via `test`, which conflicts with this project's
// pinned freezed ^2.5.7 (analyzer ^6.5.0/^7.0.0) — see .agents/MEMORY.md. This
// hand-rolled randomized loop (100+ iterations, seeded for reproducibility)
// exercises the same property without adding that dependency.
void main() {
  test(
    'Property 17: persisting a project selection (specific id or null for '
    'Unassigned) to SharedPreferences and reading it back returns the same '
    'value',
    () async {
      final random = Random(20260820);

      for (var iteration = 0; iteration < 100; iteration++) {
        SharedPreferences.setMockInitialValues({});

        // null represents Unassigned; non-null ids exercise a wide range,
        // including 0 and large values, not just small positive ids.
        final bool selectUnassigned = random.nextBool();
        final int? selection =
            selectUnassigned ? null : random.nextInt(1 << 30);

        await persistSelectedTaskProject(selection);
        final readBack = await loadPersistedTaskProjectId();

        expect(
          readBack,
          selection,
          reason: 'iteration $iteration: persisting $selection and reading '
              'it back should return the same value, got $readBack',
        );
      }
    },
  );

  test(
    'Property 17: persisting null after a non-null selection clears the '
    'stored value rather than leaving the previous id behind',
    () async {
      final random = Random(20260820);

      for (var iteration = 0; iteration < 100; iteration++) {
        SharedPreferences.setMockInitialValues({});

        final int firstSelection = random.nextInt(1 << 30);
        await persistSelectedTaskProject(firstSelection);
        expect(await loadPersistedTaskProjectId(), firstSelection);

        await persistSelectedTaskProject(null);
        final readBack = await loadPersistedTaskProjectId();

        expect(
          readBack,
          isNull,
          reason: 'iteration $iteration: persisting null after '
              '$firstSelection should clear the stored value, got '
              '$readBack',
        );
      }
    },
  );
}
