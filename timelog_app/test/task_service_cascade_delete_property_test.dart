import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/services/task_service.dart';

// Feature: task-management, Property 4: Cascade delete removes project and all associated tasks
//
// glados (the property-based testing library named in the design doc) requires
// analyzer ^8.0.0+ transitively via `test`, which conflicts with this project's
// pinned freezed ^2.5.7 (analyzer ^6.5.0/^7.0.0) — see .agents/MEMORY.md. This
// hand-rolled randomized loop (100+ iterations, seeded for reproducibility)
// exercises the same property without adding that dependency.
void main() {
  test(
    'Property 4: deleting a Task_Project removes it and all of its Tasks, '
    'leaving unrelated tasks untouched',
    () async {
      final random = Random(20260820);

      for (var iteration = 0; iteration < 100; iteration++) {
        final db = AppDatabase.forTesting(
          NativeDatabase.memory(
            setup: (rawDb) => rawDb.execute('PRAGMA foreign_keys = ON;'),
          ),
        );
        final service = TaskService(db);

        try {
          final targetProjectId =
              await service.createProject('Target $iteration');
          final otherProjectId =
              await service.createProject('Other $iteration');

          final targetTaskCount = random.nextInt(11); // 0..10
          final otherTaskCount = random.nextInt(6); // 0..5
          final unassignedTaskCount = random.nextInt(6); // 0..5

          for (var i = 0; i < targetTaskCount; i++) {
            await service.createTask(
              title: 'Target task $i',
              projectId: targetProjectId,
            );
          }
          for (var i = 0; i < otherTaskCount; i++) {
            await service.createTask(
              title: 'Other task $i',
              projectId: otherProjectId,
            );
          }
          for (var i = 0; i < unassignedTaskCount; i++) {
            await service.createTask(title: 'Unassigned task $i');
          }

          await service.deleteProject(targetProjectId);

          final remainingProjects = await service.getAllProjects();
          expect(
            remainingProjects.any((p) => p.id == targetProjectId),
            isFalse,
            reason: 'iteration $iteration: deleted project must be gone',
          );

          final remainingTargetTasks = await service.getTasksForProject(
            targetProjectId,
            includeArchived: true,
          );
          expect(
            remainingTargetTasks,
            isEmpty,
            reason:
                'iteration $iteration: cascade delete must remove all tasks '
                'that belonged to the deleted project',
          );

          final remainingOtherTasks = await service.getTasksForProject(
            otherProjectId,
            includeArchived: true,
          );
          expect(
            remainingOtherTasks.length,
            otherTaskCount,
            reason: 'iteration $iteration: unrelated project tasks must '
                'survive the deletion',
          );

          final remainingUnassignedTasks = await service.getTasksForProject(
            null,
            includeArchived: true,
          );
          expect(
            remainingUnassignedTasks.length,
            unassignedTaskCount,
            reason: 'iteration $iteration: unassigned tasks must survive '
                'the deletion',
          );
        } finally {
          await db.close();
        }
      }
    },
  );
}
