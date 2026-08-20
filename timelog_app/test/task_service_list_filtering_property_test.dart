import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/services/task_service.dart';

// Feature: task-management, Property 7: Task list filtering and ordering
//
// glados (the property-based testing library named in the design doc) requires
// analyzer ^8.0.0+ transitively via `test`, which conflicts with this project's
// pinned freezed ^2.5.7 (analyzer ^6.5.0/^7.0.0) — see .agents/MEMORY.md. This
// hand-rolled randomized loop (100+ iterations, seeded for reproducibility)
// exercises the same property without adding that dependency.
void main() {
  test(
    'Property 7: for any set of tasks distributed across multiple projects, '
    'selecting a specific project displays only the tasks belonging to that '
    'project (or tasks with null projectId for Unassigned), ordered by '
    'sortPosition ascending',
    () async {
      final random = Random(20260820);

      for (var iteration = 0; iteration < 100; iteration++) {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        final service = TaskService(db);

        try {
          final projectCount = 1 + random.nextInt(4); // 1..4 real projects
          final projectIds = <int>[];
          for (var i = 0; i < projectCount; i++) {
            projectIds.add(
              await service.createProject('Project $iteration-$i'),
            );
          }
          // Groups to distribute tasks across: the real projects plus
          // Unassigned (null).
          final groups = <int?>[null, ...projectIds];

          final expectedIdsByGroup = <int?, List<int>>{
            for (final g in groups) g: <int>[],
          };

          final taskCount = random.nextInt(21); // 0..20 tasks total
          for (var i = 0; i < taskCount; i++) {
            final group = groups[random.nextInt(groups.length)];
            final taskId = await service.createTask(
              title: 'Task $iteration-$i',
              projectId: group,
            );
            expectedIdsByGroup[group]!.add(taskId);
          }

          for (final group in groups) {
            final result = await service.getTasksForProject(group);

            // Only tasks belonging to this exact group are returned.
            expect(
              result.map((t) => t.id).toSet(),
              expectedIdsByGroup[group]!.toSet(),
              reason: 'iteration $iteration, group $group: returned task '
                  'ids must exactly match the tasks created in that group',
            );
            expect(
              result.every((t) => t.projectId == group),
              isTrue,
              reason: 'iteration $iteration, group $group: every returned '
                  'task must have the matching projectId',
            );

            // Ordered by sortPosition ascending.
            for (var i = 1; i < result.length; i++) {
              expect(
                result[i].sortPosition >= result[i - 1].sortPosition,
                isTrue,
                reason: 'iteration $iteration, group $group: tasks must be '
                    'ordered by sortPosition ascending',
              );
            }
          }
        } finally {
          await db.close();
        }
      }
    },
  );
}
