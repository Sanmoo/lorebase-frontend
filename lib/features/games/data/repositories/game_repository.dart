import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/providers/core_providers.dart';
import '../models/game_model.dart';

abstract class GameRepository {
  Future<List<GameModel>> searchGames(
    String query, {
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  });
  Future<GameModel> getGameById(String id);
}

class GameRepositoryImpl implements GameRepository {
  final Dio _dio;

  GameRepositoryImpl(this._dio);

  @override
  Future<List<GameModel>> searchGames(
    String query, {
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        '/games',
        queryParameters: {'q': query, 'page': page, 'limit': limit},
        cancelToken: cancelToken,
      );
      final items = response.data['items'] as List;
      return items
          .map((json) => GameModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to search games',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<GameModel> getGameById(String id) async {
    try {
      final response = await _dio.get('/games/$id');
      return GameModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to load game',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepositoryImpl(ref.watch(dioProvider));
});
