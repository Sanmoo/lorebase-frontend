import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorebase/core/providers/media_filter_provider.dart';
import 'package:lorebase/features/tracking/widgets/rating_stars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/tracking/pages/tracking_list_page.dart';
import 'package:lorebase/features/tracking/viewmodels/tracking_list_viewmodel.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_summary_model.dart';
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
  final AsyncValue<List<TrackedMediaModel>> testState;
  int loadTrackingCallCount = 0;
  MediaType? lastMediaType;
  FakeTrackingListVM({AsyncValue<List<TrackedMediaModel>>? state})
    : testState = state ?? const AsyncValue.data([]);

  @override
  AsyncValue<List<TrackedMediaModel>> build() => testState;
  @override
  Future<void> loadTracking({
    String? status,
    MediaType mediaType = MediaType.series,
  }) async {
    loadTrackingCallCount++;
    lastMediaType = mediaType;
  }

  @override
  Future<void> loadMore() async {}
  @override
  Future<void> refresh() async {}
}

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
      final fakeVM = FakeTrackingListVM(state: AsyncValue.data(trackings));
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
      final fakeVM = FakeTrackingListVM(state: AsyncValue.data(trackings));
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
      final fakeVM = FakeTrackingListVM(state: AsyncValue.data(trackings));
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
      final fakeVM = FakeTrackingListVM(state: AsyncValue.data(trackings));
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
      final fakeVM = FakeTrackingListVM(state: AsyncValue.data(trackings));
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
        state: AsyncValue.data([
          _tracking('t1', 'WANT_TO_WATCH', media: media),
        ]),
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

    testWidgets('game tracking item navigates to /games/:id', (tester) async {
      final trackings = [_gameTracking('t1', 'PLAYING', media: _gameMedia(1))];
      final fakeVM = FakeTrackingListVM(state: AsyncValue.data(trackings));
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
  });
}
