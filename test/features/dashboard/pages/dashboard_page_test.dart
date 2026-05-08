import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/dashboard/pages/dashboard_page.dart';
import 'package:lorebase/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_model.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_section_model.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';

class FakeDashboardVM extends DashboardViewModel {
  final AsyncValue<DashboardModel> testState;

  FakeDashboardVM({required this.testState});

  @override
  AsyncValue<DashboardModel> build() => testState;
}

DashboardModel _emptyDashboard() => DashboardModel(
      watching: const DashboardSectionModel(),
      wantToWatch: const DashboardSectionModel(),
      completed: const DashboardSectionModel(),
      dropped: const DashboardSectionModel(),
      stats: const DashboardStatsModel(),
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
  );
}

void main() {
  group('DashboardPage', () {
    ProviderContainer createContainer(FakeDashboardVM fakeVM) {
      return ProviderContainer(overrides: [
        dashboardViewModelProvider.overrideWith(() => fakeVM),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
    }

    testWidgets('loading state shows LoadingWidget', (tester) async {
      final fakeVM =
          FakeDashboardVM(testState: const AsyncValue.loading());
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('error state shows AppErrorWidget', (tester) async {
      final fakeVM =
          FakeDashboardVM(testState: AsyncValue.error('Error!', StackTrace.current));
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
      final dashboard = DashboardModel(
        watching: const DashboardSectionModel(),
        wantToWatch: const DashboardSectionModel(),
        completed: const DashboardSectionModel(),
        dropped: const DashboardSectionModel(),
        stats: const DashboardStatsModel(
          watchingCount: 3,
          wantToWatchCount: 2,
          completedCount: 5,
          droppedCount: 1,
        ),
      );
      final fakeVM = FakeDashboardVM(testState: AsyncValue.data(dashboard));
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
      final series = SeriesModel(
        tmdbId: 456,
        title: 'x',
        posterPath: 'http://example.com/p.jpg',
      );
      final dashboard = DashboardModel(
        watching: DashboardSectionModel(items: [series]),
        wantToWatch: const DashboardSectionModel(),
        completed: const DashboardSectionModel(),
        dropped: const DashboardSectionModel(),
        stats: const DashboardStatsModel(
          watchingCount: 1,
          wantToWatchCount: 0,
          completedCount: 0,
          droppedCount: 0,
        ),
      );
      final fakeVM = FakeDashboardVM(testState: AsyncValue.data(dashboard));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Watching'), findsNWidgets(2));
      expect(find.text('Completed'), findsOneWidget);
      expect(find.textContaining('No series tracked'), findsNothing);
    });
  });
}
