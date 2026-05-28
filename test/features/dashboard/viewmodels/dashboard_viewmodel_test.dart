import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/cache/cache_entry.dart';
import 'package:lorebase/core/cache/cache_service.dart';
import 'package:lorebase/core/cache/cache_providers.dart';
import 'package:lorebase/core/providers/media_filter_provider.dart';
import 'package:lorebase/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:lorebase/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_model.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_section_model.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';

class FakeDashboardRepo implements DashboardRepository {
  DashboardModel? result;
  bool shouldThrow = false;
  MediaType? lastMediaType;

  @override
  Future<DashboardModel> getDashboard({
    MediaType mediaType = MediaType.series,
  }) async {
    lastMediaType = mediaType;
    if (shouldThrow) throw Exception('Failed');
    return result ?? _defaultDashboard();
  }

  DashboardModel _defaultDashboard() => const DashboardModel(
    watching: DashboardSectionModel(),
    wantToWatch: DashboardSectionModel(),
    completed: DashboardSectionModel(),
    dropped: DashboardSectionModel(),
    stats: DashboardStatsModel(),
  );
}

void main() {
  group('DashboardViewModel', () {
    test('build() starts with AsyncValue.loading when no cache', () {
      final repo = FakeDashboardRepo();
      final container = ProviderContainer(
        overrides: [
          dashboardRepositoryProvider.overrideWith((ref) => repo),
          cacheServiceProvider.overrideWith((ref) => CacheService()),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(dashboardViewModelProvider);
      expect(state.isLoading, true);
    });

    test('build() uses shared media type selection', () async {
      final repo = FakeDashboardRepo();
      final container = ProviderContainer(
        overrides: [
          selectedMediaTypeProvider.overrideWith((ref) => MediaType.movie),
          dashboardRepositoryProvider.overrideWith((ref) => repo),
          cacheServiceProvider.overrideWith((ref) => CacheService()),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        dashboardViewModelProvider,
        (prev, next) {},
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(repo.lastMediaType, MediaType.movie);

      subscription.close();
    });

    test('build() loads dashboard data on success', () async {
      const dashboard = DashboardModel(
        watching: DashboardSectionModel(),
        wantToWatch: DashboardSectionModel(),
        completed: DashboardSectionModel(),
        dropped: DashboardSectionModel(),
        stats: DashboardStatsModel(watchingCount: 5, totalTracked: 10),
      );
      final repo = FakeDashboardRepo()..result = dashboard;
      final container = ProviderContainer(
        overrides: [
          dashboardRepositoryProvider.overrideWith((ref) => repo),
          cacheServiceProvider.overrideWith((ref) => CacheService()),
        ],
      );
      addTearDown(container.dispose);

      // Listen to trigger build and wait for async to complete
      final subscription = container.listen(
        dashboardViewModelProvider,
        (prev, next) {},
      );

      // Wait for async completion
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(dashboardViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value!.stats.watchingCount, 5);
      expect(state.value!.stats.totalTracked, 10);

      subscription.close();
    });

    test('build() sets error on failure', () async {
      final repo = FakeDashboardRepo()..shouldThrow = true;
      final container = ProviderContainer(
        overrides: [
          dashboardRepositoryProvider.overrideWith((ref) => repo),
          cacheServiceProvider.overrideWith((ref) => CacheService()),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        dashboardViewModelProvider,
        (prev, next) {},
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(dashboardViewModelProvider);
      expect(state.hasError, true);

      subscription.close();
    });

    test('refresh() reloads dashboard', () async {
      final repo = FakeDashboardRepo();
      final container = ProviderContainer(
        overrides: [
          dashboardRepositoryProvider.overrideWith((ref) => repo),
          cacheServiceProvider.overrideWith((ref) => CacheService()),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        dashboardViewModelProvider,
        (prev, next) {},
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(
        container.read(dashboardViewModelProvider).value!.stats.totalTracked,
        0,
      );

      // Change repo data and refresh
      repo.result = const DashboardModel(
        watching: DashboardSectionModel(),
        wantToWatch: DashboardSectionModel(),
        completed: DashboardSectionModel(),
        dropped: DashboardSectionModel(),
        stats: DashboardStatsModel(totalTracked: 42),
      );

      await container.read(dashboardViewModelProvider.notifier).refresh();
      expect(
        container.read(dashboardViewModelProvider).value!.stats.totalTracked,
        42,
      );

      subscription.close();
    });

    test('refresh() keeps stale data on network failure', () async {
      final cacheService = CacheService();
      await cacheService.set(
        'dashboard:v2:SERIES',
        CacheEntry(
          json: jsonEncode(
            const DashboardModel(
              watching: DashboardSectionModel(),
              wantToWatch: DashboardSectionModel(),
              completed: DashboardSectionModel(),
              dropped: DashboardSectionModel(),
              stats: DashboardStatsModel(watchingCount: 3),
            ).toJson(),
          ),
          cachedAt: DateTime.now(),
          ttl: const Duration(hours: 6),
        ),
      );
      final repo = FakeDashboardRepo()..shouldThrow = true;
      final container = ProviderContainer(
        overrides: [
          dashboardRepositoryProvider.overrideWith((ref) => repo),
          cacheServiceProvider.overrideWith((ref) => cacheService),
        ],
      );
      addTearDown(container.dispose);

      await container.read(dashboardViewModelProvider.notifier).refresh();
      final state = container.read(dashboardViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value!.stats.watchingCount, 3);
    });

    test('build() returns cached data from memory', () async {
      final cacheService = CacheService();
      await cacheService.set(
        'dashboard:v2:SERIES',
        CacheEntry(
          json: jsonEncode(
            const DashboardModel(
              watching: DashboardSectionModel(),
              wantToWatch: DashboardSectionModel(),
              completed: DashboardSectionModel(),
              dropped: DashboardSectionModel(),
              stats: DashboardStatsModel(watchingCount: 3),
            ).toJson(),
          ),
          cachedAt: DateTime.now(),
          ttl: const Duration(hours: 6),
        ),
      );
      final repo = FakeDashboardRepo();
      final container = ProviderContainer(
        overrides: [
          dashboardRepositoryProvider.overrideWith((ref) => repo),
          cacheServiceProvider.overrideWith((ref) => cacheService),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(dashboardViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value!.stats.watchingCount, 3);
    });

    test('build() triggers background refresh when cache is stale', () async {
      final cacheService = CacheService();
      await cacheService.set(
        'dashboard:v2:SERIES',
        CacheEntry(
          json: jsonEncode(
            const DashboardModel(
              watching: DashboardSectionModel(),
              wantToWatch: DashboardSectionModel(),
              completed: DashboardSectionModel(),
              dropped: DashboardSectionModel(),
              stats: DashboardStatsModel(watchingCount: 3),
            ).toJson(),
          ),
          cachedAt: DateTime.now().subtract(const Duration(days: 1)),
          ttl: const Duration(hours: 6),
        ),
      );
      const dashboard = DashboardModel(
        watching: DashboardSectionModel(),
        wantToWatch: DashboardSectionModel(),
        completed: DashboardSectionModel(),
        dropped: DashboardSectionModel(),
        stats: DashboardStatsModel(watchingCount: 10),
      );
      final repo = FakeDashboardRepo()..result = dashboard;
      final container = ProviderContainer(
        overrides: [
          dashboardRepositoryProvider.overrideWith((ref) => repo),
          cacheServiceProvider.overrideWith((ref) => cacheService),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(dashboardViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value!.stats.watchingCount, 3);

      // Wait for background refresh to complete
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final updatedState = container.read(dashboardViewModelProvider);
      expect(updatedState.hasValue, true);
      expect(updatedState.value!.stats.watchingCount, 10);
    });

    test('build() handles background refresh failure on stale cache', () async {
      final cacheService = CacheService();
      await cacheService.set(
        'dashboard:v2:SERIES',
        CacheEntry(
          json: jsonEncode(
            const DashboardModel(
              watching: DashboardSectionModel(),
              wantToWatch: DashboardSectionModel(),
              completed: DashboardSectionModel(),
              dropped: DashboardSectionModel(),
              stats: DashboardStatsModel(watchingCount: 3),
            ).toJson(),
          ),
          cachedAt: DateTime.now().subtract(const Duration(days: 1)),
          ttl: const Duration(hours: 6),
        ),
      );
      final repo = FakeDashboardRepo()..shouldThrow = true;
      final container = ProviderContainer(
        overrides: [
          dashboardRepositoryProvider.overrideWith((ref) => repo),
          cacheServiceProvider.overrideWith((ref) => cacheService),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(dashboardViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value!.stats.watchingCount, 3);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final error = container.read(dashboardBackgroundErrorProvider);
      expect(error, isNotNull);
    });

    test('loadDashboard() without media type uses shared selection', () async {
      final repo = FakeDashboardRepo();
      final container = ProviderContainer(
        overrides: [
          selectedMediaTypeProvider.overrideWith((ref) => MediaType.movie),
          dashboardRepositoryProvider.overrideWith((ref) => repo),
          cacheServiceProvider.overrideWith((ref) => CacheService()),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(dashboardViewModelProvider, (_, _) {});

      await container.read(dashboardViewModelProvider.notifier).loadDashboard();

      expect(repo.lastMediaType, MediaType.movie);

      sub.close();
    });

    test('loadDashboard() switches media type and reloads', () async {
      final cacheService = CacheService();
      final repo = FakeDashboardRepo()
        ..result = const DashboardModel(
          watching: DashboardSectionModel(),
          wantToWatch: DashboardSectionModel(),
          completed: DashboardSectionModel(),
          dropped: DashboardSectionModel(),
          stats: DashboardStatsModel(watchingCount: 5, totalTracked: 5),
        );
      final container = ProviderContainer(
        overrides: [
          dashboardRepositoryProvider.overrideWith((ref) => repo),
          cacheServiceProvider.overrideWith((ref) => cacheService),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(dashboardViewModelProvider, (_, _) {});

      await container
          .read(dashboardViewModelProvider.notifier)
          .loadDashboard(mediaType: MediaType.movie);

      final state = container.read(dashboardViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value!.stats.watchingCount, 5);

      sub.close();
    });

    test('refresh() ignores invalid stale cache and sets error', () async {
      final cacheService = CacheService();
      await cacheService.set(
        'dashboard:v2:SERIES',
        CacheEntry(
          json: 'not valid json',
          cachedAt: DateTime.now(),
          ttl: const Duration(hours: 6),
        ),
      );
      final repo = FakeDashboardRepo()..shouldThrow = true;
      final container = ProviderContainer(
        overrides: [
          dashboardRepositoryProvider.overrideWith((ref) => repo),
          cacheServiceProvider.overrideWith((ref) => cacheService),
        ],
      );
      addTearDown(container.dispose);

      await container.read(dashboardViewModelProvider.notifier).refresh();

      final state = container.read(dashboardViewModelProvider);
      expect(state.hasError, true);
    });

    test('refresh() sets error when no stale cache is available', () async {
      final repo = FakeDashboardRepo()..shouldThrow = true;
      final container = ProviderContainer(
        overrides: [
          dashboardRepositoryProvider.overrideWith((ref) => repo),
          cacheServiceProvider.overrideWith((ref) => CacheService()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(dashboardViewModelProvider.notifier).refresh();

      final state = container.read(dashboardViewModelProvider);
      expect(state.hasError, true);
    });
  });
}
