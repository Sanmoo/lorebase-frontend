import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/dashboard/pages/dashboard_page.dart';
import 'package:lorebase/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_model.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_section_model.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_summary_model.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/l10n/strings.g.dart';

class FakeDashboardVM extends DashboardViewModel {
  final AsyncValue<DashboardModel> testState;

  FakeDashboardVM({required this.testState});

  @override
  AsyncValue<DashboardModel> build() => testState;

  @override
  Future<void> refresh() async {}

  @override
  Future<void> loadDashboard({MediaType mediaType = MediaType.series}) async {}
}

DashboardModel _emptyDashboard() => const DashboardModel(
      watching: DashboardSectionModel(),
      wantToWatch: DashboardSectionModel(),
      completed: DashboardSectionModel(),
      dropped: DashboardSectionModel(),
      stats: DashboardStatsModel(),
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
          initialLocation: '/dashboard',
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (_, __) => const DashboardPage(),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  group('DashboardPage', () {
    ProviderContainer createContainer(FakeDashboardVM fakeVM) {
      return ProviderContainer(overrides: [
        dashboardViewModelProvider.overrideWith(() => fakeVM),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
    }

    testWidgets('loading state shows LoadingWidget', (tester) async {
      final fakeVM = FakeDashboardVM(testState: const AsyncValue.loading());
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('error state shows AppErrorWidget', (tester) async {
      final fakeVM = FakeDashboardVM(
          testState: AsyncValue.error('Error!', StackTrace.current));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('empty data shows EmptyStateWidget', (tester) async {
      final fakeVM =
          FakeDashboardVM(testState: AsyncValue.data(_emptyDashboard()));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.textContaining('No series tracked'), findsOneWidget);
    });

    testWidgets('data shows stats cards', (tester) async {
      const dashboard = DashboardModel(
        watching: DashboardSectionModel(),
        wantToWatch: DashboardSectionModel(),
        completed: DashboardSectionModel(),
        dropped: DashboardSectionModel(),
        stats: DashboardStatsModel(
          watchingCount: 3,
          wantToWatchCount: 2,
          completedCount: 5,
          droppedCount: 1,
        ),
      );
      final fakeVM =
          FakeDashboardVM(testState: const AsyncValue.data(dashboard));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('sections render when items are present', (tester) async {
      const media = TrackedMediaSummaryModel(
        mediaId: '456',
        title: 'x',
        mediaType: MediaType.series,
        posterPath: 'http://example.com/p.jpg',
      );
      const dashboard = DashboardModel(
        watching: DashboardSectionModel(items: [media]),
        wantToWatch: DashboardSectionModel(),
        completed: DashboardSectionModel(),
        dropped: DashboardSectionModel(),
        stats: DashboardStatsModel(
          watchingCount: 1,
          wantToWatchCount: 0,
          completedCount: 0,
          droppedCount: 0,
        ),
      );
      final fakeVM =
          FakeDashboardVM(testState: const AsyncValue.data(dashboard));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Watching'), findsNWidgets(2));
      expect(find.text('Completed'), findsOneWidget);
      expect(find.textContaining('No series tracked'), findsNothing);
    });

    testWidgets('renders all four sections when items present', (tester) async {
      const media = TrackedMediaSummaryModel(
          mediaId: '1', title: 'Series', mediaType: MediaType.series);
      const dashboard = DashboardModel(
        watching: DashboardSectionModel(items: [media]),
        wantToWatch: DashboardSectionModel(items: [media]),
        completed: DashboardSectionModel(items: [media]),
        dropped: DashboardSectionModel(items: [media]),
        stats: DashboardStatsModel(
          watchingCount: 1,
          wantToWatchCount: 1,
          completedCount: 1,
          droppedCount: 1,
        ),
      );
      final fakeVM =
          FakeDashboardVM(testState: const AsyncValue.data(dashboard));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Stats cards are always visible
      expect(find.text('Watching'), findsAtLeast(1));
      expect(find.text('Want to Watch'), findsAtLeast(1));
      expect(find.text('Completed'), findsAtLeast(1));
      expect(find.text('Dropped'), findsAtLeast(1));
      expect(find.text('Series'), findsAtLeast(1));
    });

    testWidgets('section navigates to series detail', (tester) async {
      const media = TrackedMediaSummaryModel(
          mediaId: '0', title: 'No nav', mediaType: MediaType.series);
      const dashboard = DashboardModel(
        watching: DashboardSectionModel(items: [media]),
        wantToWatch: DashboardSectionModel(),
        completed: DashboardSectionModel(),
        dropped: DashboardSectionModel(),
        stats: DashboardStatsModel(watchingCount: 1),
      );
      final fakeVM =
          FakeDashboardVM(testState: const AsyncValue.data(dashboard));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No nav'), findsOneWidget);
      expect(find.text('Watching'), findsNWidgets(2));
    });

    testWidgets('dashboard with wantToWatch section renders', (tester) async {
      const media = TrackedMediaSummaryModel(
          mediaId: '2', title: 'Want', mediaType: MediaType.series);
      const dashboard = DashboardModel(
        watching: DashboardSectionModel(),
        wantToWatch: DashboardSectionModel(items: [media]),
        completed: DashboardSectionModel(),
        dropped: DashboardSectionModel(),
        stats: DashboardStatsModel(wantToWatchCount: 1),
      );
      final fakeVM =
          FakeDashboardVM(testState: const AsyncValue.data(dashboard));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Want'), findsOneWidget);
    });

    testWidgets('dashboard with completed section renders', (tester) async {
      const media = TrackedMediaSummaryModel(
          mediaId: '3', title: 'Done', mediaType: MediaType.series);
      const dashboard = DashboardModel(
        watching: DashboardSectionModel(),
        wantToWatch: DashboardSectionModel(),
        completed: DashboardSectionModel(items: [media]),
        dropped: DashboardSectionModel(),
        stats: DashboardStatsModel(completedCount: 1),
      );
      final fakeVM =
          FakeDashboardVM(testState: const AsyncValue.data(dashboard));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('dashboard with dropped section renders', (tester) async {
      const media = TrackedMediaSummaryModel(
          mediaId: '4', title: 'Dropped', mediaType: MediaType.series);
      const dashboard = DashboardModel(
        watching: DashboardSectionModel(),
        wantToWatch: DashboardSectionModel(),
        completed: DashboardSectionModel(),
        dropped: DashboardSectionModel(items: [media]),
        stats: DashboardStatsModel(droppedCount: 1),
      );
      final fakeVM =
          FakeDashboardVM(testState: const AsyncValue.data(dashboard));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Dropped'), findsAtLeast(1));
    });

    testWidgets('all sections with empty items shows empty state',
        (tester) async {
      final dashboard = _emptyDashboard();
      final fakeVM = FakeDashboardVM(testState: AsyncValue.data(dashboard));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.textContaining('No series tracked'), findsOneWidget);
    });

    testWidgets('sections render with mediaId', (tester) async {
      const media = TrackedMediaSummaryModel(
          mediaId: '0', title: 'No Nav', mediaType: MediaType.series);
      const dashboard = DashboardModel(
        watching: DashboardSectionModel(items: [media]),
        wantToWatch: DashboardSectionModel(items: [media]),
        completed: DashboardSectionModel(items: [media]),
        dropped: DashboardSectionModel(items: [media]),
        stats: DashboardStatsModel(
          watchingCount: 1,
          wantToWatchCount: 1,
          completedCount: 1,
          droppedCount: 1,
        ),
      );
      final fakeVM =
          FakeDashboardVM(testState: const AsyncValue.data(dashboard));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // All sections render but no navigation occurs (tmdbId is 0)
      expect(find.text('No Nav'), findsAtLeast(1));
    });

    testWidgets('retry button on error calls refresh', (tester) async {
      final fakeVM = FakeDashboardVM(
          testState: AsyncValue.error('Error!', StackTrace.current));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('tapping watching section series navigates', (tester) async {
      const media = TrackedMediaSummaryModel(
        mediaId: '456',
        title: 'Series A',
        mediaType: MediaType.series,
        posterPath: 'http://example.com/p.jpg',
      );
      const dashboard = DashboardModel(
        watching: DashboardSectionModel(items: [media]),
        wantToWatch: DashboardSectionModel(),
        completed: DashboardSectionModel(),
        dropped: DashboardSectionModel(),
        stats: DashboardStatsModel(watchingCount: 1),
      );
      final fakeVM =
          FakeDashboardVM(testState: const AsyncValue.data(dashboard));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Series A'));
      await tester.pump();

      expect(find.text('Series A'), findsOneWidget);
    });

    testWidgets('switching to Movies shows movie empty state copy',
        (tester) async {
      final fakeVM =
          FakeDashboardVM(testState: AsyncValue.data(_emptyDashboard()));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Movies'));
      await tester.pumpAndSettle();

      expect(find.textContaining('No movies tracked'), findsOneWidget);
    });
  });
}
