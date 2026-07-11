import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../providers/history_provider.dart';

class DayNavigator extends ConsumerWidget {
  final AppThemeData theme;

  const DayNavigator({super.key, required this.theme});

  String _dayLabel(DateTime day) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    if (day.year == todayDate.year &&
        day.month == todayDate.month &&
        day.day == todayDate.day) {
      return 'Today';
    }
    if (day.year == yesterday.year &&
        day.month == yesterday.month &&
        day.day == yesterday.day) {
      return 'Yesterday';
    }

    return '${day.day}. ${day.month}. ${day.year}';
  }

  bool _isToday(DateTime day) {
    final today = DateTime.now();
    return day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final isToday = _isToday(selectedDay);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: theme.dim),
          onPressed: () {
            ref.read(selectedDayProvider.notifier).state =
                selectedDay.subtract(const Duration(days: 1));
          },
        ),
        GestureDetector(
          onTap: () async {
            final today = DateTime.now();
            final todayDate = DateTime(today.year, today.month, today.day);
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDay,
              firstDate: DateTime(2020),
              lastDate: todayDate,
              builder: (ctx, child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: theme.accent,
                      surface: theme.background,
                      onSurface: theme.text,
                    ),
                    dialogTheme: DialogThemeData(backgroundColor: theme.background),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              ref.read(selectedDayProvider.notifier).state =
                  DateTime(picked.year, picked.month, picked.day);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              _dayLabel(selectedDay),
              style: TextStyle(
                color: theme.text,
                fontFamily: 'Sora',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: isToday ? theme.faint : theme.dim,
          ),
          onPressed: isToday
              ? null
              : () {
                  ref.read(selectedDayProvider.notifier).state =
                      selectedDay.add(const Duration(days: 1));
                },
        ),
      ],
    );
  }
}
