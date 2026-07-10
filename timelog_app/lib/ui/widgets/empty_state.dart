import 'package:flutter/material.dart';

import '../../core/theme.dart';

class EmptyState extends StatelessWidget {
  final AppThemeData theme;

  const EmptyState({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_outlined, size: 52, color: theme.faint),
          const SizedBox(height: 16),
          Text(
            'No entries for this day',
            style: TextStyle(
              color: theme.dim,
              fontFamily: 'Sora',
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a timer to log your work',
            style: TextStyle(
              color: theme.faint,
              fontFamily: 'Sora',
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
