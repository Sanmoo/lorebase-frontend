import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/data/models/activity_event_model.dart';
import 'package:lorebase/features/social/data/models/discover_user_model.dart';
import 'package:lorebase/features/social/data/models/paginated_social_response.dart';
import 'package:lorebase/features/social/data/models/social_profile_model.dart';
import 'package:lorebase/features/social/data/repositories/social_repository.dart';

class MockAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions options) onFetch;

  MockAdapter({required this.onFetch});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return onFetch(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(Map<String, dynamic> json) => ResponseBody.fromString(
      jsonEncode(json),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      },
    );

Map<String, dynamic> _profileJson() => {
      'userId': 'user-1',
      'displayName': 'Fulano',
      'avatarUrl': 'https://example.com/a.jpg',
      'isPublic': true,
      'followingCount': 3,
      'followerCount': 7,
      'isFollowedByMe': false,
      'createdAt': '2026-05-20T10:00:00Z',
      'updatedAt': '2026-05-20T11:00:00Z',
    };

Map<String, dynamic> _activityJson() => {
      'eventId': 'evt-1',
      'user': {
        'userId': 'user-1',
        'displayName': 'Fulano',
      },
      'activityType': 'COMPLETED',
      'media': {
        'mediaId': '1',
        'mediaType': 'MOVIE',
        'title': 'Movie',
      },
      'metadata': <String, dynamic>{},
      'createdAt': '2026-05-20T10:00:00Z',
    };

Map<String, dynamic> _discoverUserJson() => {
      'userId': 'user-2',
      'displayName': 'Maria',
      'avatarUrl': null,
      'affinityScore': 0.82,
      'commonGenres': ['Anime'],
      'commonMedia': <Map<String, dynamic>>[],
      'isFollowedByMe': false,
    };

void main() {
  group('SocialRepositoryImpl', () {
    test('getMyProfile calls GET /profiles/me and parses model', () async {
      String? capturedMethod;
      String? capturedPath;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedMethod = options.method;
            capturedPath = options.path;
            return _jsonBody(_profileJson());
          },
        );
      final repo = SocialRepositoryImpl(dio);

      final result = await repo.getMyProfile();

      expect(capturedMethod, 'GET');
      expect(capturedPath, '/profiles/me');
      expect(result, isA<SocialProfileModel>());
      expect(result.userId, 'user-1');
    });

    test('updateMyProfile calls PUT /profiles/me with profile fields', () async {
      String? capturedMethod;
      String? capturedPath;
      Map<String, dynamic>? capturedData;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedMethod = options.method;
            capturedPath = options.path;
            capturedData = Map<String, dynamic>.from(options.data as Map);
            return _jsonBody(_profileJson());
          },
        );
      final repo = SocialRepositoryImpl(dio);

      final result = await repo.updateMyProfile(
        displayName: 'Fulano',
        avatarUrl: 'https://example.com/a.jpg',
        isPublic: true,
      );

      expect(capturedMethod, 'PUT');
      expect(capturedPath, '/profiles/me');
      expect(capturedData, {
        'displayName': 'Fulano',
        'avatarUrl': 'https://example.com/a.jpg',
        'isPublic': true,
      });
      expect(result.displayName, 'Fulano');
    });

    test('getFeed calls GET /feed with limit/cursor and parses page', () async {
      Map<String, dynamic>? capturedParams;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedParams = options.queryParameters;
            return _jsonBody({
              'items': [_activityJson()],
              'nextCursor': 'next',
              'hasMore': true,
            });
          },
        );
      final repo = SocialRepositoryImpl(dio);

      final result = await repo.getFeed(limit: 10, cursor: 'cursor-1');

      expect(capturedParams, {'limit': 10, 'cursor': 'cursor-1'});
      expect(result, isA<PaginatedSocialResponse<ActivityEventModel>>());
      expect(result.items.single.eventId, 'evt-1');
      expect(result.nextCursor, 'next');
    });

    test('discoverUsers calls GET /discover and parses users', () async {
      String? capturedPath;
      Map<String, dynamic>? capturedParams;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedPath = options.path;
            capturedParams = options.queryParameters;
            return _jsonBody({
              'items': [_discoverUserJson()],
              'nextCursor': null,
              'hasMore': false,
            });
          },
        );
      final repo = SocialRepositoryImpl(dio);

      final result = await repo.discoverUsers(limit: 5, cursor: 'cursor-2');

      expect(capturedPath, '/discover');
      expect(capturedParams, {'limit': 5, 'cursor': 'cursor-2'});
      expect(result, isA<PaginatedSocialResponse<DiscoverUserModel>>());
      expect(result.items.single.displayName, 'Maria');
    });

    test('followUser calls POST /follows/{userId}', () async {
      String? capturedMethod;
      String? capturedPath;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedMethod = options.method;
            capturedPath = options.path;
            return _jsonBody(<String, dynamic>{});
          },
        );
      final repo = SocialRepositoryImpl(dio);

      await repo.followUser('user-2');

      expect(capturedMethod, 'POST');
      expect(capturedPath, '/follows/user-2');
    });

    test('unfollowUser calls DELETE /follows/{userId}', () async {
      String? capturedMethod;
      String? capturedPath;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedMethod = options.method;
            capturedPath = options.path;
            return _jsonBody(<String, dynamic>{});
          },
        );
      final repo = SocialRepositoryImpl(dio);

      await repo.unfollowUser('user-2');

      expect(capturedMethod, 'DELETE');
      expect(capturedPath, '/follows/user-2');
    });
  });
}
