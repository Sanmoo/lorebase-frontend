// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MovieModel _$MovieModelFromJson(Map<String, dynamic> json) => _MovieModel(
  tmdbId: flexibleIntFromJson(json['tmdbId']),
  title: json['title'] as String,
  overview: json['overview'] as String?,
  posterPath: json['posterPath'] as String?,
  backdropPath: json['backdropPath'] as String?,
  releaseDate: json['releaseDate'] as String?,
  genres:
      (_readGenres(json, 'genres') as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  runtimeMinutes: flexibleNullableIntFromJson(
    _readRuntimeMinutes(json, 'runtimeMinutes'),
  ),
  status: json['status'] as String?,
);

Map<String, dynamic> _$MovieModelToJson(_MovieModel instance) =>
    <String, dynamic>{
      'tmdbId': flexibleIntToJson(instance.tmdbId),
      'title': instance.title,
      'overview': instance.overview,
      'posterPath': instance.posterPath,
      'backdropPath': instance.backdropPath,
      'releaseDate': instance.releaseDate,
      'genres': instance.genres,
      'runtimeMinutes': flexibleNullableIntToJson(instance.runtimeMinutes),
      'status': instance.status,
    };
