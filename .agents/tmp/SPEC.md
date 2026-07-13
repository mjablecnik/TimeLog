# App Icon Replacement — Specification

## Overview

Replace the default Flutter app icon with a custom clock/alarm icon on Android and iOS. The icon should be visually consistent across both platforms and make the app easy to identify on the home screen.

## Goals

1. Replace the default Flutter icon with a clock-themed icon (alarm clock or clock face)
2. Apply the same icon design to both Android and iOS
3. Generate all required sizes for each platform
4. Keep the icon simple and recognizable at small sizes

## Technical Approach

Use the `flutter_launcher_icons` package to generate platform-specific icon assets from a single source image. This is the standard Flutter approach and handles all size variants automatically.

### Source Icon

Generate a 1024×1024 PNG icon programmatically using ImageMagick (available in the environment). The design will be:
- A solid rounded-square background in the app's primary color (dark blue/indigo from the app theme)
- A white clock face with hour/minute hands, representing a time-tracking app
- Clean, flat design that reads well at small sizes

### Platform Targets

**Android:**
- Adaptive icon with foreground/background layers (modern Android)
- Legacy square icon fallback (older Android)
- Sizes: mipmap-mdpi (48×48) through mipmap-xxxhdpi (192×192)

**iOS:**
- Single 1024×1024 source, sized down by Xcode asset catalog
- All required sizes defined in `Contents.json` (20×20 through 1024×1024 at various scales)

### Tool: `flutter_launcher_icons`

Add as a dev dependency and configure in `pubspec.yaml` (or a separate `flutter_launcher_icons.yaml`). The package generates all platform-specific assets from one source image.

Configuration:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#1a1a2e"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

## File Structure

New/modified files:
```
timelog_app/
├── assets/icon/
│   ├── app_icon.png              (1024×1024 full icon for iOS + legacy Android)
│   └── app_icon_foreground.png   (1024×1024 foreground for Android adaptive)
├── pubspec.yaml                  (add flutter_launcher_icons dev dep + config)
├── android/app/src/main/res/
│   ├── mipmap-mdpi/ic_launcher.png       (regenerated)
│   ├── mipmap-hdpi/ic_launcher.png       (regenerated)
│   ├── mipmap-xhdpi/ic_launcher.png      (regenerated)
│   ├── mipmap-xxhdpi/ic_launcher.png     (regenerated)
│   └── mipmap-xxxhdpi/ic_launcher.png    (regenerated)
├── ios/Runner/Assets.xcassets/AppIcon.appiconset/
│   ├── Icon-App-*.png            (all sizes regenerated)
│   └── Contents.json             (unchanged structure)
```

## Constraints

- The icon must look good at all sizes (20×20 through 1024×1024)
- iOS does not support transparent backgrounds — use a solid fill
- Android adaptive icons use separate foreground/background — foreground should have padding (safe zone is 66% of canvas)
- No text in the icon — it won't be legible at small sizes
- Icon should match the app's visual identity (dark theme, clean design)

## Implementation Notes

- ImageMagick (`convert` / `magick`) will be used to generate the source PNG since we're in a headless environment
- The clock design uses SVG-like drawing primitives available in ImageMagick
- After generating the source icon, `flutter_launcher_icons` handles all resizing and platform placement
- The icon does NOT need rounded corners baked in — both Android and iOS apply their own masking
