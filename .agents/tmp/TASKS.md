# Tasks — App Icon Replacement

- [x] 1. [HIGH] Create `assets/icon/` directory and generate the 1024×1024 `app_icon.png` (full icon: dark background + white clock design) using ImageMagick
- [x] 2. [HIGH] Generate `assets/icon/app_icon_foreground.png` (1024×1024, transparent background, white clock in the 66% safe zone) for Android adaptive icons
- [x] 3. [HIGH] Add `flutter_launcher_icons` as a dev dependency in `pubspec.yaml` and add the `flutter_launcher_icons:` configuration section
- [x] 4. [HIGH] Run `dart run flutter_launcher_icons` to generate all platform-specific icon assets for Android and iOS
- [x] 5. [MEDIUM] Verify the generated Android icons exist in all `mipmap-*` directories (`ic_launcher.png`) and look correct (not corrupted/blank)
- [x] 6. [MEDIUM] Verify the generated iOS icons exist in `Assets.xcassets/AppIcon.appiconset/` with all required sizes and `Contents.json` is valid
- [ ] 7. [LOW] Clean up any temporary files and ensure `assets/icon/` source images are committed (not gitignored)
