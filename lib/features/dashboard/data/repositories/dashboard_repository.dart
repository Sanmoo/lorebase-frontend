import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../tracking/data/models/media_type.dart';
import '../models/dashboard_model.dart';

abstract class DashboardRepository {
  Future<DashboardModel> getDashboard({
    MediaType mediaType = MediaType.series,
  });
}

class DashboardRepositoryImpl implements DashboardRepository {
  final Dio _dio;

  DashboardRepositoryImpl(this._dio);

  @override
  Future<DashboardModel> getDashboard({
    MediaType mediaType = MediaType.series,
  }) async {
    try {
      final response = await _dio.get(
        '/dashboard',
        queryParameters: {'mediaType': mediaType.apiValue},
      );
      final data = response.data as Map<String, dynamic>;
      return DashboardModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(
        message: e.message ?? 'Failed to load dashboard',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dioProvider));
});
