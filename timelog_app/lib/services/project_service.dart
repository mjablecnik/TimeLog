import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Key for the legacy plain list (migrated on first access).
const _legacyKey = 'known_projects';

/// Key for the new format: JSON list of {name, lastUsed} objects.
const _projectsKey = 'known_projects_v2';

/// Projects unused for longer than this duration are automatically removed.
const _expiryDuration = Duration(days: 30);

class ProjectService {
  /// Returns known projects sorted by most-recently-used (newest first).
  /// Automatically removes projects that haven't been used for 30 days.
  Future<List<String>> getKnownProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await _loadEntries(prefs);

    // Remove expired entries.
    final now = DateTime.now();
    final active = entries
        .where((e) => now.difference(e.lastUsed) < _expiryDuration)
        .toList();

    // Persist if any were removed.
    if (active.length != entries.length) {
      await _saveEntries(prefs, active);
    }

    // Return sorted by most recently used.
    active.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    return active.map((e) => e.name).toList();
  }

  /// Saves or updates the last-used timestamp for [project].
  Future<void> saveProject(String project) async {
    final trimmed = project.trim();
    if (trimmed.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final entries = await _loadEntries(prefs);
    final now = DateTime.now();

    final index =
        entries.indexWhere((e) => e.name.toLowerCase() == trimmed.toLowerCase());
    if (index >= 0) {
      // Update timestamp (and potentially fix casing to latest input).
      entries[index] = _ProjectEntry(name: trimmed, lastUsed: now);
    } else {
      entries.add(_ProjectEntry(name: trimmed, lastUsed: now));
    }

    await _saveEntries(prefs, entries);
  }

  // -- private helpers --

  Future<List<_ProjectEntry>> _loadEntries(SharedPreferences prefs) async {
    // Try new format first.
    final json = prefs.getString(_projectsKey);
    if (json != null) {
      final List<dynamic> decoded = jsonDecode(json) as List<dynamic>;
      return decoded
          .map((e) => _ProjectEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Migrate from legacy format.
    final legacy = prefs.getStringList(_legacyKey);
    if (legacy != null && legacy.isNotEmpty) {
      final now = DateTime.now();
      final entries =
          legacy.map((name) => _ProjectEntry(name: name, lastUsed: now)).toList();
      await _saveEntries(prefs, entries);
      await prefs.remove(_legacyKey);
      return entries;
    }

    return [];
  }

  Future<void> _saveEntries(
      SharedPreferences prefs, List<_ProjectEntry> entries) async {
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_projectsKey, encoded);
  }
}

class _ProjectEntry {
  final String name;
  final DateTime lastUsed;

  _ProjectEntry({required this.name, required this.lastUsed});

  factory _ProjectEntry.fromJson(Map<String, dynamic> json) {
    return _ProjectEntry(
      name: json['name'] as String,
      lastUsed: DateTime.parse(json['lastUsed'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'lastUsed': lastUsed.toIso8601String(),
      };
}
