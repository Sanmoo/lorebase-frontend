# Tracking includeSeries Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `includeSeries=true` to the tracking API request so the My Lists tab renders series posters instead of broken-image icons.

**Architecture:** Single-line change in `TrackingRepositoryImpl.getTracking()` to pass the query param. The backend already supports `includeSeries=true` (verified via `e2e/features/tracking.feature`). No model, viewmodel, or UI changes needed.

**Tech Stack:** Dart, Dio, Riverpod

---

### Task 1: Update test to expect includeSeries param

**Files:**
- Modify: `test/features/tracking/data/repositories/tracking_repository_test.dart:60-77`

- [ ] **Step 1: Update the query params test to include `includeSeries`**

```dart
    test('getTracking() passes status, page, pageSize, includeSeries as query params',
        () async {
      Map<String, dynamic>? capturedParams;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedParams = options.queryParameters;
            return _json({'items': <Map<String, dynamic>>[]});
          },
        );
      final repo = TrackingRepositoryImpl(dio);

      await repo.getTracking(status: 'WATCHING', page: 2, pageSize: 10);
      expect(capturedParams, isNotNull);
      expect(capturedParams!['status'], 'WATCHING');
      expect(capturedParams!['page'], 2);
      expect(capturedParams!['pageSize'], 10);
      expect(capturedParams!['includeSeries'], true);
    });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/tracking/data/repositories/tracking_repository_test.dart -v`
Expected: The new test fails because `includeSeries` is not sent yet.

### Task 2: Add includeSeries to tracking repository

**Files:**
- Modify: `lib/features/tracking/data/repositories/tracking_repository.dart:36-43`

- [ ] **Step 1: Add `'includeSeries': true` to query parameters**

```dart
      final response = await _dio.get(
        '/tracking',
        queryParameters: {
          if (status != null) 'status': status,
          'page': page,
          'pageSize': pageSize,
          'includeSeries': true,
        },
      );
```

- [ ] **Step 2: Run tests to verify everything passes**

Run: `flutter test test/features/tracking/ -v`
Expected: All tracking tests pass (including the updated query params test).

### Task 3: Verify full test suite

- [ ] **Step 1: Run full lint + test suite**

Run: `make check` (or `dart analyze --fatal-infos && flutter test`)
Expected: All tests pass, no lint issues.

- [ ] **Step 2: Commit**

```bash
git add lib/features/tracking/data/repositories/tracking_repository.dart \
       test/features/tracking/data/repositories/tracking_repository_test.dart
git commit -m "feat: send includeSeries=true in tracking API request"
```
