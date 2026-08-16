import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/books/data/models/book_model.dart';

void main() {
  group('BookModel', () {
    test('fromJson parses backend response', () {
      final json = {
        'bookId': 'x1234',
        'title': 'Dune',
        'authors': ['Frank Herbert'],
        'isbn': '9780441172719',
        'pageCount': 412,
        'coverUrl': 'https://example.com/dune.jpg',
        'publisher': 'Ace Books',
        'publishedDate': '1990-06-01',
        'description': 'A desert planet saga.',
        'genre': 'Science Fiction',
      };

      final model = BookModel.fromJson(json);
      expect(model.bookId, 'x1234');
      expect(model.title, 'Dune');
      expect(model.authors, ['Frank Herbert']);
      expect(model.isbn, '9780441172719');
      expect(model.pageCount, 412);
      expect(model.coverUrl, 'https://example.com/dune.jpg');
      expect(model.publisher, 'Ace Books');
      expect(model.publishedDate, '1990-06-01');
      expect(model.description, 'A desert planet saga.');
      expect(model.genre, 'Science Fiction');
    });

    test('fromJson defaults absent optional fields safely', () {
      final json = {'bookId': 'y5678', 'title': 'Minimal Book'};

      final model = BookModel.fromJson(json);
      expect(model.bookId, 'y5678');
      expect(model.title, 'Minimal Book');
      expect(model.authors, isEmpty);
      expect(model.isbn, isNull);
      expect(model.pageCount, isNull);
      expect(model.coverUrl, isNull);
      expect(model.publisher, isNull);
      expect(model.publishedDate, isNull);
      expect(model.description, isNull);
      expect(model.genre, isNull);
    });

    test('fromJson tolerates unknown and null values from the API', () {
      final json = {
        'bookId': 'z9',
        'title': 'Tolerant Book',
        'authors': null,
        'isbn': null,
        'pageCount': null,
        'coverUrl': null,
        'publisher': null,
        'publishedDate': null,
        'description': null,
        'genre': null,
        'unexpectedField': 'ignored',
      };

      final model = BookModel.fromJson(json);
      expect(model.title, 'Tolerant Book');
      expect(model.authors, isEmpty);
      expect(model.genre, isNull);
    });

    test('toJson round-trips all fields', () {
      const model = BookModel(
        bookId: 'a1',
        title: 'Round Trip',
        authors: ['Author One', 'Author Two'],
        isbn: '9780000000000',
        pageCount: 100,
        coverUrl: 'https://example.com/cover.jpg',
        publisher: 'Publisher',
        publishedDate: '2001-01-01',
        description: 'Description',
        genre: 'Genre',
      );

      final json = model.toJson();
      expect(json['bookId'], 'a1');
      expect(json['title'], 'Round Trip');
      expect(json['authors'], ['Author One', 'Author Two']);
      expect(json['isbn'], '9780000000000');
      expect(json['pageCount'], 100);
      expect(json['coverUrl'], 'https://example.com/cover.jpg');
      expect(json['publisher'], 'Publisher');
      expect(json['publishedDate'], '2001-01-01');
      expect(json['description'], 'Description');
      expect(json['genre'], 'Genre');
    });
  });
}
