import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timelog_app/core/activity_types.dart';
import 'package:timelog_app/l10n/generated/app_localizations_cs.dart';
import 'package:timelog_app/l10n/generated/app_localizations_en.dart';

// Feature: activity-subtypes
//
// glados cannot be added (analyzer conflict, see .agents/MEMORY.md), so the
// properties use a seeded random loop with 100+ iterations.
double _luminance(Color c) => c.computeLuminance();

void main() {
  final en = AppLocalizationsEn();
  final cs = AppLocalizationsCs();

  group('registry contents', () {
    test('has the twelve main types in order', () {
      expect(activityTypes, [
        'Práce',
        'Domácí práce',
        'Meeting',
        'Komunikace',
        'Přesun',
        'Zábava',
        'Cvičení',
        'Seberozvoj',
        'Odpočinek',
        'Hygiena',
        'Jídlo',
        'Ostatní',
      ]);
    });

    test('subtypes of each type, in order', () {
      List<String> keys(String type) =>
          [for (final s in activityTypeOf(type)!.subtypes) s.key];
      expect(keys('Práce'), ['paid', 'unpaid']);
      expect(keys('Zábava'), ['active', 'passive']);
      expect(keys('Cvičení'), ['walk', 'running', 'gym']);
      expect(keys('Seberozvoj'), ['books', 'study', 'ai']);
      expect(keys('Odpočinek'), ['active', 'passive']);
      expect(keys('Hygiena'), ['general', 'toilet']);
      expect(keys('Jídlo'), ['breakfast', 'lunch', 'dinner', 'snack']);
      for (final type in [
        'Domácí práce',
        'Meeting',
        'Komunikace',
        'Přesun',
        'Ostatní',
      ]) {
        expect(activityTypeOf(type)!.subtypes, isEmpty, reason: type);
      }
    });

    test('extra field per type', () {
      expect(hasProjectField('Práce'), isTrue);
      expect(hasProjectField('Domácí práce'), isTrue);
      expect(hasCustomNameField('Ostatní'), isTrue);
      for (final type in activityTypes) {
        if (type == 'Práce' || type == 'Domácí práce') continue;
        expect(hasProjectField(type), isFalse, reason: type);
      }
      for (final type in activityTypes) {
        if (type == 'Ostatní') continue;
        expect(hasCustomNameField(type), isFalse, reason: type);
      }
    });

    test('paid work is darker than unpaid work on every theme', () {
      for (final isDark in [true, false]) {
        final paid = activityEntryColor('Práce', 'paid', isDark: isDark);
        final unpaid = activityEntryColor('Práce', 'unpaid', isDark: isDark);
        expect(_luminance(paid), lessThan(_luminance(unpaid)), reason: 'dark=$isDark');
      }
    });

    test('Přesun is labelled Travel / Cestování but keeps its key', () {
      expect(activityTypeOf('Přesun'), isNotNull);
      expect(activityTypeLabel(en, 'Přesun'), 'Travel');
      expect(activityTypeLabel(cs, 'Přesun'), 'Cestování');
    });

    test('every type and subtype has an English and a Czech label', () {
      for (final type in activityRegistry) {
        expect(activityTypeLabel(en, type.key), isNot(type.key == 'Meeting' ? '' : type.key),
            reason: type.key);
        expect(activityTypeLabel(cs, type.key), isNotEmpty);
        for (final subtype in type.subtypes) {
          expect(subtypeLabel(en, type.key, subtype.key), isNot(subtype.key),
              reason: '${type.key}/${subtype.key}');
          expect(subtypeLabel(cs, type.key, subtype.key), isNot(subtype.key),
              reason: '${type.key}/${subtype.key}');
        }
      }
      expect(subtypeLabel(cs, 'Práce', 'paid'), 'Placená');
      expect(subtypeLabel(en, 'Jídlo', 'snack'), 'Snack');
    });
  });

  group('entryMetaLine', () {
    test('subtype and project', () {
      final line = entryMetaLine(en,
          typeKey: 'Práce', subtypeKey: 'paid', project: 'App', isDark: true);
      expect(line!.text, 'App · Paid');
      expect(line.dotColor, activityEntryColor('Práce', 'paid', isDark: true));
    });

    test('subtype without project', () {
      final line = entryMetaLine(cs,
          typeKey: 'Cvičení', subtypeKey: 'walk', isDark: true);
      expect(line!.text, 'Procházka');
      expect(line.dotColor, isNotNull);
    });

    test('project without subtype has no dot', () {
      final line = entryMetaLine(en,
          typeKey: 'Domácí práce', project: 'Garage', isDark: true);
      expect(line!.text, 'Garage');
      expect(line.dotColor, isNull);
    });

    test('custom name of Ostatní', () {
      final line = entryMetaLine(en,
          typeKey: 'Ostatní', customName: ' Guitar ', isDark: false);
      expect(line!.text, 'Guitar');
      expect(line.dotColor, isNotNull);
    });

    test('nothing to show', () {
      expect(entryMetaLine(en, typeKey: 'Meeting', isDark: true), isNull);
      expect(entryMetaLine(en, typeKey: 'Ostatní', isDark: true), isNull);
      expect(
        entryMetaLine(en, typeKey: 'Práce', subtypeKey: 'bogus', isDark: true),
        isNull,
      );
    });
  });

  test('Property 1: registry integrity', () {
    final typeKeys = <String>{};
    for (final type in activityRegistry) {
      expect(typeKeys.add(type.key), isTrue, reason: 'duplicate type ${type.key}');
      final subtypeKeys = <String>{};
      for (final subtype in type.subtypes) {
        expect(subtypeKeys.add(subtype.key), isTrue,
            reason: 'duplicate subtype ${type.key}/${subtype.key}');
        expect(subtype.dark.a, 1.0);
        expect(subtype.light.a, 1.0);
      }
      expect(type.dark.a, 1.0);
      expect(type.light.a, 1.0);
    }
  });

  test('Property 2: entry colour resolution follows the fallback chain', () {
    final random = Random(20261119);
    const letters = 'abcdefghijklmnopqrstuvwxyzáíé';
    String randomString() => String.fromCharCodes(
        List.generate(1 + random.nextInt(8), (_) => letters.codeUnitAt(random.nextInt(letters.length))));
    const grey = Color(0xFFBDBDBD);

    for (var i = 0; i < 300; i++) {
      final isDark = random.nextBool();
      final useKnownType = random.nextBool();
      final typeKey = useKnownType
          ? activityTypes[random.nextInt(activityTypes.length)]
          : randomString();
      final subtypeChoice = random.nextInt(3);
      final type = activityTypeOf(typeKey);
      String? subtypeKey;
      if (subtypeChoice == 1 && type != null && type.subtypes.isNotEmpty) {
        subtypeKey = type.subtypes[random.nextInt(type.subtypes.length)].key;
      } else if (subtypeChoice == 2) {
        subtypeKey = randomString();
      }

      final color = activityEntryColor(typeKey, subtypeKey, isDark: isDark);
      final subtype = subtypeOf(typeKey, subtypeKey);
      if (subtype != null) {
        expect(color, isDark ? subtype.dark : subtype.light);
      } else if (type != null) {
        expect(color, isDark ? type.dark : type.light);
      } else {
        expect(color, grey);
      }
    }
  });

  test('Property 6: subtype preselection is always valid', () {
    final random = Random(20261120);
    for (var i = 0; i < 300; i++) {
      final typeKey = activityTypes[random.nextInt(activityTypes.length)];
      final type = activityTypeOf(typeKey)!;
      final remembered = switch (random.nextInt(3)) {
        0 => null,
        1 => 'nonsense-${random.nextInt(100)}',
        _ => type.subtypes.isEmpty
            ? 'paid'
            : type.subtypes[random.nextInt(type.subtypes.length)].key,
      };
      final result = defaultSubtypeKey(typeKey, remembered: remembered);
      if (type.subtypes.isEmpty) {
        expect(result, isNull, reason: typeKey);
      } else {
        expect(subtypeOf(typeKey, result), isNotNull, reason: '$typeKey/$remembered -> $result');
        if (remembered != null && subtypeOf(typeKey, remembered) != null) {
          expect(result, remembered);
        } else {
          expect(result, type.subtypes.first.key);
        }
      }
    }
  });

  test('Property 8: suggestion scope mapping', () {
    for (final type in activityRegistry) {
      final subtypes = <String?>[null, ...type.subtypes.map((s) => s.key), 'bogus'];
      for (final subtype in subtypes) {
        final scope = suggestionScopeOf(type.key, subtype);
        final expected = switch (type.key) {
          'Práce' when subtype == 'paid' => SuggestionScope.workPaid,
          'Práce' when subtype == 'unpaid' => SuggestionScope.workUnpaid,
          'Domácí práce' => SuggestionScope.housework,
          'Ostatní' => SuggestionScope.other,
          _ => null,
        };
        expect(scope, expected, reason: '${type.key}/$subtype');
      }
    }
    expect(suggestionScopeOf('unknown', null), isNull);
  });

  test('suggestionScopeFromName falls back to unpaid work', () {
    expect(suggestionScopeFromName('housework'), SuggestionScope.housework);
    expect(suggestionScopeFromName('workPaid'), SuggestionScope.workPaid);
    expect(suggestionScopeFromName('bogus'), SuggestionScope.workUnpaid);
    expect(suggestionScopeFromName(null), SuggestionScope.workUnpaid);
  });
}
