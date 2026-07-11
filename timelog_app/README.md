# timelog_app

A countdown timer app with time tracking capabilities built with Flutter.

## Requirements

- Flutter SDK (Dart ^3.10.4)
- For Linux desktop:
  - Build: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`, `libgstreamer1.0-dev`, `libgstreamer-plugins-base1.0-dev`
  - Runtime (audio playback): `gstreamer1.0-plugins-base` and `gstreamer1.0-plugins-good` must also be installed — the `-dev` packages above only provide headers, not the GStreamer plugin binaries (e.g. `playbin`) that `audioplayers` needs at runtime. Without them, the app crashes on startup when it tries to play the alarm sound.

## Setup

Install Flutter dependencies:

```sh
flutter pub get
```

## Running

```sh
flutter run -d linux
```

## Building

Build for Linux desktop:

```sh
flutter build linux
```

The output binary is at `build/linux/x64/release/bundle/timelog_app`.

## Code generation

This project uses `build_runner` for code generation (Drift, Freezed, Riverpod). Run after changing annotated files:

```sh
dart run build_runner build --delete-conflicting-outputs
```

## Tests

```sh
flutter test
```

## Linting

```sh
flutter analyze
```
