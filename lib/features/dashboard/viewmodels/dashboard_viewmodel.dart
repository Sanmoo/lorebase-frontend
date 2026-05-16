import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/cache/cache_entry.dart';
import '../../../core/cache/cache_providers.dart';
import '../../../features/tracking/data/models/media_type.dart';
import '../data/models/dashboard_model.dart';
import '../data/repositories/dashboard_repository.dart';

part 'dashboard_viewmodel.g.dart';

@riverpod
class DashboardViewModel extends _$DashboardViewModel {
  MediaType _currentMediaType = MediaType.series;

  @override
  AsyncValue<DashboardModel> build() {
    final cacheService = ref.read(cacheServiceProvider);
    final cacheKey = _cacheKey;

    var hit = cacheService.getSync(cacheKey);
    hit ??= cacheService.getFromDiskSync(cacheKey);

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

  String get _cacheKey => 'dashboard:v2:${_currentMediaType.apiValue}';

  Future<void> loadDashboard({
    MediaType mediaType = MediaType.series,
  }) async {
    _currentMediaType = mediaType;
    state = const AsyncValue.loading();
    await _loadFromNetwork();
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
    final data = await repository.getDashboard(
      mediaType: _currentMediaType,
    );
    final entry = CacheEntry(
      json: jsonEncode(data.toJson()),
      cachedAt: DateTime.now(),
      ttl: const Duration(hours: 6),
    );
    await cacheService.set(_cacheKey, entry);
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
      final hit = cacheService.getSync(_cacheKey);
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
