import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/movies/data/repositories/movie_repository.dart';
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

void main() {
  group('MovieRepositoryImpl', () {
    test('searchMovies() returns list of MovieModel', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => _json({
            'items': [
              {
                'tmdbId': 1,
                'title': 'Inception',
                'genres': ['Sci-Fi'],
                'runtimeMinutes': 148,
                'status': 'Released',
              },
              {
                'tmdbId': 2,
                'title': 'Interstellar',
                'genres': ['Sci-Fi'],
                'runtimeMinutes': 169,
                'status': 'Released',
              },
            ],
          }),
        );
      final repo = MovieRepositoryImpl(dio);

      final results = await repo.searchMovies('incept');
      expect(results.length, 2);
      expect(results[0].tmdbId, 1);
      expect(results[0].title, 'Inception');
      expect(results[1].title, 'Interstellar');
    });

    test('searchMovies() passes query parameters', () async {
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
      final repo = MovieRepositoryImpl(dio);

      await repo.searchMovies('test query', limit: 10);
      expect(capturedQuery, 'test query');
      expect(capturedLimit, 10);
    });

    test('searchMovies() throws ServerException on DioException', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => throw DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );
      final repo = MovieRepositoryImpl(dio);

      expect(
        () => repo.searchMovies('test'),
        throwsA(isA<ServerException>()),
      );
    });

    test('getMovieById() returns MovieModel', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => _json({
            'tmdbId': 99,
            'title': 'Test Movie',
            'overview': 'A test overview',
            'genres': ['Comedy'],
            'runtimeMinutes': 120,
          }),
        );
      final repo = MovieRepositoryImpl(dio);

      final result = await repo.getMovieById('99');
      expect(result.tmdbId, 99);
      expect(result.title, 'Test Movie');
      expect(result.overview, 'A test overview');
    });

    test('getMovieById() throws ServerException on DioException', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => throw DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );
      final repo = MovieRepositoryImpl(dio);

      expect(
        () => repo.getMovieById('123'),
        throwsA(isA<ServerException>()),
      );
    });

    test('movieRepositoryProvider creates MovieRepositoryImpl', () {
      final dio = Dio();
      final container = ProviderContainer(overrides: [
        dioProvider.overrideWith((ref) => dio),
      ]);
      addTearDown(container.dispose);

      final repo = container.read(movieRepositoryProvider);
      expect(repo, isA<MovieRepositoryImpl>());
    });
  });
}
