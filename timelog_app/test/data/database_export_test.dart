import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/data/database_export.dart';
import 'package:timelog_app/services/export_service.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });
  tearDown(() => db.close());

  final exportedAt = DateTime(2026, 11, 20, 9, 30);

  Future<Map<String, Object?>> export([
    Map<String, Object?> preferences = const <String, Object?>{},
  ]) =>
      exportData(
        db,
        preferences: preferences,
        appVersion: '1.1.4',
        exportedAt: exportedAt,
      );

  test('writes the header and one entry per table', () async {
    final data = await export();

    expect(data['format'], exportFormat);
    expect(data['formatVersion'], exportFormatVersion);
    expect(data['app'], 'timelog');
    expect(data['appVersion'], '1.1.4');
    expect(data['schemaVersion'], db.schemaVersion);
    expect(data['exportedAt'], exportedAt.toIso8601String());
    final tables = data['tables']! as Map<String, Object?>;
    expect(
      tables.keys.toSet(),
      db.allTables.map((t) => t.actualTableName).toSet(),
    );
  });

  test('copies rows as stored and counts them', () async {
    await db.into(db.taskProjects).insert(
          TaskProjectsCompanion.insert(name: 'Dancee'),
        );

    final data = await export();
    final tables = data['tables']! as Map<String, Object?>;
    final projects =
        (tables['task_projects']! as List).cast<Map<String, Object?>>();

    expect(projects, hasLength(1));
    expect(projects.single['name'], 'Dancee');
    expect((data['rowCounts']! as Map)['task_projects'], 1);
    expect((data['rowCounts']! as Map)['time_entries'], 0);
  });

  test('includes the preferences sorted by key', () async {
    final data = await export(<String, Object?>{
      'app_language': 'cs',
      'known_projects': <String>['Dancee', 'ABAP'],
      'daily_reminder_enabled': true,
    });

    final prefs = data['preferences']! as Map<String, Object?>;
    expect(prefs.keys.toList(), <String>[
      'app_language',
      'daily_reminder_enabled',
      'known_projects',
    ]);
    expect(prefs['known_projects'], <String>['Dancee', 'ABAP']);
  });

  test('the service exports the stored preferences as JSON', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'app_language': 'en',
      'timer_total_seconds': 1500,
    });
    final service = ExportService(
      db,
      now: () => exportedAt,
      appVersion: () async => '1.1.4',
    );

    final result = await service.build();
    final decoded = jsonDecode(result.json) as Map<String, Object?>;

    expect(result.fileName, 'timelog-export-2026-11-20.json');
    expect(decoded['preferences'], <String, Object?>{
      'app_language': 'en',
      'timer_total_seconds': 1500,
    });
    expect(decoded['app'], 'timelog');
  });
}
