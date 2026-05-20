import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/follow_relationship_model.dart';
import '../data/models/paginated_social_response.dart';
import '../data/repositories/social_repository.dart';

part 'social_follow_list_viewmodel.g.dart';

enum SocialFollowListKind { followers, following }

@riverpod
class SocialFollowListViewModel extends _$SocialFollowListViewModel {
  @override
  Future<PaginatedSocialResponse<FollowRelationshipModel>> build(
    String userId,
    SocialFollowListKind kind,
  ) async {
    final repository = ref.watch(socialRepositoryProvider);
    return switch (kind) {
      SocialFollowListKind.followers => repository.getFollowers(userId),
      SocialFollowListKind.following => repository.getFollowing(userId),
    };
  }
}
