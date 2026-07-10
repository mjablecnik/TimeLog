import 'package:flutter/material.dart';

import '../../core/theme.dart';

class DurationAdjuster extends StatelessWidget {
  final int minutes;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int min;
  final int max;
  final AppThemeData theme;

  const DurationAdjuster({
    super.key,
    required this.minutes,
    required this.onIncrement,
    required this.onDecrement,
    required this.min,
    required this.max,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepButton(
          icon: Icons.remove,
          theme: theme,
          enabled: minutes > min,
          onPressed: onDecrement,
        ),
        const SizedBox(width: 16),
        Text(
          '$minutes min',
          style: TextStyle(
            color: theme.dim,
            fontFamily: 'Sora',
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 16),
        _StepButton(
          icon: Icons.add,
          theme: theme,
          enabled: minutes < max,
          onPressed: onIncrement,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final AppThemeData theme;
  final bool enabled;
  final VoidCallback onPressed;

  const _StepButton({
    required this.icon,
    required this.theme,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.panel,
          border: Border.all(color: theme.border),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? theme.dim : theme.faint,
        ),
      ),
    );
  }
}
