import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/series/viewmodels/series_search_viewmodel.dart';
import 'package:lorebase/features/series/data/repositories/series_repository.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';

class FakeSeriesRepo implements SeriesRepository {
  List<SeriesModel>? results;
  bool shouldThrow = false;
  CancelToken? lastCancelToken;

  @override
  Future<List<SeriesModel>> searchSeries(String query,
      {int limit = 20, CancelToken? cancelToken}) async {
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
  Future<SeriesModel> getSeriesById(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  group('SeriesSearchViewModel', () {
    ProviderContainer createContainer(FakeSeriesRepo repo) {
      return ProviderContainer(overrides: [
        seriesRepositoryProvider.overrideWith((ref) => repo),
      ]);
    }

    test('build() returns empty list', () {
      final container = createContainer(FakeSeriesRepo());
      addTearDown(container.dispose);

      final state = container.read(seriesSearchViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value, isEmpty);
    });

    test('search() with empty query clears results', () async {
      final repo = FakeSeriesRepo()
        ..results = [const SeriesModel(tmdbId: 1, title: 'Test')];
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(seriesSearchViewModelProvider.notifier);
      await notifier.search('test');
      expect(container.read(seriesSearchViewModelProvider).value!.length, 1);

      await notifier.search('');
      expect(container.read(seriesSearchViewModelProvider).value, isEmpty);
    });

    test('search() success returns results', () async {
      final results = [
        const SeriesModel(tmdbId: 1, title: 'Breaking Bad'),
        const SeriesModel(tmdbId: 2, title: 'Better Call Saul'),
      ];
      final repo = FakeSeriesRepo()..results = results;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(seriesSearchViewModelProvider.notifier)
          .search('breaking');

      final state = container.read(seriesSearchViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value!.length, 2);
      expect(state.value![0].title, 'Breaking Bad');
    });

    test('search() error sets AsyncValue.error', () async {
      final repo = FakeSeriesRepo()..shouldThrow = true;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(seriesSearchViewModelProvider.notifier)
          .search('test');

      final state = container.read(seriesSearchViewModelProvider);
      expect(state.hasError, true);
    });

    test('clear() resets to empty list', () async {
      final repo = FakeSeriesRepo()
        ..results = [const SeriesModel(tmdbId: 1, title: 'Test')];
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(seriesSearchViewModelProvider.notifier);
      await notifier.search('test');
      expect(container.read(seriesSearchViewModelProvider).value!.length, 1);

      notifier.clear();
      expect(container.read(seriesSearchViewModelProvider).value, isEmpty);
    });

    test('search() passes CancelToken to repository', () async {
      final repo = FakeSeriesRepo();
      final container = createContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(seriesSearchViewModelProvider.notifier)
          .search('test');

      expect(repo.lastCancelToken, isNotNull);
      expect(repo.lastCancelToken, isA<CancelToken>());
    });
  });
}
