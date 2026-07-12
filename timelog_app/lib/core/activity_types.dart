import 'package:flutter/material.dart';

const List<String> activityTypes = [
  'Práce',
  'Volná práce',
  'Cvičení',
  'Spánek',
  'Přesun',
  'Volný čas',
  'Odpočinek',
  'Jídlo',
  'Hygiena',
];

/// Activity types that represent work and should show a project field.
const List<String> workActivityTypes = ['Práce', 'Volná práce'];

bool isWorkActivityType(String type) => workActivityTypes.contains(type);

/// Returns the distinct badge color for [type]. [isDark] selects the
/// variant for the "Spánek" and "Přesun" types, which need a different
/// shade on light themes to stay legible.
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
    case 'Volná práce':
      return Colors.teal[400]!;
    case 'Přesun':
      return isDark ? Colors.indigo[300]! : Colors.indigo[400]!;
    case 'Jídlo':
      return isDark ? Colors.purple[200]! : Colors.purple[900]!;
    case 'Hygiena':
      return isDark ? Colors.blue[300]! : Colors.blue[900]!;
    default:
      return Colors.grey[400]!;
  }
}
