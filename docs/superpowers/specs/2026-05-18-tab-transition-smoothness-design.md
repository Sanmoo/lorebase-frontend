# Tab Transition Smoothness — Design Spec

**Date:** 2026-05-18
**Status:** Approved by user
**Skill:** brainstorming → writing-plans

## Problem

When switching between bottom navigation tabs (Dashboard / Search / My Lists / Recommend) using `context.go()`, GoRouter applies the default `MaterialPage` slide-up transition. During this animation, the previous page remains visible underneath while the new page slides up, causing a visual overlap that appears jarring and unpolished.

## Solution

Replace GoRouter's default `MaterialPage` transition with `NoTransitionPage` for the 4 tab routes inside `ShellRoute`, achieving instant page swapping with zero animation.

## Architecture

### Scope of changes

- **File modified:** `lib/router.dart`
- **Routes affected (inside ShellRoute):**
  - `/dashboard` → `DashboardPage`
  - `/search` → `SeriesSearchPage`
  - `/tracking` → `TrackingListPage`
  - `/recommend` → `RecommendationPage`
- **Routes NOT affected:**
  - Auth routes (`/login`, `/register`, `/forgot-password`) — keep default transition
  - Detail routes (`/series/:tmdbId`, `/movies/:tmdbId`) — keep default transition (push navigation)
  - `ScaffoldWithNavBar` — unchanged
  - All page widgets — unchanged

### Implementation

Each tab route changes from:

```dart
GoRoute(
  path: '/dashboard',
  builder: (context, state) => const DashboardPage(),
),
```

to:

```dart
GoRoute(
  path: '/dashboard',
  pageBuilder: (context, state) => const NoTransitionPage(
    key: state.pageKey,
    child: DashboardPage(),
  ),
),
```

### Key details

- `key: state.pageKey` is required for GoRouter to correctly manage the page stack
- `NoTransitionPage` produces zero animation — no slide, no fade, no overlap
- `NoTransitionPage` is exported via `package:flutter/material.dart`, requiring no new imports
- Only 4 routes need modification (~8 lines changed total)

## Edge cases and considerations

1. **Detail routes preserve animation** — navigation to `/series/:tmdbId` or `/movies/:tmdbId` via `context.push()` still has the standard slide transition, which is appropriate for drill-down navigation.
2. **State preservation** — `NoTransitionPage` destroys and recreates the page on every tab switch (same as current behavior). If preserving scroll position and widget state becomes desired in the future, migrating to `StatefulShellRoute` would be the next step.
3. **Performance** — `NoTransitionPage` is lighter than `MaterialPage` since no animation is run. No negative impact.
