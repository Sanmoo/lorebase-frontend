// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../tracking/data/models/tracked_series_model.dart';
import '../../tracking/data/tracking_status.dart';
import '../../tracking/widgets/rating_stars.dart';
import '../../tracking/widgets/tracking_status_chip.dart';
import '../data/models/series_model.dart';
import '../viewmodels/series_detail_viewmodel.dart';
import '../viewmodels/series_detail_state.dart';

class SeriesDetailPage extends ConsumerWidget {
  final int tmdbId;

  const SeriesDetailPage({super.key, required this.tmdbId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(seriesDetailViewModelProvider(tmdbId));

    return detailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const LoadingWidget(message: 'Loading series details...'),
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
    String selectedStatus =
        tracking?.status ?? TrackingStatus.wantToWatch.value;
    int? selectedRating = tracking?.seriesRating;
    final reviewController =
        TextEditingController(text: tracking?.seriesReview ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEditing ? 'Manage Tracking' : 'Add to List',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ...TrackingStatus.values.map((status) {
                    final isSelected = status.value == selectedStatus;
                    return ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected
                            ? Theme.of(ctx).colorScheme.primary
                            : null,
                      ),
                      title: Text(status.label),
                      onTap: () {
                        setSheetState(() {
                          selectedStatus = status.value;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Text(
                    'Rating',
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  RatingStars(
                    rating: selectedRating,
                    maxRating: 10,
                    onRatingChanged: (r) {
                      setSheetState(() {
                        selectedRating = r;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Review (optional)',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () async {
                      final notifier = ref.read(
                        seriesDetailViewModelProvider(tmdbId).notifier,
                      );
                      try {
                        if (isEditing) {
                          await notifier.updateTracking(
                            status: selectedStatus,
                            seriesRating: selectedRating,
                            seriesReview: reviewController.text.isNotEmpty
                                ? reviewController.text
                                : null,
                          );
                        } else {
                          await notifier.addTracking(
                            selectedStatus,
                            seriesRating: selectedRating,
                            seriesReview: reviewController.text.isNotEmpty
                                ? reviewController.text
                                : null,
                          );
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    child: Text(isEditing ? 'Save Changes' : 'Add to List'),
                  ),
                  if (isEditing) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(ctx).colorScheme.error,
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: ctx,
                          builder: (dctx) => AlertDialog(
                            title: const Text('Remove from List'),
                            content: Text(
                              'Remove "${series.title}" from your list?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(dctx, true),
                                child: const Text('Remove'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && ctx.mounted) {
                          try {
                            await ref
                                .read(seriesDetailViewModelProvider(tmdbId)
                                    .notifier)
                                .removeTracking();
                            if (ctx.mounted) Navigator.pop(ctx);
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        }
                      },
                      child: const Text('Remove from List'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeriesDetailLoaded extends StatelessWidget {
  final SeriesModel series;
  final TrackedSeriesModel? tracking;
  final VoidCallback onTrackingAction;

  const _SeriesDetailLoaded({
    required this.series,
    required this.tracking,
    required this.onTrackingAction,
  });

  @override
  Widget build(BuildContext context) {
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
            label: Text(tracking != null ? 'Manage Tracking' : 'Add to List'),
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
                      child: OverflowBox(
                        minWidth: MediaQuery.of(context).size.width,
                        maxWidth: MediaQuery.of(context).size.width,
                        minHeight: 262,
                        maxHeight: 262,
                        alignment: Alignment.bottomCenter,
                        child: CachedNetworkImage(
                          imageUrl: series.backdropPath!,
                          imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
                          width: MediaQuery.of(context).size.width,
                          height: 262,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
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
                                color: theme.colorScheme.surfaceContainerHighest,
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
                                        const Icon(Icons.broken_image, size: 40),
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
                          '${series.seasonCount} season${series.seasonCount != 1 ? 's' : ''}',
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
                          label: 'First Air Date',
                          value: series.firstAirDate ?? '—',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.collections,
                          label: 'Seasons',
                          value: series.seasonCount > 0 ? '${series.seasonCount}' : '—',
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
                          label: 'Networks',
                          value: series.networks.isNotEmpty
                              ? series.networks.join(', ')
                              : '—',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.info_outline,
                          label: 'Status',
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
    final overview = widget.overview;
    if (overview == null || overview.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'No description available.',
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
          'Overview',
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
            _expanded ? 'Show less' : 'Show more',
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
