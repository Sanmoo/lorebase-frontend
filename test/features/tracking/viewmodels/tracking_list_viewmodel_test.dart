import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/cache/cache_entry.dart';
import 'package:lorebase/core/cache/cache_service.dart';
import 'package:lorebase/core/cache/cache_providers.dart';
import 'package:lorebase/features/tracking/viewmodels/tracking_list_state.dart';
import 'package:lorebase/features/tracking/viewmodels/tracking_list_viewmodel.dart';
import 'package:lorebase/features/tracking/data/repositories/tracking_repository.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';
import 'package:lorebase/features/tracking/data/models/tracking_page_model.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/features/tracking/data/tracking_cache.dart';

final now = DateTime.now();

TrackedMediaModel _makeTracking(
  String id,
  String status, {
  MediaType mediaType = MediaType.series,
  int? rating,
}) => TrackedMediaModel(
  trackingId: id,
  userId: 'user-1',
  mediaType: mediaType,
  mediaId: '123',
  status: status,
  rating: rating,
  addedAt: now,
  lastUpdated: now,
);

TrackingPage _page(
  List<TrackedMediaModel> items, {
  String? nextCursor,
  int? totalCount,
}) => TrackingPage(
  items: items,
  nextCursor: nextCursor,
  totalCount: totalCount,
);

CacheEntry _cachedPage(
  TrackingPage page, {
  Duration ttl = const Duration(hours: 6),
  DateTime? cachedAt,
}) => CacheEntry(
  json: jsonEncode(page.toJson()),
  cachedAt: cachedAt ?? DateTime.now(),
  ttl: ttl,
);

String _key(String mediaType, String status) =>
    '$trackingCachePrefix$mediaType:$status';

class FakeTrackingRepo implements TrackingRepository {
  List<TrackedMediaModel>? results;
  String? nextCursor;
  int? totalCount;
  bool shouldThrow = false;
  MediaType? lastMediaType;
  int getTrackingCallCount = 0;
  final requestedCursors = <String?>[];
  Completer<void>? delay;

  @override
  Future<TrackingPage> getTracking({
    String? status,
    MediaType? mediaType,
    String? cursor,
    int pageSize = 20,
  }) async {
    getTrackingCallCount++;
    lastMediaType = mediaType;
    requestedCursors.add(cursor);
    await delay?.future;
    if (shouldThrow) throw Exception('Failed');
    return _page(
      results ?? [],
      nextCursor: nextCursor,
      totalCount: totalCount,
    );
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
  Future<TrackingPage> getTracking({
    String? status,
    MediaType? mediaType,
    String? cursor,
    int pageSize = 20,
  }) {
    getTrackingCallCount++;
    lastMediaType = mediaType;
    final request = TrackingRequest(
      status: status,
      mediaType: mediaType,
      cursor: cursor,
      completer: Completer<TrackingPage>(),
    );
    calls.add(request);
    return request.completer.future;
  }
}

class TrackingRequest {
  TrackingRequest({
    required this.status,
    required this.mediaType,
    required this.cursor,
    required this.completer,
  });

  final String? status;
  final MediaType? mediaType;
  final String? cursor;
  final Completer<TrackingPage> completer;
}

class DelayedSetCacheService extends CacheService {
  DelayedSetCacheService() : super(envFingerprint: 'test');

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

/// Simula um cache apenas de disco: nada em memória, tudo em `disk`.
class DiskOnlyCacheService extends CacheService {
  DiskOnlyCacheService() : super(envFingerprint: 'test');

  final disk = <String, CacheEntry>{};

  @override
  CacheEntry? getSync(String key) => null;

  @override
  CacheEntry? getFromDiskSync(String key) => disk[key];

  @override
  Future<void> set(String key, CacheEntry entry) async {
    disk[key] = entry;
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
          cacheServiceProvider.overrideWith((ref) => cache ?? CacheService(envFingerprint: 'test')),
        ],
      );
    }

    test('build() returns empty list', () {
      final container = createContainer(FakeTrackingRepo());
      addTearDown(container.dispose);

      final state = container.read(trackingListViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value, const TrackingListState());
      expect(state.value!.items, isEmpty);
      expect(state.value!.hasMore, false);
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
      expect(state.value!.items.length, 2);
    });

    test(
      'loadTracking() keeps the API rating order: better first, ties stable, '
      'unrated last',
      () async {
        final items = [
          _makeTracking('t-10', 'WATCHING', rating: 10),
          _makeTracking('t-9a', 'WATCHING', rating: 9),
          _makeTracking('t-9b', 'WATCHING', rating: 9),
          _makeTracking('t-none', 'WATCHING'),
        ];
        final repo = FakeTrackingRepo()..results = items;
        final container = createContainer(repo);
        addTearDown(container.dispose);

        await container
            .read(trackingListViewModelProvider.notifier)
            .loadTracking(status: 'WATCHING');

        final state = container.read(trackingListViewModelProvider);
        expect(state.value!.items.map((e) => e.trackingId), [
          't-10',
          't-9a',
          't-9b',
          't-none',
        ]);
        expect(state.value!.items.map((e) => e.rating), [10, 9, 9, null]);
      },
    );

    test('loadTracking() ignores a cache entry from the previous key version', () async {
      final cache = CacheService(envFingerprint: 'test');
      await cache.set(
        'tracking:v4:SERIES:WATCHING',
        _cachedPage(_page([_makeTracking('t-old', 'WATCHING')])),
      );
      final repo = FakeTrackingRepo()
        ..results = [_makeTracking('t-new', 'WATCHING', rating: 9)];
      final container = createContainer(repo, cache: cache);
      addTearDown(container.dispose);

      await container
          .read(trackingListViewModelProvider.notifier)
          .loadTracking(status: 'WATCHING');

      expect(repo.getTrackingCallCount, 1);
      expect(
        container.read(trackingListViewModelProvider).value!.items.map(
          (e) => e.trackingId,
        ),
        ['t-new'],
      );
    });

    test('loadTracking() restores the rating order from cache', () async {
      final cache = CacheService(envFingerprint: 'test');
      final items = [
        _makeTracking('t-9', 'WATCHING', rating: 9),
        _makeTracking('t-4', 'WATCHING', rating: 4),
        _makeTracking('t-none', 'WATCHING'),
      ];
      await cache.set(
        _key(MediaType.series.apiValue, 'WATCHING'),
        _cachedPage(_page(items)),
      );
      final container = createContainer(FakeTrackingRepo(), cache: cache);
      addTearDown(container.dispose);

      await container
          .read(trackingListViewModelProvider.notifier)
          .loadTracking(status: 'WATCHING');

      final state = container.read(trackingListViewModelProvider);
      expect(state.value!.items.map((e) => e.trackingId), [
        't-9',
        't-4',
        't-none',
      ]);
    });

    test('refresh() shows the reordered list coming from the API', () async {
      final repo = FakeTrackingRepo()
        ..results = [
          _makeTracking('t-5', 'WATCHING', rating: 5),
          _makeTracking('t-none', 'WATCHING'),
        ];
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(trackingListViewModelProvider.notifier);
      await notifier.loadTracking(status: 'WATCHING');
      expect(
        container.read(trackingListViewModelProvider).value!.items.map(
          (e) => e.trackingId,
        ),
        ['t-5', 't-none'],
      );

      repo.results = [
        _makeTracking('t-none', 'WATCHING', rating: 10),
        _makeTracking('t-5', 'WATCHING', rating: 5),
      ];
      await notifier.refresh();

      final state = container.read(trackingListViewModelProvider);
      expect(state.value!.items.map((e) => e.trackingId), ['t-none', 't-5']);
      expect(state.value!.items.map((e) => e.rating), [10, 5]);
    });

    test('loadTracking() exposes the continuation token as hasMore', () async {
      final repo = FakeTrackingRepo()
        ..results = [_makeTracking('t-1', 'COMPLETED')]
        ..nextCursor = 'cursor-page-2'
        ..totalCount = 42;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(trackingListViewModelProvider.notifier)
          .loadTracking(status: 'COMPLETED');

      final state = container.read(trackingListViewModelProvider);
      expect(state.value!.page.nextCursor, 'cursor-page-2');
      expect(state.value!.page.totalCount, 42);
      expect(state.value!.hasMore, true);
      expect(repo.requestedCursors, [null]);
    });

    test('hasMore follows the token, never the item count', () async {
      final repo = FakeTrackingRepo()
        ..results = [
          _makeTracking('t-1', 'COMPLETED'),
          _makeTracking('t-2', 'COMPLETED'),
          _makeTracking('t-3', 'COMPLETED'),
        ]
        ..nextCursor = 'cursor-page-2'
        ..totalCount = 1;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(trackingListViewModelProvider.notifier)
          .loadTracking(status: 'COMPLETED');

      expect(
        container.read(trackingListViewModelProvider).value!.hasMore,
        true,
      );
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
        final cache = CacheService(envFingerprint: 'test');
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
        repo.calls[1].completer.complete(_page([movieItem]));
        await movieFuture;

        expect(container.read(trackingListViewModelProvider).value!.items, [
          movieItem,
        ]);

        final seriesItem = _makeTracking('series-1', 'WATCHING');
        repo.calls[0].completer.complete(_page([seriesItem]));
        await seriesFuture;

        final state = container.read(trackingListViewModelProvider);
        expect(state.value!.items, [movieItem]);
        expect(
          cache.getSync(_key(MediaType.movie.apiValue, 'WATCHING')),
          isNotNull,
        );
        expect(
          cache.getSync(_key(MediaType.series.apiValue, 'WATCHING')),
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
          _key(MediaType.movie.apiValue, 'WATCHING'),
          _cachedPage(_page([movieItem])),
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
        repo.calls.single.completer.complete(_page([seriesItem]));
        await cache.setStarted.future;

        await notifier.loadTracking(
          status: 'WATCHING',
          mediaType: MediaType.movie,
        );
        cache.allowSet.complete();
        await seriesFuture;

        expect(container.read(trackingListViewModelProvider).value!.items, [
          movieItem,
        ]);
      },
    );

    test(
      'cached loadTracking() clears fetching so loadMore works after stale request',
      () async {
        final repo = QueuedTrackingRepo();
        final cache = CacheService(envFingerprint: 'test');
        final moviePage1 = _makeTracking(
          'movie-1',
          'WATCHING',
          mediaType: MediaType.movie,
        );
        await cache.set(
          _key(MediaType.movie.apiValue, 'WATCHING'),
          _cachedPage(
            _page([moviePage1], nextCursor: 'movie-cursor-2', totalCount: 2),
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
        expect(container.read(trackingListViewModelProvider).value!.items, [
          moviePage1,
        ]);

        final seriesItem = _makeTracking('series-1', 'WATCHING');
        repo.calls.single.completer.complete(_page([seriesItem]));
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
        expect(repo.calls.last.cursor, 'movie-cursor-2');

        repo.calls.last.completer.complete(_page([moviePage2]));
        await loadMoreFuture;

        expect(container.read(trackingListViewModelProvider).value!.items, [
          moviePage1,
          moviePage2,
        ]);
      },
    );

    test('loadMore() requests the stored token and appends', () async {
      final repo = FakeTrackingRepo()
        ..results = [_makeTracking('t-1', 'COMPLETED')]
        ..nextCursor = 'cursor-page-2'
        ..totalCount = 3;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(trackingListViewModelProvider.notifier);
      await notifier.loadTracking(status: 'COMPLETED');
      expect(
        container.read(trackingListViewModelProvider).value!.hasMore,
        true,
      );

      repo.results = [_makeTracking('t-2', 'COMPLETED')];
      repo.nextCursor = null;
      await notifier.loadMore();

      final state = container.read(trackingListViewModelProvider);
      expect(repo.requestedCursors, [null, 'cursor-page-2']);
      expect(state.value!.items.length, 2);
      expect(state.value!.hasMore, false);
    });

    test('loadMore() dedupes items already loaded', () async {
      final repo = FakeTrackingRepo()
        ..results = [
          _makeTracking('t-1', 'COMPLETED'),
          _makeTracking('t-2', 'COMPLETED'),
        ]
        ..nextCursor = 'cursor-page-2'
        ..totalCount = 3;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(trackingListViewModelProvider.notifier);
      await notifier.loadTracking(status: 'COMPLETED');

      repo.results = [
        _makeTracking('t-2', 'COMPLETED'),
        _makeTracking('t-3', 'COMPLETED'),
      ];
      repo.nextCursor = null;
      await notifier.loadMore();

      final state = container.read(trackingListViewModelProvider);
      expect(state.value!.items.map((e) => e.trackingId), ['t-1', 't-2', 't-3']);
      expect(state.value!.hasMore, false);
    });

    test('loadMore() keeps the first-page totalCount when omitted', () async {
      final repo = FakeTrackingRepo()
        ..results = [_makeTracking('t-1', 'COMPLETED')]
        ..nextCursor = 'cursor-page-2'
        ..totalCount = 42;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(trackingListViewModelProvider.notifier);
      await notifier.loadTracking(status: 'COMPLETED');

      repo.results = [_makeTracking('t-2', 'COMPLETED')];
      repo.nextCursor = null;
      repo.totalCount = null;
      await notifier.loadMore();

      final state = container.read(trackingListViewModelProvider);
      expect(state.value!.page.totalCount, 42);
      expect(state.value!.items.length, 2);
    });

    test('loadMore() does not request once the token is gone', () async {
      final repo = FakeTrackingRepo()
        ..results = [_makeTracking('t-1', 'COMPLETED')]
        ..nextCursor = null;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(trackingListViewModelProvider.notifier);
      await notifier.loadTracking(status: 'COMPLETED');
      await notifier.loadMore();

      expect(repo.requestedCursors, [null]);
    });

    test(
      'loadMore() failure keeps items, reports the error and retries the same token',
      () async {
        final repo = FakeTrackingRepo()
          ..results = [_makeTracking('t-1', 'COMPLETED')]
          ..nextCursor = 'cursor-page-2'
          ..totalCount = 2;
        final container = createContainer(repo);
        addTearDown(container.dispose);

        final notifier = container.read(trackingListViewModelProvider.notifier);
        await notifier.loadTracking(status: 'COMPLETED');

        repo.shouldThrow = true;
        await notifier.loadMore();

        var state = container.read(trackingListViewModelProvider);
        expect(state.value!.items.map((e) => e.trackingId), ['t-1']);
        expect(state.value!.isLoadingMore, false);
        expect(state.value!.loadMoreError, isNotNull);
        expect(state.value!.page.nextCursor, 'cursor-page-2');
        expect(repo.requestedCursors, [null, 'cursor-page-2']);

        repo.shouldThrow = false;
        repo.results = [_makeTracking('t-2', 'COMPLETED')];
        repo.nextCursor = null;
        await notifier.loadMore();

        state = container.read(trackingListViewModelProvider);
        expect(repo.requestedCursors, [null, 'cursor-page-2', 'cursor-page-2']);
        expect(state.value!.items.map((e) => e.trackingId), ['t-1', 't-2']);
        expect(state.value!.loadMoreError, isNull);
        expect(state.value!.hasMore, false);
      },
    );

    test('loadTracking() resets the token when the status changes', () async {
      final repo = FakeTrackingRepo()
        ..results = [_makeTracking('t-1', 'WATCHING')]
        ..nextCursor = 'cursor-page-2';
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(trackingListViewModelProvider.notifier);
      await notifier.loadTracking(status: 'WATCHING');
      repo.results = [_makeTracking('t-2', 'WATCHING')];
      repo.nextCursor = 'cursor-page-3';
      await notifier.loadMore();

      repo.results = [_makeTracking('t-3', 'COMPLETED')];
      repo.nextCursor = null;
      await notifier.loadTracking(status: 'COMPLETED');

      final state = container.read(trackingListViewModelProvider);
      expect(repo.requestedCursors, [null, 'cursor-page-2', null]);
      expect(state.value!.items.map((e) => e.trackingId), ['t-3']);
      expect(state.value!.hasMore, false);
    });

    test(
      'loadTracking() resets the token when the media type changes',
      () async {
        final repo = FakeTrackingRepo()
          ..results = [_makeTracking('t-1', 'WATCHING')]
          ..nextCursor = 'cursor-page-2';
        final container = createContainer(repo);
        addTearDown(container.dispose);

        final notifier = container.read(trackingListViewModelProvider.notifier);
        await notifier.loadTracking(status: 'WATCHING');
        repo.results = [_makeTracking('t-2', 'WATCHING')];
        await notifier.loadMore();

        repo.results = [
          _makeTracking('m-1', 'WATCHING', mediaType: MediaType.movie),
        ];
        repo.nextCursor = null;
        await notifier.loadTracking(
          status: 'WATCHING',
          mediaType: MediaType.movie,
        );

        final state = container.read(trackingListViewModelProvider);
        expect(repo.requestedCursors, [null, 'cursor-page-2', null]);
        expect(state.value!.items.map((e) => e.trackingId), ['m-1']);
      },
    );

    test('refresh() reuses current status filter', () async {
      final items = [_makeTracking('t-1', 'COMPLETED')];
      final repo = FakeTrackingRepo()..results = items;
      final cache = CacheService(envFingerprint: 'test');
      final container = createContainer(repo, cache: cache);
      addTearDown(container.dispose);

      final notifier = container.read(trackingListViewModelProvider.notifier);
      await notifier.loadTracking(status: 'COMPLETED');
      expect(
        container.read(trackingListViewModelProvider).value!.items.length,
        1,
      );

      // Clear cache so refresh re-fetches from network
      await cache.clearAll();

      repo.results = [
        _makeTracking('t-1', 'COMPLETED'),
        _makeTracking('t-2', 'COMPLETED'),
      ];
      await notifier.refresh();
      expect(
        container.read(trackingListViewModelProvider).value!.items.length,
        2,
      );
    });

    test('refresh() reloads the first page and recalculates hasMore', () async {
      final repo = FakeTrackingRepo()
        ..results = [_makeTracking('t-1', 'COMPLETED')]
        ..nextCursor = 'cursor-page-2';
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(trackingListViewModelProvider.notifier);
      await notifier.loadTracking(status: 'COMPLETED');
      repo.results = [_makeTracking('t-2', 'COMPLETED')];
      repo.nextCursor = 'cursor-page-3';
      await notifier.loadMore();
      expect(container.read(trackingListViewModelProvider).value!.items.length, 2);

      repo.results = [
        _makeTracking('t-1', 'COMPLETED'),
        _makeTracking('t-4', 'COMPLETED'),
      ];
      repo.nextCursor = null;
      await notifier.refresh();

      final state = container.read(trackingListViewModelProvider);
      expect(repo.requestedCursors, [null, 'cursor-page-2', null]);
      expect(state.value!.items.map((e) => e.trackingId), ['t-1', 't-4']);
      expect(state.value!.hasMore, false);
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
      final cache = CacheService(envFingerprint: 'test');
      final items = [_makeTracking('t-1', 'WATCHING')];
      await cache.set(
        _key(MediaType.series.apiValue, 'WATCHING'),
        _cachedPage(
          _page(items, nextCursor: 'cursor-page-2', totalCount: 25),
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
      expect(state.value!.items.length, 1);
      expect(state.value!.page.nextCursor, 'cursor-page-2');
      expect(state.value!.hasMore, true);
      expect(repo.getTrackingCallCount, 0);
    });

    test(
      'loadTracking() restores the continuation token from a warm disk cache',
      () async {
        final page1 = _makeTracking('t-1', 'COMPLETED');
        final cache = DiskOnlyCacheService()
          ..disk[_key(MediaType.series.apiValue, 'COMPLETED')] = _cachedPage(
            _page([page1], nextCursor: 'cursor-page-2', totalCount: 25),
          );
        final repo = FakeTrackingRepo();
        final container = createContainer(repo, cache: cache);
        addTearDown(container.dispose);

        final notifier = container.read(trackingListViewModelProvider.notifier);
        await notifier.loadTracking(status: 'COMPLETED');

        var state = container.read(trackingListViewModelProvider);
        expect(repo.getTrackingCallCount, 0);
        expect(state.value!.hasMore, true);

        repo.results = [_makeTracking('t-2', 'COMPLETED')];
        repo.nextCursor = null;
        await notifier.loadMore();

        state = container.read(trackingListViewModelProvider);
        expect(repo.requestedCursors, ['cursor-page-2']);
        expect(state.value!.items.map((e) => e.trackingId), ['t-1', 't-2']);
        expect(state.value!.hasMore, false);
      },
    );

    test('cache keeps the continuation token for a warm restore', () async {
      final repo = FakeTrackingRepo()
        ..results = [_makeTracking('t-1', 'COMPLETED')]
        ..nextCursor = 'cursor-page-2'
        ..totalCount = 25;
      final cache = CacheService(envFingerprint: 'test');
      final container = createContainer(repo, cache: cache);
      addTearDown(container.dispose);

      await container
          .read(trackingListViewModelProvider.notifier)
          .loadTracking(status: 'COMPLETED');

      final persisted = cache.getSync(
        _key(MediaType.series.apiValue, 'COMPLETED'),
      );
      expect(persisted, isNotNull);

      final warmCache = DiskOnlyCacheService();
      warmCache.disk[_key(MediaType.series.apiValue, 'COMPLETED')] = persisted!;
      final warmRepo = FakeTrackingRepo()
        ..results = [_makeTracking('t-2', 'COMPLETED')]
        ..nextCursor = null;
      final warmContainer = createContainer(warmRepo, cache: warmCache);
      addTearDown(warmContainer.dispose);

      final notifier = warmContainer.read(trackingListViewModelProvider.notifier);
      await notifier.loadTracking(status: 'COMPLETED');

      var state = warmContainer.read(trackingListViewModelProvider);
      expect(warmRepo.getTrackingCallCount, 0);
      expect(state.value!.items.map((e) => e.trackingId), ['t-1']);
      expect(state.value!.hasMore, true);

      await notifier.loadMore();

      state = warmContainer.read(trackingListViewModelProvider);
      expect(warmRepo.requestedCursors, ['cursor-page-2']);
      expect(state.value!.items.length, 2);
    });

    test(
      'loadTracking() triggers background refresh when cache is stale',
      () async {
        final cache = CacheService(envFingerprint: 'test');
        final items = [_makeTracking('t-1', 'WATCHING')];
        await cache.set(
          _key(MediaType.series.apiValue, 'WATCHING'),
          _cachedPage(
            _page(items, nextCursor: 'cursor-page-2'),
            cachedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        );

        final newItems = [
          _makeTracking('t-1', 'WATCHING'),
          _makeTracking('t-2', 'WATCHING'),
        ];
        final repo = FakeTrackingRepo()
          ..results = newItems
          ..nextCursor = 'cursor-page-7';
        final container = createContainer(repo, cache: cache);
        addTearDown(container.dispose);

        final subscription = container.listen(
          trackingListViewModelProvider,
          (_, _) {},
        );

        await container
            .read(trackingListViewModelProvider.notifier)
            .loadTracking(status: 'WATCHING');

        expect(
          container.read(trackingListViewModelProvider).value!.items.length,
          1,
        );

        // Background refresh runs on event loop, wait for it
        await Future<void>.delayed(const Duration(seconds: 1));

        // Background refresh calls getTracking and updates state
        expect(repo.getTrackingCallCount, 1);
        final updatedState = container.read(trackingListViewModelProvider);
        expect(updatedState.hasValue, true);
        expect(updatedState.value!.items.length, 2);
        expect(updatedState.value!.page.nextCursor, 'cursor-page-7');

        subscription.close();
      },
    );

    test('background refresh does not shrink a paginated list', () async {
      final cache = CacheService(envFingerprint: 'test');
      final page1 = _makeTracking('t-1', 'COMPLETED');
      await cache.set(
        _key(MediaType.series.apiValue, 'COMPLETED'),
        _cachedPage(
          _page([page1], nextCursor: 'cursor-page-2'),
          cachedAt: DateTime.now().subtract(const Duration(days: 1)),
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
      await notifier.loadTracking(status: 'COMPLETED');
      await Future<void>.delayed(Duration.zero);
      expect(repo.calls, hasLength(1));

      final loadMoreFuture = notifier.loadMore();
      await Future<void>.delayed(Duration.zero);
      expect(repo.calls.last.cursor, 'cursor-page-2');
      repo.calls[1].completer.complete(
        _page([_makeTracking('t-2', 'COMPLETED')]),
      );
      await loadMoreFuture;

      repo.calls[0].completer.complete(
        _page([_makeTracking('t-9', 'COMPLETED')]),
      );
      await Future<void>.delayed(const Duration(seconds: 1));

      final state = container.read(trackingListViewModelProvider);
      expect(state.value!.items.map((e) => e.trackingId), ['t-1', 't-2']);
    });

    test(
      'background refresh failure sets error provider on stale cache',
      () async {
        final cache = CacheService(envFingerprint: 'test');
        final items = [_makeTracking('t-1', 'WATCHING')];
        await cache.set(
          _key(MediaType.series.apiValue, 'WATCHING'),
          _cachedPage(
            _page(items),
            cachedAt: DateTime.now().subtract(const Duration(days: 1)),
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
        final cache = CacheService(envFingerprint: 'test');
        final seriesItem = _makeTracking('series-1', 'WATCHING');
        await cache.set(
          _key(MediaType.series.apiValue, 'WATCHING'),
          _cachedPage(
            _page([seriesItem]),
            cachedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        );
        final movieItem = _makeTracking(
          'movie-1',
          'WATCHING',
          mediaType: MediaType.movie,
        );
        await cache.set(
          _key(MediaType.movie.apiValue, 'WATCHING'),
          _cachedPage(_page([movieItem])),
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
        expect(container.read(trackingListViewModelProvider).value!.items, [
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
      final cache = CacheService(envFingerprint: 'test');
      final items = [_makeTracking('t-2', 'COMPLETED')];
      await cache.set(
        _key(MediaType.series.apiValue, 'COMPLETED'),
        _cachedPage(_page(items, nextCursor: 'cursor-page-2', totalCount: 3)),
      );

      final repo = FakeTrackingRepo()..results = items;
      final container = createContainer(repo, cache: cache);
      addTearDown(container.dispose);

      await container
          .read(trackingListViewModelProvider.notifier)
          .loadTracking(status: 'COMPLETED');

      expect(
        container.read(trackingListViewModelProvider).value!.items.length,
        1,
      );

      repo.shouldThrow = true;
      await container.read(trackingListViewModelProvider.notifier).refresh();

      final state = container.read(trackingListViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value!.items.length, 1);
      expect(state.value!.page.nextCursor, 'cursor-page-2');
      expect(state.value!.hasMore, true);
    });

    test('refresh() while a page fetch is in flight keeps loadMore usable', () async {
      final repo = QueuedTrackingRepo();
      final cache = CacheService(envFingerprint: 'test');
      final container = createContainer(repo, cache: cache);
      addTearDown(container.dispose);

      final subscription = container.listen(
        trackingListViewModelProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);

      final notifier = container.read(trackingListViewModelProvider.notifier);
      final firstLoad = notifier.loadTracking(status: 'COMPLETED');
      await Future<void>.delayed(Duration.zero);

      final refreshFuture = notifier.refresh();
      await Future<void>.delayed(Duration.zero);
      expect(repo.calls, hasLength(2));

      repo.calls[1].completer.complete(
        _page(
          [_makeTracking('t-1', 'COMPLETED')],
          nextCursor: 'cursor-page-2',
        ),
      );
      await refreshFuture;

      repo.calls[0].completer.complete(
        _page([_makeTracking('t-0', 'COMPLETED')]),
      );
      await firstLoad;

      final loadMoreFuture = notifier.loadMore();
      await Future<void>.delayed(Duration.zero);

      expect(repo.calls, hasLength(3));
      expect(repo.calls.last.cursor, 'cursor-page-2');
      repo.calls.last.completer.complete(
        _page([_makeTracking('t-2', 'COMPLETED')]),
      );
      await loadMoreFuture;

      expect(
        container.read(trackingListViewModelProvider).value!.items.map(
          (e) => e.trackingId,
        ),
        ['t-1', 't-2'],
      );
    });

    test('refresh() blocks loadMore while it reloads', () async {
      final repo = QueuedTrackingRepo();
      final cache = CacheService(envFingerprint: 'test');
      final container = createContainer(repo, cache: cache);
      addTearDown(container.dispose);

      final subscription = container.listen(
        trackingListViewModelProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);

      final notifier = container.read(trackingListViewModelProvider.notifier);
      final firstLoad = notifier.loadTracking(status: 'COMPLETED');
      await Future<void>.delayed(Duration.zero);
      repo.calls[0].completer.complete(
        _page(
          [_makeTracking('t-1', 'COMPLETED')],
          nextCursor: 'cursor-page-2',
        ),
      );
      await firstLoad;

      final refreshFuture = notifier.refresh();
      final loadMoreFuture = notifier.loadMore();
      await Future<void>.delayed(Duration.zero);

      expect(repo.calls, hasLength(2));
      expect(repo.calls.last.cursor, isNull);

      repo.calls[1].completer.complete(
        _page(
          [_makeTracking('t-1', 'COMPLETED')],
          nextCursor: 'cursor-page-3',
        ),
      );
      await refreshFuture;
      await loadMoreFuture;

      expect(repo.calls, hasLength(2));
      expect(
        container.read(trackingListViewModelProvider).value!.page.nextCursor,
        'cursor-page-3',
      );
    });

    test('loadMore() skips when already loading', () async {
      final repo = FakeTrackingRepo()
        ..results = [_makeTracking('t-1', 'WATCHING')]
        ..nextCursor = 'cursor-page-2';
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final subscription = container.listen(
        trackingListViewModelProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);

      final notifier = container.read(trackingListViewModelProvider.notifier);
      await notifier.loadTracking(status: 'WATCHING');
      expect(
        container.read(trackingListViewModelProvider).value!.hasMore,
        true,
      );

      final delay = Completer<void>();
      repo.delay = delay;

      final firstLoadMoreFuture = notifier.loadMore();
      await Future<void>.delayed(Duration.zero);

      final secondLoadMoreFuture = notifier.loadMore();
      await Future<void>.delayed(Duration.zero);

      expect(repo.getTrackingCallCount, 2);
      expect(repo.requestedCursors, [null, 'cursor-page-2']);
      delay.complete();
      await firstLoadMoreFuture;
      await secondLoadMoreFuture;
    });
  });
}
