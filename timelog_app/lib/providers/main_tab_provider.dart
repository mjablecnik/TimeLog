import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index of the selected bottom-nav tab in the main shell (see `app.dart`).
/// Lifted out of `_MainShellState` so other code can switch tabs without a
/// `BuildContext` back into `_MainShell`.
final mainTabIndexProvider = StateProvider<int>((ref) => 0);
