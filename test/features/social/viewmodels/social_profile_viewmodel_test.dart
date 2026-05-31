import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/data/models/activity_event_model.dart';
import 'package:lorebase/features/social/data/models/avatar_upload_file.dart';
import 'package:lorebase/features/social/data/models/discover_user_model.dart';
import 'package:lorebase/features/social/data/models/follow_relationship_model.dart';
import 'package:lorebase/features/social/data/models/paginated_social_response.dart';
import 'package:lorebase/features/social/data/models/public_list_item_model.dart';
import 'package:lorebase/features/social/data/models/social_profile_model.dart';
import 'package:lorebase/features/social/data/repositories/social_repository.dart';
import 'package:lorebase/features/social/viewmodels/social_profile_viewmodel.dart';

void main() {
  group('SocialProfileDetailState.copyWith', () {
    test('preserves existing activityError when omitted', () {
      final error = Exception('existing');
      final state = _detailState(activityError: error);

      final updated = state.copyWith(isFollowActionInProgress: true);

      expect(updated.activityError, same(error));
      expect(updated.hasActivityError, isTrue);
    });

    test('clears existing activityError when set to null', () {
      final state = _detailState(activityError: Exception('existing'));

      final updated = state.copyWith(activityError: null);

      expect(updated.activityError, isNull);
      expect(updated.hasActivityError, isFalse);
    });

    test('replaces existing activityError with new error', () {
      final newError = Exception('new');
      final state = _detailState(activityError: Exception('existing'));

      final updated = state.copyWith(activityError: newError);

      expect(updated.activityError, same(newError));
      expect(updated.hasActivityError, isTrue);
    });
  });

  test('build loads profile and activity for userId', () async {
    final repo = _FakeSocialRepository();
    final container = ProviderContainer(
      overrides: [socialRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final state = await container.read(
      socialProfileViewModelProvider('user-1').future,
    );

    expect(state.profile.userId, 'user-1');
    expect(state.activity.items.single.eventId, 'evt-1');
    expect(state.publicLists.items, isEmpty);
    expect(repo.profileUserIds, ['user-1']);
    expect(repo.activityUserIds, ['user-1']);
    expect(repo.publicListUserIds, isEmpty);
  });

  test(
    'build loads me profile endpoint and uses resolved userId for details',
    () async {
      final repo = _FakeSocialRepository(myProfileUserId: 'current-user');
      final container = ProviderContainer(
        overrides: [socialRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final state = await container.read(
        socialProfileViewModelProvider('me').future,
      );

      expect(state.profile.userId, 'current-user');
      expect(repo.myProfileCalls, 1);
      expect(repo.profileUserIds, isEmpty);
      expect(repo.activityUserIds, ['current-user']);
      expect(repo.publicListUserIds, isEmpty);
    },
  );

  test(
    'build keeps profile and exposes activity error when user activity fails',
    () async {
      final error = Exception('boom');
      final repo = _FakeSocialRepository(activityError: error);
      final container = ProviderContainer(
        overrides: [socialRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final state = await container.read(
        socialProfileViewModelProvider('user-1').future,
      );

      expect(state.profile.userId, 'user-1');
      expect(state.activity.items, isEmpty);
      expect(state.activity.nextCursor, isNull);
      expect(state.activity.hasMore, isFalse);
      expect(state.activityError, same(error));
      expect(state.activityError, isA<Exception>());
      expect(state.hasActivityError, isTrue);
      expect(state.publicLists.items, isEmpty);
    },
  );

  test('build propagates unexpected activity Error', () async {
    final repo = _FakeSocialRepository(activityError: TypeError());
    final container = ProviderContainer(
      overrides: [socialRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(socialProfileViewModelProvider('user-1').future),
      throwsA(isA<TypeError>()),
    );
  });

  test('build has no activity error when user activity loads', () async {
    final repo = _FakeSocialRepository();
    final container = ProviderContainer(
      overrides: [socialRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final state = await container.read(
      socialProfileViewModelProvider('user-1').future,
    );

    expect(state.activityError, isNull);
    expect(state.hasActivityError, isFalse);
  });

  test(
    'follow and unfollow while loading leave loading state intact',
    () async {
      final repo = _FakeSocialRepository();
      final container = ProviderContainer(
        overrides: [socialRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(
        socialProfileViewModelProvider('user-1').notifier,
      );

      await notifier.follow();
      await notifier.unfollow();

      expect(repo.followCalls, isEmpty);
      expect(repo.unfollowCalls, isEmpty);
    },
  );

  test(
    'follow toggles profile followed and increments followerCount',
    () async {
      final repo = _FakeSocialRepository();
      final container = ProviderContainer(
        overrides: [socialRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      await container.read(socialProfileViewModelProvider('user-1').future);

      await container
          .read(socialProfileViewModelProvider('user-1').notifier)
          .follow();

      final state = container
          .read(socialProfileViewModelProvider('user-1'))
          .value!;
      expect(repo.followCalls, ['user-1']);
      expect(state.profile.isFollowedByMe, isTrue);
      expect(state.profile.followerCount, 3);
    },
  );

  test('follow is idempotent when already followed', () async {
    final repo = _FakeSocialRepository(initiallyFollowed: true);
    final container = ProviderContainer(
      overrides: [socialRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    await container.read(socialProfileViewModelProvider('user-1').future);

    await container
        .read(socialProfileViewModelProvider('user-1').notifier)
        .follow();

    final state = container
        .read(socialProfileViewModelProvider('user-1'))
        .value!;
    expect(repo.followCalls, isEmpty);
    expect(state.profile.isFollowedByMe, isTrue);
    expect(state.profile.followerCount, 2);
  });

  test(
    'duplicate in-flight follow calls are ignored and count increments once',
    () async {
      final repo = _FakeSocialRepository(followCompleter: Completer<void>());
      final container = ProviderContainer(
        overrides: [socialRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      await container.read(socialProfileViewModelProvider('user-1').future);

      final notifier = container.read(
        socialProfileViewModelProvider('user-1').notifier,
      );
      final first = notifier.follow();
      await notifier.follow();

      repo.followCompleter!.complete();
      await first;

      final state = container
          .read(socialProfileViewModelProvider('user-1'))
          .value!;
      expect(repo.followCalls, ['user-1']);
      expect(state.isFollowActionInProgress, isFalse);
      expect(state.profile.isFollowedByMe, isTrue);
      expect(state.profile.followerCount, 3);
    },
  );

  test(
    'follow failure resets in-progress state without drifting count',
    () async {
      final repo = _FakeSocialRepository(followError: Exception('boom'));
      final container = ProviderContainer(
        overrides: [socialRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      await container.read(socialProfileViewModelProvider('user-1').future);

      await expectLater(
        container
            .read(socialProfileViewModelProvider('user-1').notifier)
            .follow(),
        throwsA(isA<Exception>()),
      );

      final state = container
          .read(socialProfileViewModelProvider('user-1'))
          .value!;
      expect(state.isFollowActionInProgress, isFalse);
      expect(state.profile.isFollowedByMe, isFalse);
      expect(state.profile.followerCount, 2);
    },
  );

  test(
    'unfollow toggles false and decrements without going below zero',
    () async {
      final repo = _FakeSocialRepository(
        initialFollowerCount: 0,
        initiallyFollowed: true,
      );
      final container = ProviderContainer(
        overrides: [socialRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      await container.read(socialProfileViewModelProvider('user-1').future);

      await container
          .read(socialProfileViewModelProvider('user-1').notifier)
          .unfollow();

      final state = container
          .read(socialProfileViewModelProvider('user-1'))
          .value!;
      expect(repo.unfollowCalls, ['user-1']);
      expect(state.profile.isFollowedByMe, isFalse);
      expect(state.profile.followerCount, 0);
    },
  );

  test('unfollow is idempotent when already not followed', () async {
    final repo = _FakeSocialRepository(initiallyFollowed: false);
    final container = ProviderContainer(
      overrides: [socialRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    await container.read(socialProfileViewModelProvider('user-1').future);

    await container
        .read(socialProfileViewModelProvider('user-1').notifier)
        .unfollow();

    final state = container
        .read(socialProfileViewModelProvider('user-1'))
        .value!;
    expect(repo.unfollowCalls, isEmpty);
    expect(state.profile.isFollowedByMe, isFalse);
    expect(state.profile.followerCount, 2);
  });
}

class _FakeSocialRepository implements SocialRepository {
  @override
  Future<SocialProfileModel> updateMyAvatar({required AvatarUploadFile file}) {
    throw UnimplementedError();
  }

  _FakeSocialRepository({
    this.initialFollowerCount = 2,
    this.initiallyFollowed = false,
    this.followCompleter,
    this.followError,
    this.activityError,
    this.myProfileUserId = 'me',
  });
  final int initialFollowerCount;
  final bool initiallyFollowed;
  final Completer<void>? followCompleter;
  final Object? followError;
  final Object? activityError;
  final String myProfileUserId;
  var myProfileCalls = 0;
  final profileUserIds = <String>[];
  final activityUserIds = <String>[];
  final publicListUserIds = <String>[];
  final followCalls = <String>[];
  final unfollowCalls = <String>[];

  @override
  Future<SocialProfileModel> getProfile(String userId) async {
    profileUserIds.add(userId);
    return SocialProfileModel(
      userId: userId,
      displayName: 'Fulano',
      isPublic: true,
      followingCount: 1,
      followerCount: initialFollowerCount,
      isFollowedByMe: initiallyFollowed,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  @override
  Future<PaginatedSocialResponse<ActivityEventModel>> getUserActivity(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async {
    activityUserIds.add(userId);
    if (activityError != null) {
      throw activityError!;
    }
    return PaginatedSocialResponse(
      items: [_activity()],
      nextCursor: null,
      hasMore: false,
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
    publicListUserIds.add(userId);
    return const PaginatedSocialResponse(
      items: [
        PublicListItemModel(
          mediaId: 'media-1',
          mediaType: 'SERIES',
          status: 'WATCHING',
        ),
      ],
      nextCursor: null,
      hasMore: false,
    );
  }

  @override
  Future<void> followUser(String userId) async {
    followCalls.add(userId);
    if (followError != null) {
      throw followError!;
    }
    if (followCompleter != null) {
      await followCompleter!.future;
    }
  }

  @override
  Future<void> unfollowUser(String userId) async {
    unfollowCalls.add(userId);
  }

  @override
  Future<PaginatedSocialResponse<DiscoverUserModel>> discoverUsers({
    int limit = 20,
    String? cursor,
  }) => throw UnimplementedError();
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
  Future<SocialProfileModel> getMyProfile() async {
    myProfileCalls += 1;
    return SocialProfileModel(
      userId: myProfileUserId,
      displayName: 'Fulano',
      isPublic: true,
      followingCount: 1,
      followerCount: initialFollowerCount,
      isFollowedByMe: initiallyFollowed,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  @override
  Future<SocialProfileModel> updateMyProfile({
    required String displayName,
    String? avatarUrl,
    required bool isPublic,
  }) => throw UnimplementedError();
}

SocialProfileDetailState _detailState({Object? activityError}) {
  return SocialProfileDetailState(
    profile: SocialProfileModel(
      userId: 'user-1',
      displayName: 'Fulano',
      isPublic: true,
      followingCount: 1,
      followerCount: 2,
      isFollowedByMe: false,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
    activity: const PaginatedSocialResponse(
      items: [],
      nextCursor: null,
      hasMore: false,
    ),
    publicLists: const PaginatedSocialResponse(
      items: [],
      nextCursor: null,
      hasMore: false,
    ),
    activityError: activityError,
  );
}

ActivityEventModel _activity() => ActivityEventModel.fromJson(<String, dynamic>{
  'eventId': 'evt-1',
  'user': <String, dynamic>{'userId': 'user-1', 'displayName': 'Fulano'},
  'activityType': 'RATED',
  'media': <String, dynamic>{
    'mediaId': '1',
    'mediaType': 'SERIES',
    'title': 'Show',
  },
  'metadata': <String, dynamic>{},
  'createdAt': '2026-05-20T10:00:00Z',
});
