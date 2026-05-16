# Visual Regression Testing — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Alchemist-based golden file tests for 8 full pages (light + dark mode each), integrated into `make check` as a quality gate.

**Architecture:** New `test/visual/` directory with `flutter_test_config.dart` for Alchemist global config, `helpers/golden_helpers.dart` for centralized mock overrides, `golden_files/` for git-tracked reference PNGs, and `pages/` for one golden test per page. Each test renders a page with mocked Riverpod providers under light and dark themes.

**Tech Stack:** Flutter test, Alchemist 0.x, Riverpod overrides (existing pattern), Material 3 theming

---

### Task 1: Add alchemist dependency

**Files:**

- Modify: `pubspec.yaml` (dev_dependencies block)

- [ ] **Step 1: Add alchemist to pubspec.yaml**

```yaml
# In dev_dependencies, add:
alchemist: ^0.11.0
```

The full dev_dependencies block becomes:

```yaml
dev_dependencies:
  alchemist: ^0.11.0
  slang_build_runner: 4.11.0
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  mockito: ^5.4.0
  build_runner: ^2.4.0
  coverage: ^1.15.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.3.0
  riverpod_lint: ^2.3.0
  custom_lint: ^0.7.0
  flutter_launcher_icons: ^0.13.1
  alchemist: ^0.11.0
```

- [ ] **Step 2: Run pub get**

Run: `flutter pub get`
Expected: Resolves without errors, alchemist added to pubspec.lock.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add alchemist dependency for golden tests"
```

---

### Task 2: Create Alchemist global config

**Files:**

- Create: `test/visual/flutter_test_config.dart`

- [ ] **Step 1: Write flutter_test_config.dart**

```dart
import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(
        enabled: true,
      ),
      theme: ThemeData.light(),
      ciGoldensConfig: CiGoldensConfig(
        enabled: true,
      ),
    ),
    run: testMain,
  );
}
```

- [ ] **Step 2: Verify no test can run yet (no test files exist)**

Run: `flutter test test/visual/`
Expected: "No tests were found" or exit code 0 (no tests).

- [ ] **Step 3: Commit**

```bash
git add test/visual/flutter_test_config.dart
git commit -m "feat: add Alchemist global config for golden tests"
```

---

### Task 3: Create centralized golden helpers with mock overrides

**Files:**

- Create: `test/visual/helpers/golden_helpers.dart`

This file defines all `List<Override>` functions that each golden test imports. Each function creates fake ViewModels returning pre-filled data so pages render meaningfully.

- [ ] **Step 1: Write golden_helpers.dart**

```dart
// coverage:ignore-file
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/login_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/register_viewmodel.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_model.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_section_model.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:lorebase/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:lorebase/features/movies/data/models/movie_model.dart';
import 'package:lorebase/features/movies/viewmodels/movie_detail_state.dart';
import 'package:lorebase/features/movies/viewmodels/movie_detail_viewmodel.dart';
import 'package:lorebase/features/movies/viewmodels/movie_search_viewmodel.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';
import 'package:lorebase/features/series/viewmodels/series_detail_state.dart';
import 'package:lorebase/features/series/viewmodels/series_detail_viewmodel.dart';
import 'package:lorebase/features/series/viewmodels/series_search_viewmodel.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_summary_model.dart';
import 'package:lorebase/features/tracking/viewmodels/tracking_list_viewmodel.dart';

// ─── Fake ViewModels ────────────────────────────────────

class FakeAuthVM extends AuthViewModel {
  @override
  AuthState build() => const AuthState.authenticated('golden-user-1');

  @override
  void setAuthenticated(String userId) {}

  @override
  void setUnauthenticated() {}

  @override
  Future<void> signOut() async {}
}

class FakeUnauthVM extends AuthViewModel {
  @override
  AuthState build() => const AuthState.unauthenticated();

  @override
  void setAuthenticated(String userId) {}

  @override
  void setUnauthenticated() {}

  @override
  Future<void> signOut() async {}
}

class FakeLoginVM extends LoginViewModel {
  @override
  LoginState build() => const LoginState();
}

class FakeRegisterVM extends RegisterViewModel {
  @override
  RegisterState build() => const RegisterState();
}

class FakeDashboardVM extends DashboardViewModel {
  @override
  AsyncValue<DashboardModel> build() => AsyncValue.data(_dashboardWithData());

  @override
  Future<void> refresh() async {}

  @override
  Future<void> loadDashboard({MediaType mediaType = MediaType.series}) async {}
}

class FakeSeriesDetailVM extends SeriesDetailViewModel {
  @override
  Future<SeriesDetailState> build(int tmdbId) async => SeriesDetailState(
        series: const SeriesModel(
          tmdbId: 1,
          title: 'Breaking Bad',
          overview:
              'A high school chemistry teacher diagnosed with inoperable lung '
              'cancer turns to manufacturing and selling methamphetamine in '
              'order to secure his family\'s future.',
          genres: ['Drama', 'Crime', 'Thriller'],
          seasonCount: 5,
          status: 'Ended',
          firstAirDate: '2008-01-20',
          networks: ['AMC'],
        ),
        tracking: null,
      );
}

class FakeMovieDetailVM extends MovieDetailViewModel {
  @override
  Future<MovieDetailState> build(int tmdbId) async => MovieDetailState(
        movie: const MovieModel(
          tmdbId: 7,
          title: 'Se7en',
          overview:
              'Two detectives, a rookie and a veteran, hunt a serial killer '
              'who uses the seven deadly sins as his motives.',
          releaseDate: '1995-09-22',
          runtimeMinutes: 127,
          genres: ['Crime', 'Mystery', 'Thriller'],
        ),
        tracking: null,
      );
}

class FakeSeriesSearchVM extends SeriesSearchViewModel {
  @override
  AsyncValue<List<SeriesModel>> build() => AsyncValue.data(_searchResults());

  @override
  Future<void> search(String query) async {}

  @override
  void clear() {}
}

class FakeMovieSearchVM extends MovieSearchViewModel {
  @override
  AsyncValue<List<MovieModel>> build() => const AsyncValue.data([]);

  @override
  Future<void> search(String query) async {}

  @override
  void clear() {}
}

class FakeTrackingListVM extends TrackingListViewModel {
  @override
  AsyncValue<List<TrackedMediaModel>> build() =>
      AsyncValue.data(_trackingItems());

  @override
  Future<void> loadTracking(
      {String? status, MediaType mediaType = MediaType.series}) async {}

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> refresh() async {}
}

// ─── Data Factories ─────────────────────────────────────

DashboardModel _dashboardWithData() {
  const media = TrackedMediaSummaryModel(
    mediaId: '456',
    title: 'Breaking Bad',
    mediaType: MediaType.series,
  );
  return const DashboardModel(
    watching: DashboardSectionModel(items: [media]),
    wantToWatch: DashboardSectionModel(items: [media]),
    completed: DashboardSectionModel(items: [media]),
    dropped: DashboardSectionModel(),
    stats: DashboardStatsModel(
      watchingCount: 3,
      wantToWatchCount: 2,
      completedCount: 5,
      droppedCount: 1,
    ),
  );
}

List<SeriesModel> _searchResults() => const [
      SeriesModel(tmdbId: 1, title: 'Breaking Bad'),
      SeriesModel(tmdbId: 2, title: 'Better Call Saul'),
      SeriesModel(tmdbId: 3, title: 'Stranger Things'),
    ];

final _now = DateTime.now();

List<TrackedMediaModel> _trackingItems() => [
      TrackedMediaModel(
        trackingId: 't1',
        userId: 'golden-user-1',
        mediaType: MediaType.series,
        mediaId: '1',
        status: 'WATCHING',
        media: const TrackedMediaSummaryModel(
          mediaId: '1', title: 'Breaking Bad', mediaType: MediaType.series,
        ),
        rating: 9,
        addedAt: _now,
        lastUpdated: _now,
      ),
      TrackedMediaModel(
        trackingId: 't2',
        userId: 'golden-user-1',
        mediaType: MediaType.series,
        mediaId: '2',
        status: 'WATCHING',
        media: const TrackedMediaSummaryModel(
          mediaId: '2', title: 'Better Call Saul', mediaType: MediaType.series,
        ),
        rating: 8,
        addedAt: _now,
        lastUpdated: _now,
      ),
      TrackedMediaModel(
        trackingId: 't3',
        userId: 'golden-user-1',
        mediaType: MediaType.series,
        mediaId: '3',
        status: 'WATCHING',
        media: const TrackedMediaSummaryModel(
            mediaId: '3', title: 'Stranger Things',
            mediaType: MediaType.series),
        rating: 7,
        addedAt: _now,
        lastUpdated: _now,
      ),
    ];

// ─── Override Helpers ───────────────────────────────────

/// Common override for authenticated pages.
List<Override> authOverride() => [
      authViewModelProvider.overrideWith(() => FakeAuthVM()),
    ];

/// Common override for unauthenticated pages (login/register).
List<Override> unauthOverride() => [
      authViewModelProvider.overrideWith(() => FakeUnauthVM()),
    ];

List<Override> dashboardGoldenOverrides() => [
      dashboardViewModelProvider.overrideWith(() => FakeDashboardVM()),
      ...authOverride(),
    ];

List<Override> loginGoldenOverrides() => [
      loginViewModelProvider.overrideWith(() => FakeLoginVM()),
      ...unauthOverride(),
    ];

List<Override> registerGoldenOverrides() => [
      registerViewModelProvider.overrideWith(() => FakeRegisterVM()),
      ...unauthOverride(),
    ];

List<Override> seriesDetailGoldenOverrides() => [
      seriesDetailViewModelProvider(1)
          .overrideWith(() => FakeSeriesDetailVM()),
      ...authOverride(),
    ];

List<Override> seriesSearchGoldenOverrides() => [
      seriesSearchViewModelProvider.overrideWith(() => FakeSeriesSearchVM()),
      movieSearchViewModelProvider.overrideWith(() => FakeMovieSearchVM()),
      ...authOverride(),
    ];

List<Override> movieDetailGoldenOverrides() => [
      movieDetailViewModelProvider(7)
          .overrideWith(() => FakeMovieDetailVM()),
      ...authOverride(),
    ];

List<Override> trackingListGoldenOverrides() => [
      trackingListViewModelProvider.overrideWith(() => FakeTrackingListVM()),
      ...authOverride(),
    ];
```

- [ ] **Step 2: Verify file compiles**

Run: `dart analyze test/visual/helpers/golden_helpers.dart`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add test/visual/helpers/golden_helpers.dart
git commit -m "feat: add golden test mock overrides and fake VMs"
```

---

### Task 4: Dashboard page golden test

**Files:**

- Create: `test/visual/pages/dashboard_page_golden_test.dart`

- [ ] **Step 1: Write failing golden test (no reference file yet)**

```dart
import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorebase/features/dashboard/pages/dashboard_page.dart';
import 'package:lorebase/l10n/strings.g.dart';

import '../../helpers/golden_helpers.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  goldenTest(
    'Dashboard page renders correctly with data',
    fileName: 'dashboard_page',
    builder: () => GoldenTestGroup(
      scenarios: [
        GoldenTestScenario(
          name: 'light_default',
          child: ProviderScope(
            overrides: dashboardGoldenOverrides(),
            child: TranslationProvider(
              child: MaterialApp(
                theme: ThemeData.light(useMaterial3: true),
                home: const DashboardPage(),
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'dark_default',
          child: ProviderScope(
            overrides: dashboardGoldenOverrides(),
            child: TranslationProvider(
              child: MaterialApp(
                theme: ThemeData.dark(useMaterial3: true),
                home: const DashboardPage(),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 2: Generate initial golden files**

Run: `flutter test test/visual/pages/dashboard_page_golden_test.dart --update-goldens`
Expected: Test passes, golden PNGs created at `test/visual/golden_files/dashboard_page/`.

- [ ] **Step 3: Verify test passes against generated goldens**

Run: `flutter test test/visual/pages/dashboard_page_golden_test.dart`
Expected: PASS (all golden comparisons match).

- [ ] **Step 4: Commit**

```bash
git add test/visual/pages/dashboard_page_golden_test.dart \
        test/visual/golden_files/dashboard_page/
git commit -m "test: add dashboard page golden test (light + dark)"
```

---

### Task 5: Login page golden test

**Files:**

- Create: `test/visual/pages/login_page_golden_test.dart`

- [ ] **Step 1: Write failing golden test**

```dart
import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorebase/features/auth/pages/login_page.dart';
import 'package:lorebase/l10n/strings.g.dart';

import '../../helpers/golden_helpers.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  goldenTest(
    'Login page renders correctly',
    fileName: 'login_page',
    builder: () => GoldenTestGroup(
      scenarios: [
        GoldenTestScenario(
          name: 'light_default',
          child: ProviderScope(
            overrides: loginGoldenOverrides(),
            child: TranslationProvider(
              child: MaterialApp(
                theme: ThemeData.light(useMaterial3: true),
                home: const LoginPage(),
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'dark_default',
          child: ProviderScope(
            overrides: loginGoldenOverrides(),
            child: TranslationProvider(
              child: MaterialApp(
                theme: ThemeData.dark(useMaterial3: true),
                home: const LoginPage(),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 2: Generate initial golden files**

Run: `flutter test test/visual/pages/login_page_golden_test.dart --update-goldens`

- [ ] **Step 3: Verify test passes**

Run: `flutter test test/visual/pages/login_page_golden_test.dart`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add test/visual/pages/login_page_golden_test.dart \
        test/visual/golden_files/login_page/
git commit -m "test: add login page golden test (light + dark)"
```

---

### Task 6: Register page golden test

**Files:**

- Create: `test/visual/pages/register_page_golden_test.dart`

- [ ] **Step 1: Write failing golden test**

```dart
import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorebase/features/auth/pages/register_page.dart';
import 'package:lorebase/l10n/strings.g.dart';

import '../../helpers/golden_helpers.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  goldenTest(
    'Register page renders correctly',
    fileName: 'register_page',
    builder: () => GoldenTestGroup(
      scenarios: [
        GoldenTestScenario(
          name: 'light_default',
          child: ProviderScope(
            overrides: registerGoldenOverrides(),
            child: TranslationProvider(
              child: MaterialApp(
                theme: ThemeData.light(useMaterial3: true),
                home: const RegisterPage(),
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'dark_default',
          child: ProviderScope(
            overrides: registerGoldenOverrides(),
            child: TranslationProvider(
              child: MaterialApp(
                theme: ThemeData.dark(useMaterial3: true),
                home: const RegisterPage(),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 2: Generate initial golden files**

Run: `flutter test test/visual/pages/register_page_golden_test.dart --update-goldens`

- [ ] **Step 3: Verify test passes**

Run: `flutter test test/visual/pages/register_page_golden_test.dart`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add test/visual/pages/register_page_golden_test.dart \
        test/visual/golden_files/register_page/
git commit -m "test: add register page golden test (light + dark)"
```

---

### Task 7: Series Detail page golden test

**Files:**

- Create: `test/visual/pages/series_detail_page_golden_test.dart`

The SeriesDetailPage requires an `int tmdbId` constructor parameter.

- [ ] **Step 1: Write failing golden test**

```dart
import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorebase/features/series/pages/series_detail_page.dart';
import 'package:lorebase/l10n/strings.g.dart';

import '../../helpers/golden_helpers.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  goldenTest(
    'Series detail page renders correctly',
    fileName: 'series_detail_page',
    builder: () => GoldenTestGroup(
      scenarios: [
        GoldenTestScenario(
          name: 'light_default',
          child: ProviderScope(
            overrides: seriesDetailGoldenOverrides(),
            child: TranslationProvider(
              child: MaterialApp(
                theme: ThemeData.light(useMaterial3: true),
                home: const SeriesDetailPage(tmdbId: 1),
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'dark_default',
          child: ProviderScope(
            overrides: seriesDetailGoldenOverrides(),
            child: TranslationProvider(
              child: MaterialApp(
                theme: ThemeData.dark(useMaterial3: true),
                home: const SeriesDetailPage(tmdbId: 1),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 2: Generate initial golden files**

Run: `flutter test test/visual/pages/series_detail_page_golden_test.dart --update-goldens`

- [ ] **Step 3: Verify test passes**

Run: `flutter test test/visual/pages/series_detail_page_golden_test.dart`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add test/visual/pages/series_detail_page_golden_test.dart \
        test/visual/golden_files/series_detail_page/
git commit -m "test: add series detail page golden test (light + dark)"
```

---

### Task 8: Series Search page golden test

**Files:**

- Create: `test/visual/pages/series_search_page_golden_test.dart`

- [ ] **Step 1: Write failing golden test**

```dart
import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorebase/features/series/pages/series_search_page.dart';
import 'package:lorebase/l10n/strings.g.dart';

import '../../helpers/golden_helpers.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  goldenTest(
    'Series search page renders correctly',
    fileName: 'series_search_page',
    builder: () => GoldenTestGroup(
      scenarios: [
        GoldenTestScenario(
          name: 'light_default',
          child: ProviderScope(
            overrides: seriesSearchGoldenOverrides(),
            child: TranslationProvider(
              child: MaterialApp(
                theme: ThemeData.light(useMaterial3: true),
                home: const SeriesSearchPage(),
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'dark_default',
          child: ProviderScope(
            overrides: seriesSearchGoldenOverrides(),
            child: TranslationProvider(
              child: MaterialApp(
                theme: ThemeData.dark(useMaterial3: true),
                home: const SeriesSearchPage(),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 2: Generate initial golden files**

Run: `flutter test test/visual/pages/series_search_page_golden_test.dart --update-goldens`

- [ ] **Step 3: Verify test passes**

Run: `flutter test test/visual/pages/series_search_page_golden_test.dart`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add test/visual/pages/series_search_page_golden_test.dart \
        test/visual/golden_files/series_search_page/
git commit -m "test: add series search page golden test (light + dark)"
```

---

### Task 9: Movie Detail page golden test

**Files:**

- Create: `test/visual/pages/movie_detail_page_golden_test.dart`

- [ ] **Step 1: Write failing golden test**

```dart
import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorebase/features/movies/pages/movie_detail_page.dart';
import 'package:lorebase/l10n/strings.g.dart';

import '../../helpers/golden_helpers.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  goldenTest(
    'Movie detail page renders correctly',
    fileName: 'movie_detail_page',
    builder: () => GoldenTestGroup(
      scenarios: [
        GoldenTestScenario(
          name: 'light_default',
          child: ProviderScope(
            overrides: movieDetailGoldenOverrides(),
            child: TranslationProvider(
              child: MaterialApp(
                theme: ThemeData.light(useMaterial3: true),
                home: const MovieDetailPage(tmdbId: 7),
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'dark_default',
          child: ProviderScope(
            overrides: movieDetailGoldenOverrides(),
            child: TranslationProvider(
              child: MaterialApp(
                theme: ThemeData.dark(useMaterial3: true),
                home: const MovieDetailPage(tmdbId: 7),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 2: Generate initial golden files**

Run: `flutter test test/visual/pages/movie_detail_page_golden_test.dart --update-goldens`

- [ ] **Step 3: Verify test passes**

Run: `flutter test test/visual/pages/movie_detail_page_golden_test.dart`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add test/visual/pages/movie_detail_page_golden_test.dart \
        test/visual/golden_files/movie_detail_page/
git commit -m "test: add movie detail page golden test (light + dark)"
```

---

### Task 10: Tracking List page golden test

**Files:**

- Create: `test/visual/pages/tracking_list_page_golden_test.dart`

- [ ] **Step 1: Write failing golden test**

```dart
import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorebase/features/tracking/pages/tracking_list_page.dart';
import 'package:lorebase/l10n/strings.g.dart';

import '../../helpers/golden_helpers.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  goldenTest(
    'Tracking list page renders correctly',
    fileName: 'tracking_list_page',
    builder: () => GoldenTestGroup(
      scenarios: [
        GoldenTestScenario(
          name: 'light_default',
          child: ProviderScope(
            overrides: trackingListGoldenOverrides(),
            child: TranslationProvider(
              child: MaterialApp(
                theme: ThemeData.light(useMaterial3: true),
                home: const TrackingListPage(),
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'dark_default',
          child: ProviderScope(
            overrides: trackingListGoldenOverrides(),
            child: TranslationProvider(
              child: MaterialApp(
                theme: ThemeData.dark(useMaterial3: true),
                home: const TrackingListPage(),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 2: Generate initial golden files**

Run: `flutter test test/visual/pages/tracking_list_page_golden_test.dart --update-goldens`

- [ ] **Step 3: Verify test passes**

Run: `flutter test test/visual/pages/tracking_list_page_golden_test.dart`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add test/visual/pages/tracking_list_page_golden_test.dart \
        test/visual/golden_files/tracking_list_page/
git commit -m "test: add tracking list page golden test (light + dark)"
```

---

### Task 11: Recommendation page golden test

**Files:**

- Create: `test/visual/pages/recommendation_page_golden_test.dart`

The Recommendation page is a simple `ConsumerWidget` with no meaningful providers — it just shows a "coming soon" message. No overrides needed.

- [ ] **Step 1: Write failing golden test**

```dart
import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:lorebase/features/recommendation/pages/recommendation_page.dart';
import 'package:lorebase/l10n/strings.g.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  goldenTest(
    'Recommendation page renders correctly',
    fileName: 'recommendation_page',
    builder: () => GoldenTestGroup(
      scenarios: [
        GoldenTestScenario(
          name: 'light_default',
          child: TranslationProvider(
            child: MaterialApp(
              theme: ThemeData.light(useMaterial3: true),
              home: const RecommendationPage(),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'dark_default',
          child: TranslationProvider(
            child: MaterialApp(
              theme: ThemeData.dark(useMaterial3: true),
              home: const RecommendationPage(),
            ),
          ),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 2: Generate initial golden files**

Run: `flutter test test/visual/pages/recommendation_page_golden_test.dart --update-goldens`

- [ ] **Step 3: Verify test passes**

Run: `flutter test test/visual/pages/recommendation_page_golden_test.dart`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add test/visual/pages/recommendation_page_golden_test.dart \
        test/visual/golden_files/recommendation_page/
git commit -m "test: add recommendation page golden test (light + dark)"
```

---

### Task 12: Run all golden tests together

**Files:** None (verification only)

- [ ] **Step 1: Run all golden tests**

Run: `flutter test test/visual/`
Expected: All 8 test files pass (16 scenarios total).

- [ ] **Step 2: Commit if any golden files were regenerated**

```bash
git status
# If clean, no commit needed
```

---

### Task 13: Update Makefile with golden test targets

**Files:**

- Modify: `Makefile` (check target and new golden targets)

- [ ] **Step 1: Add golden-test and golden-update targets**

Add after the `# ─── Testing & Quality ─────────` block, before the `# ─── Web Build ─────────` block:

```makefile
# ─── Visual Regression ────────────────────────

golden-test:
	flutter test test/visual/

golden-update:
	flutter test test/visual/ --update-goldens
```

- [ ] **Step 2: Integrate golden-test into check**

Change the `check` target from:

```makefile
check: analyze test-coverage
```

To:

```makefile
check: analyze test-coverage golden-test
```

- [ ] **Step 3: Verify make check works end-to-end**

Run: `make check`
Expected: All three stages pass (analyze, test-coverage gate, golden tests).

- [ ] **Step 4: Commit**

```bash
git add Makefile
git commit -m "feat: add golden-test and golden-update targets, integrate into make check"
```

---

### Task 14: Add .gitattributes for golden PNGs

**Files:**

- Create/Modify: `.gitattributes`

- [ ] **Step 1: Check if .gitattributes exists**

Run: `ls -la .gitattributes 2>/dev/null || echo "not found"`

- [ ] **Step 2: Add binary rule for golden files**

If `.gitattributes` exists, append:

```
test/visual/golden_files/** binary
```

If it doesn't exist, create it with that single line.

- [ ] **Step 3: Commit**

```bash
git add .gitattributes
git commit -m "chore: mark golden PNGs as binary in gitattributes"
```

---

### Task 15: Final verification — full make check

**Files:** None (verification only)

- [ ] **Step 1: Run full quality gate**

Run: `make check`
Expected:

- `dart analyze --fatal-infos` passes (or warns-only → exit 0 via Makefile logic)
- `flutter test --coverage` passes, coverage gate at 100% line + branch
- `flutter test test/visual/` passes, all 16 golden scenarios match

- [ ] **Step 2: Confirm golden files are tracked**

Run: `git ls-files test/visual/golden_files/ | wc -l`
Expected: At least 8 directories each with PNG files (likely 16 files for 8 pages × 2 scenarios).

- [ ] **Step 3: Final commit (if any remaining uncommitted changes)**

```bash
git status
# Should be clean
```
