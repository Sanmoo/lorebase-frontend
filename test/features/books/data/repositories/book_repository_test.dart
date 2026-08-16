import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/errors/exceptions.dart';
import 'package:lorebase/core/providers/core_providers.dart';
import 'package:lorebase/features/books/data/repositories/book_repository.dart';

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
  group('BookRepositoryImpl', () {
    test('searchBooks() returns the paginated catalog response', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => _json({
            'items': [
              {
                'bookId': 'book-1',
                'title': 'Dune',
                'authors': ['Frank Herbert'],
                'genre': 'Science Fiction',
              },
              {
                'bookId': 'book-2',
                'title': 'Neuromancer',
                'authors': ['William Gibson'],
                'genre': 'Science Fiction',
              },
            ],
            'query': 'dune',
            'count': 2,
            'page': 1,
            'limit': 20,
          }),
        );
      final repo = BookRepositoryImpl(dio);

      final response = await repo.searchBooks('dune');
      expect(response.items, hasLength(2));
      expect(response.items[0].bookId, 'book-1');
      expect(response.items[0].title, 'Dune');
      expect(response.items[0].authors, ['Frank Herbert']);
      expect(response.items[1].title, 'Neuromancer');
      expect(response.query, 'dune');
      expect(response.count, 2);
      expect(response.page, 1);
      expect(response.limit, 20);
    });

    test('searchBooks() passes query, page and limit parameters', () async {
      String? capturedQuery;
      int? capturedPage;
      int? capturedLimit;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedQuery = options.queryParameters['q'] as String?;
            capturedPage = options.queryParameters['page'] as int?;
            capturedLimit = options.queryParameters['limit'] as int?;
            return _json({
              'items': <Map<String, dynamic>>[],
              'query': capturedQuery,
              'count': 0,
              'page': capturedPage,
              'limit': capturedLimit,
            });
          },
        );
      final repo = BookRepositoryImpl(dio);

      await repo.searchBooks('test query', page: 3, limit: 10);
      expect(capturedQuery, 'test query');
      expect(capturedPage, 3);
      expect(capturedLimit, 10);
    });

    test('searchBooks() forwards the cancel token', () async {
      CancelToken? capturedToken;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedToken = options.cancelToken;
            return _json({
              'items': <Map<String, dynamic>>[],
              'query': 'x',
              'count': 0,
            });
          },
        );
      final repo = BookRepositoryImpl(dio);
      final token = CancelToken();

      await repo.searchBooks('x', cancelToken: token);
      expect(capturedToken, same(token));
    });

    test('searchBooks() throws ServerException on DioException', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => throw DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );
      final repo = BookRepositoryImpl(dio);

      expect(() => repo.searchBooks('test'), throwsA(isA<ServerException>()));
    });

    test('searchBooks() surfaces the catalog 400 for a missing query', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => throw DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 400,
            ),
            requestOptions: options,
          ),
        );
      final repo = BookRepositoryImpl(dio);

      try {
        await repo.searchBooks('');
        fail('expected ServerException');
      } on ServerException catch (e) {
        expect(e.statusCode, 400);
      }
    });

    test('getBookById() returns BookModel', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => _json({
            'bookId': 'book-99',
            'title': 'Test Book',
            'authors': ['Author'],
            'description': 'A test description',
            'genre': 'Fiction',
            'pageCount': 300,
            'isbn': '9781234567890',
            'publisher': 'Test Publisher',
            'publishedDate': '2010-05-01',
          }),
        );
      final repo = BookRepositoryImpl(dio);

      final result = await repo.getBookById('book-99');
      expect(result.bookId, 'book-99');
      expect(result.title, 'Test Book');
      expect(result.description, 'A test description');
      expect(result.pageCount, 300);
      expect(result.isbn, '9781234567890');
      expect(result.publisher, 'Test Publisher');
      expect(result.publishedDate, '2010-05-01');
    });

    test('getBookById() throws ServerException on DioException', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) => throw DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );
      final repo = BookRepositoryImpl(dio);

      expect(
        () => repo.getBookById('book-123'),
        throwsA(isA<ServerException>()),
      );
    });

    test('bookRepositoryProvider creates BookRepositoryImpl', () {
      final dio = Dio();
      final container = ProviderContainer(
        overrides: [dioProvider.overrideWith((ref) => dio)],
      );
      addTearDown(container.dispose);

      final repo = container.read(bookRepositoryProvider);
      expect(repo, isA<BookRepositoryImpl>());
    });
  });
}
