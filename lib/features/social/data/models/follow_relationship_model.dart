import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow_relationship_model.freezed.dart';
part 'follow_relationship_model.g.dart';

@freezed
abstract class FollowRelationshipModel with _$FollowRelationshipModel {
  const factory FollowRelationshipModel({
    String? followerId,
    String? followedId,
    DateTime? followedAt,
  }) = _FollowRelationshipModel;

  factory FollowRelationshipModel.fromJson(Map<String, dynamic> json) =>
      _$FollowRelationshipModelFromJson(json);
}
