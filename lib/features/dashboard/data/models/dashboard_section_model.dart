import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../series/data/models/series_model.dart';

part 'dashboard_section_model.freezed.dart';
part 'dashboard_section_model.g.dart';

@freezed
class DashboardSectionModel with _$DashboardSectionModel {
  const factory DashboardSectionModel({
    @Default([]) List<SeriesModel> items,
    @Default(0) int total,
    @Default(false) bool hasMore,
  }) = _DashboardSectionModel;

  factory DashboardSectionModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardSectionModelFromJson(json);
}
