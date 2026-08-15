import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/cache/cache_providers.dart';
import '../../dashboard/viewmodels/dashboard_viewmodel.dart';
import '../data/repositories/series_repository.dart';
import '../../tracking/data/repositories/tracking_repository.dart';
import '../../tracking/data/models/media_type.dart';
import 'series_detail_state.dart';

part 'series_detail_viewmodel.g.dart';

@riverpod
class SeriesDetailViewModel extends _$SeriesDetailViewModel {
  @override
  Future<SeriesDetailState> build(int tmdbId) async {
    debugPrint('[SERIES_VM] build() started for tmdbId=$tmdbId');
    final seriesRepo = ref.read(seriesRepositoryProvider);
    final trackingRepo = ref.read(trackingRepositoryProvider);

    final mediaId = tmdbId.toString();
    final seriesFuture = seriesRepo.getSeriesById(mediaId);
    final trackingFuture = trackingRepo
        .getTrackingByMedia(mediaId, MediaType.series)
        .catchError((Object e) {
          debugPrint('[SERIES_VM] build() tracking lookup failed: $e');
          return null;
        });

    final series = await seriesFuture;
    final tracking = await trackingFuture;
    debugPrint(
      '[SERIES_VM] build() found tracking: rating=${tracking?.rating} status=${tracking?.status}',
    );

    return SeriesDetailState(series: series, tracking: tracking);
  }

  Future<void> addTracking(String status, {int? rating, String? review}) async {
    final currentState = state.value;
    if (currentState == null) return;
    final trackingRepo = ref.read(trackingRepositoryProvider);
    await trackingRepo.startTracking(
      currentState.series.tmdbId.toString(),
      MediaType.series,
      status,
      rating: rating,
      review: review,
    );
    await ref.read(cacheServiceProvider).remove('dashboard:v2:SERIES');
    await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
    ref.invalidate(dashboardViewModelProvider);
    ref.invalidateSelf();
  }

  Future<void> updateTracking({
    String? status,
    int? rating,
    String? review,
  }) async {
    final currentState = state.value;
    if (currentState == null) {
      debugPrint('[SERIES_VM] updateTracking aborted: state.value is null');
      return;
    }
    final current = currentState.tracking;
    if (current == null) {
      debugPrint('[SERIES_VM] updateTracking aborted: tracking is null');
      return;
    }

    final trackingRepo = ref.read(trackingRepositoryProvider);
    try {
      debugPrint(
        '[SERIES_VM] updateTracking calling API: mediaId=${current.mediaId} status=$status rating=$rating review=$review',
      );
      await trackingRepo.updateTracking(
        current.mediaId,
        mediaType: MediaType.series,
        status: status,
        rating: rating,
        review: review,
      );
      debugPrint('[SERIES_VM] updateTracking API call succeeded');
      await ref.read(cacheServiceProvider).remove('dashboard:v2:SERIES');
      await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
      debugPrint('[SERIES_VM] cache cleared, invalidating dashboard and self');
      ref.invalidate(dashboardViewModelProvider);
      ref.invalidateSelf();
    } catch (e, st) {
      debugPrint('[SERIES_VM] updateTracking failed: $e\n$st');
      rethrow;
    }
  }

  Future<void> removeTracking() async {
    final currentState = state.value;
    if (currentState == null) return;
    final current = currentState.tracking;
    if (current == null) return;

    final trackingRepo = ref.read(trackingRepositoryProvider);
    await trackingRepo.deleteTracking(
      current.mediaId,
      mediaType: MediaType.series,
    );
    await ref.read(cacheServiceProvider).remove('dashboard:v2:SERIES');
    await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
    ref.invalidate(dashboardViewModelProvider);
    ref.invalidateSelf();
  }
}
