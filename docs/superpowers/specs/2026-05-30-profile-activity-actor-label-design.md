# Profile Activity Actor Label Design

## Context

The Social profile Activity tab currently renders each activity card using `event.user.displayName`. When viewing the logged-in user's own profile this can produce text such as `Usuário avaliou xyz`, and when viewing another profile it can show the generic fallback instead of that profile's social display name.

The Social feed should keep its current behavior, using the actor provided by each feed event.

## Goal

On profile Activity tabs, display the actor label from the page context:

- Own profile: `Você`.
- Another user's profile: that profile's `displayName`.

## Non-goals

- Do not change backend API contract.
- Do not change activity verbs.
- Do not change Social feed activity cards.
- Do not add localization plumbing for `Você` in this small follow-up.

## Design

Add an optional actor label override to `SocialActivityCard`.

- `SocialActivityCard.actorLabel` defaults to null.
- When null, the card continues to render `event.user.displayName`.
- When provided, the card renders the override.
- User tap behavior remains unchanged; tapping the actor still calls `onUserTap`.

Update `SocialProfilePage` so `_ActivityTab` receives `isMe` from the page and computes:

- `actorLabel = 'Você'` when `isMe` is true.
- `actorLabel = state.profile.displayName` otherwise.

Pass this label to each profile activity card.

## Testing

- `SocialActivityCard` widget test: actor override replaces the displayed actor text while preserving media/verb rendering.
- `SocialProfilePage` widget test: own profile activity displays `Você`.
- `SocialProfilePage` widget test: another user's profile activity displays the profile display name.

## Acceptance

- Profile Activity on my own profile no longer shows `Usuário`/raw event user as actor; it shows `Você`.
- Profile Activity on another user's profile uses that profile's social display name.
- Social feed activity remains unchanged.
