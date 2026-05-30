import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/providers/core_providers.dart';
import '../models/tracked_media_model.dart';
import '../models/media_type.dart';

abstract class TrackingRepository {
  Future<List<TrackedMediaModel>> getTracking({
    String? status,
    MediaType? mediaType,
    int page = 1,
    int pageSize = 20,
  });

  Future<TrackedMediaModel?> getTrackingByMedia(
    String mediaId,
    MediaType mediaType,
  );

  Future<TrackedMediaModel> startTracking(
    String mediaId,
    MediaType mediaType,
    String status,
  );

  Future<TrackedMediaModel> updateTracking(
    String mediaId, {
    required MediaType mediaType,
    String? status,
    int? rating,
    String? review,
    List<Map<String, dynamic>>? seasonRatings,
  });

  Future<void> deleteTracking(String mediaId, {required MediaType mediaType});
}

class TrackingRepositoryImpl implements TrackingRepository {
  final Dio _dio;

  TrackingRepositoryImpl(this._dio);

  @override
  Future<List<TrackedMediaModel>> getTracking({
    String? status,
    MediaType? mediaType,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/tracking',
        queryParameters: {
          'status': ?status,
          'mediaType': ?mediaType?.apiValue,
          'page': page,
          'pageSize': pageSize,
          'includeMedia': true,
        },
      );
      final items = response.data['items'] as List;
      return items.map((json) => TrackedMediaModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to load tracking',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<TrackedMediaModel?> getTrackingByMedia(
    String mediaId,
    MediaType mediaType,
  ) async {
    try {
      final response = await _dio.get(
        '/tracking/$mediaId',
        queryParameters: {'mediaType': mediaType.apiValue},
      );
      return TrackedMediaModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw ServerException(
        message: e.message ?? 'Failed to load tracking',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<TrackedMediaModel> startTracking(
    String mediaId,
    MediaType mediaType,
    String status,
  ) async {
    try {
      final response = await _dio.post(
        '/tracking',
        data: {
          'mediaId': mediaId,
          'mediaType': mediaType.apiValue,
          'status': status,
        },
      );
      return TrackedMediaModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to start tracking',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<TrackedMediaModel> updateTracking(
    String mediaId, {
    required MediaType mediaType,
    String? status,
    int? rating,
    String? review,
    List<Map<String, dynamic>>? seasonRatings,
  }) async {
    try {
      final data = <String, dynamic>{
        'mediaType': mediaType.apiValue,
        'status': ?status,
        'seriesRating': ?rating,
        'seriesReview': ?review,
        'seasonRatings': ?seasonRatings,
      };

      final response = await _dio.put('/tracking/$mediaId', data: data);
      return TrackedMediaModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update tracking',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteTracking(
    String mediaId, {
    required MediaType mediaType,
  }) async {
    try {
      await _dio.delete(
        '/tracking/$mediaId',
        queryParameters: {'mediaType': mediaType.apiValue},
      );
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
