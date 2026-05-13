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
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (onFetch != null) return onFetch!(options)!;
    return ResponseBody.fromString('', 200);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(dynamic data) => ResponseBody.fromString(
      jsonEncode(data),
      200,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
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
        'tmdbId': 123,
        'title': mediaType == 'movie' ? 'Movie 123' : 'Series 123',
        'mediaType': mediaType,
      },
    };

void main() {
  group('TrackingRepositoryImpl', () {
    test('getTracking() returns list of TrackedMediaModel', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => _json({
            'items': [_trackingJson('t-1', 'series'), _trackingJson('t-2', 'series')],
          }),
        );
      final repo = TrackingRepositoryImpl(dio);

      final results = await repo.getTracking();
      expect(results.length, 2);
      expect(results[0].trackingId, 't-1');
      expect(results[1].trackingId, 't-2');
    });

    test('getTracking() passes status, mediaType, page, pageSize, includeMedia',
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
        page: 2,
        pageSize: 10,
      );

      expect(capturedParams!['status'], 'WATCHING');
      expect(capturedParams!['mediaType'], 'movie');
      expect(capturedParams!['page'], 2);
      expect(capturedParams!['pageSize'], 10);
      expect(capturedParams!['includeMedia'], true);
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

      expect(
        () => repo.getTracking(),
        throwsA(isA<ServerException>()),
      );
    });

    test('startTracking() POSTs and returns TrackedMediaModel', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => _json(_trackingJson('t-new', 'series')),
        );
      final repo = TrackingRepositoryImpl(dio);

      final result = await repo.startTracking('series-1', MediaType.series, 'WATCHING');
      expect(result.trackingId, 't-new');
      expect(result.status, 'WATCHING');
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

      expect(capturedParams!['mediaType'], 'series');
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
      final container = ProviderContainer(overrides: [
        dioProvider.overrideWith((ref) => dio),
      ]);
      addTearDown(container.dispose);

      final repo = container.read(trackingRepositoryProvider);
      expect(repo, isA<TrackingRepositoryImpl>());
    });
  });
}
