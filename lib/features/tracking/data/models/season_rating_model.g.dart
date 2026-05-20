// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season_rating_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SeasonRatingModel _$SeasonRatingModelFromJson(Map<String, dynamic> json) =>
    _SeasonRatingModel(
      seasonNumber: (json['seasonNumber'] as num).toInt(),
      rating: (json['rating'] as num).toInt(),
      ratedAt: DateTime.parse(json['ratedAt'] as String),
    );

Map<String, dynamic> _$SeasonRatingModelToJson(_SeasonRatingModel instance) =>
    <String, dynamic>{
      'seasonNumber': instance.seasonNumber,
      'rating': instance.rating,
      'ratedAt': instance.ratedAt.toIso8601String(),
    };
