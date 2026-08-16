import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/books/data/models/book_model.dart';
import 'package:lorebase/features/books/data/models/book_search_response.dart';
import 'package:lorebase/features/books/data/repositories/book_repository.dart';
import 'package:lorebase/features/books/viewmodels/book_search_viewmodel.dart';

class FakeBookRepo implements BookRepository {
  BookSearchResponse? response;
  bool shouldThrow = false;
  bool shouldCancel = false;
  int searchCallCount = 0;
  String? lastQuery;
  CancelToken? lastCancelToken;

  @override
  Future<BookSearchResponse> searchBooks(
    String query, {
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    searchCallCount++;
    lastQuery = query;
    lastCancelToken = cancelToken;
    if (shouldCancel) {
      throw DioException(
        type: DioExceptionType.cancel,
        requestOptions: RequestOptions(path: ''),
      );
    }
    if (shouldThrow) {
      throw DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: ''),
      );
    }
    return response ??
        BookSearchResponse(items: const [], query: query, count: 0);
  }

  @override
  Future<BookModel> getBookById(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  group('BookSearchViewModel', () {
    ProviderContainer createContainer(FakeBookRepo repo) {
      return ProviderContainer(
        overrides: [bookRepositoryProvider.overrideWith((ref) => repo)],
      );
    }

    test('build() returns empty list', () {
      final container = createContainer(FakeBookRepo());
      addTearDown(container.dispose);

      final state = container.read(bookSearchViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value, isEmpty);
    });

    test('search() returns the items of the paginated response', () async {
      final results = [
        const BookModel(bookId: '1', title: 'Dune'),
        const BookModel(bookId: '2', title: 'Neuromancer'),
      ];
      final repo = FakeBookRepo()
        ..response = BookSearchResponse(
          items: results,
          query: 'dune',
          count: 2,
          page: 1,
          limit: 20,
        );
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container.read(bookSearchViewModelProvider.notifier).search('dune');

      final state = container.read(bookSearchViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value!.length, 2);
      expect(state.value![0].title, 'Dune');
      expect(repo.lastQuery, 'dune');
    });

    test('search() cancels previous request', () async {
      final repo = FakeBookRepo()
        ..response = const BookSearchResponse(
          items: [BookModel(bookId: '1', title: 'Later')],
          count: 1,
        );
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(bookSearchViewModelProvider.notifier);

      final firstSearch = notifier.search('first');
      final firstToken = repo.lastCancelToken;
      expect(firstToken, isNotNull);
      expect(firstToken!.isCancelled, isFalse);

      await notifier.search('second');
      expect(firstToken.isCancelled, isTrue);
      expect(repo.lastQuery, 'second');

      await firstSearch;
      final state = container.read(bookSearchViewModelProvider);
      expect(state.value!.length, 1);
      expect(state.value![0].title, 'Later');
    });

    test('search() handles empty query', () async {
      final repo = FakeBookRepo()
        ..response = const BookSearchResponse(
          items: [BookModel(bookId: '1', title: 'Test')],
          count: 1,
        );
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(bookSearchViewModelProvider.notifier);
      await notifier.search('test');
      expect(container.read(bookSearchViewModelProvider).value!.length, 1);

      await notifier.search('');
      expect(container.read(bookSearchViewModelProvider).value, isEmpty);
      expect(repo.searchCallCount, 1);
    });

    test('search() handles whitespace-only query as empty', () async {
      final repo = FakeBookRepo()
        ..response = const BookSearchResponse(
          items: [BookModel(bookId: '1', title: 'Test')],
          count: 1,
        );
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(bookSearchViewModelProvider.notifier);
      await notifier.search('   ');
      expect(container.read(bookSearchViewModelProvider).value, isEmpty);
      expect(repo.searchCallCount, 0);
    });

    test('search() error sets AsyncValue.error', () async {
      final repo = FakeBookRepo()..shouldThrow = true;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container.read(bookSearchViewModelProvider.notifier).search('test');

      final state = container.read(bookSearchViewModelProvider);
      expect(state.hasError, true);
    });

    test('search() ignores cancellation errors', () async {
      final repo = FakeBookRepo()..shouldCancel = true;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container.read(bookSearchViewModelProvider.notifier).search('test');

      final state = container.read(bookSearchViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value, isEmpty);
    });

    test('clear() cancels and resets', () async {
      final repo = FakeBookRepo()
        ..response = const BookSearchResponse(
          items: [BookModel(bookId: '1', title: 'Test')],
          count: 1,
        );
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(bookSearchViewModelProvider.notifier);
      await notifier.search('test');
      expect(container.read(bookSearchViewModelProvider).value!.length, 1);

      notifier.clear();
      expect(container.read(bookSearchViewModelProvider).value, isEmpty);
    });

    test('search() passes CancelToken to repository', () async {
      final repo = FakeBookRepo();
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container.read(bookSearchViewModelProvider.notifier).search('test');

      expect(repo.lastCancelToken, isNotNull);
      expect(repo.lastCancelToken, isA<CancelToken>());
    });
  });
}
