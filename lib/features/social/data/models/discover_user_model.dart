import 'package:freezed_annotation/freezed_annotation.dart';

import 'social_media_model.dart';

part 'discover_user_model.freezed.dart';
part 'discover_user_model.g.dart';

@freezed
abstract class DiscoverUserModel with _$DiscoverUserModel {
  const factory DiscoverUserModel({
    required String userId,
    required String displayName,
    String? avatarUrl,
    required double affinityScore,
    @Default(<String>[]) List<String> commonGenres,
    @Default(<SocialMediaModel>[]) List<SocialMediaModel> commonMedia,
    @Default(false) bool isFollowedByMe,
  }) = _DiscoverUserModel;

  factory DiscoverUserModel.fromJson(Map<String, dynamic> json) =>
      _$DiscoverUserModelFromJson(json);
}
