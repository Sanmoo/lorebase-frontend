// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/media_filter_provider.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/media_type_toggle.dart';
import '../../../l10n/strings.g.dart';
import '../data/tracking_status.dart';
import '../data/models/media_type.dart';
import '../data/models/tracked_media_model.dart';
import '../viewmodels/tracking_list_state.dart';
import '../viewmodels/tracking_list_viewmodel.dart';
import '../widgets/rating_stars.dart';
import '../widgets/tracked_media_poster.dart';
import '../../../../core/cache/cache_providers.dart';

/// Distância do fim do grid que dispara a busca da próxima página.
const double _loadMoreThreshold = 400;

class TrackingListPage extends ConsumerStatefulWidget {
  const TrackingListPage({super.key});

  @override
  ConsumerState<TrackingListPage> createState() => _TrackingListPageState();
}

class _TrackingListPageState extends ConsumerState<TrackingListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrackingForTab(0);
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadTrackingForTab(_tabController.index);
    }
  }

  void _onMediaTypeChanged(MediaType type) {
    ref.read(selectedMediaTypeProvider.notifier).state = type;
    _loadTrackingForTab(_tabController.index);
  }

  void _loadTrackingForTab(int index) {
    final selectedType = ref.read(selectedMediaTypeProvider);
    final status = trackingStatusesFor(selectedType)[index].value;
    ref
        .read(trackingListViewModelProvider.notifier)
        .loadTracking(status: status, mediaType: selectedType);
  }

  /// Dispara a próxima página quando o grid se aproxima do fim — inclusive
  /// quando a página atual não preenche a viewport (sem rolagem possível).
  void _onScrollMetrics(ScrollMetrics metrics) {
    if (metrics.extentAfter > _loadMoreThreshold) return;
    if (!_canLoadMore) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadMoreNow();
    });
  }

  bool get _canLoadMore {
    final listState = ref.read(trackingListViewModelProvider).value;
    return listState != null &&
        listState.hasMore &&
        !listState.isLoadingMore &&
        listState.loadMoreError == null;
  }

  void _loadMoreNow() {
    if (!_canLoadMore) return;
    ref.read(trackingListViewModelProvider.notifier).loadMore();
  }

  void _retryLoadMore() {
    ref.read(trackingListViewModelProvider.notifier).loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    ref.listen<String?>(trackingBackgroundErrorProvider, (prev, next) {
      if (next != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next)));
        ref.read(trackingBackgroundErrorProvider.notifier).state = null;
      }
    });

    final selectedType = ref.watch(selectedMediaTypeProvider);
    final trackingState = ref.watch(trackingListViewModelProvider);

    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: MediaTypeToggle(
              selectedType: selectedType,
              onChanged: _onMediaTypeChanged,
            ),
          ),
          Container(
            color:
                Theme.of(context).appBarTheme.backgroundColor ??
                Theme.of(context).primaryColor,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: trackingStatusesFor(
                selectedType,
              ).map((status) => Tab(text: status.label(t))).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(4, (index) {
                return trackingState.when(
                  loading: () => const LoadingWidget(),
                  error: (error, _) => AppErrorWidget(
                    message: error.toString(),
                    onRetry: () => _loadTrackingForTab(index),
                  ),
                  data: (listState) {
                    if (listState.items.isEmpty) {
                      final status = trackingStatusesFor(
                        selectedType,
                      )[index].label(t);
                      return EmptyStateWidget(
                        message: _trackingEmptyMessage(t, selectedType, status),
                        icon: _trackingIcon(selectedType),
                      );
                    }
                    return _buildGrid(listState);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(TrackingListState listState) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _onScrollMetrics(notification.metrics);
        return false;
      },
      child: NotificationListener<ScrollMetricsNotification>(
        onNotification: (notification) {
          _onScrollMetrics(notification.metrics);
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.50,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildItem(listState.items[i]),
                  childCount: listState.items.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _TrackingGridFooter(
                isLoadingMore: listState.isLoadingMore,
                error: listState.loadMoreError,
                onRetry: _retryLoadMore,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(TrackedMediaModel tracking) {
    final media = tracking.media;
    if (media == null) {
      return Center(
        child: Icon(
          _trackingIcon(tracking.mediaType),
          color: Colors.grey,
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          TrackedMediaPoster(
            media: media,
            width: constraints.maxWidth,
            onTap: () async {
              final id = media.mediaId.isNotEmpty
                  ? media.mediaId
                  : tracking.mediaId;
              if (id.isEmpty) return;
              final path = _trackingDetailPath(tracking.mediaType, id);
              if (path == null) return;
              await context.push(path);
              if (!context.mounted) return;
              _loadTrackingForTab(_tabController.index);
            },
          ),
          const SizedBox(height: 4),
          RatingStars(rating: tracking.rating, size: 10, maxRating: 10),
        ],
      ),
    );
  }
}

class _TrackingGridFooter extends StatelessWidget {
  final bool isLoadingMore;
  final String? error;
  final VoidCallback onRetry;

  const _TrackingGridFooter({
    required this.isLoadingMore,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final error = this.error;
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          children: [
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.t.error_retry),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

String _trackingEmptyMessage(
  Translations t,
  MediaType mediaType,
  String status,
) {
  final template = switch (mediaType) {
    MediaType.series => t.tracking_empty,
    MediaType.movie => t.tracking_empty_movies,
    MediaType.game => t.tracking_empty_games,
    MediaType.book => t.tracking_empty_books,
  };
  return template.replaceFirst('{status}', status);
}

IconData _trackingIcon(MediaType mediaType) {
  return switch (mediaType) {
    MediaType.game => Icons.sports_esports,
    MediaType.book => Icons.menu_book,
    MediaType.series || MediaType.movie => Icons.tv_off,
  };
}

String? _trackingDetailPath(MediaType mediaType, String id) {
  return switch (mediaType) {
    MediaType.series => '/series/$id',
    MediaType.movie => '/movies/$id',
    MediaType.game => '/games/$id',
    MediaType.book => '/books/$id',
  };
}
