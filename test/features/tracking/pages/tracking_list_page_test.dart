import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/tracking/pages/tracking_list_page.dart';
import 'package:lorebase/features/tracking/viewmodels/tracking_list_viewmodel.dart';
import 'package:lorebase/features/tracking/data/models/tracked_series_model.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';

final now = DateTime.now();

TrackedSeriesModel _tracking(String id, String status) => TrackedSeriesModel(
      trackingId: id,
      userId: 'user-1',
      seriesId: '123',
      status: status,
      addedAt: now,
      lastUpdated: now,
    );

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
  );
}

void main() {
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
  });
}
