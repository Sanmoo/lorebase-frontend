// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../l10n/strings.g.dart';
import '../../../core/cache/cache_providers.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/stats_card.dart';
import '../widgets/watching_section.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    ref.listen<String?>(dashboardBackgroundErrorProvider, (prev, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next)),
        );
        ref.read(dashboardBackgroundErrorProvider.notifier).state = null;
      }
    });

    final dashboardState = ref.watch(dashboardViewModelProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardViewModelProvider.notifier).refresh(),
      child: dashboardState.when(
        loading: () =>
            LoadingWidget(message: t.dashboard_loading),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () =>
              ref.read(dashboardViewModelProvider.notifier).refresh(),
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
                        title: t.dashboard_watching,
                        count: dashboard.stats.watchingCount,
                        icon: Icons.play_circle_outline,
                        color: AppColors.watching,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        title: t.dashboard_want_to_watch,
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
                        title: t.dashboard_completed,
                        count: dashboard.stats.completedCount,
                        icon: Icons.check_circle_outline,
                        color: AppColors.completed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        title: t.dashboard_dropped,
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
                child: DashboardSection(
                  title: t.dashboard_watching,
                  series: dashboard.watching.items,
                  onTap: (series) {
                    if (series.tmdbId != 0) {
                      context.push('/series/${series.tmdbId}');
                    }
                  },
                ),
              ),
            if (dashboard.wantToWatch.items.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: DashboardSection(
                    title: t.dashboard_want_to_watch,
                    series: dashboard.wantToWatch.items,
                    onTap: (series) {
                      if (series.tmdbId != 0) {
                        context.push('/series/${series.tmdbId}');
                      }
                    },
                  ),
                ),
              ),
            if (dashboard.completed.items.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: DashboardSection(
                    title: t.dashboard_completed,
                    series: dashboard.completed.items,
                    onTap: (series) {
                      if (series.tmdbId != 0) {
                        context.push('/series/${series.tmdbId}');
                      }
                    },
                  ),
                ),
              ),
            if (dashboard.dropped.items.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: DashboardSection(
                    title: t.dashboard_dropped,
                    series: dashboard.dropped.items,
                    onTap: (series) {
                      if (series.tmdbId != 0) {
                        context.push('/series/${series.tmdbId}');
                      }
                    },
                  ),
                ),
              ),
            if (dashboard.watching.items.isEmpty &&
                dashboard.wantToWatch.items.isEmpty &&
                dashboard.completed.items.isEmpty &&
                dashboard.dropped.items.isEmpty)
              SliverFillRemaining(
                child: EmptyStateWidget(
                  message: t.dashboard_empty,
                  icon: Icons.tv_off,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
