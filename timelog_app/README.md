# timelog_app

A countdown timer app with time tracking capabilities built with Flutter.

## Requirements

- Flutter SDK (Dart ^3.10.4)
- For Linux desktop: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`, `libgstreamer1.0-dev`, `libgstreamer-plugins-base1.0-dev`

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
