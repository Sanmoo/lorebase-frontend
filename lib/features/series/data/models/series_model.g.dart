// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EpisodeAirInfoModel _$EpisodeAirInfoModelFromJson(Map<String, dynamic> json) =>
    _EpisodeAirInfoModel(
      airDate: json['airDate'] as String?,
      episodeNumber: (json['episodeNumber'] as num?)?.toInt() ?? 0,
      seasonNumber: (json['seasonNumber'] as num?)?.toInt() ?? 0,
      name: json['name'] as String?,
      overview: json['overview'] as String?,
    );

Map<String, dynamic> _$EpisodeAirInfoModelToJson(
  _EpisodeAirInfoModel instance,
) => <String, dynamic>{
  'airDate': instance.airDate,
  'episodeNumber': instance.episodeNumber,
  'seasonNumber': instance.seasonNumber,
  'name': instance.name,
  'overview': instance.overview,
};

_SeriesModel _$SeriesModelFromJson(Map<String, dynamic> json) => _SeriesModel(
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
  seriesId: json['seriesId'] as String?,
  createdAt: json['createdAt'] as String?,
  voteAverage: (json['voteAverage'] as num?)?.toDouble(),
  voteCount: (json['voteCount'] as num?)?.toInt(),
  popularity: (json['popularity'] as num?)?.toDouble(),
  originCountry:
      (json['originCountry'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  episodeRunTime:
      (json['episodeRunTime'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  numberOfEpisodes: (json['numberOfEpisodes'] as num?)?.toInt() ?? 0,
  createdBy:
      (json['createdBy'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  type: json['type'] as String?,
  lastEpisodeToAir: json['lastEpisodeToAir'] == null
      ? null
      : EpisodeAirInfoModel.fromJson(
          json['lastEpisodeToAir'] as Map<String, dynamic>,
        ),
  nextEpisodeToAir: json['nextEpisodeToAir'] == null
      ? null
      : EpisodeAirInfoModel.fromJson(
          json['nextEpisodeToAir'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$SeriesModelToJson(_SeriesModel instance) =>
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
      'seriesId': instance.seriesId,
      'createdAt': instance.createdAt,
      'voteAverage': instance.voteAverage,
      'voteCount': instance.voteCount,
      'popularity': instance.popularity,
      'originCountry': instance.originCountry,
      'episodeRunTime': instance.episodeRunTime,
      'numberOfEpisodes': instance.numberOfEpisodes,
      'createdBy': instance.createdBy,
      'type': instance.type,
      'lastEpisodeToAir': instance.lastEpisodeToAir,
      'nextEpisodeToAir': instance.nextEpisodeToAir,
    };
