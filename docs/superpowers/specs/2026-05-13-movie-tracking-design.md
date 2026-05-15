# Movie tracking support design

**Date:** 2026-05-13
**Status:** Pending User Review
**Scope:** Add end-to-end movie tracking while preparing the frontend for
future media types.
**Problem:** The frontend is series-first across search, detail, dashboard,
tracking, models, and routing. The API now supports movie tracking through a
unified tracking contract, but the app can't discover, navigate to, track, or
render movies.

## 1. Executive summary

This change adds full movie tracking without mixing all media types into a
single UI. The frontend keeps discovery and detail flows segmented by media
type, while the tracking domain becomes generic enough to support both series
and movies.

The user experience remains familiar:

- **Search** lets the user switch between **Series** and **Movies**.
- **My Lists** lets the user choose a media type first, then browse statuses.
- **Dashboard** shows stats and sections for the selected media type.
- **Detail pages** stay media-specific, with shared tracking actions.

The key design decision is to separate media catalog concerns from tracking
concerns. Search and detail remain type-specific. Tracking becomes media-aware
through a `MediaType` discriminator and generic tracked item models.

## 2. Goals and non-goals

### Goals

- Support movie discovery, movie detail navigation, and movie tracking.
- Keep series behavior working without user-visible regressions.
- Segment the UI by media type instead of mixing series and movies together.
- Generalize the tracking domain so future media types don't require another
  series-specific rewrite.
- Reuse shared tracking interactions where the behavior is the same across
  media types.

### Non-goals

- Support unknown future media types in the UI during this delivery.
- Build a single generic detail page for every media type.
- Change the **Recommend** flow.
- Introduce season-level or item-specific rating flows for movies.
- Redesign the main bottom navigation.

## 3. Current state

The current app assumes every tracked item is a series:

- `TrackedSeriesModel` uses `seriesId`, `seriesRating`, `seriesReview`, and an
  embedded `series` object.
- `TrackingRepository` exposes series-specific CRUD methods.
- `SeriesDetailViewModel` resolves tracking by searching the tracking list for
  a matching series.
- `Dashboard` and `TrackingListPage` render `SeriesModel` directly and navigate
  only to `/series/:tmdbId`.
- Search exists only for series through `SeriesRepository` and
  `SeriesSearchViewModel`.

This makes movie support more than a routing change. The domain language,
payload parsing, caches, navigation targets, and screen structure all need to
stop assuming that "tracked media" always means "tracked series."

## 4. Proposed architecture

### 4.1 Tracking becomes media-aware

The tracking feature becomes the cross-cutting layer for tracked media items.
It no longer encodes series-specific names in its primary models or repository
methods.

Introduce:

- `MediaType` enum with `series` and `movie`.
- A generic tracked item model such as `TrackedMediaModel`.
- A generic embedded summary such as `TrackedMediaSummaryModel` for poster,
  title, `tmdbId`, and `mediaType`.

The tracking layer owns:

- tracking list queries
- tracking mutations
- cache invalidation for dashboard and tracking data
- rendering decisions based on `mediaType`

### 4.2 Catalog and detail stay segmented

Catalog and detail flows stay specific to each media type:

- `features/series/` continues to own series discovery and series detail.
- `features/movies/` is added for movie discovery and movie detail.

This avoids over-generalizing detail pages before the app needs it. It also
keeps room for type-specific metadata, layouts, and future behavior.

### 4.3 Shared UI only where behavior is truly shared

Tracking actions are shared because the workflow is the same:

- choose status
- optionally set rating
- optionally write review
- save or remove tracking

Detail content is not shared unless the shared surface is already obvious.
For this delivery, the bottom sheet and any lightweight tracking affordances
can be extracted. Full detail pages remain separate.

## 5. Data model and API alignment

### 5.1 Tracking contract

The frontend targets a unified tracking contract with a media discriminator.

Example shape:

```json
{
  "trackingId": "trk_123",
  "userId": "usr_123",
  "mediaType": "series",
  "mediaId": "46260",
  "status": "watching",
  "rating": 8,
  "review": "optional",
  "media": {
    "tmdbId": 46260,
    "title": "The Rehearsal",
    "posterPath": "https://...",
    "backdropPath": "https://...",
    "mediaType": "series"
  },
  "addedAt": "2026-05-13T12:00:00Z",
  "lastUpdated": "2026-05-13T12:00:00Z"
}
```

The frontend treats `mediaType` as required and doesn't infer it from routes or
field presence.

### 5.2 Tracking models

Replace the series-specific primary tracking model with a generic one.

Recommended shape:

```dart
enum MediaType { series, movie }

@freezed
class TrackedMediaModel with _$TrackedMediaModel {
  const factory TrackedMediaModel({
    required String trackingId,
    required String userId,
    required MediaType mediaType,
    required String mediaId,
    required String status,
    int? rating,
    String? review,
    @Default([]) List<SeasonRatingModel> seasonRatings,
    TrackedMediaSummaryModel? media,
    required DateTime addedAt,
    required DateTime lastUpdated,
  }) = _TrackedMediaModel;
}
```

Notes:

- Keep `seasonRatings` on the generic model for API compatibility, but treat it
  as series-only in the UI.
- Prefer renaming `seriesRating` to `rating` and `seriesReview` to `review` if
  the new API contract supports it.
- If the backend must keep `seriesRating` and `seriesReview` for compatibility,
  map those names at the serialization boundary instead of spreading them across
  the new domain model.

### 5.3 Catalog models

Keep media-specific full-detail models:

- `SeriesModel` continues to represent series detail and search results.
- `MovieModel` is added for movie detail and search results.

Tracking lists and dashboard sections shouldn't depend directly on
`SeriesModel` or `MovieModel`. They should depend on a summary model that is
safe to render across media types.

### 5.4 Repository contracts

Evolve the tracking repository to accept media-aware inputs:

```dart
abstract class TrackingRepository {
  Future<List<TrackedMediaModel>> getTracking({
    String? status,
    MediaType? mediaType,
    int page = 1,
    int pageSize = 20,
  });

  Future<TrackedMediaModel> startTracking(
    String mediaId,
    MediaType mediaType,
    String status,
  );

  Future<TrackedMediaModel> updateTracking(
    String mediaId, {
    required MediaType mediaType,
    String? status,
    int? rating,
    String? review,
    List<Map<String, dynamic>>? seasonRatings,
  });

  Future<void> deleteTracking(
    String mediaId, {
    required MediaType mediaType,
  });
}
```

Frontend target contracts:

- `GET /tracking` accepts `status`, `mediaType`, `page`, `pageSize`, and
  `includeMedia=true`.
- `POST /tracking` accepts `{ mediaId, mediaType, status }`.
- `PUT /tracking/:mediaId` accepts `mediaType` plus any mutable fields.
- `DELETE /tracking/:mediaId` accepts `mediaType` as a query parameter.
- `GET /dashboard` accepts `mediaType` so the server returns stats and sections
  for the selected type only.
- `GET /series` and `GET /series/:id` continue unchanged.
- `GET /movies` and `GET /movies/:id` are added for movie discovery and detail.

This design depends on a unified tracking contract and explicit media-type
filters in tracking and dashboard endpoints.

## 6. Routing and navigation

Keep explicit routes for each supported media type:

- `/series/:tmdbId`
- `/movies/:tmdbId`

Do not introduce a generic `/media/:type/:id` route yet. The app still has
separate detail pages and distinct metadata needs, so explicit routes keep the
router easier to reason about and test.

Navigation rules:

- Search results route according to the active media type.
- Dashboard sections route according to the tracked item's `mediaType`.
- Tracking list items route according to the tracked item's `mediaType`.

## 7. User experience

### 7.1 Search

The existing **Search** tab remains a single destination in bottom navigation,
but the page becomes segmented by media type.

Behavior:

- Add a top-level selector for **Series** and **Movies**.
- Keep the current debounce and retry behavior.
- Use the active type to choose the repository and result card navigation.

Implementation direction:

- Keep the `/search` route.
- Replace the current series-only page implementation with a segmented search
  page.
- Add a movie-specific repository and ViewModel behind that page.

The intent is to preserve one search destination while making the media choice
explicit before results appear.

### 7.2 Detail pages

Add a movie detail page parallel to the series detail page.

Movie detail mirrors the series detail flow:

- load movie metadata
- check if the movie is already tracked
- show **Add to List** or **Manage Tracking**
- open the shared tracking sheet

The layout can resemble `SeriesDetailPage`, but the metadata fields must match
movies instead of series.

### 7.3 My Lists

`My Lists` becomes segmented by media type first, then by tracking status.

Recommended structure:

- media type selector at the top of the page
- existing status tabs below the selector
- grid content filtered by both media type and status

This keeps the current page recognizable while establishing the pattern needed
for future media types.

### 7.4 Dashboard

The dashboard also becomes segmented by media type.

Recommended structure:

- media type selector near the top
- existing stat cards reflect the selected media type only
- status sections render tracked summaries for the selected media type only

Do not mix series and movies in the same section for this delivery.

### 7.5 Recommend

The recommend flow remains out of scope and stays unchanged.

## 8. Data flow and caching

### 8.1 Search flow

1. The user chooses a media type.
2. The page dispatches the query to the matching catalog repository.
3. The UI renders media-specific results.
4. Tapping a result pushes the matching detail route.

### 8.2 Detail flow

1. The detail ViewModel loads the full catalog item.
2. The ViewModel requests tracking entries for the same `mediaType`.
3. The ViewModel resolves the matching entry by `mediaId` or the embedded
   summary `tmdbId`.
4. The page renders the current tracked state if found.

For this delivery, the detail ViewModel uses the existing list-based lookup
pattern with a media-type filter, for example
`getTracking(mediaType: ..., pageSize: 1000)`, and then resolves the matching
item client-side.

If tracking lookup fails, the detail page still renders the catalog item and
treats tracking as absent.

### 8.3 Mutation flow

When the user adds, updates, or removes tracking:

1. The detail or list ViewModel calls the generic tracking repository.
2. The app invalidates `dashboard` and `tracking:` cache entries.
3. The relevant provider refreshes and re-renders the updated state.

Keep the current cache invalidation behavior, but remove series-specific naming
from the repository and ViewModel contracts.

## 9. Error handling

- If search fails for the active media type, show retry on that segment only.
- If tracking lookup fails inside a detail page, keep the detail page usable and
  show the untracked state.
- If the API returns an unknown `mediaType`, fail close to the repository. Do
  not guess how to render it.
- If a tracked item lacks an embedded summary, the page can show a placeholder
  tile, but it must not route to the wrong detail page.
- If movie payloads omit series-only fields such as `seasonRatings`, parsing
  must still succeed.

## 10. Testing strategy

Add or update tests for the following areas:

- `MediaType` parsing and serialization.
- `TrackedMediaModel` parsing, including embedded summary data.
- `MovieModel` parsing.
- `TrackingRepository` query parameters and payload parsing for series and
  movies.
- Search ViewModels for segmented media search.
- Movie detail ViewModel behavior, including tracking lookup by `mediaType`.
- Tracking list filtering and rendering by media type and status.
- Dashboard filtering and routing by media type.
- Router coverage for `/movies/:tmdbId`.
- Regression coverage to confirm series search, detail, dashboard, and tracking
  still work.

## 11. Files and areas affected

### New files

- `lib/features/movies/data/models/movie_model.dart`
- `lib/features/movies/data/repositories/movie_repository.dart`
- `lib/features/movies/pages/movie_detail_page.dart`
- `lib/features/movies/viewmodels/...`
- new tests under `test/features/movies/`

### Modified files

- `lib/router.dart`
- `lib/features/tracking/data/repositories/tracking_repository.dart`
- `lib/features/tracking/data/models/...`
- `lib/features/tracking/viewmodels/tracking_list_viewmodel.dart`
- `lib/features/dashboard/data/models/...`
- `lib/features/dashboard/data/repositories/dashboard_repository.dart`
- `lib/features/dashboard/pages/dashboard_page.dart`
- `lib/features/series/pages/series_search_page.dart`
- `lib/features/series/viewmodels/series_detail_viewmodel.dart`
- shared tracking widgets used by detail pages
- localization files for new movie-specific copy

## 12. Delivery boundaries

This design intentionally stops at two supported media types: `series` and
`movie`. It prepares the tracking layer for more types later, but it doesn't
try to build a universal frontend abstraction for every future medium now.

That keeps this delivery focused:

- generic tracking domain
- segmented search, dashboard, and lists
- explicit movie detail flow
- no recommend changes
- no speculative support for future media UIs
