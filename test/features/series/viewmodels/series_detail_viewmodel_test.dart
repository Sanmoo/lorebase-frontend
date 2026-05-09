import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/cache/cache_service.dart';
import 'package:lorebase/core/cache/cache_providers.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';
import 'package:lorebase/features/series/data/repositories/series_repository.dart';
import 'package:lorebase/features/series/viewmodels/series_detail_viewmodel.dart';
import 'package:lorebase/features/tracking/data/models/tracked_series_model.dart';
import 'package:lorebase/features/tracking/data/repositories/tracking_repository.dart';

class FakeSeriesRepo implements SeriesRepository {
  SeriesModel? seriesResult;
  bool shouldThrow = false;

  @override
  Future<SeriesModel> getSeriesById(String id) async {
    if (shouldThrow) throw Exception('not found');
    if (seriesResult != null) return seriesResult!;
    throw UnimplementedError();
  }

  @override
  Future<List<SeriesModel>> searchSeries(String query,
      {int limit = 20, CancelToken? cancelToken}) async {
    throw UnimplementedError();
  }
}

class FakeTrackingRepo implements TrackingRepository {
  List<TrackedSeriesModel> trackingResults = [];
  bool shouldThrowTracking = false;
  TrackedSeriesModel? lastStartedTracking;
  TrackedSeriesModel? lastUpdatedTracking;
  String? lastDeletedSeriesId;
  Map<String, dynamic>? lastUpdatedFields;

  @override
  Future<List<TrackedSeriesModel>> getTracking(
      {String? status, int pageSize = 20, int page = 1}) async {
    if (shouldThrowTracking) throw Exception('failed');
    return trackingResults;
  }

  @override
  Future<TrackedSeriesModel> startTracking(
      String seriesId, String status) async {
    final now = DateTime.now();
    final result = TrackedSeriesModel(
      trackingId: 'track-$seriesId',
      userId: 'user-1',
      seriesId: seriesId,
      status: status,
      addedAt: now,
      lastUpdated: now,
    );
    lastStartedTracking = result;
    return result;
  }

  @override
  Future<TrackedSeriesModel> updateTracking(String seriesId,
      {String? status,
      int? seriesRating,
      String? seriesReview,
      List<Map<String, dynamic>>? seasonRatings}) async {
    lastUpdatedFields = <String, dynamic>{
      'seriesRating': seriesRating,
      'seriesReview': seriesReview,
      'status': status,
    };
    final now = DateTime.now();
    final result = TrackedSeriesModel(
      trackingId: 'track-$seriesId',
      userId: 'user-1',
      seriesId: seriesId,
      status: status ?? '',
      addedAt: now,
      lastUpdated: now,
    );
    lastUpdatedTracking = result;
    return result;
  }

  @override
  Future<void> deleteTracking(String seriesId) async {
    lastDeletedSeriesId = seriesId;
  }
}

void main() {
  group('SeriesDetailViewModel', () {
    ProviderContainer createContainer({
      required FakeSeriesRepo seriesRepo,
      required FakeTrackingRepo trackingRepo,
    }) {
      return ProviderContainer(overrides: [
        seriesRepositoryProvider.overrideWith((ref) => seriesRepo),
        trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
        cacheServiceProvider.overrideWith((ref) => CacheService()),
      ]);
    }

    test('build() returns SeriesDetailState with series and tracking', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo()
        ..trackingResults = [
          TrackedSeriesModel(
            trackingId: 'track-42',
            userId: 'user-1',
            seriesId: '42',
            status: 'WATCHING',
            series: const SeriesModel(tmdbId: 42, title: 'Test Show'),
            addedAt: DateTime.now(),
            lastUpdated: DateTime.now(),
          ),
        ];
      final container =
          createContainer(seriesRepo: seriesRepo, trackingRepo: trackingRepo);
      addTearDown(container.dispose);

      final future =
          container.read(seriesDetailViewModelProvider(42).future);
      final state = await future;

      expect(state.series.tmdbId, 42);
      expect(state.series.title, 'Test Show');
      expect(state.tracking, isNotNull);
      expect(state.tracking!.status, 'WATCHING');
    });

    test('build() with no matching tracking returns null tracking', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo()
        ..trackingResults = [
          TrackedSeriesModel(
            trackingId: 'track-99',
            userId: 'user-1',
            seriesId: '99',
            status: 'WATCHING',
            addedAt: DateTime.now(),
            lastUpdated: DateTime.now(),
          ),
        ];
      final container =
          createContainer(seriesRepo: seriesRepo, trackingRepo: trackingRepo);
      addTearDown(container.dispose);

      final future =
          container.read(seriesDetailViewModelProvider(42).future);
      final state = await future;

      expect(state.series.tmdbId, 42);
      expect(state.tracking, isNull);
    });

    test('build() with tracking error returns null tracking', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo()..shouldThrowTracking = true;
      final container =
          createContainer(seriesRepo: seriesRepo, trackingRepo: trackingRepo);
      addTearDown(container.dispose);

      final future =
          container.read(seriesDetailViewModelProvider(42).future);
      final state = await future;

      expect(state.series.tmdbId, 42);
      expect(state.tracking, isNull);
    });

    test('build() matches tracking by nested series.tmdbId', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo()
        ..trackingResults = [
          TrackedSeriesModel(
            trackingId: 'track-not42',
            userId: 'user-1',
            seriesId: 'not42',
            status: 'WATCHING',
            series: const SeriesModel(tmdbId: 42, title: 'Test Show'),
            addedAt: DateTime.now(),
            lastUpdated: DateTime.now(),
          ),
        ];
      final container =
          createContainer(seriesRepo: seriesRepo, trackingRepo: trackingRepo);
      addTearDown(container.dispose);

      final future =
          container.read(seriesDetailViewModelProvider(42).future);
      final state = await future;

      expect(state.tracking, isNotNull);
      expect(state.tracking!.status, 'WATCHING');
    });

    test('addTracking() without rating creates tracking', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo();
      final container =
          createContainer(seriesRepo: seriesRepo, trackingRepo: trackingRepo);
      addTearDown(container.dispose);

      await container.read(seriesDetailViewModelProvider(42).future);
      await container
          .read(seriesDetailViewModelProvider(42).notifier)
          .addTracking('WANT_TO_WATCH');

      expect(trackingRepo.lastStartedTracking, isNotNull);
      expect(trackingRepo.lastStartedTracking!.status, 'WANT_TO_WATCH');
    });

    test('addTracking() with rating and review calls updateTracking', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo();
      final container =
          createContainer(seriesRepo: seriesRepo, trackingRepo: trackingRepo);
      addTearDown(container.dispose);

      await container.read(seriesDetailViewModelProvider(42).future);
      await container
          .read(seriesDetailViewModelProvider(42).notifier)
          .addTracking('WATCHING', seriesRating: 8, seriesReview: 'Great!');

      expect(trackingRepo.lastStartedTracking, isNotNull);
      expect(trackingRepo.lastUpdatedFields, isNotNull);
      expect(trackingRepo.lastUpdatedFields!['seriesRating'], 8);
      expect(trackingRepo.lastUpdatedFields!['seriesReview'], 'Great!');
    });

    test('updateTracking() with rating calls repo', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo()
        ..trackingResults = [
          TrackedSeriesModel(
            trackingId: 'track-42',
            userId: 'user-1',
            seriesId: '42',
            status: 'WATCHING',
            series: const SeriesModel(tmdbId: 42, title: 'Test Show'),
            addedAt: DateTime.now(),
            lastUpdated: DateTime.now(),
          ),
        ];
      final container =
          createContainer(seriesRepo: seriesRepo, trackingRepo: trackingRepo);
      addTearDown(container.dispose);

      await container.read(seriesDetailViewModelProvider(42).future);
      await container
          .read(seriesDetailViewModelProvider(42).notifier)
          .updateTracking(seriesRating: 8, seriesReview: 'Great');

      expect(trackingRepo.lastUpdatedFields, isNotNull);
      expect(trackingRepo.lastUpdatedFields!['seriesRating'], 8);
      expect(trackingRepo.lastUpdatedFields!['seriesReview'], 'Great');
    });

    test('removeTracking() calls deleteTracking with correct seriesId',
        () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo()
        ..trackingResults = [
          TrackedSeriesModel(
            trackingId: 'track-42',
            userId: 'user-1',
            seriesId: '42',
            status: 'WATCHING',
            series: const SeriesModel(tmdbId: 42, title: 'Test Show'),
            addedAt: DateTime.now(),
            lastUpdated: DateTime.now(),
          ),
        ];
      final container =
          createContainer(seriesRepo: seriesRepo, trackingRepo: trackingRepo);
      addTearDown(container.dispose);

      await container.read(seriesDetailViewModelProvider(42).future);
      await container
          .read(seriesDetailViewModelProvider(42).notifier)
          .removeTracking();

      expect(trackingRepo.lastDeletedSeriesId, '42');
    });

    test('updateTracking() no-ops when state is null', () async {
      final seriesRepo = FakeSeriesRepo();
      final trackingRepo = FakeTrackingRepo();
      final container =
          createContainer(seriesRepo: seriesRepo, trackingRepo: trackingRepo);
      addTearDown(container.dispose);

      await container
          .read(seriesDetailViewModelProvider(42).notifier)
          .updateTracking(seriesRating: 5);

      expect(trackingRepo.lastUpdatedFields, isNull);
    });

    test('removeTracking() no-ops when tracking is null in state', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo();
      final container =
          createContainer(seriesRepo: seriesRepo, trackingRepo: trackingRepo);
      addTearDown(container.dispose);

      await container.read(seriesDetailViewModelProvider(42).future);
      await container
          .read(seriesDetailViewModelProvider(42).notifier)
          .removeTracking();

      expect(trackingRepo.lastDeletedSeriesId, isNull);
    });

    test('addTracking() no-ops when state is null', () async {
      final seriesRepo = FakeSeriesRepo();
      final trackingRepo = FakeTrackingRepo();
      final container =
          createContainer(seriesRepo: seriesRepo, trackingRepo: trackingRepo);
      addTearDown(container.dispose);

      await container
          .read(seriesDetailViewModelProvider(42).notifier)
          .addTracking('WANT_TO_WATCH');

      expect(trackingRepo.lastStartedTracking, isNull);
    });

    test('addTracking() with empty review and no rating calls updateTracking', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo();
      final container =
          createContainer(seriesRepo: seriesRepo, trackingRepo: trackingRepo);
      addTearDown(container.dispose);

      await container.read(seriesDetailViewModelProvider(42).future);
      await container
          .read(seriesDetailViewModelProvider(42).notifier)
          .addTracking('WATCHING', seriesReview: '');

      expect(trackingRepo.lastStartedTracking, isNotNull);
      expect(trackingRepo.lastUpdatedFields, isNull);
    });

    test('addTracking() with non-empty review and no rating calls updateTracking', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo();
      final container =
          createContainer(seriesRepo: seriesRepo, trackingRepo: trackingRepo);
      addTearDown(container.dispose);

      await container.read(seriesDetailViewModelProvider(42).future);
      await container
          .read(seriesDetailViewModelProvider(42).notifier)
          .addTracking('WATCHING', seriesReview: 'Nice show');

      expect(trackingRepo.lastStartedTracking, isNotNull);
      expect(trackingRepo.lastUpdatedFields, isNotNull);
      expect(trackingRepo.lastUpdatedFields!['seriesReview'], 'Nice show');
    });
  });
}
