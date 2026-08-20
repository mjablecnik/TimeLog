import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/core/date_format_utils.dart';

// Feature: task-management, Property 8: Date formatting
//
// glados (the property-based testing library named in the design doc) requires
// analyzer ^8.0.0+ transitively via `test`, which conflicts with this project's
// pinned freezed ^2.5.7 (analyzer ^6.5.0/^7.0.0) — see .agents/MEMORY.md. This
// hand-rolled randomized loop (100+ iterations, seeded for reproducibility)
// exercises the same property without adding that dependency.
void main() {
  test(
    'Property 8: for any valid ISO 8601 date, formatDeadline produces a '
    'string matching "d. M. yyyy" (no leading zeros on day/month, '
    '4-digit year)',
    () {
      final random = Random(20260820);
      final pattern = RegExp(r'^([1-9][0-9]*)\. ([1-9][0-9]*)\. ([0-9]{4})$');

      for (var iteration = 0; iteration < 100; iteration++) {
        final year = 1900 + random.nextInt(300); // 1900..2199
        final month = 1 + random.nextInt(12); // 1..12
        final daysInMonth = DateTime(year, month + 1, 0).day;
        final day = 1 + random.nextInt(daysInMonth);

        final isoDate =
            '$year-${month.toString().padLeft(2, '0')}-'
            '${day.toString().padLeft(2, '0')}';

        final formatted = formatDeadline(isoDate);
        final match = pattern.firstMatch(formatted);

        expect(
          match,
          isNotNull,
          reason: 'iteration $iteration: "$formatted" (from "$isoDate") '
              'must match pattern "d. M. yyyy"',
        );
        expect(
          int.parse(match!.group(1)!),
          day,
          reason: 'iteration $iteration: day component mismatch for '
              '"$isoDate"',
        );
        expect(
          int.parse(match.group(2)!),
          month,
          reason: 'iteration $iteration: month component mismatch for '
              '"$isoDate"',
        );
        expect(
          int.parse(match.group(3)!),
          year,
          reason: 'iteration $iteration: year component mismatch for '
              '"$isoDate"',
        );
      }
    },
  );
}
