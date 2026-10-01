import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/cache/cache_entry.dart';
import 'package:lorebase/core/cache/cache_service.dart';
import 'package:lorebase/core/cache/cache_providers.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';
import 'package:lorebase/features/series/data/repositories/series_repository.dart';
import 'package:lorebase/features/series/viewmodels/series_detail_viewmodel.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_model.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_section_model.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:lorebase/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:lorebase/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_summary_model.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/features/tracking/data/repositories/tracking_repository.dart';
import 'package:lorebase/features/tracking/data/tracking_cache.dart';
import 'package:lorebase/features/tracking/data/models/tracking_page_model.dart';

class FakeSeriesRepo implements SeriesRepository {
  SeriesModel? seriesResult;
  bool shouldThrow = false;
  Completer<SeriesModel>? seriesCompleter;
  void Function()? onGetSeriesById;

  @override
  Future<SeriesModel> getSeriesById(String id) async {
    onGetSeriesById?.call();
    if (seriesCompleter != null) return seriesCompleter!.future;
    if (shouldThrow) throw Exception('not found');
    if (seriesResult != null) return seriesResult!;
    throw UnimplementedError();
  }

  @override
  Future<List<SeriesModel>> searchSeries(
    String query, {
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    throw UnimplementedError();
  }
}

class FakeDashboardRepo implements DashboardRepository {
  DashboardModel dashboard = const DashboardModel(
    watching: DashboardSectionModel(),
    wantToWatch: DashboardSectionModel(),
    completed: DashboardSectionModel(),
    dropped: DashboardSectionModel(),
    stats: DashboardStatsModel(),
  );

  @override
  Future<DashboardModel> getDashboard({
    MediaType mediaType = MediaType.series,
  }) async => dashboard;
}

class FakeTrackingRepo implements TrackingRepository {
  List<TrackedMediaModel> trackingResults = [];
  TrackedMediaModel? trackingByMediaResult;
  bool shouldThrowTracking = false;
  bool shouldThrowUpdate = false;
  int getTrackingCallCount = 0;
  int getTrackingByMediaCallCount = 0;
  String? lastGetTrackingByMediaId;
  TrackedMediaModel? lastStartedTracking;
  TrackedMediaModel? lastUpdatedTracking;
  String? lastDeletedMediaId;
  MediaType? lastMediaType;
  Map<String, dynamic>? lastUpdatedFields;
  Completer<TrackedMediaModel?>? trackingByMediaCompleter;
  void Function()? onGetTrackingByMedia;

  @override
  Future<TrackingPage> getTracking({
    String? status,
    MediaType? mediaType,
    int pageSize = 20,
    String? cursor,
  }) async {
    getTrackingCallCount++;
    lastMediaType = mediaType;
    if (shouldThrowTracking) throw Exception('failed');
    return TrackingPage(items: trackingResults, totalCount: trackingResults.length);
  }

  @override
  Future<TrackedMediaModel?> getTrackingByMedia(
    String mediaId,
    MediaType mediaType,
  ) async {
    getTrackingByMediaCallCount++;
    lastGetTrackingByMediaId = mediaId;
    lastMediaType = mediaType;
    onGetTrackingByMedia?.call();
    if (trackingByMediaCompleter != null) {
      return trackingByMediaCompleter!.future;
    }
    if (shouldThrowTracking) throw Exception('failed');
    return trackingByMediaResult;
  }

  @override
  Future<TrackedMediaModel> startTracking(
    String mediaId,
    MediaType mediaType,
    String status, {
    String? selectedPlatform,
    double? hoursPlayed,
    int? rating,
    String? review,
  }) async {
    final now = DateTime.now();
    final result = TrackedMediaModel(
      trackingId: 'track-$mediaId',
      userId: 'user-1',
      mediaType: mediaType,
      mediaId: mediaId,
      status: status,
      rating: rating,
      review: review,
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
    String? selectedPlatform,
    double? hoursPlayed,
    List<Map<String, dynamic>>? seasonRatings,
  }) async {
    if (shouldThrowUpdate) throw Exception('update failed');
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
      CacheService? cache,
    }) {
      return ProviderContainer(
        overrides: [
          seriesRepositoryProvider.overrideWith((ref) => seriesRepo),
          trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
          cacheServiceProvider.overrideWith((ref) => cache ?? CacheService()),
        ],
      );
    }

    test('updating tracking refreshes an active dashboard', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo()
        ..trackingByMediaResult = TrackedMediaModel(
          trackingId: 'track-42',
          userId: 'user-1',
          mediaType: MediaType.series,
          mediaId: '42',
          status: 'WATCHING',
          addedAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );
      final dashboardRepo = FakeDashboardRepo()
        ..dashboard = const DashboardModel(
          watching: DashboardSectionModel(),
          wantToWatch: DashboardSectionModel(),
          completed: DashboardSectionModel(),
          dropped: DashboardSectionModel(),
          stats: DashboardStatsModel(watchingCount: 1),
        );
      final container = ProviderContainer(
        overrides: [
          seriesRepositoryProvider.overrideWith((ref) => seriesRepo),
          trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
          dashboardRepositoryProvider.overrideWith((ref) => dashboardRepo),
          cacheServiceProvider.overrideWith((ref) => CacheService()),
        ],
      );
      addTearDown(container.dispose);

      final dashboardSubscription = container.listen(
        dashboardViewModelProvider,
        (_, _) {},
      );
      addTearDown(dashboardSubscription.close);
      await container.read(dashboardViewModelProvider.notifier).refresh();
      await container.read(seriesDetailViewModelProvider(42).future);

      dashboardRepo.dashboard = const DashboardModel(
        watching: DashboardSectionModel(),
        wantToWatch: DashboardSectionModel(),
        completed: DashboardSectionModel(),
        dropped: DashboardSectionModel(),
        stats: DashboardStatsModel(watchingCount: 0, completedCount: 1),
      );
      await container
          .read(seriesDetailViewModelProvider(42).notifier)
          .updateTracking(status: 'COMPLETED');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(
        container.read(dashboardViewModelProvider).value!.stats.completedCount,
        1,
      );
    });

    test(
      'build() uses direct tracking lookup with media id and type',
      () async {
        final seriesRepo = FakeSeriesRepo()
          ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
        final trackingRepo = FakeTrackingRepo()
          ..trackingByMediaResult = TrackedMediaModel(
            trackingId: 'track-42',
            userId: 'user-1',
            mediaType: MediaType.series,
            mediaId: '42',
            status: 'WATCHING',
            addedAt: DateTime.now(),
            lastUpdated: DateTime.now(),
          );
        final container = createContainer(
          seriesRepo: seriesRepo,
          trackingRepo: trackingRepo,
        );
        addTearDown(container.dispose);

        final state = await container.read(
          seriesDetailViewModelProvider(42).future,
        );

        expect(state.tracking, trackingRepo.trackingByMediaResult);
        expect(trackingRepo.lastGetTrackingByMediaId, '42');
        expect(trackingRepo.lastMediaType, MediaType.series);
        expect(trackingRepo.getTrackingByMediaCallCount, 1);
        expect(trackingRepo.getTrackingCallCount, 0);
      },
    );

    test(
      'build() starts series detail and direct tracking requests concurrently',
      () async {
        final events = <String>[];
        final seriesCompleter = Completer<SeriesModel>();
        final trackingCompleter = Completer<TrackedMediaModel?>();
        final seriesRepo = FakeSeriesRepo()
          ..seriesCompleter = seriesCompleter
          ..onGetSeriesById = () => events.add('series-start');
        final trackingRepo = FakeTrackingRepo()
          ..trackingByMediaCompleter = trackingCompleter
          ..onGetTrackingByMedia = () => events.add('tracking-start');
        final container = createContainer(
          seriesRepo: seriesRepo,
          trackingRepo: trackingRepo,
        );
        addTearDown(container.dispose);

        final future = container.read(seriesDetailViewModelProvider(42).future);
        await Future<void>.delayed(Duration.zero);

        expect(events, ['series-start', 'tracking-start']);

        seriesCompleter.complete(
          const SeriesModel(tmdbId: 42, title: 'Test Show'),
        );
        trackingCompleter.complete(null);
        await future;
      },
    );

    test(
      'build() returns SeriesDetailState with series and tracking',
      () async {
        final seriesRepo = FakeSeriesRepo()
          ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
        final trackingRepo = FakeTrackingRepo()
          ..trackingByMediaResult = TrackedMediaModel(
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
          );
        final container = createContainer(
          seriesRepo: seriesRepo,
          trackingRepo: trackingRepo,
        );
        addTearDown(container.dispose);

        final future = container.read(seriesDetailViewModelProvider(42).future);
        final state = await future;

        expect(state.series.tmdbId, 42);
        expect(state.series.title, 'Test Show');
        expect(state.tracking, isNotNull);
        expect(state.tracking!.status, 'WATCHING');
        expect(trackingRepo.lastMediaType, MediaType.series);
      },
    );

    test('build() with no matching tracking returns null tracking', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo();
      final container = createContainer(
        seriesRepo: seriesRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      final future = container.read(seriesDetailViewModelProvider(42).future);
      final state = await future;

      expect(state.series.tmdbId, 42);
      expect(state.tracking, isNull);
    });

    test('build() with tracking error returns null tracking', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo()..shouldThrowTracking = true;
      final container = createContainer(
        seriesRepo: seriesRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      final future = container.read(seriesDetailViewModelProvider(42).future);
      final state = await future;

      expect(state.series.tmdbId, 42);
      expect(state.tracking, isNull);
    });

    test(
      'build() handles fast tracking error while series detail is pending',
      () async {
        final seriesCompleter = Completer<SeriesModel>();
        final seriesRepo = FakeSeriesRepo()..seriesCompleter = seriesCompleter;
        final trackingRepo = FakeTrackingRepo()..shouldThrowTracking = true;
        final container = createContainer(
          seriesRepo: seriesRepo,
          trackingRepo: trackingRepo,
        );
        addTearDown(container.dispose);

        final future = container.read(seriesDetailViewModelProvider(42).future);
        await Future<void>.delayed(Duration.zero);
        seriesCompleter.complete(
          const SeriesModel(tmdbId: 42, title: 'Test Show'),
        );

        final state = await future;

        expect(state.series.tmdbId, 42);
        expect(state.tracking, isNull);
      },
    );

    test('build() matches tracking by nested media.tmdbId', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo()
        ..trackingByMediaResult = TrackedMediaModel(
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
        );
      final container = createContainer(
        seriesRepo: seriesRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      final future = container.read(seriesDetailViewModelProvider(42).future);
      final state = await future;

      expect(state.tracking, isNotNull);
      expect(state.tracking!.status, 'WATCHING');
    });

    test('addTracking() without rating creates tracking', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo();
      final container = createContainer(
        seriesRepo: seriesRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      await container.read(seriesDetailViewModelProvider(42).future);
      await container
          .read(seriesDetailViewModelProvider(42).notifier)
          .addTracking('WANT_TO_WATCH');

      expect(trackingRepo.lastStartedTracking, isNotNull);
      expect(trackingRepo.lastStartedTracking!.status, 'WANT_TO_WATCH');
    });

    test(
      'addTracking() with rating and review sends them in startTracking',
      () async {
        final seriesRepo = FakeSeriesRepo()
          ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
        final trackingRepo = FakeTrackingRepo();
        final container = createContainer(
          seriesRepo: seriesRepo,
          trackingRepo: trackingRepo,
        );
        addTearDown(container.dispose);

        await container.read(seriesDetailViewModelProvider(42).future);
        await container
            .read(seriesDetailViewModelProvider(42).notifier)
            .addTracking('WATCHING', rating: 8, review: 'Great!');

        expect(trackingRepo.lastStartedTracking, isNotNull);
        expect(trackingRepo.lastStartedTracking!.rating, 8);
        expect(trackingRepo.lastStartedTracking!.review, 'Great!');
        expect(trackingRepo.lastUpdatedFields, isNull);
      },
    );

    test('updateTracking() with rating calls repo', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo()
        ..trackingByMediaResult = TrackedMediaModel(
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
        );
      final container = createContainer(
        seriesRepo: seriesRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      await container.read(seriesDetailViewModelProvider(42).future);
      await container
          .read(seriesDetailViewModelProvider(42).notifier)
          .updateTracking(rating: 8, review: 'Great');

      expect(trackingRepo.lastUpdatedFields, isNotNull);
      expect(trackingRepo.lastUpdatedFields!['rating'], 8);
      expect(trackingRepo.lastUpdatedFields!['review'], 'Great');
    });

    test('updateTracking() rethrows repository error', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo()
        ..shouldThrowUpdate = true
        ..trackingByMediaResult = TrackedMediaModel(
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
        );
      final container = createContainer(
        seriesRepo: seriesRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      await container.read(seriesDetailViewModelProvider(42).future);

      expect(
        () => container
            .read(seriesDetailViewModelProvider(42).notifier)
            .updateTracking(rating: 8),
        throwsException,
      );
    });

    test(
      'removeTracking() calls deleteTracking with correct mediaId',
      () async {
        final seriesRepo = FakeSeriesRepo()
          ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
        final trackingRepo = FakeTrackingRepo()
          ..trackingByMediaResult = TrackedMediaModel(
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
          );
        final container = createContainer(
          seriesRepo: seriesRepo,
          trackingRepo: trackingRepo,
        );
        addTearDown(container.dispose);

        await container.read(seriesDetailViewModelProvider(42).future);
        await container
            .read(seriesDetailViewModelProvider(42).notifier)
            .removeTracking();

        expect(trackingRepo.lastDeletedMediaId, '42');
      },
    );

    test('updateTracking() no-ops when state is null', () async {
      final seriesRepo = FakeSeriesRepo();
      final trackingRepo = FakeTrackingRepo();
      final container = createContainer(
        seriesRepo: seriesRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      await container
          .read(seriesDetailViewModelProvider(42).notifier)
          .updateTracking(rating: 5);

      expect(trackingRepo.lastUpdatedFields, isNull);
    });

    test('updateTracking() no-ops when tracking is null in state', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo();
      final container = createContainer(
        seriesRepo: seriesRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      await container.read(seriesDetailViewModelProvider(42).future);
      await container
          .read(seriesDetailViewModelProvider(42).notifier)
          .updateTracking(rating: 5);

      expect(trackingRepo.lastUpdatedFields, isNull);
    });

    test('removeTracking() no-ops when state is null', () async {
      final seriesRepo = FakeSeriesRepo();
      final trackingRepo = FakeTrackingRepo();
      final container = createContainer(
        seriesRepo: seriesRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      await container
          .read(seriesDetailViewModelProvider(42).notifier)
          .removeTracking();

      expect(trackingRepo.lastDeletedMediaId, isNull);
    });

    test(
      'updateTracking() invalidates the versioned tracking list cache',
      () async {
        final seriesRepo = FakeSeriesRepo()
          ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
        final trackingRepo = FakeTrackingRepo()
          ..trackingByMediaResult = TrackedMediaModel(
            trackingId: 'track-42',
            userId: 'user-1',
            mediaType: MediaType.series,
            mediaId: '42',
            status: 'WATCHING',
            addedAt: DateTime.now(),
            lastUpdated: DateTime.now(),
          );
        final cache = CacheService();
        await cache.set('dashboard:v2:SERIES', CacheEntry.test());
        await cache.set('${trackingCachePrefix}SERIES:all', CacheEntry.test());

        final container = createContainer(
          seriesRepo: seriesRepo,
          trackingRepo: trackingRepo,
          cache: cache,
        );
        addTearDown(container.dispose);

        await container.read(seriesDetailViewModelProvider(42).future);
        await container
            .read(seriesDetailViewModelProvider(42).notifier)
            .updateTracking(rating: 8);

        expect(cache.getSync('dashboard:v2:SERIES'), isNull);
        expect(cache.getSync('${trackingCachePrefix}SERIES:all'), isNull);
      },
    );

    test('removeTracking() no-ops when tracking is null in state', () async {
      final seriesRepo = FakeSeriesRepo()
        ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
      final trackingRepo = FakeTrackingRepo();
      final container = createContainer(
        seriesRepo: seriesRepo,
        trackingRepo: trackingRepo,
      );
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
      final container = createContainer(
        seriesRepo: seriesRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      await container
          .read(seriesDetailViewModelProvider(42).notifier)
          .addTracking('WANT_TO_WATCH');

      expect(trackingRepo.lastStartedTracking, isNull);
    });

    test(
      'addTracking() with empty review and no rating never calls updateTracking',
      () async {
        final seriesRepo = FakeSeriesRepo()
          ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
        final trackingRepo = FakeTrackingRepo();
        final container = createContainer(
          seriesRepo: seriesRepo,
          trackingRepo: trackingRepo,
        );
        addTearDown(container.dispose);

        await container.read(seriesDetailViewModelProvider(42).future);
        await container
            .read(seriesDetailViewModelProvider(42).notifier)
            .addTracking('WATCHING', review: '');

        expect(trackingRepo.lastStartedTracking, isNotNull);
        expect(trackingRepo.lastUpdatedFields, isNull);
      },
    );

    test(
      'addTracking() with non-empty review and no rating sends review in startTracking',
      () async {
        final seriesRepo = FakeSeriesRepo()
          ..seriesResult = const SeriesModel(tmdbId: 42, title: 'Test Show');
        final trackingRepo = FakeTrackingRepo();
        final container = createContainer(
          seriesRepo: seriesRepo,
          trackingRepo: trackingRepo,
        );
        addTearDown(container.dispose);

        await container.read(seriesDetailViewModelProvider(42).future);
        await container
            .read(seriesDetailViewModelProvider(42).notifier)
            .addTracking('WATCHING', review: 'Nice show');

        expect(trackingRepo.lastStartedTracking, isNotNull);
        expect(trackingRepo.lastStartedTracking!.rating, isNull);
        expect(trackingRepo.lastStartedTracking!.review, 'Nice show');
        expect(trackingRepo.lastUpdatedFields, isNull);
      },
    );
  });
}
