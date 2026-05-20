# Social Features Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Social as Lorebase's daily-engagement surface with onboarding, feed, discovery, and complete public profiles.

**Architecture:** Add a focused `lib/features/social` feature following existing Flutter/Riverpod/Freezed patterns. Keep backend access behind `SocialRepository`, keep screen state in small Riverpod viewmodels, and integrate navigation through the existing protected `ShellRoute`.

**Tech Stack:** Flutter 3.27, Dart 3.11, Riverpod codegen, GoRouter, Dio, Freezed/json_serializable, Material 3, cached_network_image, flutter_test.

---

## File Map

### Create

- `lib/features/social/data/models/social_media_model.dart` — compact media DTO used by feed/discover/profile lists.
- `lib/features/social/data/models/social_user_model.dart` — compact user DTO embedded in activity cards.
- `lib/features/social/data/models/social_profile_model.dart` — full profile DTO.
- `lib/features/social/data/models/activity_event_model.dart` — enriched activity DTO.
- `lib/features/social/data/models/discover_user_model.dart` — discover card DTO.
- `lib/features/social/data/models/follow_relationship_model.dart` — followers/following DTO.
- `lib/features/social/data/models/public_list_item_model.dart` — public profile list DTO.
- `lib/features/social/data/models/paginated_social_response.dart` — generic paginated response parser helpers.
- `lib/features/social/data/models/social_privacy.dart` — UI enum for onboarding privacy choice.
- `lib/features/social/data/repositories/social_repository.dart` — abstract repo + Dio implementation + provider.
- `lib/features/social/viewmodels/social_feed_viewmodel.dart` — feed state and actions.
- `lib/features/social/viewmodels/social_discover_viewmodel.dart` — discover state and follow action.
- `lib/features/social/viewmodels/social_onboarding_viewmodel.dart` — profile setup state and actions.
- `lib/features/social/viewmodels/social_profile_viewmodel.dart` — profile detail state and actions.
- `lib/features/social/viewmodels/social_follow_list_viewmodel.dart` — followers/following state.
- `lib/features/social/pages/social_page.dart` — top-level Social tab with onboarding gate and Feed/Discover tabs.
- `lib/features/social/pages/social_onboarding_page.dart` — onboarding form and initial follow suggestions.
- `lib/features/social/pages/social_profile_page.dart` — complete profile page.
- `lib/features/social/pages/edit_social_profile_page.dart` — edit own profile.
- `lib/features/social/widgets/social_activity_card.dart` — rich feed/profile activity card.
- `lib/features/social/widgets/discover_user_card.dart` — affinity user suggestion card.
- `lib/features/social/widgets/social_empty_feed.dart` — empty feed CTA.
- `lib/features/social/widgets/social_profile_header.dart` — profile header + follow/edit controls.
- `lib/features/social/widgets/social_follow_button.dart` — reusable follow/unfollow button.
- `lib/features/social/widgets/public_media_list_section.dart` — public lists display.
- Matching tests under `test/features/social/...`.

### Modify

- `lib/router.dart` — add Social routes and replace `/recommend` bottom-tab route usage with `/social`.
- `lib/core/widgets/scaffold_with_nav_bar.dart` — replace Recommend nav item with Social.
- `lib/features/dashboard/pages/dashboard_page.dart` — add recommendation section/card and social preview section.
- `lib/l10n/*.i18n.json` — add labels for Social, onboarding, feed, discovery, profile, empty states.
- Existing router/nav/dashboard tests and visual goldens as needed.

---

## Task 1: Social DTO Models

**Files:**

- Create: `lib/features/social/data/models/social_media_model.dart`
- Create: `lib/features/social/data/models/social_user_model.dart`
- Create: `lib/features/social/data/models/social_profile_model.dart`
- Create: `lib/features/social/data/models/activity_event_model.dart`
- Create: `lib/features/social/data/models/discover_user_model.dart`
- Create: `lib/features/social/data/models/follow_relationship_model.dart`
- Create: `lib/features/social/data/models/public_list_item_model.dart`
- Create: `lib/features/social/data/models/paginated_social_response.dart`
- Create: `lib/features/social/data/models/social_privacy.dart`
- Test: `test/features/social/data/social_models_test.dart`

- [ ] **Step 1: Write failing model tests**

Create `test/features/social/data/social_models_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/data/models/activity_event_model.dart';
import 'package:lorebase/features/social/data/models/discover_user_model.dart';
import 'package:lorebase/features/social/data/models/paginated_social_response.dart';
import 'package:lorebase/features/social/data/models/social_profile_model.dart';

void main() {
  group('social models', () {
    test('parses a social profile', () {
      final profile = SocialProfileModel.fromJson({
        'userId': 'user-1',
        'displayName': 'Fulano',
        'avatarUrl': 'https://example.com/a.jpg',
        'isPublic': true,
        'followingCount': 3,
        'followerCount': 7,
        'isFollowedByMe': false,
        'createdAt': '2026-05-20T10:00:00Z',
        'updatedAt': '2026-05-20T11:00:00Z',
      });

      expect(profile.userId, 'user-1');
      expect(profile.displayName, 'Fulano');
      expect(profile.isPublic, isTrue);
      expect(profile.followerCount, 7);
    });

    test('parses enriched activity event', () {
      final event = ActivityEventModel.fromJson({
        'eventId': 'evt-1',
        'user': {
          'userId': 'user-1',
          'displayName': 'Fulano',
          'avatarUrl': null,
        },
        'activityType': 'RATED',
        'media': {
          'mediaId': '1399',
          'mediaType': 'SERIES',
          'title': 'Game of Thrones',
          'posterUrl': 'https://example.com/p.jpg',
        },
        'metadata': {'rating': 8},
        'createdAt': '2026-05-20T10:00:00Z',
      });

      expect(event.eventId, 'evt-1');
      expect(event.user.displayName, 'Fulano');
      expect(event.media.mediaType, 'SERIES');
      expect(event.metadata['rating'], 8);
    });

    test('parses discover user with common media', () {
      final user = DiscoverUserModel.fromJson({
        'userId': 'user-2',
        'displayName': 'Maria',
        'avatarUrl': '',
        'affinityScore': 0.82,
        'commonGenres': ['Anime', 'Drama'],
        'commonMedia': [
          {
            'mediaId': '37854',
            'mediaType': 'SERIES',
            'title': 'One Piece',
            'posterUrl': null,
          }
        ],
        'isFollowedByMe': false,
      });

      expect(user.affinityScore, 0.82);
      expect(user.commonGenres, ['Anime', 'Drama']);
      expect(user.commonMedia.single.title, 'One Piece');
      expect(user.isFollowedByMe, isFalse);
    });

    test('parses paginated response', () {
      final response = PaginatedSocialResponse<ActivityEventModel>.fromJson(
        {
          'items': [
            {
              'eventId': 'evt-1',
              'user': {'userId': 'user-1', 'displayName': 'Fulano'},
              'activityType': 'COMPLETED',
              'media': {'mediaId': '1', 'mediaType': 'MOVIE', 'title': 'Movie'},
              'metadata': {},
              'createdAt': '2026-05-20T10:00:00Z',
            }
          ],
          'nextCursor': 'next',
          'hasMore': true,
        },
        ActivityEventModel.fromJson,
      );

      expect(response.items, hasLength(1));
      expect(response.nextCursor, 'next');
      expect(response.hasMore, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run tests and verify failure**

Run:

```bash
flutter test test/features/social/data/social_models_test.dart
```

Expected: FAIL because social model files do not exist.

- [ ] **Step 3: Implement model files**

Create Freezed models with these definitions:

```dart
// lib/features/social/data/models/social_media_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_media_model.freezed.dart';
part 'social_media_model.g.dart';

@freezed
abstract class SocialMediaModel with _$SocialMediaModel {
  const factory SocialMediaModel({
    required String mediaId,
    required String mediaType,
    required String title,
    String? posterUrl,
  }) = _SocialMediaModel;

  factory SocialMediaModel.fromJson(Map<String, dynamic> json) =>
      _$SocialMediaModelFromJson(json);
}
```

```dart
// lib/features/social/data/models/social_user_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_user_model.freezed.dart';
part 'social_user_model.g.dart';

@freezed
abstract class SocialUserModel with _$SocialUserModel {
  const factory SocialUserModel({
    required String userId,
    required String displayName,
    String? avatarUrl,
  }) = _SocialUserModel;

  factory SocialUserModel.fromJson(Map<String, dynamic> json) =>
      _$SocialUserModelFromJson(json);
}
```

```dart
// lib/features/social/data/models/social_profile_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_profile_model.freezed.dart';
part 'social_profile_model.g.dart';

@freezed
abstract class SocialProfileModel with _$SocialProfileModel {
  const factory SocialProfileModel({
    required String userId,
    required String displayName,
    String? avatarUrl,
    required bool isPublic,
    required int followingCount,
    required int followerCount,
    @Default(false) bool isFollowedByMe,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SocialProfileModel;

  factory SocialProfileModel.fromJson(Map<String, dynamic> json) =>
      _$SocialProfileModelFromJson(json);
}
```

```dart
// lib/features/social/data/models/activity_event_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'social_media_model.dart';
import 'social_user_model.dart';

part 'activity_event_model.freezed.dart';
part 'activity_event_model.g.dart';

@freezed
abstract class ActivityEventModel with _$ActivityEventModel {
  const factory ActivityEventModel({
    required String eventId,
    required SocialUserModel user,
    required String activityType,
    required SocialMediaModel media,
    @Default(<String, dynamic>{}) Map<String, dynamic> metadata,
    required DateTime createdAt,
  }) = _ActivityEventModel;

  factory ActivityEventModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityEventModelFromJson(json);
}
```

```dart
// lib/features/social/data/models/discover_user_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'social_media_model.dart';

part 'discover_user_model.freezed.dart';
part 'discover_user_model.g.dart';

@freezed
abstract class DiscoverUserModel with _$DiscoverUserModel {
  const factory DiscoverUserModel({
    required String userId,
    required String displayName,
    String? avatarUrl,
    required double affinityScore,
    @Default(<String>[]) List<String> commonGenres,
    @Default(<SocialMediaModel>[]) List<SocialMediaModel> commonMedia,
    @Default(false) bool isFollowedByMe,
  }) = _DiscoverUserModel;

  factory DiscoverUserModel.fromJson(Map<String, dynamic> json) =>
      _$DiscoverUserModelFromJson(json);
}
```

```dart
// lib/features/social/data/models/follow_relationship_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow_relationship_model.freezed.dart';
part 'follow_relationship_model.g.dart';

@freezed
abstract class FollowRelationshipModel with _$FollowRelationshipModel {
  const factory FollowRelationshipModel({
    String? followerId,
    String? followedId,
    DateTime? followedAt,
  }) = _FollowRelationshipModel;

  factory FollowRelationshipModel.fromJson(Map<String, dynamic> json) =>
      _$FollowRelationshipModelFromJson(json);
}
```

```dart
// lib/features/social/data/models/public_list_item_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'social_media_model.dart';

part 'public_list_item_model.freezed.dart';
part 'public_list_item_model.g.dart';

@freezed
abstract class PublicListItemModel with _$PublicListItemModel {
  const factory PublicListItemModel({
    required String mediaId,
    required String mediaType,
    required String status,
    int? rating,
    String? review,
    SocialMediaModel? media,
    DateTime? updatedAt,
  }) = _PublicListItemModel;

  factory PublicListItemModel.fromJson(Map<String, dynamic> json) =>
      _$PublicListItemModelFromJson(json);
}
```

```dart
// lib/features/social/data/models/paginated_social_response.dart
class PaginatedSocialResponse<T> {
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;

  const PaginatedSocialResponse({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  factory PaginatedSocialResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawItems = (json['items'] as List?) ?? const [];
    return PaginatedSocialResponse<T>(
      items: rawItems
          .map((item) => fromJsonT(Map<String, dynamic>.from(item as Map)))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
```

```dart
// lib/features/social/data/models/social_privacy.dart
enum SocialPrivacy {
  public,
  private;

  bool get isPublic => this == SocialPrivacy.public;
}
```

- [ ] **Step 4: Generate code**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: generated Freezed/JSON files for social models.

- [ ] **Step 5: Run model tests**

Run:

```bash
flutter test test/features/social/data/social_models_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/social/data/models test/features/social/data/social_models_test.dart
git commit -m "feat: add social data models"
```

---

## Task 2: Social Repository

**Files:**

- Create: `lib/features/social/data/repositories/social_repository.dart`
- Test: `test/features/social/data/social_repository_test.dart`

- [ ] **Step 1: Write failing repository tests**

Create `test/features/social/data/social_repository_test.dart` using a fake Dio adapter or Mockito. Test these exact behaviors:

```dart
// Required tests:
// - getMyProfile calls GET /profiles/me and parses SocialProfileModel.
// - updateMyProfile calls PUT /profiles/me with displayName, avatarUrl, isPublic.
// - getFeed calls GET /feed with limit/cursor and parses PaginatedSocialResponse<ActivityEventModel>.
// - discoverUsers calls GET /discover and parses DiscoverUserModel.
// - followUser calls POST /follows/{userId}.
// - unfollowUser calls DELETE /follows/{userId}.
```

Use the current repository test style in the codebase. If no Dio adapter helper exists, create a small test-local fake by subclassing `HttpClientAdapter`.

- [ ] **Step 2: Run tests and verify failure**

```bash
flutter test test/features/social/data/social_repository_test.dart
```

Expected: FAIL because repository does not exist.

- [ ] **Step 3: Implement repository**

Create `lib/features/social/data/repositories/social_repository.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/providers/core_providers.dart';
import '../models/activity_event_model.dart';
import '../models/discover_user_model.dart';
import '../models/follow_relationship_model.dart';
import '../models/paginated_social_response.dart';
import '../models/public_list_item_model.dart';
import '../models/social_profile_model.dart';

abstract class SocialRepository {
  Future<SocialProfileModel> getMyProfile();

  Future<SocialProfileModel> updateMyProfile({
    required String displayName,
    String? avatarUrl,
    required bool isPublic,
  });

  Future<SocialProfileModel> getProfile(String userId);
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);

  Future<PaginatedSocialResponse<ActivityEventModel>> getFeed({
    int limit = 20,
    String? cursor,
  });

  Future<PaginatedSocialResponse<DiscoverUserModel>> discoverUsers({
    int limit = 20,
    String? cursor,
  });

  Future<PaginatedSocialResponse<ActivityEventModel>> getUserActivity(
    String userId, {
    int limit = 20,
    String? cursor,
  });

  Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowers(
    String userId, {
    int limit = 20,
    String? cursor,
  });

  Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowing(
    String userId, {
    int limit = 20,
    String? cursor,
  });

  Future<PaginatedSocialResponse<PublicListItemModel>> getPublicLists(
    String userId, {
    String? status,
    String? mediaType,
    int limit = 20,
    String? cursor,
  });
}

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return SocialRepositoryImpl(ref.watch(dioProvider));
});

class SocialRepositoryImpl implements SocialRepository {
  final Dio _dio;

  SocialRepositoryImpl(this._dio);

  @override
  Future<SocialProfileModel> getMyProfile() async {
    final response = await _get('/profiles/me', failureMessage: 'Failed to load social profile');
    return SocialProfileModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  @override
  Future<SocialProfileModel> updateMyProfile({
    required String displayName,
    String? avatarUrl,
    required bool isPublic,
  }) async {
    final response = await _put(
      '/profiles/me',
      data: {
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'isPublic': isPublic,
      },
      failureMessage: 'Failed to update social profile',
    );
    return SocialProfileModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  @override
  Future<SocialProfileModel> getProfile(String userId) async {
    final response = await _get('/profiles/$userId', failureMessage: 'Failed to load profile');
    return SocialProfileModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  @override
  Future<void> followUser(String userId) async {
    await _post('/follows/$userId', failureMessage: 'Failed to follow user');
  }

  @override
  Future<void> unfollowUser(String userId) async {
    await _delete('/follows/$userId', failureMessage: 'Failed to unfollow user');
  }

  @override
  Future<PaginatedSocialResponse<ActivityEventModel>> getFeed({int limit = 20, String? cursor}) async {
    final response = await _get(
      '/feed',
      queryParameters: {'limit': limit, 'cursor': ?cursor},
      failureMessage: 'Failed to load feed',
    );
    return PaginatedSocialResponse<ActivityEventModel>.fromJson(
      Map<String, dynamic>.from(response.data as Map),
      ActivityEventModel.fromJson,
    );
  }

  @override
  Future<PaginatedSocialResponse<DiscoverUserModel>> discoverUsers({int limit = 20, String? cursor}) async {
    final response = await _get(
      '/discover',
      queryParameters: {'limit': limit, 'cursor': ?cursor},
      failureMessage: 'Failed to discover users',
    );
    return PaginatedSocialResponse<DiscoverUserModel>.fromJson(
      Map<String, dynamic>.from(response.data as Map),
      DiscoverUserModel.fromJson,
    );
  }

  @override
  Future<PaginatedSocialResponse<ActivityEventModel>> getUserActivity(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async {
    final response = await _get(
      '/profiles/$userId/activity',
      queryParameters: {'limit': limit, 'cursor': ?cursor},
      failureMessage: 'Failed to load profile activity',
    );
    return PaginatedSocialResponse<ActivityEventModel>.fromJson(
      Map<String, dynamic>.from(response.data as Map),
      ActivityEventModel.fromJson,
    );
  }

  @override
  Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowers(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async {
    final path = userId == 'me' ? '/follows/me/followers' : '/follows/$userId/followers';
    final response = await _get(
      path,
      queryParameters: {'limit': limit, 'cursor': ?cursor},
      failureMessage: 'Failed to load followers',
    );
    return PaginatedSocialResponse<FollowRelationshipModel>.fromJson(
      Map<String, dynamic>.from(response.data as Map),
      FollowRelationshipModel.fromJson,
    );
  }

  @override
  Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowing(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async {
    final path = userId == 'me' ? '/follows/me/following' : '/follows/$userId/following';
    final response = await _get(
      path,
      queryParameters: {'limit': limit, 'cursor': ?cursor},
      failureMessage: 'Failed to load following',
    );
    return PaginatedSocialResponse<FollowRelationshipModel>.fromJson(
      Map<String, dynamic>.from(response.data as Map),
      FollowRelationshipModel.fromJson,
    );
  }

  @override
  Future<PaginatedSocialResponse<PublicListItemModel>> getPublicLists(
    String userId, {
    String? status,
    String? mediaType,
    int limit = 20,
    String? cursor,
  }) async {
    final response = await _get(
      '/profiles/$userId/lists',
      queryParameters: {
        'status': ?status,
        'mediaType': ?mediaType,
        'limit': limit,
        'cursor': ?cursor,
      },
      failureMessage: 'Failed to load public lists',
    );
    return PaginatedSocialResponse<PublicListItemModel>.fromJson(
      Map<String, dynamic>.from(response.data as Map),
      PublicListItemModel.fromJson,
    );
  }

  Future<Response<dynamic>> _get(
    String path, {
    Map<String, dynamic>? queryParameters,
    required String failureMessage,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? failureMessage, statusCode: e.response?.statusCode);
    }
  }

  Future<Response<dynamic>> _post(String path, {required String failureMessage}) async {
    try {
      return await _dio.post(path);
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? failureMessage, statusCode: e.response?.statusCode);
    }
  }

  Future<Response<dynamic>> _put(String path, {Object? data, required String failureMessage}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? failureMessage, statusCode: e.response?.statusCode);
    }
  }

  Future<Response<dynamic>> _delete(String path, {required String failureMessage}) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? failureMessage, statusCode: e.response?.statusCode);
    }
  }
}
```

- [ ] **Step 4: Run repository tests**

```bash
flutter test test/features/social/data/social_repository_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/social/data/repositories test/features/social/data/social_repository_test.dart
git commit -m "feat: add social repository"
```

---

## Task 3: Feed and Discover ViewModels

**Files:**

- Create: `lib/features/social/viewmodels/social_feed_viewmodel.dart`
- Create: `lib/features/social/viewmodels/social_discover_viewmodel.dart`
- Test: `test/features/social/viewmodels/social_feed_viewmodel_test.dart`
- Test: `test/features/social/viewmodels/social_discover_viewmodel_test.dart`

- [ ] **Step 1: Write failing viewmodel tests**

Test these behaviors with a fake `SocialRepository` override:

```dart
// Feed:
// - build loads first page from getFeed.
// - refresh reloads and replaces items.
// - failed load exposes AsyncError.
// Discover:
// - build loads discoverUsers.
// - followUser calls repository and marks the user as followed.
// - follow conflict with statusCode 409 marks the user as followed.
```

- [ ] **Step 2: Run tests and verify failure**

```bash
flutter test test/features/social/viewmodels/social_feed_viewmodel_test.dart test/features/social/viewmodels/social_discover_viewmodel_test.dart
```

Expected: FAIL because viewmodels do not exist.

- [ ] **Step 3: Implement feed viewmodel**

Use Riverpod codegen:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/activity_event_model.dart';
import '../data/models/paginated_social_response.dart';
import '../data/repositories/social_repository.dart';

part 'social_feed_viewmodel.g.dart';

@riverpod
class SocialFeedViewModel extends _$SocialFeedViewModel {
  @override
  Future<PaginatedSocialResponse<ActivityEventModel>> build() async {
    return ref.watch(socialRepositoryProvider).getFeed();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(socialRepositoryProvider).getFeed());
  }
}
```

- [ ] **Step 4: Implement discover viewmodel**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/exceptions.dart';
import '../data/models/discover_user_model.dart';
import '../data/models/paginated_social_response.dart';
import '../data/repositories/social_repository.dart';

part 'social_discover_viewmodel.g.dart';

@riverpod
class SocialDiscoverViewModel extends _$SocialDiscoverViewModel {
  @override
  Future<PaginatedSocialResponse<DiscoverUserModel>> build() async {
    return ref.watch(socialRepositoryProvider).discoverUsers();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(socialRepositoryProvider).discoverUsers());
  }

  Future<void> followUser(String userId) async {
    final previous = state.valueOrNull;
    try {
      await ref.read(socialRepositoryProvider).followUser(userId);
    } on ServerException catch (e) {
      if (e.statusCode != 409) rethrow;
    }
    if (previous == null) return;
    state = AsyncData(
      PaginatedSocialResponse<DiscoverUserModel>(
        items: previous.items
            .map((user) => user.userId == userId ? user.copyWith(isFollowedByMe: true) : user)
            .toList(),
        nextCursor: previous.nextCursor,
        hasMore: previous.hasMore,
      ),
    );
  }
}
```

- [ ] **Step 5: Generate code and run tests**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/social/viewmodels/social_feed_viewmodel_test.dart test/features/social/viewmodels/social_discover_viewmodel_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/social/viewmodels test/features/social/viewmodels
git commit -m "feat: add social feed and discover state"
```

---

## Task 4: Onboarding and Profile ViewModels

**Files:**

- Create: `lib/features/social/viewmodels/social_onboarding_viewmodel.dart`
- Create: `lib/features/social/viewmodels/social_profile_viewmodel.dart`
- Create: `lib/features/social/viewmodels/social_follow_list_viewmodel.dart`
- Create: `lib/features/social/viewmodels/social_public_lists_viewmodel.dart`
- Test: matching tests under `test/features/social/viewmodels/`

- [ ] **Step 1: Write failing tests**

Required behaviors:

```dart
// Onboarding:
// - saveProfile sends displayName, avatarUrl, and privacy.isPublic.
// - displayName blank produces validation error state and no repository call.
// Profile:
// - build loads profile, activity, and public lists for userId.
// - follow toggles profile.isFollowedByMe true and increments followerCount.
// - unfollow toggles false and decrements followerCount without going below zero.
// Follow list:
// - followers mode calls getFollowers.
// - following mode calls getFollowing.
```

- [ ] **Step 2: Implement state containers**

Create simple immutable state classes in the same viewmodel files when useful:

```dart
class SocialProfileDetailState {
  final SocialProfileModel profile;
  final PaginatedSocialResponse<ActivityEventModel> activity;
  final PaginatedSocialResponse<PublicListItemModel> publicLists;

  const SocialProfileDetailState({
    required this.profile,
    required this.activity,
    required this.publicLists,
  });

  SocialProfileDetailState copyWith({SocialProfileModel? profile}) {
    return SocialProfileDetailState(
      profile: profile ?? this.profile,
      activity: activity,
      publicLists: publicLists,
    );
  }
}
```

- [ ] **Step 3: Implement viewmodels with repository calls**

Use `@riverpod` families for user-specific profile and list viewmodels. Keep follow/unfollow state updates local and deterministic.

- [ ] **Step 4: Generate code and run tests**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/social/viewmodels
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/social/viewmodels test/features/social/viewmodels
git commit -m "feat: add social onboarding and profile state"
```

---

## Task 5: Social Widgets

**Files:**

- Create widgets listed in File Map.
- Test: `test/features/social/widgets/social_activity_card_test.dart`
- Test: `test/features/social/widgets/discover_user_card_test.dart`
- Test: `test/features/social/widgets/social_empty_feed_test.dart`
- Test: `test/features/social/widgets/social_profile_header_test.dart`

- [ ] **Step 1: Write failing widget tests**

Required assertions:

```dart
// Activity card:
// - RATED renders "avaliou" and rating.
// - COMPLETED renders "completou".
// - tapping user invokes onUserTap.
// - tapping media invokes onMediaTap.
// Discover card:
// - renders affinity as percentage.
// - renders common genre chips.
// - follow button invokes onFollow.
// - followed state shows "Seguindo".
// Empty feed:
// - renders educational copy and CTA.
// Profile header:
// - renders counts and follow/edit button variant.
```

- [ ] **Step 2: Implement widgets**

Implement widgets with constructor callbacks instead of direct navigation. Example for `SocialActivityCard`:

```dart
class SocialActivityCard extends StatelessWidget {
  final ActivityEventModel event;
  final VoidCallback onUserTap;
  final VoidCallback onMediaTap;

  const SocialActivityCard({
    super.key,
    required this.event,
    required this.onUserTap,
    required this.onMediaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: GestureDetector(
          onTap: onUserTap,
          child: CircleAvatar(child: Text(event.user.displayName.characters.first.toUpperCase())),
        ),
        title: Text('${event.user.displayName} ${_activityVerb(event.activityType)} ${event.media.title}'),
        subtitle: Text(_metadataText(event)),
        onTap: onMediaTap,
      ),
    );
  }

  String _activityVerb(String type) {
    return switch (type) {
      'RATED' => 'avaliou',
      'REVIEWED' => 'escreveu uma review de',
      'COMPLETED' => 'completou',
      'STARTED_WATCHING' => 'começou',
      'DROPPED' => 'abandonou',
      'ADDED_TO_LIST' => 'adicionou à lista',
      _ => 'interagiu com',
    };
  }

  String _metadataText(ActivityEventModel event) {
    final rating = event.metadata['rating'];
    if (rating != null) return '⭐ $rating/10';
    final review = event.metadata['review'];
    if (review is String && review.isNotEmpty) return review;
    return event.media.mediaType;
  }
}
```

- [ ] **Step 3: Run widget tests**

```bash
flutter test test/features/social/widgets
```

Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add lib/features/social/widgets test/features/social/widgets
git commit -m "feat: add social widgets"
```

---

## Task 6: Social Pages

**Files:**

- Create: `lib/features/social/pages/social_page.dart`
- Create: `lib/features/social/pages/social_onboarding_page.dart`
- Create: `lib/features/social/pages/social_profile_page.dart`
- Create: `lib/features/social/pages/edit_social_profile_page.dart`
- Test: matching page tests under `test/features/social/pages/`

- [ ] **Step 1: Write failing page tests**

Required assertions:

```dart
// Social page:
// - missing profile state renders onboarding.
// - existing profile renders Feed and Discover tabs.
// - empty feed renders CTA.
// Onboarding page:
// - privacy choice is required.
// - submit calls saveProfile.
// Profile page:
// - renders Activity, Lists, Followers, Following tabs.
// - unavailable profile shows friendly message.
```

- [ ] **Step 2: Implement `SocialPage`**

`SocialPage` should watch a provider that attempts `getMyProfile`. If the provider errors with status code 404, render `SocialOnboardingPage`. Otherwise render `DefaultTabController(length: 2)` with Feed and Discover.

- [ ] **Step 3: Implement onboarding page**

Use a `Form`, `TextEditingController`, radio buttons for `SocialPrivacy.public/private`, and submit through `SocialOnboardingViewModel`.

- [ ] **Step 4: Implement profile page**

Use `DefaultTabController(length: 4)` and compose existing widgets:

```txt
Header
[Atividade] [Listas] [Seguidores] [Seguindo]
```

- [ ] **Step 5: Run page tests**

```bash
flutter test test/features/social/pages
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/social/pages test/features/social/pages
git commit -m "feat: add social pages"
```

---

## Task 7: Navigation and Bottom Nav Integration

**Files:**

- Modify: `lib/router.dart`
- Modify: `lib/core/widgets/scaffold_with_nav_bar.dart`
- Modify: `lib/l10n/*.i18n.json`
- Test: `test/router_test.dart`
- Test: `test/core/widgets/scaffold_with_nav_bar_test.dart`

- [ ] **Step 1: Write failing navigation tests**

Update tests to expect:

```dart
// Bottom nav labels include Home, Search, My Lists, Social.
// Tapping index 3 navigates to /social.
// /social/profile/:userId builds a SocialProfilePage.
// /recommend is no longer a bottom nav destination.
```

- [ ] **Step 2: Update translations**

Add keys to all `lib/l10n/*.i18n.json` files:

```json
{
  "nav_social": "Social",
  "social_feed": "Feed",
  "social_discover": "Descobrir",
  "social_empty_feed_title": "Seu feed ainda está quieto",
  "social_empty_feed_body": "Siga pessoas para ver avaliações, reviews e atividades recentes.",
  "social_discover_people": "Descobrir pessoas"
}
```

Use equivalent English and Spanish text in `en*.i18n.json` and `es.i18n.json`.

- [ ] **Step 3: Update bottom nav**

In `ScaffoldWithNavBar`, map `/social` and `/social/...` to index 3 and navigate index 3 to `/social`. Replace recommend icons with social icons such as `Icons.people_outline` and `Icons.people`.

- [ ] **Step 4: Update router**

Import social pages and add routes in the `ShellRoute`:

```dart
GoRoute(
  path: '/social',
  pageBuilder: (context, state) => NoTransitionPage(
    key: state.pageKey,
    child: const SocialPage(),
  ),
),
GoRoute(
  path: '/social/profile/me',
  builder: (context, state) => const SocialProfilePage(userId: 'me'),
),
GoRoute(
  path: '/social/profile/edit',
  builder: (context, state) => const EditSocialProfilePage(),
),
GoRoute(
  path: '/social/profile/:userId',
  builder: (context, state) => SocialProfilePage(userId: state.pathParameters['userId']!),
),
```

Keep `/recommend` route if Home still links to it during transition, but remove it from bottom nav.

- [ ] **Step 5: Generate i18n and run tests**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/router_test.dart test/core/widgets/scaffold_with_nav_bar_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/router.dart lib/core/widgets/scaffold_with_nav_bar.dart lib/l10n test/router_test.dart test/core/widgets/scaffold_with_nav_bar_test.dart
git commit -m "feat: add social navigation"
```

---

## Task 8: Home Social Preview and Recommendation Placement

**Files:**

- Modify: `lib/features/dashboard/pages/dashboard_page.dart`
- Modify/create dashboard widgets if the existing file becomes too large.
- Test: `test/features/dashboard/pages/dashboard_page_test.dart`

- [ ] **Step 1: Write failing dashboard tests**

Required assertions:

```dart
// Dashboard renders a social preview section title.
// Social preview has a CTA that navigates to /social.
// Recommendation content is still reachable from Dashboard.
```

- [ ] **Step 2: Implement social preview section**

Add a small section that watches `SocialFeedViewModel` and displays up to three activity rows. If profile/feed is unavailable, show a lightweight CTA to Social.

- [ ] **Step 3: Move recommendation affordance into Home**

Add a card/button labeled with the existing recommendation copy that navigates to `/recommend` or embeds `RecommendationPage` content if already structured for reuse. Prefer a card link for minimal coupling.

- [ ] **Step 4: Run dashboard tests**

```bash
flutter test test/features/dashboard/pages/dashboard_page_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/dashboard test/features/dashboard/pages/dashboard_page_test.dart
git commit -m "feat: add social preview to dashboard"
```

---

## Task 9: End-to-End Verification

**Files:**

- Modify tests/goldens only if affected by UI changes.

- [ ] **Step 1: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: completes without conflicting output errors.

- [ ] **Step 2: Analyze**

```bash
dart analyze --fatal-infos
```

Expected: no errors, warnings, or infos.

- [ ] **Step 3: Run tests**

```bash
flutter test
```

Expected: all tests pass.

- [ ] **Step 4: Update visual goldens if legitimate**

If visual tests fail only because bottom nav/dashboard UI intentionally changed, update goldens using the project's established command or test harness. Inspect diffs before committing.

- [ ] **Step 5: Run final check**

```bash
make check
```

Expected: analyze and coverage gate pass.

- [ ] **Step 6: Commit verification changes**

```bash
git status --short
git add .
git commit -m "test: verify social feature integration"
```

Only commit if there are legitimate remaining test/golden updates.

---

## Self-Review Notes

Spec coverage:

- Mandatory onboarding: Task 4 and Task 6.
- Explicit privacy choice: Task 1, Task 4, Task 6.
- Feed and Discover tabs: Task 6.
- Rich feed cards and navigation callbacks: Task 5 and Task 6.
- Discover affinity/common media/follow: Task 1, Task 3, Task 5.
- Complete profile with Activity, Lists, Followers, Following: Task 4 and Task 6.
- Home preview and recommendation relocation: Task 8.
- Bottom nav replacement: Task 7.
- Backend contracts: Task 2.
- Tests and acceptance criteria: Tasks 1-9.

Placeholder scan: this plan avoids TBD/TODO markers and gives exact files, commands, and behavior checks.

Type consistency: model, repository, and viewmodel names use the same names throughout the plan.
