# Series Detail Page — Design

**Date:** 2026-05-05
**Status:** Pending User Review
**Scope:** Create a series detail page so users can navigate from search/dashboard/tracking results and add/manage tracking
**Problem:** Search tab lists series but tapping a result does nothing (`// TODO: Navigate to series detail`). No detail page or tracking-add flow exists anywhere in the app.

**Tech Stack:** Flutter 3.x, go_router, Riverpod (with codegen), Freezed, Material 3

---

## 1. Executive Summary

Users can search for series in the Search tab, but tapping a result does nothing. Similarly, dashboard and tracking list items have no detail navigation. The goal is to build a unified `SeriesDetailPage` accessible from Search, Dashboard, and Tracking Lists that:

- Displays full series metadata (backdrop, poster, title, genres, overview, first air date, season count, networks, status)
- Lets users add the series to a tracking list (Want to Watch, Watching, Completed, Dropped) if not yet tracked
- Lets users manage existing tracking (change status, rate 1–10, write a review) if already tracked

**Key decision:** One unified detail page handles both tracked and untracked states. The API endpoints for series detail (`GET /series/$id`) and tracking CRUD (`POST`/`PUT`/`DELETE /tracking`) already exist in the codebase but are unused.

---

## 2. Requirements

### User Stories

1. **Search → Detail → Track:** User searches for a series, taps a result, sees full details, and adds it to a tracking list with a status.
2. **Dashboard → Detail → Manage:** User taps a series poster on the dashboard and can view details and change tracking status/rating.
3. **Tracking List → Detail → Manage:** User taps a tracked series in My Lists and can update status, rate, review, or remove.
4. **Already-tracked awareness:** If a series is already being tracked, the detail page reflects the current status instead of showing "Add to List."

### Scope Boundaries

**In scope:**
- Series detail page with hero layout (backdrop, poster, metadata)
- Bottom sheet for tracking actions (status selection, rating, review)
- Navigation from Search, Dashboard, and Tracking Lists
- Loading/error/empty state handling
- ViewModel orchestrating series detail + tracking check

**Out of scope:**
- Season-by-season rating/per-episode tracking
- Social features (sharing, comments)
- Recommendations integration
- Adding series not in catalog (manual entry)
- Push notifications for tracking changes

---

## 3. Routing & Navigation

### New Route

Add to `lib/router.dart` inside the `ShellRoute` (preserves bottom nav bar):

```dart
GoRoute(
  path: '/series/:tmdbId',
  builder: (context, state) {
    final tmdbId = int.parse(state.pathParameters['tmdbId']!);
    return SeriesDetailPage(tmdbId: tmdbId);
  },
),
```

### Navigation Origins

| Screen          | Widget        | Trigger | Action                                        |
| --------------- | ------------- | ------- | --------------------------------------------- |
| Search          | `SeriesCard`    | `onTap`   | `context.push('/series/${series.tmdbId}')`      |
| Dashboard       | `SeriesPoster`  | `onTap`   | `context.push('/series/${series.tmdbId}')`      |
| Tracking Lists  | `SeriesPoster`  | `onTap`   | `context.push('/series/${series.tmdbId}')`      |

Use `context.push()` (not `go()`) so the detail page stacks on top and the AppBar back button returns to the origin. The bottom nav bar remains visible.

---

## 4. Layout & Visual Design

**Layout:** Hero with backdrop (Option A from design session).

```
┌──────────────────────────────────┐
│ ← AppBar (series title)          │
├──────────────────────────────────┤
│                                  │
│    Backdrop image (~250px)       │
│    with gradient overlay         │
│                                  │
│  ┌──────┐                        │
│  │Poster│  Title                 │
│  │ 120  │  Genres (chips)        │
│  │  x   │  Status badge          │
│  │ 180  │  Season count          │
│  └──────┘                        │
│                                  │
│  Overview / Synopsis text        │
│                                  │
│  Info cards (2x2 grid):          │
│  ┌──────────┬──────────┐         │
│  │First Air │ Seasons  │         │
│  ├──────────┼──────────┤         │
│  │ Networks │ Status   │         │
│  └──────────┴──────────┘         │
│                                  │
├──────────────────────────────────┤
│  [ Add to List / Manage ]        │ ← fixed bottom button
└──────────────────────────────────┘
```

### Visual Elements

- **Backdrop:** `CachedNetworkImage` with `BoxFit.cover`, `height: 250`, overlayed by `DecoratedBox` with `LinearGradient` (transparent → `ColorScheme.surfaceContainer` at bottom).
- **Poster:** `CachedNetworkImage`, `width: 120, height: 180`, positioned to overlap the backdrop's bottom edge by ~30px. Rounded corners, white border, shadow.
- **Metadata row:** `Row` with poster on left, `Column` (title, genres as `Wrap` of `Chip`, status badge, season count) on right.
- **Overview:** `Padding` + `Text` with `maxLines: 5` initially. If text overflows, show a "Show more" / "Show less" text button to toggle full text.
- **Info cards:** `GridView` 2x2 using small cards or `Card` widgets. Each: icon, label (12sp, muted), value (14sp, bold).
- **Bottom button:** `bottomNavigationBar` slot with `SafeArea` + `Padding`. `FilledButton` or `ElevatedButton`, full-width. Text changes: "Add to List" (not tracked) or "Manage Tracking" (tracked).
- **Tracked indicator:** When tracked, a `TrackingStatusChip` (existing widget) appears near the title showing the current status.

### Scroll Behavior

Entire content scrolls via `SingleChildScrollView` + `Column`. The bottom button is fixed outside the scroll area via `bottomNavigationBar` property on `Scaffold`.

---

## 5. ViewModel & Data Flow

### Provider

Uses the same `@riverpod` class-based pattern as `SeriesSearchViewModel`:

```dart
part 'series_detail_viewmodel.g.dart';

@riverpod
class SeriesDetailViewModel extends _$SeriesDetailViewModel {
  @override
  Future<SeriesDetailState> build(int tmdbId) async {
    final seriesRepo = ref.read(seriesRepositoryProvider);
    final trackingRepo = ref.read(trackingRepositoryProvider);

    final series = await seriesRepo.getSeriesById(tmdbId);
    final allTracking = await trackingRepo.getTracking();
    final tracking = allTracking.cast<TrackedSeriesModel?>().firstWhere(
      (t) => t?.series?.tmdbId == tmdbId,
      orElse: () => null,
    );

    return SeriesDetailState(series: series, tracking: tracking);
  }
  // ... mutation methods below
}
```

Codegen produces `seriesDetailViewModelProvider(tmdbId)`. The `build` method re-executes on `tmdbId` change (each route push creates a new instance).

### State

```dart
@freezed
class SeriesDetailState with _$SeriesDetailState {
  const factory SeriesDetailState({
    required SeriesModel series,
    TrackedSeriesModel? tracking,   // null = not yet tracked
  }) = _SeriesDetailState;
}
```

### Build Logic (`build` method)

1. Fetch series detail: `ref.read(seriesRepositoryProvider).getSeriesById(tmdbId)` → `GET /series/$tmdbId`
2. Check existing tracking: fetch user's full tracking list via `ref.read(trackingRepositoryProvider).getTracking()` and filter where `series.tmdbId == tmdbId`. Set `tracking` if found, else `null`.
3. Return `SeriesDetailState(series: series, tracking: foundTracking)`

### Mutations (exposed as ViewModel methods)

| Method                          | API Call                  | Refresh? | Notes                                       |
| ------------------------------- | ------------------------- | -------- | ------------------------------------------- |
| `addTracking(TrackingStatus)`   | `POST /tracking`            | Yes      | Sends `{ seriesId: tmdbId.toString(), status }` |
| `updateTracking(status?, rating?, review?)` | `PUT /tracking/$seriesId` | Yes | Sends changed fields only                   |
| `removeTracking()`              | `DELETE /tracking/$seriesId`| Yes      | Sets `tracking = null` after success        |

All mutations call `ref.invalidateSelf()` after success to re-fetch state.

### API Contract Alignment

- `POST /tracking`: expects `seriesId` as string. Pass `tmdbId.toString()`.
- `PUT /tracking/$seriesId`: uses `seriesId` from `TrackedSeriesModel.seriesId` (not `tmdbId`).
- `DELETE /tracking/$seriesId`: same as PUT.

---

## 6. Tracking Interaction (Bottom Sheet)

### Trigger

The fixed bottom button opens `showModalBottomSheet()`.

### Bottom Sheet Content

Reuses and extends the existing `StatusBottomSheet` (`lib/features/tracking/widgets/status_bottom_sheet.dart`):

1. **Title:** "Add to List" or "Manage Tracking" depending on state
2. **Status selection:** 4 horizontal chips/tiles for Want to Watch, Watching, Completed, Dropped. Existing `TrackingStatus` enum values with labels.
3. **Rating (optional):** `RatingStars` widget (existing, 1–10 scale). Pre-filled if editing.
4. **Review (optional):** `TextField` with `maxLines: 3`, `InputDecoration(labelText: 'Review')`. Pre-filled if editing.
5. **Actions:**
   - **Save button** — calls `addTracking` or `updateTracking` depending on state
   - **Cancel button** — closes bottom sheet
   - **Remove button** (only when already tracked) — red text, calls `removeTracking` with confirmation dialog

### State After Action

- On success: invalidate ViewModel → UI rebuilds with updated tracking state
- On error: show `SnackBar` with error message, keep bottom sheet open for retry

---

## 7. UI States

| State                                | UI                                                                                     |
| ------------------------------------ | -------------------------------------------------------------------------------------- |
| **Loading**                            | Shimmer placeholders for backdrop (250px), poster (120×180), text lines (3), info cards (4) |
| **Error**                              | `AppErrorWidget` centered, with error message and retry button                           |
| **Loaded — not tracked**               | Full details + "Add to List" button fixed at bottom                                     |
| **Loaded — tracked**                   | Full details + `TrackingStatusChip` near title + "Manage Tracking" button               |
| **Loaded — tracking action in-flight** | Button shows `CircularProgressIndicator`, bottom sheet disabled during save             |

Edge cases:
- Series with no `posterPath` or `backdropPath`: show placeholder asset/icon
- Series with empty `overview`: show "No description available"
- Series with no `firstAirDate`: hide the card or show "—"
- Series with no `networks`: hide the card or show "—"

---

## 8. Files Affected

### New Files

| File                                                       | Purpose                                         |
| ---------------------------------------------------------- | ----------------------------------------------- |
| `lib/features/series/pages/series_detail_page.dart`          | Detail page widget                              |
| `lib/features/series/viewmodels/series_detail_viewmodel.dart`| ViewModel (Riverpod codegen)                    |
| `lib/features/series/viewmodels/series_detail_state.dart`    | `SeriesDetailState` Freezed model (shared between viewmodel and page) |

### Modified Files

| File                                                       | Change                                                  |
| ---------------------------------------------------------- | ------------------------------------------------------- |
| `lib/router.dart`                                            | Add `/series/:tmdbId` route                               |
| `lib/features/series/pages/series_search_page.dart`          | Wire `onTap` on `SeriesCard` → `context.push(...)`         |
| `lib/features/dashboard/widgets/series_horizontal_list.dart` | Wire `onTap` on `SeriesPoster` → `context.push(...)`       |
| `lib/features/dashboard/widgets/watching_section.dart`       | If needed, pass `onTap` callback or context               |
| `lib/features/tracking/pages/tracking_list_page.dart`        | Wire `onTap` on grid `SeriesPoster` → `context.push(...)`  |
| `lib/features/tracking/widgets/status_bottom_sheet.dart`     | Extend to support editing mode (rating, review, remove)   |

---

## 9. Verification

| Check                                   | Command              | Expected                              |
| --------------------------------------- | -------------------- | ------------------------------------- |
| Static analysis                         | `flutter analyze`      | 0 errors                              |
| Build runner (codegen)                  | `dart run build_runner build --delete-conflicting-outputs` | Success |
| Widget tests (if applicable)            | `flutter test`         | All pass                              |
| Manual: Search → tap → detail renders   | Device/emulator       | Detail page with series info          |
| Manual: Add to list → bottom sheet      | Device/emulator       | Status picker works, API called       |
| Manual: Manage tracking → edit rating   | Device/emulator       | Rating updates, UI reflects change    |
| Manual: Remove from list                | Device/emulator       | Tracking removed, button reverts      |
| Manual: Dashboard → tap → detail        | Device/emulator       | Navigates to detail                   |
| Manual: Tracking list → tap → detail    | Device/emulator       | Navigates to detail with existing status |

---

## 10. Risk Assessment

| Risk                                             | Likelihood | Impact | Mitigation                                                                 |
| ------------------------------------------------ | ---------- | ------ | -------------------------------------------------------------------------- |
| `_findTracking` fetches all tracking to filter one | Low        | Low    | Fine for MVP (<100 trackings expected). Future: add `GET /tracking/check/$tmdbId` endpoint |
| `TrackedSeriesModel.seriesId` vs `tmdbId` mismatch  | Medium     | Medium | Ensure `seriesId` from tracking response matches `tmdbId.toString()`. Monitor API behavior. |
| Bottom sheet complexity (rating, review, remove)  | Low        | Low    | Start with status-only bottom sheet. Add rating/review/remove incrementally if needed. |
