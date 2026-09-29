import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/repositories/tracking_repository.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/core/errors/exceptions.dart';
import 'package:lorebase/core/providers/core_providers.dart';

class MockAdapter implements HttpClientAdapter {
  final ResponseBody? Function(RequestOptions options)? onFetch;
  MockAdapter({this.onFetch});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (onFetch != null) return onFetch!(options)!;
    return ResponseBody.fromString('', 200);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(dynamic data) => ResponseBody.fromString(
  jsonEncode(data),
  200,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

final now = DateTime.now().toIso8601String();

Map<String, dynamic> _trackingJson(String id, String mediaType) => {
  'trackingId': id,
  'userId': 'user-1',
  'mediaType': mediaType,
  'mediaId': '123',
  'status': 'WATCHING',
  'rating': 8,
  'review': 'Great!',
  'addedAt': now,
  'lastUpdated': now,
  'media': {
    'mediaId': 123,
    'title': mediaType == 'movie' ? 'Movie 123' : 'Series 123',
    'mediaType': mediaType,
  },
};

void main() {
  group('TrackingRepositoryImpl', () {
    test('getTracking() returns items with the continuation token', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => _json({
            'items': [
              _trackingJson('t-1', 'series'),
              _trackingJson('t-2', 'series'),
            ],
            'nextCursor': 'cursor-page-2',
            'totalCount': 42,
            'page': 1,
            'pageSize': 20,
          }),
        );
      final repo = TrackingRepositoryImpl(dio);

      final page = await repo.getTracking();

      expect(page.items.length, 2);
      expect(page.items[0].trackingId, 't-1');
      expect(page.items[1].trackingId, 't-2');
      expect(page.nextCursor, 'cursor-page-2');
      expect(page.totalCount, 42);
      expect(page.pageSize, 20);
    });

    test('getTracking() parses a cursor page without totalCount', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => _json({
            'items': [_trackingJson('t-21', 'series')],
            'nextCursor': 'cursor-page-3',
          }),
        );
      final repo = TrackingRepositoryImpl(dio);

      final page = await repo.getTracking(cursor: 'cursor-page-2');

      expect(page.nextCursor, 'cursor-page-3');
      expect(page.totalCount, isNull);
    });

    test('getTracking() marks the end of the list when nextCursor is absent', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => _json({
            'items': [_trackingJson('t-42', 'series')],
            'totalCount': 42,
            'page': 3,
            'pageSize': 20,
          }),
        );
      final repo = TrackingRepositoryImpl(dio);

      final page = await repo.getTracking(cursor: 'cursor-page-3');

      expect(page.nextCursor, isNull);
    });

    test(
      'getTracking() sends cursor (never page) plus status, mediaType, pageSize, includeMedia',
      () async {
        Map<String, dynamic>? capturedParams;
        final dio = Dio()
          ..httpClientAdapter = MockAdapter(
            onFetch: (options) {
              capturedParams = options.queryParameters;
              return _json({'items': <Map<String, dynamic>>[]});
            },
          );
        final repo = TrackingRepositoryImpl(dio);

        await repo.getTracking(
          status: 'WATCHING',
          mediaType: MediaType.movie,
          cursor: 'cursor-page-2',
          pageSize: 10,
        );

        expect(capturedParams!['status'], 'WATCHING');
        expect(capturedParams!['mediaType'], 'MOVIE');
        expect(capturedParams!['cursor'], 'cursor-page-2');
        expect(capturedParams!['pageSize'], 10);
        expect(capturedParams!['includeMedia'], true);
        expect(capturedParams!.containsKey('page'), isFalse);
      },
    );

    test('getTracking() omits cursor on the first page', () async {
      Map<String, dynamic>? capturedParams;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedParams = options.queryParameters;
            return _json({'items': <Map<String, dynamic>>[]});
          },
        );
      final repo = TrackingRepositoryImpl(dio);

      await repo.getTracking(status: 'WATCHING');

      expect(capturedParams!.containsKey('cursor'), isFalse);
      expect(capturedParams!.containsKey('page'), isFalse);
    });

    test('getTracking() throws ServerException on DioException', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => throw DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );
      final repo = TrackingRepositoryImpl(dio);

      expect(() => repo.getTracking(), throwsA(isA<ServerException>()));
    });

    test('getTrackingByMedia returns tracked media on 200', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
      final adapter = MockAdapter(
        onFetch: (options) {
          expect(options.method, 'GET');
          expect(options.path, '/tracking/42');
          expect(
            options.queryParameters['mediaType'],
            MediaType.series.apiValue,
          );
          return _json({
            'trackingId': 'track-42',
            'userId': 'user-1',
            'mediaType': 'SERIES',
            'mediaId': '42',
            'status': 'WATCHING',
            'addedAt': '2024-01-01T00:00:00Z',
            'lastUpdated': '2024-01-02T00:00:00Z',
          });
        },
      );
      dio.httpClientAdapter = adapter;
      final repo = TrackingRepositoryImpl(dio);

      final tracking = await repo.getTrackingByMedia('42', MediaType.series);

      expect(tracking, isNotNull);
      expect(tracking!.trackingId, 'track-42');
      expect(tracking.mediaId, '42');
      expect(tracking.mediaType, MediaType.series);
      expect(tracking.status, 'WATCHING');
    });

    test('getTrackingByMedia returns book tracking for the book media type',
        () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
      final adapter = MockAdapter(
        onFetch: (options) {
          expect(options.method, 'GET');
          expect(options.path, '/tracking/book-1');
          expect(options.queryParameters['mediaType'], 'BOOK');
          return _json({
            'trackingId': 'track-book-1',
            'userId': 'user-1',
            'mediaType': 'BOOK',
            'mediaId': 'book-1',
            'status': 'WANT_TO_READ',
            'rating': 8,
            'review': 'On the shelf',
            'addedAt': '2024-01-01T00:00:00Z',
            'lastUpdated': '2024-01-02T00:00:00Z',
          });
        },
      );
      dio.httpClientAdapter = adapter;
      final repo = TrackingRepositoryImpl(dio);

      final tracking = await repo.getTrackingByMedia('book-1', MediaType.book);

      expect(tracking, isNotNull);
      expect(tracking!.trackingId, 'track-book-1');
      expect(tracking.mediaType, MediaType.book);
      expect(tracking.status, 'WANT_TO_READ');
      expect(tracking.rating, 8);
      expect(tracking.review, 'On the shelf');
    });

    test('getTrackingByMedia returns null on 404', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
      final adapter = MockAdapter(
        onFetch: (options) {
          expect(options.method, 'GET');
          expect(options.path, '/tracking/42');
          expect(
            options.queryParameters['mediaType'],
            MediaType.series.apiValue,
          );
          throw DioException(
            type: DioExceptionType.badResponse,
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 404,
              data: {'code': 'NOT_FOUND', 'message': 'TrackedMedia not found'},
            ),
          );
        },
      );
      dio.httpClientAdapter = adapter;
      final repo = TrackingRepositoryImpl(dio);

      final tracking = await repo.getTrackingByMedia('42', MediaType.series);

      expect(tracking, isNull);
    });

    test(
      'getTrackingByMedia throws ServerException on non-404 DioException',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
        dio.httpClientAdapter = MockAdapter(
          onFetch: (options) {
            throw DioException(
              type: DioExceptionType.badResponse,
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 500,
                data: {'code': 'SERVER_ERROR', 'message': 'Internal error'},
              ),
            );
          },
        );
        final repo = TrackingRepositoryImpl(dio);

        expect(
          () => repo.getTrackingByMedia('42', MediaType.series),
          throwsA(isA<ServerException>()),
        );
      },
    );

    test('startTracking() POSTs and returns TrackedMediaModel', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => _json(_trackingJson('t-new', 'series')),
        );
      final repo = TrackingRepositoryImpl(dio);

      final result = await repo.startTracking(
        'series-1',
        MediaType.series,
        'WATCHING',
      );
      expect(result.trackingId, 't-new');
      expect(result.status, 'WATCHING');
    });

    test('startTracking() sends selectedPlatform and hoursPlayed', () async {
      Map<String, dynamic>? capturedData;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedData = options.data as Map<String, dynamic>?;
            return _json(_trackingJson('t-new', 'game'));
          },
        );
      final repo = TrackingRepositoryImpl(dio);

      await repo.startTracking(
        'game-1',
        MediaType.game,
        'PLAYING',
        selectedPlatform: 'PC',
        hoursPlayed: 12.5,
      );

      expect(capturedData, isNotNull);
      expect(capturedData!['mediaId'], 'game-1');
      expect(capturedData!['mediaType'], 'GAME');
      expect(capturedData!['status'], 'PLAYING');
      expect(capturedData!['selectedPlatform'], 'PC');
      expect(capturedData!['hoursPlayed'], 12.5);
    });

    test('startTracking() sends modern rating and review keys', () async {
      Map<String, dynamic>? capturedData;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedData = options.data as Map<String, dynamic>?;
            return _json(_trackingJson('t-new', 'series'));
          },
        );
      final repo = TrackingRepositoryImpl(dio);

      await repo.startTracking(
        'series-1',
        MediaType.series,
        'WATCHING',
        rating: 9,
        review: 'muito bom',
      );

      expect(capturedData, isNotNull);
      expect(capturedData!['rating'], 9);
      expect(capturedData!['review'], 'muito bom');
      expect(capturedData!.containsKey('seriesRating'), false);
      expect(capturedData!.containsKey('seriesReview'), false);
    });

    test('startTracking() omits empty review', () async {
      Map<String, dynamic>? capturedData;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedData = options.data as Map<String, dynamic>?;
            return _json(_trackingJson('t-new', 'series'));
          },
        );
      final repo = TrackingRepositoryImpl(dio);

      await repo.startTracking(
        'series-1',
        MediaType.series,
        'WATCHING',
        review: '',
      );

      expect(capturedData, isNotNull);
      expect(capturedData!['review'], isNull);
    });

    test('startTracking() sends book mediaType and reading status', () async {
      Map<String, dynamic>? capturedData;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedData = options.data as Map<String, dynamic>?;
            return _json(_trackingJson('t-book', 'book'));
          },
        );
      final repo = TrackingRepositoryImpl(dio);

      await repo.startTracking(
        'book-1',
        MediaType.book,
        'WANT_TO_READ',
        rating: 7,
        review: 'To read soon',
      );

      expect(capturedData, isNotNull);
      expect(capturedData!['mediaId'], 'book-1');
      expect(capturedData!['mediaType'], 'BOOK');
      expect(capturedData!['status'], 'WANT_TO_READ');
      expect(capturedData!['rating'], 7);
      expect(capturedData!['review'], 'To read soon');
    });

    test('startTracking() throws ServerException on DioException', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => throw DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );
      final repo = TrackingRepositoryImpl(dio);

      expect(
        () => repo.startTracking('1', MediaType.series, 'WATCHING'),
        throwsA(isA<ServerException>()),
      );
    });

    test('updateTracking() PUTs and returns TrackedMediaModel', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => _json(_trackingJson('t-updated', 'series')),
        );
      final repo = TrackingRepositoryImpl(dio);

      final result = await repo.updateTracking(
        'series-1',
        mediaType: MediaType.series,
        status: 'COMPLETED',
        rating: 8,
        review: 'Great!',
      );
      expect(result.trackingId, 't-updated');
      expect(result.status, 'WATCHING'); // from _trackingJson default
    });

    test(
      'updateTracking() sends backend-compatible rating and review keys',
      () async {
        Map<String, dynamic>? capturedData;
        final dio = Dio()
          ..httpClientAdapter = MockAdapter(
            onFetch: (options) {
              capturedData = options.data as Map<String, dynamic>?;
              return _json(_trackingJson('t-updated', 'SERIES'));
            },
          );
        final repo = TrackingRepositoryImpl(dio);

        await repo.updateTracking(
          'series-1',
          mediaType: MediaType.series,
          status: 'WATCHING',
          rating: 8,
          review: 'Great',
        );

        expect(capturedData, isNotNull);
        expect(capturedData!['mediaType'], 'SERIES');
        expect(capturedData!['status'], 'WATCHING');
        expect(capturedData!['seriesRating'], 8);
        expect(capturedData!['seriesReview'], 'Great');
        expect(capturedData!.containsKey('rating'), false);
        expect(capturedData!.containsKey('review'), false);
      },
    );

    test('updateTracking() sends selectedPlatform and hoursPlayed', () async {
      Map<String, dynamic>? capturedData;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedData = options.data as Map<String, dynamic>?;
            return _json(_trackingJson('t-updated', 'game'));
          },
        );
      final repo = TrackingRepositoryImpl(dio);

      await repo.updateTracking(
        'game-1',
        mediaType: MediaType.game,
        status: 'PLAYING',
        selectedPlatform: 'PlayStation 5',
        hoursPlayed: 42.0,
      );

      expect(capturedData, isNotNull);
      expect(capturedData!['mediaType'], 'GAME');
      expect(capturedData!['status'], 'PLAYING');
      expect(capturedData!['selectedPlatform'], 'PlayStation 5');
      expect(capturedData!['hoursPlayed'], 42.0);
    });

    test('updateTracking() sends book mediaType and reading status', () async {
      Map<String, dynamic>? capturedData;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedData = options.data as Map<String, dynamic>?;
            return _json(_trackingJson('t-book-updated', 'book'));
          },
        );
      final repo = TrackingRepositoryImpl(dio);

      await repo.updateTracking(
        'book-1',
        mediaType: MediaType.book,
        status: 'READING',
      );

      expect(capturedData, isNotNull);
      expect(capturedData!['mediaType'], 'BOOK');
      expect(capturedData!['status'], 'READING');
    });

    test('updateTracking() throws ServerException on DioException', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => throw DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );
      final repo = TrackingRepositoryImpl(dio);

      expect(
        () => repo.updateTracking('1', mediaType: MediaType.series),
        throwsA(isA<ServerException>()),
      );
    });

    test('deleteTracking() sends mediaType as query parameter', () async {
      Map<String, dynamic>? capturedParams;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedParams = options.queryParameters;
            return ResponseBody.fromString('', 204);
          },
        );
      final repo = TrackingRepositoryImpl(dio);

      await repo.deleteTracking('series-1', mediaType: MediaType.series);

      expect(capturedParams!['mediaType'], 'SERIES');
    });

    test('deleteTracking() sends book mediaType as query parameter', () async {
      Map<String, dynamic>? capturedParams;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedParams = options.queryParameters;
            return ResponseBody.fromString('', 204);
          },
        );
      final repo = TrackingRepositoryImpl(dio);

      await repo.deleteTracking('book-1', mediaType: MediaType.book);

      expect(capturedParams!['mediaType'], 'BOOK');
    });

    test('deleteTracking() throws ServerException on DioException', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => throw DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );
      final repo = TrackingRepositoryImpl(dio);

      expect(
        () => repo.deleteTracking('1', mediaType: MediaType.series),
        throwsA(isA<ServerException>()),
      );
    });

    test('updateTracking() passes seasonRatings in data', () async {
      Map<String, dynamic>? capturedData;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedData = options.data as Map<String, dynamic>?;
            return _json(_trackingJson('t-updated', 'series'));
          },
        );
      final repo = TrackingRepositoryImpl(dio);

      await repo.updateTracking(
        'series-1',
        mediaType: MediaType.series,
        status: 'WATCHING',
        seasonRatings: [
          {'seasonNumber': 1, 'rating': 8},
        ],
      );
      expect(capturedData, isNotNull);
      expect(capturedData!['seasonRatings'], isA<List>());
      expect((capturedData!['seasonRatings'] as List).length, 1);
    });

    test('trackingRepositoryProvider creates TrackingRepositoryImpl', () {
      final dio = Dio();
      final container = ProviderContainer(
        overrides: [dioProvider.overrideWith((ref) => dio)],
      );
      addTearDown(container.dispose);

      final repo = container.read(trackingRepositoryProvider);
      expect(repo, isA<TrackingRepositoryImpl>());
    });
  });
}
