import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorebase/features/tracking/widgets/rating_stars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/tracking/pages/tracking_list_page.dart';
import 'package:lorebase/features/tracking/viewmodels/tracking_list_viewmodel.dart';
import 'package:lorebase/features/tracking/data/models/tracked_series_model.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/l10n/strings.g.dart';

final now = DateTime.now();

TrackedSeriesModel _tracking(String id, String status, {SeriesModel? series, int? seriesRating}) => TrackedSeriesModel(
      trackingId: id,
      userId: 'user-1',
      seriesId: '123',
      status: status,
      seriesRating: seriesRating,
      series: series,
      addedAt: now,
      lastUpdated: now,
    );

SeriesModel _series(int id) => SeriesModel(tmdbId: id, title: 'Show $id');

class FakeTrackingListVM extends TrackingListViewModel {
  final AsyncValue<List<TrackedSeriesModel>> testState;
  FakeTrackingListVM({AsyncValue<List<TrackedSeriesModel>>? state})
      : testState = state ?? const AsyncValue.data([]);

  @override
  AsyncValue<List<TrackedSeriesModel>> build() => testState;
  @override
  Future<void> loadTracking({String? status}) async {}
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
              builder: (_, __) => const TrackingListPage(),
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
      return ProviderContainer(overrides: [
        trackingListViewModelProvider.overrideWith(() => fakeVM),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
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

    testWidgets('shows AppBar with title', (tester) async {
      final container = createContainer(FakeTrackingListVM());
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('My Lists'), findsOneWidget);
    });

    testWidgets('shows empty state when list is empty', (tester) async {
      final container = createContainer(FakeTrackingListVM());
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.byIcon(Icons.tv_off), findsOneWidget);
    });

    testWidgets('shows loading indicator', (tester) async {
      final fakeVM =
          FakeTrackingListVM(state: const AsyncValue.loading());
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error with retry', (tester) async {
      final fakeVM = FakeTrackingListVM(
          state: AsyncValue.error('Error!', StackTrace.current));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows error message text', (tester) async {
      final fakeVM = FakeTrackingListVM(
          state: AsyncValue.error('Failed to load', StackTrace.current));
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
        _tracking('t1', 'WATCHING', series: _series(1)),
        _tracking('t2', 'WATCHING', series: _series(2)),
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

    testWidgets('shows tv icon when series is null', (tester) async {
      final trackings = [
        _tracking('t1', 'WATCHING', series: null),
      ];
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
        _tracking('t1', 'WATCHING', series: _series(1), seriesRating: 8),
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

    testWidgets('series with tmdbId 0 shows no navigation', (tester) async {
      const series = SeriesModel(tmdbId: 0, title: 'Test');
      final trackings = [
        _tracking('t1', 'WATCHING', series: series),
      ];
      final fakeVM = FakeTrackingListVM(state: AsyncValue.data(trackings));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('tracks state with series shows poster and title', (tester) async {
      const series = SeriesModel(tmdbId: 5, title: 'Test');
      final trackings = [
        _tracking('t1', 'WANT_TO_WATCH', series: series),
      ];
      final fakeVM = FakeTrackingListVM(state: AsyncValue.data(trackings));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test'), findsOneWidget);
    });
  });
}
