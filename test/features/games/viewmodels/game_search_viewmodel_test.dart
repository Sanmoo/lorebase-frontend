import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/games/data/models/game_model.dart';
import 'package:lorebase/features/games/data/repositories/game_repository.dart';
import 'package:lorebase/features/games/viewmodels/game_search_viewmodel.dart';

class FakeGameRepo implements GameRepository {
  List<GameModel>? results;
  bool shouldThrow = false;
  bool shouldCancel = false;
  int searchCallCount = 0;
  String? lastQuery;
  CancelToken? lastCancelToken;

  @override
  Future<List<GameModel>> searchGames(
    String query, {
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    searchCallCount++;
    lastQuery = query;
    lastCancelToken = cancelToken;
    if (shouldCancel) {
      throw DioException(
        type: DioExceptionType.cancel,
        requestOptions: RequestOptions(path: ''),
      );
    }
    if (shouldThrow) {
      throw DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: ''),
      );
    }
    return results ?? [];
  }

  @override
  Future<GameModel> getGameById(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  group('GameSearchViewModel', () {
    ProviderContainer createContainer(FakeGameRepo repo) {
      return ProviderContainer(
        overrides: [gameRepositoryProvider.overrideWith((ref) => repo)],
      );
    }

    test('build() returns empty list', () {
      final container = createContainer(FakeGameRepo());
      addTearDown(container.dispose);

      final state = container.read(gameSearchViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value, isEmpty);
    });

    test('search() returns results', () async {
      final results = [
        const GameModel(gameId: '1', title: 'The Witcher 3'),
        const GameModel(gameId: '2', title: 'Hollow Knight'),
      ];
      final repo = FakeGameRepo()..results = results;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(gameSearchViewModelProvider.notifier)
          .search('witcher');

      final state = container.read(gameSearchViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value!.length, 2);
      expect(state.value![0].title, 'The Witcher 3');
      expect(repo.lastQuery, 'witcher');
    });

    test('search() cancels previous request', () async {
      final repo = FakeGameRepo()
        ..results = [const GameModel(gameId: '1', title: 'Later')];
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(gameSearchViewModelProvider.notifier);

      // Start a search that will never complete because we don't await it.
      final firstSearch = notifier.search('first');
      final firstToken = repo.lastCancelToken;
      expect(firstToken, isNotNull);
      expect(firstToken!.isCancelled, isFalse);

      // Start a second search; the first token should be cancelled.
      await notifier.search('second');
      expect(firstToken.isCancelled, isTrue);
      expect(repo.lastQuery, 'second');

      // Let the first search finish; its result should not overwrite the
      // second search's results because the request was cancelled.
      await firstSearch;
      final state = container.read(gameSearchViewModelProvider);
      expect(state.value!.length, 1);
      expect(state.value![0].title, 'Later');
    });

    test('search() handles empty query', () async {
      final repo = FakeGameRepo()
        ..results = [const GameModel(gameId: '1', title: 'Test')];
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(gameSearchViewModelProvider.notifier);
      await notifier.search('test');
      expect(container.read(gameSearchViewModelProvider).value!.length, 1);

      await notifier.search('');
      expect(container.read(gameSearchViewModelProvider).value, isEmpty);
      expect(repo.searchCallCount, 1);
    });

    test('search() handles whitespace-only query as empty', () async {
      final repo = FakeGameRepo()
        ..results = [const GameModel(gameId: '1', title: 'Test')];
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(gameSearchViewModelProvider.notifier);
      await notifier.search('   ');
      expect(container.read(gameSearchViewModelProvider).value, isEmpty);
      expect(repo.searchCallCount, 0);
    });

    test('search() error sets AsyncValue.error', () async {
      final repo = FakeGameRepo()..shouldThrow = true;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container.read(gameSearchViewModelProvider.notifier).search('test');

      final state = container.read(gameSearchViewModelProvider);
      expect(state.hasError, true);
    });

    test('search() ignores cancellation errors', () async {
      final repo = FakeGameRepo()..shouldCancel = true;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container.read(gameSearchViewModelProvider.notifier).search('test');

      final state = container.read(gameSearchViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value, isEmpty);
    });

    test('clear() cancels and resets', () async {
      final repo = FakeGameRepo()
        ..results = [const GameModel(gameId: '1', title: 'Test')];
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(gameSearchViewModelProvider.notifier);
      await notifier.search('test');
      expect(container.read(gameSearchViewModelProvider).value!.length, 1);

      notifier.clear();
      expect(container.read(gameSearchViewModelProvider).value, isEmpty);
    });

    test('search() passes CancelToken to repository', () async {
      final repo = FakeGameRepo();
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container.read(gameSearchViewModelProvider.notifier).search('test');

      expect(repo.lastCancelToken, isNotNull);
      expect(repo.lastCancelToken, isA<CancelToken>());
    });
  });
}
