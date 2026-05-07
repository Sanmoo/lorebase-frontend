# Search Debounce Fix — Design

**Date:** 2026-05-07
**Status:** Pending User Review
**Scope:** Fix visual layout breakdown in Search tab when typing >2 characters
**Problem:** Every keystroke (when query.length >= 2) fires a new API call without debounce or cancellation. Rapid state transitions (loading ↔ data) trigger consecutive widget tree rebuilds, causing the layout engine to lose constraint references — the keyboard flickers, the bottom navigation bar shifts, and the body area resizes erratically.

---

## 1. Root Cause

**Factor A: No debounce** — `series_search_page.dart:28` fires `search(query)` on every `onChanged` event when `query.length >= 2`. Typing "abc" fires 2 API calls ("ab", "abc") in rapid succession, each triggering `AsyncValue.loading()` → `AsyncValue.data(results)`, causing consecutive `Scaffold` rebuilds.

**Factor B: TextField + keyboard amplifies rebuild impact** — The `TextField` sits inside the `AppBar` with `autofocus: true`. Each rebuild during keyboard-visible state recalculates `viewInsets`, causing the keyboard to flicker and the bottom nav bar to reposition.

---

## 2. Solution

Add a 300ms debounce timer in `_SeriesSearchPageState` and a `CancelToken` in `SeriesSearchViewModel` to cancel in-flight requests before starting a new one.

### File 1: `lib/features/series/pages/series_search_page.dart`

Add `Timer? _debounceTimer` field. Wrap the `search()` call in a debounce:

```dart
Timer? _debounceTimer;

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

Cancel the timer in `dispose()`.

### File 2: `lib/features/series/viewmodels/series_search_viewmodel.dart`

Track the in-flight request with `CancelToken? _cancelToken`:

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
    final results = await repository.searchSeries(query, cancelToken: cancelToken);
    state = AsyncValue.data(results);
  } catch (error, stackTrace) {
    if (error is DioException && error.type == DioExceptionType.cancel) return;
    state = AsyncValue.error(error, stackTrace);
  }
}
```

### File 3: `lib/features/series/data/repositories/series_repository.dart`

Add optional `CancelToken?` parameter to `searchSeries` (interface + implementation):

```dart
Future<List<SeriesModel>> searchSeries(String query, {int limit = 20, CancelToken? cancelToken});
```

Pass `cancelToken` to `_dio.get()`.

---

## 3. Corrected Flow

```
User types "abc" rapidly:
  "a"  → timer cancelled, nothing fires (len < 2)
  "ab" → 300ms timer starts
  "c"  → timer cancelled, new 300ms timer starts
  [300ms of inactivity]
  → Single API call: search("abc")
  → Stable UI, no flicker
```

If a request is still in-flight when a new one starts, it gets cancelled via `CancelToken`. The viewmodel silently ignores cancelled request completions.

---

## 4. Out of Scope

- The logic gap for 1-character input (stale results remain visible) — separate UX issue
- Nested Scaffold refactor — this is the project-wide pattern, changing it would require modifying all 4 tab pages and the shell route
