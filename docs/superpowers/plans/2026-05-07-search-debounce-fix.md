# Search Debounce Fix — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix visual layout breakdown in Search tab by adding 300ms debounce to search input and CancelToken to abort in-flight API requests.

**Architecture:** Add a `Timer`-based debounce in `SeriesSearchPage`'s `_onSearchChanged` handler, and a `CancelToken` in `SeriesSearchViewModel.search()` to cancel previous Dio requests before starting new ones. The repository layer passes the token through to Dio.

**Tech Stack:** Flutter, Riverpod (AutoDisposeNotifier), Dio, Dart `dart:async`

---

### Task 1: Add `CancelToken?` parameter to SeriesRepository

**Files:**
- Modify: `lib/features/series/data/repositories/series_repository.dart`

- [ ] **Step 1: Add CancelToken import and parameter to interface and implementation**

Add `import 'package:dio/dio.dart';` if not already present (it is).

In `lib/features/series/data/repositories/series_repository.dart`, change the abstract method signature from:

```dart
Future<List<SeriesModel>> searchSeries(String query, {int limit = 20});
```

To:

```dart
Future<List<SeriesModel>> searchSeries(String query, {int limit = 20, CancelToken? cancelToken});
```

Change the implementation signature from:

```dart
Future<List<SeriesModel>> searchSeries(String query, {int limit = 20}) async {
```

To:

```dart
Future<List<SeriesModel>> searchSeries(String query, {int limit = 20, CancelToken? cancelToken}) async {
```

Change the `_dio.get()` call from:

```dart
final response = await _dio.get(
  '/series',
  queryParameters: {
    'q': query,
    'limit': limit,
  },
);
```

To:

```dart
final response = await _dio.get(
  '/series',
  queryParameters: {
    'q': query,
    'limit': limit,
  },
  cancelToken: cancelToken,
);
```

- [ ] **Step 2: Verify compilation**

```bash
cd lib && dart analyze ../lib/features/series/data/repositories/series_repository.dart
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/features/series/data/repositories/series_repository.dart
git commit -m "feat: add CancelToken parameter to SeriesRepository.searchSeries"
```

---

### Task 2: Add CancelToken to SeriesSearchViewModel

**Files:**
- Modify: `lib/features/series/viewmodels/series_search_viewmodel.dart`

- [ ] **Step 1: Add CancelToken logic to search method**

Add `import 'package:dio/dio.dart';` at the top of the file.

Add a private field `CancelToken? _cancelToken;` above the `build()` method.

Replace the `search` method:

From:

```dart
Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final repository = ref.read(seriesRepositoryProvider);
      final results = await repository.searchSeries(query);
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
```

To:

```dart
CancelToken? _cancelToken;

Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    _cancelToken?.cancel();
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;

    state = const AsyncValue.loading();
    try {
      final repository = ref.read(seriesRepositoryProvider);
      final results = await repository.searchSeries(
        query,
        cancelToken: cancelToken,
      );
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      if (error is DioException && error.type == DioExceptionType.cancel) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }
```

Also update the `clear` method to cancel any in-flight request:

From:

```dart
void clear() {
    state = const AsyncValue.data([]);
  }
```

To:

```dart
void clear() {
    _cancelToken?.cancel();
    _cancelToken = null;
    state = const AsyncValue.data([]);
  }
```

- [ ] **Step 2: Regenerate Riverpod code**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `series_search_viewmodel.g.dart` is regenerated. Verify no errors in output.

- [ ] **Step 3: Verify compilation**

```bash
cd lib && dart analyze ../lib/features/series/viewmodels/series_search_viewmodel.dart
```

Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lib/features/series/viewmodels/series_search_viewmodel.dart lib/features/series/viewmodels/series_search_viewmodel.g.dart
git commit -m "feat: add CancelToken to SeriesSearchViewModel to abort stale requests"
```

---

### Task 3: Add debounce to SeriesSearchPage

**Files:**
- Modify: `lib/features/series/pages/series_search_page.dart`

- [ ] **Step 1: Add debounce timer to _SeriesSearchPageState**

Add `import 'dart:async';` at the top of the file.

Add a private field `Timer? _debounceTimer;` above `_searchController`:

```dart
class _SeriesSearchPageState extends ConsumerState<SeriesSearchPage> {
  Timer? _debounceTimer;
  final _searchController = TextEditingController();
```

Replace the `_onSearchChanged` method:

From:

```dart
void _onSearchChanged(String query) {
    if (query.length >= 2) {
      ref.read(seriesSearchViewModelProvider.notifier).search(query);
    } else if (query.isEmpty) {
      ref.read(seriesSearchViewModelProvider.notifier).clear();
    }
  }
```

To:

```dart
void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.length >= 2) {
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        ref.read(seriesSearchViewModelProvider.notifier).search(query);
      });
    } else if (query.isEmpty) {
      ref.read(seriesSearchViewModelProvider.notifier).clear();
    }
  }
```

Update `dispose()` to cancel the timer:

From:

```dart
@override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
```

To:

```dart
@override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }
```

- [ ] **Step 2: Verify compilation**

```bash
cd lib && dart analyze ../lib/features/series/pages/series_search_page.dart
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/features/series/pages/series_search_page.dart
git commit -m "fix: add 300ms debounce to series search input"
```

---

### Task 4: Final verification

- [ ] **Step 1: Run dart analyze on full project**

```bash
dart analyze lib/
```

Expected: No errors (existing LSP errors in `.worktrees/` and `test/` directories are pre-existing and unrelated).

- [ ] **Step 2: Run existing tests**

```bash
flutter test
```

Expected: Existing tests pass (none relate to search, so no regressions).

- [ ] **Step 3: Manual verification steps**

1. Launch the app
2. Navigate to Search tab
3. Type slowly: each character should not cause layout flickering
4. Type rapidly: type 3+ characters quickly, verify layout remains stable (no keyboard flicker, no bottom nav shift)
5. Verify search results still appear correctly after the debounce delay
6. Verify clear button works properly
7. Verify empty state shows when clearing the search field
