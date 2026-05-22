# Global Media Type Filter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the selected media type globally consistent between Buscar and Minhas Listas for the current app session.

**Architecture:** Add one session-scoped Riverpod `StateProvider<MediaType>` with initial value `MediaType.series`. Refactor `SeriesSearchPage` and `TrackingListPage` to read/write this provider instead of maintaining separate local `_selectedType` fields.

**Tech Stack:** Flutter 3.27, Dart, Riverpod, GoRouter, Flutter widget tests.

---

## File Structure

- Create: `lib/core/providers/media_type_filter_provider.dart`
  - Owns the session-scoped selected media type provider.
- Modify: `lib/features/series/pages/series_search_page.dart`
  - Replaces local `_selectedType` state with `selectedMediaTypeProvider`.
- Modify: `lib/features/tracking/pages/tracking_list_page.dart`
  - Replaces local `_selectedType` state with `selectedMediaTypeProvider` and uses provider value for initial/reload calls.
- Modify: `test/features/series/pages/series_search_page_test.dart`
  - Adds/updates coverage for provider-backed Buscar behavior.
- Modify: `test/features/tracking/pages/tracking_list_page_test.dart`
  - Adds/updates coverage for provider-backed Minhas Listas behavior.
- Create: `test/core/providers/media_type_filter_provider_test.dart`
  - Verifies initial provider value and mutability.
- Create: `test/features/media_type_filter_cross_screen_test.dart`
  - Covers the reported cross-screen behavior with one shared `ProviderContainer`.

---

### Task 1: Add the Global Provider

**Files:**
- Create: `lib/core/providers/media_type_filter_provider.dart`
- Create: `test/core/providers/media_type_filter_provider_test.dart`

- [ ] **Step 1: Write the failing provider test**

Create `test/core/providers/media_type_filter_provider_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/providers/media_type_filter_provider.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';

void main() {
  group('selectedMediaTypeProvider', () {
    test('defaults to series for a new app session', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedMediaTypeProvider), MediaType.series);
    });

    test('can be updated during the current app session', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedMediaTypeProvider.notifier).state = MediaType.movie;

      expect(container.read(selectedMediaTypeProvider), MediaType.movie);
    });
  });
}
```

- [ ] **Step 2: Run the provider test to verify it fails**

Run:

```bash
flutter test test/core/providers/media_type_filter_provider_test.dart
```

Expected: FAIL because `package:lorebase/core/providers/media_type_filter_provider.dart` does not exist.

- [ ] **Step 3: Implement the provider**

Create `lib/core/providers/media_type_filter_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/tracking/data/models/media_type.dart';

final selectedMediaTypeProvider = StateProvider<MediaType>(
  (ref) => MediaType.series,
);
```

- [ ] **Step 4: Run the provider test to verify it passes**

Run:

```bash
flutter test test/core/providers/media_type_filter_provider_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

Run:

```bash
git add lib/core/providers/media_type_filter_provider.dart test/core/providers/media_type_filter_provider_test.dart
git commit -m "feat: add media type filter provider"
```

---

### Task 2: Refactor Buscar to Use the Global Provider

**Files:**
- Modify: `lib/features/series/pages/series_search_page.dart`
- Modify: `test/features/series/pages/series_search_page_test.dart`

- [ ] **Step 1: Add a failing test for provider-backed initial selection**

In `test/features/series/pages/series_search_page_test.dart`, add this import:

```dart
import 'package:lorebase/core/providers/media_type_filter_provider.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
```

Add this test inside `group('SeriesSearchPage', () { ... })`:

```dart
testWidgets('uses the shared media type provider for initial selection', (
  tester,
) async {
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
}
```

- [ ] **Step 2: Run the new Buscar test to verify it fails**

Run:

```bash
flutter test test/features/series/pages/series_search_page_test.dart --plain-name "uses the shared media type provider for initial selection"
```

Expected: FAIL because `SeriesSearchPage` still initializes local state to `MediaType.series`.

- [ ] **Step 3: Refactor `SeriesSearchPage`**

In `lib/features/series/pages/series_search_page.dart`, add this import:

```dart
import '../../../../core/providers/media_type_filter_provider.dart';
```

Remove this field from `_SeriesSearchPageState`:

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

At the start of `build`, add:

```dart
final selectedType = ref.watch(selectedMediaTypeProvider);
```

In `build`, replace each `_selectedType` reference with `selectedType`.

In `_onSearchChanged`, replace each `_selectedType` reference with:

```dart
ref.read(selectedMediaTypeProvider)
```

The intended `_onSearchChanged` body is:

```dart
void _onSearchChanged(String query) {
  _debounceTimer?.cancel();
  final selectedType = ref.read(selectedMediaTypeProvider);
  if (query.length >= 2) {
    _debounceTimer = Timer(AppConstants.kSearchDebounceDuration, () {
      if (selectedType == MediaType.series) {
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

- [ ] **Step 4: Run Buscar tests**

Run:

```bash
flutter test test/features/series/pages/series_search_page_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

Run:

```bash
git add lib/features/series/pages/series_search_page.dart test/features/series/pages/series_search_page_test.dart
git commit -m "feat: use shared media type in search"
```

---

### Task 3: Refactor Minhas Listas to Use the Global Provider

**Files:**
- Modify: `lib/features/tracking/pages/tracking_list_page.dart`
- Modify: `test/features/tracking/pages/tracking_list_page_test.dart`

- [ ] **Step 1: Add a failing test for provider-backed initial tracking load**

In `test/features/tracking/pages/tracking_list_page_test.dart`, add this import:

```dart
import 'package:lorebase/core/providers/media_type_filter_provider.dart';
```

Update `FakeTrackingListVM` by adding a field:

```dart
MediaType? lastMediaType;
```

Update `loadTracking` to record the passed media type:

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

Add this test inside `group('TrackingListPage', () { ... })`:

```dart
testWidgets('uses the shared media type provider for initial load', (
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

  expect(fakeVM.lastMediaType, MediaType.movie);
  expect(find.text('No Want to Watch movies yet'), findsOneWidget);
}
```

- [ ] **Step 2: Run the new tracking test to verify it fails**

Run:

```bash
flutter test test/features/tracking/pages/tracking_list_page_test.dart --plain-name "uses the shared media type provider for initial load"
```

Expected: FAIL because `TrackingListPage` still uses local `MediaType.series` for initial load.

- [ ] **Step 3: Refactor `TrackingListPage`**

In `lib/features/tracking/pages/tracking_list_page.dart`, add this import:

```dart
import '../../../../core/providers/media_type_filter_provider.dart';
```

Remove this field from `_TrackingListPageState`:

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

At the start of `build`, add:

```dart
final selectedType = ref.watch(selectedMediaTypeProvider);
```

In `build`, replace each `_selectedType` reference with `selectedType`.

- [ ] **Step 4: Run tracking tests**

Run:

```bash
flutter test test/features/tracking/pages/tracking_list_page_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

Run:

```bash
git add lib/features/tracking/pages/tracking_list_page.dart test/features/tracking/pages/tracking_list_page_test.dart
git commit -m "feat: use shared media type in tracking"
```

---

### Task 4: Add Cross-Screen Regression Coverage

**Files:**
- Create: `test/features/media_type_filter_cross_screen_test.dart`

- [ ] **Step 1: Write the failing cross-screen regression test**

Create `test/features/media_type_filter_cross_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/movies/data/models/movie_model.dart';
import 'package:lorebase/features/movies/viewmodels/movie_search_viewmodel.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';
import 'package:lorebase/features/series/pages/series_search_page.dart';
import 'package:lorebase/features/series/viewmodels/series_search_viewmodel.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';
import 'package:lorebase/features/tracking/pages/tracking_list_page.dart';
import 'package:lorebase/features/tracking/viewmodels/tracking_list_viewmodel.dart';
import 'package:lorebase/l10n/strings.g.dart';

class _FakeAuthVM extends AuthViewModel {
  @override
  AuthState build() => const AuthState.authenticated('user-1');

  @override
  void setAuthenticated(String userId) {}

  @override
  void setUnauthenticated() {}

  @override
  Future<void> signOut() async {}
}

class _FakeSeriesSearchVM extends SeriesSearchViewModel {
  @override
  AsyncValue<List<SeriesModel>> build() => const AsyncValue.data([]);

  @override
  Future<void> search(String query) async {}

  @override
  void clear() {}
}

class _FakeMovieSearchVM extends MovieSearchViewModel {
  @override
  AsyncValue<List<MovieModel>> build() => const AsyncValue.data([]);

  @override
  Future<void> search(String query) async {}

  @override
  void clear() {}
}

class _FakeTrackingListVM extends TrackingListViewModel {
  @override
  AsyncValue<List<TrackedMediaModel>> build() => const AsyncValue.data([]);

  @override
  Future<void> loadTracking({
    String? status,
    MediaType mediaType = MediaType.series,
  }) async {}

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> refresh() async {}
}

Widget _wrap(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: TranslationProvider(
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/tracking',
          routes: [
            GoRoute(
              path: '/tracking',
              builder: (_, _) => const TrackingListPage(),
            ),
            GoRoute(
              path: '/search',
              builder: (_, _) => const SeriesSearchPage(),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  testWidgets('media type selection is shared from tracking to search', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        authViewModelProvider.overrideWith(() => _FakeAuthVM()),
        seriesSearchViewModelProvider.overrideWith(() => _FakeSeriesSearchVM()),
        movieSearchViewModelProvider.overrideWith(() => _FakeMovieSearchVM()),
        trackingListViewModelProvider.overrideWith(() => _FakeTrackingListVM()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(container));
    await tester.pump();

    await tester.tap(find.text('Movies'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(TrackingListPage));
    context.go('/search');
    await tester.pumpAndSettle();

    expect(find.text('Search movies...'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the cross-screen regression test**

Run:

```bash
flutter test test/features/media_type_filter_cross_screen_test.dart
```

Expected: PASS if Tasks 1-3 are complete. If it fails, fix only the provider wiring needed to satisfy the shared-state behavior.

- [ ] **Step 3: Commit**

Run:

```bash
git add test/features/media_type_filter_cross_screen_test.dart
git commit -m "test: cover shared media type across screens"
```

---

### Task 5: Final Verification

**Files:**
- No new files expected.

- [ ] **Step 1: Run targeted tests**

Run:

```bash
flutter test test/core/providers/media_type_filter_provider_test.dart test/features/series/pages/series_search_page_test.dart test/features/tracking/pages/tracking_list_page_test.dart test/features/media_type_filter_cross_screen_test.dart
```

Expected: PASS.

- [ ] **Step 2: Run analyzer**

Run:

```bash
dart analyze --fatal-infos
```

Expected: exit code 0 with no errors or infos.

- [ ] **Step 3: Run full test suite if targeted checks pass**

Run:

```bash
flutter test
```

Expected: PASS.

- [ ] **Step 4: Commit any final fixes**

If verification required fixes, run:

```bash
git add lib test
git commit -m "fix: stabilize shared media type filter"
```

If no fixes were needed, do not create an empty commit.

---

## Self-Review

- Spec coverage: Tasks 1-4 implement a session-scoped provider, refactor Buscar and Minhas Listas, avoid persistence and route parameters, and add regression coverage for the reported behavior.
- Placeholder scan: No TBD/TODO/fill-in-later placeholders remain.
- Type consistency: The plan consistently uses `selectedMediaTypeProvider`, `StateProvider<MediaType>`, and existing `MediaType.series` / `MediaType.movie` values.
