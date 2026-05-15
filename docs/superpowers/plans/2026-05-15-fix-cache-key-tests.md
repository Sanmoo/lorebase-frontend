# Fix Cache Key Tests Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix 3 failing tests in `tracking_list_viewmodel_test.dart` caused by cache key mismatch after `MediaType.apiValue` changed to uppercase.

**Architecture:** Replace hardcoded lowercase `'tracking:series:...'` cache key strings with template literals referencing `MediaType.series.apiValue`. Single file, 3 string replacements, no new imports needed.

**Tech Stack:** Dart, Flutter test framework

---

### Task 1: Fix cache key references and verify

**Files:**
- Modify: `test/features/tracking/viewmodels/tracking_list_viewmodel_test.dart`

- [ ] **Step 1: Replace hardcoded cache keys with `MediaType.series.apiValue` references**

Three occurrences of `'tracking:series:WATCHING:1'` need to change to `'tracking:${MediaType.series.apiValue}:WATCHING:1'`.

The occurrences are in these tests (search for `tracking:series:` in the file):

1. **"returns cached data from memory"** — the `cache.set()` call:

```dart
// Before:
await cache.set('tracking:series:WATCHING:1', CacheEntry(

// After:
await cache.set('tracking:${MediaType.series.apiValue}:WATCHING:1', CacheEntry(
```

2. **"triggers background refresh when cache is stale"** — the `cache.set()` call:

```dart
// Before:
await cache.set('tracking:series:WATCHING:1', CacheEntry(

// After:
await cache.set('tracking:${MediaType.series.apiValue}:WATCHING:1', CacheEntry(
```

3. **"background refresh failure sets error provider on stale cache"** — the `cache.set()` call:

```dart
// Before:
await cache.set('tracking:series:WATCHING:1', CacheEntry(

// After:
await cache.set('tracking:${MediaType.series.apiValue}:WATCHING:1', CacheEntry(
```

> Note: `MediaType` and `media_type.dart` are already imported at the top of the file (line 12: `import 'package:lorebase/features/tracking/data/models/media_type.dart';`). No import changes needed.

- [ ] **Step 2: Run the failing tests to verify they pass**

```bash
flutter test test/features/tracking/viewmodels/tracking_list_viewmodel_test.dart
```

Expected: All tests pass, no failures.

- [ ] **Step 3: Commit**

```bash
git add test/features/tracking/viewmodels/tracking_list_viewmodel_test.dart
git commit -m "test: fix cache key references to use MediaType.apiValue in tracking viewmodel tests"
```
