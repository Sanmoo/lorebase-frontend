// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardStatsModelImpl _$$DashboardStatsModelImplFromJson(
  Map<String, dynamic> json,
) => _$DashboardStatsModelImpl(
  watchingCount: (json['watchingCount'] as num?)?.toInt() ?? 0,
  wantToWatchCount: (json['wantToWatchCount'] as num?)?.toInt() ?? 0,
  completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
  droppedCount: (json['droppedCount'] as num?)?.toInt() ?? 0,
  totalTracked: (json['totalTracked'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$DashboardStatsModelImplToJson(
  _$DashboardStatsModelImpl instance,
) => <String, dynamic>{
  'watchingCount': instance.watchingCount,
  'wantToWatchCount': instance.wantToWatchCount,
  'completedCount': instance.completedCount,
  'droppedCount': instance.droppedCount,
  'totalTracked': instance.totalTracked,
};
