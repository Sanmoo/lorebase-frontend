import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/data/models/activity_event_model.dart';
import 'package:lorebase/features/social/data/models/discover_user_model.dart';
import 'package:lorebase/features/social/data/models/follow_relationship_model.dart';
import 'package:lorebase/features/social/data/models/paginated_social_response.dart';
import 'package:lorebase/features/social/data/models/public_list_item_model.dart';
import 'package:lorebase/features/social/data/models/social_profile_model.dart';
import 'package:lorebase/features/social/data/repositories/social_repository.dart';
import 'package:lorebase/features/social/viewmodels/social_follow_list_viewmodel.dart';

void main() {
  test('followers mode calls getFollowers', () async {
    final repo = _FakeSocialRepository();
    final container = ProviderContainer(
      overrides: [socialRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    await container.read(
      socialFollowListViewModelProvider(
        'user-1',
        SocialFollowListKind.followers,
      ).future,
    );
    expect(repo.followersCalls, ['user-1']);
    expect(repo.followingCalls, isEmpty);
  });

  test('following mode calls getFollowing', () async {
    final repo = _FakeSocialRepository();
    final container = ProviderContainer(
      overrides: [socialRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    await container.read(
      socialFollowListViewModelProvider(
        'user-1',
        SocialFollowListKind.following,
      ).future,
    );
    expect(repo.followingCalls, ['user-1']);
    expect(repo.followersCalls, isEmpty);
  });
}

class _FakeSocialRepository implements SocialRepository {
  final followersCalls = <String>[];
  final followingCalls = <String>[];
  @override
  Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowers(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async {
    followersCalls.add(userId);
    return const PaginatedSocialResponse(
      items: [],
      nextCursor: null,
      hasMore: false,
    );
  }

  @override
  Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowing(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async {
    followingCalls.add(userId);
    return const PaginatedSocialResponse(
      items: [],
      nextCursor: null,
      hasMore: false,
    );
  }

  @override
  Future<PaginatedSocialResponse<DiscoverUserModel>> discoverUsers({
    int limit = 20,
    String? cursor,
  }) => throw UnimplementedError();
  @override
  Future<void> followUser(String userId) => throw UnimplementedError();
  @override
  Future<PaginatedSocialResponse<ActivityEventModel>> getFeed({
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
  Future<void> unfollowUser(String userId) => throw UnimplementedError();
  @override
  Future<SocialProfileModel> updateMyProfile({
    required String displayName,
    String? avatarUrl,
    required bool isPublic,
  }) => throw UnimplementedError();
}
