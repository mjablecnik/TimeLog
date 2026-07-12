import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../providers/history_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/day_navigator.dart';
import '../widgets/day_summary.dart';
import '../widgets/empty_state.dart';
import '../widgets/history_entry_card.dart';
import '../widgets/manual_entry_sheet.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  void _addEntry(BuildContext context, AppThemeData theme, DateTime selectedDay) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManualEntrySheet(
        theme: theme,
        selectedDay: selectedDay,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final entriesAsync = ref.watch(dayEntriesProvider);
    final selectedDay = ref.watch(selectedDayProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.center,
              children: [
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
                Positioned(
                  right: 16,
                  child: IconButton(
                    icon: Icon(Icons.add, color: theme.text),
                    onPressed: () => _addEntry(context, theme, selectedDay),
                  ),
                ),
              ],
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
