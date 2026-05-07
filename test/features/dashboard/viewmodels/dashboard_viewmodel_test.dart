import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:lorebase/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_model.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_section_model.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_stats_model.dart';

class FakeDashboardRepo implements DashboardRepository {
  DashboardModel? result;
  bool shouldThrow = false;

  @override
  Future<DashboardModel> getDashboard() async {
    if (shouldThrow) throw Exception('Failed');
    return result ?? _defaultDashboard();
  }

  DashboardModel _defaultDashboard() => DashboardModel(
        watching: const DashboardSectionModel(),
        wantToWatch: const DashboardSectionModel(),
        completed: const DashboardSectionModel(),
        dropped: const DashboardSectionModel(),
        stats: const DashboardStatsModel(),
      );
}

void main() {
  group('DashboardViewModel', () {
    test('build() starts with AsyncValue.loading', () {
      final repo = FakeDashboardRepo();
      final container = ProviderContainer(overrides: [
        dashboardRepositoryProvider.overrideWith((ref) => repo),
      ]);
      addTearDown(container.dispose);

      final state = container.read(dashboardViewModelProvider);
      expect(state.isLoading, true);
    });

    test('build() loads dashboard data on success', () async {
      final dashboard = DashboardModel(
        watching: const DashboardSectionModel(),
        wantToWatch: const DashboardSectionModel(),
        completed: const DashboardSectionModel(),
        dropped: const DashboardSectionModel(),
        stats: const DashboardStatsModel(watchingCount: 5, totalTracked: 10),
      );
      final repo = FakeDashboardRepo()..result = dashboard;
      final container = ProviderContainer(overrides: [
        dashboardRepositoryProvider.overrideWith((ref) => repo),
      ]);
      addTearDown(container.dispose);

      // Listen to trigger build and wait for async to complete
      final subscription = container.listen(
        dashboardViewModelProvider,
        (prev, next) {},
      );

      // Wait for async completion
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(dashboardViewModelProvider);
      expect(state.hasValue, true);
      expect(state.value!.stats.watchingCount, 5);
      expect(state.value!.stats.totalTracked, 10);

      subscription.close();
    });

    test('build() sets error on failure', () async {
      final repo = FakeDashboardRepo()..shouldThrow = true;
      final container = ProviderContainer(overrides: [
        dashboardRepositoryProvider.overrideWith((ref) => repo),
      ]);
      addTearDown(container.dispose);

      final subscription = container.listen(
        dashboardViewModelProvider,
        (prev, next) {},
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(dashboardViewModelProvider);
      expect(state.hasError, true);

      subscription.close();
    });

    test('refresh() reloads dashboard', () async {
      final repo = FakeDashboardRepo();
      final container = ProviderContainer(overrides: [
        dashboardRepositoryProvider.overrideWith((ref) => repo),
      ]);
      addTearDown(container.dispose);

      final subscription = container.listen(
        dashboardViewModelProvider,
        (prev, next) {},
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(container.read(dashboardViewModelProvider).value!.stats.totalTracked, 0);

      // Change repo data and refresh
      repo.result = DashboardModel(
        watching: const DashboardSectionModel(),
        wantToWatch: const DashboardSectionModel(),
        completed: const DashboardSectionModel(),
        dropped: const DashboardSectionModel(),
        stats: const DashboardStatsModel(totalTracked: 42),
      );

      await container.read(dashboardViewModelProvider.notifier).refresh();
      expect(container.read(dashboardViewModelProvider).value!.stats.totalTracked, 42);

      subscription.close();
    });
  });
}
