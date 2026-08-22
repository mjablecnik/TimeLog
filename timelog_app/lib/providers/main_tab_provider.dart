import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index of the selected bottom-nav tab in the main shell (see `app.dart`).
/// Lifted out of `_MainShellState` so routes pushed on top of the shell
/// (e.g. `HistoryScreen`, reached from the Stats tab) can switch tabs
/// without needing a `BuildContext` back into `_MainShell`.
final mainTabIndexProvider = StateProvider<int>((ref) => 0);
