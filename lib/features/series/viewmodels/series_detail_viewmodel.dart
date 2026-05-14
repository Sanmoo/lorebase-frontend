import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/cache/cache_providers.dart';
import '../data/repositories/series_repository.dart';
import '../../tracking/data/repositories/tracking_repository.dart';
import '../../tracking/data/models/tracked_media_model.dart';
import '../../tracking/data/models/media_type.dart';
import 'series_detail_state.dart';

part 'series_detail_viewmodel.g.dart';

@riverpod
class SeriesDetailViewModel extends _$SeriesDetailViewModel {
  @override
  Future<SeriesDetailState> build(int tmdbId) async {
    final seriesRepo = ref.read(seriesRepositoryProvider);
    final trackingRepo = ref.read(trackingRepositoryProvider);

    final series = await seriesRepo.getSeriesById(tmdbId.toString());

    TrackedMediaModel? tracking;
    try {
      final allTracking = await trackingRepo.getTracking(
        pageSize: 1000,
        mediaType: MediaType.series,
      );
      tracking = allTracking.firstWhere(
        (t) =>
            (t.media != null && t.media!.tmdbId == tmdbId) ||
            t.mediaId == tmdbId.toString(),
      );
    } catch (_) {
      tracking = null;
    }

    return SeriesDetailState(series: series, tracking: tracking);
  }

  Future<void> addTracking(
    String status, {
    int? rating,
    String? review,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    final trackingRepo = ref.read(trackingRepositoryProvider);
    final tracking = await trackingRepo.startTracking(
      currentState.series.tmdbId.toString(),
      MediaType.series,
      status,
    );
    final hasExtra = (rating != null) || (review != null && review.isNotEmpty);
    if (hasExtra) {
      await trackingRepo.updateTracking(
        tracking.mediaId,
        mediaType: MediaType.series,
        rating: rating,
        review: review,
      );
    }
    await ref.read(cacheServiceProvider).remove('dashboard');
    await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
    ref.invalidateSelf();
  }

  Future<void> updateTracking({
    String? status,
    int? rating,
    String? review,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    final current = currentState.tracking;
    if (current == null) return;

    final trackingRepo = ref.read(trackingRepositoryProvider);
    await trackingRepo.updateTracking(
      current.mediaId,
      mediaType: MediaType.series,
      status: status,
      rating: rating,
      review: review,
    );
    await ref.read(cacheServiceProvider).remove('dashboard');
    await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
    ref.invalidateSelf();
  }

  Future<void> removeTracking() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    final current = currentState.tracking;
    if (current == null) return;

    final trackingRepo = ref.read(trackingRepositoryProvider);
    await trackingRepo.deleteTracking(
      current.mediaId,
      mediaType: MediaType.series,
    );
    await ref.read(cacheServiceProvider).remove('dashboard');
    await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
    ref.invalidateSelf();
  }
}
