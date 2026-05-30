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
  bool shouldThrow = false;
  bool shouldThrowStart = false;
  bool shouldThrowUpdate = false;
  String? lastStatus;
  String? lastMediaId;
  MediaType? lastMediaType;
  int? lastRating;
  String? lastReview;
  bool deleteCalled = false;
  bool updateCalled = false;
  bool startCalled = false;

  @override
  Future<List<TrackedMediaModel>> getTracking({
    String? status,
    MediaType? mediaType,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (shouldThrow) throw Exception('Failed');
    return trackingResults;
  }

  @override
  Future<TrackedMediaModel?> getTrackingByMedia(
    String mediaId,
    MediaType mediaType,
  ) async {
    return null;
  }

  @override
  Future<TrackedMediaModel> startTracking(
    String mediaId,
    MediaType mediaType,
    String status,
  ) async {
    if (shouldThrowStart) throw Exception('start failed');
    startCalled = true;
    lastMediaId = mediaId;
    lastMediaType = mediaType;
    lastStatus = status;
    return TrackedMediaModel(
      trackingId: 'new-track',
      userId: 'user-1',
      mediaType: mediaType,
      mediaId: mediaId,
      status: status,
      addedAt: DateTime.now(),
      lastUpdated: DateTime.now(),
    );
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
    if (shouldThrowUpdate) throw Exception('update failed');
    updateCalled = true;
    lastMediaId = mediaId;
    lastMediaType = mediaType;
    lastStatus = status;
    lastRating = rating;
    lastReview = review;
    return TrackedMediaModel(
      trackingId: mediaId,
      userId: 'user-1',
      mediaType: mediaType,
      mediaId: '7',
      status: status ?? 'WATCHING',
      addedAt: DateTime.now(),
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Future<void> deleteTracking(
    String mediaId, {
    required MediaType mediaType,
  }) async {
    deleteCalled = true;
    lastMediaId = mediaId;
    lastMediaType = mediaType;
  }
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
            mediaId: '7',
            title: 'Se7en',
            mediaType: MediaType.movie,
          ),
          addedAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        ),
      ];

    final container = ProviderContainer(
      overrides: [
        movieRepositoryProvider.overrideWith((ref) => movieRepo),
        trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
        cacheServiceProvider.overrideWith((ref) => CacheService()),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(movieDetailViewModelProvider(7).future);

    expect(state.movie.title, 'Se7en');
    expect(state.tracking, isNotNull);
    expect(state.tracking!.mediaType, MediaType.movie);
  });

  test('build() handles tracking fetch error gracefully', () async {
    final movieRepo = FakeMovieRepo()
      ..movieResult = const MovieModel(tmdbId: 7, title: 'Se7en');
    final trackingRepo = FakeTrackingRepo()..shouldThrow = true;

    final container = ProviderContainer(
      overrides: [
        movieRepositoryProvider.overrideWith((ref) => movieRepo),
        trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
        cacheServiceProvider.overrideWith((ref) => CacheService()),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(movieDetailViewModelProvider(7).future);

    expect(state.movie.title, 'Se7en');
    expect(state.tracking, isNull);
  });

  test('addTracking() calls startTracking and invalidates', () async {
    final movieRepo = FakeMovieRepo()
      ..movieResult = const MovieModel(tmdbId: 7, title: 'Se7en');
    final trackingRepo = FakeTrackingRepo();

    final container = ProviderContainer(
      overrides: [
        movieRepositoryProvider.overrideWith((ref) => movieRepo),
        trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
        cacheServiceProvider.overrideWith((ref) => CacheService()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(movieDetailViewModelProvider(7).future);
    await container
        .read(movieDetailViewModelProvider(7).notifier)
        .addTracking('WATCHING');

    expect(trackingRepo.startCalled, true);
    expect(trackingRepo.lastStatus, 'WATCHING');
  });

  test('addTracking() calls updateTracking with review only', () async {
    final movieRepo = FakeMovieRepo()
      ..movieResult = const MovieModel(tmdbId: 7, title: 'Se7en');
    final trackingRepo = FakeTrackingRepo();

    final container = ProviderContainer(
      overrides: [
        movieRepositoryProvider.overrideWith((ref) => movieRepo),
        trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
        cacheServiceProvider.overrideWith((ref) => CacheService()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(movieDetailViewModelProvider(7).future);
    await container
        .read(movieDetailViewModelProvider(7).notifier)
        .addTracking('WATCHING', review: 'Nice movie');

    expect(trackingRepo.updateCalled, true);
    expect(trackingRepo.lastReview, 'Nice movie');
  });

  test('addTracking() includes rating and review when provided', () async {
    final movieRepo = FakeMovieRepo()
      ..movieResult = const MovieModel(tmdbId: 7, title: 'Se7en');
    final trackingRepo = FakeTrackingRepo();

    final container = ProviderContainer(
      overrides: [
        movieRepositoryProvider.overrideWith((ref) => movieRepo),
        trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
        cacheServiceProvider.overrideWith((ref) => CacheService()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(movieDetailViewModelProvider(7).future);
    await container
        .read(movieDetailViewModelProvider(7).notifier)
        .addTracking('WATCHING', rating: 5, review: 'Great!');

    expect(trackingRepo.updateCalled, true);
    expect(trackingRepo.lastRating, 5);
    expect(trackingRepo.lastReview, 'Great!');
  });

  test('addTracking() does nothing when state has no value', () async {
    final movieRepo = FakeMovieRepo()
      ..movieResult = const MovieModel(tmdbId: 7, title: 'Se7en');
    final trackingRepo = FakeTrackingRepo();

    final container = ProviderContainer(
      overrides: [
        movieRepositoryProvider.overrideWith((ref) => movieRepo),
        trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
        cacheServiceProvider.overrideWith((ref) => CacheService()),
      ],
    );
    addTearDown(container.dispose);

    // Don't await build - state still loading
    container.read(movieDetailViewModelProvider(7));
    await container
        .read(movieDetailViewModelProvider(7).notifier)
        .addTracking('WATCHING');

    expect(trackingRepo.startCalled, false);
  });

  test('updateTracking() updates tracking data', () async {
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
          addedAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        ),
      ];

    final container = ProviderContainer(
      overrides: [
        movieRepositoryProvider.overrideWith((ref) => movieRepo),
        trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
        cacheServiceProvider.overrideWith((ref) => CacheService()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(movieDetailViewModelProvider(7).future);
    await container
        .read(movieDetailViewModelProvider(7).notifier)
        .updateTracking(status: 'COMPLETED', rating: 4);

    expect(trackingRepo.updateCalled, true);
    expect(trackingRepo.lastStatus, 'COMPLETED');
    expect(trackingRepo.lastRating, 4);
  });

  test('addTracking() rethrows repository error', () async {
    final movieRepo = FakeMovieRepo()
      ..movieResult = const MovieModel(tmdbId: 7, title: 'Se7en');
    final trackingRepo = FakeTrackingRepo()..shouldThrowStart = true;

    final container = ProviderContainer(
      overrides: [
        movieRepositoryProvider.overrideWith((ref) => movieRepo),
        trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
        cacheServiceProvider.overrideWith((ref) => CacheService()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(movieDetailViewModelProvider(7).future);

    expect(
      () => container
          .read(movieDetailViewModelProvider(7).notifier)
          .addTracking('WATCHING'),
      throwsException,
    );
  });

  test('updateTracking() rethrows repository error', () async {
    final movieRepo = FakeMovieRepo()
      ..movieResult = const MovieModel(tmdbId: 7, title: 'Se7en');
    final trackingRepo = FakeTrackingRepo()
      ..shouldThrowUpdate = true
      ..trackingResults = [
        TrackedMediaModel(
          trackingId: 'track-7',
          userId: 'user-1',
          mediaType: MediaType.movie,
          mediaId: '7',
          status: 'WATCHING',
          addedAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        ),
      ];

    final container = ProviderContainer(
      overrides: [
        movieRepositoryProvider.overrideWith((ref) => movieRepo),
        trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
        cacheServiceProvider.overrideWith((ref) => CacheService()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(movieDetailViewModelProvider(7).future);

    expect(
      () => container
          .read(movieDetailViewModelProvider(7).notifier)
          .updateTracking(status: 'COMPLETED'),
      throwsException,
    );
  });

  test('updateTracking() does nothing when no tracking exists', () async {
    final movieRepo = FakeMovieRepo()
      ..movieResult = const MovieModel(tmdbId: 7, title: 'Se7en');
    final trackingRepo = FakeTrackingRepo();

    final container = ProviderContainer(
      overrides: [
        movieRepositoryProvider.overrideWith((ref) => movieRepo),
        trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
        cacheServiceProvider.overrideWith((ref) => CacheService()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(movieDetailViewModelProvider(7).future);
    await container
        .read(movieDetailViewModelProvider(7).notifier)
        .updateTracking(status: 'COMPLETED');

    expect(trackingRepo.updateCalled, false);
  });

  test('removeTracking() deletes tracking', () async {
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
          addedAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        ),
      ];

    final container = ProviderContainer(
      overrides: [
        movieRepositoryProvider.overrideWith((ref) => movieRepo),
        trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
        cacheServiceProvider.overrideWith((ref) => CacheService()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(movieDetailViewModelProvider(7).future);
    await container
        .read(movieDetailViewModelProvider(7).notifier)
        .removeTracking();

    expect(trackingRepo.deleteCalled, true);
  });

  test('removeTracking() does nothing when no tracking exists', () async {
    final movieRepo = FakeMovieRepo()
      ..movieResult = const MovieModel(tmdbId: 7, title: 'Se7en');
    final trackingRepo = FakeTrackingRepo();

    final container = ProviderContainer(
      overrides: [
        movieRepositoryProvider.overrideWith((ref) => movieRepo),
        trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
        cacheServiceProvider.overrideWith((ref) => CacheService()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(movieDetailViewModelProvider(7).future);
    await container
        .read(movieDetailViewModelProvider(7).notifier)
        .removeTracking();

    expect(trackingRepo.deleteCalled, false);
  });
}
