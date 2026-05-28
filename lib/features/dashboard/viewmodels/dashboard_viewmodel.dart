import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/cache/cache_entry.dart';
import '../../../core/cache/cache_providers.dart';
import '../../../core/providers/media_filter_provider.dart';
import '../../../features/tracking/data/models/media_type.dart';
import '../data/models/dashboard_model.dart';
import '../data/repositories/dashboard_repository.dart';

part 'dashboard_viewmodel.g.dart';

@riverpod
class DashboardViewModel extends _$DashboardViewModel {
  MediaType _currentMediaType = MediaType.series;
  int _requestGeneration = 0;

  @override
  AsyncValue<DashboardModel> build() {
    _currentMediaType = ref.watch(selectedMediaTypeProvider);
    final requestGeneration = ++_requestGeneration;
    final mediaType = _currentMediaType;
    final cacheService = ref.read(cacheServiceProvider);
    final cacheKey = _cacheKeyFor(mediaType);

    var hit = cacheService.getSync(cacheKey);
    hit ??= cacheService.getFromDiskSync(cacheKey);

    if (hit != null) {
      final data = DashboardModel.fromJson(
        jsonDecode(hit.json) as Map<String, dynamic>,
      );
      if (!hit.isFresh) {
        _backgroundRefresh(
          mediaType: mediaType,
          cacheKey: cacheKey,
          requestGeneration: requestGeneration,
        );
      }
      return AsyncValue.data(data);
    }

    _loadFromNetwork(
      mediaType: mediaType,
      cacheKey: cacheKey,
      requestGeneration: requestGeneration,
    );
    return const AsyncValue.loading();
  }

  Future<void> loadDashboard({MediaType? mediaType}) async {
    _currentMediaType = mediaType ?? ref.read(selectedMediaTypeProvider);
    final requestGeneration = ++_requestGeneration;
    final requestMediaType = _currentMediaType;
    final cacheKey = _cacheKeyFor(requestMediaType);
    state = const AsyncValue.loading();
    await _loadFromNetwork(
      mediaType: requestMediaType,
      cacheKey: cacheKey,
      requestGeneration: requestGeneration,
    );
  }

  Future<void> _loadFromNetwork({
    required MediaType mediaType,
    required String cacheKey,
    required int requestGeneration,
  }) async {
    try {
      final data = await _fetchAndCache(
        mediaType: mediaType,
        cacheKey: cacheKey,
        requestGeneration: requestGeneration,
      );
      if (!_isCurrent(requestGeneration, mediaType) || data == null) return;
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      if (_isCurrent(requestGeneration, mediaType)) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<DashboardModel?> _fetchAndCache({
    required MediaType mediaType,
    required String cacheKey,
    required int requestGeneration,
  }) async {
    final repository = ref.read(dashboardRepositoryProvider);
    final cacheService = ref.read(cacheServiceProvider);
    final data = await repository.getDashboard(mediaType: mediaType);
    if (!_isCurrent(requestGeneration, mediaType)) return null;
    final entry = CacheEntry(
      json: jsonEncode(data.toJson()),
      cachedAt: DateTime.now(),
      ttl: const Duration(hours: 6),
    );
    await cacheService.set(cacheKey, entry);
    if (!_isCurrent(requestGeneration, mediaType)) return null;
    return data;
  }

  void _backgroundRefresh({
    required MediaType mediaType,
    required String cacheKey,
    required int requestGeneration,
  }) {
    Future(() async {
      try {
        final data = await _fetchAndCache(
          mediaType: mediaType,
          cacheKey: cacheKey,
          requestGeneration: requestGeneration,
        );
        if (!_isCurrent(requestGeneration, mediaType) || data == null) return;
        state = AsyncValue.data(data);
      } catch (_) {
        if (_isCurrent(requestGeneration, mediaType)) {
          ref.read(dashboardBackgroundErrorProvider.notifier).state =
              'Could not refresh. Pull down to retry.';
        }
      }
    });
  }

  Future<void> refresh() async {
    final requestGeneration = ++_requestGeneration;
    final mediaType = _currentMediaType;
    final cacheKey = _cacheKeyFor(mediaType);
    state = const AsyncValue.loading();
    try {
      final data = await _fetchAndCache(
        mediaType: mediaType,
        cacheKey: cacheKey,
        requestGeneration: requestGeneration,
      );
      if (!_isCurrent(requestGeneration, mediaType) || data == null) return;
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      if (!_isCurrent(requestGeneration, mediaType)) return;
      final cacheService = ref.read(cacheServiceProvider);
      final hit = cacheService.getSync(cacheKey);
      if (hit != null) {
        try {
          state = AsyncValue.data(
            DashboardModel.fromJson(
              jsonDecode(hit.json) as Map<String, dynamic>,
            ),
          );
          return;
        } catch (_) {}
      }
      state = AsyncValue.error(error, stackTrace);
    }
  }

  bool _isCurrent(int requestGeneration, MediaType mediaType) =>
      requestGeneration == _requestGeneration && mediaType == _currentMediaType;

  String _cacheKeyFor(MediaType mediaType) =>
      'dashboard:v2:${mediaType.apiValue}';
}
