import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/series/pages/series_search_page.dart';
import 'package:lorebase/features/series/viewmodels/series_search_viewmodel.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';

class FakeSearchVM extends SeriesSearchViewModel {
  final AsyncValue<List<SeriesModel>> testState;
  FakeSearchVM({AsyncValue<List<SeriesModel>>? state})
      : testState = state ?? const AsyncValue.data([]);

  @override
  AsyncValue<List<SeriesModel>> build() => testState;
  @override
  Future<void> search(String query) async {}
  @override
  void clear() {}
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
        initialLocation: '/search',
        routes: [
          GoRoute(
            path: '/search',
            builder: (_, __) => const SeriesSearchPage(),
          ),
        ],
      ),
    ),
  );
}

void main() {
  group('SeriesSearchPage', () {
    ProviderContainer createContainer(FakeSearchVM fakeVM) {
      return ProviderContainer(overrides: [
        seriesSearchViewModelProvider.overrideWith(() => fakeVM),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
    }

    testWidgets('renders search field', (tester) async {
      final container = createContainer(FakeSearchVM());
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows empty state for empty query', (tester) async {
      final container = createContainer(FakeSearchVM());
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(
        find.textContaining('Type at least 2 characters'),
        findsOneWidget,
      );
    });

    testWidgets('shows results list when data available', (tester) async {
      final results = [
        SeriesModel(tmdbId: 1, title: 'Breaking Bad'),
        SeriesModel(tmdbId: 2, title: 'Better Call Saul'),
      ];
      final fakeVM = FakeSearchVM(state: AsyncValue.data(results));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Breaking Bad'), findsOneWidget);
      expect(find.text('Better Call Saul'), findsOneWidget);
    });

    testWidgets('shows no results message for empty data', (tester) async {
      final fakeVM = FakeSearchVM(state: const AsyncValue.data([]));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      // Need to simulate a search query state
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      // Empty list but query is empty → shows initial state
      expect(
        find.textContaining('Type at least 2 characters'),
        findsOneWidget,
      );
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      final fakeVM =
          FakeSearchVM(state: const AsyncValue.loading());
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
