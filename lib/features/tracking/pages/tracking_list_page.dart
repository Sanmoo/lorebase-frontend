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
import '../viewmodels/tracking_list_viewmodel.dart';
import '../widgets/rating_stars.dart';
import '../widgets/tracked_media_poster.dart';
import '../../../../core/cache/cache_providers.dart';

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
                  data: (trackings) {
                    if (trackings.isEmpty) {
                      final status = trackingStatusesFor(
                        selectedType,
                      )[index].label(t);
                      return EmptyStateWidget(
                        message: _trackingEmptyMessage(t, selectedType, status),
                        icon: _trackingIcon(selectedType),
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.50,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: trackings.length,
                      itemBuilder: (context, i) {
                        final tracking = trackings[i];
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
                                  final path = _trackingDetailPath(
                                    tracking.mediaType,
                                    id,
                                  );
                                  if (path == null) return;
                                  await context.push(path);
                                  if (!context.mounted) return;
                                  _loadTrackingForTab(_tabController.index);
                                },
                              ),
                              const SizedBox(height: 4),
                              RatingStars(
                                rating: tracking.rating,
                                size: 10,
                                maxRating: 10,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
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
