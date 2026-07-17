import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Multi-select weekday chip row. Days follow Dart's `DateTime.weekday`
/// convention: 1=Monday ... 7=Sunday.
class DaySelector extends StatelessWidget {
  static const List<String> _labels = ['Po', 'Út', 'St', 'Čt', 'Pá', 'So', 'Ne'];

  final Set<int> activeDays;
  final ValueChanged<Set<int>> onChanged;
  final AppThemeData theme;

  const DaySelector({
    super.key,
    required this.activeDays,
    required this.onChanged,
    required this.theme,
  });

  void _toggle(int day) {
    final updated = Set<int>.from(activeDays);
    if (updated.contains(day)) {
      updated.remove(day);
    } else {
      updated.add(day);
    }
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final day = index + 1;
        final isSelected = activeDays.contains(day);
        return GestureDetector(
          onTap: () => _toggle(day),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? theme.accent : theme.panel,
              border: Border.all(
                color: isSelected ? theme.accent : theme.border,
              ),
            ),
            child: Text(
              _labels[index],
              style: TextStyle(
                color: isSelected ? theme.ink : theme.dim,
                fontFamily: 'Sora',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }
}
