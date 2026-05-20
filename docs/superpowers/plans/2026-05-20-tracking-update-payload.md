# Tracking Update Payload Compatibility Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make frontend tracking update requests use the backend's current `seriesRating` and `seriesReview` field names so rating/review updates persist.

**Architecture:** Keep the compatibility mapping at the repository boundary. Viewmodels and widgets continue using generic `rating` and `review` parameters; `TrackingRepositoryImpl.updateTracking` translates them into backend-compatible JSON keys.

**Tech Stack:** Flutter/Dart, Dio, Riverpod, flutter_test.

---

## File Structure

- Modify: `test/features/tracking/data/repositories/tracking_repository_test.dart`
  - Add a repository-level test that captures `options.data` for `updateTracking`.
  - Assert that update payload uses `seriesRating` / `seriesReview` and does not include `rating` / `review`.

- Modify: `lib/features/tracking/data/repositories/tracking_repository.dart`
  - Change only the outgoing JSON keys inside `TrackingRepositoryImpl.updateTracking`.
  - Keep the method signature unchanged.
  - Keep diagnostic logs elsewhere unchanged.

---

### Task 1: Add failing repository payload test

**Files:**
- Modify: `test/features/tracking/data/repositories/tracking_repository_test.dart`

- [ ] **Step 1: Add the failing test**

Insert this test inside `group('TrackingRepositoryImpl', () { ... })`, near the existing `updateTracking()` tests:

```dart
test('updateTracking() sends backend-compatible rating and review keys',
    () async {
  Map<String, dynamic>? capturedData;
  final dio = Dio()
    ..httpClientAdapter = MockAdapter(
      onFetch: (options) {
        capturedData = options.data as Map<String, dynamic>?;
        return _json(_trackingJson('t-updated', 'SERIES'));
      },
    );
  final repo = TrackingRepositoryImpl(dio);

  await repo.updateTracking(
    'series-1',
    mediaType: MediaType.series,
    status: 'WATCHING',
    rating: 8,
    review: 'Great',
  );

  expect(capturedData, isNotNull);
  expect(capturedData!['mediaType'], 'SERIES');
  expect(capturedData!['status'], 'WATCHING');
  expect(capturedData!['seriesRating'], 8);
  expect(capturedData!['seriesReview'], 'Great');
  expect(capturedData!.containsKey('rating'), false);
  expect(capturedData!.containsKey('review'), false);
});
```

- [ ] **Step 2: Run the focused test and verify it fails**

Run:

```bash
flutter test test/features/tracking/data/repositories/tracking_repository_test.dart
```

Expected: FAIL. The new test should fail because current payload uses `rating` and `review`, so `capturedData!['seriesRating']` is `null`.

- [ ] **Step 3: Commit the failing test**

```bash
git add test/features/tracking/data/repositories/tracking_repository_test.dart
git commit -m "test: cover backend-compatible tracking update payload"
```

---

### Task 2: Implement repository payload compatibility mapping

**Files:**
- Modify: `lib/features/tracking/data/repositories/tracking_repository.dart`

- [ ] **Step 1: Update `updateTracking` payload keys**

In `TrackingRepositoryImpl.updateTracking`, replace this block:

```dart
final data = <String, dynamic>{
  'mediaType': mediaType.apiValue,
  if (status != null) 'status': status,
  if (rating != null) 'rating': rating,
  if (review != null) 'review': review,
  if (seasonRatings != null) 'seasonRatings': seasonRatings,
};
```

with:

```dart
final data = <String, dynamic>{
  'mediaType': mediaType.apiValue,
  if (status != null) 'status': status,
  if (rating != null) 'seriesRating': rating,
  if (review != null) 'seriesReview': review,
  if (seasonRatings != null) 'seasonRatings': seasonRatings,
};
```

- [ ] **Step 2: Run the focused repository test**

Run:

```bash
flutter test test/features/tracking/data/repositories/tracking_repository_test.dart
```

Expected: PASS. The new payload test should pass, and existing repository tests should still pass.

- [ ] **Step 3: Run related viewmodel tests**

Run:

```bash
flutter test test/features/series/viewmodels/series_detail_viewmodel_test.dart test/features/movies/viewmodels/movie_detail_viewmodel_test.dart
```

Expected: PASS. Viewmodels should remain unchanged because the repository method signature did not change.

- [ ] **Step 4: Commit the implementation**

```bash
git add lib/features/tracking/data/repositories/tracking_repository.dart
git commit -m "fix: send backend-compatible tracking update fields"
```

---

### Task 3: Verify and document final state

**Files:**
- No source edits expected.

- [ ] **Step 1: Run analyzer wrapper**

Run:

```bash
make analyze
```

Expected: PASS. Existing infos/warnings may be accepted by the wrapper according to project conventions.

- [ ] **Step 2: Run focused tests together**

Run:

```bash
flutter test test/features/tracking/data/repositories/tracking_repository_test.dart test/features/series/viewmodels/series_detail_viewmodel_test.dart test/features/movies/viewmodels/movie_detail_viewmodel_test.dart
```

Expected: PASS.

- [ ] **Step 3: Manual API verification**

Run the app and repeat the previously failing flow:

1. Open a tracked series.
2. Open **Manage Tracking**.
3. Change rating from 7 to 8.
4. Tap **Save Changes**.
5. Confirm diagnostic log now shows request data containing `seriesRating: 8`.
6. Confirm API response and subsequent `build()` show `rating=8`.

Expected diagnostic pattern:

```txt
[SERIES_VM] updateTracking calling API: mediaId=124101 status=WATCHING rating=8 review=null
...
data:
{mediaType: SERIES, status: WATCHING, seriesRating: 8}
...
[SERIES_VM] build() found tracking: rating=8 status=WATCHING
```

- [ ] **Step 4: Commit verification note if any docs changed**

No commit is needed if no files changed. If a verification note is added to docs, commit it with:

```bash
git add docs/superpowers/plans/2026-05-20-tracking-update-payload.md
git commit -m "docs: add tracking payload verification notes"
```

---

## Self-Review

- Spec coverage: This plan covers the approved frontend-only compatibility fix, repository tests, focused verification, and keeps diagnostic logs.
- Placeholder scan: No TBD/TODO/placeholders remain.
- Type consistency: Uses existing `TrackingRepositoryImpl.updateTracking`, `MediaType.series`, `rating`, `review`, `seriesRating`, and `seriesReview` names consistently.
