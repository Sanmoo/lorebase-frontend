import 'package:freezed_annotation/freezed_annotation.dart';
import 'tracked_media_model.dart';

part 'tracking_page_model.freezed.dart';
part 'tracking_page_model.g.dart';

/// Uma página de `GET /tracking`: os itens e o token de continuação
/// (`nextCursor`) devolvido pela API. `nextCursor` ausente significa fim da
/// lista; `totalCount` só vem na primeira página.
@freezed
abstract class TrackingPage with _$TrackingPage {
  @JsonSerializable(explicitToJson: true)
  const factory TrackingPage({
    @Default([]) List<TrackedMediaModel> items,
    String? nextCursor,
    int? totalCount,
    int? page,
    int? pageSize,
  }) = _TrackingPage;

  factory TrackingPage.fromJson(Map<String, dynamic> json) =>
      _$TrackingPageFromJson(json);
}
