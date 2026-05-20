import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../tracking/data/models/tracked_media_summary_model.dart';

part 'dashboard_section_model.freezed.dart';
part 'dashboard_section_model.g.dart';

@freezed
abstract class DashboardSectionModel with _$DashboardSectionModel {
  const factory DashboardSectionModel({
    @Default([]) List<TrackedMediaSummaryModel> items,
    @Default(0) int total,
    @Default(false) bool hasMore,
  }) = _DashboardSectionModel;

  factory DashboardSectionModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardSectionModelFromJson(json);
}
