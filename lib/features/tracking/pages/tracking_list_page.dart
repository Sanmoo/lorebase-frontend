// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  MediaType _selectedType = MediaType.series;

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
    setState(() {
      _selectedType = type;
    });
    _loadTrackingForTab(_tabController.index);
  }

  void _loadTrackingForTab(int index) {
    final status = TrackingStatus.values[index].value;
    ref.read(trackingListViewModelProvider.notifier).loadTracking(
          status: status,
          mediaType: _selectedType,
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    ref.listen<String?>(trackingBackgroundErrorProvider, (prev, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next)),
        );
        ref.read(trackingBackgroundErrorProvider.notifier).state = null;
      }
    });

    final trackingState = ref.watch(trackingListViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.tracking_list_title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: MediaTypeToggle(
              selectedType: _selectedType,
              onChanged: _onMediaTypeChanged,
            ),
          ),
          Container(
            color: Theme.of(context).appBarTheme.backgroundColor ??
                Theme.of(context).primaryColor,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: TrackingStatus.values
                  .map((s) => Tab(text: s.label(t)))
                  .toList(),
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
                      return EmptyStateWidget(
                        message: _selectedType == MediaType.series
                            ? t.tracking_empty.replaceFirst('{status}',
                                TrackingStatus.values[index].label(t))
                            : t.tracking_empty_movies.replaceFirst('{status}',
                                TrackingStatus.values[index].label(t)),
                        icon: Icons.tv_off,
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
                          return const Center(
                            child: Icon(Icons.tv_off, color: Colors.grey),
                          );
                        }
                        return Column(
                          children: [
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) =>
                                    TrackedMediaPoster(
                                  media: media,
                                  width: constraints.maxWidth,
                                  onTap: () {
                                    if (media.mediaId.isEmpty) return;
                                    final path =
                                        tracking.mediaType == MediaType.series
                                            ? '/series/${media.mediaId}'
                                            : '/movies/${media.mediaId}';
                                    context.push(path);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            RatingStars(
                              rating: tracking.rating,
                              size: 10,
                              maxRating: 10,
                            ),
                          ],
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
