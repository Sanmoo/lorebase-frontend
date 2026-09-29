import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/cache/cache_entry.dart';
import '../../../core/cache/cache_providers.dart';
import '../data/models/media_type.dart';
import '../data/models/tracked_media_model.dart';
import '../data/models/tracking_page_model.dart';
import '../data/repositories/tracking_repository.dart';
import 'tracking_list_state.dart';

part 'tracking_list_viewmodel.g.dart';

@riverpod
class TrackingListViewModel extends _$TrackingListViewModel {
  String? _currentStatus;
  MediaType _currentMediaType = MediaType.series;
  int _requestGeneration = 0;
  bool _isFetching = false;

  /// Reduzível por `--dart-define=TRACKING_PAGE_SIZE=N` para validar a
  /// paginação contra listas curtas.
  static const int _pageSize = int.fromEnvironment(
    'TRACKING_PAGE_SIZE',
    defaultValue: 20,
  );

  @override
  AsyncValue<TrackingListState> build() {
    return const AsyncValue.data(TrackingListState());
  }

  Future<void> loadTracking({
    String? status,
    MediaType mediaType = MediaType.series,
  }) async {
    _currentStatus = status;
    _currentMediaType = mediaType;
    final requestGeneration = ++_requestGeneration;

    final cacheKey = _buildCacheKey();
    final cacheService = ref.read(cacheServiceProvider);

    var hit = cacheService.getSync(cacheKey);
    hit ??= cacheService.getFromDiskSync(cacheKey);

    if (hit != null) {
      final page = _parsePage(hit.json);
      if (_isCurrent(requestGeneration, status, mediaType)) {
        state = AsyncValue.data(TrackingListState(page: page));
        _isFetching = false;
      }
      if (!hit.isFresh) {
        _backgroundRefresh(
          cacheKey,
          status,
          mediaType,
          requestGeneration,
          page.nextCursor,
        );
      }
      return;
    }

    state = const AsyncValue.loading();
    _isFetching = true;
    try {
      await _fetch(
        status: status,
        mediaType: mediaType,
        cursor: null,
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

  /// Busca a próxima página com o token atual e anexa aos itens já exibidos,
  /// deduplicando por `trackingId`. Não dispara quando a lista esgotou
  /// (`nextCursor` ausente) nem durante outra busca.
  Future<void> loadMore() async {
    if (_isFetching) return;
    final current = state.value;
    final cursor = current?.page.nextCursor;
    if (current == null || cursor == null) return;

    _isFetching = true;
    final status = _currentStatus;
    final mediaType = _currentMediaType;
    final cacheKey = _buildCacheKey();
    final requestGeneration = _requestGeneration;
    state = AsyncValue.data(
      current.copyWith(isLoadingMore: true, loadMoreError: null),
    );
    try {
      await _fetch(
        status: status,
        mediaType: mediaType,
        cursor: cursor,
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

  /// Relê a primeira página (sem token) e recalcula o estado de paginação.
  Future<void> refresh() async {
    final cacheService = ref.read(cacheServiceProvider);
    final status = _currentStatus;
    final mediaType = _currentMediaType;
    final requestGeneration = ++_requestGeneration;
    _isFetching = true;
    final key = _buildCacheKey();
    final staleEntry =
        cacheService.getSync(key) ?? cacheService.getFromDiskSync(key);
    await cacheService.remove(key);

    state = const AsyncValue.loading();
    try {
      final repository = ref.read(trackingRepositoryProvider);
      final page = await repository.getTracking(
        status: status,
        mediaType: mediaType,
        pageSize: _pageSize,
      );
      if (!_isCurrent(requestGeneration, status, mediaType)) return;
      await _store(key, page);
      if (!_isCurrent(requestGeneration, status, mediaType)) return;
      state = AsyncValue.data(TrackingListState(page: page));
    } catch (error, stackTrace) {
      if (!_isCurrent(requestGeneration, status, mediaType)) return;
      if (staleEntry != null) {
        await cacheService.set(key, staleEntry);
        if (!_isCurrent(requestGeneration, status, mediaType)) return;
        state = AsyncValue.data(
          TrackingListState(page: _parsePage(staleEntry.json)),
        );
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    } finally {
      if (requestGeneration == _requestGeneration) {
        _isFetching = false;
      }
    }
  }

  Future<void> _fetch({
    required String? status,
    required MediaType mediaType,
    required String? cursor,
    required String cacheKey,
    required int requestGeneration,
    required bool append,
  }) async {
    try {
      final repository = ref.read(trackingRepositoryProvider);

      final loadedPage = await repository.getTracking(
        status: status,
        mediaType: mediaType,
        cursor: cursor,
        pageSize: _pageSize,
      );
      if (!_isCurrent(requestGeneration, status, mediaType)) return;

      final page = append && state.hasValue
          ? loadedPage.copyWith(
              items: _dedupedAppend(state.value!.items, loadedPage.items),
              // `totalCount` só vem na primeira página; preserva o valor já
              // conhecido sem que o fluxo dependa dele.
              totalCount: loadedPage.totalCount ?? state.value!.page.totalCount,
            )
          : loadedPage;

      await _store(cacheKey, page);
      if (!_isCurrent(requestGeneration, status, mediaType)) return;

      state = AsyncValue.data(TrackingListState(page: page));
    } catch (error, stackTrace) {
      if (!_isCurrent(requestGeneration, status, mediaType)) return;
      if (append && state.hasValue) {
        // O token continua o mesmo, então a próxima tentativa rebusca a
        // página que falhou em vez de pular para a seguinte.
        state = AsyncValue.data(
          state.value!.copyWith(
            isLoadingMore: false,
            loadMoreError: error.toString(),
          ),
        );
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  void _backgroundRefresh(
    String key,
    String? status,
    MediaType mediaType,
    int requestGeneration,
    String? cachedNextCursor,
  ) {
    final repository = ref.read(trackingRepositoryProvider);
    final errorNotifier = ref.read(trackingBackgroundErrorProvider.notifier);
    final pageSize = _pageSize;

    Future(() async {
      try {
        final loadedPage = await repository.getTracking(
          status: status,
          mediaType: mediaType,
          pageSize: pageSize,
        );
        if (!_isCurrent(requestGeneration, status, mediaType)) return;
        // Se o usuário já paginou, o refresh não deve encolher a lista.
        if (state.value?.page.nextCursor != cachedNextCursor) return;
        await _store(key, loadedPage);
        if (!_isCurrent(requestGeneration, status, mediaType)) return;
        if (state.value?.page.nextCursor != cachedNextCursor) return;
        if (!ref.mounted) return; // coverage:ignore-line
        state = AsyncValue.data(TrackingListState(page: loadedPage));
      } catch (_) {
        if (_isCurrent(requestGeneration, status, mediaType)) {
          errorNotifier.state = 'Could not refresh. Pull down to retry.';
        }
      }
    });
  }

  Future<void> _store(String key, TrackingPage page) {
    final entry = CacheEntry(
      json: jsonEncode(page.toJson()),
      cachedAt: DateTime.now(),
      ttl: const Duration(hours: 6),
    );
    return ref.read(cacheServiceProvider).set(key, entry);
  }

  List<TrackedMediaModel> _dedupedAppend(
    List<TrackedMediaModel> existing,
    List<TrackedMediaModel> incoming,
  ) {
    final seen = existing.map((e) => e.trackingId).toSet();
    return [
      ...existing,
      ...incoming.where((e) => seen.add(e.trackingId)),
    ];
  }

  bool _isCurrent(
    int requestGeneration,
    String? status,
    MediaType mediaType,
  ) =>
      requestGeneration == _requestGeneration &&
      status == _currentStatus &&
      mediaType == _currentMediaType;

  String _buildCacheKey() =>
      'tracking:v4:${_currentMediaType.apiValue}:${_currentStatus ?? "all"}';

  TrackingPage _parsePage(String json) =>
      TrackingPage.fromJson(Map<String, dynamic>.from(jsonDecode(json) as Map));
}
