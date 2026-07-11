# Memory

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
