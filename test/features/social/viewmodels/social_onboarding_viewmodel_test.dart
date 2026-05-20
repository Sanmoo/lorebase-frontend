import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/data/models/activity_event_model.dart';
import 'package:lorebase/features/social/data/models/discover_user_model.dart';
import 'package:lorebase/features/social/data/models/follow_relationship_model.dart';
import 'package:lorebase/features/social/data/models/paginated_social_response.dart';
import 'package:lorebase/features/social/data/models/public_list_item_model.dart';
import 'package:lorebase/features/social/data/models/social_profile_model.dart';
import 'package:lorebase/features/social/data/models/social_privacy.dart';
import 'package:lorebase/features/social/data/repositories/social_repository.dart';
import 'package:lorebase/features/social/viewmodels/social_onboarding_viewmodel.dart';

void main() {
  test(
    'saveProfile sends displayName, avatarUrl, and privacy.isPublic',
    () async {
      final repo = _FakeSocialRepository();
      final container = ProviderContainer(
        overrides: [socialRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container
          .read(socialOnboardingViewModelProvider.notifier)
          .saveProfile(
            displayName: 'Fulano',
            avatarUrl: 'https://example.com/a.jpg',
            privacy: SocialPrivacy.public,
          );

      expect(repo.updateMyProfileCalls, 1);
      expect(repo.lastDisplayName, 'Fulano');
      expect(repo.lastAvatarUrl, 'https://example.com/a.jpg');
      expect(repo.lastIsPublic, isTrue);
      expect(
        container.read(socialOnboardingViewModelProvider).profile,
        repo.profile.copyWith(avatarUrl: 'https://example.com/a.jpg'),
      );
    },
  );

  test(
    'repository failure resets saving and exposes error message',
    () async {
      final repo = _FakeSocialRepository(updateError: Exception('boom'));
      final container = ProviderContainer(
        overrides: [socialRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container
          .read(socialOnboardingViewModelProvider.notifier)
          .saveProfile(
            displayName: 'Fulano',
            avatarUrl: null,
            privacy: SocialPrivacy.private,
          );

      final state = container.read(socialOnboardingViewModelProvider);
      expect(repo.updateMyProfileCalls, 1);
      expect(state.isSaving, isFalse);
      expect(state.errorMessage, 'Failed to save profile');
      expect(state.validationError, isNull);
    },
  );

  test(
    'blank displayName sets validation error and does not call repository',
    () async {
      final repo = _FakeSocialRepository(updateError: Exception('boom'));
      final container = ProviderContainer(
        overrides: [socialRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container
          .read(socialOnboardingViewModelProvider.notifier)
          .saveProfile(
            displayName: '   ',
            avatarUrl: null,
            privacy: SocialPrivacy.private,
          );

      final state = container.read(socialOnboardingViewModelProvider);
      expect(state.validationError, 'Display name is required');
      expect(repo.updateMyProfileCalls, 0);
    },
  );
}

class _FakeSocialRepository implements SocialRepository {
  _FakeSocialRepository({this.updateError});

  final Object? updateError;
  int updateMyProfileCalls = 0;
  String? lastDisplayName;
  String? lastAvatarUrl;
  bool? lastIsPublic;
  final profile = _profile();

  @override
  Future<SocialProfileModel> updateMyProfile({
    required String displayName,
    String? avatarUrl,
    required bool isPublic,
  }) async {
    updateMyProfileCalls++;
    if (updateError != null) {
      throw updateError!;
    }
    lastDisplayName = displayName;
    lastAvatarUrl = avatarUrl;
    lastIsPublic = isPublic;
    return profile.copyWith(
      displayName: displayName,
      avatarUrl: avatarUrl,
      isPublic: isPublic,
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
  Future<void> unfollowUser(String userId) => throw UnimplementedError();
}

SocialProfileModel _profile() => SocialProfileModel(
  userId: 'user-1',
  displayName: 'Fulano',
  isPublic: true,
  followingCount: 0,
  followerCount: 0,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);
