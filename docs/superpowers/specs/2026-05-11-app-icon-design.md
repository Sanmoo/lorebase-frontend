# App Icon Configuration — Android & Web

Date: 2026-05-11

## Goal

Replace the default Flutter app icon with a custom Lorebase icon (stylized "L" forming an eye with circuit lines, purple on white background) for both Android and web platforms.

## Source Image

- File: `~/Downloads/LorebaseIcon.jpeg` → staged to `assets/app_icon.png`
- Original: 816×1440 (portrait)
- Crop: center 816×816 (removes excess vertical whitespace)
- Background: white (~RGB 250,241,236)
- Foreground: purple (~RGB 48,16,80) with orange/gold accents (~RGB 240,176,112)
- Corners: rounded (the design has rounded-corner styling)

## Approach

Option B: `flutter_launcher_icons` for Android + separate script for web.

## Android — flutter_launcher_icons

### Config (`pubspec.yaml`)

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.1

flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/app_icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/app_icon.png"
  min_sdk_android: 21
```

### What gets generated

| File | Density | Size |
|------|---------|------|
| `mipmap-mdpi/ic_launcher.png` | mdpi | 48×48 |
| `mipmap-hdpi/ic_launcher.png` | hdpi | 72×72 |
| `mipmap-xhdpi/ic_launcher.png` | xhdpi | 96×96 |
| `mipmap-xxhdpi/ic_launcher.png` | xxhdpi | 144×144 |
| `mipmap-xxxhdpi/ic_launcher.png` | xxxhdpi | 192×192 |
| `mipmap-mdpi/ic_launcher_foreground.png` | mdpi | 48×48 |
| `mipmap-mdpi/ic_launcher_background.png` | mdpi | 48×48 |
| ... (same for all 5 densities) | | |
| `mipmap-anydpi-v26/ic_launcher.xml` | adaptive | XML layer-list |

## Web — Favicon + Manifest Icons

### Files to generate

| File | Size | Purpose |
|------|------|---------|
| `web/favicon.png` | 32×32 | Browser tab icon |
| `web/icons/Icon-192.png` | 192×192 | PWA manifest |
| `web/icons/Icon-512.png` | 512×512 | PWA manifest |
| `web/icons/Icon-maskable-192.png` | 192×192 | Maskable PWA (10% padding) |
| `web/icons/Icon-maskable-512.png` | 512×512 | Maskable PWA (10% padding) |

### Generation script

A Python (Pillow) or Dart script that:
1. Reads `assets/app_icon.png`
2. Resizes to each target size
3. For maskable variants: scales the source to 80% and centers on white background (safe zone for Android/PWA masking)

### manifest.json

Already references the correct paths — no changes needed.

## Pipeline

1. Copy source to staging, crop to square, convert to PNG → `assets/app_icon.png`
2. Add `assets/` to `pubspec.yaml` `flutter:` section
3. Add `flutter_launcher_icons` dev dependency and config
4. Run `dart run flutter_launcher_icons` (Android icons generated)
5. Run web icon generation script
6. Remove old default icons (existing mipmap pngs will be replaced by step 4)

## Files to modify

| File | Action |
|------|--------|
| `pubspec.yaml` | Add `flutter_launcher_icons` dep + config, add `assets/` |
| `assets/app_icon.png` | **New** — cropped source icon |
| `web/favicon.png` | **Replace** — generated |
| `web/icons/Icon-*.png` | **Replace** — 4 files, generated |
| `android/.../mipmap-*/ic_launcher*.png` | **Replace** — ~15 files, auto-generated |

## Out of scope

- iOS / macOS — no platform directories exist
- Adaptive icon animation / theme switching
- Play Store listing graphics (feature graphic, screenshots)
