import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/data/models/activity_event_model.dart';
import 'package:lorebase/features/social/data/models/discover_user_model.dart';
import 'package:lorebase/features/social/data/models/follow_relationship_model.dart';
import 'package:lorebase/features/social/data/models/paginated_social_response.dart';
import 'package:lorebase/features/social/data/models/public_list_item_model.dart';
import 'package:lorebase/features/social/data/models/social_profile_model.dart';

void main() {
  group('social models', () {
    test('parses a social profile', () {
      final profile = SocialProfileModel.fromJson({
        'userId': 'user-1',
        'displayName': 'Fulano',
        'avatarUrl': 'https://example.com/a.jpg',
        'isPublic': true,
        'followingCount': 3,
        'followerCount': 7,
        'isFollowedByMe': false,
        'createdAt': '2026-05-20T10:00:00Z',
        'updatedAt': '2026-05-20T11:00:00Z',
      });

      expect(profile.userId, 'user-1');
      expect(profile.displayName, 'Fulano');
      expect(profile.avatarUrl, 'https://example.com/a.jpg');
      expect(profile.isPublic, isTrue);
      expect(profile.followerCount, 7);
    });

    test('allows nullable profile avatar URL', () {
      final profile = SocialProfileModel.fromJson({
        'userId': 'user-1',
        'displayName': 'Fulano',
        'avatarUrl': null,
        'isPublic': true,
        'followingCount': 3,
        'followerCount': 7,
        'isFollowedByMe': false,
        'createdAt': '2026-05-20T10:00:00Z',
        'updatedAt': '2026-05-20T11:00:00Z',
      });

      expect(profile.avatarUrl, isNull);
    });

    test('parses enriched activity event', () {
      final event = ActivityEventModel.fromJson({
        'eventId': 'evt-1',
        'user': {
          'userId': 'user-1',
          'displayName': 'Fulano',
          'avatarUrl': null,
        },
        'activityType': 'RATED',
        'media': {
          'mediaId': '1399',
          'mediaType': 'SERIES',
          'title': 'Game of Thrones',
          'posterUrl': 'https://example.com/p.jpg',
        },
        'metadata': {'rating': 8},
        'createdAt': '2026-05-20T10:00:00Z',
      });

      expect(event.eventId, 'evt-1');
      expect(event.user.displayName, 'Fulano');
      expect(event.user.avatarUrl, isNull);
      expect(event.media.mediaType, 'SERIES');
      expect(event.metadata['rating'], 8);
    });

    test('defaults activity metadata to empty map when omitted', () {
      final event = ActivityEventModel.fromJson({
        'eventId': 'evt-1',
        'user': {'userId': 'user-1', 'displayName': 'Fulano'},
        'activityType': 'COMPLETED',
        'media': {'mediaId': '1', 'mediaType': 'MOVIE', 'title': 'Movie'},
        'createdAt': '2026-05-20T10:00:00Z',
      });

      expect(event.metadata, isEmpty);
    });

    test('parses discover user with common media', () {
      final user = DiscoverUserModel.fromJson({
        'userId': 'user-2',
        'displayName': 'Maria',
        'avatarUrl': '',
        'affinityScore': 0.82,
        'commonGenres': ['Anime', 'Drama'],
        'commonMedia': [
          {
            'mediaId': '37854',
            'mediaType': 'SERIES',
            'title': 'One Piece',
            'posterUrl': null,
          },
        ],
        'isFollowedByMe': false,
      });

      expect(user.affinityScore, 0.82);
      expect(user.commonGenres, ['Anime', 'Drama']);
      expect(user.commonMedia.single.title, 'One Piece');
      expect(user.commonMedia.single.posterUrl, isNull);
      expect(user.isFollowedByMe, isFalse);
    });

    test('parses follow relationship', () {
      final relationship = FollowRelationshipModel.fromJson({
        'followerId': 'user-1',
        'followedId': 'user-2',
        'followedAt': '2026-05-20T10:00:00Z',
      });

      expect(relationship.followerId, 'user-1');
      expect(relationship.followedId, 'user-2');
      expect(
        relationship.followedAt,
        DateTime.parse('2026-05-20T10:00:00Z'),
      );
    });

    test('parses public list item', () {
      final item = PublicListItemModel.fromJson({
        'mediaId': '1399',
        'mediaType': 'SERIES',
        'status': 'COMPLETED',
        'rating': 9,
        'review': 'Winter came.',
        'media': {
          'mediaId': '1399',
          'mediaType': 'SERIES',
          'title': 'Game of Thrones',
          'posterUrl': null,
        },
        'updatedAt': '2026-05-20T11:00:00Z',
      });

      expect(item.mediaId, '1399');
      expect(item.mediaType, 'SERIES');
      expect(item.status, 'COMPLETED');
      expect(item.rating, 9);
      expect(item.review, 'Winter came.');
      expect(item.media?.title, 'Game of Thrones');
      expect(item.media?.posterUrl, isNull);
      expect(item.updatedAt, DateTime.parse('2026-05-20T11:00:00Z'));
    });

    test('parses paginated response', () {
      final response = PaginatedSocialResponse<ActivityEventModel>.fromJson({
        'items': [
          {
            'eventId': 'evt-1',
            'user': {'userId': 'user-1', 'displayName': 'Fulano'},
            'activityType': 'COMPLETED',
            'media': {'mediaId': '1', 'mediaType': 'MOVIE', 'title': 'Movie'},
            'metadata': {},
            'createdAt': '2026-05-20T10:00:00Z',
          },
        ],
        'nextCursor': 'next',
        'hasMore': true,
      }, ActivityEventModel.fromJson);

      expect(response.items, hasLength(1));
      expect(response.nextCursor, 'next');
      expect(response.hasMore, isTrue);
    });
  });
}
