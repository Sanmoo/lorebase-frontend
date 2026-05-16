# Backdrop Glitch Fix — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix Android backdrop image glitch by adding `ClipRect` wrapping to the backdrop `OverflowBox` in both movie and series detail pages.

**Architecture:** Wrap the backdrop `OverflowBox` inside the existing `Positioned.fill` with a `ClipRect`, matching the pattern already used by the poster in the same `Stack` (which uses `ClipRRect`). The `ClipRect` clips the overflowed 12px at the top, hiding corrupted Skia-decoded pixels on Android.

**Tech Stack:** Flutter, cached_network_image, flutter_test

---

### Task 1: Add ClipRect to backdrop in both detail pages

**Files:**

- Modify: `lib/features/movies/pages/movie_detail_page.dart` — wrap backdrop `OverflowBox` in `ClipRect`
- Modify: `lib/features/series/pages/series_detail_page.dart` — wrap backdrop `OverflowBox` in `ClipRect`
- Modify: `test/features/movies/pages/movie_detail_page_test.dart` — add test for ClipRect presence
- Modify: `test/features/series/pages/series_detail_page_test.dart` — add test for ClipRect presence

---

- [ ] **Step 1: Write failing test for movie detail page — ClipRect wraps backdrop OverflowBox**

```dart
// Add to movie_detail_page_test.dart, inside group('MovieDetailPage', () { ... })

testWidgets('backdrop OverflowBox is wrapped in ClipRect', (tester) async {
  final movie = _testMovie().copyWith(
    backdropPath: '/test-backdrop.jpg',
  );
  final detail = MovieDetailState(movie: movie, tracking: null);
  final container = ProviderContainer(overrides: [
    movieDetailViewModelProvider(7)
        .overrideWith(() => FakeMovieDetailVM(detail)),
    authViewModelProvider.overrideWith(() => FakeAuthVM()),
  ]);
  addTearDown(container.dispose);

  await tester.pumpWidget(_wrap(container));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  // Verify ClipRect exists as an ancestor of CachedNetworkImage (backdrop)
  // The backdrop uses OverflowBox wrapping CachedNetworkImage;
  // we verify ClipRect wraps that OverflowBox
  final clipRect = tester.widget<ClipRect>(
    find.ancestor(
      of: find.byWidgetPredicate(
        (w) => w is OverflowBox && w.maxHeight == 262,
      ),
      matching: find.byType(ClipRect),
    ),
  );
  expect(clipRect, isA<ClipRect>());
});
```

- [ ] **Step 2: Write failing test for series detail page — ClipRect wraps backdrop OverflowBox**

```dart
// Add to series_detail_page_test.dart, inside group('SeriesDetailPage', () { ... })

testWidgets('backdrop OverflowBox is wrapped in ClipRect', (tester) async {
  final series = _testSeries().copyWith(
    backdropPath: '/test-backdrop.jpg',
  );
  final detail = SeriesDetailState(series: series, tracking: null);
  final container = ProviderContainer(overrides: [
    seriesDetailViewModelProvider(1)
        .overrideWith(() => FakeDetailVM(data: detail)),
    authViewModelProvider.overrideWith(() => FakeAuthVM()),
  ]);
  addTearDown(container.dispose);

  await tester.pumpWidget(_wrap(container));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  // Verify ClipRect exists as an ancestor of CachedNetworkImage (backdrop)
  final clipRect = tester.widget<ClipRect>(
    find.ancestor(
      of: find.byWidgetPredicate(
        (w) => w is OverflowBox && w.maxHeight == 262,
      ),
      matching: find.byType(ClipRect),
    ),
  );
  expect(clipRect, isA<ClipRect>());
});
```

- [ ] **Step 3: Run tests to verify they fail**

Run:

```bash
flutter test test/features/movies/pages/movie_detail_page_test.dart test/features/series/pages/series_detail_page_test.dart
```

Expected: 2 FAIL — `find.ancestor` doesn't find `ClipRect` because it hasn't been added yet.

- [ ] **Step 4: Add ClipRect wrapping to movie detail backdrop**

In `lib/features/movies/pages/movie_detail_page.dart`, locate the backdrop `OverflowBox` inside `Positioned.fill`:

```dart
// BEFORE (line ~144-158):
                  if (hasBackdrop)
                    Positioned.fill(
                      child: OverflowBox(
                        minWidth: MediaQuery.of(context).size.width,
                        maxWidth: MediaQuery.of(context).size.width,
                        minHeight: 262,
                        maxHeight: 262,
                        alignment: Alignment.bottomCenter,
                        child: CachedNetworkImage(
                          imageUrl: movie.backdropPath!,
                          imageRenderMethodForWeb:
                              ImageRenderMethodForWeb.HttpGet,
                          width: MediaQuery.of(context).size.width,
                          height: 262,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
                    )

// AFTER:
                  if (hasBackdrop)
                    Positioned.fill(
                      child: ClipRect(
                        child: OverflowBox(
                          minWidth: MediaQuery.of(context).size.width,
                          maxWidth: MediaQuery.of(context).size.width,
                          minHeight: 262,
                          maxHeight: 262,
                          alignment: Alignment.bottomCenter,
                          child: CachedNetworkImage(
                            imageUrl: movie.backdropPath!,
                            imageRenderMethodForWeb:
                                ImageRenderMethodForWeb.HttpGet,
                            width: MediaQuery.of(context).size.width,
                            height: 262,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                        ),
                      ),
                    )
```

- [ ] **Step 5: Add ClipRect wrapping to series detail backdrop**

In `lib/features/series/pages/series_detail_page.dart`, locate the backdrop `OverflowBox` inside `Positioned.fill`:

```dart
// BEFORE (line ~195-209):
                  if (hasBackdrop)
                    Positioned.fill(
                      child: OverflowBox(
                        minWidth: MediaQuery.of(context).size.width,
                        maxWidth: MediaQuery.of(context).size.width,
                        minHeight: 262,
                        maxHeight: 262,
                        alignment: Alignment.bottomCenter,
                        child: CachedNetworkImage(
                          imageUrl: series.backdropPath!,
                          imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
                          width: MediaQuery.of(context).size.width,
                          height: 262,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
                    )

// AFTER:
                  if (hasBackdrop)
                    Positioned.fill(
                      child: ClipRect(
                        child: OverflowBox(
                          minWidth: MediaQuery.of(context).size.width,
                          maxWidth: MediaQuery.of(context).size.width,
                          minHeight: 262,
                          maxHeight: 262,
                          alignment: Alignment.bottomCenter,
                          child: CachedNetworkImage(
                            imageUrl: series.backdropPath!,
                            imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
                            width: MediaQuery.of(context).size.width,
                            height: 262,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                        ),
                      ),
                    )
```

- [ ] **Step 6: Run all detail page tests to verify they pass**

Run:

```bash
flutter test test/features/movies/pages/movie_detail_page_test.dart test/features/series/pages/series_detail_page_test.dart
```

Expected: ALL PASS — including the 2 new ClipRect tests.

- [ ] **Step 7: Run full test suite and analyze**

Run:

```bash
make check
```

Expected: All tests pass, analysis clean.

- [ ] **Step 8: Commit**

```bash
git add lib/features/movies/pages/movie_detail_page.dart \
        lib/features/series/pages/series_detail_page.dart \
        test/features/movies/pages/movie_detail_page_test.dart \
        test/features/series/pages/series_detail_page_test.dart
git commit -m "fix: add ClipRect to backdrop OverflowBox to prevent Android Skia glitch"
```
