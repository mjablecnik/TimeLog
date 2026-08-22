import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart' show statsTabIndex;
import '../../core/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/history_provider.dart';
import '../../providers/main_tab_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/day_navigator.dart';
import '../widgets/day_summary.dart';
import '../widgets/empty_state.dart';
import '../widgets/history_entry_card.dart';
import '../widgets/manual_entry_sheet.dart';

const _swipeVelocityThreshold = 300.0;

bool _isToday(DateTime day) {
  final now = DateTime.now();
  final today = logicalDay(now);
  return day.year == today.year && day.month == today.month && day.day == today.day;
}

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
    final l10n = AppLocalizations.of(context)!;
    final entriesAsync = ref.watch(dayEntriesProvider);
    final selectedDay = ref.watch(selectedDayProvider);

    return Scaffold(
      backgroundColor: theme.background,
      bottomNavigationBar: AppBottomNav(
        selectedIndex: statsTabIndex,
        onTap: (index) {
          Navigator.of(context).pop();
          if (index != statsTabIndex) {
            ref.read(mainTabIndexProvider.notifier).state = index;
          }
        },
        theme: theme,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  l10n.historyTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.text,
                    fontFamily: 'Sora',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Positioned(
                  left: 16,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.text),
                    tooltip: l10n.commonBack,
                    onPressed: () => Navigator.of(context).pop(),
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
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity.abs() < _swipeVelocityThreshold) return;
                  if (velocity < 0) {
                    // Swipe left → next day
                    if (_isToday(selectedDay)) return;
                    ref.read(selectedDayProvider.notifier).state =
                        selectedDay.add(const Duration(days: 1));
                  } else {
                    // Swipe right → previous day
                    ref.read(selectedDayProvider.notifier).state =
                        selectedDay.subtract(const Duration(days: 1));
                  }
                },
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
                      l10n.historyLoadError,
                      style: TextStyle(color: theme.dim, fontFamily: 'Sora'),
                    ),
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
