# Media Type apiValue Uppercase Fix — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Change `MediaType.apiValue` from lowercase (`'series'`, `'movie'`) to uppercase (`'SERIES'`, `'MOVIE'`) so the frontend sends backend-compatible query parameters.

**Architecture:** Single-enum change in `lib/features/tracking/data/models/media_type.dart`. The `apiValue` field is consumed by repository query parameters, cache keys, and JSON serialization (`mediaTypeToJson`). Deserialization (`mediaTypeFromJson` → `fromApiValue`) is already case-insensitive via `.toLowerCase()`. All consumers automatically pick up the new value; only test expectations need updating.

**Tech Stack:** Dart 3.3+, Flutter 3.27, Freezed, Riverpod

---

### Task 1: Update `MediaType.apiValue` to uppercase

**Files:**

- Modify: `lib/features/tracking/data/models/media_type.dart:5-8`

- [ ] **Step 1: Change the apiValue constructor arguments**

```dart
enum MediaType {
  series('SERIES'),
  movie('MOVIE');

  const MediaType(this.apiValue);

  final String apiValue;
  ...
}
```

The rest of the file stays identical — `fromApiValue` already uses `.toLowerCase()`, `label()` is unaffected, `mediaTypeFromJson`/`mediaTypeToJson` are auto-wired to `apiValue`.

- [ ] **Step 2: Run analyzer to confirm no type errors**

```bash
dart analyze --fatal-infos lib/features/tracking/data/models/media_type.dart
```

Expected: No issues found.

---

### Task 2: Update `media_type_test.dart` expectations

**Files:**

- Modify: `test/features/tracking/data/models/media_type_test.dart:8-9`
- Modify: `test/features/tracking/data/models/media_type_test.dart:29`

- [ ] **Step 1: Update apiValue test expectations**

Change lines 7-10 from:

```dart
    test('apiValue exposes stable backend values', () {
      expect(MediaType.series.apiValue, 'series');
      expect(MediaType.movie.apiValue, 'movie');
    });
```

To:

```dart
    test('apiValue exposes stable backend values', () {
      expect(MediaType.series.apiValue, 'SERIES');
      expect(MediaType.movie.apiValue, 'MOVIE');
    });
```

- [ ] **Step 2: Update mediaTypeToJson roundtrip test**

Change line 27-30 from:

```dart
    test('mediaTypeFromJson and mediaTypeToJson roundtrip', () {
      expect(mediaTypeFromJson('series'), MediaType.series);
      expect(mediaTypeToJson(MediaType.movie), 'movie');
```

To:

```dart
    test('mediaTypeFromJson and mediaTypeToJson roundtrip', () {
      expect(mediaTypeFromJson('series'), MediaType.series);
      expect(mediaTypeToJson(MediaType.movie), 'MOVIE');
```

- [ ] **Step 3: Run the media_type test file**

```bash
flutter test test/features/tracking/data/models/media_type_test.dart
```

Expected: All 4 tests pass.

- [ ] **Step 4: Commit**

```bash
git add lib/features/tracking/data/models/media_type.dart test/features/tracking/data/models/media_type_test.dart
git commit -m "fix: change MediaType.apiValue to uppercase for backend compatibility"
```

---

### Task 3: Update `dashboard_viewmodel_test.dart` cache key strings

**Files:**

- Modify: `test/features/dashboard/viewmodels/dashboard_viewmodel_test.dart:135,161,186,226`

- [ ] **Step 1: Replace all 4 occurrences of `'dashboard:series'` with `'dashboard:SERIES'`**

Lines 135, 161, 186, 226 — each is a `cacheService.set('dashboard:series', ...)` call.

Change each from `'dashboard:series'` to `'dashboard:SERIES'`.

```dart
// Line ~135 (refresh() keeps stale data on network failure)
await cacheService.set('dashboard:SERIES', CacheEntry(...

// Line ~161 (build() returns cached data from memory)
await cacheService.set('dashboard:SERIES', CacheEntry(...

// Line ~186 (build() triggers background refresh when cache is stale)
await cacheService.set('dashboard:SERIES', CacheEntry(...

// Line ~226 (build() handles background refresh failure on stale cache)
await cacheService.set('dashboard:SERIES', CacheEntry(...
```

- [ ] **Step 2: Run the dashboard viewmodel tests**

```bash
flutter test test/features/dashboard/viewmodels/dashboard_viewmodel_test.dart
```

Expected: All 10 tests pass.

- [ ] **Step 3: Commit**

```bash
git add test/features/dashboard/viewmodels/dashboard_viewmodel_test.dart
git commit -m "test: update dashboard cache keys for uppercase mediaType apiValue"
```

---

### Task 4: Update `tracked_media_model_test.dart` and `tracked_media_summary_model_test.dart` expectations

**Files:**

- Modify: `test/features/tracking/data/models/tracked_media_model_test.dart:32`
- Modify: `test/features/tracking/data/models/tracked_media_model_test.dart:66`
- Modify: `test/features/tracking/data/models/tracked_media_summary_model_test.dart:17`

- [ ] **Step 1: Update tracked_media_model_test.dart expectations**

Line 32 — change from `'series'` to `'SERIES'`:

```dart
expect(model.mediaType.apiValue, 'SERIES');
```

Line 66 — change from `'movie'` to `'MOVIE'`:

```dart
expect(model.mediaType.apiValue, 'MOVIE');
```

- [ ] **Step 2: Update tracked_media_summary_model_test.dart expectation**

Line 17 — change from `'movie'` to `'MOVIE'`:

```dart
expect(model.mediaType.apiValue, 'MOVIE');
```

- [ ] **Step 3: Run both test files**

```bash
flutter test test/features/tracking/data/models/tracked_media_model_test.dart
flutter test test/features/tracking/data/models/tracked_media_summary_model_test.dart
```

Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
git add test/features/tracking/data/models/tracked_media_model_test.dart test/features/tracking/data/models/tracked_media_summary_model_test.dart
git commit -m "test: update tracking model tests for uppercase mediaType apiValue"
```

---

### Task 5: Run full test suite and quality gate

**Files:**

- (None — verification only)

- [ ] **Step 1: Run all tests**

```bash
flutter test
```

Expected: All tests pass, 0 failures.

- [ ] **Step 2: Run coverage gate**

```bash
make test-coverage
```

Expected: 100% line + branch coverage.

- [ ] **Step 3: Run analyzer**

```bash
dart analyze --fatal-infos
```

Expected: No issues found.

- [ ] **Step 4: Commit (if any changes from the above)**

```bash
git add -A
git commit -m "chore: verify full test suite and quality gate pass"
```
