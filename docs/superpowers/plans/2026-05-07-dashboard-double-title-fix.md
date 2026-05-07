# Dashboard Double Title Fix — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the duplicate "lorebase" AppBar title on the Dashboard (Home) tab by eliminating the nested `Scaffold` from `DashboardPage`.

**Architecture:** `DashboardPage` is wrapped by `ScaffoldWithNavBar` (via `ShellRoute`) which already provides a `Scaffold` + `AppBar`. The page should return only its body content — `RefreshIndicator` wrapping the dashboard state — matching the pattern of all other tab pages (Search, Tracking, Recommend).

**Tech Stack:** Flutter, Dart, GoRouter, Riverpod

---

### Task 1: Remove redundant Scaffold + AppBar from DashboardPage

**Files:**
- Modify: `lib/features/dashboard/pages/dashboard_page.dart:19-22`

- [ ] **Step 1: Remove the nested Scaffold wrapper**

In `lib/features/dashboard/pages/dashboard_page.dart`, replace lines 19-22:

```dart
    return Scaffold(
      appBar: AppBar(
        title: const Text('lorebase'),
      ),
      body: RefreshIndicator(
```

with:

```dart
    return RefreshIndicator(
```

And remove the trailing closing bracket on line 120:

```dart
      ),
    );
  }
```

becomes:

```dart
    );
  }
```

The full `build` method after the change should read:

```dart
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardViewModelProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardViewModelProvider.notifier).refresh(),
      child: dashboardState.when(
        loading: () => const LoadingWidget(message: 'Loading your dashboard...'),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.read(dashboardViewModelProvider.notifier).refresh(),
        ),
        data: (dashboard) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        title: 'Watching',
                        count: dashboard.stats.watchingCount,
                        icon: Icons.play_circle_outline,
                        color: AppColors.watching,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        title: 'Want to Watch',
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
                        title: 'Completed',
                        count: dashboard.stats.completedCount,
                        icon: Icons.check_circle_outline,
                        color: AppColors.completed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        title: 'Dropped',
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
                child: WatchingSection(
                  series: dashboard.watching.items,
                  onTap: (series) {
                    if (series.tmdbId != 0) {
                      context.push('/series/${series.tmdbId}');
                    }
                  },
                ),
              ),
            if (dashboard.wantToWatch.items.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: WatchingSection(
                    series: dashboard.wantToWatch.items,
                    onTap: (series) {
                      if (series.tmdbId != 0) {
                        context.push('/series/${series.tmdbId}');
                      }
                    },
                  ),
                ),
              ),
            if (dashboard.watching.items.isEmpty && dashboard.wantToWatch.items.isEmpty)
              const SliverFillRemaining(
                child: EmptyStateWidget(
                  message: 'No series tracked yet.\nSearch and add your first series!',
                  icon: Icons.tv_off,
                ),
              ),
          ],
        ),
      ),
    );
  }
```

- [ ] **Step 2: Verify the file compiles**

Run: `flutter analyze lib/features/dashboard/pages/dashboard_page.dart`

Expected: No issues found.

- [ ] **Step 3: Run the full static analysis**

Run: `flutter analyze`

Expected: No issues found (pre-existing issues unrelated to this change are acceptable but no new issues should appear).

- [ ] **Step 4: Run existing tests**

Run: `flutter test`

Expected: All existing tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/dashboard/pages/dashboard_page.dart
git commit -m "fix: remove duplicate Scaffold/AppBar from DashboardPage to fix double 'lorebase' title"
```
