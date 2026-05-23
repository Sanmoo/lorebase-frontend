# Social Profile Unavailable Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `/social/profile/me` render the profile header when the profile API succeeds, even when optional fields are blank and activity/list data is partial or malformed.

**Architecture:** Normalize social API payloads at the repository boundary before passing JSON into Freezed models, because this is where backend compatibility belongs. Change `SocialProfileViewModel` so profile loading is authoritative and activity/list failures degrade to empty sections instead of failing the entire profile screen.

**Tech Stack:** Flutter 3.27, Dart, Riverpod codegen, Freezed/json_serializable, Dio, flutter_test.

---

## File Structure

- Modify `test/features/social/data/social_repository_test.dart`
  - Add regression tests for BFF-observed payload shapes: profile payload with `username` but blank/missing `displayName`, and public-list item with `updatedAt: ''`.
- Modify `lib/features/social/data/repositories/social_repository.dart`
  - Normalize profile JSON defaults before `SocialProfileModel.fromJson`.
  - Normalize paginated item JSON before model parsing through an optional mapper argument.
  - Use that mapper for `getPublicLists` to convert blank `updatedAt` to `null`.
- Modify `test/features/social/viewmodels/social_profile_viewmodel_test.dart`
  - Add regression tests proving the profile state still loads when activity or public lists fail.
- Modify `lib/features/social/viewmodels/social_profile_viewmodel.dart`
  - Load profile first.
  - Load activity and lists independently with fallback empty pages.
  - Keep follow/unfollow behavior unchanged.
- Optional verification only: `test/features/social/pages/social_pages_test.dart`
  - Existing widget tests should continue to pass. Do not modify unless an assertion must be adjusted because of a deliberate behavior change.

---

### Task 1: Normalize observed repository payloads

**Files:**
- Modify: `test/features/social/data/social_repository_test.dart`
- Modify: `lib/features/social/data/repositories/social_repository.dart`

- [ ] **Step 1: Add failing repository tests**

Add these tests inside `group('SocialRepositoryImpl', () { ... })` in `test/features/social/data/social_repository_test.dart`, near the existing `getMyProfile tolerates BFF profile responses without timestamps` and `getPublicLists calls lists endpoint and parses list items` tests:

```dart
    test(
      'getMyProfile falls back to username or generic display name',
      () async {
        final dio = Dio()
          ..httpClientAdapter = MockAdapter(
            onFetch: (_) => _jsonBody({
              'userId': 'user-1',
              'username': '',
              'avatarUrl': '',
              'isPublic': true,
              'followingCount': 0,
              'followerCount': 0,
            }),
          );
        final repo = SocialRepositoryImpl(dio);

        final result = await repo.getMyProfile();

        expect(result.displayName, 'Usuário');
        expect(result.avatarUrl, isNull);
      },
    );

    test('getPublicLists tolerates blank updatedAt values', () async {
      final dio = Dio()
        ..httpClientAdapter = MockAdapter(
          onFetch: (_) => _jsonBody({
            'items': [
              {
                'mediaId': 'media-1',
                'mediaType': 'SERIES',
                'status': 'PLAN_TO_WATCH',
                'updatedAt': '',
              },
            ],
            'nextCursor': null,
            'hasMore': false,
          }),
        );
      final repo = SocialRepositoryImpl(dio);

      final result = await repo.getPublicLists('user-1');

      expect(result.items.single.mediaId, 'media-1');
      expect(result.items.single.status, 'PLAN_TO_WATCH');
      expect(result.items.single.updatedAt, isNull);
    });
```

- [ ] **Step 2: Run repository tests and verify RED**

Run:

```bash
flutter test test/features/social/data/social_repository_test.dart
```

Expected result:

- The new display-name fallback test fails with a missing `displayName` cast/type error, or `avatarUrl` remains `''`.
- The new public-list test fails with a `FormatException` from parsing `updatedAt: ''`.

- [ ] **Step 3: Implement minimal repository normalization**

In `lib/features/social/data/repositories/social_repository.dart`, update `getPublicLists`, `_getPaginated`, and `_profileFromResponse` as follows.

Change `getPublicLists` to pass a normalization mapper:

```dart
  @override
  Future<PaginatedSocialResponse<PublicListItemModel>> getPublicLists(
    String userId, {
    String? status,
    String? mediaType,
    int limit = 20,
    String? cursor,
  }) async {
    return _getPaginated(
      '/profiles/$userId/lists',
      queryParameters: {
        'status': ?status,
        'mediaType': ?mediaType,
        'limit': limit,
        'cursor': ?cursor,
      },
      fromJson: PublicListItemModel.fromJson,
      normalizeItem: _normalizePublicListItem,
      fallbackMessage: 'Failed to load public lists',
    );
  }
```

Change `_getPaginated` to accept and apply `normalizeItem`:

```dart
  Future<PaginatedSocialResponse<T>> _getPaginated<T>(
    String path, {
    required Map<String, dynamic> queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic> Function(Map<String, dynamic>)? normalizeItem,
    required String fallbackMessage,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return PaginatedSocialResponse<T>.fromJson(
        _responseMap(response.data),
        (json) => fromJson(normalizeItem?.call(json) ?? json),
      );
    } on DioException catch (e) {
      throw _repositoryException(e, fallbackMessage);
    }
  }
```

Replace `_profileFromResponse` with:

```dart
  SocialProfileModel _profileFromResponse(dynamic data) {
    final json = _responseMap(data);
    const epoch = '1970-01-01T00:00:00.000Z';
    json['createdAt'] ??= epoch;
    json['updatedAt'] ??= epoch;
    if ((json['displayName'] as String?)?.trim().isEmpty ?? true) {
      final username = (json['username'] as String?)?.trim();
      json['displayName'] = username == null || username.isEmpty
          ? 'Usuário'
          : username;
    }
    if ((json['avatarUrl'] as String?)?.trim().isEmpty ?? false) {
      json['avatarUrl'] = null;
    }
    if (json['isPublic'] == null) {
      json['isPublic'] = true;
    }
    json['followingCount'] ??= 0;
    json['followerCount'] ??= 0;
    if (json['isFollowedByMe'] == null && json['isFollowing'] is bool) {
      json['isFollowedByMe'] = json['isFollowing'];
    }
    return SocialProfileModel.fromJson(json);
  }
```

Add this helper below `_profileFromResponse`:

```dart
  Map<String, dynamic> _normalizePublicListItem(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    if ((normalized['updatedAt'] as String?)?.trim().isEmpty ?? false) {
      normalized['updatedAt'] = null;
    }
    return normalized;
  }
```

- [ ] **Step 4: Run repository tests and verify GREEN**

Run:

```bash
flutter test test/features/social/data/social_repository_test.dart
```

Expected result: all tests in `social_repository_test.dart` pass.

- [ ] **Step 5: Commit repository normalization**

Run:

```bash
git add test/features/social/data/social_repository_test.dart lib/features/social/data/repositories/social_repository.dart
git commit -m "fix: normalize social profile payloads"
```

---

### Task 2: Degrade profile detail subresources gracefully

**Files:**
- Modify: `test/features/social/viewmodels/social_profile_viewmodel_test.dart`
- Modify: `lib/features/social/viewmodels/social_profile_viewmodel.dart`

- [ ] **Step 1: Add failing ViewModel tests**

In `test/features/social/viewmodels/social_profile_viewmodel_test.dart`, add two tests after `build loads me profile endpoint and uses resolved userId for details`:

```dart
  test('build keeps profile when user activity fails', () async {
    final repo = _FakeSocialRepository(activityError: Exception('activity'));
    final container = ProviderContainer(
      overrides: [socialRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final state = await container.read(
      socialProfileViewModelProvider('user-1').future,
    );

    expect(state.profile.userId, 'user-1');
    expect(state.activity.items, isEmpty);
    expect(state.publicLists.items.single.mediaId, 'media-1');
  });

  test('build keeps profile when public lists fail', () async {
    final repo = _FakeSocialRepository(publicListsError: Exception('lists'));
    final container = ProviderContainer(
      overrides: [socialRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final state = await container.read(
      socialProfileViewModelProvider('user-1').future,
    );

    expect(state.profile.userId, 'user-1');
    expect(state.activity.items.single.eventId, 'evt-1');
    expect(state.publicLists.items, isEmpty);
  });
```

Update `_FakeSocialRepository` constructor and fields:

```dart
  _FakeSocialRepository({
    this.initialFollowerCount = 2,
    this.initiallyFollowed = false,
    this.followCompleter,
    this.followError,
    this.activityError,
    this.publicListsError,
    this.myProfileUserId = 'me',
  });
  final int initialFollowerCount;
  final bool initiallyFollowed;
  final Completer<void>? followCompleter;
  final Object? followError;
  final Object? activityError;
  final Object? publicListsError;
  final String myProfileUserId;
```

Update fake methods:

```dart
  @override
  Future<PaginatedSocialResponse<ActivityEventModel>> getUserActivity(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async {
    activityUserIds.add(userId);
    if (activityError != null) {
      throw activityError!;
    }
    return PaginatedSocialResponse(
      items: [_activity()],
      nextCursor: null,
      hasMore: false,
    );
  }
```

```dart
  @override
  Future<PaginatedSocialResponse<PublicListItemModel>> getPublicLists(
    String userId, {
    String? status,
    String? mediaType,
    int limit = 20,
    String? cursor,
  }) async {
    publicListUserIds.add(userId);
    if (publicListsError != null) {
      throw publicListsError!;
    }
    return const PaginatedSocialResponse(
      items: [
        PublicListItemModel(
          mediaId: 'media-1',
          mediaType: 'SERIES',
          status: 'WATCHING',
        ),
      ],
      nextCursor: null,
      hasMore: false,
    );
  }
```

- [ ] **Step 2: Run ViewModel tests and verify RED**

Run:

```bash
flutter test test/features/social/viewmodels/social_profile_viewmodel_test.dart
```

Expected result: the two new tests fail because `SocialProfileViewModel.build` currently awaits activity and public lists through a record `.wait`, so one subresource error fails the entire build.

- [ ] **Step 3: Implement minimal graceful degradation**

In `lib/features/social/viewmodels/social_profile_viewmodel.dart`, replace `build` with:

```dart
  @override
  Future<SocialProfileDetailState> build(String userId) async {
    final repository = ref.watch(socialRepositoryProvider);
    final profile = userId == 'me'
        ? await repository.getMyProfile()
        : await repository.getProfile(userId);
    final resolvedUserId = profile.userId;
    final (activity, publicLists) = await (
      _loadActivity(repository, resolvedUserId),
      _loadPublicLists(repository, resolvedUserId),
    ).wait;

    return SocialProfileDetailState(
      profile: profile,
      activity: activity,
      publicLists: publicLists,
    );
  }
```

Add these private helpers inside `SocialProfileViewModel`, below `build` and above `follow`:

```dart
  Future<PaginatedSocialResponse<ActivityEventModel>> _loadActivity(
    SocialRepository repository,
    String resolvedUserId,
  ) async {
    try {
      return await repository.getUserActivity(resolvedUserId);
    } catch (_) {
      return const PaginatedSocialResponse(
        items: [],
        nextCursor: null,
        hasMore: false,
      );
    }
  }

  Future<PaginatedSocialResponse<PublicListItemModel>> _loadPublicLists(
    SocialRepository repository,
    String resolvedUserId,
  ) async {
    try {
      return await repository.getPublicLists(resolvedUserId);
    } catch (_) {
      return const PaginatedSocialResponse(
        items: [],
        nextCursor: null,
        hasMore: false,
      );
    }
  }
```

- [ ] **Step 4: Run ViewModel tests and verify GREEN**

Run:

```bash
flutter test test/features/social/viewmodels/social_profile_viewmodel_test.dart
```

Expected result: all tests in `social_profile_viewmodel_test.dart` pass.

- [ ] **Step 5: Commit ViewModel graceful degradation**

Run:

```bash
git add test/features/social/viewmodels/social_profile_viewmodel_test.dart lib/features/social/viewmodels/social_profile_viewmodel.dart
git commit -m "fix: keep social profile visible when details fail"
```

---

### Task 3: Add widget-level regression for `/social/profile/me`

**Files:**
- Modify: `test/features/social/pages/social_pages_test.dart`

- [ ] **Step 1: Add failing widget test**

In `test/features/social/pages/social_pages_test.dart`, add this test after `Profile page renders Activity, Lists, Followers, Following tabs`:

```dart
  testWidgets(
    'Profile page for me renders header when activity and lists are empty',
    (tester) async {
      await tester.pumpSocial(
        const SocialProfilePage(userId: 'me', isMe: true),
        _FakeSocialRepository(
          profile: _profile(userId: 'current-user', displayName: 'Usuário'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Usuário'), findsOneWidget);
      expect(find.text('Editar perfil'), findsOneWidget);
      expect(
        find.text('Este perfil não está disponível no momento.'),
        findsNothing,
      );
      expect(find.text('Nenhuma atividade pública ainda.'), findsOneWidget);
    },
  );
```

- [ ] **Step 2: Run widget test and verify status**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart
```

Expected result after Tasks 1 and 2: pass. If this passes immediately, keep it as a regression test because it captures expected screen behavior after the lower-level fixes.

- [ ] **Step 3: Commit widget regression test**

Run:

```bash
git add test/features/social/pages/social_pages_test.dart
git commit -m "test: cover social profile me fallback UI"
```

---

### Task 4: Verify full social surface and static analysis

**Files:**
- No code changes expected.

- [ ] **Step 1: Run all social tests**

Run:

```bash
flutter test test/features/social
```

Expected result: all social tests pass.

- [ ] **Step 2: Run analyzer**

Run:

```bash
dart analyze --fatal-infos
```

Expected result: analyzer exits successfully with no errors or infos.

- [ ] **Step 3: Inspect git diff**

Run:

```bash
git diff --stat HEAD~3..HEAD
git status --short
```

Expected result:

- Only these code/test paths are changed by the implementation commits:
  - `lib/features/social/data/repositories/social_repository.dart`
  - `lib/features/social/viewmodels/social_profile_viewmodel.dart`
  - `test/features/social/data/social_repository_test.dart`
  - `test/features/social/viewmodels/social_profile_viewmodel_test.dart`
  - `test/features/social/pages/social_pages_test.dart`
- `.tasks/task-000001.md` may remain modified by WorkQ because the task was claimed before this session. Do not edit it manually.

- [ ] **Step 4: Do not mark WorkQ done automatically**

Do not run `workq done lorebase-frontend:task-000001` unless the human explicitly asks. Report the implemented commits and verification output, and ask whether they want the task marked done.

---

## Self-Review

- Spec coverage: The plan covers the observed blank profile fields, blank list timestamps, and graceful degradation for activity/list failures while preserving profile rendering.
- Placeholder scan: No placeholder steps remain; every code-changing step includes exact paths, snippets, commands, and expected outcomes.
- Type consistency: All referenced types already exist in the codebase: `SocialRepositoryImpl`, `PaginatedSocialResponse<T>`, `ActivityEventModel`, `PublicListItemModel`, and `SocialProfileViewModel`.
