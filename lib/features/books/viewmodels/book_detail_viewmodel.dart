import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/cache/cache_providers.dart';
import '../../dashboard/viewmodels/dashboard_viewmodel.dart';
import '../../tracking/data/models/media_type.dart';
import '../../tracking/data/repositories/tracking_repository.dart';
import '../../tracking/data/tracking_cache.dart';
import '../data/repositories/book_repository.dart';
import 'book_detail_state.dart';

part 'book_detail_viewmodel.g.dart';

@riverpod
class BookDetailViewModel extends _$BookDetailViewModel {
  @override
  Future<BookDetailState> build(String bookId) async {
    final bookFuture = ref.read(bookRepositoryProvider).getBookById(bookId);
    final trackingFuture = ref
        .read(trackingRepositoryProvider)
        .getTrackingByMedia(bookId, MediaType.book)
        .catchError((Object e) {
          debugPrint('[BOOK_VM] tracking lookup failed: $e');
          return null;
        });

    final book = await bookFuture;
    final tracking = await trackingFuture;
    return BookDetailState(book: book, tracking: tracking);
  }

  Future<void> addTracking(
    String status, {
    int? rating,
    String? review,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    await ref
        .read(trackingRepositoryProvider)
        .startTracking(
          currentState.book.bookId,
          MediaType.book,
          status,
          rating: rating,
          review: review,
        );

    await _invalidateCaches();
    ref.invalidateSelf();
  }

  Future<void> updateTracking({
    String? status,
    int? rating,
    String? review,
  }) async {
    final current = state.value?.tracking;
    if (current == null) return;

    await ref
        .read(trackingRepositoryProvider)
        .updateTracking(
          current.mediaId,
          mediaType: MediaType.book,
          status: status,
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
        .deleteTracking(current.mediaId, mediaType: MediaType.book);

    await _invalidateCaches();
    ref.invalidateSelf();
  }

  Future<void> _invalidateCaches() async {
    final cacheService = ref.read(cacheServiceProvider);
    await cacheService.remove('dashboard:v2:BOOK');
    await cacheService.removeByPrefix(trackingCacheInvalidationPrefix);
    ref.invalidate(dashboardViewModelProvider);
  }
}
