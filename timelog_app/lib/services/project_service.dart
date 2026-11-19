import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/activity_types.dart';
import '../data/database.dart';

/// Legacy keys of the single combined list (before suggestions were scoped).
const _legacyKey = 'known_projects';
const _legacyKeyV2 = 'known_projects_v2';

/// Prefix of the per-scope lists: JSON list of {name, lastUsed} objects.
const _scopedKeyPrefix = 'known_names_v3_';

/// Set once the scoped lists were filled from the existing entries.
const _seededKey = 'known_names_v3_seeded';

/// Names unused for longer than this duration are automatically removed.
const _expiryDuration = Duration(days: 30);

/// Remembers the names the user typed, one list per [SuggestionScope]
/// (paid work, unpaid work, housework, other), so that a name entered in one
/// category is not offered in another.
class ProjectService {
  /// Returns the known names of [scope], most recently used first. Names that
  /// were not used for 30 days are removed.
  Future<List<String>> getKnownNames(SuggestionScope scope) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = _load(prefs, scope);

    final now = DateTime.now();
    final active = entries
        .where((e) => now.difference(e.lastUsed) < _expiryDuration)
        .toList();
    if (active.length != entries.length) {
      await _save(prefs, scope, active);
    }

    active.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    return active.map((e) => e.name).toList();
  }

  /// Adds [name] to the list of [scope], or refreshes its last-used time.
  /// Names are compared ignoring letter case; the casing of the latest input
  /// is kept.
  Future<void> saveName(SuggestionScope scope, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final entries = _load(prefs, scope);
    final now = DateTime.now();

    final index = entries.indexWhere(
      (e) => e.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (index >= 0) {
      entries[index] = _NameEntry(name: trimmed, lastUsed: now);
    } else {
      entries.add(_NameEntry(name: trimmed, lastUsed: now));
    }
    await _save(prefs, scope, entries);
  }

  /// One-time fill of the scoped lists from existing time entries (their
  /// project or custom name, in the scope the registry assigns to the entry),
  /// with the latest end time of a name as its last-used time. Removes the
  /// legacy combined lists. Does nothing when it already ran.
  Future<void> seedFromEntries(List<TimeEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_seededKey) == true) return;

    final now = DateTime.now();
    final seeded = <SuggestionScope, Map<String, _NameEntry>>{};
    for (final entry in entries) {
      final scope = suggestionScopeOf(entry.activityType, entry.subtype);
      if (scope == null) continue;
      final name =
          (hasCustomNameField(entry.activityType)
                  ? entry.customName
                  : entry.project)
              ?.trim();
      if (name == null || name.isEmpty) continue;
      final lastUsed = DateTime.tryParse(entry.endTime);
      if (lastUsed == null || now.difference(lastUsed) >= _expiryDuration) {
        continue;
      }
      final byName = seeded.putIfAbsent(scope, () => {});
      final key = name.toLowerCase();
      final existing = byName[key];
      if (existing == null || lastUsed.isAfter(existing.lastUsed)) {
        byName[key] = _NameEntry(name: name, lastUsed: lastUsed);
      }
    }

    for (final scope in SuggestionScope.values) {
      final fromEntries = seeded[scope];
      if (fromEntries == null) continue;
      // Merge with anything already saved, keeping the newer time per name.
      final merged = <String, _NameEntry>{
        for (final e in _load(prefs, scope)) e.name.toLowerCase(): e,
      };
      for (final e in fromEntries.values) {
        final existing = merged[e.name.toLowerCase()];
        if (existing == null || e.lastUsed.isAfter(existing.lastUsed)) {
          merged[e.name.toLowerCase()] = e;
        }
      }
      await _save(prefs, scope, merged.values.toList());
    }

    await prefs.remove(_legacyKey);
    await prefs.remove(_legacyKeyV2);
    await prefs.setBool(_seededKey, true);
  }

  // -- private helpers --

  List<_NameEntry> _load(SharedPreferences prefs, SuggestionScope scope) {
    final json = prefs.getString('$_scopedKeyPrefix${scope.name}');
    if (json == null) return [];
    try {
      final decoded = jsonDecode(json) as List<dynamic>;
      return decoded
          .map((e) => _NameEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // A corrupt list counts as empty and is overwritten on the next save.
      return [];
    }
  }

  Future<void> _save(
    SharedPreferences prefs,
    SuggestionScope scope,
    List<_NameEntry> entries,
  ) async {
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString('$_scopedKeyPrefix${scope.name}', encoded);
  }
}

class _NameEntry {
  final String name;
  final DateTime lastUsed;

  _NameEntry({required this.name, required this.lastUsed});

  factory _NameEntry.fromJson(Map<String, dynamic> json) {
    return _NameEntry(
      name: json['name'] as String,
      lastUsed: DateTime.parse(json['lastUsed'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'lastUsed': lastUsed.toIso8601String(),
  };
}
