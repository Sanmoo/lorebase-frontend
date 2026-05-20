import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/movie_model.dart';
import '../data/repositories/movie_repository.dart';

part 'movie_search_viewmodel.g.dart';

@riverpod
class MovieSearchViewModel extends _$MovieSearchViewModel {
  CancelToken? _cancelToken;

  @override
  AsyncValue<List<MovieModel>> build() {
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
      final results = await ref.read(movieRepositoryProvider).searchMovies(
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
