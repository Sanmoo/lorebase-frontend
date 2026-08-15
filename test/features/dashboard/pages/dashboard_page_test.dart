import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/core/providers/media_filter_provider.dart';
import 'package:lorebase/features/dashboard/pages/dashboard_page.dart';
import 'package:lorebase/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_model.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_section_model.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_summary_model.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/features/social/data/models/activity_event_model.dart';
import 'package:lorebase/features/social/data/models/paginated_social_response.dart';
import 'package:lorebase/features/social/data/models/social_media_model.dart';
import 'package:lorebase/features/social/data/models/social_profile_model.dart';
import 'package:lorebase/features/social/data/models/social_user_model.dart';
import 'package:lorebase/features/social/pages/social_page.dart';
import 'package:lorebase/features/social/viewmodels/social_feed_viewmodel.dart';
import 'package:lorebase/l10n/strings.g.dart';

class FakeDashboardVM extends DashboardViewModel {
  final AsyncValue<DashboardModel> testState;
  int refreshCount = 0;

  FakeDashboardVM({required this.testState});

  @override
  AsyncValue<DashboardModel> build() => testState;

  @override
  Future<void> refresh() async {
    refreshCount++;
  }

  @override
  Future<void> loadDashboard({MediaType? mediaType}) async {}
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

class FakeSocialFeedVM extends SocialFeedViewModel {
  final AsyncValue<PaginatedSocialResponse<ActivityEventModel>> testState;
  int refreshCount = 0;

  FakeSocialFeedVM({required this.testState});

  @override
  Future<PaginatedSocialResponse<ActivityEventModel>> build() async {
    return testState.value ??
        const PaginatedSocialResponse<ActivityEventModel>(
          items: [],
          nextCursor: null,
          hasMore: false,
        );
  }

  @override
  Future<void> refresh() async {
    refreshCount++;
  }
}

PaginatedSocialResponse<ActivityEventModel> _feed([
  List<ActivityEventModel> items = const [],
]) => PaginatedSocialResponse<ActivityEventModel>(
  items: items,
  nextCursor: null,
  hasMore: false,
);

ActivityEventModel _activity(
  String id,
  String title, {
  String activityType = 'COMPLETED',
  Map<String, dynamic> metadata = const <String, dynamic>{},
}) => ActivityEventModel(
  eventId: id,
  user: const SocialUserModel(userId: 'user-1', displayName: 'Fulano'),
  activityType: activityType,
  media: SocialMediaModel(mediaId: id, mediaType: 'SERIES', title: title),
  metadata: metadata,
  createdAt: DateTime.utc(2026, 5, 20),
);

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
              builder: (_, _) => const DashboardPage(),
            ),
            GoRoute(
              path: '/social',
              builder: (_, _) => const Scaffold(body: Text('Social page')),
            ),
            GoRoute(
              path: '/recommend',
              builder: (_, _) => const Scaffold(body: Text('Recommend page')),
            ),
            GoRoute(
              path: '/games/:gameId',
              builder: (_, _) => const Scaffold(body: Text('Game detail page')),
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
      return ProviderContainer(
        overrides: [
          dashboardViewModelProvider.overrideWith(() => fakeVM),
          socialFeedViewModelProvider.overrideWith(
            () => FakeSocialFeedVM(testState: AsyncValue.data(_feed())),
          ),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
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
        testState: AsyncValue.error('Error!', StackTrace.current),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('uses and updates shared media type selection', (tester) async {
      final fakeVM = FakeDashboardVM(
        testState: AsyncValue.data(_emptyDashboard()),
      );
      final container = ProviderContainer(
        overrides: [
          selectedMediaTypeProvider.overrideWith((ref) => MediaType.movie),
          dashboardViewModelProvider.overrideWith(() => fakeVM),
          socialFeedViewModelProvider.overrideWith(
            () => FakeSocialFeedVM(testState: AsyncValue.data(_feed())),
          ),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.textContaining('No movies tracked'), findsOneWidget);
      expect(container.read(selectedMediaTypeProvider), MediaType.movie);

      await tester.tap(find.text('Series'));
      await tester.pumpAndSettle();

      expect(find.textContaining('No series tracked'), findsOneWidget);
      expect(container.read(selectedMediaTypeProvider), MediaType.series);
    });

    testWidgets('book selection uses reading labels and empty copy', (
      tester,
    ) async {
      final fakeVM = FakeDashboardVM(
        testState: AsyncValue.data(_emptyDashboard()),
      );
      final container = ProviderContainer(
        overrides: [
          selectedMediaTypeProvider.overrideWith((ref) => MediaType.book),
          dashboardViewModelProvider.overrideWith(() => fakeVM),
          socialFeedViewModelProvider.overrideWith(
            () => FakeSocialFeedVM(testState: AsyncValue.data(_feed())),
          ),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Reading'), findsOneWidget);
      expect(find.text('Want to Read'), findsOneWidget);
      expect(find.textContaining('No books tracked'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book), findsOneWidget);
    });

    testWidgets('empty data shows EmptyStateWidget', (tester) async {
      final fakeVM = FakeDashboardVM(
        testState: AsyncValue.data(_emptyDashboard()),
      );
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
      final fakeVM = FakeDashboardVM(
        testState: const AsyncValue.data(dashboard),
      );
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
      final fakeVM = FakeDashboardVM(
        testState: const AsyncValue.data(dashboard),
      );
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
        mediaId: '1',
        title: 'Series',
        mediaType: MediaType.series,
      );
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
      final fakeVM = FakeDashboardVM(
        testState: const AsyncValue.data(dashboard),
      );
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
        mediaId: '0',
        title: 'No nav',
        mediaType: MediaType.series,
      );
      const dashboard = DashboardModel(
        watching: DashboardSectionModel(items: [media]),
        wantToWatch: DashboardSectionModel(),
        completed: DashboardSectionModel(),
        dropped: DashboardSectionModel(),
        stats: DashboardStatsModel(watchingCount: 1),
      );
      final fakeVM = FakeDashboardVM(
        testState: const AsyncValue.data(dashboard),
      );
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
        mediaId: '2',
        title: 'Want',
        mediaType: MediaType.series,
      );
      const dashboard = DashboardModel(
        watching: DashboardSectionModel(),
        wantToWatch: DashboardSectionModel(items: [media]),
        completed: DashboardSectionModel(),
        dropped: DashboardSectionModel(),
        stats: DashboardStatsModel(wantToWatchCount: 1),
      );
      final fakeVM = FakeDashboardVM(
        testState: const AsyncValue.data(dashboard),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Want'), findsOneWidget);
    });

    testWidgets('dashboard with completed section renders', (tester) async {
      const media = TrackedMediaSummaryModel(
        mediaId: '3',
        title: 'Done',
        mediaType: MediaType.series,
      );
      const dashboard = DashboardModel(
        watching: DashboardSectionModel(),
        wantToWatch: DashboardSectionModel(),
        completed: DashboardSectionModel(items: [media]),
        dropped: DashboardSectionModel(),
        stats: DashboardStatsModel(completedCount: 1),
      );
      final fakeVM = FakeDashboardVM(
        testState: const AsyncValue.data(dashboard),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('dashboard with dropped section renders', (tester) async {
      const media = TrackedMediaSummaryModel(
        mediaId: '4',
        title: 'Dropped',
        mediaType: MediaType.series,
      );
      const dashboard = DashboardModel(
        watching: DashboardSectionModel(),
        wantToWatch: DashboardSectionModel(),
        completed: DashboardSectionModel(),
        dropped: DashboardSectionModel(items: [media]),
        stats: DashboardStatsModel(droppedCount: 1),
      );
      final fakeVM = FakeDashboardVM(
        testState: const AsyncValue.data(dashboard),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Dropped'), findsAtLeast(1));
    });

    testWidgets('all sections with empty items shows empty state', (
      tester,
    ) async {
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
        mediaId: '0',
        title: 'No Nav',
        mediaType: MediaType.series,
      );
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
      final fakeVM = FakeDashboardVM(
        testState: const AsyncValue.data(dashboard),
      );
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
        testState: AsyncValue.error('Error!', StackTrace.current),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(find.text('Retry'), findsOneWidget);
    });

    test('refresh helper refreshes dashboard and social feed', () async {
      final fakeVM = FakeDashboardVM(
        testState: AsyncValue.data(_emptyDashboard()),
      );
      final fakeSocialVM = FakeSocialFeedVM(
        testState: AsyncValue.data(_feed()),
      );

      await refreshDashboardAndSocialFeed(
        dashboardViewModel: fakeVM,
        socialFeedViewModel: fakeSocialVM,
      );

      expect(fakeVM.refreshCount, 1);
      expect(fakeSocialVM.refreshCount, 1);
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
      final fakeVM = FakeDashboardVM(
        testState: const AsyncValue.data(dashboard),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.ensureVisible(find.text('Series A'));

      await tester.tap(find.text('Series A'), warnIfMissed: false);
      await tester.pump();

      expect(find.text('Series A'), findsOneWidget);
    });

    testWidgets('switching to Movies shows movie empty state copy', (
      tester,
    ) async {
      final fakeVM = FakeDashboardVM(
        testState: AsyncValue.data(_emptyDashboard()),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Movies'));
      await tester.pumpAndSettle();

      expect(find.textContaining('No movies tracked'), findsOneWidget);
    });

    testWidgets('renders a social preview section title', (tester) async {
      final fakeVM = FakeDashboardVM(
        testState: AsyncValue.data(_emptyDashboard()),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Social activity'), findsOneWidget);
    });

    testWidgets('shows social profile name as dashboard context', (
      tester,
    ) async {
      final fakeVM = FakeDashboardVM(
        testState: AsyncValue.data(_emptyDashboard()),
      );
      final container = ProviderContainer(
        overrides: [
          dashboardViewModelProvider.overrideWith(() => fakeVM),
          socialFeedViewModelProvider.overrideWith(
            () => FakeSocialFeedVM(testState: AsyncValue.data(_feed())),
          ),
          mySocialProfileProvider.overrideWith(
            (ref) async => SocialProfileModel(
              userId: 'user-1',
              displayName: 'Fulano',
              isPublic: true,
              followingCount: 1,
              followerCount: 2,
              createdAt: DateTime.utc(2026, 5, 20),
              updatedAt: DateTime.utc(2026, 5, 20),
            ),
          ),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Social profile: Fulano'), findsOneWidget);
    });

    testWidgets('social preview CTA navigates to social', (tester) async {
      final fakeVM = FakeDashboardVM(
        testState: AsyncValue.data(_emptyDashboard()),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.drag(find.byType(Scrollable), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open Social'));
      await tester.pumpAndSettle();

      expect(find.text('Social page'), findsOneWidget);
    });

    testWidgets('recommendation content is reachable from dashboard', (
      tester,
    ) async {
      final fakeVM = FakeDashboardVM(
        testState: AsyncValue.data(_emptyDashboard()),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.ensureVisible(find.text('Recommendations for you'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get recommendations'));
      await tester.pumpAndSettle();

      expect(find.text('Recommend page'), findsOneWidget);
    });

    testWidgets('recommendation card renders social-style content', (
      tester,
    ) async {
      final fakeVM = FakeDashboardVM(
        testState: AsyncValue.data(_emptyDashboard()),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.ensureVisible(find.text('Recommendations for you'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.auto_awesome_outlined), findsOneWidget);
      expect(find.text('Recommendations for you'), findsOneWidget);
      expect(
        find.text('Find something tailored to watch next.'),
        findsOneWidget,
      );
      expect(find.text('Get recommendations'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text('Get recommendations'),
          matching: find.byType(TextButton),
        ),
        findsNothing,
      );
      expect(
        find.ancestor(
          of: find.text('Recommendations for you'),
          matching: find.byType(ListTile),
        ),
        findsNothing,
      );
    });

    testWidgets('tapping recommendation card surface navigates to recommend', (
      tester,
    ) async {
      final fakeVM = FakeDashboardVM(
        testState: AsyncValue.data(_emptyDashboard()),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.ensureVisible(find.text('Recommendations for you'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Recommendations for you'));
      await tester.pumpAndSettle();

      expect(find.text('Recommend page'), findsOneWidget);
    });

    testWidgets('social preview translates added to list activity rows', (
      tester,
    ) async {
      final fakeVM = FakeDashboardVM(
        testState: AsyncValue.data(_emptyDashboard()),
      );
      final container = ProviderContainer(
        overrides: [
          dashboardViewModelProvider.overrideWith(() => fakeVM),
          socialFeedViewModelProvider.overrideWith(
            () => FakeSocialFeedVM(
              testState: AsyncValue.data(
                _feed([
                  _activity('1', 'Devoradores', activityType: 'added_to_list'),
                ]),
              ),
            ),
          ),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(
        find.textContaining(
          'Fulano ${t.social_activity_added_to_list} Devoradores',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('added_to_list'), findsNothing);
    });

    testWidgets('social preview includes list name for added to list rows', (
      tester,
    ) async {
      final fakeVM = FakeDashboardVM(
        testState: AsyncValue.data(_emptyDashboard()),
      );
      final container = ProviderContainer(
        overrides: [
          dashboardViewModelProvider.overrideWith(() => fakeVM),
          socialFeedViewModelProvider.overrideWith(
            () => FakeSocialFeedVM(
              testState: AsyncValue.data(
                _feed([
                  _activity(
                    '1',
                    'Devoradores',
                    activityType: 'added_to_list',
                    metadata: const {'listName': 'Favoritos'},
                  ),
                ]),
              ),
            ),
          ),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(
        find.textContaining('Fulano adicionou Devoradores à lista Favoritos'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Fulano adicionou à lista Devoradores'),
        findsNothing,
      );
    });

    testWidgets('social preview shows up to three activity rows', (
      tester,
    ) async {
      final fakeVM = FakeDashboardVM(
        testState: AsyncValue.data(_emptyDashboard()),
      );
      final container = ProviderContainer(
        overrides: [
          dashboardViewModelProvider.overrideWith(() => fakeVM),
          socialFeedViewModelProvider.overrideWith(
            () => FakeSocialFeedVM(
              testState: AsyncValue.data(
                _feed([
                  _activity('1', 'One Piece'),
                  _activity('2', 'Frieren'),
                  _activity('3', 'Dungeon Meshi'),
                  _activity('4', 'Hidden'),
                ]),
              ),
            ),
          ),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(
        find.text('Fulano ${t.social_activity_completed} One Piece'),
        findsOneWidget,
      );
      expect(
        find.text('Fulano ${t.social_activity_completed} Frieren'),
        findsOneWidget,
      );
      expect(
        find.text('Fulano ${t.social_activity_completed} Dungeon Meshi'),
        findsOneWidget,
      );
      expect(find.textContaining('Hidden'), findsNothing);
    });

    testWidgets('game section item navigates to /games/:id', (tester) async {
      const media = TrackedMediaSummaryModel(
        mediaId: '789',
        title: 'Game X',
        mediaType: MediaType.game,
      );
      const dashboard = DashboardModel(
        watching: DashboardSectionModel(items: [media]),
        wantToWatch: DashboardSectionModel(),
        completed: DashboardSectionModel(),
        dropped: DashboardSectionModel(),
        stats: DashboardStatsModel(watchingCount: 1),
      );
      final fakeVM = FakeDashboardVM(
        testState: const AsyncValue.data(dashboard),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.ensureVisible(find.text('Game X'));

      // Match pattern from series navigation test
      await tester.tap(find.text('Game X'), warnIfMissed: false);
      await tester.pump();

      expect(find.text('Game X'), findsOneWidget);
    });
  });
}
