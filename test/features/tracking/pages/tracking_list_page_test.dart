import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorebase/core/providers/media_filter_provider.dart';
import 'package:lorebase/features/tracking/widgets/rating_stars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/tracking/pages/tracking_list_page.dart';
import 'package:lorebase/features/tracking/viewmodels/tracking_list_state.dart';
import 'package:lorebase/features/tracking/viewmodels/tracking_list_viewmodel.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_summary_model.dart';
import 'package:lorebase/features/tracking/data/models/tracking_page_model.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/l10n/strings.g.dart';

final now = DateTime.now();

TrackedMediaModel _tracking(
  String id,
  String status, {
  TrackedMediaSummaryModel? media,
  int? rating,
}) => TrackedMediaModel(
  trackingId: id,
  userId: 'user-1',
  mediaType: MediaType.series,
  mediaId: '123',
  status: status,
  rating: rating,
  media: media,
  addedAt: now,
  lastUpdated: now,
);

TrackedMediaSummaryModel _media(int id) => TrackedMediaSummaryModel(
  mediaId: id.toString(),
  title: 'Show $id',
  mediaType: MediaType.series,
);

TrackedMediaModel _gameTracking(
  String id,
  String status, {
  TrackedMediaSummaryModel? media,
}) => TrackedMediaModel(
  trackingId: id,
  userId: 'user-1',
  mediaType: MediaType.game,
  mediaId: '456',
  status: status,
  media: media,
  addedAt: now,
  lastUpdated: now,
);

TrackedMediaSummaryModel _gameMedia(int id) => TrackedMediaSummaryModel(
  mediaId: id.toString(),
  title: 'Game $id',
  mediaType: MediaType.game,
);

class FakeTrackingListVM extends TrackingListViewModel {
  final AsyncValue<TrackingListState> testState;
  int loadTrackingCallCount = 0;
  int loadMoreCallCount = 0;
  int refreshCallCount = 0;
  MediaType? lastMediaType;
  String? lastStatus;
  bool shouldThrowOnLoadMore = false;
  FakeTrackingListVM({AsyncValue<TrackingListState>? state})
    : testState = state ?? const AsyncValue.data(TrackingListState());

  @override
  AsyncValue<TrackingListState> build() => testState;
  @override
  Future<void> loadTracking({
    String? status,
    MediaType mediaType = MediaType.series,
  }) async {
    loadTrackingCallCount++;
    lastMediaType = mediaType;
    lastStatus = status;
  }

  @override
  Future<void> loadMore() async {
    loadMoreCallCount++;
    final current = state.value;
    if (current == null) return;
    if (shouldThrowOnLoadMore) {
      state = AsyncValue.data(
        current.copyWith(
          isLoadingMore: false,
          loadMoreError: 'Failed to load more',
        ),
      );
      return;
    }
    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
  }

  @override
  Future<void> refresh() async {
    refreshCallCount++;
  }
}

TrackingListState _listState(
  List<TrackedMediaModel> items, {
  String? nextCursor,
  bool isLoadingMore = false,
  String? loadMoreError,
}) => TrackingListState(
  page: TrackingPage(items: items, nextCursor: nextCursor),
  isLoadingMore: isLoadingMore,
  loadMoreError: loadMoreError,
);

AsyncValue<TrackingListState> _data(
  List<TrackedMediaModel> items, {
  String? nextCursor,
  bool isLoadingMore = false,
  String? loadMoreError,
}) => AsyncValue.data(
  _listState(
    items,
    nextCursor: nextCursor,
    isLoadingMore: isLoadingMore,
    loadMoreError: loadMoreError,
  ),
);

class FakeAuthVM extends AuthViewModel {
  @override
  AuthState build() => const AuthState.authenticated('user-1');
  @override
  void setAuthenticated(String userId) {}
  @override
  void setUnauthenticated() {}
  @override
  Future<void> signOut() async {}
}

Widget _wrap(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: TranslationProvider(
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/tracking',
          routes: [
            GoRoute(
              path: '/tracking',
              builder: (_, _) => const TrackingListPage(),
            ),
            GoRoute(
              path: '/series/:tmdbId',
              builder: (context, _) => Scaffold(
                body: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Back from detail'),
                ),
              ),
            ),
            GoRoute(
              path: '/games/:gameId',
              builder: (context, _) => Scaffold(
                body: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Back from game'),
                ),
              ),
            ),
            GoRoute(
              path: '/books/:bookId',
              builder: (context, _) => Scaffold(
                body: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Back from book'),
                ),
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

  group('TrackingListPage', () {
    ProviderContainer createContainer(FakeTrackingListVM fakeVM) {
      return ProviderContainer(
        overrides: [
          trackingListViewModelProvider.overrideWith(() => fakeVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
    }

    testWidgets('renders 4 tabs', (tester) async {
      final container = createContainer(FakeTrackingListVM());
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Want to Watch'), findsOneWidget);
      expect(find.text('Watching'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Dropped'), findsOneWidget);
    });

    testWidgets('shows empty state when list is empty', (tester) async {
      final container = createContainer(FakeTrackingListVM());
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.byIcon(Icons.tv_off), findsOneWidget);
    });

    testWidgets('shows loading indicator', (tester) async {
      final fakeVM = FakeTrackingListVM(state: const AsyncValue.loading());
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error with retry', (tester) async {
      final fakeVM = FakeTrackingListVM(
        state: AsyncValue.error('Error!', StackTrace.current),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows error message text', (tester) async {
      final fakeVM = FakeTrackingListVM(
        state: AsyncValue.error('Failed to load', StackTrace.current),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Failed to load'), findsOneWidget);
    });

    testWidgets('shows correct empty state message per tab', (tester) async {
      final container = createContainer(FakeTrackingListVM());
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('No Want to Watch series yet'), findsOneWidget);
    });

    testWidgets('tab switching works', (tester) async {
      final container = createContainer(FakeTrackingListVM());
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Want to Watch'), findsOneWidget);

      await tester.tap(find.text('Watching'));
      await tester.pumpAndSettle();

      expect(find.text('No Watching series yet'), findsOneWidget);
    });

    testWidgets('renders series in grid when data available', (tester) async {
      final trackings = [
        _tracking('t1', 'WATCHING', media: _media(1)),
        _tracking('t2', 'WATCHING', media: _media(2)),
      ];
      final fakeVM = FakeTrackingListVM(state: _data(trackings));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Show 1'), findsOneWidget);
      expect(find.text('Show 2'), findsOneWidget);
    });

    testWidgets('shows tv icon when media is null', (tester) async {
      final trackings = [_tracking('t1', 'WATCHING', media: null)];
      final fakeVM = FakeTrackingListVM(state: _data(trackings));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.tv_off), findsOneWidget);
    });

    testWidgets('shows rating stars per item', (tester) async {
      final trackings = [
        _tracking('t1', 'WATCHING', media: _media(1), rating: 8),
      ];
      final fakeVM = FakeTrackingListVM(state: _data(trackings));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(RatingStars), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNWidgets(8));
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));
    });

    testWidgets('media with tmdbId 0 shows no navigation', (tester) async {
      const media = TrackedMediaSummaryModel(
        mediaId: '0',
        title: 'Test',
        mediaType: MediaType.series,
      );
      final trackings = [_tracking('t1', 'WATCHING', media: media)];
      final fakeVM = FakeTrackingListVM(state: _data(trackings));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('tracks state with media shows poster and title', (
      tester,
    ) async {
      const media = TrackedMediaSummaryModel(
        mediaId: '5',
        title: 'Test',
        mediaType: MediaType.series,
      );
      final trackings = [_tracking('t1', 'WANT_TO_WATCH', media: media)];
      final fakeVM = FakeTrackingListVM(state: _data(trackings));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('reloads current tab after returning from detail', (
      tester,
    ) async {
      const media = TrackedMediaSummaryModel(
        mediaId: '5',
        title: 'Test',
        mediaType: MediaType.series,
      );
      final fakeVM = FakeTrackingListVM(
        state: _data([_tracking('t1', 'WANT_TO_WATCH', media: media)]),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      expect(fakeVM.loadTrackingCallCount, 1);

      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Back from detail'));
      await tester.pumpAndSettle();

      expect(fakeVM.loadTrackingCallCount, 2);
    });

    testWidgets('loads initial tab with shared media type selection', (
      tester,
    ) async {
      final fakeVM = FakeTrackingListVM();
      final container = ProviderContainer(
        overrides: [
          selectedMediaTypeProvider.overrideWith((ref) => MediaType.movie),
          trackingListViewModelProvider.overrideWith(() => fakeVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(fakeVM.loadTrackingCallCount, 1);
      expect(fakeVM.lastMediaType, MediaType.movie);
      expect(find.text('No Want to Watch movies yet'), findsOneWidget);

      await tester.tap(find.text('Series'));
      await tester.pumpAndSettle();

      expect(container.read(selectedMediaTypeProvider), MediaType.series);
      expect(fakeVM.lastMediaType, MediaType.series);
    });

    testWidgets('switching to Movies shows movie empty state copy', (
      tester,
    ) async {
      final container = createContainer(FakeTrackingListVM());
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Movies'));
      await tester.pumpAndSettle();

      expect(find.text('No Want to Watch movies yet'), findsOneWidget);
    });

    testWidgets('switching to Games shows game empty state copy', (
      tester,
    ) async {
      final container = createContainer(FakeTrackingListVM());
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Games'));
      await tester.pumpAndSettle();

      expect(find.text('No Want to Play games yet'), findsOneWidget);
    });

    testWidgets('switching to Games sends game status to view model', (
      tester,
    ) async {
      final fakeVM = FakeTrackingListVM();
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      // Tab 0 em séries usa status de série (WANT_TO_WATCH).
      expect(fakeVM.lastStatus, 'WANT_TO_WATCH');

      await tester.tap(find.text('Games'));
      await tester.pumpAndSettle();

      expect(fakeVM.lastMediaType, MediaType.game);
      // Games usam status próprios — WANT_TO_WATCH seria rejeitado (400) pelo
      // backend e a aba Jogos nunca carregaria.
      expect(fakeVM.lastStatus, 'WANT_TO_PLAY');
      // Labels das tabs acompanham o tipo de mídia.
      expect(find.text('Want to Play'), findsOneWidget);
      expect(find.text('Want to Watch'), findsNothing);
    });

    testWidgets('switching to Books uses reading statuses and copy', (
      tester,
    ) async {
      final fakeVM = FakeTrackingListVM();
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Books'));
      await tester.pumpAndSettle();

      expect(fakeVM.lastMediaType, MediaType.book);
      expect(fakeVM.lastStatus, 'WANT_TO_READ');
      expect(find.text('Want to Read'), findsOneWidget);
      expect(find.text('Reading'), findsOneWidget);
      expect(find.text('Want to Watch'), findsNothing);
      expect(find.text('No Want to Read books yet'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book), findsOneWidget);

      await tester.tap(find.text('Reading'));
      await tester.pumpAndSettle();
      expect(fakeVM.lastStatus, 'READING');
    });

    testWidgets('book tracking item renders and navigates to /books/:id', (
      tester,
    ) async {
      const media = TrackedMediaSummaryModel(
        mediaId: 'book-1',
        title: 'Book 1',
        mediaType: MediaType.book,
      );
      final trackings = [
        TrackedMediaModel(
          trackingId: 't1',
          userId: 'user-1',
          mediaType: MediaType.book,
          mediaId: 'book-1',
          status: 'READING',
          media: media,
          addedAt: now,
          lastUpdated: now,
        ),
      ];
      final fakeVM = FakeTrackingListVM(state: _data(trackings));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Book data returned by the tracking interface renders on the grid.
      expect(find.text('Book 1'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book), findsNothing);

      await tester.tap(find.text('Book 1'));
      await tester.pumpAndSettle();

      expect(find.text('Back from book'), findsOneWidget);
    });

    testWidgets('game tracking item navigates to /games/:id', (tester) async {
      final trackings = [_gameTracking('t1', 'PLAYING', media: _gameMedia(1))];
      final fakeVM = FakeTrackingListVM(state: _data(trackings));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Game 1'), findsOneWidget);

      await tester.tap(find.text('Game 1'));
      await tester.pumpAndSettle();

      expect(find.text('Back from game'), findsOneWidget);
    });

    testWidgets('loads the next page when the grid approaches the end', (
      tester,
    ) async {
      final trackings = List.generate(
        20,
        (i) => _tracking('t$i', 'COMPLETED', media: _media(i)),
      );
      final fakeVM = FakeTrackingListVM(
        state: _data(trackings, nextCursor: 'cursor-page-2'),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      expect(fakeVM.loadMoreCallCount, 0);

      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -4000),
      );
      await tester.pump();
      await tester.pump();

      expect(fakeVM.loadMoreCallCount, 1);
    });

    testWidgets('does not load more when the list is exhausted', (tester) async {
      final trackings = List.generate(
        20,
        (i) => _tracking('t$i', 'COMPLETED', media: _media(i)),
      );
      final fakeVM = FakeTrackingListVM(
        state: _data(trackings),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -4000),
      );
      await tester.pumpAndSettle();

      expect(fakeVM.loadMoreCallCount, 0);
    });

    testWidgets('loads more when a short page does not fill the viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final trackings = List.generate(
        20,
        (i) => _tracking('t$i', 'COMPLETED', media: _media(i)),
      );
      final fakeVM = FakeTrackingListVM(
        state: _data(trackings, nextCursor: 'cursor-page-2'),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fakeVM.loadMoreCallCount, 1);
    });

    testWidgets('shows a footer indicator while loading more', (tester) async {
      final trackings = List.generate(
        20,
        (i) => _tracking('t$i', 'COMPLETED', media: _media(i)),
      );
      final fakeVM = FakeTrackingListVM(
        state: _data(
          trackings,
          nextCursor: 'cursor-page-2',
          isLoadingMore: true,
        ),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -4000),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows no footer indicator when the list is exhausted', (
      tester,
    ) async {
      final trackings = [_tracking('t1', 'COMPLETED', media: _media(1))];
      final fakeVM = FakeTrackingListVM(state: _data(trackings));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('load-more failure keeps items and retries from the footer', (
      tester,
    ) async {
      final trackings = List.generate(
        2,
        (i) => _tracking('t$i', 'COMPLETED', media: _media(i)),
      );
      final fakeVM = FakeTrackingListVM(
        state: _data(trackings, nextCursor: 'cursor-page-2'),
      )..shouldThrowOnLoadMore = true;
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -4000),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Show 0'), findsOneWidget);
      expect(find.text('Failed to load more'), findsOneWidget);

      fakeVM.shouldThrowOnLoadMore = false;
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump();

      expect(fakeVM.loadMoreCallCount, 2);
      expect(find.text('Failed to load more'), findsNothing);
    });
  });
}
