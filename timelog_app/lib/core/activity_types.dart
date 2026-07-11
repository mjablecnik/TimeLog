import 'package:flutter/material.dart';

const List<String> activityTypes = [
  'Práce',
  'Volný čas',
  'Odpočinek',
  'Spánek',
  'Cvičení',
];

/// Returns the distinct badge color for [type]. [isDark] selects the
/// variant for the "Spánek" type, which needs a different shade on light
/// themes to stay legible.
Color activityTypeColor(String type, {bool isDark = true}) {
  switch (type) {
    case 'Práce':
      return Colors.red[400]!;
    case 'Volný čas':
      return Colors.green[400]!;
    case 'Odpočinek':
      return Colors.blue[400]!;
    case 'Spánek':
      return isDark ? Colors.purple[300]! : Colors.purple[700]!;
    case 'Cvičení':
      return Colors.amber[600]!;
    default:
      return Colors.grey[400]!;
  }
}
