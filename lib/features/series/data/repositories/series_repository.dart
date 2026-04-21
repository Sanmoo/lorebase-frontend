import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/providers/core_providers.dart';
import '../models/series_model.dart';

abstract class SeriesRepository {
  Future<List<SeriesModel>> searchSeries(String query, {int limit = 20});
  Future<SeriesModel> getSeriesById(String id);
}

class SeriesRepositoryImpl implements SeriesRepository {
  final Dio _dio;

  SeriesRepositoryImpl(this._dio);

  @override
  Future<List<SeriesModel>> searchSeries(String query, {int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/series',
        queryParameters: {
          'q': query,
          'limit': limit,
        },
      );
      final items = response.data['items'] as List;
      return items.map((json) => SeriesModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to search series',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<SeriesModel> getSeriesById(String id) async {
    try {
      final response = await _dio.get('/series/$id');
      return SeriesModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to load series',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

final seriesRepositoryProvider = Provider<SeriesRepository>((ref) {
  return SeriesRepositoryImpl(ref.watch(dioProvider));
});
