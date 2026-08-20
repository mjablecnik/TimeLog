import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/services/task_service.dart';

// Feature: task-management, Property 3: Project creation persists to database
//
// glados (the property-based testing library named in the design doc) requires
// analyzer ^8.0.0+ transitively via `test`, which conflicts with this project's
// pinned freezed ^2.5.7 (analyzer ^6.5.0/^7.0.0) — see .agents/MEMORY.md. This
// hand-rolled randomized loop (100+ iterations, seeded for reproducibility)
// exercises the same property without adding that dependency.
void main() {
  test(
    'Property 3: for any valid project name (1-100 non-whitespace-only '
    'characters), creating a project results in the Task_Database '
    'containing a TaskProject with that exact name, appearing in the '
    'project list',
    () async {
      final random = Random(20260820);
      const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
          '0123456789 ěščřžýáíéúů-_.';

      String randomValidName() {
        final length = 1 + random.nextInt(100); // 1..100
        String name;
        do {
          name = List.generate(
            length,
            (_) => chars[random.nextInt(chars.length)],
          ).join();
        } while (name.trim().isEmpty);
        return name;
      }

      for (var iteration = 0; iteration < 100; iteration++) {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        final service = TaskService(db);

        try {
          final name = randomValidName();

          final id = await service.createProject(name);

          final allProjects = await service.getAllProjects();
          final created = allProjects.where((p) => p.id == id);

          expect(
            created.length,
            1,
            reason: 'iteration $iteration: created project (id $id) must '
                'appear exactly once in the project list',
          );
          expect(
            created.single.name,
            name,
            reason: 'iteration $iteration: persisted project name must '
                'exactly match the name that was submitted',
          );
        } finally {
          await db.close();
        }
      }
    },
  );
}
