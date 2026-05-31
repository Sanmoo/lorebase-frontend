import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/errors/exceptions.dart';
import 'package:lorebase/features/social/data/models/activity_event_model.dart';
import 'package:lorebase/features/social/data/models/avatar_upload_file.dart';
import 'package:lorebase/features/social/data/models/discover_user_model.dart';
import 'package:lorebase/features/social/data/models/follow_relationship_model.dart';
import 'package:lorebase/features/social/data/models/paginated_social_response.dart';
import 'package:lorebase/features/social/data/models/public_list_item_model.dart';
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

ResponseBody _jsonBody(Map<String, dynamic> json, {int statusCode = 200}) =>
    ResponseBody.fromString(
      jsonEncode(json),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
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
  'userId': 'user-1',
  'activityType': 'COMPLETED',
  'mediaId': '1',
  'mediaType': 'MOVIE',
  'mediaTitle': 'Movie',
  'metadata': <String, dynamic>{'displayName': 'Fulano'},
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

Map<String, dynamic> _followRelationshipJson() => {
  'userId': 'user-2',
  'username': 'maria',
  'displayName': 'Maria Souza',
  'avatarUrl': 'https://example.com/maria.png',
  'isFollowing': true,
};

Map<String, dynamic> _publicListItemJson() => {
  'mediaId': 'media-1',
  'mediaType': 'MOVIE',
  'status': 'COMPLETED',
  'rating': 9,
  'review': 'Great',
  'media': {'mediaId': 'media-1', 'mediaType': 'MOVIE', 'title': 'Movie'},
  'updatedAt': '2026-05-20T10:00:00Z',
};

void main() {
  group('SocialRepositoryImpl', () {
    test('getMyProfile calls GET /users/me/profile and parses model', () async {
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
      expect(capturedPath, '/users/me/profile');
      expect(result, isA<SocialProfileModel>());
      expect(result.userId, 'user-1');
    });

    test(
      'getMyProfile tolerates BFF profile responses without timestamps',
      () async {
        final dio = Dio()
          ..httpClientAdapter = MockAdapter(
            onFetch: (_) => _jsonBody({
              'userId': 'user-1',
              'displayName': 'Fulano',
              'avatarUrl': null,
              'isPublic': true,
              'followingCount': 0,
              'followerCount': 0,
            }),
          );
        final repo = SocialRepositoryImpl(dio);

        final result = await repo.getMyProfile();

        expect(result.userId, 'user-1');
        expect(
          result.createdAt,
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        );
        expect(
          result.updatedAt,
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        );
      },
    );

    test(
      'getMyProfile normalizes missing optional BFF profile fields',
      () async {
        final dio = Dio()
          ..httpClientAdapter = MockAdapter(
            onFetch: (_) => _jsonBody({
              'userId': 'user-1',
              'displayName': '  ',
              'username': '  fulano  ',
              'avatarUrl': '   ',
              'isFollowing': true,
            }),
          );
        final repo = SocialRepositoryImpl(dio);

        final result = await repo.getMyProfile();

        expect(result.displayName, 'fulano');
        expect(result.avatarUrl, isNull);
        expect(result.isPublic, isTrue);
        expect(result.followingCount, 0);
        expect(result.followerCount, 0);
        expect(result.isFollowedByMe, isTrue);
      },
    );

    test(
      'getMyProfile falls back to generic displayName without username',
      () async {
        final dio = Dio()
          ..httpClientAdapter = MockAdapter(
            onFetch: (_) => _jsonBody({
              'userId': 'user-1',
              'displayName': '',
              'avatarUrl': null,
              'isPublic': true,
              'followingCount': 0,
              'followerCount': 0,
            }),
          );
        final repo = SocialRepositoryImpl(dio);

        final result = await repo.getMyProfile();

        expect(result.displayName, 'Usuário');
      },
    );

    test(
      'updateMyProfile calls PUT /users/me/profile with profile fields',
      () async {
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
        expect(capturedPath, '/users/me/profile');
        expect(capturedData, {
          'displayName': 'Fulano',
          'avatarUrl': 'https://example.com/a.jpg',
          'isPublic': true,
        });
        expect(result.displayName, 'Fulano');
      },
    );

    test(
      'updateMyAvatar sends multipart avatar and parses updated profile',
      () async {
        late RequestOptions captured;
        final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                captured = options;
                handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: {
                      'userId': 'user-1',
                      'displayName': 'Alice',
                      'avatarUrl': 'https://cdn.example/avatar.png',
                      'isPublic': true,
                      'followingCount': 0,
                      'followerCount': 0,
                      'createdAt': '2026-05-30T12:00:00Z',
                      'updatedAt': '2026-05-30T12:00:00Z',
                    },
                  ),
                );
              },
            ),
          );
        final repo = SocialRepositoryImpl(dio);

        final profile = await repo.updateMyAvatar(
          file: AvatarUploadFile(
            bytes: Uint8List.fromList([1, 2, 3]),
            filename: 'avatar.png',
            mimeType: 'image/png',
          ),
        );

        expect(captured.method, 'PUT');
        expect(captured.path, '/users/me/avatar');
        expect(captured.data, isA<FormData>());
        final formData = captured.data as FormData;
        expect(formData.files.single.key, 'avatar');
        expect(formData.files.single.value.filename, 'avatar.png');
        expect(profile.avatarUrl, 'https://cdn.example/avatar.png');
      },
    );

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
      expect(result.items.single.user.userId, 'user-1');
      expect(result.items.single.user.displayName, 'Fulano');
      expect(result.items.single.media.mediaId, '1');
      expect(result.items.single.media.mediaType, 'MOVIE');
      expect(result.items.single.media.title, 'Movie');
      expect(result.nextCursor, 'next');
    });

    test('getFeed keeps nested activity payloads working', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (_) => _jsonBody({
            'items': [
              {
                'eventId': 'evt-nested',
                'activityType': 'WATCHING',
                'user': {
                  'userId': 'user-nested',
                  'displayName': 'Maria',
                  'avatarUrl': 'https://example.com/maria.jpg',
                },
                'media': {
                  'mediaId': 'media-nested',
                  'mediaType': 'SERIES',
                  'title': 'Series',
                  'posterUrl': 'https://example.com/poster.jpg',
                },
                'metadata': <String, dynamic>{},
                'createdAt': '2026-05-20T10:00:00Z',
              },
            ],
            'nextCursor': null,
            'hasMore': false,
          }),
        );
      final repo = SocialRepositoryImpl(dio);

      final result = await repo.getFeed();

      final event = result.items.single;
      expect(event.eventId, 'evt-nested');
      expect(event.user.userId, 'user-nested');
      expect(event.user.displayName, 'Maria');
      expect(event.user.avatarUrl, 'https://example.com/maria.jpg');
      expect(event.media.mediaId, 'media-nested');
      expect(event.media.mediaType, 'SERIES');
      expect(event.media.title, 'Series');
      expect(event.media.posterUrl, 'https://example.com/poster.jpg');
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

    test('followUser calls POST /users/{userId}/follow', () async {
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
      expect(capturedPath, '/users/user-2/follow');
    });

    test('unfollowUser calls DELETE /users/{userId}/follow', () async {
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
      expect(capturedPath, '/users/user-2/follow');
    });

    test('getMyProfile propagates 404 as ServerException', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (_) => _jsonBody({'message': 'Not found'}, statusCode: 404),
        );
      final repo = SocialRepositoryImpl(dio);

      await expectLater(
        repo.getMyProfile(),
        throwsA(
          isA<ServerException>().having(
            (exception) => exception.statusCode,
            'statusCode',
            404,
          ),
        ),
      );
    });

    test('followUser propagates 409 as ServerException', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (_) =>
              _jsonBody({'message': 'Already following'}, statusCode: 409),
        );
      final repo = SocialRepositoryImpl(dio);

      await expectLater(
        repo.followUser('user-2'),
        throwsA(
          isA<ServerException>().having(
            (exception) => exception.statusCode,
            'statusCode',
            409,
          ),
        ),
      );
    });

    test('getMyProfile propagates Dio AuthException error', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            throw DioException(
              requestOptions: options,
              error: const AuthException(message: 'Unauthorized'),
            );
          },
        );
      final repo = SocialRepositoryImpl(dio);

      await expectLater(
        repo.getMyProfile(),
        throwsA(
          isA<AuthException>().having(
            (exception) => exception.message,
            'message',
            'Unauthorized',
          ),
        ),
      );
    });

    test('getFeed propagates Dio NetworkException error', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            throw DioException(
              requestOptions: options,
              error: const NetworkException(message: 'No internet'),
            );
          },
        );
      final repo = SocialRepositoryImpl(dio);

      await expectLater(
        repo.getFeed(),
        throwsA(
          isA<NetworkException>().having(
            (exception) => exception.message,
            'message',
            'No internet',
          ),
        ),
      );
    });

    test('getProfile calls user profile endpoint', () async {
      String? capturedPath;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedPath = options.path;
            return _jsonBody(_profileJson());
          },
        );
      final repo = SocialRepositoryImpl(dio);

      final result = await repo.getProfile('user-2');

      expect(capturedPath, '/users/user-2/profile');
      expect(result.displayName, 'Fulano');
    });

    test('updateMyProfile maps Dio failure to ServerException', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (_) => _jsonBody({'message': 'Bad'}, statusCode: 400),
        );
      final repo = SocialRepositoryImpl(dio);

      await expectLater(
        repo.updateMyProfile(displayName: 'Fulano', isPublic: true),
        throwsA(isA<ServerException>()),
      );
    });

    test('unfollowUser maps Dio failure to ServerException', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (_) => _jsonBody({'message': 'Bad'}, statusCode: 400),
        );
      final repo = SocialRepositoryImpl(dio);

      await expectLater(
        repo.unfollowUser('user-2'),
        throwsA(isA<ServerException>()),
      );
    });

    test('getProfile propagates embedded ServerException', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            throw DioException(
              requestOptions: options,
              error: const ServerException(message: 'Nope', statusCode: 418),
            );
          },
        );
      final repo = SocialRepositoryImpl(dio);

      await expectLater(
        repo.getProfile('user-2'),
        throwsA(
          isA<ServerException>().having(
            (exception) => exception.statusCode,
            'statusCode',
            418,
          ),
        ),
      );
    });

    test(
      'getUserActivity calls profile activity endpoint and parses events',
      () async {
        String? capturedPath;
        Map<String, dynamic>? capturedParams;
        final dio = Dio()
          ..httpClientAdapter = MockAdapter(
            onFetch: (options) {
              capturedPath = options.path;
              capturedParams = options.queryParameters;
              return _jsonBody({
                'items': [_activityJson()],
                'nextCursor': null,
                'hasMore': false,
              });
            },
          );
        final repo = SocialRepositoryImpl(dio);

        final result = await repo.getUserActivity(
          'user-1',
          limit: 12,
          cursor: 'cursor-3',
        );

        expect(capturedPath, '/profiles/user-1/activity');
        expect(capturedParams, {'limit': 12, 'cursor': 'cursor-3'});
        expect(result, isA<PaginatedSocialResponse<ActivityEventModel>>());
        expect(result.items.single.eventId, 'evt-1');
        expect(result.items.single.user.userId, 'user-1');
        expect(result.items.single.user.displayName, 'Fulano');
        expect(result.items.single.media.mediaId, '1');
        expect(result.items.single.media.mediaType, 'MOVIE');
        expect(result.items.single.media.title, 'Movie');
      },
    );

    test(
      'getUserActivity normalizes flattened BFF activity media fields before parsing',
      () async {
        final dio = Dio()
          ..httpClientAdapter = MockAdapter(
            onFetch: (_) => _jsonBody({
              'items': [
                {
                  'eventId': 'evt-flat',
                  'userId': 'user-flat',
                  'displayName': 'Ana',
                  'username': 'ana-user',
                  'avatarUrl': 'https://example.com/ana.jpg',
                  'activityType': 'COMPLETED',
                  'mediaId': 'media-flat',
                  'mediaType': 'MOVIE',
                  'mediaTitle': 'Flat Movie',
                  'mediaPosterUrl': 'https://example.com/flat.jpg',
                  'metadata': <String, dynamic>{},
                  'createdAt': '2026-05-20T10:00:00Z',
                },
              ],
              'nextCursor': null,
              'hasMore': false,
            }),
          );
        final repo = SocialRepositoryImpl(dio);

        final result = await repo.getUserActivity('user-flat');

        final event = result.items.single;
        expect(event.eventId, 'evt-flat');
        expect(event.user.userId, 'user-flat');
        expect(event.user.displayName, 'Ana');
        expect(event.user.avatarUrl, 'https://example.com/ana.jpg');
        expect(event.media.mediaId, 'media-flat');
        expect(event.media.mediaType, 'MOVIE');
        expect(event.media.title, 'Flat Movie');
        expect(event.media.posterUrl, 'https://example.com/flat.jpg');
      },
    );

    test(
      'getUserActivity falls back to metadata avatarUrl for flattened activity',
      () async {
        final dio = Dio()
          ..httpClientAdapter = MockAdapter(
            onFetch: (_) => _jsonBody({
              'items': [
                {
                  'eventId': 'evt-metadata-avatar',
                  'userId': 'user-metadata-avatar',
                  'activityType': 'COMPLETED',
                  'mediaId': 'media-metadata-avatar',
                  'mediaType': 'MOVIE',
                  'mediaTitle': 'Metadata Movie',
                  'metadata': <String, dynamic>{
                    'displayName': 'Metadata Ana',
                    'avatarUrl': 'https://example.com/metadata-ana.jpg',
                  },
                  'createdAt': '2026-05-20T10:00:00Z',
                },
              ],
              'nextCursor': null,
              'hasMore': false,
            }),
          );
        final repo = SocialRepositoryImpl(dio);

        final result = await repo.getUserActivity('user-metadata-avatar');

        final event = result.items.single;
        expect(event.user.displayName, 'Metadata Ana');
        expect(event.user.avatarUrl, 'https://example.com/metadata-ana.jpg');
      },
    );

    test(
      'getUserActivity supports simple flattened activity aliases',
      () async {
        final dio = Dio()
          ..httpClientAdapter = MockAdapter(
            onFetch: (_) => _jsonBody({
              'items': [
                {
                  'id': 'evt-alias',
                  'userId': 'user-alias',
                  'type': 'RATED',
                  'mediaId': 'media-alias',
                  'mediaType': 'MOVIE',
                  'mediaTitle': 'Alias Movie',
                  'timestamp': '2026-05-20T10:00:00Z',
                },
              ],
              'nextCursor': null,
              'hasMore': false,
            }),
          );
        final repo = SocialRepositoryImpl(dio);

        final result = await repo.getUserActivity('user-alias');

        final event = result.items.single;
        expect(event.eventId, 'evt-alias');
        expect(event.activityType, 'RATED');
        expect(event.createdAt, DateTime.parse('2026-05-20T10:00:00Z'));
        expect(event.user.userId, 'user-alias');
        expect(event.user.displayName, 'Usuário');
      },
    );

    test(
      'getFollowers calls followers endpoint and parses relationships',
      () async {
        String? capturedPath;
        Map<String, dynamic>? capturedParams;
        final dio = Dio()
          ..httpClientAdapter = MockAdapter(
            onFetch: (options) {
              capturedPath = options.path;
              capturedParams = options.queryParameters;
              return _jsonBody({
                'items': [_followRelationshipJson()],
                'nextCursor': 'next-followers',
                'hasMore': true,
              });
            },
          );
        final repo = SocialRepositoryImpl(dio);

        final result = await repo.getFollowers(
          'user-2',
          limit: 7,
          cursor: 'cursor-4',
        );

        expect(capturedPath, '/users/user-2/followers');
        expect(capturedParams, {'limit': 7, 'cursor': 'cursor-4'});
        expect(result, isA<PaginatedSocialResponse<FollowRelationshipModel>>());
        expect(result.items.single.userId, 'user-2');
        expect(result.items.single.username, 'maria');
        expect(result.items.single.displayName, 'Maria Souza');
        expect(result.items.single.avatarUrl, 'https://example.com/maria.png');
        expect(result.items.single.isFollowing, isTrue);
        expect(result.nextCursor, 'next-followers');
      },
    );

    test(
      'getFollowing calls following endpoint and parses relationships',
      () async {
        String? capturedPath;
        Map<String, dynamic>? capturedParams;
        final dio = Dio()
          ..httpClientAdapter = MockAdapter(
            onFetch: (options) {
              capturedPath = options.path;
              capturedParams = options.queryParameters;
              return _jsonBody({
                'items': [_followRelationshipJson()],
                'nextCursor': null,
                'hasMore': false,
              });
            },
          );
        final repo = SocialRepositoryImpl(dio);

        final result = await repo.getFollowing(
          'user-1',
          limit: 8,
          cursor: 'cursor-5',
        );

        expect(capturedPath, '/users/user-1/following');
        expect(capturedParams, {'limit': 8, 'cursor': 'cursor-5'});
        expect(result, isA<PaginatedSocialResponse<FollowRelationshipModel>>());
        expect(result.items.single.userId, 'user-2');
        expect(result.items.single.displayName, 'Maria Souza');
      },
    );

    test('getFollowers calls users followers BFF endpoint for me', () async {
      String? capturedPath;
      Map<String, dynamic>? capturedParams;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedPath = options.path;
            capturedParams = options.queryParameters;
            return _jsonBody({
              'items': <Map<String, dynamic>>[],
              'nextCursor': null,
              'hasMore': false,
            });
          },
        );
      final repository = SocialRepositoryImpl(dio);

      final response = await repository.getFollowers('me');

      expect(capturedPath, '/users/me/followers');
      expect(capturedParams, {'limit': 20});
      expect(response.items, isEmpty);
    });

    test(
      'getFollowing calls users following BFF endpoint for public profile',
      () async {
        String? capturedPath;
        Map<String, dynamic>? capturedParams;
        final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
          ..httpClientAdapter = MockAdapter(
            onFetch: (options) {
              capturedPath = options.path;
              capturedParams = options.queryParameters;
              return _jsonBody({
                'items': <Map<String, dynamic>>[],
                'nextCursor': null,
                'hasMore': false,
              });
            },
          );
        final repository = SocialRepositoryImpl(dio);

        final response = await repository.getFollowing('user-1');

        expect(capturedPath, '/users/user-1/following');
        expect(capturedParams, {'limit': 20});
        expect(response.items, isEmpty);
      },
    );

    test(
      'getPublicLists tolerates BFF list items with empty updatedAt',
      () async {
        final dio = Dio()
          ..httpClientAdapter = MockAdapter(
            onFetch: (_) => _jsonBody({
              'items': [
                {
                  ..._publicListItemJson(),
                  'status': 'PLAN_TO_WATCH',
                  'updatedAt': '',
                },
              ],
              'nextCursor': null,
              'hasMore': false,
            }),
          );
        final repo = SocialRepositoryImpl(dio);

        final result = await repo.getPublicLists('user-1');

        expect(result.items.single.status, 'PLAN_TO_WATCH');
        expect(result.items.single.updatedAt, isNull);
      },
    );

    test(
      'getPublicLists normalizes top-level media title and posterUrl',
      () async {
        final dio = Dio()
          ..httpClientAdapter = MockAdapter(
            onFetch: (_) => _jsonBody({
              'items': [
                {
                  'mediaId': '1422',
                  'mediaType': 'SERIES',
                  'status': 'WATCHING',
                  'title': 'The Middle: Uma Família Perdida no Meio do Nada',
                  'posterUrl':
                      'https://image.tmdb.org/t/p/w500/a3hPMvgOe9vOpEEHkuta63AtYnJ.jpg',
                  'rating': 6,
                  'updatedAt': '',
                },
              ],
              'nextCursor': '',
              'hasMore': false,
            }),
          );
        final repo = SocialRepositoryImpl(dio);

        final result = await repo.getPublicLists('user-1');
        final item = result.items.single;

        expect(item.mediaId, '1422');
        expect(item.mediaType, 'SERIES');
        expect(item.status, 'WATCHING');
        expect(item.rating, 6);
        expect(item.updatedAt, isNull);
        expect(item.media?.mediaId, '1422');
        expect(item.media?.mediaType, 'SERIES');
        expect(
          item.media?.title,
          'The Middle: Uma Família Perdida no Meio do Nada',
        );
        expect(
          item.media?.posterUrl,
          'https://image.tmdb.org/t/p/w500/a3hPMvgOe9vOpEEHkuta63AtYnJ.jpg',
        );
      },
    );

    test('getPublicLists calls lists endpoint and parses list items', () async {
      String? capturedPath;
      Map<String, dynamic>? capturedParams;
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (options) {
            capturedPath = options.path;
            capturedParams = options.queryParameters;
            return _jsonBody({
              'items': [_publicListItemJson()],
              'nextCursor': 'next-lists',
              'hasMore': true,
            });
          },
        );
      final repo = SocialRepositoryImpl(dio);

      final result = await repo.getPublicLists(
        'user-1',
        status: 'COMPLETED',
        mediaType: 'MOVIE',
        limit: 9,
        cursor: 'cursor-6',
      );

      expect(capturedPath, '/profiles/user-1/lists');
      expect(capturedParams, {
        'status': 'COMPLETED',
        'mediaType': 'MOVIE',
        'limit': 9,
        'cursor': 'cursor-6',
      });
      expect(result, isA<PaginatedSocialResponse<PublicListItemModel>>());
      expect(result.items.single.mediaId, 'media-1');
      expect(result.nextCursor, 'next-lists');
    });
  });
}
