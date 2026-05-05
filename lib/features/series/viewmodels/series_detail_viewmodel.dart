import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/series_repository.dart';
import '../../tracking/data/repositories/tracking_repository.dart';
import '../../tracking/data/models/tracked_series_model.dart';
import 'series_detail_state.dart';

part 'series_detail_viewmodel.g.dart';

@riverpod
class SeriesDetailViewModel extends _$SeriesDetailViewModel {
  @override
  Future<SeriesDetailState> build(int tmdbId) async {
    final seriesRepo = ref.read(seriesRepositoryProvider);
    final trackingRepo = ref.read(trackingRepositoryProvider);

    final series = await seriesRepo.getSeriesById(tmdbId.toString());

    TrackedSeriesModel? tracking;
    try {
      final allTracking = await trackingRepo.getTracking(pageSize: 1000);
      tracking = allTracking.firstWhere(
        (t) => t.series?.tmdbId == tmdbId,
      );
    } catch (_) {
      tracking = null;
    }

    return SeriesDetailState(series: series, tracking: tracking);
  }

  Future<void> addTracking(String status) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    final trackingRepo = ref.read(trackingRepositoryProvider);
    await trackingRepo.startTracking(
      currentState.series.tmdbId.toString(),
      status,
    );
    ref.invalidateSelf();
  }

  Future<void> updateTracking({
    String? status,
    int? seriesRating,
    String? seriesReview,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    final current = currentState.tracking;
    if (current == null) return;

    final trackingRepo = ref.read(trackingRepositoryProvider);
    await trackingRepo.updateTracking(
      current.seriesId,
      status: status,
      seriesRating: seriesRating,
      seriesReview: seriesReview,
    );
    ref.invalidateSelf();
  }

  Future<void> removeTracking() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    final current = currentState.tracking;
    if (current == null) return;

    final trackingRepo = ref.read(trackingRepositoryProvider);
    await trackingRepo.deleteTracking(current.seriesId);
    ref.invalidateSelf();
  }
}
