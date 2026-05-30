# Direct Tracking Lookup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace broad tracking list scans on media detail pages with the new backend direct tracking lookup endpoint.

**Architecture:** Add a nullable direct lookup method to `TrackingRepository`, mapping backend `404` to `null` and preserving existing error handling for other failures. Update series and movie detail viewmodels to start media detail and direct tracking lookup futures immediately, then combine results into their existing state objects. Keep UI state shape unchanged: `tracking == null` still means show “Add to List”, and non-null tracking still means show “Manage Tracking”.

**Tech Stack:** Flutter 3.27, Dart/Riverpod codegen, Dio, Freezed models, flutter_test.

---

## Backend contract verified

The backend task `lorebase-backend:8` is done. The implemented contract is:

- `GET /tracking/{mediaId}?mediaType=series|movie`
- `200`: response body is the same tracking DTO shape used by existing list/start/update endpoints.
- `404`: no tracking exists for this user/media/type, or the stored tracking media type differs.
- `400`: missing or invalid `mediaType`.
- `401`: unauthenticated.

Frontend implication: `404` must be treated as “not tracked” (`null`), not as a detail page error.

## File structure

- Modify `lib/features/tracking/data/repositories/tracking_repository.dart`
  - Add `getTrackingByMedia(String mediaId, MediaType mediaType)` to the abstract repository.
  - Implement the new Dio `GET /tracking/$mediaId` call.
  - Map `DioException.response?.statusCode == 404` to `null`.
- Modify `lib/features/series/viewmodels/series_detail_viewmodel.dart`
  - Replace `getTracking(pageSize: 1000, mediaType: MediaType.series)` + local `firstWhere` scan with direct lookup.
  - Start series and tracking futures before awaiting either one.
- Modify `lib/features/movies/viewmodels/movie_detail_viewmodel.dart`
  - Apply the same direct lookup and parallel start pattern for movies.
- Modify `test/features/tracking/data/repositories/tracking_repository_test.dart`
  - Add repository tests for 200 direct lookup and 404-as-null.
- Modify `test/features/series/viewmodels/series_detail_viewmodel_test.dart`
  - Update `FakeTrackingRepo` to implement the new abstract method.
  - Add tests proving direct lookup is used and broad listing is not used.
  - Add a concurrency regression test proving detail and tracking futures are both started before either completes.
- Modify `test/features/movies/viewmodels/movie_detail_viewmodel_test.dart`
  - Update fake repository implementation.
  - Add direct lookup/no broad listing test for movies.

---

### Task 1: Add failing repository tests for direct tracking lookup

**Files:**
- Modify: `test/features/tracking/data/repositories/tracking_repository_test.dart`
- Later modify: `lib/features/tracking/data/repositories/tracking_repository.dart`

- [ ] **Step 1: Inspect existing repository test style**

Run:

```bash
sed -n '1,260p' test/features/tracking/data/repositories/tracking_repository_test.dart
```

Expected: See the existing Dio mock/interceptor style used for `getTracking`, `startTracking`, `updateTracking`, and `deleteTracking`.

- [ ] **Step 2: Write failing tests**

Add these tests inside the existing `TrackingRepositoryImpl` test group, adapting only helper names to match the current file:

```dart
test('getTrackingByMedia returns tracked media on 200', () async {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
  final adapter = _MockAdapter((options) async {
    expect(options.method, 'GET');
    expect(options.path, '/tracking/42');
    expect(options.queryParameters['mediaType'], 'series');
    return ResponseBody.fromString(
      '''{
        "trackingId":"track-42",
        "userId":"user-1",
        "mediaType":"SERIES",
        "mediaId":"42",
        "status":"WATCHING",
        "addedAt":"2024-01-01T00:00:00Z",
        "lastUpdated":"2024-01-02T00:00:00Z"
      }''',
      200,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );
  });
  dio.httpClientAdapter = adapter;
  final repo = TrackingRepositoryImpl(dio);

  final tracking = await repo.getTrackingByMedia('42', MediaType.series);

  expect(tracking, isNotNull);
  expect(tracking!.trackingId, 'track-42');
  expect(tracking.mediaId, '42');
  expect(tracking.mediaType, MediaType.series);
  expect(tracking.status, 'WATCHING');
});

test('getTrackingByMedia returns null on 404', () async {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
  final adapter = _MockAdapter((options) async {
    expect(options.method, 'GET');
    expect(options.path, '/tracking/42');
    expect(options.queryParameters['mediaType'], 'series');
    return ResponseBody.fromString(
      '{"code":"NOT_FOUND","message":"TrackedMedia not found"}',
      404,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );
  });
  dio.httpClientAdapter = adapter;
  final repo = TrackingRepositoryImpl(dio);

  final tracking = await repo.getTrackingByMedia('42', MediaType.series);

  expect(tracking, isNull);
});
```

If the file does not use `_MockAdapter`, create an equivalent test using the file’s existing Dio fake. Do not change production code in this step.

- [ ] **Step 3: Run tests to verify RED**

Run:

```bash
flutter test test/features/tracking/data/repositories/tracking_repository_test.dart --plain-name 'getTrackingByMedia'
```

Expected: FAIL because `TrackingRepositoryImpl` does not yet define `getTrackingByMedia`.

- [ ] **Step 4: Implement the repository method**

In `lib/features/tracking/data/repositories/tracking_repository.dart`, add this method to `abstract class TrackingRepository`:

```dart
Future<TrackedMediaModel?> getTrackingByMedia(
  String mediaId,
  MediaType mediaType,
);
```

Add this implementation to `TrackingRepositoryImpl`:

```dart
@override
Future<TrackedMediaModel?> getTrackingByMedia(
  String mediaId,
  MediaType mediaType,
) async {
  try {
    final response = await _dio.get(
      '/tracking/$mediaId',
      queryParameters: {'mediaType': mediaType.apiValue},
    );
    return TrackedMediaModel.fromJson(response.data);
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) return null;
    throw ServerException(
      message: e.message ?? 'Failed to load tracking',
      statusCode: e.response?.statusCode,
    );
  }
}
```

- [ ] **Step 5: Run tests to verify GREEN**

Run:

```bash
flutter test test/features/tracking/data/repositories/tracking_repository_test.dart --plain-name 'getTrackingByMedia'
```

Expected: PASS.

- [ ] **Step 6: Commit Task 1**

```bash
git add lib/features/tracking/data/repositories/tracking_repository.dart test/features/tracking/data/repositories/tracking_repository_test.dart
git commit -m "feat: add direct tracking lookup repository method"
```

---

### Task 2: Update series detail to use direct lookup and start futures in parallel

**Files:**
- Modify: `test/features/series/viewmodels/series_detail_viewmodel_test.dart`
- Modify: `lib/features/series/viewmodels/series_detail_viewmodel.dart`

- [ ] **Step 1: Update the fake repository for the new interface**

In `FakeTrackingRepo`, add fields:

```dart
TrackedMediaModel? directTrackingResult;
String? lastDirectMediaId;
MediaType? lastDirectMediaType;
int getTrackingCallCount = 0;
int getTrackingByMediaCallCount = 0;
Completer<List<TrackedMediaModel>>? trackingListCompleter;
Completer<TrackedMediaModel?>? directTrackingCompleter;
```

Modify `getTracking` to increment the count and optionally wait:

```dart
@override
Future<List<TrackedMediaModel>> getTracking({
  String? status,
  MediaType? mediaType,
  int pageSize = 20,
  int page = 1,
}) async {
  getTrackingCallCount += 1;
  lastMediaType = mediaType;
  if (trackingListCompleter != null) {
    return trackingListCompleter!.future;
  }
  if (shouldThrowTracking) throw Exception('failed');
  return trackingResults;
}
```

Add `getTrackingByMedia`:

```dart
@override
Future<TrackedMediaModel?> getTrackingByMedia(
  String mediaId,
  MediaType mediaType,
) async {
  getTrackingByMediaCallCount += 1;
  lastDirectMediaId = mediaId;
  lastDirectMediaType = mediaType;
  if (directTrackingCompleter != null) {
    return directTrackingCompleter!.future;
  }
  if (shouldThrowTracking) throw Exception('failed');
  return directTrackingResult;
}
```

- [ ] **Step 2: Write failing direct-lookup test**

Add this test to `SeriesDetailViewModel` group:

```dart
test('build() uses direct tracking lookup instead of broad tracking list', () async {
  final tracking = TrackedMediaModel(
    trackingId: 'track-42',
    userId: 'user-1',
    mediaType: MediaType.series,
    mediaId: '42',
    status: 'WATCHING',
    addedAt: DateTime.now(),
    lastUpdated: DateTime.now(),
  );
  final seriesRepo = FakeSeriesRepo()
    ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
  final trackingRepo = FakeTrackingRepo()
    ..directTrackingResult = tracking
    ..trackingResults = [];
  final container = createContainer(
    seriesRepo: seriesRepo,
    trackingRepo: trackingRepo,
  );
  addTearDown(container.dispose);

  final state = await container.read(seriesDetailViewModelProvider(42).future);

  expect(state.tracking, same(tracking));
  expect(trackingRepo.getTrackingByMediaCallCount, 1);
  expect(trackingRepo.lastDirectMediaId, '42');
  expect(trackingRepo.lastDirectMediaType, MediaType.series);
  expect(trackingRepo.getTrackingCallCount, 0);
});
```

- [ ] **Step 3: Write failing concurrency regression test**

Add a completer field to `FakeSeriesRepo`:

```dart
Completer<SeriesModel>? seriesCompleter;
int getSeriesByIdCallCount = 0;
```

Modify `getSeriesById`:

```dart
@override
Future<SeriesModel> getSeriesById(String id) async {
  getSeriesByIdCallCount += 1;
  if (seriesCompleter != null) return seriesCompleter!.future;
  if (shouldThrow) throw Exception('not found');
  if (seriesResult != null) return seriesResult!;
  throw UnimplementedError();
}
```

Add this test:

```dart
test('build() starts series and direct tracking requests without awaiting one before the other', () async {
  final seriesCompleter = Completer<SeriesModel>();
  final trackingCompleter = Completer<TrackedMediaModel?>();
  final seriesRepo = FakeSeriesRepo()..seriesCompleter = seriesCompleter;
  final trackingRepo = FakeTrackingRepo()
    ..directTrackingCompleter = trackingCompleter;
  final container = createContainer(
    seriesRepo: seriesRepo,
    trackingRepo: trackingRepo,
  );
  addTearDown(container.dispose);

  final future = container.read(seriesDetailViewModelProvider(42).future);
  await Future<void>.delayed(Duration.zero);

  expect(seriesRepo.getSeriesByIdCallCount, 1);
  expect(trackingRepo.getTrackingByMediaCallCount, 1);

  trackingCompleter.complete(null);
  seriesCompleter.complete(const SeriesModel(tmdbId: 42, title: 'Slow Show'));

  final state = await future;
  expect(state.series.title, 'Slow Show');
  expect(state.tracking, isNull);
});
```

- [ ] **Step 4: Run tests to verify RED**

Run:

```bash
flutter test test/features/series/viewmodels/series_detail_viewmodel_test.dart --plain-name 'direct tracking'
```

Expected: FAIL because the viewmodel still calls `getTracking` and does not start the direct lookup.

- [ ] **Step 5: Implement series detail direct lookup**

Replace the body of `build` in `lib/features/series/viewmodels/series_detail_viewmodel.dart` with:

```dart
@override
Future<SeriesDetailState> build(int tmdbId) async {
  debugPrint('[SERIES_VM] build() started for tmdbId=$tmdbId');
  final seriesRepo = ref.read(seriesRepositoryProvider);
  final trackingRepo = ref.read(trackingRepositoryProvider);
  final mediaId = tmdbId.toString();

  final seriesFuture = seriesRepo.getSeriesById(mediaId);
  final trackingFuture = trackingRepo.getTrackingByMedia(
    mediaId,
    MediaType.series,
  );

  final series = await seriesFuture;
  TrackedMediaModel? tracking;
  try {
    tracking = await trackingFuture;
    debugPrint(
      '[SERIES_VM] build() direct tracking lookup result: ${tracking == null ? 'not tracked' : 'status=${tracking.status}'}',
    );
  } catch (e) {
    debugPrint('[SERIES_VM] build() tracking lookup failed: $e');
    tracking = null;
  }

  return SeriesDetailState(series: series, tracking: tracking);
}
```

Keep imports unchanged unless analyzer reports an unused import.

- [ ] **Step 6: Run tests to verify GREEN**

Run:

```bash
flutter test test/features/series/viewmodels/series_detail_viewmodel_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit Task 2**

```bash
git add lib/features/series/viewmodels/series_detail_viewmodel.dart test/features/series/viewmodels/series_detail_viewmodel_test.dart
git commit -m "fix: load series tracking with direct lookup"
```

---

### Task 3: Update movie detail to use direct lookup

**Files:**
- Modify: `test/features/movies/viewmodels/movie_detail_viewmodel_test.dart`
- Modify: `lib/features/movies/viewmodels/movie_detail_viewmodel.dart`

- [ ] **Step 1: Update movie test fake for the new interface**

In the fake tracking repository in `test/features/movies/viewmodels/movie_detail_viewmodel_test.dart`, add the same method required by the interface:

```dart
TrackedMediaModel? directTrackingResult;
String? lastDirectMediaId;
MediaType? lastDirectMediaType;
int getTrackingCallCount = 0;
int getTrackingByMediaCallCount = 0;

@override
Future<TrackedMediaModel?> getTrackingByMedia(
  String mediaId,
  MediaType mediaType,
) async {
  getTrackingByMediaCallCount += 1;
  lastDirectMediaId = mediaId;
  lastDirectMediaType = mediaType;
  if (shouldThrowTracking) throw Exception('failed');
  return directTrackingResult;
}
```

Also increment `getTrackingCallCount` at the top of the existing `getTracking` fake method:

```dart
getTrackingCallCount += 1;
```

- [ ] **Step 2: Write failing movie direct-lookup test**

Add this test to the `MovieDetailViewModel` group, adapting `_testMovie` helper names if the file already has one:

```dart
test('build() uses direct movie tracking lookup instead of broad tracking list', () async {
  final tracking = TrackedMediaModel(
    trackingId: 'track-550',
    userId: 'user-1',
    mediaType: MediaType.movie,
    mediaId: '550',
    status: 'WATCHED',
    addedAt: DateTime.now(),
    lastUpdated: DateTime.now(),
  );
  final movieRepo = FakeMovieRepo()
    ..movieResult = const MovieModel(tmdbId: 550, title: 'Fight Club');
  final trackingRepo = FakeTrackingRepo()
    ..directTrackingResult = tracking
    ..trackingResults = [];
  final container = createContainer(
    movieRepo: movieRepo,
    trackingRepo: trackingRepo,
  );
  addTearDown(container.dispose);

  final state = await container.read(movieDetailViewModelProvider(550).future);

  expect(state.tracking, same(tracking));
  expect(trackingRepo.getTrackingByMediaCallCount, 1);
  expect(trackingRepo.lastDirectMediaId, '550');
  expect(trackingRepo.lastDirectMediaType, MediaType.movie);
  expect(trackingRepo.getTrackingCallCount, 0);
});
```

- [ ] **Step 3: Run tests to verify RED**

Run:

```bash
flutter test test/features/movies/viewmodels/movie_detail_viewmodel_test.dart --plain-name 'direct movie tracking'
```

Expected: FAIL because movie detail still calls `getTracking`.

- [ ] **Step 4: Implement movie direct lookup**

Replace the body of `build` in `lib/features/movies/viewmodels/movie_detail_viewmodel.dart` with:

```dart
@override
Future<MovieDetailState> build(int tmdbId) async {
  debugPrint('[MOVIE_VM] build() started for tmdbId=$tmdbId');
  final mediaId = tmdbId.toString();
  final movieFuture = ref.read(movieRepositoryProvider).getMovieById(mediaId);
  final trackingFuture = ref.read(trackingRepositoryProvider).getTrackingByMedia(
        mediaId,
        MediaType.movie,
      );

  final movie = await movieFuture;
  TrackedMediaModel? tracking;
  try {
    tracking = await trackingFuture;
    debugPrint(
      '[MOVIE_VM] build() direct tracking lookup result: ${tracking == null ? 'not tracked' : 'status=${tracking.status}'}',
    );
  } catch (e) {
    debugPrint('[MOVIE_VM] build() tracking lookup failed: $e');
    tracking = null;
  }
  return MovieDetailState(movie: movie, tracking: tracking);
}
```

- [ ] **Step 5: Run tests to verify GREEN**

Run:

```bash
flutter test test/features/movies/viewmodels/movie_detail_viewmodel_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit Task 3**

```bash
git add lib/features/movies/viewmodels/movie_detail_viewmodel.dart test/features/movies/viewmodels/movie_detail_viewmodel_test.dart
git commit -m "fix: load movie tracking with direct lookup"
```

---

### Task 4: Run generated-interface and regression checks

**Files:**
- Potentially modify tests that define `TrackingRepository` fakes.
- Do not edit generated files unless `build_runner` regenerates them due unrelated changes; this plan should not require generated changes.

- [ ] **Step 1: Find all fake implementations needing the new method**

Run:

```bash
rg "implements TrackingRepository" test lib
```

Expected: Every fake listed implements `getTrackingByMedia`. If any fake lacks it, add this minimal implementation when the test does not care about direct lookup:

```dart
@override
Future<TrackedMediaModel?> getTrackingByMedia(
  String mediaId,
  MediaType mediaType,
) async {
  return null;
}
```

- [ ] **Step 2: Run focused tests**

Run:

```bash
flutter test test/features/tracking/data/repositories/tracking_repository_test.dart test/features/series/viewmodels/series_detail_viewmodel_test.dart test/features/movies/viewmodels/movie_detail_viewmodel_test.dart
```

Expected: PASS.

- [ ] **Step 3: Run analyzer**

Run:

```bash
make analyze
```

Expected: PASS. If analyzer reports only formatting issues, run:

```bash
dart format lib/features/tracking/data/repositories/tracking_repository.dart lib/features/series/viewmodels/series_detail_viewmodel.dart lib/features/movies/viewmodels/movie_detail_viewmodel.dart test/features/tracking/data/repositories/tracking_repository_test.dart test/features/series/viewmodels/series_detail_viewmodel_test.dart test/features/movies/viewmodels/movie_detail_viewmodel_test.dart
make analyze
```

- [ ] **Step 4: Run targeted widget/page tests for labels**

Run:

```bash
flutter test test/features/series/pages/series_detail_page_test.dart test/features/movies/pages/movie_detail_page_test.dart
```

Expected: PASS. This verifies existing “Add to List” vs “Manage Tracking” UI still follows `tracking == null` / non-null state.

- [ ] **Step 5: Commit any remaining test-fake/analyzer fixes**

If Step 1 or Step 3 required additional fake updates, commit them:

```bash
git add test lib
git commit -m "test: update tracking repository fakes"
```

If no additional changes were needed, skip this commit.

---

### Task 5: Record WorkQ handoff note without closing the task

**Files:**
- No manual `.tasks` edits.

- [ ] **Step 1: Add WorkQ comment summarizing implementation**

Run:

```bash
workq comments add lorebase-frontend:task-000021 "Frontend updated to use backend direct tracking lookup endpoint GET /tracking/{mediaId}?mediaType=series|movie for series/movie detail pages. 404 is treated as not tracked; broad pageSize=1000 tracking scans removed from detail viewmodels. Focused tests and analyzer were run."
```

Expected: WorkQ reports `lorebase-frontend:21 commented`.

- [ ] **Step 2: Do not mark task done**

Do not run `workq done lorebase-frontend:task-000021` unless the human explicitly asks.

---

## Self-review

- Spec coverage: The plan covers backend contract integration, reliable tracking state, removal of broad/redundant tracking list calls on detail pages, 404-as-not-tracked behavior, series and movie parity, and tests for existing/non-existing tracking plus slow/parallel loading.
- Placeholder scan: No `TBD`, `TODO`, or unspecified implementation steps remain.
- Type consistency: The new method is consistently named `getTrackingByMedia(String mediaId, MediaType mediaType)` and returns `Future<TrackedMediaModel?>` across repository, implementation, and fakes.
