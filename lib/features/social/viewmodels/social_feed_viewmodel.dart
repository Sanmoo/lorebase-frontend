import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/activity_event_model.dart';
import '../data/models/paginated_social_response.dart';
import '../data/repositories/social_repository.dart';

part 'social_feed_viewmodel.g.dart';

@riverpod
class SocialFeedViewModel extends _$SocialFeedViewModel {
  @override
  Future<PaginatedSocialResponse<ActivityEventModel>> build() async {
    return ref.watch(socialRepositoryProvider).getFeed();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(socialRepositoryProvider).getFeed(),
    );
  }
}
