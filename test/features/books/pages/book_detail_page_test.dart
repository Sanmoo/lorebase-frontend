import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/books/data/models/book_model.dart';
import 'package:lorebase/features/books/pages/book_detail_page.dart';
import 'package:lorebase/features/books/viewmodels/book_detail_state.dart';
import 'package:lorebase/features/books/viewmodels/book_detail_viewmodel.dart';
import 'package:lorebase/l10n/strings.g.dart';

BookModel _richBook() => const BookModel(
  bookId: 'dune-1',
  title: 'Dune',
  authors: ['Frank Herbert'],
  isbn: '9780441172719',
  pageCount: 412,
  coverUrl: 'https://example.com/dune.jpg',
  publisher: 'Ace Books',
  publishedDate: '1990-06-01',
  description:
      'Set on the desert planet Arrakis, Dune is the story of Paul Atreides, '
      'who would become known as Muad\'Dib — and of a great family\'s '
      'ambition to control an inimitable resource: the spice melange.',
  genre: 'Science Fiction',
);

BookModel _minimalBook() => const BookModel(bookId: 'min-1', title: 'Minimal');

class FakeDetailVM extends BookDetailViewModel {
  final BookDetailState data;

  FakeDetailVM({required this.data});

  @override
  Future<BookDetailState> build(String bookId) async => data;
}

class _LoadingDetailVM extends BookDetailViewModel {
  @override
  Future<BookDetailState> build(String bookId) async {
    return Completer<BookDetailState>().future;
  }
}

class _ErrorDetailVM extends BookDetailViewModel {
  @override
  Future<BookDetailState> build(String bookId) async {
    throw Exception('Test error message');
  }
}

Widget _wrap(ProviderContainer container, {String bookId = 'dune-1'}) {
  return UncontrolledProviderScope(
    container: container,
    child: TranslationProvider(
      child: MaterialApp.router(
        locale: AppLocale.enUs.flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: GoRouter(
          initialLocation: '/books/$bookId',
          routes: [
            GoRoute(
              path: '/books/:bookId',
              builder: (_, state) => BookDetailPage(
                bookId: state.pathParameters['bookId']!,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  group('BookDetailPage', () {
    testWidgets('shows loading indicator while fetching', (tester) async {
      final container = ProviderContainer(
        overrides: [
          bookDetailViewModelProvider('dune-1').overrideWith(
            () => _LoadingDetailVM(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading book details...'), findsOneWidget);
    });

    testWidgets('shows error message and retry when the fetch fails', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          bookDetailViewModelProvider('dune-1').overrideWith(
            () => _ErrorDetailVM(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pumpAndSettle();

      expect(find.text('Exception: Test error message'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders cover, title, authors and genre in evidence', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          bookDetailViewModelProvider('dune-1').overrideWith(
            () => FakeDetailVM(data: BookDetailState(book: _richBook())),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Dune'), findsNWidgets(2)); // app bar + body
      expect(find.text('Frank Herbert'), findsOneWidget);
      expect(find.text('Science Fiction'), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('renders synopsis, pages, ISBN, publisher and publication', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          bookDetailViewModelProvider('dune-1').overrideWith(
            () => FakeDetailVM(data: BookDetailState(book: _richBook())),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Synopsis'), findsOneWidget);
      expect(find.textContaining('Set on the desert planet Arrakis'), findsOneWidget);
      expect(find.text('Pages'), findsOneWidget);
      expect(find.text('412 pages'), findsOneWidget);
      expect(find.text('ISBN'), findsOneWidget);
      expect(find.text('9780441172719'), findsOneWidget);
      expect(find.text('Publisher'), findsOneWidget);
      expect(find.text('Ace Books'), findsOneWidget);
      expect(find.text('Published'), findsOneWidget);
      expect(find.text('Jun 1, 1990'), findsOneWidget);
    });

    testWidgets('hides absent optional fields without placeholders', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          bookDetailViewModelProvider('min-1').overrideWith(
            () => FakeDetailVM(data: BookDetailState(book: _minimalBook())),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container, bookId: 'min-1'));
      await tester.pump();

      expect(find.text('Minimal'), findsNWidgets(2));
      // No placeholder dashes for missing metadata.
      expect(find.text('—'), findsNothing);
      expect(find.text('Pages'), findsNothing);
      expect(find.text('ISBN'), findsNothing);
      expect(find.text('Publisher'), findsNothing);
      expect(find.text('Published'), findsNothing);
      // Authors and genre sections are absent too.
      expect(find.text('No synopsis available.'), findsOneWidget);
    });

    testWidgets('long synopsis can be expanded and collapsed', (tester) async {
      final container = ProviderContainer(
        overrides: [
          bookDetailViewModelProvider('dune-1').overrideWith(
            () => FakeDetailVM(data: BookDetailState(book: _richBook())),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Show more'), findsOneWidget);

      await tester.ensureVisible(find.text('Show more'));
      await tester.tap(find.text('Show more'));
      await tester.pump();

      expect(find.text('Show less'), findsOneWidget);

      await tester.ensureVisible(find.text('Show less'));
      await tester.tap(find.text('Show less'));
      await tester.pump();

      expect(find.text('Show more'), findsOneWidget);
    });

    testWidgets('shows placeholder icon when cover is absent', (tester) async {
      final container = ProviderContainer(
        overrides: [
          bookDetailViewModelProvider('min-1').overrideWith(
            () => FakeDetailVM(data: BookDetailState(book: _minimalBook())),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container, bookId: 'min-1'));
      await tester.pump();

      expect(find.byIcon(Icons.menu_book), findsOneWidget);
    });
  });
}
