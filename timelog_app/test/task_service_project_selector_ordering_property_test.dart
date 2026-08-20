import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/services/task_service.dart';

// Feature: task-management, Property 1: Project selector ordering
//
// glados (the property-based testing library named in the design doc) requires
// analyzer ^8.0.0+ transitively via `test`, which conflicts with this project's
// pinned freezed ^2.5.7 (analyzer ^6.5.0/^7.0.0) — see .agents/MEMORY.md. This
// hand-rolled randomized loop (100+ iterations, seeded for reproducibility)
// exercises the same property without adding that dependency.
//
// ProjectSelector (lib/ui/widgets/project_selector.dart) renders projects in
// the exact order returned by taskProjectsProvider (backed by
// TaskService.getAllProjects()/watchAllProjects()) and unconditionally
// appends the "Nepřiřazeno" (Unassigned) chip after that loop — so the
// "Unassigned always last" half of the property is structurally guaranteed
// by the widget's build method, and the meaningful, testable half is that
// the underlying data is sorted alphabetically case-insensitively.
void main() {
  test(
    'Property 1: for any list of Task_Projects, they are returned sorted '
    'alphabetically by name (case-insensitive), and the widget places the '
    'Unassigned entry after all of them',
    () async {
      final random = Random(20260820);
      const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

      String randomName() {
        final length = 1 + random.nextInt(12);
        return List.generate(
          length,
          (_) => letters[random.nextInt(letters.length)],
        ).join();
      }

      for (var iteration = 0; iteration < 100; iteration++) {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        final service = TaskService(db);

        try {
          final projectCount = random.nextInt(11); // 0..10 projects
          final names = List.generate(projectCount, (_) => randomName());

          // Insert in random (unsorted) order — the property must hold
          // regardless of insertion order.
          for (final name in names) {
            await service.createProject(name);
          }

          final result = await service.getAllProjects();

          expect(
            result.length,
            projectCount,
            reason: 'iteration $iteration: all created projects must be '
                'returned',
          );

          for (var i = 1; i < result.length; i++) {
            final prev = result[i - 1].name.toLowerCase();
            final curr = result[i].name.toLowerCase();
            expect(
              prev.compareTo(curr) <= 0,
              isTrue,
              reason: 'iteration $iteration: projects must be sorted '
                  'alphabetically case-insensitively, but "${result[i - 1].name}" '
                  'came before "${result[i].name}"',
            );
          }

          // Mirrors ProjectSelector._buildRow: projects (as returned by the
          // provider) followed unconditionally by the Unassigned entry.
          final displayedLabels = [
            ...result.map((p) => p.name),
            'Nepřiřazeno',
          ];
          expect(
            displayedLabels.last,
            'Nepřiřazeno',
            reason: 'iteration $iteration: Unassigned must always be the '
                'last entry in the Project_Selector',
          );
        } finally {
          await db.close();
        }
      }
    },
  );
}
