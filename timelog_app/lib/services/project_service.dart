import 'package:shared_preferences/shared_preferences.dart';

const _knownProjectsKey = 'known_projects';

class ProjectService {
  Future<List<String>> getKnownProjects() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_knownProjectsKey) ?? [];
  }

  Future<void> saveProject(String project) async {
    final trimmed = project.trim();
    if (trimmed.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final known = prefs.getStringList(_knownProjectsKey) ?? [];
    final alreadyKnown = known.any((p) => p.toLowerCase() == trimmed.toLowerCase());
    if (!alreadyKnown) {
      await prefs.setStringList(_knownProjectsKey, [...known, trimmed]);
    }
  }
}
