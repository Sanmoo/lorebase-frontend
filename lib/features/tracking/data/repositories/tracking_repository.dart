import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/providers/core_providers.dart';
import '../models/tracked_series_model.dart';

abstract class TrackingRepository {
  Future<List<TrackedSeriesModel>> getTracking({
    String? status,
    int page = 1,
    int pageSize = 20,
  });
  Future<TrackedSeriesModel> startTracking(String seriesId, String status);
  Future<TrackedSeriesModel> updateTracking(
    String seriesId, {
    String? status,
    int? seriesRating,
    String? seriesReview,
    List<Map<String, dynamic>>? seasonRatings,
  });
  Future<void> deleteTracking(String seriesId);
}

class TrackingRepositoryImpl implements TrackingRepository {
  final Dio _dio;

  TrackingRepositoryImpl(this._dio);

  @override
  Future<List<TrackedSeriesModel>> getTracking({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/tracking',
        queryParameters: {
          if (status != null) 'status': status,
          'page': page,
          'pageSize': pageSize,
          'includeSeries': true,
        },
      );
      final items = response.data['items'] as List;
      return items.map((json) => TrackedSeriesModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to load tracking',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<TrackedSeriesModel> startTracking(String seriesId, String status) async {
    try {
      final response = await _dio.post(
        '/tracking',
        data: {
          'seriesId': seriesId,
          'status': status,
        },
      );
      return TrackedSeriesModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to start tracking',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<TrackedSeriesModel> updateTracking(
    String seriesId, {
    String? status,
    int? seriesRating,
    String? seriesReview,
    List<Map<String, dynamic>>? seasonRatings,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (status != null) data['status'] = status;
      if (seriesRating != null) data['seriesRating'] = seriesRating;
      if (seriesReview != null) data['seriesReview'] = seriesReview;
      if (seasonRatings != null) data['seasonRatings'] = seasonRatings;

      final response = await _dio.put(
        '/tracking/$seriesId',
        data: data,
      );
      return TrackedSeriesModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update tracking',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteTracking(String seriesId) async {
    try {
      await _dio.delete('/tracking/$seriesId');
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete tracking',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return TrackingRepositoryImpl(ref.watch(dioProvider));
});
