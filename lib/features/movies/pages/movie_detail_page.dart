// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../l10n/strings.g.dart';
import '../../tracking/data/models/tracked_media_model.dart';
import '../../tracking/data/tracking_status.dart';
import '../../tracking/widgets/tracking_editor_sheet.dart';
import '../../tracking/widgets/tracking_status_chip.dart';
import '../data/models/movie_model.dart';
import '../viewmodels/movie_detail_viewmodel.dart';
import '../viewmodels/movie_detail_state.dart';

class MovieDetailPage extends ConsumerWidget {
  final int tmdbId;

  const MovieDetailPage({super.key, required this.tmdbId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final detailAsync = ref.watch(movieDetailViewModelProvider(tmdbId));

    return detailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: LoadingWidget(message: t.movie_detail_loading),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(movieDetailViewModelProvider(tmdbId)),
        ),
      ),
      data: (detail) => _MovieDetailLoaded(
        movie: detail.movie,
        tracking: detail.tracking,
        onTrackingAction: () => _showTrackingSheet(context, ref, detail),
      ),
    );
  }

  void _showTrackingSheet(
    BuildContext context,
    WidgetRef ref,
    MovieDetailState detail,
  ) {
    final movie = detail.movie;
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
          final notifier = ref.read(
            movieDetailViewModelProvider(tmdbId).notifier,
          );
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
          } catch (e, st) {
            debugPrint('[MOVIE_TRACKING] onSave failed: $e\n$st');
            if (ctx.mounted) {
              ScaffoldMessenger.of(
                ctx,
              ).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          }
        },
        onRemove: isEditing
            ? () async {
                try {
                  await ref
                      .read(movieDetailViewModelProvider(tmdbId).notifier)
                      .removeTracking();
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e, st) {
                  debugPrint('[MOVIE_TRACKING] onRemove failed: $e\n$st');
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(
                      ctx,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              }
            : null,
        removeLabel: ctx.t.series_detail_remove_from_list,
        removeConfirmTitle: ctx.t.series_detail_remove_from_list,
        removeConfirmMessage: ctx.t.series_detail_remove_confirm.replaceFirst(
          '{title}',
          movie.title,
        ),
      ),
    );
  }
}

class _MovieDetailLoaded extends StatelessWidget {
  final MovieModel movie;
  final TrackedMediaModel? tracking;
  final VoidCallback onTrackingAction;

  const _MovieDetailLoaded({
    required this.movie,
    required this.tracking,
    required this.onTrackingAction,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final hasBackdrop =
        movie.backdropPath != null && movie.backdropPath!.isNotEmpty;
    final hasPoster = movie.posterPath != null && movie.posterPath!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton.icon(
            onPressed: onTrackingAction,
            icon: Icon(tracking != null ? Icons.edit : Icons.add),
            label: Text(
              tracking != null
                  ? t.series_detail_manage_tracking
                  : t.series_detail_add_to_list,
            ),
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
                        child: Image.network(
                          movie.backdropPath!,
                          height: 250,
                          fit: BoxFit.fitHeight,
                          alignment: Alignment.bottomCenter,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
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
                                child: CachedNetworkImage(
                                  imageUrl: movie.posterPath!,
                                  imageRenderMethodForWeb:
                                      ImageRenderMethodForWeb.HttpGet,
                                  width: 120,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.broken_image, size: 40),
                                ),
                              )
                            : Container(
                                width: 120,
                                height: 180,
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.movie, size: 40),
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
                    movie.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (movie.genres.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: movie.genres
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
                  if (tracking != null)
                    TrackingStatusChip(status: tracking!.status),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _OverviewSection(overview: movie.overview),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.calendar_today,
                      label: t.movie_detail_release_date,
                      value: movie.releaseDate ?? '—',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.timer,
                      label: t.movie_detail_runtime,
                      value: movie.runtimeMinutes != null
                          ? t.movie_detail_runtime_minutes.replaceFirst(
                              '{minutes}',
                              '${movie.runtimeMinutes}',
                            )
                          : '—',
                    ),
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
