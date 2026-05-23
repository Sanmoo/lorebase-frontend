# Series Search Detail URL Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Opening a series detail from search should navigate to `/series/:tmdbId` with the browser/app URL reflecting the detail route.

**Architecture:** Keep the existing `/series/:tmdbId` GoRouter route and the existing `SeriesCard` tap callback. Change only the search result navigation from stack-based `context.push()` to location-changing `context.go()`, and cover it with a widget navigation test.

**Tech Stack:** Flutter 3.27, Dart, GoRouter, Riverpod provider overrides, flutter_test.

---

## File Structure

- Modify `test/features/series/pages/series_search_page_test.dart`
  - Add a route-aware test wrapper that includes `/search` and `/series/:tmdbId`.
  - Add a failing widget test proving tapping a series search result changes the router location to `/series/1` and displays a detail-route sentinel.
- Modify `lib/features/series/pages/series_search_page.dart`
  - Replace `context.push('/series/${item.tmdbId}')` with `context.go('/series/${item.tmdbId}')` for series results only.

---

### Task 1: Add failing navigation test

**Files:**
- Modify: `test/features/series/pages/series_search_page_test.dart`

- [ ] **Step 1: Add a route-aware test helper**

In `test/features/series/pages/series_search_page_test.dart`, below the existing `_wrap` helper, add this helper:

```dart
Widget _wrapWithSeriesDetailRoute(
  ProviderContainer container, {
  required GoRouter router,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: TranslationProvider(
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}
```

- [ ] **Step 2: Add the failing test**

In the `SeriesSearchPage` group in `test/features/series/pages/series_search_page_test.dart`, add this test near the existing tap/navigation test:

```dart
testWidgets('tapping series item updates location to series detail route', (
  tester,
) async {
  final results = [const SeriesModel(tmdbId: 1, title: 'Breaking Bad')];
  final fakeVM = FakeSearchVM(state: AsyncValue.data(results));
  final container = createContainer(fakeVM);
  addTearDown(container.dispose);

  late final GoRouter router;
  router = GoRouter(
    initialLocation: '/search',
    routes: [
      GoRoute(path: '/search', builder: (_, _) => const SeriesSearchPage()),
      GoRoute(
        path: '/series/:tmdbId',
        builder: (_, state) => Text(
          'Series detail ${state.pathParameters['tmdbId']}',
          textDirection: TextDirection.ltr,
        ),
      ),
    ],
  );

  await tester.pumpWidget(_wrapWithSeriesDetailRoute(container, router: router));
  await tester.pump();

  await tester.tap(find.text('Breaking Bad'));
  await tester.pumpAndSettle();

  expect(router.routeInformationProvider.value.uri.path, '/series/1');
  expect(find.text('Series detail 1'), findsOneWidget);
});
```

- [ ] **Step 3: Run the focused test and verify RED**

Run:

```bash
flutter test test/features/series/pages/series_search_page_test.dart --plain-name 'tapping series item updates location to series detail route'
```

Expected: FAIL because `context.push()` displays the detail route but preserves the current route information path as `/search`, or otherwise fails the path assertion. If the test errors due to a test harness typo, fix the test harness and re-run until it fails for the navigation-location assertion.

---

### Task 2: Implement minimal navigation fix

**Files:**
- Modify: `lib/features/series/pages/series_search_page.dart`
- Test: `test/features/series/pages/series_search_page_test.dart`

- [ ] **Step 1: Change series result navigation**

In `lib/features/series/pages/series_search_page.dart`, replace the series result tap callback:

```dart
onTap: item.tmdbId != 0
    ? () => context.push('/series/${item.tmdbId}')
    : null,
```

with:

```dart
onTap: item.tmdbId != 0
    ? () => context.go('/series/${item.tmdbId}')
    : null,
```

Do not change movie navigation in this task.

- [ ] **Step 2: Run the focused test and verify GREEN**

Run:

```bash
flutter test test/features/series/pages/series_search_page_test.dart --plain-name 'tapping series item updates location to series detail route'
```

Expected: PASS.

- [ ] **Step 3: Run the full affected test file**

Run:

```bash
flutter test test/features/series/pages/series_search_page_test.dart
```

Expected: PASS for all tests in the file.

- [ ] **Step 4: Run static checks for touched files**

Run LSP diagnostics on touched files:

```text
lsp_diagnostics(filePaths: ['lib/features/series/pages/series_search_page.dart', 'test/features/series/pages/series_search_page_test.dart'], severity: 'all')
```

Then run:

```bash
dart analyze --fatal-infos
```

Expected: no errors. If warnings or infos appear in touched code, fix them.

---

## Self-Review

- Spec coverage: The plan covers the expected `/series/:tmdbId` URL after opening a series result from search, preserves deep-link route usage, and adds a navigation test.
- Placeholder scan: No TBD/TODO/implement-later placeholders remain.
- Type consistency: The test uses existing `SeriesModel`, `FakeSearchVM`, `ProviderContainer`, `GoRouter`, and `SeriesSearchPage` names already present in the test file.
