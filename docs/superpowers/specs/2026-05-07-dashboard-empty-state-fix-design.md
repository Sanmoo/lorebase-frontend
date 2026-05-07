# Design Spec: Dashboard Empty State Fix

**Date:** 2026-05-07
**Status:** Approved

## Problem

In the Home tab (`DashboardPage`), the empty state message "No series tracked yet. Search and add your first series!" is shown even when the user has tracked series in the "Completed" (or "Dropped") section. This happens because the empty state condition only checks `watching` and `wantToWatch` sections, ignoring `completed` and `dropped`.

Additionally, the dashboard page only renders horizontal series lists for Watching and Want to Watch sections. When a user has series in Completed or Dropped but not in Watching/WantToWatch, the StatsCards correctly show the counts, but no section lists are rendered, making the empty state message confusing and contradictory.

## Root Cause

`lib/features/dashboard/pages/dashboard_page.dart:110-116`:

```dart
if (dashboard.watching.items.isEmpty && dashboard.wantToWatch.items.isEmpty)
  const SliverFillRemaining(
    child: EmptyStateWidget(
      message: 'No series tracked yet.\nSearch and add your first series!',
      icon: Icons.tv_off,
    ),
  ),
```

The condition only considers 2 of the 4 tracking sections.

## Solution

### Approach: Generalize WatchingSection → DashboardSection

The `WatchingSection` widget is already structurally generic — it accepts a list of `SeriesModel` and an `onTap` callback. Currently the title is hardcoded as `'Watching'`. We generalize it by adding a `title` parameter and renaming the class.

### Files Changed

#### 1. `lib/features/dashboard/widgets/watching_section.dart`

- Rename class from `WatchingSection` to `DashboardSection`
- Add `title` parameter (`String`) to the constructor
- Use `title` instead of the hardcoded `'Watching'` text
- File name stays `watching_section.dart` (only the class is renamed, minimizing diff)

#### 2. `lib/features/dashboard/pages/dashboard_page.dart`

- Update import and references from `WatchingSection` to `DashboardSection`
- Add `title` parameter to all section usages: `'Watching'`, `'Want to Watch'`, `'Completed'`, `'Dropped'`
- Add conditional rendering for Completed and Dropped sections (same pattern as Watching/WantToWatch)
- Fix empty state condition to check all 4 sections:

```dart
if (dashboard.watching.items.isEmpty &&
    dashboard.wantToWatch.items.isEmpty &&
    dashboard.completed.items.isEmpty &&
    dashboard.dropped.items.isEmpty)
```

### Section Order (top to bottom)

| Order | Section        | Status     |
|-------|---------------|------------|
| 1     | Watching       | Existing   |
| 2     | Want to Watch  | Existing   |
| 3     | Completed      | **New**    |
| 4     | Dropped        | **New**    |
| —     | Empty State    | Fixed      |

Each section only renders when `items.isNotEmpty`. Spacing between sections uses the existing pattern (`Padding` with `24.0` top).

### Data Flow

- No API changes required. The `GET /dashboard` endpoint already returns all 4 sections with `items`, `total`, and `hasMore` fields.
- The `DashboardViewModel` already provides the full `DashboardModel` with all 4 sections.
- Each section's `items` list contains `SeriesModel` objects with `tmdbId` for navigation.

### Edge Cases

| Scenario                                              | Behavior                                                   |
|------------------------------------------------------|------------------------------------------------------------|
| All 4 sections empty                                  | Empty state message shown                                  |
| Only watching has items                               | Watching section shown, no empty state                     |
| Only completed has items                              | Completed section shown, no empty state (**the fix**)      |
| 20+ items in any section                              | Horizontal scroll works (powered by `SeriesHorizontalList`) |
| Network error from `GET /dashboard`                   | `AppErrorWidget` with retry (existing behavior, unchanged) |
| Loading state                                         | `LoadingWidget` (existing behavior, unchanged)             |

### Out of Scope

- "View all" link for sections (not present in current code, not added here)
- Section-level empty state messages (e.g., "No watching series yet")
- Pagination for dashboard sections
- Visual style changes to StatsCards or section headers
