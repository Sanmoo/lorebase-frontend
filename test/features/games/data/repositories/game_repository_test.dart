import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/errors/exceptions.dart';
import 'package:lorebase/core/providers/core_providers.dart';
import 'package:lorebase/features/games/data/repositories/game_repository.dart';

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

void main() {
  group('GameRepositoryImpl', () {
    test('searchGames() returns list of GameModel', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => _json({
            'items': [
              {
                'gameId': 'game-1',
                'title': 'The Last of Us',
                'genre': 'Action',
                'platforms': ['PS5', 'PC'],
                'developer': 'Naughty Dog',
              },
              {
                'gameId': 'game-2',
                'title': 'God of War',
                'genre': 'Action',
                'platforms': ['PS5', 'PC'],
                'developer': 'Santa Monica Studio',
              },
            ],
          }),
        );
      final repo = GameRepositoryImpl(dio);

      final results = await repo.searchGames('test');
      expect(results.length, 2);
      expect(results[0].gameId, 'game-1');
      expect(results[0].title, 'The Last of Us');
      expect(results[1].title, 'God of War');
    });

    test('searchGames() passes query parameters', () async {
      String? capturedQuery;
      int? capturedPage;
      int? capturedLimit;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedQuery = options.queryParameters['q'] as String?;
            capturedPage = options.queryParameters['page'] as int?;
            capturedLimit = options.queryParameters['limit'] as int?;
            return _json({'items': <Map<String, dynamic>>[]});
          },
        );
      final repo = GameRepositoryImpl(dio);

      await repo.searchGames('test query', page: 2, limit: 10);
      expect(capturedQuery, 'test query');
      expect(capturedPage, 2);
      expect(capturedLimit, 10);
    });

    test('searchGames() throws ServerException on DioException', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => throw DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );
      final repo = GameRepositoryImpl(dio);

      expect(() => repo.searchGames('test'), throwsA(isA<ServerException>()));
    });

    test('getGameById() returns GameModel', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => _json({
            'gameId': 'game-99',
            'title': 'Test Game',
            'summary': 'A test summary',
            'genre': 'RPG',
            'platforms': ['PC'],
            'developer': 'Test Dev',
          }),
        );
      final repo = GameRepositoryImpl(dio);

      final result = await repo.getGameById('game-99');
      expect(result.gameId, 'game-99');
      expect(result.title, 'Test Game');
      expect(result.summary, 'A test summary');
    });

    test('getGameById() throws ServerException on DioException', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => throw DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );
      final repo = GameRepositoryImpl(dio);

      expect(
        () => repo.getGameById('game-123'),
        throwsA(isA<ServerException>()),
      );
    });

    test('gameRepositoryProvider creates GameRepositoryImpl', () {
      final dio = Dio();
      final container = ProviderContainer(
        overrides: [dioProvider.overrideWith((ref) => dio)],
      );
      addTearDown(container.dispose);

      final repo = container.read(gameRepositoryProvider);
      expect(repo, isA<GameRepositoryImpl>());
    });
  });
}
