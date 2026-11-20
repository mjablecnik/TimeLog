import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../services/database_service.dart';
import '../services/export_service.dart';
import '../services/project_service.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final databaseServiceProvider = FutureProvider<DatabaseService>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final service = DatabaseService(db);
  await service.initialize();
  return service;
});

final projectServiceProvider = Provider<ProjectService>((ref) {
  return ProjectService();
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(ref.watch(appDatabaseProvider));
});
