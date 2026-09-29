import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/models/tracked_media_model.dart';
import '../data/models/tracking_page_model.dart';

part 'tracking_list_state.freezed.dart';

/// Estado acumulado da lista de acompanhamento: a página corrente (itens já
/// anexados + token de continuação) e o andamento da busca da próxima página.
@freezed
abstract class TrackingListState with _$TrackingListState {
  const TrackingListState._();

  const factory TrackingListState({
    @Default(TrackingPage()) TrackingPage page,
    @Default(false) bool isLoadingMore,
    String? loadMoreError,
  }) = _TrackingListState;

  List<TrackedMediaModel> get items => page.items;

  /// `true` enquanto houver token de continuação: fim da lista é
  /// `nextCursor` ausente, nunca contagem de itens.
  bool get hasMore => page.nextCursor != null;
}
