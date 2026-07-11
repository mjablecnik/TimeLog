import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/activity_types.dart';
import '../../core/theme.dart';
import '../../data/database.dart' show TimeEntry;
import '../../data/stats_data.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/theme_provider.dart';
import '../painters/bar_painter.dart';
import '../painters/timeline_painter.dart';

String _formatDuration(Duration duration) {
  final totalMinutes = duration.inMinutes;
  if (totalMinutes < 60) return '${totalMinutes}m';
  final hours = totalMinutes ~/ 60;
  final mins = totalMinutes % 60;
  return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
}

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final statsAsync = ref.watch(statisticsProvider);
    final period = ref.watch(statisticsPeriodProvider);
    final date = ref.watch(statisticsDateProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Text(
              'Statistiky',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.text,
                fontFamily: 'Sora',
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _PeriodToggle(theme: theme),
            const SizedBox(height: 8),
            _DateNav(theme: theme),
            const SizedBox(height: 4),
            Expanded(
              child: statsAsync.when(
                data: (stats) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (period == StatsPeriod.daily)
                      _DailyTimeline(
                        entries: stats.entries,
                        day: date,
                        theme: theme,
                      ),
                    Expanded(child: _StatsBody(stats: stats, theme: theme)),
                  ],
                ),
                loading: () => Center(
                  child: CircularProgressIndicator(color: theme.accent),
                ),
                error: (error, _) => Center(
                  child: Text(
                    'Nepodařilo se načíst statistiky.',
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

class _PeriodToggle extends ConsumerWidget {
  final AppThemeData theme;

  const _PeriodToggle({required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(statisticsPeriodProvider);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: theme.track,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PeriodSegment(
              label: 'Den',
              isActive: period == StatsPeriod.daily,
              theme: theme,
              onTap: () => ref.read(statisticsPeriodProvider.notifier).state =
                  StatsPeriod.daily,
            ),
            _PeriodSegment(
              label: 'Týden',
              isActive: period == StatsPeriod.weekly,
              theme: theme,
              onTap: () => ref.read(statisticsPeriodProvider.notifier).state =
                  StatsPeriod.weekly,
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodSegment extends StatelessWidget {
  final String label;
  final bool isActive;
  final AppThemeData theme;
  final VoidCallback onTap;

  const _PeriodSegment({
    required this.label,
    required this.isActive,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? theme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? theme.ink : theme.dim,
            fontFamily: 'Sora',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DateNav extends ConsumerWidget {
  final AppThemeData theme;

  const _DateNav({required this.theme});

  DateTime _weekStart(DateTime date) {
    final start = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(start.year, start.month, start.day);
  }

  String _label(StatsPeriod period, DateTime date) {
    final now = DateTime.now();
    if (period == StatsPeriod.daily) {
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      if (date == today) return 'Dnes';
      if (date == yesterday) return 'Včera';
      return '${date.day}. ${date.month}. ${date.year}';
    }

    final weekStart = _weekStart(date);
    if (weekStart == _weekStart(now)) return 'Tento týden';
    final weekEnd = weekStart.add(const Duration(days: 6));
    return '${weekStart.day}. ${weekStart.month}. – ${weekEnd.day}. ${weekEnd.month}. ${weekEnd.year}';
  }

  bool _isCurrent(StatsPeriod period, DateTime date) {
    final now = DateTime.now();
    if (period == StatsPeriod.daily) {
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }
    return _weekStart(date) == _weekStart(now);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(statisticsPeriodProvider);
    final date = ref.watch(statisticsDateProvider);
    final step = period == StatsPeriod.daily ? 1 : 7;
    final isCurrent = _isCurrent(period, date);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: theme.dim),
          onPressed: () {
            ref.read(statisticsDateProvider.notifier).state =
                date.subtract(Duration(days: step));
          },
        ),
        Text(
          _label(period, date),
          style: TextStyle(
            color: theme.text,
            fontFamily: 'Sora',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: isCurrent ? theme.faint : theme.dim,
          ),
          onPressed: isCurrent
              ? null
              : () {
                  ref.read(statisticsDateProvider.notifier).state =
                      date.add(Duration(days: step));
                },
        ),
      ],
    );
  }
}

class _DailyTimeline extends StatelessWidget {
  final List<TimeEntry> entries;
  final DateTime day;
  final AppThemeData theme;

  const _DailyTimeline({
    required this.entries,
    required this.day,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.themeKey != AppTheme.paper;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
      ),
      child: SizedBox(
        height: 48,
        child: CustomPaint(
          painter: TimelinePainter(
            entries: entries,
            day: day,
            theme: theme,
            isDark: isDark,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  final StatsData stats;
  final AppThemeData theme;

  const _StatsBody({required this.stats, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (stats.byActivityType.isEmpty) {
      return Center(
        child: Text(
          'Žádné záznamy pro toto období',
          style: TextStyle(color: theme.dim, fontFamily: 'Sora', fontSize: 15),
        ),
      );
    }

    final isDark = theme.themeKey != AppTheme.paper;
    final typeEntries = stats.byActivityType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final projectEntries = stats.byProject.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Podle typu aktivity',
          style: TextStyle(
            color: theme.dim,
            fontFamily: 'Sora',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        for (final entry in typeEntries)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ActivityTypeBar(
              type: entry.key,
              duration: entry.value,
              progress: stats.totalTracked.inSeconds == 0
                  ? 0
                  : entry.value.inSeconds / stats.totalTracked.inSeconds,
              color: activityTypeColor(entry.key, isDark: isDark),
              theme: theme,
            ),
          ),
        if (projectEntries.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Podle projektu',
            style: TextStyle(
              color: theme.dim,
              fontFamily: 'Sora',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          for (final entry in projectEntries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        color: theme.text,
                        fontFamily: 'Sora',
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDuration(entry.value),
                    style: TextStyle(
                      color: theme.dim,
                      fontFamily: 'Sora',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
        ],
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.panel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Celkem sledováno',
                style: TextStyle(
                  color: theme.dim,
                  fontFamily: 'Sora',
                  fontSize: 13,
                ),
              ),
              Text(
                _formatDuration(stats.totalTracked),
                style: TextStyle(
                  color: theme.text,
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.panel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nesledovaný čas',
                style: TextStyle(
                  color: theme.dim,
                  fontFamily: 'Sora',
                  fontSize: 13,
                ),
              ),
              Text(
                _formatDuration(stats.untrackedTime),
                style: TextStyle(
                  color: theme.text,
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityTypeBar extends StatelessWidget {
  final String type;
  final Duration duration;
  final double progress;
  final Color color;
  final AppThemeData theme;

  const _ActivityTypeBar({
    required this.type,
    required this.duration,
    required this.progress,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                type,
                style: TextStyle(
                  color: theme.text,
                  fontFamily: 'Sora',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${_formatDuration(duration)} · $percent%',
              style: TextStyle(color: theme.dim, fontFamily: 'Sora', fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 8,
          child: CustomPaint(
            painter: BarPainter(progress: progress, color: color, theme: theme),
            size: Size.infinite,
          ),
        ),
      ],
    );
  }
}
