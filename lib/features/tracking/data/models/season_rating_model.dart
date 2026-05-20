import 'package:freezed_annotation/freezed_annotation.dart';

part 'season_rating_model.freezed.dart';
part 'season_rating_model.g.dart';

@freezed
abstract class SeasonRatingModel with _$SeasonRatingModel {
  const factory SeasonRatingModel({
    required int seasonNumber,
    required int rating,
    required DateTime ratedAt,
  }) = _SeasonRatingModel;

  factory SeasonRatingModel.fromJson(Map<String, dynamic> json) =>
      _$SeasonRatingModelFromJson(json);
}
