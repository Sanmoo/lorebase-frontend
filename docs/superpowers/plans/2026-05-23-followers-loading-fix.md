# Followers Loading Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stop the profile Followers tab from loading forever and call the BFF route that actually exists.

**Architecture:** The frontend should call Experience BFF public social routes under `/users/{userId}/followers` and `/users/{userId}/following`, not SocialContext internal routes under `/follows/...`. The follow-list Riverpod provider should also disable automatic retry so any future API error reaches the UI error state instead of creating an indefinite retry/loading loop.

**Tech Stack:** Flutter, Dart, Riverpod codegen, Dio, Flutter widget tests, build_runner.

---

### Backend evidence

The browser reproduced the bug on `/social/profile/me`: `GET /follows/me/followers?limit=20` returned `404 {"error":{"code":"NOT_FOUND","message":"Route not found"}}` repeatedly. In `../lorebase-backend/experience-bff/cmd/api/main.go`, Experience BFF routes follow lists only under `/users/*`:

```go
if strings.HasSuffix(path, "/following") && method == "GET" {
    resp, handlerErr := socialHandler.HandleListFollowing(ctx, request, locale)
    return middleware.ApplyCORSHeaders(resp, origin), handlerErr
}
if strings.HasSuffix(path, "/followers") && method == "GET" {
    resp, handlerErr := socialHandler.HandleListFollowers(ctx, request, locale)
    return middleware.ApplyCORSHeaders(resp, origin), handlerErr
}
```

So the frontend repository path is wrong for the deployed BFF. SocialContext itself has `/follows/...`, but the frontend talks to Experience BFF.

### Task 1: Repository paths

**Files:**
- Modify: `test/features/social/data/social_repository_test.dart`
- Modify: `lib/features/social/data/repositories/social_repository.dart`

- [ ] **Step 1: Write failing repository path tests**

Add tests asserting follow-list methods call BFF `/users` paths:

```dart
test('getFollowers calls users followers BFF endpoint for me', () async {
  final dio = Dio(
    BaseOptions(baseUrl: 'https://api.example.test'),
  );
  final adapter = _FakeAdapter((request) {
    expect(request.path, '/users/me/followers');
    expect(request.queryParameters, {'limit': 20});
    return ResponseBody.fromString(
      '{"items":[],"nextCursor":null,"hasMore":false}',
      200,
      headers: {Headers.contentTypeHeader: ['application/json']},
    );
  });
  dio.httpClientAdapter = adapter;

  final repository = SocialRepositoryImpl(dio);

  final response = await repository.getFollowers('me');

  expect(response.items, isEmpty);
  expect(adapter.callCount, 1);
});

test('getFollowing calls users following BFF endpoint for public profile', () async {
  final dio = Dio(
    BaseOptions(baseUrl: 'https://api.example.test'),
  );
  final adapter = _FakeAdapter((request) {
    expect(request.path, '/users/user-1/following');
    expect(request.queryParameters, {'limit': 20});
    return ResponseBody.fromString(
      '{"items":[],"nextCursor":null,"hasMore":false}',
      200,
      headers: {Headers.contentTypeHeader: ['application/json']},
    );
  });
  dio.httpClientAdapter = adapter;

  final repository = SocialRepositoryImpl(dio);

  final response = await repository.getFollowing('user-1');

  expect(response.items, isEmpty);
  expect(adapter.callCount, 1);
});
```

- [ ] **Step 2: Run tests and verify they fail**

Run:

```bash
flutter test test/features/social/data/social_repository_test.dart --plain-name "getFollowers calls users followers BFF endpoint for me"
flutter test test/features/social/data/social_repository_test.dart --plain-name "getFollowing calls users following BFF endpoint for public profile"
```

Expected: failures showing current paths are `/follows/me/followers` and `/follows/user-1/following`.

- [ ] **Step 3: Implement minimal path fix**

In `lib/features/social/data/repositories/social_repository.dart`, change:

```dart
final path = userId == 'me'
    ? '/follows/me/followers'
    : '/follows/$userId/followers';
```

to:

```dart
final path = '/users/$userId/followers';
```

And change:

```dart
final path = userId == 'me'
    ? '/follows/me/following'
    : '/follows/$userId/following';
```

to:

```dart
final path = '/users/$userId/following';
```

- [ ] **Step 4: Verify repository tests pass**

Run:

```bash
flutter test test/features/social/data/social_repository_test.dart --plain-name "getFollowers calls users followers BFF endpoint for me"
flutter test test/features/social/data/social_repository_test.dart --plain-name "getFollowing calls users following BFF endpoint for public profile"
```

Expected: both pass.

### Task 2: Disable follow-list provider retry

**Files:**
- Modify: `test/features/social/viewmodels/social_follow_list_viewmodel_test.dart`
- Modify: `lib/features/social/viewmodels/social_follow_list_viewmodel.dart`
- Generated after build_runner: `lib/features/social/viewmodels/social_follow_list_viewmodel.g.dart`

- [ ] **Step 1: Write failing provider retry test**

Add this test:

```dart
test('Social follow list provider disables automatic retry', () {
  final retry = socialFollowListViewModelProvider.retry;

  expect(retry, isNotNull);
  expect(retry!(0, Exception('route not found')), isNull);
});
```

- [ ] **Step 2: Run test and verify it fails**

Run:

```bash
flutter test test/features/social/viewmodels/social_follow_list_viewmodel_test.dart --plain-name "Social follow list provider disables automatic retry"
```

Expected: fail because retry is currently the generated/default policy or null in a way that does not prove explicit disablement.

- [ ] **Step 3: Implement explicit no-retry provider annotation**

In `lib/features/social/viewmodels/social_follow_list_viewmodel.dart`, add before the class:

```dart
Duration? _noSocialFollowListRetry(int retryCount, Object error) => null;
```

Change:

```dart
@riverpod
class SocialFollowListViewModel extends _$SocialFollowListViewModel {
```

to:

```dart
@Riverpod(retry: _noSocialFollowListRetry)
class SocialFollowListViewModel extends _$SocialFollowListViewModel {
```

- [ ] **Step 4: Regenerate Riverpod code**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `social_follow_list_viewmodel.g.dart` updates to include `retry: _noSocialFollowListRetry`.

- [ ] **Step 5: Verify retry test passes**

Run:

```bash
flutter test test/features/social/viewmodels/social_follow_list_viewmodel_test.dart --plain-name "Social follow list provider disables automatic retry"
```

Expected: pass.

### Task 3: Followers tab error-state regression test

**Files:**
- Modify: `test/features/social/pages/social_pages_test.dart`

- [ ] **Step 1: Write failing widget test for Followers API failure**

Extend `_FakeSocialRepository` with a field:

```dart
Object? followersError;
```

Change `getFollowers` to:

```dart
@override
Future<PaginatedSocialResponse<FollowRelationshipModel>> getFollowers(
  String userId, {
  int limit = 20,
  String? cursor,
}) async {
  final error = followersError;
  if (error != null) {
    throw error;
  }
  return _empty();
}
```

Add test:

```dart
testWidgets('Profile followers failure shows error instead of spinner', (
  tester,
) async {
  final repository = _FakeSocialRepository()
    ..followersError = const ServerException(
      message: 'Route not found',
      statusCode: 404,
    );
  await tester.pumpSocial(
    const SocialProfilePage(userId: 'me', isMe: true),
    repository,
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('Followers'));
  await tester.pumpAndSettle();

  expect(find.text('Erro ao carregar lista.'), findsOneWidget);
  expect(find.byType(CircularProgressIndicator), findsNothing);
});
```

- [ ] **Step 2: Run widget test**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart --plain-name "Profile followers failure shows error instead of spinner"
```

Expected after Task 2: pass. If run before Task 2, it may hang or keep retrying.

### Task 4: Verification

**Files:**
- No new source files.

- [ ] **Step 1: Run focused tests**

Run:

```bash
flutter test test/features/social/data/social_repository_test.dart test/features/social/viewmodels/social_follow_list_viewmodel_test.dart test/features/social/pages/social_pages_test.dart
```

Expected: all pass.

- [ ] **Step 2: Run analysis**

Run:

```bash
make analyze
```

Expected: pass.

- [ ] **Step 3: Browser verification**

Run:

```bash
flutter run -d web-server --web-port 8083
```

Open `http://localhost:8083`, navigate to `Social → Meu perfil → Followers`, and confirm network uses:

```text
GET /users/me/followers?limit=20
```

Expected UI: empty state when no followers, follower rows when present, or stable error message if backend returns an error. It must not repeatedly call the endpoint forever.
