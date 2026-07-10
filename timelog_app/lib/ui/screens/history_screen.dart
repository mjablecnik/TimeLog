import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/history_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/day_navigator.dart';
import '../widgets/day_summary.dart';
import '../widgets/empty_state.dart';
import '../widgets/history_entry_card.dart';
import '../widgets/theme_dots.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final entriesAsync = ref.watch(dayEntriesProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            const ThemeDots(),
            const SizedBox(height: 8),
            Text(
              'History',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.text,
                fontFamily: 'Sora',
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            DayNavigator(theme: theme),
            const SizedBox(height: 4),
            Expanded(
              child: entriesAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return EmptyState(theme: theme);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DaySummary(entries: entries, theme: theme),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: entries.length,
                          itemBuilder: (context, index) => HistoryEntryCard(
                            entry: entries[index],
                            theme: theme,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(color: theme.accent),
                ),
                error: (error, _) => Center(
                  child: Text(
                    'Failed to load entries.',
                    style: TextStyle(color: theme.dim, fontFamily: 'Sora'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
