import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/cache/cache_providers.dart';
import '../data/repositories/game_repository.dart';
import '../../tracking/data/models/media_type.dart';
import '../../tracking/data/repositories/tracking_repository.dart';
import 'game_detail_state.dart';

part 'game_detail_viewmodel.g.dart';

@riverpod
class GameDetailViewModel extends _$GameDetailViewModel {
  @override
  Future<GameDetailState> build(String gameId) async {
    final gameFuture = ref.read(gameRepositoryProvider).getGameById(gameId);
    final trackingFuture = ref
        .read(trackingRepositoryProvider)
        .getTrackingByMedia(gameId, MediaType.game)
        .catchError((Object e) {
          debugPrint('[GAME_VM] tracking lookup failed: $e');
          return null;
        });

    final game = await gameFuture;
    final tracking = await trackingFuture;
    return GameDetailState(game: game, tracking: tracking);
  }

  Future<void> addTracking(
    String status, {
    required String selectedPlatform,
    double? hoursPlayed,
    int? rating,
    String? review,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    final tracking = await ref
        .read(trackingRepositoryProvider)
        .startTracking(
          currentState.game.gameId,
          MediaType.game,
          status,
          selectedPlatform: selectedPlatform,
          hoursPlayed: hoursPlayed,
        );

    final hasExtra = rating != null || (review != null && review.isNotEmpty);
    if (hasExtra) {
      await ref
          .read(trackingRepositoryProvider)
          .updateTracking(
            tracking.mediaId,
            mediaType: MediaType.game,
            rating: rating,
            review: review,
          );
    }

    await _invalidateCaches();
    ref.invalidateSelf();
  }

  Future<void> updateTracking({
    String? status,
    String? selectedPlatform,
    double? hoursPlayed,
    int? rating,
    String? review,
  }) async {
    final current = state.value?.tracking;
    if (current == null) return;

    await ref
        .read(trackingRepositoryProvider)
        .updateTracking(
          current.mediaId,
          mediaType: MediaType.game,
          status: status,
          selectedPlatform: selectedPlatform,
          hoursPlayed: hoursPlayed,
          rating: rating,
          review: review,
        );

    await _invalidateCaches();
    ref.invalidateSelf();
  }

  Future<void> removeTracking() async {
    final current = state.value?.tracking;
    if (current == null) return;

    await ref
        .read(trackingRepositoryProvider)
        .deleteTracking(current.mediaId, mediaType: MediaType.game);

    await _invalidateCaches();
    ref.invalidateSelf();
  }

  Future<void> _invalidateCaches() async {
    final cacheService = ref.read(cacheServiceProvider);
    await cacheService.remove('dashboard:v2:GAME');
    await cacheService.removeByPrefix('tracking:v2:');
  }
}
