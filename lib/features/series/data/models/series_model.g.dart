// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SeriesModelImpl _$$SeriesModelImplFromJson(
  Map<String, dynamic> json,
) => _$SeriesModelImpl(
  tmdbId: flexibleIntFromJson(json['tmdbId']),
  title: json['title'] as String,
  overview: json['overview'] as String?,
  posterPath: json['posterPath'] as String?,
  backdropPath: json['backdropPath'] as String?,
  firstAirDate: json['firstAirDate'] as String?,
  genres:
      (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  networks:
      (json['networks'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  seasonCount: (json['seasonCount'] as num?)?.toInt() ?? 0,
  status: json['status'] as String?,
);

Map<String, dynamic> _$$SeriesModelImplToJson(_$SeriesModelImpl instance) =>
    <String, dynamic>{
      'tmdbId': flexibleIntToJson(instance.tmdbId),
      'title': instance.title,
      'overview': instance.overview,
      'posterPath': instance.posterPath,
      'backdropPath': instance.backdropPath,
      'firstAirDate': instance.firstAirDate,
      'genres': instance.genres,
      'networks': instance.networks,
      'seasonCount': instance.seasonCount,
      'status': instance.status,
    };
