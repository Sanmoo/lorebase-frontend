import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/cache/cache_providers.dart';
import 'package:lorebase/core/cache/cache_entry.dart';
import 'package:lorebase/core/cache/cache_service.dart';
import 'package:lorebase/features/games/data/models/game_model.dart';
import 'package:lorebase/features/games/data/repositories/game_repository.dart';
import 'package:lorebase/features/games/viewmodels/game_detail_viewmodel.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';
import 'package:lorebase/features/tracking/data/repositories/tracking_repository.dart';
import 'package:lorebase/features/tracking/data/models/tracking_page_model.dart';

class FakeGameRepo implements GameRepository {
  GameModel? gameResult;
  Completer<GameModel>? gameCompleter;
  bool shouldThrow = false;
  String? lastGetGameById;

  @override
  Future<GameModel> getGameById(String id) async {
    lastGetGameById = id;
    if (gameCompleter != null) return gameCompleter!.future;
    if (shouldThrow) throw Exception('game not found');
    if (gameResult != null) return gameResult!;
    throw UnimplementedError();
  }

  @override
  Future<List<GameModel>> searchGames(
    String query, {
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    throw UnimplementedError();
  }
}

class FakeTrackingRepo implements TrackingRepository {
  TrackedMediaModel? trackingByMediaResult;
  bool shouldThrowTracking = false;
  bool shouldThrowStart = false;
  bool shouldThrowUpdate = false;
  int getTrackingByMediaCallCount = 0;
  String? lastGetTrackingByMediaId;
  MediaType? lastGetTrackingByMediaType;

  bool startCalled = false;
  String? lastStartMediaId;
  MediaType? lastStartMediaType;
  String? lastStartStatus;
  String? lastStartPlatform;
  double? lastStartHoursPlayed;
  int? lastStartRating;
  String? lastStartReview;

  bool updateCalled = false;
  String? lastUpdateMediaId;
  MediaType? lastUpdateMediaType;
  String? lastUpdateStatus;
  String? lastUpdatePlatform;
  double? lastUpdateHoursPlayed;
  int? lastUpdateRating;
  String? lastUpdateReview;

  bool deleteCalled = false;
  String? lastDeleteMediaId;
  MediaType? lastDeleteMediaType;

  @override
  Future<TrackingPage> getTracking({
    String? status,
    MediaType? mediaType,
    String? cursor,
    int pageSize = 20,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<TrackedMediaModel?> getTrackingByMedia(
    String mediaId,
    MediaType mediaType,
  ) async {
    getTrackingByMediaCallCount++;
    lastGetTrackingByMediaId = mediaId;
    lastGetTrackingByMediaType = mediaType;
    if (shouldThrowTracking) throw Exception('tracking failed');
    return trackingByMediaResult;
  }

  @override
  Future<TrackedMediaModel> startTracking(
    String mediaId,
    MediaType mediaType,
    String status, {
    String? selectedPlatform,
    double? hoursPlayed,
    int? rating,
    String? review,
  }) async {
    if (shouldThrowStart) throw Exception('start failed');
    startCalled = true;
    lastStartMediaId = mediaId;
    lastStartMediaType = mediaType;
    lastStartStatus = status;
    lastStartPlatform = selectedPlatform;
    lastStartHoursPlayed = hoursPlayed;
    lastStartRating = rating;
    lastStartReview = review;
    final now = DateTime.now();
    return TrackedMediaModel(
      trackingId: 'track-$mediaId',
      userId: 'user-1',
      mediaType: mediaType,
      mediaId: mediaId,
      status: status,
      selectedPlatform: selectedPlatform,
      hoursPlayed: hoursPlayed,
      rating: rating,
      review: review,
      addedAt: now,
      lastUpdated: now,
    );
  }

  @override
  Future<TrackedMediaModel> updateTracking(
    String mediaId, {
    required MediaType mediaType,
    String? status,
    int? rating,
    String? review,
    String? selectedPlatform,
    double? hoursPlayed,
    List<Map<String, dynamic>>? seasonRatings,
  }) async {
    if (shouldThrowUpdate) throw Exception('update failed');
    updateCalled = true;
    lastUpdateMediaId = mediaId;
    lastUpdateMediaType = mediaType;
    lastUpdateStatus = status;
    lastUpdateRating = rating;
    lastUpdateReview = review;
    lastUpdatePlatform = selectedPlatform;
    lastUpdateHoursPlayed = hoursPlayed;
    final now = DateTime.now();
    return TrackedMediaModel(
      trackingId: 'track-$mediaId',
      userId: 'user-1',
      mediaType: mediaType,
      mediaId: mediaId,
      status: status ?? 'PLAYING',
      selectedPlatform: selectedPlatform,
      hoursPlayed: hoursPlayed,
      rating: rating,
      review: review,
      addedAt: now,
      lastUpdated: now,
    );
  }

  @override
  Future<void> deleteTracking(
    String mediaId, {
    required MediaType mediaType,
  }) async {
    deleteCalled = true;
    lastDeleteMediaId = mediaId;
    lastDeleteMediaType = mediaType;
  }
}

ProviderContainer createContainer({
  required FakeGameRepo gameRepo,
  required FakeTrackingRepo trackingRepo,
  CacheService? cacheService,
}) {
  return ProviderContainer(
    overrides: [
      gameRepositoryProvider.overrideWith((ref) => gameRepo),
      trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
      cacheServiceProvider.overrideWith(
        (ref) => cacheService ?? CacheService(),
      ),
    ],
  );
}

void main() {
  group('GameDetailViewModel', () {
    test('build() loads game and tracking', () async {
      final gameRepo = FakeGameRepo()
        ..gameResult = const GameModel(gameId: 'g1', title: 'Hollow Knight');
      final trackingRepo = FakeTrackingRepo()
        ..trackingByMediaResult = TrackedMediaModel(
          trackingId: 'track-g1',
          userId: 'user-1',
          mediaType: MediaType.game,
          mediaId: 'g1',
          status: 'PLAYING',
          selectedPlatform: 'PC',
          hoursPlayed: 12.5,
          addedAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

      final container = createContainer(
        gameRepo: gameRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      final state = await container.read(
        gameDetailViewModelProvider('g1').future,
      );

      expect(state.game.gameId, 'g1');
      expect(state.game.title, 'Hollow Knight');
      expect(state.tracking, isNotNull);
      expect(state.tracking!.status, 'PLAYING');
      expect(state.tracking!.selectedPlatform, 'PC');
      expect(state.tracking!.hoursPlayed, 12.5);
      expect(trackingRepo.getTrackingByMediaCallCount, 1);
      expect(trackingRepo.lastGetTrackingByMediaId, 'g1');
      expect(trackingRepo.lastGetTrackingByMediaType, MediaType.game);
    });

    test('build() returns null tracking when none', () async {
      final gameRepo = FakeGameRepo()
        ..gameResult = const GameModel(gameId: 'g2', title: 'Celeste');
      final trackingRepo = FakeTrackingRepo();

      final container = createContainer(
        gameRepo: gameRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      final state = await container.read(
        gameDetailViewModelProvider('g2').future,
      );

      expect(state.game.gameId, 'g2');
      expect(state.tracking, isNull);
    });

    test('build() handles tracking error gracefully', () async {
      final gameRepo = FakeGameRepo()
        ..gameResult = const GameModel(gameId: 'g3', title: 'Ori');
      final trackingRepo = FakeTrackingRepo()..shouldThrowTracking = true;

      final container = createContainer(
        gameRepo: gameRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      final state = await container.read(
        gameDetailViewModelProvider('g3').future,
      );

      expect(state.game.gameId, 'g3');
      expect(state.tracking, isNull);
    });

    test('addTracking() calls startTracking with platform', () async {
      final gameRepo = FakeGameRepo()
        ..gameResult = const GameModel(gameId: 'g1', title: 'Hollow Knight');
      final trackingRepo = FakeTrackingRepo();

      final container = createContainer(
        gameRepo: gameRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      await container.read(gameDetailViewModelProvider('g1').future);
      await container
          .read(gameDetailViewModelProvider('g1').notifier)
          .addTracking('PLAYING', selectedPlatform: 'PC', hoursPlayed: 12.5);

      expect(trackingRepo.startCalled, true);
      expect(trackingRepo.lastStartMediaId, 'g1');
      expect(trackingRepo.lastStartMediaType, MediaType.game);
      expect(trackingRepo.lastStartStatus, 'PLAYING');
      expect(trackingRepo.lastStartPlatform, 'PC');
      expect(trackingRepo.lastStartHoursPlayed, 12.5);
    });

    test('addTracking() sends rating and review in startTracking', () async {
      final gameRepo = FakeGameRepo()
        ..gameResult = const GameModel(gameId: 'g1', title: 'Hollow Knight');
      final trackingRepo = FakeTrackingRepo();

      final container = createContainer(
        gameRepo: gameRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      await container.read(gameDetailViewModelProvider('g1').future);
      await container
          .read(gameDetailViewModelProvider('g1').notifier)
          .addTracking(
            'COMPLETED',
            selectedPlatform: 'Switch',
            hoursPlayed: 45.0,
            rating: 9,
            review: 'Masterpiece',
          );

      expect(trackingRepo.startCalled, true);
      expect(trackingRepo.lastStartRating, 9);
      expect(trackingRepo.lastStartReview, 'Masterpiece');
      expect(trackingRepo.updateCalled, false);
    });

    test('addTracking() no-ops when state has no value', () async {
      final gameRepo = FakeGameRepo()
        ..gameResult = const GameModel(gameId: 'g1', title: 'Hollow Knight');
      final trackingRepo = FakeTrackingRepo();

      final container = createContainer(
        gameRepo: gameRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      container.read(gameDetailViewModelProvider('g1'));
      await container
          .read(gameDetailViewModelProvider('g1').notifier)
          .addTracking('PLAYING', selectedPlatform: 'PC');

      expect(trackingRepo.startCalled, false);
    });

    test('addTracking() sends review in startTracking when rating is null', () async {
      final gameRepo = FakeGameRepo()
        ..gameResult = const GameModel(gameId: 'g1', title: 'Hollow Knight');
      final trackingRepo = FakeTrackingRepo();

      final container = createContainer(
        gameRepo: gameRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      await container.read(gameDetailViewModelProvider('g1').future);
      await container
          .read(gameDetailViewModelProvider('g1').notifier)
          .addTracking(
            'COMPLETED',
            selectedPlatform: 'Switch',
            review: 'Great!',
          );

      expect(trackingRepo.startCalled, true);
      expect(trackingRepo.lastStartRating, isNull);
      expect(trackingRepo.lastStartReview, 'Great!');
      expect(trackingRepo.updateCalled, false);
    });

    test(
      'updateTracking() calls updateTracking with hoursPlayed and platform',
      () async {
        final gameRepo = FakeGameRepo()
          ..gameResult = const GameModel(gameId: 'g1', title: 'Hollow Knight');
        final trackingRepo = FakeTrackingRepo()
          ..trackingByMediaResult = TrackedMediaModel(
            trackingId: 'track-g1',
            userId: 'user-1',
            mediaType: MediaType.game,
            mediaId: 'g1',
            status: 'PLAYING',
            selectedPlatform: 'PC',
            addedAt: DateTime.now(),
            lastUpdated: DateTime.now(),
          );

        final container = createContainer(
          gameRepo: gameRepo,
          trackingRepo: trackingRepo,
        );
        addTearDown(container.dispose);

        await container.read(gameDetailViewModelProvider('g1').future);
        await container
            .read(gameDetailViewModelProvider('g1').notifier)
            .updateTracking(
              status: 'COMPLETED',
              selectedPlatform: 'PlayStation',
              hoursPlayed: 30.0,
              rating: 8,
            );

        expect(trackingRepo.updateCalled, true);
        expect(trackingRepo.lastUpdateMediaId, 'g1');
        expect(trackingRepo.lastUpdateMediaType, MediaType.game);
        expect(trackingRepo.lastUpdateStatus, 'COMPLETED');
        expect(trackingRepo.lastUpdatePlatform, 'PlayStation');
        expect(trackingRepo.lastUpdateHoursPlayed, 30.0);
        expect(trackingRepo.lastUpdateRating, 8);
      },
    );

    test('updateTracking() no-ops when tracking is null', () async {
      final gameRepo = FakeGameRepo()
        ..gameResult = const GameModel(gameId: 'g1', title: 'Hollow Knight');
      final trackingRepo = FakeTrackingRepo();

      final container = createContainer(
        gameRepo: gameRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      await container.read(gameDetailViewModelProvider('g1').future);
      await container
          .read(gameDetailViewModelProvider('g1').notifier)
          .updateTracking(status: 'COMPLETED');

      expect(trackingRepo.updateCalled, false);
    });

    test('removeTracking() calls deleteTracking', () async {
      final gameRepo = FakeGameRepo()
        ..gameResult = const GameModel(gameId: 'g1', title: 'Hollow Knight');
      final trackingRepo = FakeTrackingRepo()
        ..trackingByMediaResult = TrackedMediaModel(
          trackingId: 'track-g1',
          userId: 'user-1',
          mediaType: MediaType.game,
          mediaId: 'g1',
          status: 'PLAYING',
          addedAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

      final container = createContainer(
        gameRepo: gameRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      await container.read(gameDetailViewModelProvider('g1').future);
      await container
          .read(gameDetailViewModelProvider('g1').notifier)
          .removeTracking();

      expect(trackingRepo.deleteCalled, true);
      expect(trackingRepo.lastDeleteMediaId, 'g1');
      expect(trackingRepo.lastDeleteMediaType, MediaType.game);
    });

    test('removeTracking() no-ops when tracking is null', () async {
      final gameRepo = FakeGameRepo()
        ..gameResult = const GameModel(gameId: 'g1', title: 'Hollow Knight');
      final trackingRepo = FakeTrackingRepo();

      final container = createContainer(
        gameRepo: gameRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      await container.read(gameDetailViewModelProvider('g1').future);
      await container
          .read(gameDetailViewModelProvider('g1').notifier)
          .removeTracking();

      expect(trackingRepo.deleteCalled, false);
    });

    test('tracking mutations invalidate game caches', () async {
      final gameRepo = FakeGameRepo()
        ..gameResult = const GameModel(gameId: 'g1', title: 'Hollow Knight');
      final trackingRepo = FakeTrackingRepo()
        ..trackingByMediaResult = TrackedMediaModel(
          trackingId: 'track-g1',
          userId: 'user-1',
          mediaType: MediaType.game,
          mediaId: 'g1',
          status: 'PLAYING',
          addedAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );
      final cacheService = CacheService();
      await cacheService.set('dashboard:v2:GAME', CacheEntry.test());
      await cacheService.set('tracking:v5:GAME:all', CacheEntry.test());

      final container = createContainer(
        gameRepo: gameRepo,
        trackingRepo: trackingRepo,
        cacheService: cacheService,
      );
      addTearDown(container.dispose);

      await container.read(gameDetailViewModelProvider('g1').future);
      await container
          .read(gameDetailViewModelProvider('g1').notifier)
          .removeTracking();

      expect(cacheService.getSync('dashboard:v2:GAME'), isNull);
      expect(cacheService.getSync('tracking:v5:GAME:all'), isNull);
    });
  });
}
