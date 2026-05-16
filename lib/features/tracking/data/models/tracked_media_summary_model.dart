import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/json_converters.dart';
import 'media_type.dart';

part 'tracked_media_summary_model.freezed.dart';
part 'tracked_media_summary_model.g.dart';

MediaType? _nullableMediaTypeFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) return mediaTypeFromJson(value);
  throw FormatException(
    'Cannot convert $value (${value.runtimeType}) to MediaType',
  );
}

dynamic _nullableMediaTypeToJson(MediaType? value) => value?.apiValue;

@freezed
class TrackedMediaSummaryModel with _$TrackedMediaSummaryModel {
  const factory TrackedMediaSummaryModel({
    @JsonKey(
      name: 'tmdbId',
      fromJson: flexibleStringFromJson,
      toJson: flexibleStringToJson,
    )
    @Default('')
    String mediaId,
    required String title,
    @JsonKey(
      fromJson: _nullableMediaTypeFromJson,
      toJson: _nullableMediaTypeToJson,
    )
    MediaType? mediaType,
    String? overview,
    String? posterPath,
    String? status,
    int? trackingRating,
    int? seasonCount,
    DateTime? addedAt,
  }) = _TrackedMediaSummaryModel;

  factory TrackedMediaSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$TrackedMediaSummaryModelFromJson(json);
}
