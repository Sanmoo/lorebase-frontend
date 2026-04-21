import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/tracked_series_model.dart';
import '../data/repositories/tracking_repository.dart';

part 'tracking_list_viewmodel.g.dart';

@riverpod
class TrackingListViewModel extends _$TrackingListViewModel {
  String? _currentStatus;
  int _page = 1;
  static const int _pageSize = 20;

  @override
  AsyncValue<List<TrackedSeriesModel>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> loadTracking({String? status}) async {
    _currentStatus = status;
    _page = 1;
    state = const AsyncValue.loading();
    await _fetch();
  }

  Future<void> loadMore() async {
    if (state.isLoading) return;
    _page++;
    await _fetch(append: true);
  }

  Future<void> refresh() => loadTracking(status: _currentStatus);

  Future<void> _fetch({bool append = false}) async {
    try {
      final repository = ref.read(trackingRepositoryProvider);
      final items = await repository.getTracking(
        status: _currentStatus,
        page: _page,
        pageSize: _pageSize,
      );
      if (append && state.hasValue) {
        state = AsyncValue.data([...state.value!, ...items]);
      } else {
        state = AsyncValue.data(items);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
