import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/services/task_service.dart';

// Feature: task-management, Property 5: New task sort position at end of group
//
// glados (the property-based testing library named in the design doc) requires
// analyzer ^8.0.0+ transitively via `test`, which conflicts with this project's
// pinned freezed ^2.5.7 (analyzer ^6.5.0/^7.0.0) — see .agents/MEMORY.md. This
// hand-rolled randomized loop (100+ iterations, seeded for reproducibility)
// exercises the same property without adding that dependency.
void main() {
  test(
    'Property 5: for any group (project or Unassigned) containing N tasks, '
    'creating a new task assigns it a sort position greater than all '
    'existing tasks in that group',
    () async {
      final random = Random(20260820);

      for (var iteration = 0; iteration < 100; iteration++) {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        final service = TaskService(db);

        try {
          final useProject = random.nextBool();
          final int? groupProjectId = useProject
              ? await service.createProject('Group $iteration')
              : null;
          final otherProjectId =
              await service.createProject('Other $iteration');

          final existingCount = random.nextInt(11); // 0..10
          for (var i = 0; i < existingCount; i++) {
            await service.createTask(
              title: 'Existing task $i',
              projectId: groupProjectId,
            );
          }

          // Noise in an unrelated group must not influence the target
          // group's sort positions.
          final noiseCount = random.nextInt(6); // 0..5
          for (var i = 0; i < noiseCount; i++) {
            await service.createTask(
              title: 'Noise task $i',
              projectId: otherProjectId,
            );
          }

          final beforeTasks = await service.getTasksForProject(
            groupProjectId,
            includeArchived: true,
          );
          final maxBefore = beforeTasks.isEmpty
              ? -1
              : beforeTasks
                  .map((t) => t.sortPosition)
                  .reduce((a, b) => a > b ? a : b);

          final newTaskId = await service.createTask(
            title: 'New task',
            projectId: groupProjectId,
          );

          final afterTasks = await service.getTasksForProject(
            groupProjectId,
            includeArchived: true,
          );
          final newTask = afterTasks.firstWhere((t) => t.id == newTaskId);

          expect(
            newTask.sortPosition > maxBefore,
            isTrue,
            reason: 'iteration $iteration: new task sortPosition '
                '(${newTask.sortPosition}) must exceed the prior max '
                '($maxBefore) within its own group',
          );
          expect(
            afterTasks.every(
              (t) => t.id == newTaskId || t.sortPosition <= maxBefore,
            ),
            isTrue,
            reason: 'iteration $iteration: existing tasks in the group must '
                'keep their sort positions unchanged',
          );
        } finally {
          await db.close();
        }
      }
    },
  );
}
