import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/cache/cache_service.dart';
import 'package:lorebase/core/cache/cache_providers.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';
import 'package:lorebase/features/series/data/repositories/series_repository.dart';
import 'package:lorebase/features/series/viewmodels/series_detail_viewmodel.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_summary_model.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
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
  List<TrackedMediaModel> trackingResults = [];
  bool shouldThrowTracking = false;
  TrackedMediaModel? lastStartedTracking;
  TrackedMediaModel? lastUpdatedTracking;
  String? lastDeletedMediaId;
  MediaType? lastMediaType;
  Map<String, dynamic>? lastUpdatedFields;

  @override
  Future<List<TrackedMediaModel>> getTracking({
    String? status,
    MediaType? mediaType,
    int pageSize = 20,
    int page = 1,
  }) async {
    lastMediaType = mediaType;
    if (shouldThrowTracking) throw Exception('failed');
    return trackingResults;
  }

  @override
  Future<TrackedMediaModel> startTracking(
    String mediaId,
    MediaType mediaType,
    String status,
  ) async {
    final now = DateTime.now();
    final result = TrackedMediaModel(
      trackingId: 'track-$mediaId',
      userId: 'user-1',
      mediaType: mediaType,
      mediaId: mediaId,
      status: status,
      addedAt: now,
      lastUpdated: now,
    );
    lastStartedTracking = result;
    return result;
  }

  @override
  Future<TrackedMediaModel> updateTracking(
    String mediaId, {
    required MediaType mediaType,
    String? status,
    int? rating,
    String? review,
    List<Map<String, dynamic>>? seasonRatings,
  }) async {
    lastUpdatedFields = <String, dynamic>{
      'rating': rating,
      'review': review,
      'status': status,
    };
    final now = DateTime.now();
    final result = TrackedMediaModel(
      trackingId: 'track-$mediaId',
      userId: 'user-1',
      mediaType: mediaType,
      mediaId: mediaId,
      status: status ?? '',
      addedAt: now,
      lastUpdated: now,
    );
    lastUpdatedTracking = result;
    return result;
  }

  @override
  Future<void> deleteTracking(
    String mediaId, {
    required MediaType mediaType,
  }) async {
    lastDeletedMediaId = mediaId;
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
          TrackedMediaModel(
            trackingId: 'track-42',
            userId: 'user-1',
            mediaType: MediaType.series,
            mediaId: '42',
            status: 'WATCHING',
            media: const TrackedMediaSummaryModel(
              mediaId: '42',
              title: 'Test Show',
              mediaType: MediaType.series,
            ),
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
      expect(trackingRepo.lastMediaType, MediaType.series);
    });

    test('build() with no matching tracking returns null tracking', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo()
        ..trackingResults = [
          TrackedMediaModel(
            trackingId: 'track-99',
            userId: 'user-1',
            mediaType: MediaType.series,
            mediaId: '99',
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

    test('build() matches tracking by nested media.tmdbId', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo()
        ..trackingResults = [
          TrackedMediaModel(
            trackingId: 'track-not42',
            userId: 'user-1',
            mediaType: MediaType.series,
            mediaId: 'not42',
            status: 'WATCHING',
            media: const TrackedMediaSummaryModel(
              mediaId: '42',
              title: 'Test Show',
              mediaType: MediaType.series,
            ),
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
          .addTracking('WATCHING', rating: 8, review: 'Great!');

      expect(trackingRepo.lastStartedTracking, isNotNull);
      expect(trackingRepo.lastUpdatedFields, isNotNull);
      expect(trackingRepo.lastUpdatedFields!['rating'], 8);
      expect(trackingRepo.lastUpdatedFields!['review'], 'Great!');
    });

    test('updateTracking() with rating calls repo', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo()
        ..trackingResults = [
          TrackedMediaModel(
            trackingId: 'track-42',
            userId: 'user-1',
            mediaType: MediaType.series,
            mediaId: '42',
            status: 'WATCHING',
            media: const TrackedMediaSummaryModel(
              mediaId: '42',
              title: 'Test Show',
              mediaType: MediaType.series,
            ),
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
          .updateTracking(rating: 8, review: 'Great');

      expect(trackingRepo.lastUpdatedFields, isNotNull);
      expect(trackingRepo.lastUpdatedFields!['rating'], 8);
      expect(trackingRepo.lastUpdatedFields!['review'], 'Great');
    });

    test('removeTracking() calls deleteTracking with correct mediaId',
        () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo()
        ..trackingResults = [
          TrackedMediaModel(
            trackingId: 'track-42',
            userId: 'user-1',
            mediaType: MediaType.series,
            mediaId: '42',
            status: 'WATCHING',
            media: const TrackedMediaSummaryModel(
              mediaId: '42',
              title: 'Test Show',
              mediaType: MediaType.series,
            ),
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

      expect(trackingRepo.lastDeletedMediaId, '42');
    });

    test('updateTracking() no-ops when state is null', () async {
      final seriesRepo = FakeSeriesRepo();
      final trackingRepo = FakeTrackingRepo();
      final container =
          createContainer(seriesRepo: seriesRepo, trackingRepo: trackingRepo);
      addTearDown(container.dispose);

      await container
          .read(seriesDetailViewModelProvider(42).notifier)
          .updateTracking(rating: 5);

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

      expect(trackingRepo.lastDeletedMediaId, isNull);
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
          .addTracking('WATCHING', review: '');

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
          .addTracking('WATCHING', review: 'Nice show');

      expect(trackingRepo.lastStartedTracking, isNotNull);
      expect(trackingRepo.lastUpdatedFields, isNotNull);
      expect(trackingRepo.lastUpdatedFields!['review'], 'Nice show');
    });
  });
}
