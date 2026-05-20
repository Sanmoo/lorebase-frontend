// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_section_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardSectionModelImpl _$$DashboardSectionModelImplFromJson(
  Map<String, dynamic> json,
) => _$DashboardSectionModelImpl(
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

Map<String, dynamic> _$$DashboardSectionModelImplToJson(
  _$DashboardSectionModelImpl instance,
) => <String, dynamic>{
  'items': instance.items,
  'total': instance.total,
  'hasMore': instance.hasMore,
};
