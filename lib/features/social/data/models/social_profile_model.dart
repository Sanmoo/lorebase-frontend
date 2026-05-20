import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_profile_model.freezed.dart';
part 'social_profile_model.g.dart';

@freezed
abstract class SocialProfileModel with _$SocialProfileModel {
  const factory SocialProfileModel({
    required String userId,
    required String displayName,
    String? avatarUrl,
    required bool isPublic,
    required int followingCount,
    required int followerCount,
    @Default(false) bool isFollowedByMe,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SocialProfileModel;

  factory SocialProfileModel.fromJson(Map<String, dynamic> json) =>
      _$SocialProfileModelFromJson(json);
}
