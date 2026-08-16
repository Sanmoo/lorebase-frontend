import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/books/data/models/book_model.dart';
import 'package:lorebase/features/books/data/models/book_search_response.dart';
import 'package:lorebase/features/books/data/repositories/book_repository.dart';
import 'package:lorebase/features/books/viewmodels/book_detail_state.dart';
import 'package:lorebase/features/books/viewmodels/book_detail_viewmodel.dart';

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

void main() {
  group('BookDetailViewModel', () {
    test('build() passes the requested catalog id to the repository', () async {
      const book = BookModel(bookId: 'abc123', title: 'Dune');
      final repo = FakeBookRepo()..bookResult = book;
      final container = ProviderContainer(
        overrides: [bookRepositoryProvider.overrideWith((ref) => repo)],
      );
      addTearDown(container.dispose);

      final state = await container.read(
        bookDetailViewModelProvider('abc123').future,
      );

      expect(repo.lastGetBookById, 'abc123');
      expect(state.book.bookId, 'abc123');
      expect(state.book.title, 'Dune');
    });

    test('build() surfaces repository errors as AsyncError', () async {
      final repo = FakeBookRepo()..shouldThrow = true;
      final container = ProviderContainer(
        overrides: [bookRepositoryProvider.overrideWith((ref) => repo)],
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
  });
}
