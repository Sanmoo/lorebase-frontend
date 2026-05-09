import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/cache/cache_entry.dart';
import '../../../core/cache/cache_providers.dart';
import '../data/models/dashboard_model.dart';
import '../data/repositories/dashboard_repository.dart';

part 'dashboard_viewmodel.g.dart';

@riverpod
class DashboardViewModel extends _$DashboardViewModel {
  @override
  AsyncValue<DashboardModel> build() {
    final cacheService = ref.read(cacheServiceProvider);

    var hit = cacheService.getSync('dashboard');
    if (hit == null) {
      hit = cacheService.getFromDiskSync('dashboard');
    }

    if (hit != null) {
      final data = DashboardModel.fromJson(
        jsonDecode(hit.json) as Map<String, dynamic>,
      );
      if (!hit.isFresh) {
        _backgroundRefresh();
      }
      return AsyncValue.data(data);
    }

    _loadFromNetwork();
    return const AsyncValue.loading();
  }

  Future<void> _loadFromNetwork() async {
    try {
      final data = await _fetchAndCache();
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<DashboardModel> _fetchAndCache() async {
    final repository = ref.read(dashboardRepositoryProvider);
    final cacheService = ref.read(cacheServiceProvider);
    final data = await repository.getDashboard();
    final entry = CacheEntry(
      json: jsonEncode(data.toJson()),
      cachedAt: DateTime.now(),
      ttl: const Duration(hours: 6),
    );
    await cacheService.set('dashboard', entry);
    return data;
  }

  void _backgroundRefresh() {
    Future(() async {
      try {
        final data = await _fetchAndCache();
        state = AsyncValue.data(data);
      } catch (_) {
        ref.read(dashboardBackgroundErrorProvider.notifier).state =
            'Could not refresh. Pull down to retry.';
      }
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final data = await _fetchAndCache();
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      final cacheService = ref.read(cacheServiceProvider);
      final hit = cacheService.getSync('dashboard');
      if (hit != null) {
        try {
          state = AsyncValue.data(DashboardModel.fromJson(
            jsonDecode(hit.json) as Map<String, dynamic>,
          ));
          return;
        } catch (_) {}
      }
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
