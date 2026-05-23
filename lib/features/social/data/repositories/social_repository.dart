import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/logging/debug_log.dart';
import '../../../../core/providers/core_providers.dart';
import '../models/activity_event_model.dart';
import '../models/discover_user_model.dart';
import '../models/follow_relationship_model.dart';
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

  Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowers(
    String userId, {
    int limit = 20,
    String? cursor,
  });

  Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowing(
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
    const path = '/users/me/profile';
    debugLog('[SocialProfile] repository getMyProfile started path=$path');
    try {
      final profile = await _getProfile(path, 'Failed to load profile');
      debugLog('[SocialProfile] repository getMyProfile success path=$path');
      return profile;
    } on ServerException catch (error) {
      debugLog(
        '[SocialProfile] repository getMyProfile failed '
        'path=$path status=${error.statusCode}',
      );
      rethrow;
    } catch (error) {
      debugLog(
        '[SocialProfile] repository getMyProfile failed '
        'path=$path type=${error.runtimeType}',
      );
      rethrow;
    }
  }

  @override
  Future<SocialProfileModel> updateMyProfile({
    required String displayName,
    String? avatarUrl,
    required bool isPublic,
  }) async {
    try {
      final response = await _dio.put(
        '/users/me/profile',
        data: {
          'displayName': displayName,
          'avatarUrl': avatarUrl,
          'isPublic': isPublic,
        },
      );
      return _profileFromResponse(response.data);
    } on DioException catch (e) {
      throw _repositoryException(e, 'Failed to update profile');
    }
  }

  @override
  Future<SocialProfileModel> getProfile(String userId) async {
    return _getProfile('/profiles/$userId', 'Failed to load profile');
  }

  @override
  Future<void> followUser(String userId) async {
    try {
      await _dio.post('/users/$userId/follow');
    } on DioException catch (e) {
      throw _repositoryException(e, 'Failed to follow user');
    }
  }

  @override
  Future<void> unfollowUser(String userId) async {
    try {
      await _dio.delete('/users/$userId/follow');
    } on DioException catch (e) {
      throw _repositoryException(e, 'Failed to unfollow user');
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
  Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowers(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async {
    final path = '/users/$userId/followers';
    return _getPaginated(
      path,
      queryParameters: _paginationParams(limit: limit, cursor: cursor),
      fromJson: FollowRelationshipModel.fromJson,
      fallbackMessage: 'Failed to load followers',
    );
  }

  @override
  Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowing(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async {
    final path = '/users/$userId/following';
    return _getPaginated(
      path,
      queryParameters: _paginationParams(limit: limit, cursor: cursor),
      fromJson: FollowRelationshipModel.fromJson,
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
      fromJson: _publicListItemFromJson,
      fallbackMessage: 'Failed to load public lists',
    );
  }

  Future<SocialProfileModel> _getProfile(
    String path,
    String fallbackMessage,
  ) async {
    try {
      final response = await _dio.get(path);
      return _profileFromResponse(response.data);
    } on DioException catch (e) {
      throw _repositoryException(e, fallbackMessage);
    }
  }

  Future<PaginatedSocialResponse<T>> _getPaginated<T>(
    String path, {
    required Map<String, dynamic> queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
    required String fallbackMessage,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return PaginatedSocialResponse<T>.fromJson(
        _responseMap(response.data),
        fromJson,
      );
    } on DioException catch (e) {
      throw _repositoryException(e, fallbackMessage);
    }
  }

  Map<String, dynamic> _paginationParams({required int limit, String? cursor}) {
    return {'limit': limit, 'cursor': ?cursor};
  }

  PublicListItemModel _publicListItemFromJson(Map<String, dynamic> json) {
    final normalizedJson = Map<String, dynamic>.from(json);
    if (normalizedJson['updatedAt'] == '') {
      normalizedJson['updatedAt'] = null;
    }
    return PublicListItemModel.fromJson(normalizedJson);
  }

  SocialProfileModel _profileFromResponse(dynamic data) {
    final json = _responseMap(data);
    const epoch = '1970-01-01T00:00:00.000Z';
    json['createdAt'] ??= epoch;
    json['updatedAt'] ??= epoch;
    json['displayName'] = _profileDisplayName(json);
    json['avatarUrl'] = _profileAvatarUrl(json['avatarUrl']);
    json['isPublic'] ??= true;
    json['followingCount'] ??= 0;
    json['followerCount'] ??= 0;
    if (json['isFollowedByMe'] == null && json['isFollowing'] is bool) {
      json['isFollowedByMe'] = json['isFollowing'];
    }
    return SocialProfileModel.fromJson(json);
  }

  String _profileDisplayName(Map<String, dynamic> json) {
    final displayName = (json['displayName'] as String?)?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    final username = (json['username'] as String?)?.trim();
    if (username != null && username.isNotEmpty) {
      return username;
    }
    return 'Usuário';
  }

  String? _profileAvatarUrl(dynamic avatarUrl) {
    final url = avatarUrl as String?;
    if (url == null || url.trim().isEmpty) {
      return null;
    }
    return url;
  }

  Map<String, dynamic> _responseMap(dynamic data) {
    return Map<String, dynamic>.from(data as Map);
  }

  Exception _repositoryException(DioException exception, String message) {
    final error = exception.error;
    if (error is ServerException) {
      return error;
    }
    if (error is AuthException) {
      return error;
    }
    if (error is NetworkException) {
      return error;
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
