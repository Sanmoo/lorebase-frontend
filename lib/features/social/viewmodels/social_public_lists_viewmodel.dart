import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/paginated_social_response.dart';
import '../data/models/public_list_item_model.dart';
import '../data/repositories/social_repository.dart';

part 'social_public_lists_viewmodel.g.dart';

@riverpod
class SocialPublicListsViewModel extends _$SocialPublicListsViewModel {
  @override
  Future<PaginatedSocialResponse<PublicListItemModel>> build(
    String userId, {
    String? status,
    String? mediaType,
  }) async {
    return ref
        .watch(socialRepositoryProvider)
        .getPublicLists(userId, status: status, mediaType: mediaType);
  }
}
