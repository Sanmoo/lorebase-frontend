import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/cache/cache_providers.dart';
import 'package:lorebase/core/cache/cache_entry.dart';
import 'package:lorebase/core/cache/cache_service.dart';
import 'package:lorebase/features/books/data/models/book_model.dart';
import 'package:lorebase/features/books/data/models/book_search_response.dart';
import 'package:lorebase/features/books/data/repositories/book_repository.dart';
import 'package:lorebase/features/books/viewmodels/book_detail_state.dart';
import 'package:lorebase/features/books/viewmodels/book_detail_viewmodel.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';
import 'package:lorebase/features/tracking/data/repositories/tracking_repository.dart';
import 'package:lorebase/features/tracking/data/models/tracking_page_model.dart';

class FakeBookRepo implements BookRepository {
  BookModel? bookResult;
  Completer<BookModel>? bookCompleter;
  bool shouldThrow = false;
  String? lastGetBookById;

  @override
  Future<BookModel> getBookById(String id) async {
    lastGetBookById = id;
    if (bookCompleter != null) return bookCompleter!.future;
    if (shouldThrow) throw Exception('book not found');
    if (bookResult != null) return bookResult!;
    throw UnimplementedError();
  }

  @override
  Future<BookSearchResponse> searchBooks(
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
  int getTrackingByMediaCallCount = 0;
  String? lastGetTrackingByMediaId;
  MediaType? lastGetTrackingByMediaType;

  bool startCalled = false;
  String? lastStartMediaId;
  MediaType? lastStartMediaType;
  String? lastStartStatus;
  int? lastStartRating;
  String? lastStartReview;

  bool updateCalled = false;
  String? lastUpdateMediaId;
  MediaType? lastUpdateMediaType;
  String? lastUpdateStatus;
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
    startCalled = true;
    lastStartMediaId = mediaId;
    lastStartMediaType = mediaType;
    lastStartStatus = status;
    lastStartRating = rating;
    lastStartReview = review;
    final now = DateTime.now();
    return TrackedMediaModel(
      trackingId: 'track-$mediaId',
      userId: 'user-1',
      mediaType: mediaType,
      mediaId: mediaId,
      status: status,
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
    updateCalled = true;
    lastUpdateMediaId = mediaId;
    lastUpdateMediaType = mediaType;
    lastUpdateStatus = status;
    lastUpdateRating = rating;
    lastUpdateReview = review;
    final now = DateTime.now();
    return TrackedMediaModel(
      trackingId: 'track-$mediaId',
      userId: 'user-1',
      mediaType: mediaType,
      mediaId: mediaId,
      status: status ?? 'WANT_TO_READ',
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

const _book = BookModel(bookId: 'abc123', title: 'Dune');

ProviderContainer createContainer({
  required FakeBookRepo bookRepo,
  required FakeTrackingRepo trackingRepo,
  CacheService? cacheService,
}) {
  return ProviderContainer(
    overrides: [
      bookRepositoryProvider.overrideWith((ref) => bookRepo),
      trackingRepositoryProvider.overrideWith((ref) => trackingRepo),
      cacheServiceProvider.overrideWith(
        (ref) => cacheService ?? CacheService(),
      ),
    ],
  );
}

void main() {
  group('BookDetailViewModel', () {
    test('build() passes the requested catalog id to the repository', () async {
      final bookRepo = FakeBookRepo()..bookResult = _book;
      final trackingRepo = FakeTrackingRepo();

      final container = createContainer(
        bookRepo: bookRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      final state = await container.read(
        bookDetailViewModelProvider('abc123').future,
      );

      expect(bookRepo.lastGetBookById, 'abc123');
      expect(state.book.bookId, 'abc123');
      expect(state.book.title, 'Dune');
      expect(state.tracking, isNull);
    });

    test('build() loads tracking for the book media type', () async {
      final bookRepo = FakeBookRepo()..bookResult = _book;
      final trackingRepo = FakeTrackingRepo()
        ..trackingByMediaResult = TrackedMediaModel(
          trackingId: 'track-abc123',
          userId: 'user-1',
          mediaType: MediaType.book,
          mediaId: 'abc123',
          status: 'READING',
          rating: 8,
          review: 'Great so far',
          addedAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

      final container = createContainer(
        bookRepo: bookRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      final state = await container.read(
        bookDetailViewModelProvider('abc123').future,
      );

      expect(trackingRepo.getTrackingByMediaCallCount, 1);
      expect(trackingRepo.lastGetTrackingByMediaId, 'abc123');
      expect(trackingRepo.lastGetTrackingByMediaType, MediaType.book);
      expect(state.tracking, isNotNull);
      expect(state.tracking!.status, 'READING');
      expect(state.tracking!.rating, 8);
      expect(state.tracking!.review, 'Great so far');
    });

    test('build() handles tracking lookup errors gracefully', () async {
      final bookRepo = FakeBookRepo()..bookResult = _book;
      final trackingRepo = FakeTrackingRepo()..shouldThrowTracking = true;

      final container = createContainer(
        bookRepo: bookRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      final state = await container.read(
        bookDetailViewModelProvider('abc123').future,
      );

      expect(state.book.bookId, 'abc123');
      expect(state.tracking, isNull);
    });

    test('build() surfaces repository errors as AsyncError', () async {
      final bookRepo = FakeBookRepo()..shouldThrow = true;
      final trackingRepo = FakeTrackingRepo();
      final container = createContainer(
        bookRepo: bookRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      final states = <AsyncValue<BookDetailState>>[];
      final sub = container.listen<AsyncValue<BookDetailState>>(
        bookDetailViewModelProvider('missing'),
        (prev, next) => states.add(next),
      );
      addTearDown(sub.close);

      // Let the provider build and settle into its error state.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(states.last.hasError, isTrue);
    });

    test('addTracking() starts tracking with the book media type', () async {
      final bookRepo = FakeBookRepo()..bookResult = _book;
      final trackingRepo = FakeTrackingRepo();

      final container = createContainer(
        bookRepo: bookRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      await container.read(bookDetailViewModelProvider('abc123').future);
      await container
          .read(bookDetailViewModelProvider('abc123').notifier)
          .addTracking('WANT_TO_READ', rating: 7, review: 'On the shelf');

      expect(trackingRepo.startCalled, true);
      expect(trackingRepo.lastStartMediaId, 'abc123');
      expect(trackingRepo.lastStartMediaType, MediaType.book);
      expect(trackingRepo.lastStartStatus, 'WANT_TO_READ');
      expect(trackingRepo.lastStartRating, 7);
      expect(trackingRepo.lastStartReview, 'On the shelf');
      expect(trackingRepo.updateCalled, false);
    });

    test('addTracking() no-ops when state has no value', () async {
      final bookRepo = FakeBookRepo()..bookResult = _book;
      final trackingRepo = FakeTrackingRepo();

      final container = createContainer(
        bookRepo: bookRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      container.read(bookDetailViewModelProvider('abc123'));
      await container
          .read(bookDetailViewModelProvider('abc123').notifier)
          .addTracking('WANT_TO_READ');

      expect(trackingRepo.startCalled, false);
    });

    test('updateTracking() updates with the book media type', () async {
      final bookRepo = FakeBookRepo()..bookResult = _book;
      final trackingRepo = FakeTrackingRepo()
        ..trackingByMediaResult = TrackedMediaModel(
          trackingId: 'track-abc123',
          userId: 'user-1',
          mediaType: MediaType.book,
          mediaId: 'abc123',
          status: 'WANT_TO_READ',
          addedAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

      final container = createContainer(
        bookRepo: bookRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      await container.read(bookDetailViewModelProvider('abc123').future);
      await container
          .read(bookDetailViewModelProvider('abc123').notifier)
          .updateTracking(status: 'COMPLETED', rating: 9, review: 'Loved it');

      expect(trackingRepo.updateCalled, true);
      expect(trackingRepo.lastUpdateMediaId, 'abc123');
      expect(trackingRepo.lastUpdateMediaType, MediaType.book);
      expect(trackingRepo.lastUpdateStatus, 'COMPLETED');
      expect(trackingRepo.lastUpdateRating, 9);
      expect(trackingRepo.lastUpdateReview, 'Loved it');
    });

    test('updateTracking() no-ops when tracking is null', () async {
      final bookRepo = FakeBookRepo()..bookResult = _book;
      final trackingRepo = FakeTrackingRepo();

      final container = createContainer(
        bookRepo: bookRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      await container.read(bookDetailViewModelProvider('abc123').future);
      await container
          .read(bookDetailViewModelProvider('abc123').notifier)
          .updateTracking(status: 'READING');

      expect(trackingRepo.updateCalled, false);
    });

    test('removeTracking() deletes with the book media type', () async {
      final bookRepo = FakeBookRepo()..bookResult = _book;
      final trackingRepo = FakeTrackingRepo()
        ..trackingByMediaResult = TrackedMediaModel(
          trackingId: 'track-abc123',
          userId: 'user-1',
          mediaType: MediaType.book,
          mediaId: 'abc123',
          status: 'READING',
          addedAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

      final container = createContainer(
        bookRepo: bookRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      await container.read(bookDetailViewModelProvider('abc123').future);
      await container
          .read(bookDetailViewModelProvider('abc123').notifier)
          .removeTracking();

      expect(trackingRepo.deleteCalled, true);
      expect(trackingRepo.lastDeleteMediaId, 'abc123');
      expect(trackingRepo.lastDeleteMediaType, MediaType.book);
    });

    test('removeTracking() no-ops when tracking is null', () async {
      final bookRepo = FakeBookRepo()..bookResult = _book;
      final trackingRepo = FakeTrackingRepo();

      final container = createContainer(
        bookRepo: bookRepo,
        trackingRepo: trackingRepo,
      );
      addTearDown(container.dispose);

      await container.read(bookDetailViewModelProvider('abc123').future);
      await container
          .read(bookDetailViewModelProvider('abc123').notifier)
          .removeTracking();

      expect(trackingRepo.deleteCalled, false);
    });

    test('tracking mutations invalidate book caches', () async {
      final bookRepo = FakeBookRepo()..bookResult = _book;
      final trackingRepo = FakeTrackingRepo()
        ..trackingByMediaResult = TrackedMediaModel(
          trackingId: 'track-abc123',
          userId: 'user-1',
          mediaType: MediaType.book,
          mediaId: 'abc123',
          status: 'READING',
          addedAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );
      final cacheService = CacheService();
      await cacheService.set('dashboard:v2:BOOK', CacheEntry.test());
      await cacheService.set('tracking:v5:BOOK:all', CacheEntry.test());

      final container = createContainer(
        bookRepo: bookRepo,
        trackingRepo: trackingRepo,
        cacheService: cacheService,
      );
      addTearDown(container.dispose);

      await container.read(bookDetailViewModelProvider('abc123').future);
      await container
          .read(bookDetailViewModelProvider('abc123').notifier)
          .removeTracking();

      expect(cacheService.getSync('dashboard:v2:BOOK'), isNull);
      expect(cacheService.getSync('tracking:v5:BOOK:all'), isNull);
    });
  });
}
