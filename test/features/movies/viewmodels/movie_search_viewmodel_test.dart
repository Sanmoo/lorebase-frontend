import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/movies/data/models/movie_model.dart';
import 'package:lorebase/features/movies/data/repositories/movie_repository.dart';
import 'package:lorebase/features/movies/viewmodels/movie_search_viewmodel.dart';

class FakeMovieRepo implements MovieRepository {
  List<MovieModel>? results;
  bool shouldThrow = false;
  CancelToken? lastCancelToken;

  @override
  Future<List<MovieModel>> searchMovies(
    String query, {
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    lastCancelToken = cancelToken;
    if (shouldThrow) {
      throw DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: ''),
      );
    }
    return results ?? [];
  }

  @override
  Future<MovieModel> getMovieById(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  group('MovieSearchViewModel', () {
    ProviderContainer createContainer(FakeMovieRepo repo) {
      return ProviderContainer(overrides: [
        movieRepositoryProvider.overrideWith((ref) => repo),
      ]);
    }

    test('build() returns empty list', () {
      final container = createContainer(FakeMovieRepo());
      addTearDown(container.dispose);

      final state = container.read(movieSearchViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value, isEmpty);
    });

    test('search() with empty query clears results', () async {
      final repo = FakeMovieRepo()
        ..results = [const MovieModel(tmdbId: 1, title: 'Test')];
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(movieSearchViewModelProvider.notifier);
      await notifier.search('test');
      expect(container.read(movieSearchViewModelProvider).value!.length, 1);

      await notifier.search('');
      expect(container.read(movieSearchViewModelProvider).value, isEmpty);
    });

    test('search() success returns results', () async {
      final results = [
        const MovieModel(tmdbId: 1, title: 'Inception'),
        const MovieModel(tmdbId: 2, title: 'Interstellar'),
      ];
      final repo = FakeMovieRepo()..results = results;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(movieSearchViewModelProvider.notifier)
          .search('incept');

      final state = container.read(movieSearchViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value!.length, 2);
      expect(state.value![0].title, 'Inception');
    });

    test('search() error sets AsyncValue.error', () async {
      final repo = FakeMovieRepo()..shouldThrow = true;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(movieSearchViewModelProvider.notifier)
          .search('test');

      final state = container.read(movieSearchViewModelProvider);
      expect(state.hasError, true);
    });

    test('clear() resets to empty list', () async {
      final repo = FakeMovieRepo()
        ..results = [const MovieModel(tmdbId: 1, title: 'Test')];
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(movieSearchViewModelProvider.notifier);
      await notifier.search('test');
      expect(container.read(movieSearchViewModelProvider).value!.length, 1);

      notifier.clear();
      expect(container.read(movieSearchViewModelProvider).value, isEmpty);
    });

    test('search() passes CancelToken to repository', () async {
      final repo = FakeMovieRepo();
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(movieSearchViewModelProvider.notifier)
          .search('test');

      expect(repo.lastCancelToken, isNotNull);
      expect(repo.lastCancelToken, isA<CancelToken>());
    });
  });
}
