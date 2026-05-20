// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_section_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardSectionModel _$DashboardSectionModelFromJson(
  Map<String, dynamic> json,
) => _DashboardSectionModel(
  items:
      (json['items'] as List<dynamic>?)
          ?.map(
            (e) => TrackedMediaSummaryModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  total: (json['total'] as num?)?.toInt() ?? 0,
  hasMore: json['hasMore'] as bool? ?? false,
);

Map<String, dynamic> _$DashboardSectionModelToJson(
  _DashboardSectionModel instance,
) => <String, dynamic>{
  'items': instance.items,
  'total': instance.total,
  'hasMore': instance.hasMore,
};
