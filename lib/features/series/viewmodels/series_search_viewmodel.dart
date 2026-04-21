import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/series_model.dart';
import '../data/repositories/series_repository.dart';

part 'series_search_viewmodel.g.dart';

@riverpod
class SeriesSearchViewModel extends _$SeriesSearchViewModel {
  @override
  AsyncValue<List<SeriesModel>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final repository = ref.read(seriesRepositoryProvider);
      final results = await repository.searchSeries(query);
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}
