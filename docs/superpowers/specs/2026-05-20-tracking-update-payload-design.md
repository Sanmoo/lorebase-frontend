# Tracking Update Payload Compatibility Design

## Problem

The frontend sends tracking rating and review updates with generic field names:

```json
{
  "mediaType": "SERIES",
  "status": "WATCHING",
  "rating": 8,
  "review": "..."
}
```

The current backend handler in `lorebase-backend/user-tracking/cmd/api/main.go` expects legacy field names:

```go
SeriesRating *int    `json:"seriesRating,omitempty"`
SeriesReview *string `json:"seriesReview,omitempty"`
```

As a result, `PUT /tracking/{mediaId}` returns `200 OK` and updates `lastUpdated`, but ignores the submitted `rating` field. The response keeps the previous rating.

## Scope

Implement a frontend compatibility change only. Keep the backend unchanged for this fix.

In scope:

- Update the frontend tracking repository payload for update requests.
- Send `seriesRating` instead of `rating` when a rating is provided.
- Send `seriesReview` instead of `review` when a review is provided.
- Add or update repository tests to assert the exact outgoing request payload.
- Keep the existing diagnostic logs because they may help future tracking/debug sessions.

Out of scope:

- Backend changes.
- Removing diagnostic logs.
- Fixing `tmdbId` vs `mediaId` model/API mismatch.
- Fixing movie `409 Conflict` behavior.
- Broad cache refactors.

## Architecture

The change belongs in the data layer, in:

```txt
lib/features/tracking/data/repositories/tracking_repository.dart
```

`TrackingRepositoryImpl.updateTracking` is the single boundary that translates frontend model fields into the backend request body. Updating that method keeps the viewmodels, widgets, and pages unchanged.

Current payload construction:

```dart
final data = <String, dynamic>{
  'mediaType': mediaType.apiValue,
  if (status != null) 'status': status,
  if (rating != null) 'rating': rating,
  if (review != null) 'review': review,
  if (seasonRatings != null) 'seasonRatings': seasonRatings,
};
```

Target payload construction:

```dart
final data = <String, dynamic>{
  'mediaType': mediaType.apiValue,
  if (status != null) 'status': status,
  if (rating != null) 'seriesRating': rating,
  if (review != null) 'seriesReview': review,
  if (seasonRatings != null) 'seasonRatings': seasonRatings,
};
```

## Data Flow

1. `TrackingEditorSheet` collects status, rating, and review.
2. Detail viewmodel calls `trackingRepository.updateTracking(...)`.
3. `TrackingRepositoryImpl.updateTracking` maps frontend parameters to backend-compatible JSON keys.
4. Backend receives `seriesRating` / `seriesReview` and applies them.
5. Viewmodel invalidates itself and fetches the updated tracking state.

## Error Handling

No new error handling behavior is required for this compatibility fix. Existing repository behavior remains:

- Dio errors are converted to `ServerException`.
- Existing diagnostic logs in detail viewmodels/pages remain in place.

## Testing

Update `test/features/tracking/data/repositories/tracking_repository_test.dart` to verify that `updateTracking` sends:

```json
{
  "mediaType": "SERIES",
  "status": "WATCHING",
  "seriesRating": 8,
  "seriesReview": "Great"
}
```

Also verify that the old `rating` / `review` keys are not present in the request body for update calls.

## Acceptance Criteria

- Updating a tracked series rating from 7 to 8 sends `seriesRating: 8`.
- Backend response should return the updated rating once the frontend sends the expected field name.
- Repository test fails before the implementation and passes after.
- Existing diagnostic logs remain available.
