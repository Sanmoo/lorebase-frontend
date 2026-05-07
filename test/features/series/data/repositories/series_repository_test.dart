import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/series/data/repositories/series_repository.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';
import 'package:lorebase/core/errors/exceptions.dart';

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

void main() {
  group('SeriesRepositoryImpl', () {
    test('searchSeries() returns list of SeriesModel', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => _json({
            'items': [
              {
                'tmdbId': 1,
                'title': 'Breaking Bad',
                'genres': ['Drama'],
                'networks': ['AMC'],
                'seasonCount': 5,
                'status': 'Ended',
              },
              {
                'tmdbId': 2,
                'title': 'Better Call Saul',
                'genres': ['Drama'],
                'networks': ['AMC'],
                'seasonCount': 6,
                'status': 'Ended',
              },
            ],
          }),
        );
      final repo = SeriesRepositoryImpl(dio);

      final results = await repo.searchSeries('breaking');
      expect(results.length, 2);
      expect(results[0].tmdbId, 1);
      expect(results[0].title, 'Breaking Bad');
      expect(results[1].title, 'Better Call Saul');
    });

    test('searchSeries() passes query parameters', () async {
      String? capturedQuery;
      int? capturedLimit;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedQuery = options.queryParameters['q'] as String?;
            capturedLimit = options.queryParameters['limit'] as int?;
            return _json({'items': <Map<String, dynamic>>[]});
          },
        );
      final repo = SeriesRepositoryImpl(dio);

      await repo.searchSeries('test query', limit: 10);
      expect(capturedQuery, 'test query');
      expect(capturedLimit, 10);
    });

    test('searchSeries() throws ServerException on DioException', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => throw DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );
      final repo = SeriesRepositoryImpl(dio);

      expect(
        () => repo.searchSeries('test'),
        throwsA(isA<ServerException>()),
      );
    });

    test('getSeriesById() returns SeriesModel', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => _json({
            'tmdbId': 99,
            'title': 'Test Series',
            'overview': 'A test overview',
            'genres': ['Comedy'],
            'seasonCount': 2,
          }),
        );
      final repo = SeriesRepositoryImpl(dio);

      final result = await repo.getSeriesById('99');
      expect(result.tmdbId, 99);
      expect(result.title, 'Test Series');
      expect(result.overview, 'A test overview');
    });

    test('getSeriesById() throws ServerException on DioException', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => throw DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );
      final repo = SeriesRepositoryImpl(dio);

      expect(
        () => repo.getSeriesById('123'),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
