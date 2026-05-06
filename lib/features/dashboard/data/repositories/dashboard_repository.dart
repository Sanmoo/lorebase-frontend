import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/providers/core_providers.dart';
import '../models/dashboard_model.dart';

abstract class DashboardRepository {
  Future<DashboardModel> getDashboard();
}

class DashboardRepositoryImpl implements DashboardRepository {
  final Dio _dio;

  DashboardRepositoryImpl(this._dio);

  @override
  Future<DashboardModel> getDashboard() async {
    try {
      final response = await _dio.get('/dashboard');
      final data = response.data as Map<String, dynamic>;
      _normalizeDashboardItems(data);
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

  void _normalizeDashboardItems(Map<String, dynamic> data) {
    for (final section in ['watching', 'wantToWatch', 'completed', 'dropped']) {
      final sectionData = data[section];
      if (sectionData is Map<String, dynamic>) {
        final items = sectionData['items'];
        if (items is List) {
          for (final item in items) {
            if (item is Map<String, dynamic>) {
              if (item['tmdbId'] == null && item['seriesId'] != null) {
                item['tmdbId'] =
                    int.tryParse(item['seriesId'].toString()) ?? 0;
              }
            }
          }
        }
      }
    }
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dioProvider));
});
