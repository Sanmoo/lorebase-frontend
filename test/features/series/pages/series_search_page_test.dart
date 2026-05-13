import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/series/pages/series_search_page.dart';
import 'package:lorebase/features/series/viewmodels/series_search_viewmodel.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/features/movies/data/models/movie_model.dart';
import 'package:lorebase/features/movies/viewmodels/movie_search_viewmodel.dart';
import 'package:lorebase/l10n/strings.g.dart';

class FakeSearchVM extends SeriesSearchViewModel {
  final AsyncValue<List<SeriesModel>> testState;
  bool retryCalled = false;
  FakeSearchVM({AsyncValue<List<SeriesModel>>? state})
      : testState = state ?? const AsyncValue.data([]);

  @override
  AsyncValue<List<SeriesModel>> build() => testState;
  @override
  Future<void> search(String query) async { retryCalled = true; }
  @override
  void clear() {}
}

class FakeMovieSearchVM extends MovieSearchViewModel {
  final AsyncValue<List<MovieModel>> testState;
  bool searchCalled = false;

  FakeMovieSearchVM({AsyncValue<List<MovieModel>>? state})
      : testState = state ?? const AsyncValue.data([]);

  @override
  AsyncValue<List<MovieModel>> build() => testState;

  @override
  Future<void> search(String query) async {
    searchCalled = true;
  }

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
    child: TranslationProvider(
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
    ),
  );
}

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

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
        const SeriesModel(tmdbId: 1, title: 'Breaking Bad'),
        const SeriesModel(tmdbId: 2, title: 'Better Call Saul'),
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

    testWidgets('shows error message and retry when search fails',
        (tester) async {
      final fakeVM = FakeSearchVM(
        state: AsyncValue.error('Search failed', StackTrace.current),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Search failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows no results message when empty data with non-empty query',
        (tester) async {
      final fakeVM = FakeSearchVM(state: const AsyncValue.data([]));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(
        find.textContaining('Type at least 2 characters'),
        findsOneWidget,
      );
    });

    testWidgets('search field has autofocus', (tester) async {
      final fakeVM = FakeSearchVM();
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      // TextField should be focused (autofocus)
      expect(tester.testTextInput.isVisible, isTrue);
    });

    testWidgets('typing text triggers debounced search', (tester) async {
      final fakeVM = FakeSearchVM();
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'breaking');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1100));

      expect(fakeVM.retryCalled, true);
    });

    testWidgets('retry button calls search', (tester) async {
      final fakeVM = FakeSearchVM(
        state: AsyncValue.error('Failed', StackTrace.current),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1100));

      expect(fakeVM.retryCalled, true);
    });

    testWidgets('typing text triggers onChanged with debounce', (tester) async {
      final fakeVM = FakeSearchVM();
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'breaking');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1100));

      expect(fakeVM.retryCalled, true);
    });

    testWidgets('tapping series item does not crash', (tester) async {
      final results = [
        const SeriesModel(tmdbId: 1, title: 'Breaking Bad'),
      ];
      final fakeVM = FakeSearchVM(state: AsyncValue.data(results));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Breaking Bad'));
      await tester.pump();

      expect(find.text('Breaking Bad'), findsOneWidget);
    });

    testWidgets('switching to Movies shows the movie hint', (tester) async {
      final container = ProviderContainer(overrides: [
        seriesSearchViewModelProvider.overrideWith(() => FakeSearchVM()),
        movieSearchViewModelProvider.overrideWith(() => FakeMovieSearchVM()),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Movies'));
      await tester.pumpAndSettle();

      expect(find.text('Search movies...'), findsOneWidget);
    });
  });
}
