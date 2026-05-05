# Series Detail Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a series detail page with hero layout that lets users view series metadata and add/manage tracking from Search, Dashboard, and Tracking Lists.

**Architecture:** One unified `SeriesDetailPage` at route `/series/:tmdbId`. A Riverpod ViewModel fetches series detail + checks current tracking. A fixed bottom button opens a modal bottom sheet for status selection, rating, and review. Existing tracking API methods (POST/PUT/DELETE) are wired from the ViewModel — the repository layer needs no changes.

**Tech Stack:** Flutter 3.x, go_router, Riverpod (codegen), Freezed, CachedNetworkImage, Material 3

---

### Task 1: Create SeriesDetailState

**Files:**
- Create: `lib/features/series/viewmodels/series_detail_state.dart`

- [ ] **Step 1: Write the state model**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/models/series_model.dart';
import '../../tracking/data/models/tracked_series_model.dart';

part 'series_detail_state.freezed.dart';

@freezed
class SeriesDetailState with _$SeriesDetailState {
  const factory SeriesDetailState({
    required SeriesModel series,
    TrackedSeriesModel? tracking,
  }) = _SeriesDetailState;
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/series/viewmodels/series_detail_state.dart
git commit -m "feat: add SeriesDetailState Freezed model"
```

---

### Task 2: Create SeriesDetailViewModel

**Files:**
- Create: `lib/features/series/viewmodels/series_detail_viewmodel.dart`

- [ ] **Step 1: Write the ViewModel**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/series_repository.dart';
import '../../tracking/data/repositories/tracking_repository.dart';
import '../../tracking/data/models/tracked_series_model.dart';
import 'series_detail_state.dart';

part 'series_detail_viewmodel.g.dart';

@riverpod
class SeriesDetailViewModel extends _$SeriesDetailViewModel {
  @override
  Future<SeriesDetailState> build(int tmdbId) async {
    final seriesRepo = ref.read(seriesRepositoryProvider);
    final trackingRepo = ref.read(trackingRepositoryProvider);

    final series = await seriesRepo.getSeriesById(tmdbId.toString());

    TrackedSeriesModel? tracking;
    try {
      final allTracking = await trackingRepo.getTracking();
      tracking = allTracking.firstWhere(
        (t) => t.series?.tmdbId == tmdbId,
      );
    } catch (_) {
      tracking = null;
    }

    return SeriesDetailState(series: series, tracking: tracking);
  }

  Future<void> addTracking(String status) async {
    final currentState = state.requireValue;
    final trackingRepo = ref.read(trackingRepositoryProvider);
    await trackingRepo.startTracking(
      currentState.series.tmdbId.toString(),
      status,
    );
    ref.invalidateSelf();
  }

  Future<void> updateTracking({
    String? status,
    int? seriesRating,
    String? seriesReview,
  }) async {
    final currentState = state.requireValue;
    final current = currentState.tracking;
    if (current == null) return;

    final trackingRepo = ref.read(trackingRepositoryProvider);
    await trackingRepo.updateTracking(
      current.seriesId,
      status: status,
      seriesRating: seriesRating,
      seriesReview: seriesReview,
    );
    ref.invalidateSelf();
  }

  Future<void> removeTracking() async {
    final currentState = state.requireValue;
    final current = currentState.tracking;
    if (current == null) return;

    final trackingRepo = ref.read(trackingRepositoryProvider);
    await trackingRepo.deleteTracking(current.seriesId);
    ref.invalidateSelf();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/series/viewmodels/series_detail_viewmodel.dart
git commit -m "feat: add SeriesDetailViewModel Riverpod provider"
```

---

### Task 3: Run build_runner codegen

**Files:**
- Generated: `lib/features/series/viewmodels/series_detail_state.freezed.dart`
- Generated: `lib/features/series/viewmodels/series_detail_viewmodel.g.dart`

- [ ] **Step 1: Run codegen**

```bash
cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend && dart run build_runner build --delete-conflicting-outputs
```

Expected: `Succeeded after Xs with Y outputs`

- [ ] **Step 2: Commit generated files**

```bash
git add lib/features/series/viewmodels/series_detail_state.freezed.dart lib/features/series/viewmodels/series_detail_viewmodel.g.dart
git commit -m "chore: add generated code for SeriesDetailState and SeriesDetailViewModel"
```

---

### Task 4: Create SeriesDetailPage

**Files:**
- Create: `lib/features/series/pages/series_detail_page.dart`

- [ ] **Step 1: Write the detail page widget**

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    String selectedStatus = tracking?.status ?? TrackingStatus.wantToWatch.value;
    int? selectedRating = tracking?.seriesRating;
    final reviewController = TextEditingController(text: tracking?.seriesReview ?? '');

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
                    Navigator.pop(ctx);
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
                        await notifier.addTracking(selectedStatus);
                      }
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
                        Navigator.pop(ctx);
                        ref
                            .read(seriesDetailViewModelProvider(tmdbId).notifier)
                            .removeTracking();
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
    final hasBackdrop = series.backdropPath != null && series.backdropPath!.isNotEmpty;
    final hasPoster = series.posterPath != null && series.posterPath!.isNotEmpty;

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
                      child: CachedNetworkImage(
                        imageUrl: series.backdropPath!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
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
                        child: hasPoster
                            ? CachedNetworkImage(
                                imageUrl: series.posterPath!,
                                width: 120,
                                height: 180,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  width: 120,
                                  height: 180,
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  child: const Icon(Icons.broken_image, size: 40),
                                ),
                              )
                            : Container(
                                width: 120,
                                height: 180,
                                color: theme.colorScheme.surfaceContainerHighest,
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
                      Text(
                        '${series.seasonCount} season${series.seasonCount != 1 ? 's' : ''}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (tracking != null) ...[
                        const SizedBox(width: 12),
                        TrackingStatusChip(status: tracking.status),
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
              child: GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                children: [
                  _InfoCard(
                    icon: Icons.calendar_today,
                    label: 'First Air Date',
                    value: series.firstAirDate ?? '—',
                  ),
                  _InfoCard(
                    icon: Icons.collections,
                    label: 'Seasons',
                    value: '${series.seasonCount}',
                  ),
                  _InfoCard(
                    icon: Icons.live_tv,
                    label: 'Networks',
                    value: series.networks.isNotEmpty
                        ? series.networks.join(', ')
                        : '—',
                  ),
                  _InfoCard(
                    icon: Icons.info_outline,
                    label: 'Status',
                    value: series.status ?? '—',
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/series/pages/series_detail_page.dart
git commit -m "feat: add SeriesDetailPage with hero layout and tracking bottom sheet"
```

---

### Task 5: Add route to router.dart

**Files:**
- Modify: `lib/router.dart`

- [ ] **Step 1: Add import and route**

Add import at top (after existing series import on line 11):

```dart
import 'features/series/pages/series_detail_page.dart';
```

Add route inside the `ShellRoute` routes list, after the `/search` route (after line 51):

```dart
GoRoute(
  path: '/series/:tmdbId',
  builder: (context, state) {
    final tmdbId = int.parse(state.pathParameters['tmdbId']!);
    return SeriesDetailPage(tmdbId: tmdbId);
  },
),
```

- [ ] **Step 2: Commit**

```bash
git add lib/router.dart
git commit -m "feat: add /series/:tmdbId route for series detail page"
```

---

### Task 6: Wire onTap in Search page

**Files:**
- Modify: `lib/features/series/pages/series_search_page.dart`

- [ ] **Step 1: Add go_router import**

After `import 'package:flutter/material.dart';` (line 1), add:

```dart
import 'package:go_router/go_router.dart';
```

- [ ] **Step 2: Replace TODO with navigation**

Replace lines 86-88:

```dart
                  onTap: () {
                    // TODO: Navigate to series detail
                  },
```

With:

```dart
                  onTap: () => context.push('/series/${item.tmdbId}'),
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/series/pages/series_search_page.dart
git commit -m "feat: wire search result tap to series detail page"
```

---

### Task 7: Wire onTap in Dashboard

**Files:**
- Modify: `lib/features/dashboard/widgets/series_horizontal_list.dart`
- Modify: `lib/features/dashboard/widgets/watching_section.dart`
- Modify: `lib/features/dashboard/pages/dashboard_page.dart`

- [ ] **Step 1: Add onTap parameter to SeriesHorizontalList**

Replace the entire file content with:

```dart
import 'package:flutter/material.dart';
import '../../series/data/models/series_model.dart';
import '../../series/widgets/series_poster.dart';

class SeriesHorizontalList extends StatelessWidget {
  final List<SeriesModel> series;
  final ValueChanged<SeriesModel>? onTap;

  const SeriesHorizontalList({super.key, required this.series, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: series.length,
        itemBuilder: (context, index) {
          final item = series[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SeriesPoster(
              series: item,
              width: 120,
              onTap: onTap != null ? () => onTap!(item) : null,
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Add onTap parameter to WatchingSection**

Replace the entire file content with:

```dart
import 'package:flutter/material.dart';
import '../../series/data/models/series_model.dart';
import 'series_horizontal_list.dart';

class WatchingSection extends StatelessWidget {
  final List<SeriesModel> series;
  final ValueChanged<SeriesModel>? onTap;

  const WatchingSection({super.key, required this.series, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Watching',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 8),
        SeriesHorizontalList(series: series, onTap: onTap),
      ],
    );
  }
}
```

- [ ] **Step 3: Pass onTap callbacks in DashboardPage**

Add `import 'package:go_router/go_router.dart';` after line 2 (`import 'package:flutter/material.dart';`).

In `dashboard_page.dart`, replace lines 84-88:

```dart
              if (dashboard.watching.items.isNotEmpty)
                SliverToBoxAdapter(
                  child: WatchingSection(series: dashboard.watching.items),
                ),
```

With:

```dart
              if (dashboard.watching.items.isNotEmpty)
                SliverToBoxAdapter(
                  child: WatchingSection(
                    series: dashboard.watching.items,
                    onTap: (series) =>
                        context.push('/series/${series.tmdbId}'),
                  ),
                ),
```

Replace lines 88-96:

```dart
              if (dashboard.wantToWatch.items.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: WatchingSection(
                      series: dashboard.wantToWatch.items,
                    ),
                  ),
                ),
```

With:

```dart
              if (dashboard.wantToWatch.items.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: WatchingSection(
                      series: dashboard.wantToWatch.items,
                      onTap: (series) =>
                          context.push('/series/${series.tmdbId}'),
                    ),
                  ),
                ),
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/dashboard/widgets/series_horizontal_list.dart \
        lib/features/dashboard/widgets/watching_section.dart \
        lib/features/dashboard/pages/dashboard_page.dart
git commit -m "feat: wire dashboard poster taps to series detail page"
```

---

### Task 8: Wire onTap in Tracking List page

**Files:**
- Modify: `lib/features/tracking/pages/tracking_list_page.dart`

- [ ] **Step 1: Add go_router import**

After `import 'package:flutter/material.dart';` (line 1), add:

```dart
import 'package:go_router/go_router.dart';
```

- [ ] **Step 2: Replace TODO with navigation**

Replace lines 110-112:

```dart
                              onTap: () {
                                // TODO: Navigate to tracking detail
                              },
```

With:

```dart
                              onTap: () =>
                                  context.push('/series/${series.tmdbId}'),
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/tracking/pages/tracking_list_page.dart
git commit -m "feat: wire tracking list tap to series detail page"
```

---

### Task 9: Verify

- [ ] **Step 1: Run static analysis**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 2: Run build_runner to ensure generated code is fresh**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `Succeeded` (should be a no-op since codegen ran in Task 3)

- [ ] **Step 3: Run existing tests**

```bash
flutter test
```

Expected: All existing tests pass (no new tests added in this plan)

- [ ] **Step 4: Manual verification checklist**

| Check | Action | Expected |
|-------|--------|----------|
| Search → Detail | Search "break", tap a result | Detail page renders with backdrop, poster, metadata |
| Detail → Add to List | On untracked series, tap "Add to List" | Bottom sheet opens with status options |
| Add → Confirm | Select "Want to Watch", tap "Add to List" | Bottom sheet closes, button changes to "Manage Tracking" |
| Detail → Manage | On tracked series, tap "Manage Tracking" | Bottom sheet shows current status selected, rating, review |
| Manage → Edit rating | Tap rating stars | Rating updates |
| Manage → Save | Change status, add review, tap "Save Changes" | Changes reflected on page |
| Remove from List | Tap "Manage Tracking", tap "Remove from List", confirm | Tracking removed, button shows "Add to List" |
| Dashboard → Detail | On Home tab, tap a poster in Watching section | Navigates to detail page |
| Tracking → Detail | On My Lists tab, tap a poster | Navigates to detail page with current tracking status |
| Back navigation | Tap back arrow on detail page | Returns to origin screen |

- [ ] **Step 5: Commit if any fixes were made**

If `flutter analyze` required fixes:

```bash
git add -A
git commit -m "fix: address flutter analyze issues for series detail feature"
```
