import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/services/task_service.dart';

// Feature: task-management, Property 16: Deleting a task project does not
// affect time entries
//
// glados (the property-based testing library named in the design doc) requires
// analyzer ^8.0.0+ transitively via `test`, which conflicts with this project's
// pinned freezed ^2.5.7 (analyzer ^6.5.0/^7.0.0) — see .agents/MEMORY.md. This
// hand-rolled randomized loop (100+ iterations, seeded for reproducibility)
// exercises the same property without adding that dependency.
void main() {
  test(
    'Property 16: deleting a Task_Project whose name matches existing '
    'TimeEntry.project values leaves those TimeEntry records unchanged',
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
          final projectName = 'Shared Project $iteration';
          final projectId = await service.createProject(projectName);

          final entryCount = random.nextInt(6); // 0..5
          final beforeEntries = <TimeEntry>[];
          for (var i = 0; i < entryCount; i++) {
            final start = DateTime(2026, 1, 1, 8 + i, 0);
            final end = start.add(const Duration(hours: 1));
            final id = await db.into(db.timeEntries).insert(
                  TimeEntriesCompanion.insert(
                    startTime: start.toIso8601String(),
                    endTime: end.toIso8601String(),
                    description: 'Entry $i',
                    project: Value(projectName),
                  ),
                );
            final entry = await (db.select(db.timeEntries)
                  ..where((t) => t.id.equals(id)))
                .getSingle();
            beforeEntries.add(entry);
          }

          await service.deleteProject(projectId);

          final remainingProjects = await service.getAllProjects();
          expect(
            remainingProjects.any((p) => p.id == projectId),
            isFalse,
            reason: 'iteration $iteration: deleted project must be gone',
          );

          for (final before in beforeEntries) {
            final after = await (db.select(db.timeEntries)
                  ..where((t) => t.id.equals(before.id)))
                .getSingle();
            expect(
              after,
              before,
              reason: 'iteration $iteration: TimeEntry ${before.id} must be '
                  'byte-for-byte unchanged after the Task_Project it '
                  'shares a name with is deleted',
            );
          }

          final remainingEntries = await db.select(db.timeEntries).get();
          expect(
            remainingEntries.length,
            entryCount,
            reason: 'iteration $iteration: no TimeEntry rows should be '
                'removed by the cascade delete on TaskProjects',
          );
        } finally {
          await db.close();
        }
      }
    },
  );
}
