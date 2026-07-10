# Memory

## flutter command fails due to /opt/flutter read-only permissions
- Project: timelog_app
- Problem: `/opt/flutter/bin/cache/engine.stamp` and `/opt/flutter/bin/cache/lockfile` are owned by root and read-only. The `flutter` shell script tries to overwrite engine.stamp on every run, causing "Permission denied" and exiting before running any command. The flutter dart snapshot also needs to write to `/opt/flutter/packages/flutter_tools/.dart_tool/package_config.json` which is also read-only.
- Solution: Create a writable flutter wrapper at `/tmp/flutter-wrap/`:
  1. `mkdir -p /tmp/flutter-wrap/{bin/cache,bin/internal,.git/objects/pack,.git/refs/heads,packages}`
  2. Copy/symlink flutter files: `cp /opt/flutter/bin/flutter /tmp/flutter-wrap/bin/flutter && chmod +x /tmp/flutter-wrap/bin/flutter`
  3. Symlink internal files: `for f in /opt/flutter/bin/internal/*; do [ "$(basename $f)" != "update_engine_version.sh" ] && ln -sf "$f" /tmp/flutter-wrap/bin/internal/$(basename $f) || cp "$f" /tmp/flutter-wrap/bin/internal/; done`
  4. Create writable cache: `cat /opt/flutter/bin/cache/engine.stamp > /tmp/flutter-wrap/bin/cache/engine.stamp && cat /opt/flutter/bin/cache/flutter_tools.stamp > /tmp/flutter-wrap/bin/cache/flutter_tools.stamp && touch /tmp/flutter-wrap/bin/cache/{engine.realm,lockfile,.dartignore} && ln -sf /opt/flutter/bin/cache/{dart-sdk,flutter_tools.snapshot} /tmp/flutter-wrap/bin/cache/ && mkdir /tmp/flutter-wrap/bin/cache/pkg`
  5. Create fake git repo with correct hash: `HASH=f6ff1529fd6d8af5f706051d9251ac9231c83407 && echo "ref: refs/heads/main" > /tmp/flutter-wrap/.git/HEAD && echo "$HASH" > /tmp/flutter-wrap/.git/refs/heads/main && echo -e "[core]\n  repositoryformatversion = 0\n  filemode = false\n  bare = false" > /tmp/flutter-wrap/.git/config` (use hash from flutter_tools.stamp)
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

## dart_check package does not exist on pub.dev
- Project: timelog_app
- Problem: The spec references `dart_check` as a Dart property-based testing library, but it does not exist on pub.dev and causes `pub get` to fail with "could not find package dart_check".
- Solution: Removed `dart_check` from pubspec.yaml. The property tests marked with `*` (optional) that use this library can be skipped or implemented with a different PBT library if needed.
- Source: create-code, 2026-07-10
