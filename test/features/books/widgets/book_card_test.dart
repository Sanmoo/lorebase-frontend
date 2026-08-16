import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/books/data/models/book_model.dart';
import 'package:lorebase/features/books/widgets/book_card.dart';

void main() {
  testWidgets('renders title, authors and genre', (tester) async {
    const book = BookModel(
      bookId: '1',
      title: 'Dune',
      authors: ['Frank Herbert'],
      genre: 'Science Fiction',
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BookCard(book: book))),
    );

    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('Frank Herbert'), findsOneWidget);
    expect(find.text('Science Fiction'), findsOneWidget);
  });

  testWidgets('joins multiple authors with commas', (tester) async {
    const book = BookModel(
      bookId: '2',
      title: 'Good Omens',
      authors: ['Terry Pratchett', 'Neil Gaiman'],
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BookCard(book: book))),
    );

    expect(find.text('Terry Pratchett, Neil Gaiman'), findsOneWidget);
  });

  testWidgets('hides authors and genre when absent', (tester) async {
    const book = BookModel(bookId: '3', title: 'Minimal Book');

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BookCard(book: book))),
    );

    expect(find.text('Minimal Book'), findsOneWidget);
    expect(find.byType(Icon), findsOneWidget); // book placeholder icon
  });

  testWidgets('renders cover and falls back when the image fails to load', (
    tester,
  ) async {
    const book = BookModel(
      bookId: '5',
      title: 'Covered Book',
      coverUrl: 'https://example.com/cover.jpg',
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BookCard(book: book))),
    );

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.imageUrl, 'https://example.com/cover.jpg');
    expect(image.fit, BoxFit.cover);
    expect(image.filterQuality, FilterQuality.high);
    expect(find.text('Covered Book'), findsOneWidget);
  });

  testWidgets('errorIcon returns the book fallback icon', (tester) async {
    Icon? capturedIcon;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          capturedIcon ??= BookCard.errorIcon(
            context,
            '',
            Exception('test'),
          ) as Icon;
          return const SizedBox();
        },
      ),
    );
    expect(capturedIcon, isNotNull);
    expect(capturedIcon!.icon, Icons.menu_book);
  });

  testWidgets('treats an empty coverUrl as absent', (tester) async {
    const book = BookModel(bookId: '6', title: 'Empty Cover', coverUrl: '');

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BookCard(book: book))),
    );

    expect(find.text('Empty Cover'), findsOneWidget);
    expect(find.byIcon(Icons.menu_book), findsOneWidget);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;
    const book = BookModel(bookId: '4', title: 'The Hobbit');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookCard(book: book, onTap: () => tapped = true),
        ),
      ),
    );

    await tester.tap(find.text('The Hobbit'));
    expect(tapped, isTrue);
  });
}
