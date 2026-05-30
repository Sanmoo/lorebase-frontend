import 'package:flutter/foundation.dart';
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
    debugPrint('[MOVIE_VM] build() started for tmdbId=$tmdbId');
    final mediaId = tmdbId.toString();
    final movieFuture = ref.read(movieRepositoryProvider).getMovieById(mediaId);
    final trackingFuture = ref
        .read(trackingRepositoryProvider)
        .getTrackingByMedia(mediaId, MediaType.movie);

    final movie = await movieFuture;
    TrackedMediaModel? tracking;
    try {
      tracking = await trackingFuture;
      debugPrint(
        '[MOVIE_VM] build() found tracking: rating=${tracking?.rating} status=${tracking?.status}',
      );
    } catch (e) {
      debugPrint('[MOVIE_VM] build() tracking lookup failed: $e');
      tracking = null;
    }
    return MovieDetailState(movie: movie, tracking: tracking);
  }

  Future<void> addTracking(String status, {int? rating, String? review}) async {
    final currentState = state.value;
    if (currentState == null) {
      debugPrint('[MOVIE_VM] addTracking aborted: state.value is null');
      return;
    }
    try {
      final tracking = await ref
          .read(trackingRepositoryProvider)
          .startTracking(
            currentState.movie.tmdbId.toString(),
            MediaType.movie,
            status,
          );
      debugPrint(
        '[MOVIE_VM] startTracking succeeded: mediaId=${tracking.mediaId}',
      );
      final hasExtra =
          (rating != null) || (review != null && review.isNotEmpty);
      if (hasExtra) {
        await ref
            .read(trackingRepositoryProvider)
            .updateTracking(
              tracking.mediaId,
              mediaType: MediaType.movie,
              rating: rating,
              review: review,
            );
        debugPrint('[MOVIE_VM] updateTracking (post-start) succeeded');
      }
      await ref.read(cacheServiceProvider).remove('dashboard:movie');
      await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
      ref.invalidateSelf();
    } catch (e, st) {
      debugPrint('[MOVIE_VM] addTracking failed: $e\n$st');
      rethrow;
    }
  }

  Future<void> updateTracking({
    String? status,
    int? rating,
    String? review,
  }) async {
    final current = state.value?.tracking;
    if (current == null) {
      debugPrint('[MOVIE_VM] updateTracking aborted: tracking is null');
      return;
    }
    try {
      await ref
          .read(trackingRepositoryProvider)
          .updateTracking(
            current.mediaId,
            mediaType: MediaType.movie,
            status: status,
            rating: rating,
            review: review,
          );
      debugPrint(
        '[MOVIE_VM] updateTracking succeeded: mediaId=${current.mediaId} status=$status rating=$rating',
      );
      await ref.read(cacheServiceProvider).remove('dashboard:movie');
      await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
      ref.invalidateSelf();
    } catch (e, st) {
      debugPrint('[MOVIE_VM] updateTracking failed: $e\n$st');
      rethrow;
    }
  }

  Future<void> removeTracking() async {
    final current = state.value?.tracking;
    if (current == null) return;
    await ref
        .read(trackingRepositoryProvider)
        .deleteTracking(current.mediaId, mediaType: MediaType.movie);
    await ref.read(cacheServiceProvider).remove('dashboard:movie');
    await ref.read(cacheServiceProvider).removeByPrefix('tracking:');
    ref.invalidateSelf();
  }
}
