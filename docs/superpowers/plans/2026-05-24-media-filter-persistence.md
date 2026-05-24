# Media Filter Persistence Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Persist the selected media filter (`MediaType.series` or `MediaType.movie`) in memory across existing screens that use `MediaTypeToggle`.

**Architecture:** Add a small Riverpod `StateProvider<MediaType>` as the single in-memory source of truth. `SeriesSearchPage` and `TrackingListPage` read the provider when building and write to it when the user changes the toggle, then use that value for search/load behavior.

**Tech Stack:** Flutter, Dart, Riverpod, GoRouter, flutter_test.

---

## File Structure

- Create: `lib/core/providers/media_filter_provider.dart`
  - Owns the shared in-memory selected media type provider.
- Modify: `lib/features/series/pages/series_search_page.dart`
  - Reads/writes the shared media type provider instead of local `_selectedType`.
- Modify: `lib/features/tracking/pages/tracking_list_page.dart`
  - Reads/writes the shared media type provider and loads tracking with the shared value.
- Modify: `test/features/series/pages/series_search_page_test.dart`
  - Adds RED/GREEN coverage for search screen reading and updating the shared provider.
- Modify: `test/features/tracking/pages/tracking_list_page_test.dart`
  - Adds RED/GREEN coverage for tracking screen loading with the shared provider.

## Task 1: Add shared provider and prove SeriesSearchPage uses it

**Files:**
- Create: `lib/core/providers/media_filter_provider.dart`
- Modify: `lib/features/series/pages/series_search_page.dart`
- Test: `test/features/series/pages/series_search_page_test.dart`

- [ ] **Step 1: Write the failing SeriesSearchPage test**

Add these imports to `test/features/series/pages/series_search_page_test.dart`:

```dart
import 'package:lorebase/core/providers/media_filter_provider.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
```

Add this test inside the `SeriesSearchPage` group, after `switching to Movies shows the movie hint`:

```dart
testWidgets('uses and updates shared media type selection', (tester) async {
  final container = ProviderContainer(
    overrides: [
      selectedMediaTypeProvider.overrideWith((ref) => MediaType.movie),
      seriesSearchViewModelProvider.overrideWith(() => FakeSearchVM()),
      movieSearchViewModelProvider.overrideWith(() => FakeMovieSearchVM()),
      authViewModelProvider.overrideWith(() => FakeAuthVM()),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(_wrap(container));
  await tester.pump();

  expect(find.text('Search movies...'), findsOneWidget);
  expect(container.read(selectedMediaTypeProvider), MediaType.movie);

  await tester.tap(find.text('Series'));
  await tester.pumpAndSettle();

  expect(find.text('Search series...'), findsOneWidget);
  expect(container.read(selectedMediaTypeProvider), MediaType.series);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/features/series/pages/series_search_page_test.dart --plain-name "uses and updates shared media type selection"
```

Expected: FAIL because `core/providers/media_filter_provider.dart` and `selectedMediaTypeProvider` do not exist yet.

- [ ] **Step 3: Create the shared provider**

Create `lib/core/providers/media_filter_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/tracking/data/models/media_type.dart';

final selectedMediaTypeProvider = StateProvider<MediaType>(
  (ref) => MediaType.series,
);
```

- [ ] **Step 4: Update SeriesSearchPage to use the provider**

In `lib/features/series/pages/series_search_page.dart`, add the import:

```dart
import '../../../../core/providers/media_filter_provider.dart';
```

Remove the local field from `_SeriesSearchPageState`:

```dart
MediaType _selectedType = MediaType.series;
```

Replace `_onTypeChanged` with:

```dart
void _onTypeChanged(MediaType type) {
  ref.read(selectedMediaTypeProvider.notifier).state = type;
  _searchController.clear();
  ref.read(seriesSearchViewModelProvider.notifier).clear();
  ref.read(movieSearchViewModelProvider.notifier).clear();
}
```

Replace `_onSearchChanged` with:

```dart
void _onSearchChanged(String query) {
  _debounceTimer?.cancel();
  final selectedType = ref.read(selectedMediaTypeProvider);
  if (query.length >= 2) {
    _debounceTimer = Timer(AppConstants.kSearchDebounceDuration, () {
      final currentType = ref.read(selectedMediaTypeProvider);
      if (currentType == MediaType.series) {
        ref.read(seriesSearchViewModelProvider.notifier).search(query);
      } else {
        ref.read(movieSearchViewModelProvider.notifier).search(query);
      }
    });
  } else if (query.isEmpty) {
    if (selectedType == MediaType.series) {
      ref.read(seriesSearchViewModelProvider.notifier).clear();
    } else {
      ref.read(movieSearchViewModelProvider.notifier).clear();
    }
  }
}
```

At the start of `build`, before `return Scaffold`, add:

```dart
final selectedType = ref.watch(selectedMediaTypeProvider);
```

In the `TextField` decoration, replace `_selectedType` with `selectedType`:

```dart
hintText: selectedType == MediaType.series
    ? context.t.search_hint
    : context.t.search_hint_movies,
```

In `MediaTypeToggle`, replace `_selectedType` with `selectedType`:

```dart
selectedType: selectedType,
```

In `_SearchResultsBody`, replace `_selectedType` with `selectedType`:

```dart
mediaType: selectedType,
```

- [ ] **Step 5: Run test to verify it passes**

Run:

```bash
flutter test test/features/series/pages/series_search_page_test.dart --plain-name "uses and updates shared media type selection"
```

Expected: PASS.

- [ ] **Step 6: Run the full SeriesSearchPage test file**

Run:

```bash
flutter test test/features/series/pages/series_search_page_test.dart
```

Expected: PASS for all tests in the file.

- [ ] **Step 7: Commit Task 1**

Run:

```bash
git add lib/core/providers/media_filter_provider.dart lib/features/series/pages/series_search_page.dart test/features/series/pages/series_search_page_test.dart
git commit -m "feat: share media filter selection in search"
```

## Task 2: Prove TrackingListPage loads with the shared provider

**Files:**
- Modify: `lib/features/tracking/pages/tracking_list_page.dart`
- Test: `test/features/tracking/pages/tracking_list_page_test.dart`

- [ ] **Step 1: Strengthen FakeTrackingListVM to capture media type**

In `test/features/tracking/pages/tracking_list_page_test.dart`, add this field to `FakeTrackingListVM`:

```dart
MediaType? lastMediaType;
```

Update `loadTracking` in `FakeTrackingListVM` to record the media type:

```dart
@override
Future<void> loadTracking({
  String? status,
  MediaType mediaType = MediaType.series,
}) async {
  loadTrackingCallCount++;
  lastMediaType = mediaType;
}
```

- [ ] **Step 2: Write the failing TrackingListPage test**

Add this import to `test/features/tracking/pages/tracking_list_page_test.dart`:

```dart
import 'package:lorebase/core/providers/media_filter_provider.dart';
```

Add this test inside the `TrackingListPage` group, after `switching to Movies shows movie empty state copy`:

```dart
testWidgets('loads initial tab with shared media type selection', (
  tester,
) async {
  final fakeVM = FakeTrackingListVM();
  final container = ProviderContainer(
    overrides: [
      selectedMediaTypeProvider.overrideWith((ref) => MediaType.movie),
      trackingListViewModelProvider.overrideWith(() => fakeVM),
      authViewModelProvider.overrideWith(() => FakeAuthVM()),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(_wrap(container));
  await tester.pump();

  expect(fakeVM.loadTrackingCallCount, 1);
  expect(fakeVM.lastMediaType, MediaType.movie);
  expect(find.text('No Want to Watch movies yet'), findsOneWidget);

  await tester.tap(find.text('Series'));
  await tester.pumpAndSettle();

  expect(container.read(selectedMediaTypeProvider), MediaType.series);
  expect(fakeVM.lastMediaType, MediaType.series);
});
```

- [ ] **Step 3: Run test to verify it fails**

Run:

```bash
flutter test test/features/tracking/pages/tracking_list_page_test.dart --plain-name "loads initial tab with shared media type selection"
```

Expected: FAIL because `TrackingListPage` still initializes and loads with local `MediaType.series`.

- [ ] **Step 4: Update TrackingListPage to use the provider**

In `lib/features/tracking/pages/tracking_list_page.dart`, add the import:

```dart
import '../../../../core/providers/media_filter_provider.dart';
```

Remove the local field from `_TrackingListPageState`:

```dart
MediaType _selectedType = MediaType.series;
```

Replace `_onMediaTypeChanged` with:

```dart
void _onMediaTypeChanged(MediaType type) {
  ref.read(selectedMediaTypeProvider.notifier).state = type;
  _loadTrackingForTab(_tabController.index);
}
```

Replace `_loadTrackingForTab` with:

```dart
void _loadTrackingForTab(int index) {
  final status = TrackingStatus.values[index].value;
  final selectedType = ref.read(selectedMediaTypeProvider);
  ref
      .read(trackingListViewModelProvider.notifier)
      .loadTracking(status: status, mediaType: selectedType);
}
```

At the start of `build`, after `final t = context.t;`, add:

```dart
final selectedType = ref.watch(selectedMediaTypeProvider);
```

In `MediaTypeToggle`, replace `_selectedType` with `selectedType`:

```dart
selectedType: selectedType,
```

In the empty state message, replace `_selectedType` with `selectedType`:

```dart
message: selectedType == MediaType.series
```

- [ ] **Step 5: Run test to verify it passes**

Run:

```bash
flutter test test/features/tracking/pages/tracking_list_page_test.dart --plain-name "loads initial tab with shared media type selection"
```

Expected: PASS.

- [ ] **Step 6: Run the full TrackingListPage test file**

Run:

```bash
flutter test test/features/tracking/pages/tracking_list_page_test.dart
```

Expected: PASS for all tests in the file.

- [ ] **Step 7: Commit Task 2**

Run:

```bash
git add lib/features/tracking/pages/tracking_list_page.dart test/features/tracking/pages/tracking_list_page_test.dart
git commit -m "feat: share media filter selection in tracking"
```

## Task 3: Cross-screen regression and final verification

**Files:**
- Modify: `test/features/series/pages/series_search_page_test.dart`

- [ ] **Step 1: Add a cross-screen regression test to SeriesSearchPage tests**

In `test/features/series/pages/series_search_page_test.dart`, add this import if it is not already present:

```dart
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';
import 'package:lorebase/features/tracking/pages/tracking_list_page.dart';
import 'package:lorebase/features/tracking/viewmodels/tracking_list_viewmodel.dart';
```

Add this fake class near the other fake viewmodels:

```dart
class FakeTrackingListVM extends TrackingListViewModel {
  MediaType? lastMediaType;

  @override
  AsyncValue<List<TrackedMediaModel>> build() => const AsyncValue.data([]);

  @override
  Future<void> loadTracking({
    String? status,
    MediaType mediaType = MediaType.series,
  }) async {
    lastMediaType = mediaType;
  }

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> refresh() async {}
}
```

Add this test inside the `SeriesSearchPage` group:

```dart
testWidgets('movie selection in search is reused by tracking page', (
  tester,
) async {
  final trackingVM = FakeTrackingListVM();
  late final GoRouter router;
  final container = ProviderContainer(
    overrides: [
      seriesSearchViewModelProvider.overrideWith(() => FakeSearchVM()),
      movieSearchViewModelProvider.overrideWith(() => FakeMovieSearchVM()),
      trackingListViewModelProvider.overrideWith(() => trackingVM),
      authViewModelProvider.overrideWith(() => FakeAuthVM()),
    ],
  );
  addTearDown(container.dispose);

  router = GoRouter(
    initialLocation: '/search',
    routes: [
      GoRoute(path: '/search', builder: (_, _) => const SeriesSearchPage()),
      GoRoute(path: '/tracking', builder: (_, _) => const TrackingListPage()),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TranslationProvider(
        child: MaterialApp.router(routerConfig: router),
      ),
    ),
  );
  await tester.pump();

  await tester.tap(find.text('Movies'));
  await tester.pumpAndSettle();

  router.go('/tracking');
  await tester.pumpAndSettle();

  expect(container.read(selectedMediaTypeProvider), MediaType.movie);
  expect(trackingVM.lastMediaType, MediaType.movie);
  expect(find.text('No Want to Watch movies yet'), findsOneWidget);
});
```

- [ ] **Step 2: Run test to verify it passes**

Run:

```bash
flutter test test/features/series/pages/series_search_page_test.dart --plain-name "movie selection in search is reused by tracking page"
```

Expected: PASS.

- [ ] **Step 3: Run all affected tests**

Run:

```bash
flutter test test/features/series/pages/series_search_page_test.dart test/features/tracking/pages/tracking_list_page_test.dart test/core/widgets/media_type_toggle_test.dart
```

Expected: PASS.

- [ ] **Step 4: Run static analysis**

Run:

```bash
dart analyze --fatal-infos
```

Expected: PASS with no errors or infos.

- [ ] **Step 5: Commit Task 3**

Run:

```bash
git add test/features/series/pages/series_search_page_test.dart test/features/tracking/pages/tracking_list_page_test.dart
git commit -m "test: cover cross-screen media filter persistence"
```

## Self-Review

- Spec coverage: Task 1 covers search reading/updating shared selection. Task 2 covers tracking reading/updating/loading with shared selection. Task 3 covers cross-screen persistence in one session and final verification.
- Placeholder scan: No TBD/TODO placeholders remain; each task includes exact files, code, commands, and expected results.
- Type consistency: The shared provider is consistently named `selectedMediaTypeProvider` and uses `StateProvider<MediaType>`. Test fakes use the existing `AsyncValue<List<TrackedMediaModel>>` tracking viewmodel signature.
