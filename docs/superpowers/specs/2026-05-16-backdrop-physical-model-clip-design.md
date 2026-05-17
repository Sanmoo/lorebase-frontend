# Backdrop PhysicalModel Clip Fix — Design Spec

**Date:** 2026-05-16
**Status:** Approved
**Branch:** (to be created via writing-plans)

## Problem

The Android Skia rendering glitch (corrupted pixels at top-left of backdrop image) on movie/series detail pages required a workaround: rendering the image taller than the container via `OverflowBox` and clipping the overflow. The current fix uses `ClipRRect` + 48px overflow (298px image in 250px container), which eliminates the glitch but causes excessive vertical cropping — characters' heads are cut off.

## Root Cause Analysis

- `ClipRRect`/`ClipRect` apply clipping via Skia's `canvas.clipRRect()`. On Android, this clip can be bypassed or ineffective because the Skia decoding corruption occurs in the same rendering pipeline that performs the clip.
- The 48px overflow was needed because the clip wasn't fully effective; more overflow pushed corrupted pixels further above the viewport.

## Solution

Replace `ClipRRect` with `PhysicalModel(color: Colors.transparent, clipBehavior: Clip.hardEdge)`.

### Why PhysicalModel works

`PhysicalModel` creates a dedicated GPU composition layer. The clip is performed by the platform compositor (HWUI on Android), not by Skia's canvas clipping. This means:

1. The image is rasterized (decoded + scaled) within the child subtree
2. The rasterized result is then clipped by the GPU compositor layer
3. The Skia corruption is confined to the rasterization step; the compositor clips cleanly on the final texture

### Target parameters

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Overflow | 24px (274px image in 250px container) | 91% height visible, acceptable crop |
| Clip | `Clip.hardEdge` | Precise pixel clip, no anti-alias needed |
| Color | `Colors.transparent` | No shadow/elevation, transparent layer |

## Code Changes

Two files, identical change:

**`lib/features/movies/pages/movie_detail_page.dart`**
**`lib/features/series/pages/series_detail_page.dart`**

```dart
// Before:
Positioned.fill(
  child: ClipRRect(
    borderRadius: const BorderRadius.only(topLeft: Radius.circular(1)),
    key: const ValueKey('backdrop_clip'),
    child: SizedBox.expand(
      child: OverflowBox(
        alignment: Alignment.bottomCenter,
        minHeight: 298, maxHeight: 298,
        child: CachedNetworkImage(height: 298, ...),
      ),
    ),
  ),
)

// After:
Positioned.fill(
  child: PhysicalModel(
    color: Colors.transparent,
    clipBehavior: Clip.hardEdge,
    key: const ValueKey('backdrop_clip'),
    child: OverflowBox(
      alignment: Alignment.bottomCenter,
      minHeight: 274, maxHeight: 274,
      child: CachedNetworkImage(
        width: MediaQuery.of(context).size.width,
        height: 274,
        fit: BoxFit.cover, ...
      ),
    ),
  ),
)
```

Key changes:
1. `ClipRRect` → `PhysicalModel(color: Colors.transparent, clipBehavior: Clip.hardEdge)`
2. Remove `SizedBox.expand` (PhysicalModel gets bounds from Positioned.fill)
3. `298` → `274` (48px → 24px overflow)

## Testing

- Existing unit tests use `find.byKey(const ValueKey('backdrop_clip'))` → `findsOneWidget`. Key moves to `PhysicalModel`. Tests remain valid.
- Golden tests: 16 goldens. The 24px vs 48px difference may cause minor golden diff. If so, regenerate goldens.
- Manual test: install APK on Android device, verify no glitch on both movie and series detail pages.

## Rollback / Fallback

If PhysicalModel doesn't resolve the glitch on Android at 24px overflow, fallback is Option B: `RepaintBoundary` around the image to isolate rasterization into a separate texture, with 12px overflow.

## Scope

- `lib/features/movies/pages/movie_detail_page.dart` — backdrop section
- `lib/features/series/pages/series_detail_page.dart` — backdrop section
- `test/features/movies/pages/movie_detail_page_test.dart` — no test changes needed (key unchanged)
- `test/features/series/pages/series_detail_page_test.dart` — no test changes needed (key unchanged)
- `test/visual/` — may regenerate goldens if diff
