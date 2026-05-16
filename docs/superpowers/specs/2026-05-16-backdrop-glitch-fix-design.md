# Backdrop Glitch Fix — Design Spec

**Date:** 2026-05-16

## Problem

The movie detail page backdrop image shows corrupted pixels (glitch) in the top-left corner on Android. This is caused by the known Flutter/Skia Android rendering bug where decoded images have corrupted pixels at the top. The existing `OverflowBox` workaround (+12px height, `alignment: Alignment.bottomCenter`) pushes the corruption upward, but the `Stack(clipBehavior: Clip.none)` prevents the overflowed pixels from being clipped — they're painted and visible on Android.

The series detail page has the same code but hasn't been observed showing the glitch. This is a preventative fix applied to both pages.

## Solution

Wrap the backdrop `OverflowBox` in a `ClipRect` inside the `Positioned.fill`, mirroring the pattern used by the poster in the same `Stack` (which uses `ClipRRect`). The `ClipRect` clips the child to the Stack bounds, effectively hiding the 12px of overflowed corrupted pixels.

### Before

```dart
Positioned.fill(
  child: OverflowBox(
    alignment: Alignment.bottomCenter,
    child: CachedNetworkImage(...),
  ),
)
```

### After

```dart
Positioned.fill(
  child: ClipRect(
    child: OverflowBox(
      alignment: Alignment.bottomCenter,
      child: CachedNetworkImage(...),
    ),
  ),
)
```

## Affected Files

- `lib/features/movies/pages/movie_detail_page.dart` — add `ClipRect` wrapping backdrop `OverflowBox`
- `lib/features/series/pages/series_detail_page.dart` — add `ClipRect` wrapping backdrop `OverflowBox`

## No Side Effects

- The gradient overlay (`Positioned.fill` + `DecoratedBox`) is a separate Stack child — unaffected
- The poster (`Positioned(bottom: -30)`) uses its own `ClipRRect` — unaffected
- `Stack(clipBehavior: Clip.none)` is preserved — poster overflow at bottom and shadow still work
