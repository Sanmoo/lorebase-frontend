import 'dart:math' as math;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/activity_event_model.dart';
import '../data/models/paginated_social_response.dart';
import '../data/models/public_list_item_model.dart';
import '../data/models/social_profile_model.dart';
import '../data/repositories/social_repository.dart';

part 'social_profile_viewmodel.g.dart';

class SocialProfileDetailState {
  final SocialProfileModel profile;
  final PaginatedSocialResponse<ActivityEventModel> activity;
  final PaginatedSocialResponse<PublicListItemModel> publicLists;
  final bool isFollowActionInProgress;
  final Object? activityError;

  const SocialProfileDetailState({
    required this.profile,
    required this.activity,
    required this.publicLists,
    this.isFollowActionInProgress = false,
    this.activityError,
  });

  bool get hasActivityError => activityError != null;

  SocialProfileDetailState copyWith({
    SocialProfileModel? profile,
    PaginatedSocialResponse<ActivityEventModel>? activity,
    PaginatedSocialResponse<PublicListItemModel>? publicLists,
    bool? isFollowActionInProgress,
    Object? activityError = _unchangedActivityError,
  }) {
    return SocialProfileDetailState(
      profile: profile ?? this.profile,
      activity: activity ?? this.activity,
      publicLists: publicLists ?? this.publicLists,
      isFollowActionInProgress:
          isFollowActionInProgress ?? this.isFollowActionInProgress,
      activityError: identical(activityError, _unchangedActivityError)
          ? this.activityError
          : activityError,
    );
  }
}

const Object _unchangedActivityError = Object();

@riverpod
class SocialProfileViewModel extends _$SocialProfileViewModel {
  @override
  Future<SocialProfileDetailState> build(String userId) async {
    final repository = ref.watch(socialRepositoryProvider);
    final profile = userId == 'me'
        ? await repository.getMyProfile()
        : await repository.getProfile(userId);
    final resolvedUserId = profile.userId;
    final (:activity, :activityError) = await _loadUserActivity(
      repository,
      resolvedUserId,
    );

    return SocialProfileDetailState(
      profile: profile,
      activity: activity,
      publicLists: _emptyPublicListsResponse(),
      activityError: activityError,
    );
  }

  Future<
    ({
      PaginatedSocialResponse<ActivityEventModel> activity,
      Object? activityError,
    })
  >
  _loadUserActivity(SocialRepository repository, String resolvedUserId) async {
    try {
      return (
        activity: await repository.getUserActivity(resolvedUserId),
        activityError: null,
      );
    } on Exception catch (error) {
      return (activity: _emptyActivityResponse(), activityError: error);
    }
  }

  Future<void> follow() async {
    final latest = _latestValue();
    if (latest == null ||
        latest.isFollowActionInProgress ||
        latest.profile.isFollowedByMe) {
      return;
    }

    _setFollowActionInProgress(true);
    try {
      await ref.read(socialRepositoryProvider).followUser(userId);
      _updateProfile(
        (profile) => profile.copyWith(
          isFollowedByMe: true,
          followerCount: profile.followerCount + 1,
        ),
      );
    } finally {
      _setFollowActionInProgress(false);
    }
  }

  Future<void> unfollow() async {
    final latest = _latestValue();
    if (latest == null ||
        latest.isFollowActionInProgress ||
        !latest.profile.isFollowedByMe) {
      return;
    }

    _setFollowActionInProgress(true);
    try {
      await ref.read(socialRepositoryProvider).unfollowUser(userId);
      _updateProfile(
        (profile) => profile.copyWith(
          isFollowedByMe: false,
          followerCount: math.max(0, profile.followerCount - 1),
        ),
      );
    } finally {
      _setFollowActionInProgress(false);
    }
  }

  void _updateProfile(SocialProfileModel Function(SocialProfileModel) update) {
    final latest = _latestValue();
    // coverage:ignore-start
    if (latest == null) {
      return;
    }
    // coverage:ignore-end
    state = AsyncData(latest.copyWith(profile: update(latest.profile)));
  }

  void _setFollowActionInProgress(bool isInProgress) {
    final latest = _latestValue();
    // coverage:ignore-start
    if (latest == null) {
      return;
    }
    // coverage:ignore-end
    state = AsyncData(latest.copyWith(isFollowActionInProgress: isInProgress));
  }

  SocialProfileDetailState? _latestValue() {
    return switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };
  }
}

PaginatedSocialResponse<ActivityEventModel> _emptyActivityResponse() {
  return const PaginatedSocialResponse(
    items: [],
    nextCursor: null,
    hasMore: false,
  );
}

PaginatedSocialResponse<PublicListItemModel> _emptyPublicListsResponse() {
  return const PaginatedSocialResponse(
    items: [],
    nextCursor: null,
    hasMore: false,
  );
}
