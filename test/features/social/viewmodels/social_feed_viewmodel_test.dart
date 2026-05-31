import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/data/models/activity_event_model.dart';
import 'package:lorebase/features/social/data/models/avatar_upload_file.dart';
import 'package:lorebase/features/social/data/models/discover_user_model.dart';
import 'package:lorebase/features/social/data/models/follow_relationship_model.dart';
import 'package:lorebase/features/social/data/models/paginated_social_response.dart';
import 'package:lorebase/features/social/data/models/public_list_item_model.dart';
import 'package:lorebase/features/social/data/models/social_media_model.dart';
import 'package:lorebase/features/social/data/models/social_profile_model.dart';
import 'package:lorebase/features/social/data/models/social_user_model.dart';
import 'package:lorebase/features/social/data/repositories/social_repository.dart';
import 'package:lorebase/features/social/viewmodels/social_feed_viewmodel.dart';

class _FakeSocialRepository implements SocialRepository {
  @override
  Future<SocialProfileModel> updateMyAvatar({required AvatarUploadFile file}) {
    throw UnimplementedError();
  }

  PaginatedSocialResponse<ActivityEventModel>? feed;
  Object? feedError;
  int getFeedCalls = 0;

  @override
  Future<PaginatedSocialResponse<ActivityEventModel>> getFeed({
    int limit = 20,
    String? cursor,
  }) async {
    getFeedCalls++;
    final error = feedError;
    if (error != null) throw error;
    return feed ?? _feedResponse('first');
  }

  @override
  Future<PaginatedSocialResponse<DiscoverUserModel>> discoverUsers({
    int limit = 20,
    String? cursor,
  }) => throw UnimplementedError();

  @override
  Future<void> followUser(String userId) => throw UnimplementedError();

  @override
  Future<void> unfollowUser(String userId) => throw UnimplementedError();

  @override
  Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowers(
    String userId, {
    int limit = 20,
    String? cursor,
  }) => throw UnimplementedError();

  @override
  Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowing(
    String userId, {
    int limit = 20,
    String? cursor,
  }) => throw UnimplementedError();

  @override
  Future<SocialProfileModel> getMyProfile() => throw UnimplementedError();

  @override
  Future<SocialProfileModel> getProfile(String userId) =>
      throw UnimplementedError();

  @override
  Future<PaginatedSocialResponse<PublicListItemModel>> getPublicLists(
    String userId, {
    String? status,
    String? mediaType,
    int limit = 20,
    String? cursor,
  }) => throw UnimplementedError();

  @override
  Future<PaginatedSocialResponse<ActivityEventModel>> getUserActivity(
    String userId, {
    int limit = 20,
    String? cursor,
  }) => throw UnimplementedError();

  @override
  Future<SocialProfileModel> updateMyProfile({
    required String displayName,
    String? avatarUrl,
    required bool isPublic,
  }) => throw UnimplementedError();
}

void main() {
  group('SocialFeedViewModel', () {
    test('build loads first page from getFeed', () async {
      final repo = _FakeSocialRepository()..feed = _feedResponse('event-1');
      final container = _container(repo);
      addTearDown(container.dispose);

      final state = await container.read(socialFeedViewModelProvider.future);

      expect(repo.getFeedCalls, 1);
      expect(state.items.single.eventId, 'event-1');
    });

    test('refresh reloads and replaces items', () async {
      final repo = _FakeSocialRepository()..feed = _feedResponse('event-1');
      final container = _container(repo);
      addTearDown(container.dispose);
      await container.read(socialFeedViewModelProvider.future);

      repo.feed = _feedResponse('event-2');
      await container.read(socialFeedViewModelProvider.notifier).refresh();

      final state = container.read(socialFeedViewModelProvider);
      expect(repo.getFeedCalls, 2);
      expect(state.value!.items.single.eventId, 'event-2');
    });

    test('failed load exposes AsyncError', () async {
      final repo = _FakeSocialRepository()..feedError = Exception('failed');
      final container = _container(repo);
      addTearDown(container.dispose);

      final subscription = container.listen(
        socialFeedViewModelProvider,
        (previous, next) {},
      );

      await Future<void>.delayed(Duration.zero);

      expect(container.read(socialFeedViewModelProvider).hasError, true);
      subscription.close();
    });
  });
}

ProviderContainer _container(_FakeSocialRepository repo) {
  return ProviderContainer(
    overrides: [socialRepositoryProvider.overrideWith((ref) => repo)],
  );
}

PaginatedSocialResponse<ActivityEventModel> _feedResponse(String id) {
  return PaginatedSocialResponse<ActivityEventModel>(
    items: [
      ActivityEventModel(
        eventId: id,
        user: const SocialUserModel(userId: 'user-1', displayName: 'User 1'),
        activityType: 'completed',
        media: const SocialMediaModel(
          mediaId: 'media-1',
          mediaType: 'series',
          title: 'Series',
        ),
        createdAt: DateTime.utc(2026),
      ),
    ],
    nextCursor: 'next',
    hasMore: true,
  );
}
