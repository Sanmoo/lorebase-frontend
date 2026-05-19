# Tab Transition Smoothness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace GoRouter's default `MaterialPage` slide-up transition with `NoTransitionPage` for the 4 bottom nav tab routes, eliminating visual overlap when switching tabs.

**Architecture:** Swap `builder:` for `pageBuilder:` returning `NoTransitionPage` on each tab route inside `ShellRoute`. Only `lib/router.dart` is modified; no new dependencies.

**Tech Stack:** Flutter 3.27, GoRouter 13.2.5, Riverpod

---

### Task 1: Switch tab routes to NoTransitionPage

**Files:**
- Modify: `lib/router.dart:30-55` (the 4 tab routes inside ShellRoute)

- [ ] **Step 1: Read the current router file**

```bash
cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend && cat -n lib/router.dart
```

- [ ] **Step 2: Replace `/dashboard` route builder with pageBuilder**

Change this (lines ~30-33):
```dart
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
```

To this:
```dart
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              key: state.pageKey,
              child: DashboardPage(),
            ),
          ),
```

- [ ] **Step 3: Replace `/search` route builder with pageBuilder**

Change this:
```dart
          GoRoute(
            path: '/search',
            builder: (context, state) => const SeriesSearchPage(),
          ),
```

To this:
```dart
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => const NoTransitionPage(
              key: state.pageKey,
              child: SeriesSearchPage(),
            ),
          ),
```

- [ ] **Step 4: Replace `/tracking` route builder with pageBuilder**

Change this:
```dart
          GoRoute(
            path: '/tracking',
            builder: (context, state) => const TrackingListPage(),
          ),
```

To this:
```dart
          GoRoute(
            path: '/tracking',
            pageBuilder: (context, state) => const NoTransitionPage(
              key: state.pageKey,
              child: TrackingListPage(),
            ),
          ),
```

- [ ] **Step 5: Replace `/recommend` route builder with pageBuilder**

Change this:
```dart
          GoRoute(
            path: '/recommend',
            builder: (context, state) => const RecommendationPage(),
          ),
```

To this:
```dart
          GoRoute(
            path: '/recommend',
            pageBuilder: (context, state) => const NoTransitionPage(
              key: state.pageKey,
              child: RecommendationPage(),
            ),
          ),
```

- [ ] **Step 6: Verify the file compiles**

```bash
cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend && dart analyze lib/router.dart
```
Expected: No errors, no warnings.

- [ ] **Step 7: Run full analyze**

```bash
cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend && make analyze
```
Expected: Exit code 0 (pass).

- [ ] **Step 8: Run existing tests to ensure nothing broke**

```bash
cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend && flutter test
```
Expected: All tests pass.

- [ ] **Step 9: Commit**

```bash
cd /home/sanmoo/dev/github.com/lorebase/lorebase-frontend && git add lib/router.dart && git commit -m "fix: remove slide transition between bottom nav tabs"
```
