import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/app.dart';
import 'package:timelog_app/data/database.dart';
import 'package:timelog_app/providers/database_provider.dart';
import 'package:timelog_app/ui/widgets/bottom_nav.dart';

void main() {
  testWidgets('TimeLogApp smoke test', (WidgetTester tester) async {
    // Use in-memory SQLite so the 3-second init timer resolves immediately
    final inMemoryDb = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(inMemoryDb),
        ],
        child: const TimeLogApp(),
      ),
    );

    // Allow async providers (DB init, stream) to settle
    await tester.pump(Duration.zero);
    await tester.pump(const Duration(milliseconds: 100));

    // Verify basic structure renders without error
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(AppBottomNav), findsOneWidget);

    await inMemoryDb.close();
  });
}
