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
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';
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

TrackedMediaModel _trackedBook({String status = 'WANT_TO_READ'}) =>
    TrackedMediaModel(
      trackingId: 't1',
      userId: 'u1',
      mediaType: MediaType.book,
      mediaId: 'dune-1',
      status: status,
      rating: 8,
      review: 'A classic',
      addedAt: DateTime.now(),
      lastUpdated: DateTime.now(),
    );

class FakeDetailVM extends BookDetailViewModel {
  final BookDetailState data;
  bool failAddTracking = false;
  bool failUpdateTracking = false;
  bool failRemoveTracking = false;
  String? lastAddStatus;
  int? lastAddRating;
  String? lastAddReview;
  String? lastUpdateStatus;
  int? lastUpdateRating;
  String? lastUpdateReview;
  bool removeCalled = false;

  FakeDetailVM({required this.data});

  @override
  Future<BookDetailState> build(String bookId) async => data;

  @override
  Future<void> addTracking(
    String status, {
    int? rating,
    String? review,
  }) async {
    if (failAddTracking) throw Exception('Add failed');
    lastAddStatus = status;
    lastAddRating = rating;
    lastAddReview = review;
  }

  @override
  Future<void> updateTracking({
    String? status,
    int? rating,
    String? review,
  }) async {
    if (failUpdateTracking) throw Exception('Update failed');
    lastUpdateStatus = status;
    lastUpdateRating = rating;
    lastUpdateReview = review;
  }

  @override
  Future<void> removeTracking() async {
    if (failRemoveTracking) throw Exception('Remove failed');
    removeCalled = true;
  }
}

/// Returns the leading icon of the ListTile whose title is [label].
IconData? _sheetStatusIcon(WidgetTester tester, String label) {
  final tile = tester.widget<ListTile>(
    find
        .ancestor(of: find.text(label), matching: find.byType(ListTile))
        .first,
  );
  return (tile.leading as Icon).icon;
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

    testWidgets('renders Add to List button when not tracking', (tester) async {
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

      expect(find.text('Add to List'), findsOneWidget);
    });

    testWidgets(
      'tracking sheet opens with Want to Read preselected and all reading statuses',
      (tester) async {
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

        await tester.tap(find.text('Add to List'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Save Changes'), findsOneWidget);
        // Every reading status is offered.
        expect(find.text('Want to Read'), findsOneWidget);
        expect(find.text('Reading'), findsOneWidget);
        expect(find.text('Completed'), findsOneWidget);
        expect(find.text('Dropped'), findsOneWidget);
        // Want to Read is preselected.
        expect(_sheetStatusIcon(tester, 'Want to Read'), Icons.check_circle);
        expect(_sheetStatusIcon(tester, 'Reading'), Icons.circle_outlined);
        expect(_sheetStatusIcon(tester, 'Completed'), Icons.circle_outlined);
        expect(_sheetStatusIcon(tester, 'Dropped'), Icons.circle_outlined);
      },
    );

    testWidgets('choosing a reading status and saving creates the tracking', (
      tester,
    ) async {
      final fakeVM = FakeDetailVM(data: BookDetailState(book: _richBook()));
      final container = ProviderContainer(
        overrides: [
          bookDetailViewModelProvider('dune-1').overrideWith(() => fakeVM),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Add to List'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Reading'));
      await tester.pump();

      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'Great book!');
      await tester.ensureVisible(find.byIcon(Icons.star_border).first);
      await tester.tap(find.byIcon(Icons.star_border).first);
      await tester.pump();

      final saveButton = find.widgetWithText(FilledButton, 'Save Changes');
      await tester.ensureVisible(saveButton);
      await tester.pump();
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(fakeVM.lastAddStatus, 'READING');
      expect(fakeVM.lastAddRating, 1);
      expect(fakeVM.lastAddReview, 'Great book!');
      // The sheet closes on success.
      expect(find.text('Save Changes'), findsNothing);
    });

    testWidgets('save failure in create mode shows snackbar', (tester) async {
      final fakeVM = FakeDetailVM(data: BookDetailState(book: _richBook()))
        ..failAddTracking = true;
      final container = ProviderContainer(
        overrides: [
          bookDetailViewModelProvider('dune-1').overrideWith(() => fakeVM),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Add to List'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final saveButton = find.widgetWithText(FilledButton, 'Save Changes');
      await tester.ensureVisible(saveButton);
      await tester.pump();
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('Server error. Please try again later.'),
        findsOneWidget,
      );
      // The sheet stays open so the user can retry.
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('renders reading status chip when tracking', (tester) async {
      final container = ProviderContainer(
        overrides: [
          bookDetailViewModelProvider('dune-1').overrideWith(
            () => FakeDetailVM(
              data: BookDetailState(
                book: _richBook(),
                tracking: _trackedBook(),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Manage Tracking'), findsOneWidget);
      expect(find.text('Want to Read'), findsOneWidget);
    });

    testWidgets('bottom sheet shows edit mode with remove button', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          bookDetailViewModelProvider('dune-1').overrideWith(
            () => FakeDetailVM(
              data: BookDetailState(
                book: _richBook(),
                tracking: _trackedBook(),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Manage Tracking'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Manage Tracking'), findsWidgets);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Remove from List'), findsOneWidget);
    });

    testWidgets('changing the status and saving updates the tracking', (
      tester,
    ) async {
      final fakeVM = FakeDetailVM(
        data: BookDetailState(book: _richBook(), tracking: _trackedBook()),
      );
      final container = ProviderContainer(
        overrides: [
          bookDetailViewModelProvider('dune-1').overrideWith(() => fakeVM),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Manage Tracking'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Reading'));
      await tester.pump();

      final saveButton = find.widgetWithText(FilledButton, 'Save Changes');
      await tester.ensureVisible(saveButton);
      await tester.pump();
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(fakeVM.lastUpdateStatus, 'READING');
      // The sheet closes on success.
      expect(find.text('Save Changes'), findsNothing);
    });

    testWidgets('save failure in edit mode shows snackbar', (tester) async {
      final fakeVM = FakeDetailVM(
        data: BookDetailState(book: _richBook(), tracking: _trackedBook()),
      )..failUpdateTracking = true;
      final container = ProviderContainer(
        overrides: [
          bookDetailViewModelProvider('dune-1').overrideWith(() => fakeVM),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Manage Tracking'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final saveButton = find.widgetWithText(FilledButton, 'Save Changes');
      await tester.ensureVisible(saveButton);
      await tester.pump();
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('Server error. Please try again later.'),
        findsOneWidget,
      );
    });

    testWidgets('remove button triggers a confirmation dialog', (tester) async {
      final container = ProviderContainer(
        overrides: [
          bookDetailViewModelProvider('dune-1').overrideWith(
            () => FakeDetailVM(
              data: BookDetailState(
                book: _richBook(),
                tracking: _trackedBook(),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Manage Tracking'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.ensureVisible(find.text('Remove from List'));
      await tester.pump();
      await tester.tap(find.text('Remove from List'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Remove "Dune" from your list?'), findsOneWidget);
    });

    testWidgets('remove dialog cancel keeps the editor open', (tester) async {
      final fakeVM = FakeDetailVM(
        data: BookDetailState(book: _richBook(), tracking: _trackedBook()),
      );
      final container = ProviderContainer(
        overrides: [
          bookDetailViewModelProvider('dune-1').overrideWith(() => fakeVM),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Manage Tracking'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.ensureVisible(find.text('Remove from List'));
      await tester.pump();
      await tester.tap(find.text('Remove from List'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fakeVM.removeCalled, false);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('remove confirmation removes and closes the editor', (
      tester,
    ) async {
      final fakeVM = FakeDetailVM(
        data: BookDetailState(book: _richBook(), tracking: _trackedBook()),
      );
      final container = ProviderContainer(
        overrides: [
          bookDetailViewModelProvider('dune-1').overrideWith(() => fakeVM),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Manage Tracking'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.ensureVisible(find.text('Remove from List'));
      await tester.pump();
      await tester.tap(find.text('Remove from List'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Remove'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(fakeVM.removeCalled, true);
      expect(find.text('Save Changes'), findsNothing);
    });

    testWidgets('remove failure shows snackbar and keeps the editor open', (
      tester,
    ) async {
      final fakeVM = FakeDetailVM(
        data: BookDetailState(book: _richBook(), tracking: _trackedBook()),
      )..failRemoveTracking = true;
      final container = ProviderContainer(
        overrides: [
          bookDetailViewModelProvider('dune-1').overrideWith(() => fakeVM),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Manage Tracking'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.ensureVisible(find.text('Remove from List'));
      await tester.pump();
      await tester.tap(find.text('Remove from List'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Remove'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('Server error. Please try again later.'),
        findsOneWidget,
      );
      expect(find.text('Save Changes'), findsOneWidget);
    });
  });
}
