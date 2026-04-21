import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/dashboard_model.dart';
import '../data/repositories/dashboard_repository.dart';

part 'dashboard_viewmodel.g.dart';

@riverpod
class DashboardViewModel extends _$DashboardViewModel {
  @override
  AsyncValue<DashboardModel> build() {
    loadDashboard();
    return const AsyncValue.loading();
  }

  Future<void> loadDashboard() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(dashboardRepositoryProvider);
      final dashboard = await repository.getDashboard();
      state = AsyncValue.data(dashboard);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() => loadDashboard();
}
