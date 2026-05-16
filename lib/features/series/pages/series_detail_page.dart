// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../l10n/strings.g.dart';
import '../../tracking/data/models/tracked_media_model.dart';
import '../../tracking/data/tracking_status.dart';
import '../../tracking/widgets/tracking_editor_sheet.dart';
import '../../tracking/widgets/tracking_status_chip.dart';
import '../data/models/series_model.dart';
import '../viewmodels/series_detail_viewmodel.dart';
import '../viewmodels/series_detail_state.dart';

class SeriesDetailPage extends ConsumerWidget {
  final int tmdbId;

  const SeriesDetailPage({super.key, required this.tmdbId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final detailAsync = ref.watch(seriesDetailViewModelProvider(tmdbId));

    return detailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: LoadingWidget(message: t.series_detail_loading),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(seriesDetailViewModelProvider(tmdbId)),
        ),
      ),
      data: (detail) => _SeriesDetailLoaded(
        series: detail.series,
        tracking: detail.tracking,
        onTrackingAction: () => _showTrackingSheet(context, ref, detail),
      ),
    );
  }

  void _showTrackingSheet(
    BuildContext context,
    WidgetRef ref,
    SeriesDetailState detail,
  ) {
    final series = detail.series;
    final tracking = detail.tracking;
    final isEditing = tracking != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => TrackingEditorSheet(
        title: isEditing
            ? ctx.t.series_detail_manage_tracking
            : ctx.t.series_detail_add_to_list,
        initialStatus: tracking?.status ?? TrackingStatus.wantToWatch.value,
        initialRating: tracking?.rating,
        initialReview: tracking?.review ?? '',
        onSave: ({required status, rating, review}) async {
          final notifier =
              ref.read(seriesDetailViewModelProvider(tmdbId).notifier);
          try {
            if (isEditing) {
              await notifier.updateTracking(
                status: status,
                rating: rating,
                review: review,
              );
            } else {
              await notifier.addTracking(
                status,
                rating: rating,
                review: review,
              );
            }
            if (ctx.mounted) Navigator.pop(ctx);
          } catch (e) {
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(ctx.t.error_server)),
              );
            }
          }
        },
        onRemove: isEditing
            ? () async {
                try {
                  await ref
                      .read(seriesDetailViewModelProvider(tmdbId).notifier)
                      .removeTracking();
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(ctx.t.error_server)),
                    );
                  }
                }
              }
            : null,
        removeLabel: ctx.t.series_detail_remove_from_list,
        removeConfirmTitle: ctx.t.series_detail_remove_from_list,
        removeConfirmMessage: ctx.t.series_detail_remove_confirm.replaceFirst(
          '{title}',
          series.title,
        ),
      ),
    );
  }
}

class _SeriesDetailLoaded extends StatelessWidget {
  final SeriesModel series;
  final TrackedMediaModel? tracking;
  final VoidCallback onTrackingAction;

  const _SeriesDetailLoaded({
    required this.series,
    required this.tracking,
    required this.onTrackingAction,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final hasBackdrop =
        series.backdropPath != null && series.backdropPath!.isNotEmpty;
    final hasPoster =
        series.posterPath != null && series.posterPath!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(series.title),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton.icon(
            onPressed: onTrackingAction,
            icon: Icon(tracking != null ? Icons.edit : Icons.add),
            label: Text(tracking != null
                ? t.series_detail_manage_tracking
                : t.series_detail_add_to_list),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 250,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (hasBackdrop)
                    Positioned.fill(
                      child: ClipRect(
                        key: const ValueKey('backdrop_clip'),
                        child: OverflowBox(
                          minWidth: MediaQuery.of(context).size.width,
                          maxWidth: MediaQuery.of(context).size.width,
                          minHeight: 262,
                          maxHeight: 262,
                          alignment: Alignment.bottomCenter,
                          child: CachedNetworkImage(
                            imageUrl: series.backdropPath!,
                            imageRenderMethodForWeb:
                                ImageRenderMethodForWeb.HttpGet,
                            width: MediaQuery.of(context).size.width,
                            height: 262,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Positioned.fill(
                      child: Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            theme.colorScheme.surface,
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: hasPoster
                            ? Container(
                                width: 120,
                                height: 180,
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: OverflowBox(
                                  minWidth: 120,
                                  maxWidth: 120,
                                  minHeight: 192,
                                  maxHeight: 192,
                                  alignment: Alignment.bottomCenter,
                                  child: CachedNetworkImage(
                                    imageUrl: series.posterPath!,
                                    imageRenderMethodForWeb:
                                        ImageRenderMethodForWeb.HttpGet,
                                    width: 120,
                                    height: 192,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.broken_image,
                                            size: 40),
                                  ),
                                ),
                              )
                            : Container(
                                width: 120,
                                height: 180,
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.tv, size: 40),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(168, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    series.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (series.genres.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: series.genres
                          .map(
                            (g) => Chip(
                              label: Text(g),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (series.seasonCount > 0)
                        Text(
                          '${series.seasonCount} ${series.seasonCount == 1 ? 'season' : 'seasons'}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      if (tracking != null) ...[
                        const SizedBox(width: 12),
                        TrackingStatusChip(status: tracking!.status),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _OverviewSection(overview: series.overview),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.calendar_today,
                          label: t.series_detail_first_air_date,
                          value: series.firstAirDate ?? '—',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.collections,
                          label: t.series_detail_seasons,
                          value: series.seasonCount > 0
                              ? '${series.seasonCount}'
                              : '—',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.live_tv,
                          label: t.series_detail_networks,
                          value: series.networks.isNotEmpty
                              ? series.networks.join(', ')
                              : '—',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.info_outline,
                          label: t.series_detail_status,
                          value: series.status ?? '—',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OverviewSection extends StatefulWidget {
  final String? overview;

  const _OverviewSection({required this.overview});

  @override
  State<_OverviewSection> createState() => _OverviewSectionState();
}

class _OverviewSectionState extends State<_OverviewSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final overview = widget.overview;
    if (overview == null || overview.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.series_detail_overview,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            t.series_detail_no_description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.series_detail_overview,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          overview,
          maxLines: _expanded ? null : 5,
          overflow: _expanded ? null : TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? t.series_detail_show_less : t.series_detail_show_more,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
