import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../series/widgets/series_poster.dart';
import '../data/tracking_status.dart';
import '../viewmodels/tracking_list_viewmodel.dart';
import '../widgets/tracking_status_chip.dart';

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

  void _loadTrackingForTab(int index) {
    final status = TrackingStatus.values[index].value;
    ref.read(trackingListViewModelProvider.notifier).loadTracking(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingListViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lists'),
        bottom: TabBar(
          controller: _tabController,
          tabs: TrackingStatus.values
              .map((s) => Tab(text: s.label))
              .toList(),
        ),
      ),
      body: TabBarView(
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
                  message: 'No ${TrackingStatus.values[index].label} series yet',
                  icon: Icons.tv_off,
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.55,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: trackings.length,
                itemBuilder: (context, i) {
                  final tracking = trackings[i];
                  final series = tracking.series;
                  if (series == null) {
                    return const Center(
                      child: Icon(Icons.tv_off, color: Colors.grey),
                    );
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: SeriesPoster(
                          series: series,
                          onTap: () {
                            // TODO: Navigate to tracking detail
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                      TrackingStatusChip(status: tracking.status),
                    ],
                  );
                },
              );
            },
          );
        }),
      ),
    );
  }
}
