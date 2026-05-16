# Dashboard Poster Glitch Fix — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the Flutter/Skia Android image rendering glitch on posters shown in the Dashboard (Home) and Tracking List ("Minhas Listas") pages.

**Architecture:** Apply the existing `OverflowBox` workaround (12px extra height + `Alignment.bottomCenter` alignment) to the `TrackedMediaPoster` widget, which is the only poster widget missing this fix. The workaround shifts corrupted pixels outside the visible clip area. The pattern is already proven in 5 other poster/backdrop widgets.

**Tech Stack:** Flutter, Dart, CachedNetworkImage, OverflowBox

**Spec:** `docs/superpowers/specs/2026-05-16-fix-dashboard-poster-glitch-design.md`

---

### Task 1: Add OverflowBox workaround to TrackedMediaPoster

**Files:**
- Modify: `lib/features/tracking/widgets/tracked_media_poster.dart`

- [ ] **Step 1: Run existing tests to confirm no pre-existing failures**

    ```bash
    cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend
    flutter test test/features/tracking/widgets/tracked_media_poster_test.dart 2>/dev/null
    ```

    Expected output: tests pass (or the test file may not exist — if it doesn't, note it and proceed).

- [ ] **Step 2: Apply the OverflowBox fix**

    In `lib/features/tracking/widgets/tracked_media_poster.dart`, wrap the `CachedNetworkImage` inside an `OverflowBox` with 12px extra height and `Alignment.bottomCenter`, matching the pattern from `SeriesPoster`.

    **Change this block (around lines 29-39):**

    ```dart
    // BEFORE — no workaround
    ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: width,
        height: width * 1.5,
        color: Colors.grey[300],
        child: media.posterPath != null && media.posterPath!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: media.posterPath!,
                imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image),
              )
            : const Icon(Icons.broken_image),
      ),
    ),
    ```

    ```dart
    // AFTER — with OverflowBox workaround
    ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: width,
        height: width * 1.5,
        color: Colors.grey[300],
        child: media.posterPath != null && media.posterPath!.isNotEmpty
            ? OverflowBox(
                minWidth: width,
                maxWidth: width,
                minHeight: width * 1.5 + 12,
                maxHeight: width * 1.5 + 12,
                alignment: Alignment.bottomCenter,
                child: CachedNetworkImage(
                  imageUrl: media.posterPath!,
                  imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
                  width: width,
                  height: width * 1.5 + 12,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image),
                ),
              )
            : const Icon(Icons.broken_image),
      ),
    ),
    ```

- [ ] **Step 3: Run `dart analyze --fatal-infos` to verify no static issues**

    ```bash
    cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend
    dart analyze --fatal-infos
    ```

    Expected: no errors or warnings.

- [ ] **Step 4: Run full test suite to verify no regressions**

    ```bash
    cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend
    flutter test
    ```

    Expected: all tests pass.

- [ ] **Step 5: Run `make check` for final coverage gate**

    ```bash
    cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend
    make check
    ```

    Expected: analysis passes + coverage at 100% line and branch.

- [ ] **Step 6: Commit**

    ```bash
    cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend
    git add lib/features/tracking/widgets/tracked_media_poster.dart
    git commit -m "fix: reapply OverflowBox workaround to TrackedMediaPoster for Android image glitch

    TrackedMediaPoster was created after the original fix (49adb46) and
    did not receive the OverflowBox workaround. This caused the Android
    Flutter/Skia rendering glitch (corrupted pixels at the top of poster
    images) to reappear on the Dashboard and Tracking List pages.

    The fix wraps CachedNetworkImage in an OverflowBox with 12px extra
    height aligned to bottomCenter, pushing corrupted pixels outside the
    visible clip area — matching the pattern used in SeriesPoster,
    SeriesCard, MovieCard, SeriesDetailPage, and MovieDetailPage."
    ```
