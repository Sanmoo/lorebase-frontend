// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardModel _$DashboardModelFromJson(Map<String, dynamic> json) =>
    _DashboardModel(
      watching: DashboardSectionModel.fromJson(
        json['watching'] as Map<String, dynamic>,
      ),
      wantToWatch: DashboardSectionModel.fromJson(
        json['wantToWatch'] as Map<String, dynamic>,
      ),
      completed: DashboardSectionModel.fromJson(
        json['completed'] as Map<String, dynamic>,
      ),
      dropped: DashboardSectionModel.fromJson(
        json['dropped'] as Map<String, dynamic>,
      ),
      stats: DashboardStatsModel.fromJson(
        json['stats'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$DashboardModelToJson(_DashboardModel instance) =>
    <String, dynamic>{
      'watching': instance.watching,
      'wantToWatch': instance.wantToWatch,
      'completed': instance.completed,
      'dropped': instance.dropped,
      'stats': instance.stats,
    };
