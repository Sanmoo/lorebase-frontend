# Social Features Design

## Summary

Lorebase will add Social as a primary engagement surface. The feature aims to increase daily engagement by showing activity from followed users, helping users discover people with similar taste, and exposing richer public profiles.

The main navigation changes from `Home / Search / My Lists / Recommend` to:

1. Home
2. Search
3. My Lists
4. Social

Recommend will move from a bottom navigation tab into the Home/Dashboard as a recommendation section or card.

## Product Scope

The Social MVP assumes the backend social contracts described in this document are available. The frontend does not need to implement a degraded mode for the current partial backend contract.

The MVP includes:

- Mandatory social profile onboarding before first Social use.
- Explicit privacy choice during onboarding.
- Social page with Feed and Discover tabs.
- Rich activity feed cards.
- Navigation from activity cards to user profiles and media details.
- Discover users by affinity.
- Complete social profile with Activity, Lists, Followers, and Following.
- Home/Dashboard preview of social activity.

The MVP excludes:

- Likes/reactions.
- Comments.
- Invite/import friends.
- Fine-grained per-list privacy controls.
- Compatibility score on profile pages.

## Navigation and Information Architecture

Protected routes inside the existing `ShellRoute`:

```txt
/social
/social/onboarding
/social/profile/me
/social/profile/edit
/social/profile/:userId
/social/profile/:userId/followers
/social/profile/:userId/following
```

`/social` is responsible for deciding whether to render onboarding or the normal Social experience. This avoids adding social profile state to the global `authRedirect` logic.

The Social page contains two tabs:

- Feed
- Discover

The Home/Dashboard remains balanced. It keeps existing dashboard content and adds:

- a short social activity preview;
- a CTA to open Social;
- the existing recommendation experience as a Home section/card.

## First-Run Onboarding

When the user opens Social, the app calls `GET /profiles/me`.

- `200`: load normal Social experience.
- `404`: show mandatory onboarding.

The onboarding form asks for:

- display name;
- avatar URL;
- explicit privacy choice:
  - Public: appears in discovery and can be viewed/followed by others.
  - Private: hidden from discovery and unavailable as a public profile.

After saving with `PUT /profiles/me`, the app loads Discover suggestions so the user can follow compatible users before entering the feed.

## Frontend Architecture

Create a new feature folder:

```txt
lib/features/social/
  data/
    models/
      social_profile_model.dart
      social_user_model.dart
      activity_event_model.dart
      discover_user_model.dart
      follow_relationship_model.dart
      public_list_item_model.dart
      paginated_social_response.dart
    repositories/
      social_repository.dart
  pages/
    social_page.dart
    social_onboarding_page.dart
    social_profile_page.dart
    edit_social_profile_page.dart
  viewmodels/
    social_feed_viewmodel.dart
    social_discover_viewmodel.dart
    social_profile_viewmodel.dart
    social_onboarding_viewmodel.dart
    social_follow_list_viewmodel.dart
    social_public_lists_viewmodel.dart
  widgets/
    social_activity_card.dart
    social_profile_header.dart
    social_follow_button.dart
    discover_user_card.dart
    social_empty_feed.dart
    social_onboarding_form.dart
    public_media_list_section.dart
```

Models use Freezed and JSON serialization. Generated `*.g.dart` and `*.freezed.dart` files remain generated-only.

### Repository

`SocialRepository` is the single access point for social backend calls. It uses the existing `Dio` provider.

Core methods:

```dart
Future<SocialProfileModel> getMyProfile();
Future<SocialProfileModel> updateMyProfile(...);
Future<SocialProfileModel> getProfile(String userId);
Future<void> followUser(String userId);
Future<void> unfollowUser(String userId);
Future<PaginatedSocialResponse<ActivityEventModel>> getFeed(...);
Future<PaginatedSocialResponse<DiscoverUserModel>> discoverUsers(...);
Future<PaginatedSocialResponse<ActivityEventModel>> getUserActivity(...);
Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowers(...);
Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowing(...);
Future<PaginatedSocialResponse<PublicListItemModel>> getPublicLists(...);
```

### ViewModels

ViewModels are small and screen-oriented:

- `SocialFeedViewModel`: feed load, refresh, pagination state.
- `SocialDiscoverViewModel`: suggestions, follow action, followed state update.
- `SocialProfileViewModel`: profile header, user activity, public lists.
- `SocialOnboardingViewModel`: profile creation and initial suggestions.
- `SocialFollowListViewModel`: followers/following lists.
- `SocialPublicListsViewModel`: public list filters and pagination if needed.

## Backend Contracts

### Existing endpoints used

```http
GET /profiles/me
PUT /profiles/me
GET /profiles/{userId}

POST /follows/{userId}
DELETE /follows/{userId}

GET /follows/me/following
GET /follows/me/followers
GET /follows/{userId}/following
GET /follows/{userId}/followers

GET /feed
GET /discover
```

### New endpoints needed

#### User activity for profile

```http
GET /profiles/{userId}/activity?limit=20&cursor=<cursor>
```

Response:

```json
{
  "items": [
    {
      "eventId": "evt_123",
      "user": {
        "userId": "user_123",
        "displayName": "Fulano",
        "avatarUrl": "https://example.com/avatar.jpg"
      },
      "activityType": "RATED",
      "media": {
        "mediaId": "1399",
        "mediaType": "SERIES",
        "title": "Game of Thrones",
        "posterUrl": "https://example.com/poster.jpg"
      },
      "metadata": {
        "rating": 8,
        "review": "Excelente"
      },
      "createdAt": "2026-05-20T10:00:00Z"
    }
  ],
  "nextCursor": "abc",
  "hasMore": true
}
```

#### Public lists for profile

```http
GET /profiles/{userId}/lists?status=<status>&mediaType=<mediaType>&limit=20&cursor=<cursor>
```

The MVP shows all public tracked items. Fine-grained visibility controls are out of scope.

### Existing endpoint improvements

#### Enriched feed

```http
GET /feed?limit=20&cursor=<cursor>
```

Expected response shape:

```json
{
  "items": [
    {
      "eventId": "evt_123",
      "user": {
        "userId": "user_123",
        "displayName": "Fulano",
        "avatarUrl": "https://example.com/avatar.jpg"
      },
      "activityType": "RATED",
      "media": {
        "mediaId": "1399",
        "mediaType": "SERIES",
        "title": "Game of Thrones",
        "posterUrl": "https://example.com/poster.jpg"
      },
      "metadata": {
        "rating": 8,
        "review": "Excelente"
      },
      "createdAt": "2026-05-20T10:00:00Z"
    }
  ],
  "nextCursor": "abc",
  "hasMore": true
}
```

#### Enriched discovery

```http
GET /discover?limit=20&cursor=<cursor>
```

Expected response shape:

```json
{
  "items": [
    {
      "userId": "user_123",
      "displayName": "Fulano",
      "avatarUrl": "https://example.com/avatar.jpg",
      "affinityScore": 0.82,
      "commonGenres": ["Anime", "Drama"],
      "commonMedia": [
        {
          "mediaId": "37854",
          "mediaType": "SERIES",
          "title": "One Piece",
          "posterUrl": "https://example.com/poster.jpg"
        }
      ],
      "isFollowedByMe": false
    }
  ],
  "nextCursor": "abc",
  "hasMore": true
}
```

## UI and UX

### Home preview

Home adds a social activity preview with three to five recent items and a `Ver tudo` CTA. If no profile or no feed is available, the section shows a light CTA to start Social.

### Feed

Activity cards show:

- actor avatar and display name;
- activity sentence;
- media title and poster;
- important metadata such as rating or review snippet;
- created time.

Interactions:

- tapping user/avatar opens `/social/profile/:userId`;
- tapping media opens `/series/:tmdbId` or `/movies/:tmdbId` based on `mediaType`;
- no reactions or comments in the MVP.

### Discover

Discover cards show:

- avatar and display name;
- affinity score;
- common genres;
- common media with title/poster when available;
- follow button.

After following, the button changes to `Seguindo`. Cards do not disappear immediately.

### Profile

The profile page shows:

- avatar;
- display name;
- follower/following counts;
- follow/unfollow button for other users;
- edit profile affordance for the current user;
- privacy indicator for the current user's private profile.

Profile tabs:

- Activity
- Lists
- Followers
- Following

Compatibility score is not shown on profiles. It remains specific to Discover.

## Privacy

Public profiles:

- appear in Discover;
- can be followed;
- can be viewed by other users;
- can have public activities shown in feeds.

Private profiles:

- do not appear in Discover;
- are unavailable as public profiles;
- can still use Social to follow others and view their own feed.

Recommended backend rule: private profile activity should not appear in other users' feeds or public profile pages.

## Error and Empty States

### Error handling

- `401`: handled by existing auth/session behavior.
- `404` on `GET /profiles/me`: show onboarding.
- `404` on another user's profile: show friendly unavailable profile state.
- `409` on follow: treat as already following and update UI to `Seguindo`.
- `5xx`/timeout: show retry affordance without discarding already loaded data where possible.

### Empty states

Feed with no followed users:

```txt
Seu feed ainda está quieto
Siga pessoas para ver avaliações, reviews e atividades recentes.
[Descobrir pessoas]
```

Discover with no suggestions:

```txt
Ainda não encontramos pessoas compatíveis
Continue acompanhando séries e filmes para melhorar suas sugestões.
```

Profile with no activity:

```txt
Nenhuma atividade pública ainda
Quando este usuário avaliar, concluir ou adicionar mídias, aparecerá aqui.
```

Profile with no public lists:

```txt
Nenhuma lista pública disponível
```

Followers/following empty states use direct messages such as `Nenhum seguidor ainda` and `Ainda não segue ninguém`.

## Pagination and Refresh

Feed and Discover use `RefreshIndicator`.

The models support `hasMore` and `nextCursor` from the beginning. Infinite scroll can be implemented in the MVP if straightforward; otherwise the structure is ready for a follow-up.

## Testing Strategy

### Unit tests

Models:

- parse social profile;
- parse enriched activity events;
- parse discover users with affinity and common media;
- parse follow relationships;
- parse public list items;
- parse paginated responses;
- tolerate optional `avatarUrl`, `posterUrl`, and metadata fields.

Repository:

- `GET /profiles/me` success;
- `GET /profiles/me` 404 propagation for onboarding;
- `PUT /profiles/me` payload;
- `GET /feed` parsing;
- `GET /discover` parsing;
- follow and unfollow calls;
- `409` follow behavior surfaced for viewmodel handling.

ViewModels:

- Social opens onboarding when my profile is missing;
- Social loads feed when profile exists;
- onboarding saves profile and loads suggestions;
- Discover changes card state to `Seguindo` after follow;
- Feed refresh works;
- Profile loads header, activity, and lists;
- profile 404/private maps to unavailable state.

### Widget tests

- Social without profile renders onboarding.
- Onboarding requires privacy choice.
- Empty feed shows Discover CTA.
- Feed renders activity text for known activity types.
- User tap navigates to profile.
- Media tap navigates to series/movie detail.
- Discover renders affinity and common media.
- Profile renders Activity, Lists, Followers, Following.
- Follow button changes to `Seguindo`.

## Acceptance Criteria

1. Bottom navigation shows Home, Search, My Lists, Social.
2. Recommend is available from Home, not bottom navigation.
3. First Social access without profile requires onboarding.
4. Onboarding requires display name and explicit privacy choice.
5. After onboarding, the user sees compatible people suggestions.
6. Social has Feed and Discover tabs.
7. Feed shows enriched cards with user, media, activity type, and main metadata.
8. Feed cards open user profiles and media details.
9. Empty feed explains how to populate the feed and links to Discover.
10. Discover shows affinity, common genres/media, and follow action.
11. Profile shows header, follow/unfollow, Activity, Lists, Followers, and Following.
12. Private or unavailable profiles show a friendly unavailable state.
13. Tests cover models, repository, viewmodels, and core widgets.
14. `dart analyze --fatal-infos` and `flutter test` pass.
