# Fix Duplicated "lorebase" Title on Dashboard (Home) Tab

## Problem

The Dashboard (Home) tab renders two "lorebase" AppBar titles stacked vertically — one from the outer `ScaffoldWithNavBar` shell and another from the inner `DashboardPage`'s own `Scaffold` + `AppBar`. Other tabs (Search, My Lists, Recommend) do not have this issue because they rely solely on the shell's `Scaffold` + `AppBar`.

## Root Cause

`DashboardPage` (`lib/features/dashboard/pages/dashboard_page.dart:19-22`) defines its own `Scaffold` with an `AppBar` titled "lorebase", but it is already wrapped by `ScaffoldWithNavBar` (`lib/core/widgets/scaffold_with_nav_bar.dart:50-51`) via a `ShellRoute` in the router. This creates a nested `Scaffold` → `Scaffold` structure with duplicate AppBars.

## Architecture Context

```
ShellRoute (ScaffoldWithNavBar)
  ├── Scaffold
  │   ├── AppBar: "lorebase" + logout button   ← outer AppBar (correct)
  │   ├── Body: child
  │   │   └── DashboardPage
  │   │       ├── Scaffold                      ← INNER Scaffold (incorrect)
  │   │       │   ├── AppBar: "lorebase"        ← duplicate title
  │   │       │   ├── Body: RefreshIndicator
  │   │       │   │   └── dashboardState.when(...)
  │   └── BottomNavigationBar
```

All other tab pages (Search, Tracking, Recommend) return only their body content, correctly relying on the shell's `Scaffold`.

## Design Decision

**Remove the redundant `Scaffold` and `AppBar` from `DashboardPage`**, making it consistent with the other tab pages. The `RefreshIndicator` with pull-to-refresh behavior is preserved.

## Implementation

**File changed:** `lib/features/dashboard/pages/dashboard_page.dart`

**Change:** Remove lines 19-22 (the `Scaffold` wrapper and `AppBar`), promote the `RefreshIndicator` to be the root widget returned by `build`.

Before:
```dart
return Scaffold(
  appBar: AppBar(
    title: const Text('lorebase'),
  ),
  body: RefreshIndicator(
    onRefresh: () => ref.read(dashboardViewModelProvider.notifier).refresh(),
    child: dashboardState.when(...),
  ),
);
```

After:
```dart
return RefreshIndicator(
  onRefresh: () => ref.read(dashboardViewModelProvider.notifier).refresh(),
  child: dashboardState.when(...),
);
```

## Verification

- Build the app and navigate to the Home tab — only one "lorebase" title should appear in the AppBar
- Pull-to-refresh should still work on the dashboard
- Navigate between all tabs — no regressions in layout
