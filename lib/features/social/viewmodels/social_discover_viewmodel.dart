import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/exceptions.dart';
import '../data/models/discover_user_model.dart';
import '../data/models/paginated_social_response.dart';
import '../data/repositories/social_repository.dart';

part 'social_discover_viewmodel.g.dart';

@riverpod
class SocialDiscoverViewModel extends _$SocialDiscoverViewModel {
  @override
  Future<PaginatedSocialResponse<DiscoverUserModel>> build() async {
    return ref.watch(socialRepositoryProvider).discoverUsers();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(socialRepositoryProvider).discoverUsers(),
    );
  }

  Future<void> followUser(String userId) async {
    final previous = state.value;

    try {
      await ref.read(socialRepositoryProvider).followUser(userId);
    } on ServerException catch (error) {
      if (error.statusCode != 409) {
        rethrow;
      }
    }

    if (previous == null) {
      return;
    }

    state = AsyncData(
      PaginatedSocialResponse<DiscoverUserModel>(
        items: previous.items
            .map(
              (user) => user.userId == userId
                  ? user.copyWith(isFollowedByMe: true)
                  : user,
            )
            .toList(),
        nextCursor: previous.nextCursor,
        hasMore: previous.hasMore,
      ),
    );
  }
}
