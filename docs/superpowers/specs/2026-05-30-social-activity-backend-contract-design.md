# Social Activity Backend Contract Fix Design

## Context

The Social Activity tab is always empty for the logged-in user and when viewing follower profiles. Investigation found that the frontend activity model expects nested `user` and `media` objects, while the backend social API returns activity items as a flattened DTO.

Backend activity payload shape:

```json
{
  "eventId": "evt-1",
  "userId": "user-1",
  "activityType": "COMPLETED",
  "mediaId": "media-1",
  "mediaType": "SERIES",
  "mediaTitle": "Show title",
  "metadata": {},
  "createdAt": "2026-05-20T10:00:00Z"
}
```

The frontend must conform to the backend API contract. It should not require the backend to emit the older nested UI shape.

## Goals

- Parse the backend activity DTO returned by `GET /feed`.
- Parse the backend activity DTO returned by `GET /profiles/{userId}/activity`.
- Render activity cards when valid backend activity data exists.
- Preserve clear empty states when the backend genuinely returns no items.
- Avoid silently converting unexpected parsing/schema errors into empty activity.

## Non-goals

- Change backend endpoints or response shape.
- Redesign Social UI cards.
- Add pagination behavior beyond the current first-page loading behavior.

## Architecture

Add a frontend API DTO for social activity that represents the backend contract directly. The repository layer parses activity responses through that DTO, then maps them into the existing `ActivityEventModel` used by widgets and view models.

This keeps API-conformance logic at the repository boundary and avoids spreading backend DTO fields through the UI.

## Components

### Activity API DTO

Create a small DTO under `lib/features/social/data/models/` or as a private repository helper with fields matching the backend:

- `eventId`
- `userId`
- `activityType`
- `mediaId`
- `mediaType`
- `mediaTitle`
- `metadata`
- `createdAt`

The DTO maps to `ActivityEventModel`:

- `user.userId = userId`
- `user.displayName = metadata.displayName` or `metadata.username` when present; otherwise `Usuário`
- `media.mediaId = mediaId`
- `media.mediaType = mediaType`
- `media.title = mediaTitle`
- `metadata` and `createdAt` pass through unchanged

### SocialRepositoryImpl

Update activity-loading paths only:

- `getFeed()` uses the backend activity DTO mapper.
- `getUserActivity()` uses the backend activity DTO mapper.

Other repository methods remain unchanged.

### SocialProfileViewModel error handling

`SocialProfileViewModel` currently catches any user activity error and returns an empty activity page. That can mask schema/parsing mismatches as a real empty state.

Keep graceful degradation only for expected repository/network/server failures if needed, but do not swallow unexpected parsing/type errors. Unexpected response-shape problems should surface as errors so future backend contract drift is visible.

## Data flow

1. UI watches `socialFeedViewModelProvider` or `socialProfileViewModelProvider(userId)`.
2. ViewModel calls `SocialRepository`.
3. Repository calls the existing backend endpoints:
   - `/feed`
   - `/profiles/{userId}/activity`
4. Repository parses paginated response items as backend activity DTOs.
5. Repository maps DTOs into `ActivityEventModel`.
6. Existing widgets render `SocialActivityCard` from `ActivityEventModel`.

## Empty and error states

- Valid response with `items: []` remains a real empty state.
- Network/server failures continue to show existing error or graceful degraded UI according to each screen's existing behavior.
- Invalid or unexpected activity item shape should not become an empty list silently.

## Testing

Add or update tests for:

- `SocialRepositoryImpl.getFeed` parses flattened backend activity items.
- `SocialRepositoryImpl.getUserActivity` parses flattened backend activity items.
- Social feed displays activity cards when repository returns items.
- Social feed displays the empty feed state when repository returns no items.
- Social profile activity displays cards for follower/user activity.
- Social profile activity displays empty state only when the repository returns an empty page.
- Unexpected activity payload/parsing failure is not silently converted to empty activity.

## Acceptance mapping

- Correct endpoint for logged-in/social feed: `GET /feed` remains in use.
- Correct endpoint for profile activity: `GET /profiles/{userId}/activity` remains in use.
- Parsing no longer discards valid flattened backend activity items.
- Empty state represents a real empty `items` array, not hidden parsing failure.
- Tests cover activity present, activity empty, profile activity, and unexpected responses.
