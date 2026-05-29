// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/providers/media_filter_provider.dart';
import '../../../../core/widgets/media_type_toggle.dart';
import '../../../l10n/strings.g.dart';
import '../../tracking/data/models/media_type.dart';
import '../../social/data/models/activity_event_model.dart';
import '../../social/data/models/paginated_social_response.dart';
import '../../social/data/models/social_profile_model.dart';
import '../../social/pages/social_page.dart';
import '../../social/viewmodels/social_feed_viewmodel.dart';
import '../../social/widgets/social_activity_verb.dart';
import '../../../core/cache/cache_providers.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/stats_card.dart';
import '../widgets/watching_section.dart';

Future<void> refreshDashboardAndSocialFeed({
  required DashboardViewModel dashboardViewModel,
  required SocialFeedViewModel socialFeedViewModel,
}) async {
  await dashboardViewModel.refresh();
  await socialFeedViewModel.refresh();
}

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  void _onMediaTypeChanged(MediaType type) {
    ref.read(selectedMediaTypeProvider.notifier).state = type;
  }

  Future<void> _refreshDashboardAndSocialFeed() {
    return refreshDashboardAndSocialFeed(
      dashboardViewModel: ref.read(dashboardViewModelProvider.notifier),
      socialFeedViewModel: ref.read(socialFeedViewModelProvider.notifier),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    ref.listen<String?>(dashboardBackgroundErrorProvider, (prev, next) {
      if (next != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next)));
        ref.read(dashboardBackgroundErrorProvider.notifier).state = null;
      }
    });

    final selectedType = ref.watch(selectedMediaTypeProvider);
    final dashboardState = ref.watch(dashboardViewModelProvider);
    final socialFeedState = ref.watch(socialFeedViewModelProvider);
    final socialProfileState = ref.watch(mySocialProfileProvider);

    return RefreshIndicator(
      onRefresh: _refreshDashboardAndSocialFeed,
      child: dashboardState.when(
        loading: () => LoadingWidget(message: t.dashboard_loading),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () =>
              ref.read(dashboardViewModelProvider.notifier).refresh(),
        ),
        data: (dashboard) => CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: MediaTypeToggle(
                  selectedType: selectedType,
                  onChanged: _onMediaTypeChanged,
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
                  items: dashboard.watching.items,
                  onTap: (item) {
                    if (item.mediaId.isEmpty) return;
                    context.push(
                      item.mediaType == MediaType.series
                          ? '/series/${item.mediaId}'
                          : '/movies/${item.mediaId}',
                    );
                  },
                ),
              ),
            if (dashboard.wantToWatch.items.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: DashboardSection(
                    title: t.dashboard_want_to_watch,
                    items: dashboard.wantToWatch.items,
                    onTap: (item) {
                      if (item.mediaId.isEmpty) return;
                      context.push(
                        item.mediaType == MediaType.series
                            ? '/series/${item.mediaId}'
                            : '/movies/${item.mediaId}',
                      );
                    },
                  ),
                ),
              ),
            if (dashboard.completed.items.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: DashboardSection(
                    title: t.dashboard_completed,
                    items: dashboard.completed.items,
                    onTap: (item) {
                      if (item.mediaId.isEmpty) return;
                      context.push(
                        item.mediaType == MediaType.series
                            ? '/series/${item.mediaId}'
                            : '/movies/${item.mediaId}',
                      );
                    },
                  ),
                ),
              ),
            if (dashboard.dropped.items.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: DashboardSection(
                    title: t.dashboard_dropped,
                    items: dashboard.dropped.items,
                    onTap: (item) {
                      if (item.mediaId.isEmpty) return;
                      context.push(
                        item.mediaType == MediaType.series
                            ? '/series/${item.mediaId}'
                            : '/movies/${item.mediaId}',
                      );
                    },
                  ),
                ),
              ),
            if (dashboard.watching.items.isEmpty &&
                dashboard.wantToWatch.items.isEmpty &&
                dashboard.completed.items.isEmpty &&
                dashboard.dropped.items.isEmpty)
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(
                      height: 260,
                      child: EmptyStateWidget(
                        message: selectedType == MediaType.series
                            ? t.dashboard_empty
                            : t.dashboard_empty_movies,
                        icon: Icons.tv_off,
                      ),
                    ),
                    _SocialPreviewSection(
                      feedState: socialFeedState,
                      profileState: socialProfileState,
                    ),
                    _RecommendationCard(onTap: () => context.go('/recommend')),
                  ],
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: _SocialPreviewSection(
                  feedState: socialFeedState,
                  profileState: socialProfileState,
                ),
              ),
              SliverToBoxAdapter(
                child: _RecommendationCard(
                  onTap: () => context.go('/recommend'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SocialPreviewSection extends StatelessWidget {
  final AsyncValue<PaginatedSocialResponse<ActivityEventModel>> feedState;
  final AsyncValue<SocialProfileModel> profileState;

  const _SocialPreviewSection({
    required this.feedState,
    required this.profileState,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final activities = feedState.asData?.value.items.take(3).toList() ?? [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.groups_outlined),
                  const SizedBox(width: 8),
                  Text(
                    t.dashboard_social_preview_title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              if (profileState.hasValue) ...[
                const SizedBox(height: 8),
                Text(
                  'Perfil social: ${profileState.requireValue.displayName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              if (activities.isEmpty)
                Text(
                  t.dashboard_social_preview_body,
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                ...activities.map(_SocialActivityRow.new),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/social'),
                  child: Text(t.dashboard_social_preview_cta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialActivityRow extends StatelessWidget {
  final ActivityEventModel activity;

  const _SocialActivityRow(this.activity);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.bolt_outlined, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${activity.user.displayName} ${socialActivityVerbFor(activity.activityType)} ${activity.media.title}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final VoidCallback onTap;

  const _RecommendationCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_outlined),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.dashboard_recommendation_title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  t.dashboard_recommendation_body,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    t.dashboard_recommendation_cta,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
