import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../services/database_service.dart';

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
