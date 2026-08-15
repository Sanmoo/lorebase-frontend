// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import '../../../core/i18n/date_formatter.dart';
import '../../../core/utils/image_url.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../l10n/strings.g.dart';
import '../../tracking/data/models/media_type.dart';
import '../../tracking/data/models/tracked_media_model.dart';
import '../../tracking/widgets/tracking_editor_sheet.dart';
import '../../tracking/widgets/tracking_status_chip.dart';
import '../data/models/game_model.dart';
import '../viewmodels/game_detail_viewmodel.dart';
import '../viewmodels/game_detail_state.dart';

class GameDetailPage extends ConsumerWidget {
  final String gameId;

  const GameDetailPage({super.key, required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final detailAsync = ref.watch(gameDetailViewModelProvider(gameId));

    return detailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: LoadingWidget(message: t.game_detail_loading),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: t.game_detail_error(message: error.toString()),
          onRetry: () => ref.invalidate(gameDetailViewModelProvider(gameId)),
        ),
      ),
      data: (detail) => _GameDetailLoaded(
        game: detail.game,
        tracking: detail.tracking,
        onTrackingAction: () => _showTrackingSheet(context, ref, detail),
      ),
    );
  }

  void _showTrackingSheet(
    BuildContext context,
    WidgetRef ref,
    GameDetailState detail,
  ) {
    final game = detail.game;
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
        initialStatus: tracking?.status ?? 'WANT_TO_PLAY',
        initialRating: tracking?.rating,
        initialReview: tracking?.review ?? '',
        initialSelectedPlatform: tracking?.selectedPlatform,
        initialHoursPlayed: tracking?.hoursPlayed,
        isGame: true,
        onSave:
            ({
              required status,
              rating,
              review,
              selectedPlatform,
              hoursPlayed,
            }) async {
              final notifier = ref.read(
                gameDetailViewModelProvider(gameId).notifier,
              );
              try {
                if (isEditing) {
                  await notifier.updateTracking(
                    status: status,
                    rating: rating,
                    review: review,
                    selectedPlatform: selectedPlatform,
                    hoursPlayed: hoursPlayed,
                  );
                } else {
                  await notifier.addTracking(
                    status,
                    selectedPlatform: selectedPlatform ?? '',
                    hoursPlayed: hoursPlayed,
                    rating: rating,
                    review: review,
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e, st) {
                debugPrint('[GAME_TRACKING] onSave failed: $e\n$st');
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(
                        ctx.t.game_detail_error(message: e.toString()),
                      ),
                    ),
                  );
                }
              }
            },
        onRemove: isEditing
            ? () async {
                try {
                  await ref
                      .read(gameDetailViewModelProvider(gameId).notifier)
                      .removeTracking();
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e, st) {
                  debugPrint('[GAME_TRACKING] onRemove failed: $e\n$st');
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(
                          ctx.t.game_detail_error(message: e.toString()),
                        ),
                      ),
                    );
                  }
                }
              }
            : null,
        removeLabel: ctx.t.series_detail_remove_from_list,
        removeConfirmTitle: ctx.t.series_detail_remove_from_list,
        removeConfirmMessage: ctx.t.series_detail_remove_confirm(
          title: game.title,
        ),
      ),
    );
  }
}

class _GameDetailLoaded extends StatelessWidget {
  final GameModel game;
  final TrackedMediaModel? tracking;
  final VoidCallback onTrackingAction;

  const _GameDetailLoaded({
    required this.game,
    required this.tracking,
    required this.onTrackingAction,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final hasCover = game.coverUrl != null && game.coverUrl!.isNotEmpty;
    final hasBackdrop =
        game.backdropUrl != null && game.backdropUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(game.title)),
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
                          game.backdropUrl!,
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
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: hasCover
                            ? Container(
                                width: 120,
                                height: 180,
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: CachedNetworkImage(
                                  imageUrl: highResolutionIgdbImageUrl(
                                    game.coverUrl!,
                                  ),
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
                                child: const Icon(
                                  Icons.videogame_asset,
                                  size: 40,
                                ),
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
                    game.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (game.genre != null && game.genre!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Chip(
                        label: Text(game.genre!),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  if (game.platforms.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: game.platforms
                          .map(
                            (p) => Chip(
                              label: Text(p),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 8),
                  if (tracking != null)
                    TrackingStatusChip(
                      status: tracking!.status,
                      // Bug fix: sem mediaType o chip caía no enum de SÉRIES e
                      // todo status de jogo virava "Quero Ver" (fromString
                      // default wantToWatch). Corrigido para rotular por
                      // GameTrackingStatus ("Quero Jogar"/"Jogando"/...).
                      mediaType: MediaType.game,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _OverviewSection(summary: game.summary),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.calendar_today,
                      label: t.game_detail_release_date,
                      value: formatLocalizedDate(context, game.releaseDate),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.business,
                      label: t.game_detail_developer,
                      value: game.developer ?? '—',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.publish,
                      label: t.game_detail_publisher,
                      value: game.publisher ?? '—',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.sports_esports,
                      label: t.game_detail_game_modes,
                      value: game.gameModes.isNotEmpty
                          ? game.gameModes.join(', ')
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
  final String? summary;

  const _OverviewSection({required this.summary});

  @override
  State<_OverviewSection> createState() => _OverviewSectionState();
}

class _OverviewSectionState extends State<_OverviewSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final summary = widget.summary;
    if (summary == null || summary.isEmpty) {
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
          summary,
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
