import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/books/data/models/book_model.dart';
import 'package:lorebase/features/books/data/models/book_search_response.dart';

void main() {
  group('BookSearchResponse', () {
    test('fromJson parses the paginated catalog contract', () {
      final json = {
        'items': [
          {'bookId': 'a1', 'title': 'Dune'},
          {'bookId': 'a2', 'title': 'Neuromancer'},
        ],
        'query': 'dune',
        'count': 2,
        'page': 1,
        'limit': 20,
      };

      final response = BookSearchResponse.fromJson(json);
      expect(response.items, hasLength(2));
      expect(response.items.first, isA<BookModel>());
      expect(response.items.first.title, 'Dune');
      expect(response.query, 'dune');
      expect(response.count, 2);
      expect(response.page, 1);
      expect(response.limit, 20);
    });

    test('fromJson handles an empty items list', () {
      final json = {'items': <Map<String, dynamic>>[], 'query': 'x', 'count': 0};

      final response = BookSearchResponse.fromJson(json);
      expect(response.items, isEmpty);
      expect(response.query, 'x');
      expect(response.count, 0);
    });

    test('fromJson defaults when pagination fields are absent', () {
      final json = {'items': <Map<String, dynamic>>[]};

      final response = BookSearchResponse.fromJson(json);
      expect(response.items, isEmpty);
      expect(response.query, '');
      expect(response.count, 0);
      expect(response.page, 1);
      expect(response.limit, 20);
    });

    test('defaults preserve a sane empty contract', () {
      const response = BookSearchResponse();
      expect(response.items, isEmpty);
      expect(response.query, '');
      expect(response.count, 0);
      expect(response.page, 1);
      expect(response.limit, 20);
    });

    test('copyWith updates pagination state', () {
      const response = BookSearchResponse(
        items: [
          BookModel(bookId: 'a1', title: 'Dune'),
        ],
        query: 'dune',
        count: 1,
        page: 1,
        limit: 20,
      );

      final nextPage = response.copyWith(page: 2);
      expect(nextPage.page, 2);
      expect(nextPage.items, response.items);
    });
  });
}
