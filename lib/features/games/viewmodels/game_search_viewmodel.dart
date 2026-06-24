import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/game_model.dart';
import '../data/repositories/game_repository.dart';

part 'game_search_viewmodel.g.dart';

@riverpod
class GameSearchViewModel extends _$GameSearchViewModel {
  CancelToken? _cancelToken;

  @override
  AsyncValue<List<GameModel>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    _cancelToken?.cancel();
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;

    final previousState = state;
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(gameRepositoryProvider);
      final results = await repository.searchGames(
        query,
        cancelToken: cancelToken,
      );
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      if (error is DioException && error.type == DioExceptionType.cancel) {
        state = previousState;
        return;
      }
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clear() {
    _cancelToken?.cancel();
    _cancelToken = null;
    state = const AsyncValue.data([]);
  }
}
