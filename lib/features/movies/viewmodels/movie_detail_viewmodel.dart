import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/cache/cache_providers.dart';
import '../../tracking/data/models/media_type.dart';
import '../../tracking/data/models/tracked_media_model.dart';
import '../../tracking/data/repositories/tracking_repository.dart';
import '../data/repositories/movie_repository.dart';
import 'movie_detail_state.dart';

part 'movie_detail_viewmodel.g.dart';

@riverpod
class MovieDetailViewModel extends _$MovieDetailViewModel {
  @override
  Future<MovieDetailState> build(int tmdbId) async {
    final movie = await ref.read(movieRepositoryProvider).getMovieById(
          tmdbId.toString(),
        );
    TrackedMediaModel? tracking;
    try {
      final allTracking = await ref.read(trackingRepositoryProvider).getTracking(
            mediaType: MediaType.movie,
            pageSize: 1000,
          );
      tracking = allTracking.firstWhere(
        (t) =>
            (t.media != null && t.media!.tmdbId == tmdbId) ||
            t.mediaId == tmdbId.toString(),
      );
    } catch (_) {
      tracking = null;
    }
    return MovieDetailState(movie: movie, tracking: tracking);
  }

  Future<void> addTracking(
    String status, {
    int? rating,
    String? review,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    final tracking = await ref.read(trackingRepositoryProvider).startTracking(
          currentState.movie.tmdbId.toString(),
          MediaType.movie,
          status,
        );
    if (rating != null || (review != null && review.isNotEmpty)) {
      await ref.read(trackingRepositoryProvider).updateTracking(
            tracking.mediaId,
            mediaType: MediaType.movie,
            rating: rating,
            review: review,
          );
    }
    await ref.read(cacheServiceProvider).remove('dashboard:movie');
    await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
    ref.invalidateSelf();
  }

  Future<void> updateTracking({
    String? status,
    int? rating,
    String? review,
  }) async {
    final current = state.valueOrNull?.tracking;
    if (current == null) return;
    await ref.read(trackingRepositoryProvider).updateTracking(
          current.mediaId,
          mediaType: MediaType.movie,
          status: status,
          rating: rating,
          review: review,
        );
    await ref.read(cacheServiceProvider).remove('dashboard:movie');
    await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
    ref.invalidateSelf();
  }

  Future<void> removeTracking() async {
    final current = state.valueOrNull?.tracking;
    if (current == null) return;
    await ref.read(trackingRepositoryProvider).deleteTracking(
          current.mediaId,
          mediaType: MediaType.movie,
        );
    await ref.read(cacheServiceProvider).remove('dashboard:movie');
    await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
    ref.invalidateSelf();
  }
}
