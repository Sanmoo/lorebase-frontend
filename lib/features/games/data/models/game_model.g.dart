// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameModel _$GameModelFromJson(Map<String, dynamic> json) => _GameModel(
  gameId: json['gameId'] as String,
  title: json['title'] as String,
  summary: json['summary'] as String?,
  genre: json['genre'] as String?,
  coverUrl: json['coverUrl'] as String?,
  backdropUrl: json['backdropUrl'] as String?,
  releaseDate: json['releaseDate'] as String?,
  platforms:
      (json['platforms'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  developer: json['developer'] as String?,
  publisher: json['publisher'] as String?,
  franchise: json['franchise'] as String?,
  gameModes:
      (json['gameModes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$GameModelToJson(_GameModel instance) =>
    <String, dynamic>{
      'gameId': instance.gameId,
      'title': instance.title,
      'summary': instance.summary,
      'genre': instance.genre,
      'coverUrl': instance.coverUrl,
      'backdropUrl': instance.backdropUrl,
      'releaseDate': instance.releaseDate,
      'platforms': instance.platforms,
      'developer': instance.developer,
      'publisher': instance.publisher,
      'franchise': instance.franchise,
      'gameModes': instance.gameModes,
    };
