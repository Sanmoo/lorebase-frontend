import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/providers/core_providers.dart';
import '../models/activity_event_model.dart';
import '../models/discover_user_model.dart';
import '../models/paginated_social_response.dart';
import '../models/public_list_item_model.dart';
import '../models/social_profile_model.dart';

abstract class SocialRepository {
  Future<SocialProfileModel> getMyProfile();

  Future<SocialProfileModel> updateMyProfile({
    required String displayName,
    String? avatarUrl,
    required bool isPublic,
  });

  Future<SocialProfileModel> getProfile(String userId);

  Future<void> followUser(String userId);

  Future<void> unfollowUser(String userId);

  Future<PaginatedSocialResponse<ActivityEventModel>> getFeed({
    int limit = 20,
    String? cursor,
  });

  Future<PaginatedSocialResponse<DiscoverUserModel>> discoverUsers({
    int limit = 20,
    String? cursor,
  });

  Future<PaginatedSocialResponse<ActivityEventModel>> getUserActivity(
    String userId, {
    int limit = 20,
    String? cursor,
  });

  Future<PaginatedSocialResponse<SocialProfileModel>> getFollowers(
    String userId, {
    int limit = 20,
    String? cursor,
  });

  Future<PaginatedSocialResponse<SocialProfileModel>> getFollowing(
    String userId, {
    int limit = 20,
    String? cursor,
  });

  Future<PaginatedSocialResponse<PublicListItemModel>> getPublicLists(
    String userId, {
    String? status,
    String? mediaType,
    int limit = 20,
    String? cursor,
  });
}

class SocialRepositoryImpl implements SocialRepository {
  final Dio _dio;

  SocialRepositoryImpl(this._dio);

  @override
  Future<SocialProfileModel> getMyProfile() async {
    return _getProfile('/profiles/me', 'Failed to load profile');
  }

  @override
  Future<SocialProfileModel> updateMyProfile({
    required String displayName,
    String? avatarUrl,
    required bool isPublic,
  }) async {
    try {
      final response = await _dio.put(
        '/profiles/me',
        data: {
          'displayName': displayName,
          'avatarUrl': avatarUrl,
          'isPublic': isPublic,
        },
      );
      return SocialProfileModel.fromJson(_responseMap(response.data));
    } on DioException catch (e) {
      throw _serverException(e, 'Failed to update profile');
    }
  }

  @override
  Future<SocialProfileModel> getProfile(String userId) async {
    return _getProfile('/profiles/$userId', 'Failed to load profile');
  }

  @override
  Future<void> followUser(String userId) async {
    try {
      await _dio.post('/follows/$userId');
    } on DioException catch (e) {
      throw _serverException(e, 'Failed to follow user');
    }
  }

  @override
  Future<void> unfollowUser(String userId) async {
    try {
      await _dio.delete('/follows/$userId');
    } on DioException catch (e) {
      throw _serverException(e, 'Failed to unfollow user');
    }
  }

  @override
  Future<PaginatedSocialResponse<ActivityEventModel>> getFeed({
    int limit = 20,
    String? cursor,
  }) async {
    return _getPaginated(
      '/feed',
      queryParameters: _paginationParams(limit: limit, cursor: cursor),
      fromJson: ActivityEventModel.fromJson,
      fallbackMessage: 'Failed to load feed',
    );
  }

  @override
  Future<PaginatedSocialResponse<DiscoverUserModel>> discoverUsers({
    int limit = 20,
    String? cursor,
  }) async {
    return _getPaginated(
      '/discover',
      queryParameters: _paginationParams(limit: limit, cursor: cursor),
      fromJson: DiscoverUserModel.fromJson,
      fallbackMessage: 'Failed to discover users',
    );
  }

  @override
  Future<PaginatedSocialResponse<ActivityEventModel>> getUserActivity(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async {
    return _getPaginated(
      '/profiles/$userId/activity',
      queryParameters: _paginationParams(limit: limit, cursor: cursor),
      fromJson: ActivityEventModel.fromJson,
      fallbackMessage: 'Failed to load user activity',
    );
  }

  @override
  Future<PaginatedSocialResponse<SocialProfileModel>> getFollowers(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async {
    final path = userId == 'me'
        ? '/follows/me/followers'
        : '/follows/$userId/followers';
    return _getPaginated(
      path,
      queryParameters: _paginationParams(limit: limit, cursor: cursor),
      fromJson: SocialProfileModel.fromJson,
      fallbackMessage: 'Failed to load followers',
    );
  }

  @override
  Future<PaginatedSocialResponse<SocialProfileModel>> getFollowing(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async {
    final path = userId == 'me'
        ? '/follows/me/following'
        : '/follows/$userId/following';
    return _getPaginated(
      path,
      queryParameters: _paginationParams(limit: limit, cursor: cursor),
      fromJson: SocialProfileModel.fromJson,
      fallbackMessage: 'Failed to load following',
    );
  }

  @override
  Future<PaginatedSocialResponse<PublicListItemModel>> getPublicLists(
    String userId, {
    String? status,
    String? mediaType,
    int limit = 20,
    String? cursor,
  }) async {
    return _getPaginated(
      '/profiles/$userId/lists',
      queryParameters: {
        'status': ?status,
        'mediaType': ?mediaType,
        'limit': limit,
        'cursor': ?cursor,
      },
      fromJson: PublicListItemModel.fromJson,
      fallbackMessage: 'Failed to load public lists',
    );
  }

  Future<SocialProfileModel> _getProfile(
    String path,
    String fallbackMessage,
  ) async {
    try {
      final response = await _dio.get(path);
      return SocialProfileModel.fromJson(_responseMap(response.data));
    } on DioException catch (e) {
      throw _serverException(e, fallbackMessage);
    }
  }

  Future<PaginatedSocialResponse<T>> _getPaginated<T>(
    String path, {
    required Map<String, dynamic> queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
    required String fallbackMessage,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return PaginatedSocialResponse<T>.fromJson(
        _responseMap(response.data),
        fromJson,
      );
    } on DioException catch (e) {
      throw _serverException(e, fallbackMessage);
    }
  }

  Map<String, dynamic> _paginationParams({
    required int limit,
    String? cursor,
  }) {
    return {
      'limit': limit,
      'cursor': ?cursor,
    };
  }

  Map<String, dynamic> _responseMap(dynamic data) {
    return Map<String, dynamic>.from(data as Map);
  }

  ServerException _serverException(DioException exception, String message) {
    if (exception.error is ServerException) {
      return exception.error as ServerException;
    }
    return ServerException(
      message: exception.message ?? message,
      statusCode: exception.response?.statusCode,
    );
  }
}

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return SocialRepositoryImpl(ref.watch(dioProvider));
});
