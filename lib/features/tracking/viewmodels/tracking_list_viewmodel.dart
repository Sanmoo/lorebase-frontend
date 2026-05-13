import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/cache/cache_entry.dart';
import '../../../core/cache/cache_providers.dart';
import '../data/models/tracked_media_model.dart';
import '../data/models/media_type.dart';
import '../data/repositories/tracking_repository.dart';

part 'tracking_list_viewmodel.g.dart';

@riverpod
class TrackingListViewModel extends _$TrackingListViewModel {
  String? _currentStatus;
  MediaType _currentMediaType = MediaType.series;
  int _page = 1;
  static const int _pageSize = 20;

  @override
  AsyncValue<List<TrackedMediaModel>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> loadTracking({String? status, MediaType mediaType = MediaType.series}) async {
    _currentStatus = status;
    _currentMediaType = mediaType;
    _page = 1;

    final cacheKey = _buildCacheKey();
    final cacheService = ref.read(cacheServiceProvider);

    var hit = cacheService.getSync(cacheKey);
    hit ??= cacheService.getFromDiskSync(cacheKey);

    if (hit != null) {
      final items = _parseItems(hit.json);
      state = AsyncValue.data(items);
      if (!hit.isFresh) {
        _backgroundRefresh(cacheKey);
      }
      return;
    }

    state = const AsyncValue.loading();
    await _fetch(append: false);
  }

  Future<void> loadMore() async {
    if (state.isLoading) return;
    _page++;
    await _fetch(append: true);
  }

  Future<void> refresh() async {
    final cacheService = ref.read(cacheServiceProvider);
    final key = _buildCacheKey();
    final staleEntry = cacheService.getSync(key);
    await cacheService.remove(key);

    state = const AsyncValue.loading();
    try {
      final repository = ref.read(trackingRepositoryProvider);
      final items = await repository.getTracking(
        status: _currentStatus,
        mediaType: _currentMediaType,
        page: _page,
        pageSize: _pageSize,
      );
      final entry = CacheEntry(
        json: jsonEncode(items.map((e) => e.toJson()).toList()),
        cachedAt: DateTime.now(),
        ttl: const Duration(hours: 6),
      );
      await cacheService.set(key, entry);
      state = AsyncValue.data(items);
    } catch (error, stackTrace) {
      if (staleEntry != null) {
        await cacheService.set(key, staleEntry);
        state = AsyncValue.data(_parseItems(staleEntry.json));
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<void> _fetch({bool append = false}) async {
    try {
      final repository = ref.read(trackingRepositoryProvider);
      final cacheService = ref.read(cacheServiceProvider);

      final items = await repository.getTracking(
        status: _currentStatus,
        mediaType: _currentMediaType,
        page: _page,
        pageSize: _pageSize,
      );

      final entry = CacheEntry(
        json: jsonEncode(items.map((e) => e.toJson()).toList()),
        cachedAt: DateTime.now(),
        ttl: const Duration(hours: 6),
      );
      await cacheService.set(_buildCacheKey(), entry);

      if (append && state.hasValue) {
        state = AsyncValue.data([...state.value!, ...items]);
      } else {
        state = AsyncValue.data(items);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void _backgroundRefresh(String key) {
    Future(() async {
      try {
        final repository = ref.read(trackingRepositoryProvider);
        final cacheService = ref.read(cacheServiceProvider);
        final items = await repository.getTracking(
          status: _currentStatus,
          mediaType: _currentMediaType,
          page: _page,
          pageSize: _pageSize,
        );
        final entry = CacheEntry(
          json: jsonEncode(items.map((e) => e.toJson()).toList()),
          cachedAt: DateTime.now(),
          ttl: const Duration(hours: 6),
        );
        await cacheService.set(key, entry);
        state = AsyncValue.data(items);
      } catch (_) {
        ref.read(trackingBackgroundErrorProvider.notifier).state =
            'Could not refresh. Pull down to retry.';
      }
    });
  }

  String _buildCacheKey() => 'tracking:${_currentMediaType.apiValue}:${_currentStatus ?? "all"}:$_page';

  List<TrackedMediaModel> _parseItems(String json) {
    final list = jsonDecode(json) as List;
    return list
        .map((e) => TrackedMediaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
