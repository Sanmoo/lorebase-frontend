import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_model.dart';
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

ResponseBody _jsonBody(Map<String, dynamic> json) => ResponseBody.fromString(
      jsonEncode(json),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      },
    );

Map<String, dynamic> _dashboardJson() => {
      'watching': {
        'items': [
          {
            'mediaId': 1,
            'title': 'Test Show',
            'mediaType': 'SERIES',
          }
        ],
        'total': 1,
        'hasMore': false,
      },
      'wantToWatch': {
        'items': <Map<String, dynamic>>[],
        'total': 0,
        'hasMore': false,
      },
      'completed': {
        'items': <Map<String, dynamic>>[],
        'total': 0,
        'hasMore': false,
      },
      'dropped': {
        'items': <Map<String, dynamic>>[],
        'total': 0,
        'hasMore': false,
      },
      'stats': {
        'watchingCount': 1,
        'wantToWatchCount': 0,
        'completedCount': 0,
        'droppedCount': 0,
        'totalTracked': 1,
      },
    };

void main() {
  group('DashboardRepositoryImpl', () {
    test('getDashboard() returns DashboardModel on success', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => _jsonBody(_dashboardJson()),
        );
      final repo = DashboardRepositoryImpl(dio);

      final result = await repo.getDashboard();
      expect(result, isA<DashboardModel>());
      expect(result.stats.watchingCount, 1);
      expect(result.watching.items.length, 1);
      expect(result.watching.items[0].title, 'Test Show');
    });

    test('getDashboard() throws ServerException on DioException', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => throw DioException(
            type: DioExceptionType.badResponse,
            message: 'Server error',
            requestOptions: RequestOptions(path: ''),
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(path: ''),
            ),
          ),
        );
      final repo = DashboardRepositoryImpl(dio);

      expect(
        () => repo.getDashboard(),
        throwsA(isA<ServerException>()),
      );
    });

    test('getDashboard() sends mediaType to the API', () async {
      Map<String, dynamic>? capturedParams;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedParams = options.queryParameters;
            return _jsonBody(_dashboardJson());
          },
        );
      final repo = DashboardRepositoryImpl(dio);

      await repo.getDashboard(mediaType: MediaType.movie);

      expect(capturedParams!['mediaType'], 'MOVIE');
    });

    test('getDashboard() re-throws ServerException from DioException.error',
        () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => throw DioException(
            type: DioExceptionType.badResponse,
            error: const ServerException(
              message: 'Auth failed',
              statusCode: 401,
            ),
            requestOptions: RequestOptions(path: ''),
          ),
        );
      final repo = DashboardRepositoryImpl(dio);

      expect(
        () => repo.getDashboard(),
        throwsA(isA<ServerException>()),
      );
    });

    test('dashboardRepositoryProvider creates DashboardRepositoryImpl', () {
      final dio = Dio();
      final container = ProviderContainer(overrides: [
        dioProvider.overrideWith((ref) => dio),
      ]);
      addTearDown(container.dispose);

      final repo = container.read(dashboardRepositoryProvider);
      expect(repo, isA<DashboardRepositoryImpl>());
    });
  });
}
