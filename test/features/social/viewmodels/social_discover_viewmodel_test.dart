import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/errors/exceptions.dart';
import 'package:lorebase/features/social/data/models/activity_event_model.dart';
import 'package:lorebase/features/social/data/models/discover_user_model.dart';
import 'package:lorebase/features/social/data/models/follow_relationship_model.dart';
import 'package:lorebase/features/social/data/models/paginated_social_response.dart';
import 'package:lorebase/features/social/data/models/public_list_item_model.dart';
import 'package:lorebase/features/social/data/models/social_profile_model.dart';
import 'package:lorebase/features/social/data/repositories/social_repository.dart';
import 'package:lorebase/features/social/viewmodels/social_discover_viewmodel.dart';

class _FakeSocialRepository implements SocialRepository {
  PaginatedSocialResponse<DiscoverUserModel>? discover;
  Object? followError;
  int discoverCalls = 0;
  final followedUserIds = <String>[];

  @override
  Future<PaginatedSocialResponse<DiscoverUserModel>> discoverUsers({
    int limit = 20,
    String? cursor,
  }) async {
    discoverCalls++;
    return discover ?? _discoverResponse(isFollowed: false);
  }

  @override
  Future<void> followUser(String userId) async {
    followedUserIds.add(userId);
    final error = followError;
    if (error != null) throw error;
  }

  @override
  Future<PaginatedSocialResponse<ActivityEventModel>> getFeed({
    int limit = 20,
    String? cursor,
  }) => throw UnimplementedError();

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
  group('SocialDiscoverViewModel', () {
    test('build loads discoverUsers', () async {
      final repo = _FakeSocialRepository()
        ..discover = _discoverResponse(isFollowed: false);
      final container = _container(repo);
      addTearDown(container.dispose);

      final state = await container.read(socialDiscoverViewModelProvider.future);

      expect(repo.discoverCalls, 1);
      expect(state.items.single.userId, 'user-1');
    });

    test('refresh reloads and replaces items', () async {
      final repo = _FakeSocialRepository()
        ..discover = _discoverResponse(isFollowed: false, userId: 'user-1');
      final container = _container(repo);
      addTearDown(container.dispose);
      await container.read(socialDiscoverViewModelProvider.future);

      repo.discover = _discoverResponse(isFollowed: false, userId: 'user-2');
      await container.read(socialDiscoverViewModelProvider.notifier).refresh();

      final state = container.read(socialDiscoverViewModelProvider);
      expect(repo.discoverCalls, 2);
      expect(state.value!.items.single.userId, 'user-2');
    });

    test('followUser calls repository and marks the user as followed', () async {
      final repo = _FakeSocialRepository()
        ..discover = _discoverResponse(isFollowed: false);
      final container = _container(repo);
      addTearDown(container.dispose);
      await container.read(socialDiscoverViewModelProvider.future);

      await container.read(socialDiscoverViewModelProvider.notifier).followUser(
            'user-1',
          );

      final state = container.read(socialDiscoverViewModelProvider).value!;
      expect(repo.followedUserIds, ['user-1']);
      expect(state.items.single.isFollowedByMe, true);
      expect(state.nextCursor, 'next');
      expect(state.hasMore, true);
    });

    test('non-conflict ServerException propagates without mutating state',
        () async {
      final repo = _FakeSocialRepository()
        ..discover = _discoverResponse(isFollowed: false)
        ..followError = const ServerException(
          message: 'Server failed',
          statusCode: 500,
        );
      final container = _container(repo);
      addTearDown(container.dispose);
      await container.read(socialDiscoverViewModelProvider.future);

      expect(
        () => container
            .read(socialDiscoverViewModelProvider.notifier)
            .followUser('user-1'),
        throwsA(isA<ServerException>()),
      );

      final state = container.read(socialDiscoverViewModelProvider).value!;
      expect(repo.followedUserIds, ['user-1']);
      expect(state.items.single.isFollowedByMe, false);
    });

    test('follow conflict with ServerException statusCode 409 marks followed',
        () async {
      final repo = _FakeSocialRepository()
        ..discover = _discoverResponse(isFollowed: false)
        ..followError = const ServerException(
          message: 'Already following',
          statusCode: 409,
        );
      final container = _container(repo);
      addTearDown(container.dispose);
      await container.read(socialDiscoverViewModelProvider.future);

      await container.read(socialDiscoverViewModelProvider.notifier).followUser(
            'user-1',
          );

      expect(
        container
            .read(socialDiscoverViewModelProvider)
            .value!
            .items
            .single
            .isFollowedByMe,
        true,
      );
    });
  });
}

ProviderContainer _container(_FakeSocialRepository repo) {
  return ProviderContainer(
    overrides: [socialRepositoryProvider.overrideWith((ref) => repo)],
  );
}

PaginatedSocialResponse<DiscoverUserModel> _discoverResponse({
  required bool isFollowed,
  String userId = 'user-1',
}) {
  return PaginatedSocialResponse<DiscoverUserModel>(
    items: [
      DiscoverUserModel(
        userId: userId,
        displayName: 'User 1',
        affinityScore: 0.9,
        isFollowedByMe: isFollowed,
      ),
    ],
    nextCursor: 'next',
    hasMore: true,
  );
}
