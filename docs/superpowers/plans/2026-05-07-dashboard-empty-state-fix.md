# Dashboard Empty State Fix Implementation Plan

> **For agentic workers:** Use subagent-driven-development or executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the Home dashboard so the empty state "No series tracked yet" message only appears when ALL tracking sections are empty, and render Completed/Dropped sections alongside Watching/WantToWatch.

**Architecture:** Generalize the `WatchingSection` widget to `DashboardSection` by adding a `title` parameter, then reuse it for all 4 tracking sections in `DashboardPage`. Fix the empty state condition to check all 4 sections instead of just 2.

**Tech Stack:** Flutter, Dart, Riverpod

---

### Task 1: Generalize WatchingSection → DashboardSection

**Files:**
- Modify: `lib/features/dashboard/widgets/watching_section.dart`

- [ ] **Step 1: Rename class and add `title` parameter**

Replace the entire file content:

```dart
import 'package:flutter/material.dart';
import '../../series/data/models/series_model.dart';
import 'series_horizontal_list.dart';

class DashboardSection extends StatelessWidget {
  final String title;
  final List<SeriesModel> series;
  final ValueChanged<SeriesModel>? onTap;

  const DashboardSection({
    super.key,
    required this.title,
    required this.series,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
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

- [ ] **Step 2: Write widget test for DashboardSection**

Create `test/features/dashboard/widgets/dashboard_section_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/dashboard/widgets/watching_section.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';

void main() {
  group('DashboardSection', () {
    testWidgets('renders title and series list', (tester) async {
      final series = [
        SeriesModel(
          tmdbId: 1,
          title: 'Test Show',
          posterUrl: '',
          backdropUrl: '',
          overview: '',
          firstAirDate: '',
          voteAverage: 8.0,
          genres: [],
          networks: [],
          numberOfSeasons: 1,
          numberOfEpisodes: 10,
          status: 'Ended',
          seasons: [],
          cast: [],
          creators: [],
        ),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardSection(
              title: 'Completed',
              series: series,
            ),
          ),
        ),
      );

      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Test Show'), findsOneWidget);
    });

    testWidgets('shows correct title for different sections', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardSection(
              title: 'Dropped',
              series: [],
            ),
          ),
        ),
      );

      expect(find.text('Dropped'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 3: Run test to verify it passes**

```bash
flutter test test/features/dashboard/widgets/dashboard_section_test.dart
```

Expected: All tests PASS

- [ ] **Step 4: Commit**

```bash
git add lib/features/dashboard/widgets/watching_section.dart test/features/dashboard/widgets/dashboard_section_test.dart
git commit -m "refactor: generalize WatchingSection to DashboardSection with title param"
```

---

### Task 2: Update DashboardPage to render all 4 sections and fix empty state

**Files:**
- Modify: `lib/features/dashboard/pages/dashboard_page.dart`

- [ ] **Step 1: Replace WatchingSection usage with DashboardSection for all 4 sections and fix empty state condition**

In `dashboard_page.dart`, replace the three section sections (lines 85-116) with all four sections and the corrected empty state condition:

```dart
              if (dashboard.watching.items.isNotEmpty)
                SliverToBoxAdapter(
                  child: DashboardSection(
                    title: 'Watching',
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
                    child: DashboardSection(
                      title: 'Want to Watch',
                      series: dashboard.wantToWatch.items,
                      onTap: (series) {
                        if (series.tmdbId != 0) {
                          context.push('/series/${series.tmdbId}');
                        }
                      },
                    ),
                  ),
                ),
              if (dashboard.completed.items.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: DashboardSection(
                      title: 'Completed',
                      series: dashboard.completed.items,
                      onTap: (series) {
                        if (series.tmdbId != 0) {
                          context.push('/series/${series.tmdbId}');
                        }
                      },
                    ),
                  ),
                ),
              if (dashboard.dropped.items.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: DashboardSection(
                      title: 'Dropped',
                      series: dashboard.dropped.items,
                      onTap: (series) {
                        if (series.tmdbId != 0) {
                          context.push('/series/${series.tmdbId}');
                        }
                      },
                    ),
                  ),
                ),
              if (dashboard.watching.items.isEmpty &&
                  dashboard.wantToWatch.items.isEmpty &&
                  dashboard.completed.items.isEmpty &&
                  dashboard.dropped.items.isEmpty)
                const SliverFillRemaining(
                  child: EmptyStateWidget(
                    message: 'No series tracked yet.\nSearch and add your first series!',
                    icon: Icons.tv_off,
                  ),
                ),
```

- [ ] **Step 2: Run flutter analyze to verify no compile errors**

```bash
flutter analyze lib/features/dashboard/
```

Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/features/dashboard/pages/dashboard_page.dart
git commit -m "fix: show all dashboard sections and correct empty state condition"
```
