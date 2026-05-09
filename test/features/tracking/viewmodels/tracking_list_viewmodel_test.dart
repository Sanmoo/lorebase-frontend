import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/cache/cache_entry.dart';
import 'package:lorebase/core/cache/cache_service.dart';
import 'package:lorebase/core/cache/cache_providers.dart';
import 'package:lorebase/features/tracking/viewmodels/tracking_list_viewmodel.dart';
import 'package:lorebase/features/tracking/data/repositories/tracking_repository.dart';
import 'package:lorebase/features/tracking/data/models/tracked_series_model.dart';

final now = DateTime.now();

TrackedSeriesModel _makeTracking(String id, String status) =>
    TrackedSeriesModel(
      trackingId: id,
      userId: 'user-1',
      seriesId: '123',
      status: status,
      addedAt: now,
      lastUpdated: now,
    );

class FakeTrackingRepo implements TrackingRepository {
  List<TrackedSeriesModel>? results;
  bool shouldThrow = false;

  @override
  Future<List<TrackedSeriesModel>> getTracking({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (shouldThrow) throw Exception('Failed');
    return results ?? [];
  }

  @override
  Future<TrackedSeriesModel> startTracking(
          String seriesId, String status) async =>
      _makeTracking('t-1', status);

  @override
  Future<TrackedSeriesModel> updateTracking(String seriesId,
          {String? status,
          int? seriesRating,
          String? seriesReview,
          List<Map<String, dynamic>>? seasonRatings}) async =>
      _makeTracking('t-1', status ?? 'WATCHING');

  @override
  Future<void> deleteTracking(String seriesId) async {}
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
  });
}
