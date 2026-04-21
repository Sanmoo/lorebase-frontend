// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season_rating_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SeasonRatingModelImpl _$$SeasonRatingModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SeasonRatingModelImpl(
      seasonNumber: json['seasonNumber'] as int,
      rating: json['rating'] as int,
      ratedAt: DateTime.parse(json['ratedAt'] as String),
    );

Map<String, dynamic> _$$SeasonRatingModelImplToJson(
        _$SeasonRatingModelImpl instance) =>
    <String, dynamic>{
      'seasonNumber': instance.seasonNumber,
      'rating': instance.rating,
      'ratedAt': instance.ratedAt.toIso8601String(),
    };
