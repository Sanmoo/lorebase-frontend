# Code Context

## Files Retrieved
1. `lib/features/tracking/data/repositories/tracking_repository.dart` (lines 8-163) — frontend tracking REST contract.
2. `lib/features/tracking/data/models/tracked_media_model.dart` (lines 8-32) — persisted tracking response model.
3. `lib/features/tracking/data/models/media_type.dart` (lines 3-35) — frontend media-type enum excludes books.
4. `lib/features/tracking/data/tracking_status.dart` (lines 3-29) — non-game status enum excludes reading statuses.
5. `lib/features/tracking/widgets/tracking_editor_sheet.dart` (lines 10-190) — editing UI supports status/rating/review and game-only fields.
6. `lib/features/tracking/pages/tracking_list_page.dart` (lines 24-181) — tracking filtering, status tabs, and navigation branches.
7. `lib/features/series/pages/series_search_page.dart` (lines 49-180) — search type dispatch requires an explicit book branch.
8. `lib/features/dashboard/data/repositories/dashboard_repository.dart` (lines 8-43) — dashboard filter sends `mediaType`.
9. `../lorebase-backend/.scratch/book-catalog/spec.md` (lines 1-174) — implemented backend book-contract specification.
10. `../lorebase-backend/book-catalog/internal/dto/responses.go` (lines 8-78) — concrete book JSON response shape.
11. `../lorebase-backend/experience-bff/internal/handlers/books.go` (lines 18-90) — public BFF book endpoints.
12. `../lorebase-backend/experience-bff/internal/handlers/tracking.go` (lines 82-220) — BFF tracking create/update payloads and book default status.
13. `../lorebase-backend/user-tracking/internal/domain/tracking_status.go` (lines 13-54) — valid `BOOK` statuses.
14. `../lorebase-backend/docs/adr/0001-book-media-identity.md` (lines 1-21) — Google Books volume-ID identity decision.

## Key Code

### Frontend tracking contract
`TrackingRepository` exposes:
- `GET /tracking?status=&mediaType=&page=&pageSize=&includeMedia=true`
- `GET /tracking/{mediaId}?mediaType=`
- `POST /tracking`
- `PUT /tracking/{mediaId}` with `mediaType` in JSON
- `DELETE /tracking/{mediaId}?mediaType=`

Create payload:
```json
{
  "mediaId": "string",
  "mediaType": "SERIES|MOVIE|GAME",
  "status": "string",
  "selectedPlatform": "string|null",
  "hoursPlayed": "number|null",
  "rating": "int|null",
  "review": "string|null"
}
```

Update payload currently uses legacy names for rating/review:
```json
{
  "mediaType": "SERIES|MOVIE|GAME",
  "status": "string|null",
  "seriesRating": "int|null",
  "seriesReview": "string|null",
  "selectedPlatform": "string|null",
  "hoursPlayed": "number|null",
  "seasonRatings": [{"seasonNumber": 1, "rating": 8, "ratedAt": "ISO-8601"}]
}
```

`TrackedMediaModel` response fields:
`trackingId`, `userId`, `mediaType`, `mediaId`, `status`, optional `rating`, `review`, `selectedPlatform`, `hoursPlayed`, `seasonRatings`, nested `media`, `addedAt`, `lastUpdated`.

There is **no progress/page-count/pages-read/current-page field**, and no separate note/comment model. User-entered prose is one optional `review` field (editor label is “review”). No book-specific tracking fields exist in v1.

### Backend book contract
The backend workspace has an implemented `book-catalog` and BFF contract:

- `GET /books?q={query}&page={positive-int}&limit={positive-int}`
- `GET /books/{bookId}`
- Search accepts title, author, or ISBN through a single free-text `q`.
- Book ID / tracking `mediaId` is the **Google Books volume ID**, not ISBN.
- Book JSON:
```json
{
  "bookId": "zyTCAlFPjgYC",
  "title": "string",
  "authors": ["string"],
  "isbn": "string",
  "pageCount": 123,
  "coverUrl": "https://...",
  "publisher": "string",
  "publishedDate": "string",
  "description": "string",
  "genre": "string"
}
```
Optional book fields are omitted by backend `omitempty`.

Backend accepts `mediaType=BOOK` (case-insensitive at BFF/user-tracking boundaries) and valid book statuses are:
`WANT_TO_READ`, `READING`, `COMPLETED`, `DROPPED`.

BFF tracking accepts modern `rating`/`review`, plus legacy `seriesRating`/`seriesReview` aliases. If book creation omits `status`, BFF defaults it to `WANT_TO_READ`.

### All frontend `MediaType` surfaces
Non-generated source references:
- `lib/core/providers/media_filter_provider.dart` — global selected type default.
- `lib/core/widgets/media_type_toggle.dart` — `MediaType.values` segmented control; adding enum value creates a visible segment.
- `lib/features/dashboard/data/repositories/dashboard_repository.dart` — `/dashboard` filter.
- `lib/features/dashboard/pages/dashboard_page.dart` — series/game UI/icon/navigation branches.
- `lib/features/dashboard/viewmodels/dashboard_viewmodel.dart` — filter/cache-key branches.
- `lib/features/games/pages/game_detail_page.dart` — game tracking sheet.
- `lib/features/games/viewmodels/game_detail_viewmodel.dart` — game tracking CRUD.
- `lib/features/movies/viewmodels/movie_detail_viewmodel.dart` — movie tracking CRUD.
- `lib/features/series/viewmodels/series_detail_viewmodel.dart` — series tracking CRUD.
- `lib/features/series/pages/series_search_page.dart` — hints, clearing, search dispatch, result switch.
- `lib/features/social/data/repositories/social_repository.dart` — media-type API use.
- `lib/features/social/widgets/public_media_list_section.dart` — display/type branches.
- `lib/features/tracking/data/models/media_type.dart` — source enum/parser/labels.
- `lib/features/tracking/data/models/tracked_media_model.dart` and `tracked_media_summary_model.dart` — response deserialization.
- `lib/features/tracking/data/repositories/tracking_repository.dart` — all tracking payload/query serialization.
- `lib/features/tracking/pages/tracking_list_page.dart` — status selection, empty state/icon, detail route.
- `lib/features/tracking/viewmodels/tracking_list_viewmodel.dart` — list type and cache key.
- `lib/features/tracking/widgets/tracking_status_chip.dart` — type/status presentation.

Generated `*.g.dart`/`*.freezed.dart` references follow the two tracking models and must not be edited.

## Architecture
Flutter has one shared `MediaType` enum used by the global type filter, search dispatch, dashboard filtering, tracking CRUD, list navigation, and social display. It currently only serializes `SERIES`, `MOVIE`, `GAME`; parsing backend `BOOK` throws `ArgumentError`.

The backend already supports books end-to-end: BFF `/books` proxies `book-catalog`, user tracking validates `BOOK` and reading statuses, and dashboard maps `READING`/`WANT_TO_READ` into existing response sections. The frontend is the missing consumer.

## Start Here
Open `lib/features/tracking/data/models/media_type.dart`: it is the compile-time/API boundary blocking every backend `BOOK` response and drives the shared toggle.

## Review Findings
- **blocker:** `lib/features/tracking/data/models/media_type.dart:3-35` has no `book('BOOK')`; a backend book response cannot deserialize.
- **blocker:** `lib/features/tracking/data/tracking_status.dart:3-29` has no `WANT_TO_READ`/`READING`; `tracking_list_page.dart:49-57` would send television statuses for books.
- **high:** `lib/features/series/pages/series_search_page.dart:49-180` has exhaustive three-type dispatch and no book repository/viewmodel/card route.
- **high:** `lib/features/tracking/pages/tracking_list_page.dart:145-151` only routes series, game, or movie; tracked books would navigate to `/movies/{id}`.
- **medium:** `lib/features/tracking/widgets/tracking_editor_sheet.dart:10-190` is suitable for book status/rating/review, but text uses series localization keys and has no book vocabulary.
- **no backend blocker:** parent workspace contains `book-catalog`, `user-tracking`, and `experience-bff` book implementation; no remote/API discovery gap remains.

## Residual Risks
- Frontend has no book model/repository/detail/search UI, route, assets, or localized book strings.
- Backend v1 explicitly excludes reading progress, format, audiobook edition, notes, and comments; adding those requires a new backend contract rather than frontend-only fields.
- The backend dashboard retains generic `watching`/`wantToWatch` response section names for books; frontend must translate labels based on selected `MediaType.book`.