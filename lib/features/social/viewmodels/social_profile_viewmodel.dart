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

  const SocialProfileDetailState({
    required this.profile,
    required this.activity,
    required this.publicLists,
  });

  SocialProfileDetailState copyWith({
    SocialProfileModel? profile,
    PaginatedSocialResponse<ActivityEventModel>? activity,
    PaginatedSocialResponse<PublicListItemModel>? publicLists,
  }) {
    return SocialProfileDetailState(
      profile: profile ?? this.profile,
      activity: activity ?? this.activity,
      publicLists: publicLists ?? this.publicLists,
    );
  }
}

@riverpod
class SocialProfileViewModel extends _$SocialProfileViewModel {
  @override
  Future<SocialProfileDetailState> build(String userId) async {
    final repository = ref.watch(socialRepositoryProvider);
    final (profile, activity, publicLists) = await (
      repository.getProfile(userId),
      repository.getUserActivity(userId),
      repository.getPublicLists(userId),
    ).wait;

    return SocialProfileDetailState(
      profile: profile,
      activity: activity,
      publicLists: publicLists,
    );
  }

  Future<void> follow() async {
    await ref.read(socialRepositoryProvider).followUser(userId);
    _updateProfile(
      (profile) => profile.copyWith(
        isFollowedByMe: true,
        followerCount: profile.followerCount + 1,
      ),
    );
  }

  Future<void> unfollow() async {
    await ref.read(socialRepositoryProvider).unfollowUser(userId);
    _updateProfile(
      (profile) => profile.copyWith(
        isFollowedByMe: false,
        followerCount: math.max(0, profile.followerCount - 1),
      ),
    );
  }

  void _updateProfile(SocialProfileModel Function(SocialProfileModel) update) {
    final latest = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (latest == null) {
      return;
    }
    state = AsyncData(latest.copyWith(profile: update(latest.profile)));
  }
}
