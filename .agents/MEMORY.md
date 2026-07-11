# Memory

## drift's sqlite3 ffi package needs an unversioned libsqlite3.so on the loader path, not just the system libsqlite3.so.0
- Project: timelog_app
- Problem: Any widget test that directly awaits a query on a `NativeDatabase.memory()` (e.g. `await db.into(db.timeEntries).insert(...)` at the top of the test body, outside the widget tree) fails with `Invalid argument(s): Failed to load dynamic library 'libsqlite3.so': libsqlite3.so: cannot open shared object file: No such file or directory` (via `package:sqlite3/src/ffi/load_library.dart`). The sandbox only has the runtime package `libsqlite3-0` installed (`/usr/lib/x86_64-linux-gnu/libsqlite3.so.0`), not `libsqlite3-dev`, so there's no unversioned `libsqlite3.so` symlink for `dlopen` to find by the default name. Note `test/widget_test.dart`'s existing smoke test *looks* like it exercises the same NativeDatabase.memory() path and "passes" regardless, but that's misleading — it only pumps for ~150ms and never directly awaits a query outside the widget tree, so a `FutureProvider` (`databaseServiceProvider`) failing to open the DB just sits as an unresolved/errored `AsyncValue` that nothing in that test asserts on; it doesn't mean sqlite3 actually works.
- Solution: Before running `flutter test` on anything that touches Drift/sqlite3 directly, create a local unversioned symlink and put it on `LD_LIBRARY_PATH`: `mkdir -p /tmp/sqlite3-dev/lib && ln -sf /usr/lib/x86_64-linux-gnu/libsqlite3.so.0 /tmp/sqlite3-dev/lib/libsqlite3.so`, then run with `LD_LIBRARY_PATH=/tmp/sqlite3-dev/lib:$LD_LIBRARY_PATH flutter test ...`. Like the other `/tmp` wrapper dirs, this doesn't persist between agent runs — recreate it every time.
- Source: from-brief, 2026-07-11

## Testing EditSheet's showTimePicker: FutureProvider must be pre-resolved via ProviderContainer before the first Save tap
- Project: timelog_app
- Problem: A widget test for `EditSheet` that uses a plain `ProviderScope` (rather than an explicit `ProviderContainer`) and taps "Save" shows `Database unavailable. Please try again.` on the very first tap that actually reaches `ref.read(databaseServiceProvider).valueOrNull` — even though the DB itself works fine (confirmed via direct queries) and later Save taps in the same test succeed. Root cause: `databaseServiceProvider` (`FutureProvider`) is lazily created and only starts resolving on first read; if an earlier `_save()` call returned early on validation failure (e.g. end-time-before-start) without ever reading the provider, then the *next* Save tap is the first real read, and `.valueOrNull` is still `null` because the async `initialize()` hasn't completed synchronously yet.
- Solution: Build an explicit `ProviderContainer(overrides: [...])`, `await container.read(databaseServiceProvider.future)` to force it to fully resolve, *then* `pumpWidget(UncontrolledProviderScope(container: container, child: ...))`. This matches the pattern already used in `test/description_sheet_prefill_cancel_test.dart` for the timer provider. Also useful for driving Material's `showTimePicker`: tap the field showing the current `HH:mm` text, tap the `Icons.keyboard_outlined` icon to switch from dial to manual entry, then `find.descendant(of: find.byType(Dialog), matching: find.byType(TextField))` to reach the hour/minute `TextFormField`s (scoping to the `Dialog` avoids matching the sheet's own description/project text fields underneath), enter digits, and tap the `TextButton` labeled `'OK'`.
- Source: from-brief, 2026-07-11

## Widget tests that leave TimerNotifier running fail with "A Timer is still pending" unless explicitly stopped before the test body ends
- Project: timelog_app
- Problem: A widget test that calls `TimerNotifier.start()`/`resume()` (e.g. to drive `TimerScreen` through pause/resume for the prefill-cancel flow) leaves the notifier's internal periodic `_ticker` running when the test body finishes. `ProviderContainer.dispose()` registered via `addTearDown` would cancel it (via `TimerNotifier.dispose()`), but `flutter_test`'s `AutomatedTestWidgetsFlutterBinding._verifyInvariants` checks for pending timers *before* `addTearDown` callbacks run, so the test fails with `A Timer is still pending even after the widget tree was disposed` even though the assertions themselves all passed.
- Solution: Explicitly call `container.read(timerProvider.notifier).stop()` (or `.pause()`) as the last line of the test body, before relying on `addTearDown(container.dispose)` for cleanup. `stop()`/`pause()` cancel `_ticker` synchronously.
- Source: from-brief, 2026-07-11

## database.dart migration referencing a new column fails `flutter analyze` until build_runner regenerates database.g.dart — this is expected, not a bug
- Project: timelog_app
- Problem: TASKS.md deliberately splits "add column to table class" / "add schemaVersion bump + migration" / "run build_runner" into separate numbered tasks. After adding `m.addColumn(timeEntries, timeEntries.project)` in the `onUpgrade` migration (task 3) but before running `dart run build_runner build` (task 4), `flutter analyze lib/data/database.dart` fails with `error • The argument type 'TextColumn' can't be assigned to the parameter type 'GeneratedColumn<Object>' • argument_type_not_assignable`. This is because `timeEntries` inside `AppDatabase` resolves to the generated `$TimeEntriesTable` class in `database.g.dart`, and until that file is regenerated it has no `project` getter of the correct `GeneratedColumn<String>` type — `timeEntries.project` falls back to the abstract declarative-API `TextColumn` from `time_entry.dart`, which doesn't match the `GeneratedColumn<Object>` parameter type `Migrator.addColumn` expects.
- Solution: This is a transient, expected state between the "add migration" and "regenerate" tasks — don't try to fix it by changing the migration code. Just implement the migration task as specified, note that full compile is blocked on the next task (build_runner regen), and let that task resolve it. Confirmed this matches the prior run's pattern (project column added to `time_entry.dart` in an earlier commit before schemaVersion/migration/codegen existed, also without a passing `flutter analyze`).
- Source: from-brief, 2026-07-11

## /tmp setup artifacts (flutter-wrap, clang-wrap, gst-dev) do not persist between agent runs
- Project: timelog_app
- Problem: `/tmp/flutter-wrap`, `/tmp/clang-wrap`, and `/tmp/gst-dev` (built per the wrapper/gstreamer-dev recipes below) are gone at the start of each new run/container — they must be recreated every time, not just verified. Also, a naive existence check like `ls /tmp/gst-dev/.../pkgconfig/ 2>/dev/null | head -5 && echo exists || echo missing` is a false positive: piping `ls` into `head` means the `&&`/`||` branch on the pipeline's exit status (from `head`, which always succeeds even on empty input), not on `ls`'s exit status, so it reports "exists" even when the directory is missing.
- Solution: At the start of any build task, just recreate all three wrapper dirs unconditionally (cheap, idempotent) rather than probing for them first. If you do want to check existence, test the actual target file directly, e.g. `test -f /tmp/gst-dev/usr/include/gstreamer-1.0/gst/gst.h && echo exists || echo missing` (no pipe).
- Source: from-brief, 2026-07-11

## audioplayers_linux crashes on startup (uncaught C++ exception) unless GStreamer plugin binaries are installed, not just -dev headers
- Project: timelog_app
- Problem: `flutter build linux` succeeds and `flutter analyze`/`flutter test` pass cleanly (all use only `libgstreamer1.0-dev`/`libgstreamer-plugins-base1.0-dev`), but the built binary aborts immediately on startup with `terminate called after throwing an instance of 'char const*'` / SIGABRT the first time it constructs an `AudioPlayer` (audioplayers_linux plugin, alarm sound). Root cause (confirmed via gdb backtrace, `AudioPlayer::AudioPlayer` in `audioplayers_linux-*/linux/audio_player.cc:17`): `gst_element_factory_make("playbin", NULL)` returns null because the `playbin` GStreamer element is shipped in the `gstreamer1.0-plugins-base` runtime package, which is NOT a dependency of the `-dev` packages used at build time. `audio_player.cc` throws a raw `throw "Not all elements could be created.";` (bare C-string, not a subclass of `std::exception`) from inside a GLib platform-message callback, which is never caught anywhere up the call stack (flutter engine → GTK → GLib main loop → `main()`), so it always terminates the whole process, not just the failing plugin call.
- Solution: This is an environment/runtime-dependency gap, not an app code bug — don't try to fix it in Dart/C++. Install (or in a no-root sandbox, `apt-get download` + `dpkg-deb -x` into a local prefix and add to `LD_LIBRARY_PATH` + `GST_PLUGIN_SYSTEM_PATH`) the actual GStreamer plugin packages: `gstreamer1.0-plugins-base`, `gstreamer1.0-plugins-good`, and their transitive runtime lib `liborc-0.4-0t64` (the dev variant `liborc-0.4-dev` only ships the unversioned `.so` symlink, not `.so.0`). README now documents this under Requirements. To reproduce/verify in a headless container: run under `dbus-run-session -- xvfb-run -a ./timelog_app`, and to get a real backtrace when it aborts, run under gdb with `handle SIGPIPE nostop noprint pass` first (dart:io's Process/ExitCodeHandler thread trips an unrelated, harmless SIGPIPE early that otherwise stops gdb before reaching the real crash).
- Source: check-build, 2026-07-11

## dart pub get strips platform plugin registration — use flutter pub get or revert generated files
- Project: timelog_app
- Problem: Running `/opt/flutter/bin/cache/dart-sdk/bin/dart pub get` directly (instead of `flutter pub get`) to resolve dependencies before `flutter analyze`/`flutter test` also regenerates `linux/flutter/generated_plugin_registrant.cc`, `linux/flutter/generated_plugins.cmake`, `macos/Flutter/GeneratedPluginRegistrant.swift`, and `windows/flutter/generated_plugin_registrant.cc/.cmake`, but strips out the `audioplayers_linux` and `sqlite3_flutter_libs` plugin registrations (dart pub get's plugin resolution differs from flutter's). This silently breaks the Linux build (missing plugin registration) if the generated files are committed.
- Solution: After running `dart pub get`, check `git status`/`git diff` for changes to `generated_plugin_registrant.*` / `generated_plugins.cmake` / `GeneratedPluginRegistrant.swift` and `git checkout --` them before committing, since they aren't part of the intended change. Prefer `flutter pub get` via the wrapper when possible; only fall back to raw `dart pub get` when needed and always revert the plugin registrant side-effects afterward.
- Source: from-brief, 2026-07-11

## flutter command fails due to /opt/flutter read-only permissions
- Project: timelog_app
- Problem: `/opt/flutter/bin/cache/engine.stamp` and `/opt/flutter/bin/cache/lockfile` are owned by root and read-only. The `flutter` shell script tries to overwrite engine.stamp on every run, causing "Permission denied" and exiting before running any command. The flutter dart snapshot also needs to write to `/opt/flutter/packages/flutter_tools/.dart_tool/package_config.json` which is also read-only.
- Solution: Create a writable flutter wrapper at `/tmp/flutter-wrap/`:
  1. `mkdir -p /tmp/flutter-wrap/{bin/cache,bin/internal,.git/objects/pack,.git/refs/heads,packages}`
  2. Copy/symlink flutter files: `cp /opt/flutter/bin/flutter /tmp/flutter-wrap/bin/flutter && chmod +x /tmp/flutter-wrap/bin/flutter`
  3. Symlink internal files: `for f in /opt/flutter/bin/internal/*; do [ "$(basename $f)" != "update_engine_version.sh" ] && ln -sf "$f" /tmp/flutter-wrap/bin/internal/$(basename $f) || cp "$f" /tmp/flutter-wrap/bin/internal/; done`
  4. Create writable cache: `cat /opt/flutter/bin/cache/engine.stamp > /tmp/flutter-wrap/bin/cache/engine.stamp && cat /opt/flutter/bin/cache/flutter_tools.stamp > /tmp/flutter-wrap/bin/cache/flutter_tools.stamp && touch /tmp/flutter-wrap/bin/cache/{engine.realm,lockfile,.dartignore} && ln -sf /opt/flutter/bin/cache/{dart-sdk,flutter_tools.snapshot} /tmp/flutter-wrap/bin/cache/ && mkdir /tmp/flutter-wrap/bin/cache/pkg`
  5. Create git repo mirroring opt/flutter: `cp /opt/flutter/.git/packed-refs /tmp/flutter-wrap/.git/packed-refs && cat /opt/flutter/.git/HEAD > /tmp/flutter-wrap/.git/HEAD && cp /opt/flutter/.git/config /tmp/flutter-wrap/.git/config && ln -sf /opt/flutter/.git/objects/pack/pack-*.idx /tmp/flutter-wrap/.git/objects/pack/ && ln -sf /opt/flutter/.git/objects/pack/pack-*.pack /tmp/flutter-wrap/.git/objects/pack/`
  5b. Copy version json: `cp /opt/flutter/bin/cache/flutter.version.json /tmp/flutter-wrap/bin/cache/flutter.version.json` (critical: without this, flutter reports version 0.0.0-unknown and pub get fails)
  6. Copy flutter_tools to writable location: `cp -r /opt/flutter/packages/flutter_tools /tmp/flutter-tools-rw`
  7. Set up packages: `for pkg in /opt/flutter/packages/*/; do [ "$(basename $pkg)" != "flutter_tools" ] && ln -sf "$pkg" /tmp/flutter-wrap/packages/$(basename $pkg); done && ln -sf /tmp/flutter-tools-rw /tmp/flutter-wrap/packages/flutter_tools`
  8. Run: `FLUTTER_PREBUILT_ENGINE_VERSION=$(cat /opt/flutter/bin/internal/engine.version) PUB_CACHE=/home/agent/.pub-cache /tmp/flutter-wrap/bin/flutter test --no-pub`
  9. Also run `dart pub get` first: `/opt/flutter/bin/cache/dart-sdk/bin/dart pub get` to populate the pub cache
- Source: create-code, 2026-07-10

## flutter analyze crashes without dev/ and examples/ dirs in wrapper
- Project: timelog_app
- Problem: `flutter analyze` crashes with "PathNotFoundException: Directory listing failed, path = '/tmp/flutter-wrap/dev/'" because `FlutterCommandRunner._gatherProjectPaths` lists `dev/` and `examples/` directories that don't exist in the wrapper.
- Solution: Create empty placeholder dirs: `mkdir -p /tmp/flutter-wrap/{dev,examples}` before running `flutter analyze`.
- Source: check-build, 2026-07-10

## flutter build linux fails: no ld/ld.lld in /usr/lib/llvm-18/bin
- Project: timelog_app
- Problem: `flutter build linux` looks for `ld.lld` or `ld` in the same directory as the real `clang++` binary (resolved via symlinks → `/usr/lib/llvm-18/bin/`). Neither linker exists there and /usr/lib/llvm-18/bin/ is read-only.
- Solution: Create wrapper shell scripts (not symlinks) for clang++/clang/llvm-ar and a real ld.lld script in `/tmp/clang-wrap/bin/`, then prepend it to PATH. The wrapper for `clang++` must be a script file, not a symlink, because Flutter resolves symlinks to find the parent directory. Run: `PATH=/tmp/clang-wrap/bin:$PATH FLUTTER_PREBUILT_ENGINE_VERSION=... PUB_CACHE=... /tmp/flutter-wrap/bin/flutter build linux --no-pub`.
  ```sh
  mkdir -p /tmp/clang-wrap/bin
  printf '#!/bin/bash\nexec /usr/lib/llvm-18/bin/clang++ "$@"\n' > /tmp/clang-wrap/bin/clang++
  printf '#!/bin/bash\nexec /usr/lib/llvm-18/bin/clang "$@"\n' > /tmp/clang-wrap/bin/clang
  printf '#!/bin/bash\nexec /usr/bin/ar "$@"\n' > /tmp/clang-wrap/bin/llvm-ar
  printf '#!/bin/bash\nexec /usr/bin/ld "$@"\n' > /tmp/clang-wrap/bin/ld.lld
  chmod +x /tmp/clang-wrap/bin/*
  ```
- Source: check-build, 2026-07-10

## flutter wrapper needs version json + pack files to detect SDK version
- Project: timelog_app
- Problem: After recreating the flutter wrapper, `flutter pub get` fails with "The current Flutter SDK version is 0.0.0-unknown" because: (a) HEAD in the fake git repo is a bare hash detached from a branch so `git describe` can't find the version, and (b) the pack objects aren't available.
- Solution: Copy `/opt/flutter/bin/cache/flutter.version.json` to `/tmp/flutter-wrap/bin/cache/flutter.version.json`. This file contains the pre-computed version and is read before git is consulted. Also copy `packed-refs` and `HEAD` from `/opt/flutter/.git/` and link the pack file from `/opt/flutter/.git/objects/pack/`.
  ```sh
  cp /opt/flutter/bin/cache/flutter.version.json /tmp/flutter-wrap/bin/cache/flutter.version.json
  cp /opt/flutter/.git/packed-refs /tmp/flutter-wrap/.git/packed-refs
  cat /opt/flutter/.git/HEAD > /tmp/flutter-wrap/.git/HEAD
  cp /opt/flutter/.git/config /tmp/flutter-wrap/.git/config
  ln -sf /opt/flutter/.git/objects/pack/pack-*.idx /tmp/flutter-wrap/.git/objects/pack/
  ln -sf /opt/flutter/.git/objects/pack/pack-*.pack /tmp/flutter-wrap/.git/objects/pack/
  ```
- Source: check-build, 2026-07-10

## flutter build linux fails: audioplayers_linux requires gstreamer dev headers
- Project: timelog_app
- Problem: `flutter build linux` fails with "The following required packages were not found: gstreamer-1.0" because `audioplayers_linux` CMakeLists.txt uses `pkg_check_modules(GSTREAMER REQUIRED gstreamer-1.0)` and the gstreamer dev package is not installed.
- Solution: Download and extract gstreamer dev packages manually (no root needed), fix their pkg-config prefix, then pass `PKG_CONFIG_PATH`, `LIBRARY_PATH`, and `LD_LIBRARY_PATH` to the build command. Packages needed: `libgstreamer1.0-dev`, `libgstreamer-plugins-base1.0-dev`, `libunwind-dev`, `libdw-dev`, `libelf-dev`, `liborc-0.4-dev`, `libdw1t64`, `libelf1t64`.
  ```sh
  mkdir -p /tmp/gst-extract /tmp/gst-dev
  cd /tmp/gst-extract
  apt-get download libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libunwind-dev libdw-dev libelf-dev liborc-0.4-dev libdw1t64 libelf1t64 libgstreamer1.0-0 libgstreamer-plugins-base1.0-0
  for f in *.deb; do dpkg-deb -x "$f" /tmp/gst-dev; done
  for pc in /tmp/gst-dev/usr/lib/x86_64-linux-gnu/pkgconfig/*.pc; do
    sed -i "s|^prefix=/usr$|prefix=/tmp/gst-dev/usr|g" "$pc"
  done
  ```
  Then build with:
  ```sh
  PATH=/tmp/clang-wrap/bin:$PATH \
    PKG_CONFIG_PATH=/tmp/gst-dev/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig \
    LIBRARY_PATH=/tmp/gst-dev/usr/lib/x86_64-linux-gnu \
    LD_LIBRARY_PATH=/tmp/gst-dev/usr/lib/x86_64-linux-gnu \
    FLUTTER_PREBUILT_ENGINE_VERSION=$(cat /opt/flutter/bin/internal/engine.version) \
    PUB_CACHE=/home/agent/.pub-cache \
    /tmp/flutter-wrap/bin/flutter build linux
  ```
- Source: check-build, 2026-07-10

## pub-cache missing packages referenced in .dart_tool/package_config.json cause cascading false compile errors
- Project: timelog_app
- Problem: `flutter analyze`/`flutter test` on files unrelated to riverpod (e.g. `edit_sheet.dart`) failed with `Target of URI doesn't exist: 'package:flutter_riverpod/...'`, `Undefined class 'ConsumerState'`, `widget`/`setState`/`mounted`/`context` undefined, plus unrelated errors in `boolean_selector`/`string_scanner` (`FileSpan isn't a type`). `.dart_tool/package_config.json` and `pubspec.lock` both referenced `flutter_riverpod-2.6.1`, but the package was simply absent from `/home/agent/.pub-cache/hosted/pub.dev/` (likely pruned/reset between agent runs) — so the analyzer treated the import as missing and cascaded undefined-identifier errors through the whole class.
- Solution: Before trusting confusing "undefined" errors that look like a real code bug, check whether the referenced package actually exists on disk: `ls /home/agent/.pub-cache/hosted/pub.dev/ | grep -i <pkg>`. If missing, run `/opt/flutter/bin/cache/dart-sdk/bin/dart pub get` to refetch (then check `git status` for the plugin-registrant side effects noted below and revert them before committing).
- Source: from-brief, 2026-07-11

## dart_check package does not exist on pub.dev
- Project: timelog_app
- Problem: The spec references `dart_check` as a Dart property-based testing library, but it does not exist on pub.dev and causes `pub get` to fail with "could not find package dart_check".
- Solution: Removed `dart_check` from pubspec.yaml. The property tests marked with `*` (optional) that use this library can be skipped or implemented with a different PBT library if needed.
- Source: create-code, 2026-07-10

## Runtime smoke-testing audioplayers_linux requires gstreamer1.0-plugins-base/-good, not just the lib*-0 runtime packages
- Project: timelog_app
- Problem: Confirmed the earlier "audioplayers_linux crashes on startup" memory entry, but with a correction: installing `libgstreamer1.0-0` and `libgstreamer-plugins-base1.0-0` (the `lib*-0` packages, which only ship core GStreamer *libraries* like libgstaudio/libgstvideo/libgstapp) is NOT enough to fix the `gst_element_factory_make("playbin", NULL)` crash. The `playbin` GStreamer *element* itself lives in `libgstplayback.so`, which ships in the separate `gstreamer1.0-plugins-base` package (element-scanner plugins, distinct from the `libgstreamer-plugins-base1.0-0` library package despite the near-identical name). Without it the app still aborts with `terminate called after throwing an instance of 'char const*'` even with GST_PLUGIN_SYSTEM_PATH pointed at a dir that has plugins-good elements.
- Solution: For a full runtime smoke test (not just `flutter build`), `apt-get download` + `dpkg-deb -x` into the shared `/tmp/gst-dev` prefix: `gstreamer1.0-plugins-base`, `gstreamer1.0-plugins-good`, and `liborc-0.4-0t64` (the versioned runtime `.so.0`, not just `-dev`'s unversioned symlink). Then run with both `GST_PLUGIN_SYSTEM_PATH=/tmp/gst-dev/usr/lib/x86_64-linux-gnu/gstreamer-1.0` and `LD_LIBRARY_PATH=/tmp/gst-dev/usr/lib/x86_64-linux-gnu` set, under `dbus-run-session -- xvfb-run -a`. Verify with `ldd` on `libgstplayback.so` that no deps are `not found` before assuming it'll load. A process that's still running after several seconds (rather than exiting immediately with SIGABRT/134) confirms the fix; `timeout N ... ; echo $?` reporting 124 (timeout) rather than 134 (SIGABRT) is the pass signal.
- Source: from-brief, 2026-07-11
