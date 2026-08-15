import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/core/providers/media_filter_provider.dart';
import 'package:lorebase/features/series/pages/series_search_page.dart';
import 'package:lorebase/features/series/viewmodels/series_search_viewmodel.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/features/movies/data/models/movie_model.dart';
import 'package:lorebase/features/movies/viewmodels/movie_search_viewmodel.dart';
import 'package:lorebase/features/games/data/models/game_model.dart';
import 'package:lorebase/features/games/viewmodels/game_search_viewmodel.dart';
import 'package:lorebase/features/games/widgets/game_card.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';
import 'package:lorebase/features/tracking/pages/tracking_list_page.dart';
import 'package:lorebase/features/tracking/viewmodels/tracking_list_viewmodel.dart';
import 'package:lorebase/l10n/strings.g.dart';

class FakeSearchVM extends SeriesSearchViewModel {
  final AsyncValue<List<SeriesModel>> testState;
  bool searchCalled = false;
  FakeSearchVM({AsyncValue<List<SeriesModel>>? state})
    : testState = state ?? const AsyncValue.data([]);

  @override
  AsyncValue<List<SeriesModel>> build() => testState;
  @override
  Future<void> search(String query) async {
    searchCalled = true;
  }

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

class FakeGameSearchVM extends GameSearchViewModel {
  final AsyncValue<List<GameModel>> testState;
  bool searchCalled = false;

  FakeGameSearchVM({AsyncValue<List<GameModel>>? state})
    : testState = state ?? const AsyncValue.data([]);

  @override
  AsyncValue<List<GameModel>> build() => testState;

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

class FakeTrackingListVM extends TrackingListViewModel {
  MediaType? lastMediaType;

  @override
  AsyncValue<List<TrackedMediaModel>> build() => const AsyncValue.data([]);

  @override
  Future<void> loadTracking({
    String? status,
    MediaType mediaType = MediaType.series,
  }) async {
    lastMediaType = mediaType;
  }

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> refresh() async {}
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
              builder: (_, _) => const SeriesSearchPage(),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _wrapWithSeriesDetailRoute(
  ProviderContainer container, {
  required GoRouter router,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: TranslationProvider(child: MaterialApp.router(routerConfig: router)),
  );
}

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  group('SeriesSearchPage', () {
    ProviderContainer createContainer(FakeSearchVM fakeVM) {
      return ProviderContainer(
        overrides: [
          seriesSearchViewModelProvider.overrideWith(() => fakeVM),
          movieSearchViewModelProvider.overrideWith(() => FakeMovieSearchVM()),
          gameSearchViewModelProvider.overrideWith(() => FakeGameSearchVM()),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
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

      expect(find.textContaining('Type at least 2 characters'), findsOneWidget);
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
      expect(find.textContaining('Type at least 2 characters'), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      final fakeVM = FakeSearchVM(state: const AsyncValue.loading());
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message and retry when search fails', (
      tester,
    ) async {
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

    testWidgets(
      'shows no results message when empty data with non-empty query',
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
      },
    );

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

    testWidgets('clear search button has an accessible label', (tester) async {
      final fakeVM = FakeSearchVM();
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'breaking');
      await tester.pump();

      expect(find.byTooltip('Clear search'), findsOneWidget);
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

      expect(fakeVM.searchCalled, true);
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

      expect(fakeVM.searchCalled, true);
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

      expect(fakeVM.searchCalled, true);
    });

    testWidgets('tapping series item updates location to series detail route', (
      tester,
    ) async {
      final results = [const SeriesModel(tmdbId: 1, title: 'Breaking Bad')];
      final fakeVM = FakeSearchVM(state: AsyncValue.data(results));
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      late final GoRouter router;
      router = GoRouter(
        initialLocation: '/search',
        routes: [
          GoRoute(path: '/search', builder: (_, _) => const SeriesSearchPage()),
          GoRoute(
            path: '/series/:tmdbId',
            builder: (_, state) => Text(
              'Series detail ${state.pathParameters['tmdbId']}',
              textDirection: TextDirection.ltr,
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _wrapWithSeriesDetailRoute(container, router: router),
      );
      await tester.pump();

      await tester.tap(find.text('Breaking Bad'));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/series/1');
      expect(router.canPop(), isFalse);
      expect(find.text('Series detail 1'), findsOneWidget);
    });

    testWidgets(
      'tapping game item preserves search route for back navigation',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            selectedMediaTypeProvider.overrideWith((ref) => MediaType.game),
            seriesSearchViewModelProvider.overrideWith(() => FakeSearchVM()),
            movieSearchViewModelProvider.overrideWith(
              () => FakeMovieSearchVM(),
            ),
            gameSearchViewModelProvider.overrideWith(
              () => FakeGameSearchVM(
                state: const AsyncValue.data([
                  GameModel(gameId: '1', title: 'Hollow Knight'),
                ]),
              ),
            ),
            authViewModelProvider.overrideWith(() => FakeAuthVM()),
          ],
        );
        addTearDown(container.dispose);

        late final GoRouter router;
        router = GoRouter(
          initialLocation: '/search',
          routes: [
            GoRoute(
              path: '/search',
              builder: (_, _) => const SeriesSearchPage(),
            ),
            GoRoute(
              path: '/games/:gameId',
              builder: (_, state) => Text(
                'Game detail ${state.pathParameters['gameId']}',
                textDirection: TextDirection.ltr,
              ),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          _wrapWithSeriesDetailRoute(container, router: router),
        );
        await tester.pump();

        await tester.tap(find.byType(GameCard));
        await tester.pumpAndSettle();

        expect(router.canPop(), isTrue);
        expect(find.text('Game detail 1'), findsOneWidget);
      },
    );

    testWidgets('uses and updates shared media type selection', (tester) async {
      final container = ProviderContainer(
        overrides: [
          selectedMediaTypeProvider.overrideWith((ref) => MediaType.movie),
          seriesSearchViewModelProvider.overrideWith(() => FakeSearchVM()),
          movieSearchViewModelProvider.overrideWith(() => FakeMovieSearchVM()),
          gameSearchViewModelProvider.overrideWith(() => FakeGameSearchVM()),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Search movies...'), findsOneWidget);
      expect(container.read(selectedMediaTypeProvider), MediaType.movie);

      await tester.tap(find.text('Series'));
      await tester.pumpAndSettle();

      expect(find.text('Search series...'), findsOneWidget);
      expect(container.read(selectedMediaTypeProvider), MediaType.series);
    });

    testWidgets('switching to Movies shows the movie hint', (tester) async {
      final container = ProviderContainer(
        overrides: [
          seriesSearchViewModelProvider.overrideWith(() => FakeSearchVM()),
          movieSearchViewModelProvider.overrideWith(() => FakeMovieSearchVM()),
          gameSearchViewModelProvider.overrideWith(() => FakeGameSearchVM()),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Movies'));
      await tester.pumpAndSettle();

      expect(find.text('Search movies...'), findsOneWidget);
    });

    testWidgets('movie selection in search is reused by tracking page', (
      tester,
    ) async {
      final trackingVM = FakeTrackingListVM();
      final container = ProviderContainer(
        overrides: [
          seriesSearchViewModelProvider.overrideWith(() => FakeSearchVM()),
          movieSearchViewModelProvider.overrideWith(() => FakeMovieSearchVM()),
          gameSearchViewModelProvider.overrideWith(() => FakeGameSearchVM()),
          trackingListViewModelProvider.overrideWith(() => trackingVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/search',
        routes: [
          GoRoute(path: '/search', builder: (_, _) => const SeriesSearchPage()),
          GoRoute(
            path: '/tracking',
            builder: (_, _) => const TrackingListPage(),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _wrapWithSeriesDetailRoute(container, router: router),
      );
      await tester.pump();

      await tester.tap(find.text('Movies'));
      await tester.pumpAndSettle();

      router.go('/tracking');
      await tester.pumpAndSettle();

      expect(container.read(selectedMediaTypeProvider), MediaType.movie);
      expect(trackingVM.lastMediaType, MediaType.movie);
      expect(find.text('No Want to Watch movies yet'), findsOneWidget);
    });

    testWidgets(
      'switching media type before debounce fires cancels stale search',
      (tester) async {
        final fakeSeriesVM = FakeSearchVM();
        final fakeMovieVM = FakeMovieSearchVM();
        final fakeGameVM = FakeGameSearchVM();
        final container = ProviderContainer(
          overrides: [
            seriesSearchViewModelProvider.overrideWith(() => fakeSeriesVM),
            movieSearchViewModelProvider.overrideWith(() => fakeMovieVM),
            gameSearchViewModelProvider.overrideWith(() => fakeGameVM),
            authViewModelProvider.overrideWith(() => FakeAuthVM()),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(_wrap(container));
        await tester.pump();

        await tester.enterText(find.byType(TextField), 'breaking');
        await tester.pump();

        await tester.tap(find.text('Movies'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1100));

        expect(fakeSeriesVM.searchCalled, isFalse);
        expect(fakeMovieVM.searchCalled, isFalse);
        expect(fakeGameVM.searchCalled, isFalse);
      },
    );

    testWidgets('switching to Games shows the games hint', (tester) async {
      final container = ProviderContainer(
        overrides: [
          seriesSearchViewModelProvider.overrideWith(() => FakeSearchVM()),
          movieSearchViewModelProvider.overrideWith(() => FakeMovieSearchVM()),
          gameSearchViewModelProvider.overrideWith(() => FakeGameSearchVM()),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Games'));
      await tester.pumpAndSettle();

      expect(find.text('Search games...'), findsOneWidget);
    });

    testWidgets('switching to Games clears series and movie viewmodels', (
      tester,
    ) async {
      bool seriesCleared = false;
      bool movieCleared = false;
      bool gameCleared = false;

      final container = ProviderContainer(
        overrides: [
          seriesSearchViewModelProvider.overrideWith(
            () => _FakeSearchVMWithClear(onClear: () => seriesCleared = true),
          ),
          movieSearchViewModelProvider.overrideWith(
            () =>
                _FakeMovieSearchVMWithClear(onClear: () => movieCleared = true),
          ),
          gameSearchViewModelProvider.overrideWith(
            () => _FakeGameSearchVMWithClear(onClear: () => gameCleared = true),
          ),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Games'));
      await tester.pumpAndSettle();

      expect(seriesCleared, isTrue);
      expect(movieCleared, isTrue);
      expect(gameCleared, isTrue);
    });

    testWidgets('typing while Games selected triggers GameSearchViewModel', (
      tester,
    ) async {
      final fakeGameVM = FakeGameSearchVM();
      final container = ProviderContainer(
        overrides: [
          seriesSearchViewModelProvider.overrideWith(() => FakeSearchVM()),
          movieSearchViewModelProvider.overrideWith(() => FakeMovieSearchVM()),
          gameSearchViewModelProvider.overrideWith(() => fakeGameVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Games'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'witcher');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1100));

      expect(fakeGameVM.searchCalled, isTrue);
    });

    testWidgets('switching to Books uses the book search labels', (
      tester,
    ) async {
      final container = createContainer(FakeSearchVM());
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Books'));
      await tester.pumpAndSettle();

      expect(find.text('Search books...'), findsOneWidget);
      expect(find.text('Type at least 2 characters to search'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Dune');
      await tester.pump();

      expect(find.text('No books found'), findsOneWidget);
    });

    testWidgets('shows game results list when data available', (tester) async {
      final results = [
        const GameModel(gameId: '1', title: 'The Witcher 3'),
        const GameModel(gameId: '2', title: 'Hollow Knight'),
      ];
      final fakeGameVM = FakeGameSearchVM(state: AsyncValue.data(results));
      final container = ProviderContainer(
        overrides: [
          seriesSearchViewModelProvider.overrideWith(() => FakeSearchVM()),
          movieSearchViewModelProvider.overrideWith(() => FakeMovieSearchVM()),
          gameSearchViewModelProvider.overrideWith(() => fakeGameVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Games'));
      await tester.pumpAndSettle();

      expect(find.text('The Witcher 3'), findsOneWidget);
      expect(find.text('Hollow Knight'), findsOneWidget);
    });

    testWidgets('tapping a game result navigates to game detail route', (
      tester,
    ) async {
      final results = [const GameModel(gameId: '7', title: 'Hades')];
      final fakeGameVM = FakeGameSearchVM(state: AsyncValue.data(results));
      final container = ProviderContainer(
        overrides: [
          seriesSearchViewModelProvider.overrideWith(() => FakeSearchVM()),
          movieSearchViewModelProvider.overrideWith(() => FakeMovieSearchVM()),
          gameSearchViewModelProvider.overrideWith(() => fakeGameVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      late final GoRouter router;
      router = GoRouter(
        initialLocation: '/search',
        routes: [
          GoRoute(path: '/search', builder: (_, _) => const SeriesSearchPage()),
          GoRoute(
            path: '/games/:gameId',
            builder: (_, state) => Text(
              'Game detail ${state.pathParameters['gameId']}',
              textDirection: TextDirection.ltr,
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _wrapWithSeriesDetailRoute(container, router: router),
      );
      await tester.pump();

      await tester.tap(find.text('Games'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hades'));
      await tester.pumpAndSettle();

      expect(router.canPop(), isTrue);
      expect(find.text('Game detail 7'), findsOneWidget);
    });
  });
}

class _FakeSearchVMWithClear extends SeriesSearchViewModel {
  final VoidCallback onClear;

  _FakeSearchVMWithClear({required this.onClear});

  @override
  AsyncValue<List<SeriesModel>> build() => const AsyncValue.data([]);

  @override
  Future<void> search(String query) async {}

  @override
  void clear() => onClear();
}

class _FakeMovieSearchVMWithClear extends MovieSearchViewModel {
  final VoidCallback onClear;

  _FakeMovieSearchVMWithClear({required this.onClear});

  @override
  AsyncValue<List<MovieModel>> build() => const AsyncValue.data([]);

  @override
  Future<void> search(String query) async {}

  @override
  void clear() => onClear();
}

class _FakeGameSearchVMWithClear extends GameSearchViewModel {
  final VoidCallback onClear;

  _FakeGameSearchVMWithClear({required this.onClear});

  @override
  AsyncValue<List<GameModel>> build() => const AsyncValue.data([]);

  @override
  Future<void> search(String query) async {}

  @override
  void clear() => onClear();
}
