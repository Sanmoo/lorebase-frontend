import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/stats_card.dart';
import '../widgets/watching_section.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('lorebase'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardViewModelProvider.notifier).refresh(),
        child: dashboardState.when(
          loading: () => const LoadingWidget(message: 'Loading your dashboard...'),
          error: (error, _) => ErrorWidget(
            message: error.toString(),
            onRetry: () => ref.read(dashboardViewModelProvider.notifier).refresh(),
          ),
          data: (dashboard) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Watching',
                          count: dashboard.stats.watchingCount,
                          icon: Icons.play_circle_outline,
                          color: AppColors.watching,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          title: 'Want to Watch',
                          count: dashboard.stats.wantToWatchCount,
                          icon: Icons.bookmark_border,
                          color: AppColors.wantToWatch,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Completed',
                          count: dashboard.stats.completedCount,
                          icon: Icons.check_circle_outline,
                          color: AppColors.completed,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          title: 'Dropped',
                          count: dashboard.stats.droppedCount,
                          icon: Icons.cancel_outlined,
                          color: AppColors.dropped,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (dashboard.watching.items.isNotEmpty)
                SliverToBoxAdapter(
                  child: WatchingSection(series: dashboard.watching.items),
                ),
              if (dashboard.wantToWatch.items.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: WatchingSection(
                      series: dashboard.wantToWatch.items,
                    ),
                  ),
                ),
              if (dashboard.watching.items.isEmpty && dashboard.wantToWatch.items.isEmpty)
                const SliverFillRemaining(
                  child: EmptyStateWidget(
                    message: 'No series tracked yet.\nSearch and add your first series!',
                    icon: Icons.tv_off,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
