import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/providers/core_providers.dart';
import '../models/movie_model.dart';

abstract class MovieRepository {
  Future<List<MovieModel>> searchMovies(
    String query, {
    int limit = 20,
    CancelToken? cancelToken,
  });

  Future<MovieModel> getMovieById(String id);
}

class MovieRepositoryImpl implements MovieRepository {
  final Dio _dio;

  MovieRepositoryImpl(this._dio);

  @override
  Future<List<MovieModel>> searchMovies(
    String query, {
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        '/movies',
        queryParameters: {'q': query, 'limit': limit},
        cancelToken: cancelToken,
      );
      final items = response.data['items'] as List;
      return items.map((json) => MovieModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to search movies',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<MovieModel> getMovieById(String id) async {
    try {
      final response = await _dio.get('/movies/$id');
      return MovieModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to load movie',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepositoryImpl(ref.watch(dioProvider));
});
