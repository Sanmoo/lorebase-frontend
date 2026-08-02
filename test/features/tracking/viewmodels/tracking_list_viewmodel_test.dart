import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/cache/cache_entry.dart';
import 'package:lorebase/core/cache/cache_service.dart';
import 'package:lorebase/core/cache/cache_providers.dart';
import 'package:lorebase/features/tracking/viewmodels/tracking_list_viewmodel.dart';
import 'package:lorebase/features/tracking/data/repositories/tracking_repository.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';

final now = DateTime.now();

TrackedMediaModel _makeTracking(
  String id,
  String status, {
  MediaType mediaType = MediaType.series,
}) => TrackedMediaModel(
  trackingId: id,
  userId: 'user-1',
  mediaType: mediaType,
  mediaId: '123',
  status: status,
  addedAt: now,
  lastUpdated: now,
);

class FakeTrackingRepo implements TrackingRepository {
  List<TrackedMediaModel>? results;
  bool shouldThrow = false;
  MediaType? lastMediaType;
  int getTrackingCallCount = 0;
  Completer<void>? delay;

  @override
  Future<List<TrackedMediaModel>> getTracking({
    String? status,
    MediaType? mediaType,
    int page = 1,
    int pageSize = 20,
  }) async {
    getTrackingCallCount++;
    lastMediaType = mediaType;
    await delay?.future;
    if (shouldThrow) throw Exception('Failed');
    return results ?? [];
  }

  @override
  Future<TrackedMediaModel?> getTrackingByMedia(
    String mediaId,
    MediaType mediaType,
  ) async {
    return null;
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
  }) async => _makeTracking('t-1', status);

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
  }) async => _makeTracking('t-1', status ?? 'WATCHING');

  @override
  Future<void> deleteTracking(
    String mediaId, {
    required MediaType mediaType,
  }) async {}
}

class QueuedTrackingRepo extends FakeTrackingRepo {
  final calls = <TrackingRequest>[];

  @override
  Future<List<TrackedMediaModel>> getTracking({
    String? status,
    MediaType? mediaType,
    int page = 1,
    int pageSize = 20,
  }) {
    getTrackingCallCount++;
    lastMediaType = mediaType;
    final request = TrackingRequest(
      status: status,
      mediaType: mediaType,
      page: page,
      completer: Completer<List<TrackedMediaModel>>(),
    );
    calls.add(request);
    return request.completer.future;
  }
}

class TrackingRequest {
  TrackingRequest({
    required this.status,
    required this.mediaType,
    required this.page,
    required this.completer,
  });

  final String? status;
  final MediaType? mediaType;
  final int page;
  final Completer<List<TrackedMediaModel>> completer;
}

class DelayedSetCacheService extends CacheService {
  final setStarted = Completer<void>();
  final allowSet = Completer<void>();

  Future<void> seed(String key, CacheEntry entry) => super.set(key, entry);

  @override
  Future<void> set(String key, CacheEntry entry) async {
    if (!setStarted.isCompleted) {
      setStarted.complete();
      await allowSet.future;
    }
    await super.set(key, entry);
  }
}

void main() {
  group('TrackingListViewModel', () {
    ProviderContainer createContainer(
      FakeTrackingRepo repo, {
      CacheService? cache,
    }) {
      return ProviderContainer(
        overrides: [
          trackingRepositoryProvider.overrideWith((ref) => repo),
          cacheServiceProvider.overrideWith((ref) => cache ?? CacheService()),
        ],
      );
    }

    test('build() returns empty list', () {
      final container = createContainer(FakeTrackingRepo());
      addTearDown(container.dispose);

      final state = container.read(trackingListViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value, isEmpty);
    });

    test('loadTracking() fetches with status filter', () async {
      final items = [
        _makeTracking('t-1', 'WATCHING'),
        _makeTracking('t-2', 'WATCHING'),
      ];
      final repo = FakeTrackingRepo()..results = items;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(trackingListViewModelProvider.notifier)
          .loadTracking(status: 'WATCHING');

      final state = container.read(trackingListViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value!.length, 2);
    });

    test('loadTracking() sets error on failure', () async {
      final repo = FakeTrackingRepo()..shouldThrow = true;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(trackingListViewModelProvider.notifier)
          .loadTracking(status: 'WATCHING');

      final state = container.read(trackingListViewModelProvider);
      expect(state.hasError, true);
    });

    test(
      'stale loadTracking() response cannot overwrite newer media type',
      () async {
        final repo = QueuedTrackingRepo();
        final cache = CacheService();
        final container = createContainer(repo, cache: cache);
        addTearDown(container.dispose);

        final subscription = container.listen(
          trackingListViewModelProvider,
          (_, _) {},
        );
        addTearDown(subscription.close);

        final notifier = container.read(trackingListViewModelProvider.notifier);
        final seriesFuture = notifier.loadTracking(
          status: 'WATCHING',
          mediaType: MediaType.series,
        );
        await Future<void>.delayed(Duration.zero);

        final movieFuture = notifier.loadTracking(
          status: 'WATCHING',
          mediaType: MediaType.movie,
        );
        await Future<void>.delayed(Duration.zero);

        expect(repo.calls, hasLength(2));
        expect(repo.calls[0].mediaType, MediaType.series);
        expect(repo.calls[1].mediaType, MediaType.movie);

        final movieItem = _makeTracking(
          'movie-1',
          'WATCHING',
          mediaType: MediaType.movie,
        );
        repo.calls[1].completer.complete([movieItem]);
        await movieFuture;

        expect(container.read(trackingListViewModelProvider).value, [
          movieItem,
        ]);

        final seriesItem = _makeTracking('series-1', 'WATCHING');
        repo.calls[0].completer.complete([seriesItem]);
        await seriesFuture;

        final state = container.read(trackingListViewModelProvider);
        expect(state.value, [movieItem]);
        expect(
          cache.getSync('tracking:v2:${MediaType.movie.apiValue}:WATCHING:1'),
          isNotNull,
        );
        expect(
          cache.getSync('tracking:v2:${MediaType.series.apiValue}:WATCHING:1'),
          isNull,
        );
      },
    );

    test(
      'loadTracking() response that becomes stale during cache set cannot overwrite',
      () async {
        final repo = QueuedTrackingRepo();
        final cache = DelayedSetCacheService();
        final movieItem = _makeTracking(
          'movie-1',
          'WATCHING',
          mediaType: MediaType.movie,
        );
        await cache.seed(
          'tracking:v2:${MediaType.movie.apiValue}:WATCHING:1',
          CacheEntry(
            json: jsonEncode([movieItem.toJson()]),
            cachedAt: DateTime.now(),
            ttl: const Duration(hours: 6),
          ),
        );
        final container = createContainer(repo, cache: cache);
        addTearDown(container.dispose);

        final subscription = container.listen(
          trackingListViewModelProvider,
          (_, _) {},
        );
        addTearDown(subscription.close);

        final notifier = container.read(trackingListViewModelProvider.notifier);
        final seriesFuture = notifier.loadTracking(
          status: 'WATCHING',
          mediaType: MediaType.series,
        );
        await Future<void>.delayed(Duration.zero);

        final seriesItem = _makeTracking('series-1', 'WATCHING');
        repo.calls.single.completer.complete([seriesItem]);
        await cache.setStarted.future;

        await notifier.loadTracking(
          status: 'WATCHING',
          mediaType: MediaType.movie,
        );
        cache.allowSet.complete();
        await seriesFuture;

        expect(container.read(trackingListViewModelProvider).value, [
          movieItem,
        ]);
      },
    );

    test(
      'cached loadTracking() clears fetching so loadMore works after stale request',
      () async {
        final repo = QueuedTrackingRepo();
        final cache = CacheService();
        final moviePage1 = _makeTracking(
          'movie-1',
          'WATCHING',
          mediaType: MediaType.movie,
        );
        await cache.set(
          'tracking:v2:${MediaType.movie.apiValue}:WATCHING:1',
          CacheEntry(
            json: jsonEncode([moviePage1.toJson()]),
            cachedAt: DateTime.now(),
            ttl: const Duration(hours: 6),
          ),
        );
        final container = createContainer(repo, cache: cache);
        addTearDown(container.dispose);

        final subscription = container.listen(
          trackingListViewModelProvider,
          (_, _) {},
        );
        addTearDown(subscription.close);

        final notifier = container.read(trackingListViewModelProvider.notifier);
        final seriesFuture = notifier.loadTracking(
          status: 'WATCHING',
          mediaType: MediaType.series,
        );
        await Future<void>.delayed(Duration.zero);

        await notifier.loadTracking(
          status: 'WATCHING',
          mediaType: MediaType.movie,
        );

        expect(repo.calls, hasLength(1));
        expect(repo.calls.single.mediaType, MediaType.series);
        expect(container.read(trackingListViewModelProvider).value, [
          moviePage1,
        ]);

        final seriesItem = _makeTracking('series-1', 'WATCHING');
        repo.calls.single.completer.complete([seriesItem]);
        await seriesFuture;

        final moviePage2 = _makeTracking(
          'movie-2',
          'WATCHING',
          mediaType: MediaType.movie,
        );
        final loadMoreFuture = notifier.loadMore();
        await Future<void>.delayed(Duration.zero);

        expect(repo.calls, hasLength(2));
        expect(repo.calls.last.mediaType, MediaType.movie);
        expect(repo.calls.last.page, 2);

        repo.calls.last.completer.complete([moviePage2]);
        await loadMoreFuture;

        expect(container.read(trackingListViewModelProvider).value, [
          moviePage1,
          moviePage2,
        ]);
      },
    );

    test('loadMore() appends to existing list', () async {
      final firstPage = [_makeTracking('t-1', 'WATCHING')];
      final repo = FakeTrackingRepo()..results = firstPage;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(trackingListViewModelProvider.notifier)
          .loadTracking(status: 'WATCHING');
      expect(container.read(trackingListViewModelProvider).value!.length, 1);

      // Set page 2 results
      repo.results = [_makeTracking('t-2', 'WATCHING')];
      await container.read(trackingListViewModelProvider.notifier).loadMore();

      expect(container.read(trackingListViewModelProvider).value!.length, 2);
    });

    test('refresh() reuses current status filter', () async {
      final items = [_makeTracking('t-1', 'COMPLETED')];
      final repo = FakeTrackingRepo()..results = items;
      final cache = CacheService();
      final container = createContainer(repo, cache: cache);
      addTearDown(container.dispose);

      final notifier = container.read(trackingListViewModelProvider.notifier);
      await notifier.loadTracking(status: 'COMPLETED');
      expect(container.read(trackingListViewModelProvider).value!.length, 1);

      // Clear cache so refresh re-fetches from network
      await cache.clearAll();

      repo.results = [
        _makeTracking('t-1', 'COMPLETED'),
        _makeTracking('t-2', 'COMPLETED'),
      ];
      await notifier.refresh();
      expect(container.read(trackingListViewModelProvider).value!.length, 2);
    });

    test('loadTracking() defaults to series media type', () async {
      final repo = FakeTrackingRepo()
        ..results = [_makeTracking('t-1', 'WATCHING')];
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(trackingListViewModelProvider.notifier)
          .loadTracking(status: 'WATCHING');

      expect(repo.lastMediaType, MediaType.series);
    });

    test('loadTracking() returns cached data from memory', () async {
      final cache = CacheService();
      final items = [_makeTracking('t-1', 'WATCHING')];
      await cache.set(
        'tracking:v2:${MediaType.series.apiValue}:WATCHING:1',
        CacheEntry(
          json: jsonEncode(items.map((e) => e.toJson()).toList()),
          cachedAt: DateTime.now(),
          ttl: const Duration(hours: 6),
        ),
      );

      final repo = FakeTrackingRepo();
      final container = createContainer(repo, cache: cache);
      addTearDown(container.dispose);

      await container
          .read(trackingListViewModelProvider.notifier)
          .loadTracking(status: 'WATCHING');

      final state = container.read(trackingListViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value!.length, 1);
    });

    test(
      'loadTracking() triggers background refresh when cache is stale',
      () async {
        final cache = CacheService();
        final items = [_makeTracking('t-1', 'WATCHING')];
        await cache.set(
          'tracking:v2:${MediaType.series.apiValue}:WATCHING:1',
          CacheEntry(
            json: jsonEncode(items.map((e) => e.toJson()).toList()),
            cachedAt: DateTime.now().subtract(const Duration(days: 1)),
            ttl: const Duration(hours: 6),
          ),
        );

        final newItems = [
          _makeTracking('t-1', 'WATCHING'),
          _makeTracking('t-2', 'WATCHING'),
        ];
        final repo = FakeTrackingRepo()..results = newItems;
        final container = createContainer(repo, cache: cache);
        addTearDown(container.dispose);

        final subscription = container.listen(
          trackingListViewModelProvider,
          (_, _) {},
        );

        await container
            .read(trackingListViewModelProvider.notifier)
            .loadTracking(status: 'WATCHING');

        expect(container.read(trackingListViewModelProvider).value!.length, 1);

        // Background refresh runs on event loop, wait for it
        await Future<void>.delayed(const Duration(seconds: 1));

        // Background refresh calls getTracking and updates state
        expect(repo.getTrackingCallCount, 1);
        // After background refresh, state should reflect new data
        final updatedState = container.read(trackingListViewModelProvider);
        expect(updatedState.hasValue, true);
        expect(updatedState.value!.length, 2);

        subscription.close();
      },
    );

    test(
      'background refresh failure sets error provider on stale cache',
      () async {
        final cache = CacheService();
        final items = [_makeTracking('t-1', 'WATCHING')];
        await cache.set(
          'tracking:v2:${MediaType.series.apiValue}:WATCHING:1',
          CacheEntry(
            json: jsonEncode(items.map((e) => e.toJson()).toList()),
            cachedAt: DateTime.now().subtract(const Duration(days: 1)),
            ttl: const Duration(hours: 6),
          ),
        );

        final repo = FakeTrackingRepo()..shouldThrow = true;
        final container = createContainer(repo, cache: cache);
        addTearDown(container.dispose);

        await container
            .read(trackingListViewModelProvider.notifier)
            .loadTracking(status: 'WATCHING');

        await Future<void>.delayed(const Duration(milliseconds: 50));

        final error = container.read(trackingBackgroundErrorProvider);
        expect(error, isNotNull);
      },
    );

    test(
      'stale background refresh failure does not set error provider',
      () async {
        final cache = CacheService();
        final seriesItem = _makeTracking('series-1', 'WATCHING');
        await cache.set(
          'tracking:v2:${MediaType.series.apiValue}:WATCHING:1',
          CacheEntry(
            json: jsonEncode([seriesItem.toJson()]),
            cachedAt: DateTime.now().subtract(const Duration(days: 1)),
            ttl: const Duration(hours: 6),
          ),
        );
        final movieItem = _makeTracking(
          'movie-1',
          'WATCHING',
          mediaType: MediaType.movie,
        );
        await cache.set(
          'tracking:v2:${MediaType.movie.apiValue}:WATCHING:1',
          CacheEntry(
            json: jsonEncode([movieItem.toJson()]),
            cachedAt: DateTime.now(),
            ttl: const Duration(hours: 6),
          ),
        );

        final repo = QueuedTrackingRepo();
        final container = createContainer(repo, cache: cache);
        addTearDown(container.dispose);

        final subscription = container.listen(
          trackingListViewModelProvider,
          (_, _) {},
        );
        addTearDown(subscription.close);

        final notifier = container.read(trackingListViewModelProvider.notifier);
        await notifier.loadTracking(
          status: 'WATCHING',
          mediaType: MediaType.series,
        );
        await Future<void>.delayed(Duration.zero);

        await notifier.loadTracking(
          status: 'WATCHING',
          mediaType: MediaType.movie,
        );

        expect(repo.calls, hasLength(1));
        repo.calls.single.completer.completeError(Exception('Failed'));
        await Future<void>.delayed(Duration.zero);

        expect(container.read(trackingBackgroundErrorProvider), isNull);
        expect(container.read(trackingListViewModelProvider).value, [
          movieItem,
        ]);
      },
    );

    test(
      'refresh() sets error state when no stale cache is available',
      () async {
        final repo = FakeTrackingRepo()..shouldThrow = true;
        final container = createContainer(repo);
        addTearDown(container.dispose);

        await container
            .read(trackingListViewModelProvider.notifier)
            .loadTracking(status: 'WATCHING');

        // Clear cache so no stale entry exists for refresh
        final cache = container.read(cacheServiceProvider);
        await cache.clearAll();

        await container.read(trackingListViewModelProvider.notifier).refresh();

        final state = container.read(trackingListViewModelProvider);
        expect(state.hasError, true);
      },
    );

    test('refresh() reuses stale cache on network failure', () async {
      final cache = CacheService();
      final items = [_makeTracking('t-2', 'COMPLETED')];
      await cache.set(
        'tracking:v2:${MediaType.series.apiValue}:COMPLETED:1',
        CacheEntry(
          json: jsonEncode(items.map((e) => e.toJson()).toList()),
          cachedAt: DateTime.now(),
          ttl: const Duration(hours: 6),
        ),
      );

      final repo = FakeTrackingRepo()..results = items;
      final container = createContainer(repo, cache: cache);
      addTearDown(container.dispose);

      await container
          .read(trackingListViewModelProvider.notifier)
          .loadTracking(status: 'COMPLETED');

      expect(container.read(trackingListViewModelProvider).value!.length, 1);

      repo.shouldThrow = true;
      await container.read(trackingListViewModelProvider.notifier).refresh();

      final state = container.read(trackingListViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value!.length, 1);
    });

    test('loadMore() skips when already loading', () async {
      final delay = Completer<void>();
      final repo = FakeTrackingRepo()
        ..delay = delay
        ..results = [_makeTracking('t-1', 'WATCHING')];
      final cache = CacheService();
      await cache.clearAll();
      final container = createContainer(repo, cache: cache);
      addTearDown(container.dispose);

      final subscription = container.listen(
        trackingListViewModelProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);

      final firstLoadMoreFuture = container
          .read(trackingListViewModelProvider.notifier)
          .loadMore();
      await Future<void>.delayed(Duration.zero);

      final secondLoadMoreFuture = container
          .read(trackingListViewModelProvider.notifier)
          .loadMore();
      await Future<void>.delayed(Duration.zero);

      expect(repo.getTrackingCallCount, 1);
      delay.complete();
      await firstLoadMoreFuture;
      await secondLoadMoreFuture;
    });
  });
}
