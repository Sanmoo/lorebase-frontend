import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/cache/cache_service.dart';
import 'package:lorebase/core/cache/cache_providers.dart';
import 'package:lorebase/features/tracking/viewmodels/tracking_list_viewmodel.dart';
import 'package:lorebase/features/tracking/data/repositories/tracking_repository.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';

final now = DateTime.now();

TrackedMediaModel _makeTracking(String id, String status) =>
    TrackedMediaModel(
      trackingId: id,
      userId: 'user-1',
      mediaType: MediaType.series,
      mediaId: '123',
      status: status,
      addedAt: now,
      lastUpdated: now,
    );

class FakeTrackingRepo implements TrackingRepository {
  List<TrackedMediaModel>? results;
  bool shouldThrow = false;
  MediaType? lastMediaType;

  @override
  Future<List<TrackedMediaModel>> getTracking({
    String? status,
    MediaType? mediaType,
    int page = 1,
    int pageSize = 20,
  }) async {
    lastMediaType = mediaType;
    if (shouldThrow) throw Exception('Failed');
    return results ?? [];
  }

  @override
  Future<TrackedMediaModel> startTracking(
    String mediaId,
    MediaType mediaType,
    String status,
  ) async =>
      _makeTracking('t-1', status);

  @override
  Future<TrackedMediaModel> updateTracking(
    String mediaId, {
    required MediaType mediaType,
    String? status,
    int? rating,
    String? review,
    List<Map<String, dynamic>>? seasonRatings,
  }) async =>
      _makeTracking('t-1', status ?? 'WATCHING');

  @override
  Future<void> deleteTracking(
    String mediaId, {
    required MediaType mediaType,
  }) async {}
}

void main() {
  group('TrackingListViewModel', () {
    ProviderContainer createContainer(FakeTrackingRepo repo, {CacheService? cache}) {
      return ProviderContainer(overrides: [
        trackingRepositoryProvider.overrideWith((ref) => repo),
        cacheServiceProvider.overrideWith((ref) => cache ?? CacheService()),
      ]);
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
      await container
          .read(trackingListViewModelProvider.notifier)
          .loadMore();

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
      final repo = FakeTrackingRepo()..results = [_makeTracking('t-1', 'WATCHING')];
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container.read(trackingListViewModelProvider.notifier).loadTracking(
            status: 'WATCHING',
          );

      expect(repo.lastMediaType, MediaType.series);
    });
  });
}
