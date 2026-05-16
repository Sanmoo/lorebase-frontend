import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/movies/data/models/movie_model.dart';
import 'package:lorebase/features/movies/pages/movie_detail_page.dart';
import 'package:lorebase/features/movies/viewmodels/movie_detail_state.dart';
import 'package:lorebase/features/movies/viewmodels/movie_detail_viewmodel.dart';
import 'package:lorebase/l10n/strings.g.dart';

class FakeMovieDetailVM extends MovieDetailViewModel {
  final MovieDetailState data;

  FakeMovieDetailVM(this.data);

  @override
  Future<MovieDetailState> build(int tmdbId) async => data;
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

class _LoadingMovieDetailVM extends MovieDetailViewModel {
  @override
  Future<MovieDetailState> build(int tmdbId) async {
    await Completer<Never>().future;
    throw UnimplementedError();
  }
}

class _ErrorMovieDetailVM extends MovieDetailViewModel {
  @override
  Future<MovieDetailState> build(int tmdbId) async {
    throw Exception('Test error message');
  }
}

MovieModel _testMovie() => const MovieModel(
      tmdbId: 7,
      title: 'Se7en',
      overview: 'A test overview',
      releaseDate: '1995-09-22',
      runtimeMinutes: 127,
      genres: ['Thriller'],
    );

Widget _wrap(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: TranslationProvider(
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/movies/7',
          routes: [
            GoRoute(
              path: '/movies/:tmdbId',
              builder: (_, state) => MovieDetailPage(
                  tmdbId: int.parse(state.pathParameters['tmdbId']!)),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  group('MovieDetailPage', () {
    testWidgets('renders Add to List and movie metadata', (tester) async {
      final detail = MovieDetailState(movie: _testMovie(), tracking: null);
      final container = ProviderContainer(overrides: [
        movieDetailViewModelProvider(7)
            .overrideWith(() => FakeMovieDetailVM(detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Se7en'), findsWidgets);
      expect(find.text('Release Date'), findsOneWidget);
      expect(find.text('1995-09-22'), findsOneWidget);
      expect(find.text('Runtime'), findsOneWidget);
      expect(find.text('127 min'), findsOneWidget);
      expect(find.text('Add to List'), findsOneWidget);
    });

    testWidgets('loading state shows LoadingWidget', (tester) async {
      final container = ProviderContainer(overrides: [
        movieDetailViewModelProvider(7)
            .overrideWith(() => _LoadingMovieDetailVM()),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Loading movie details...'), findsOneWidget);
    });

    testWidgets('error state shows error message and retry', (tester) async {
      final container = ProviderContainer(overrides: [
        movieDetailViewModelProvider(7)
            .overrideWith(() => _ErrorMovieDetailVM()),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Exception: Test error message'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('overview section renders', (tester) async {
      final detail = MovieDetailState(movie: _testMovie(), tracking: null);
      final container = ProviderContainer(overrides: [
        movieDetailViewModelProvider(7)
            .overrideWith(() => FakeMovieDetailVM(detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('A test overview'), findsOneWidget);
    });

    testWidgets('overview with null overview shows no description',
        (tester) async {
      final movie = _testMovie().copyWith(overview: null);
      final detail = MovieDetailState(movie: movie, tracking: null);
      final container = ProviderContainer(overrides: [
        movieDetailViewModelProvider(7)
            .overrideWith(() => FakeMovieDetailVM(detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No description available.'), findsOneWidget);
    });

    testWidgets('backdrop OverflowBox is wrapped in ClipRRect', (tester) async {
      final movie = _testMovie().copyWith(
        backdropPath: '/test-backdrop.jpg',
      );
      final detail = MovieDetailState(movie: movie, tracking: null);
      final container = ProviderContainer(overrides: [
        movieDetailViewModelProvider(7)
            .overrideWith(() => FakeMovieDetailVM(detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the backdrop ClipRect wrapper is present (key: backdrop_clip)
      expect(find.byKey(const ValueKey('backdrop_clip')), findsOneWidget);
    });

    testWidgets('overview with empty overview shows no description',
        (tester) async {
      final movie = _testMovie().copyWith(overview: '');
      final detail = MovieDetailState(movie: movie, tracking: null);
      final container = ProviderContainer(overrides: [
        movieDetailViewModelProvider(7)
            .overrideWith(() => FakeMovieDetailVM(detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No description available.'), findsOneWidget);
    });
  });
}
