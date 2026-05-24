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
  int _requestGeneration = 0;
  bool _isFetching = false;
  static const int _pageSize = 20;

  @override
  AsyncValue<List<TrackedMediaModel>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> loadTracking({
    String? status,
    MediaType mediaType = MediaType.series,
  }) async {
    _currentStatus = status;
    _currentMediaType = mediaType;
    _page = 1;
    final requestGeneration = ++_requestGeneration;

    final cacheKey = _buildCacheKey();
    final cacheService = ref.read(cacheServiceProvider);

    var hit = cacheService.getSync(cacheKey);
    hit ??= cacheService.getFromDiskSync(cacheKey);

    if (hit != null) {
      final items = _parseItems(hit.json);
      if (_isCurrent(requestGeneration, status, mediaType, 1)) {
        state = AsyncValue.data(items);
        _isFetching = false;
      }
      if (!hit.isFresh) {
        _backgroundRefresh(cacheKey, status, mediaType, 1, requestGeneration);
      }
      return;
    }

    state = const AsyncValue.loading();
    _isFetching = true;
    try {
      await _fetch(
        status: status,
        mediaType: mediaType,
        page: 1,
        cacheKey: cacheKey,
        requestGeneration: requestGeneration,
        append: false,
      );
    } finally {
      if (requestGeneration == _requestGeneration) {
        _isFetching = false;
      }
    }
  }

  Future<void> loadMore() async {
    if (_isFetching) return;
    _page++;
    final page = _page;
    final status = _currentStatus;
    final mediaType = _currentMediaType;
    final cacheKey = _buildCacheKey();
    final requestGeneration = _requestGeneration;
    _isFetching = true;
    try {
      await _fetch(
        status: status,
        mediaType: mediaType,
        page: page,
        cacheKey: cacheKey,
        requestGeneration: requestGeneration,
        append: true,
      );
    } finally {
      if (requestGeneration == _requestGeneration) {
        _isFetching = false;
      }
    }
  }

  Future<void> refresh() async {
    final cacheService = ref.read(cacheServiceProvider);
    final status = _currentStatus;
    final mediaType = _currentMediaType;
    final page = _page;
    final requestGeneration = ++_requestGeneration;
    final key = _buildCacheKey();
    final staleEntry = cacheService.getSync(key);
    await cacheService.remove(key);

    state = const AsyncValue.loading();
    try {
      final repository = ref.read(trackingRepositoryProvider);
      final items = await repository.getTracking(
        status: status,
        mediaType: mediaType,
        page: page,
        pageSize: _pageSize,
      );
      if (!_isCurrent(requestGeneration, status, mediaType, page)) return;
      final entry = CacheEntry(
        json: jsonEncode(items.map((e) => e.toJson()).toList()),
        cachedAt: DateTime.now(),
        ttl: const Duration(hours: 6),
      );
      await cacheService.set(key, entry);
      state = AsyncValue.data(items);
    } catch (error, stackTrace) {
      if (!_isCurrent(requestGeneration, status, mediaType, page)) return;
      if (staleEntry != null) {
        await cacheService.set(key, staleEntry);
        state = AsyncValue.data(_parseItems(staleEntry.json));
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<void> _fetch({
    required String? status,
    required MediaType mediaType,
    required int page,
    required String cacheKey,
    required int requestGeneration,
    bool append = false,
  }) async {
    try {
      final repository = ref.read(trackingRepositoryProvider);
      final cacheService = ref.read(cacheServiceProvider);

      final items = await repository.getTracking(
        status: status,
        mediaType: mediaType,
        page: page,
        pageSize: _pageSize,
      );
      if (!_isCurrent(requestGeneration, status, mediaType, page)) return;

      final entry = CacheEntry(
        json: jsonEncode(items.map((e) => e.toJson()).toList()),
        cachedAt: DateTime.now(),
        ttl: const Duration(hours: 6),
      );
      await cacheService.set(cacheKey, entry);

      if (append && state.hasValue) {
        state = AsyncValue.data([...state.value!, ...items]);
      } else {
        state = AsyncValue.data(items);
      }
    } catch (error, stackTrace) {
      if (_isCurrent(requestGeneration, status, mediaType, page)) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  void _backgroundRefresh(
    String key,
    String? status,
    MediaType mediaType,
    int page,
    int requestGeneration,
  ) {
    final repository = ref.read(trackingRepositoryProvider);
    final cacheService = ref.read(cacheServiceProvider);
    final errorNotifier = ref.read(trackingBackgroundErrorProvider.notifier);
    final pageSize = _pageSize;

    Future(() async {
      try {
        final items = await repository.getTracking(
          status: status,
          mediaType: mediaType,
          page: page,
          pageSize: pageSize,
        );
        if (!_isCurrent(requestGeneration, status, mediaType, page)) return;
        final entry = CacheEntry(
          json: jsonEncode(items.map((e) => e.toJson()).toList()),
          cachedAt: DateTime.now(),
          ttl: const Duration(hours: 6),
        );
        await cacheService.set(key, entry);
        if (!ref.mounted) return; // coverage:ignore-line
        state = AsyncValue.data(items);
      } catch (_) {
        errorNotifier.state = 'Could not refresh. Pull down to retry.';
      }
    });
  }

  bool _isCurrent(
    int requestGeneration,
    String? status,
    MediaType mediaType,
    int page,
  ) =>
      requestGeneration == _requestGeneration &&
      status == _currentStatus &&
      mediaType == _currentMediaType &&
      page == _page;

  String _buildCacheKey() =>
      'tracking:v2:${_currentMediaType.apiValue}:${_currentStatus ?? "all"}:$_page';

  List<TrackedMediaModel> _parseItems(String json) {
    final list = jsonDecode(json) as List;
    return list
        .map((e) => TrackedMediaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
