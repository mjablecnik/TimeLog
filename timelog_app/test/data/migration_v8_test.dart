import 'dart:math';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/data/database.dart';

// Feature: activity-subtypes
//
// Each test builds an in-memory database in the shape of an older schema
// version, sets `PRAGMA user_version`, and opens it through AppDatabase so that
// Drift runs `onUpgrade`.

const _timeEntriesV4 = '''
CREATE TABLE time_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  description TEXT NOT NULL,
  activity_type TEXT NOT NULL DEFAULT 'Práce',
  project TEXT,
  created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s','now') AS INTEGER))
)''';

const _timeEntriesV5 = '''
CREATE TABLE time_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  description TEXT NOT NULL,
  activity_type TEXT NOT NULL DEFAULT 'Práce',
  project TEXT,
  entertainment_type TEXT,
  created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s','now') AS INTEGER))
)''';

const _taskProjectsV7 = '''
CREATE TABLE task_projects (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s','now') AS INTEGER))
)''';

/// Opens a database whose schema is at [version], with [setup] statements run first.
AppDatabase _openAt(int version, List<String> statements) {
  return AppDatabase.forTesting(
    NativeDatabase.memory(
      setup: (raw) {
        for (final statement in statements) {
          raw.execute(statement);
        }
        raw.execute('PRAGMA user_version = $version');
      },
    ),
  );
}

String _insertEntry(String type, {String? entertainment, String? project, int i = 0}) {
  final columns = entertainment == null && project == null
      ? 'start_time, end_time, description, activity_type'
      : 'start_time, end_time, description, activity_type, project, entertainment_type';
  final values = entertainment == null && project == null
      ? "'2026-01-01T08:0$i:00', '2026-01-01T09:00:00', 'entry $i', '$type'"
      : "'2026-01-01T08:0$i:00', '2026-01-01T09:00:00', 'entry $i', '$type', "
          "${project == null ? 'NULL' : "'$project'"}, "
          "${entertainment == null ? 'NULL' : "'$entertainment'"}";
  return 'INSERT INTO time_entries ($columns) VALUES ($values)';
}

void main() {
  test('v7 -> v8: maps legacy entries to subtypes and leaves other columns alone', () async {
    final db = _openAt(7, [
      _timeEntriesV5,
      _taskProjectsV7,
      _insertEntry('Práce', project: 'App', i: 1),
      _insertEntry('Zábava', entertainment: 'Aktivní zábava', i: 2),
      _insertEntry('Zábava', entertainment: 'Pasivní zábava', i: 3),
      _insertEntry('Zábava', i: 4),
      _insertEntry('Cvičení', i: 5),
      _insertEntry('Domácí práce', project: 'Garage', i: 6),
      "INSERT INTO task_projects (name) VALUES ('Old project')",
    ]);
    addTearDown(db.close);

    final rows = await (db.select(db.timeEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    expect(rows, hasLength(6));
    expect(rows.map((r) => r.subtype).toList(), [
      'unpaid',
      'active',
      'passive',
      null,
      null,
      null,
    ]);
    expect(rows[0].project, 'App');
    expect(rows[0].description, 'entry 1');
    expect(rows[5].project, 'Garage');
    expect(rows.every((r) => r.customName == null), isTrue);
    // The legacy column is kept as it was.
    expect(rows[1].entertainmentType, 'Aktivní zábava');

    final projects = await db.getAllTaskProjects();
    expect(projects, hasLength(1));
    expect(projects.single.name, 'Old project');
    expect(projects.single.scope, 'workUnpaid');
  });

  test('v6 -> v8: task tables are created with scope and it is not added twice', () async {
    final db = _openAt(6, [
      _timeEntriesV5,
      _insertEntry('Práce', i: 1),
    ]);
    addTearDown(db.close);

    final rows = await db.select(db.timeEntries).get();
    expect(rows.single.subtype, 'unpaid');

    final projectId = await db.insertTaskProject(
      TaskProjectsCompanion.insert(name: 'New'),
    );
    final project = (await db.getAllTaskProjects()).single;
    expect(project.id, projectId);
    expect(project.scope, 'workUnpaid');
  });

  test('v5 -> v8: the version 6 and 7 tables are created before the version 8 step', () async {
    final db = _openAt(5, [
      _timeEntriesV5,
      _insertEntry('Práce', i: 1),
      _insertEntry('Zábava', entertainment: 'Pasivní zábava', i: 2),
    ]);
    addTearDown(db.close);

    final rows = await (db.select(db.timeEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    expect(rows[0].subtype, 'unpaid');
    expect(rows[1].subtype, 'passive');

    // The tables of versions 6 and 7 exist, the latter with `scope`.
    expect(await db.getAllReminders(), isEmpty);
    final projectId = await db.insertTaskProject(
      TaskProjectsCompanion.insert(name: 'Fresh'),
    );
    expect((await db.getAllTaskProjects()).single.id, projectId);
    expect((await db.getAllTaskProjects()).single.scope, 'workUnpaid');
  });

  test('v4 -> v8: the version 5 renames run before the version 8 step', () async {
    final db = _openAt(4, [
      _timeEntriesV4,
      "INSERT INTO time_entries (start_time, end_time, description, activity_type) VALUES ('2026-01-01T08:00:00', '2026-01-01T09:00:00', 'a', 'Volný čas')",
      "INSERT INTO time_entries (start_time, end_time, description, activity_type) VALUES ('2026-01-01T09:00:00', '2026-01-01T10:00:00', 'b', 'Volná práce')",
      "INSERT INTO time_entries (start_time, end_time, description, activity_type) VALUES ('2026-01-01T10:00:00', '2026-01-01T11:00:00', 'c', 'Práce')",
    ]);
    addTearDown(db.close);

    final rows = await (db.select(db.timeEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    // Version 5 renamed these types.
    expect(rows[0].activityType, 'Seberozvoj');
    expect(rows[1].activityType, 'Domácí práce');
    expect(rows[2].subtype, 'unpaid');
    expect(rows.every((r) => r.entertainmentType == null), isTrue);
  });

  test('a fresh database has the new columns and no data update', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.timeEntries).insert(
          TimeEntriesCompanion.insert(
            startTime: '2026-01-01T08:00:00',
            endTime: '2026-01-01T09:00:00',
            description: 'x',
          ),
        );
    final row = (await db.select(db.timeEntries).get()).single;
    expect(row.subtype, isNull);
    expect(row.customName, isNull);
    expect(db.schemaVersion, 8);

    final columns = await db
        .customSelect("SELECT name FROM pragma_table_info('task_projects')")
        .get();
    expect(columns.map((r) => r.read<String>('name')), contains('scope'));
  });

  test('Property 3: migration mapping for random legacy entries', () async {
    final random = Random(20261121);
    const types = [
      'Práce',
      'Domácí práce',
      'Přesun',
      'Zábava',
      'Cvičení',
      'Seberozvoj',
      'Odpočinek',
      'Hygiena',
      'Jídlo',
    ];
    const entertainmentValues = [null, 'Aktivní zábava', 'Pasivní zábava', 'jiné'];

    for (var iteration = 0; iteration < 100; iteration++) {
      final count = random.nextInt(8);
      final inputs = <({String type, String? entertainment, String? project})>[];
      final statements = <String>[_timeEntriesV5, _taskProjectsV7];
      for (var i = 0; i < count; i++) {
        final type = types[random.nextInt(types.length)];
        final entertainment = type == 'Zábava'
            ? entertainmentValues[random.nextInt(entertainmentValues.length)]
            : null;
        final project = random.nextBool() ? 'P${random.nextInt(5)}' : null;
        inputs.add((type: type, entertainment: entertainment, project: project));
        statements.add(
          _insertEntry(type, entertainment: entertainment, project: project, i: i % 10),
        );
      }
      final projectCount = random.nextInt(4);
      for (var i = 0; i < projectCount; i++) {
        statements.add("INSERT INTO task_projects (name) VALUES ('proj $i')");
      }

      final db = _openAt(7, statements);
      try {
        final rows = await (db.select(db.timeEntries)
              ..orderBy([(t) => OrderingTerm.asc(t.id)]))
            .get();
        expect(rows, hasLength(count), reason: 'iteration $iteration');
        for (var i = 0; i < count; i++) {
          final input = inputs[i];
          final expected = switch ((input.type, input.entertainment)) {
            ('Práce', _) => 'unpaid',
            ('Zábava', 'Aktivní zábava') => 'active',
            ('Zábava', 'Pasivní zábava') => 'passive',
            _ => null,
          };
          expect(rows[i].subtype, expected, reason: 'iteration $iteration row $i');
          expect(rows[i].activityType, input.type);
          expect(rows[i].project, input.project);
          expect(rows[i].customName, isNull);
        }
        final projects = await db.getAllTaskProjects();
        expect(projects, hasLength(projectCount));
        expect(projects.every((p) => p.scope == 'workUnpaid'), isTrue);
      } finally {
        await db.close();
      }
    }
  });
}
