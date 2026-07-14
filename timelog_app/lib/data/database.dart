import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'time_entry.dart';

part 'database.g.dart';

@DriftDatabase(tables: [TimeEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(timeEntries, timeEntries.activityType);
          }
          if (from < 3) {
            // No SQL change needed: the description min-length constraint
            // is enforced by drift at the Dart layer, not a SQL CHECK.
          }
          if (from < 4) {
            await m.addColumn(timeEntries, timeEntries.project);
          }
          if (from < 5) {
            await m.addColumn(timeEntries, timeEntries.entertainmentType);
            await customStatement(
              "UPDATE time_entries SET activity_type = 'Seberozvoj' WHERE activity_type = 'Volný čas'",
            );
            await customStatement(
              "UPDATE time_entries SET activity_type = 'Domácí práce' WHERE activity_type = 'Volná práce'",
            );
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'timelog.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
