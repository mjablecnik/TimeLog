import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/database.dart';

class DaySummary extends StatelessWidget {
  final List<TimeEntry> entries;
  final AppThemeData theme;

  const DaySummary({super.key, required this.entries, required this.theme});

  String _totalTime() {
    int totalMinutes = 0;
    for (final entry in entries) {
      final start = DateTime.parse(entry.startTime);
      final end = DateTime.parse(entry.endTime);
      totalMinutes += end.difference(start).inMinutes;
    }
    if (totalMinutes < 60) return '${totalMinutes}m';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }

  @override
  Widget build(BuildContext context) {
    final count = entries.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '$count ${count == 1 ? 'entry' : 'entries'}',
            style: TextStyle(
              color: theme.dim,
              fontFamily: 'Sora',
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Total: ${_totalTime()}',
            style: TextStyle(
              color: theme.dim,
              fontFamily: 'Sora',
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
