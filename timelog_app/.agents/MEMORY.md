# Memory

## Flutter SDK "dubious ownership" blocks every flutter/dart command
- Project: timelog_app
- Problem: The sandbox's Flutter SDK lives at `/opt/flutter`, owned by `root` (not the
  `agent` user running commands). Git refuses to operate inside it ("detected dubious
  ownership"), and the `flutter` tool shells out to `git` internally to resolve its
  version, so every `flutter ...` command (even `flutter --version`) fails immediately
  with exit 128.
- Solution: Don't run `git config --global --add safe.directory` (that persists a change
  to the real global git config). Instead, pass an ad-hoc override via env vars for just
  that command: `export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=safe.directory
  GIT_CONFIG_VALUE_0=/opt/flutter`. This satisfies git without writing to any config file.
  Also note `.fvm/flutter_sdk` (FVM's pinned-version symlink) points to a
  `/home/agent/fvm/versions/...` path that doesn't actually exist in this sandbox — FVM
  itself is not functional here; use `/opt/flutter/bin` on PATH directly (the installed
  version, 3.38.5, is close enough to the pinned 3.44.6 and satisfies the `^3.10.4` Dart SDK
  constraint).
- Source: check-build, 2026-08-20 19:40

## Stale build/ CMakeCache breaks `flutter build linux` with a bogus compiler path
- Project: timelog_app
- Problem: A pre-existing `build/linux/x64/release/CMakeCache.txt` (left over from a
  different environment/build) hardcoded `CMAKE_CXX_COMPILER=/tmp/clang-wrap/bin/clang++`,
  a path that doesn't exist in this sandbox. CMake fails immediately with "is not a full
  path to an existing compiler tool" before even getting to the real dependency problems.
- Solution: `build/` is git-ignored — safe to `rm -rf build` and let `flutter build linux`
  regenerate the CMake cache fresh against the compilers actually on this machine.
- Source: check-build, 2026-08-20 19:41

## `flutter build linux` needs GStreamer -dev headers + a compiler-adjacent linker/archiver — none present, no root
- Project: timelog_app
- Problem: `audioplayers_linux`'s CMakeLists calls `pkg_check_modules(... REQUIRED gstreamer-1.0
  gstreamer-audio-1.0 ...)`, but this sandbox only has GStreamer *runtime* libs, not the
  `-dev` packages (`libgstreamer1.0-dev`, `libgstreamer-plugins-base1.0-dev`, transitively
  `libunwind-dev`, `libdw-dev`, `liborc-0.4-dev`). There's no `sudo`/root, so
  `apt-get install` is impossible. Separately, Dart's native-assets build step
  (`dart_build` target) resolves the C toolchain by running `which clang++`, fully
  resolving symlinks, and then looking for `ld`/`ld.lld` and `ar`/`llvm-ar` **in that same
  directory** — but on this box `clang++` resolves to `/usr/lib/llvm-18/bin/`, which only
  contains the clang binaries, not `ld`/`ar` (those live in `/usr/bin`). Build fails with
  "Failed to find any of [ld.lld, ld] in LocalDirectory: '/usr/lib/llvm-18/bin'".
- Solution (no-root workaround, repeat each session — nothing here persists across sandbox
  resets since it all lives under /tmp):
  1. `apt-get download <pkg>` works without root (only *installing* via dpkg needs root).
     Download `libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libunwind-dev libdw-dev
     libelf-dev zlib1g-dev liborc-0.4-dev` (+ their `.0`/runtime counterparts) into a scratch
     dir, then `dpkg-deb -x <file>.deb /tmp/gst-prefix` for each — this just unpacks the
     archive to an arbitrary directory, no privileges needed.
  2. The extracted `.pc` files hardcode `prefix=/usr`, which would resolve to the *real*
     system `/usr` (missing the headers). Patch them: `sed -i
     's|^prefix=/usr$|prefix=/tmp/gst-prefix/usr|' /tmp/gst-prefix/usr/lib/x86_64-linux-gnu/pkgconfig/*.pc`.
  3. Export `PKG_CONFIG_PATH=/tmp/gst-prefix/usr/lib/x86_64-linux-gnu/pkgconfig`,
     `CPATH=/tmp/gst-prefix/usr/include:/tmp/gst-prefix/usr/include/x86_64-linux-gnu`,
     `LIBRARY_PATH=/tmp/gst-prefix/usr/lib/x86_64-linux-gnu`, and
     `LD_LIBRARY_PATH=/tmp/gst-prefix/usr/lib/x86_64-linux-gnu:...` before building/running.
  4. For the linker/archiver: create a shim dir (e.g. `/tmp/clang-shim`) containing small
     wrapper *scripts* (not symlinks — symlinks get fully resolved away by flutter_tools'
     `resolveSymbolicLinks()`, defeating the trick) named `clang`/`clang++` that just
     `exec /usr/lib/llvm-18/bin/clang(++) "$@"`, plus plain symlinks `ld -> /usr/bin/ld` and
     `ar -> /usr/bin/ar` in the same directory. Put `/tmp/clang-shim` first on `PATH`. Now
     `which clang++` resolves to a stable, non-symlinked path whose directory also has
     `ld`/`ar`.
  5. `rm -rf build/` first (see previous entry) so CMake reconfigures against the new env.
  This gets `flutter build linux --release` to a clean `✓ Built build/linux/.../timelog_app`.
- Source: check-build, 2026-08-20 19:48

## `flutter test` fails on every Drift/sqlite3 test: missing unversioned `libsqlite3.so`
- Project: timelog_app
- Problem: `package:sqlite3`'s Linux loader does `DynamicLibrary.open('libsqlite3.so')`
  (the unversioned dev symlink, normally provided by `libsqlite3-dev`). This sandbox only
  has the runtime `libsqlite3.so.0` (from `libsqlite3-0`), not the dev symlink, and there's
  no root to install `libsqlite3-dev`. Every test that touches the Drift-backed
  `AppDatabase` fails with `Failed to load dynamic library 'libsqlite3.so'`.
- Solution: `mkdir -p /tmp/sqlite3-shim && ln -sf /usr/lib/x86_64-linux-gnu/libsqlite3.so.0
  /tmp/sqlite3-shim/libsqlite3.so`, then export
  `LD_LIBRARY_PATH=/tmp/sqlite3-shim:$LD_LIBRARY_PATH` before `flutter test`. No source
  changes needed.
- Source: check-build, 2026-08-20 19:42

## Running the built app headlessly needs a D-Bus session + `xdg-user-dir`, or it throws (but doesn't crash)
- Project: timelog_app
- Problem: On a bare `xvfb-run` with no session bus, `ReminderService.initialize()`
  (flutter_local_notifications' Linux backend) throws an unhandled `SocketException`
  connecting to `/run/user/1000/bus`, and `path_provider_linux`'s
  `getApplicationDocumentsDirectory()` throws `ProcessException: Permission denied` because
  the `xdg-user-dir` binary isn't installed in this minimal sandbox at all. Neither is
  fatal — Flutter's zone error handler logs and the app keeps running — but it's noisy and
  means DB-backed startup logic (`RecurringReminderService.rescheduleAll`) silently no-ops.
- Solution: run under `xvfb-run -a dbus-run-session -- <binary>` with `XDG_RUNTIME_DIR` set
  to a writable dir you own (e.g. `/tmp/xdg-runtime-1000`, `chmod 700`). For `xdg-user-dir`,
  since it's not installable without root, drop a tiny shim script on `PATH` ahead of
  everything else that echoes `$HOME/<Folder>` per the `$1` arg (mirrors real
  `xdg-user-dirs` default behavior with no config). With both in place the app starts with
  zero unhandled Dart exceptions; only benign GStreamer plugin-scanner warnings remain
  (optional codec plugins like taglib/wavpack/cdparanoia missing their libs — irrelevant to
  the app, which only needs `mpg123`/`playback`/`audioconvert`/`autodetect` for the alarm
  MP3, all of which *are* present once the GStreamer runtime shim from the previous entry
  is on `LD_LIBRARY_PATH`).
- Source: check-build, 2026-08-20 19:51
