// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardStatsModel _$DashboardStatsModelFromJson(Map<String, dynamic> json) =>
    _DashboardStatsModel(
      watchingCount: (json['watchingCount'] as num?)?.toInt() ?? 0,
      wantToWatchCount: (json['wantToWatchCount'] as num?)?.toInt() ?? 0,
      completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
      droppedCount: (json['droppedCount'] as num?)?.toInt() ?? 0,
      totalTracked: (json['totalTracked'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DashboardStatsModelToJson(
  _DashboardStatsModel instance,
) => <String, dynamic>{
  'watchingCount': instance.watchingCount,
  'wantToWatchCount': instance.wantToWatchCount,
  'completedCount': instance.completedCount,
  'droppedCount': instance.droppedCount,
  'totalTracked': instance.totalTracked,
};
