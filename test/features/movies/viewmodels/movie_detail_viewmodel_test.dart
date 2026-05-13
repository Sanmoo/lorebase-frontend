import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/cache/cache_providers.dart';
import 'package:lorebase/core/cache/cache_service.dart';
import 'package:lorebase/features/movies/data/models/movie_model.dart';
import 'package:lorebase/features/movies/data/repositories/movie_repository.dart';
import 'package:lorebase/features/movies/viewmodels/movie_detail_viewmodel.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_summary_model.dart';
import 'package:lorebase/features/tracking/data/repositories/tracking_repository.dart';

class FakeMovieRepo implements MovieRepository {
  MovieModel? movieResult;

  @override
  Future<MovieModel> getMovieById(String id) async => movieResult!;

  @override
  Future<List<MovieModel>> searchMovies(
    String query, {
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    throw UnimplementedError();
  }
}

class FakeTrackingRepo implements TrackingRepository {
  List<TrackedMediaModel> trackingResults = [];

  @override
  Future<List<TrackedMediaModel>> getTracking({
    String? status,
    MediaType? mediaType,
    int page = 1,
    int pageSize = 20,
  }) async => trackingResults;

  @override
  Future<TrackedMediaModel> startTracking(
    String mediaId,
    MediaType mediaType,
    String status,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<TrackedMediaModel> updateTracking(
    String mediaId, {
    required MediaType mediaType,
    String? status,
    int? rating,
    String? review,
    List<Map<String, dynamic>>? seasonRatings,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTracking(
    String mediaId, {
    required MediaType mediaType,
  }) async {}
}

void main() {
  test('build() loads movie and matching movie tracking', () async {
    final movieRepo = FakeMovieRepo()
      ..movieResult = const MovieModel(tmdbId: 7, title: 'Se7en');
    final trackingRepo = FakeTrackingRepo()
      ..trackingResults = [
        TrackedMediaModel(
          trackingId: 'track-7',
          userId: 'user-1',
          mediaType: MediaType.movie,
          mediaId: '7',
          status: 'WATCHING',
          media: const TrackedMediaSummaryModel(
            tmdbId: 7,
            title: 'Se7en',
            mediaType: MediaType.movie,
          ),
          addedAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        ),
      ];

    final container = ProviderContainer(overrides: [
      movieRepositoryProvider.overrideWith((ref) => movieRepo),
      trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
      cacheServiceProvider.overrideWith((ref) => CacheService()),
    ]);
    addTearDown(container.dispose);

    final state = await container.read(movieDetailViewModelProvider(7).future);

    expect(state.movie.title, 'Se7en');
    expect(state.tracking, isNotNull);
    expect(state.tracking!.mediaType, MediaType.movie);
  });
}
