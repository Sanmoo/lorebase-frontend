# Social Activity Backend Contract Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Social Activity render valid backend activity data by parsing the backend's flattened activity DTO contract.

**Architecture:** Keep UI models stable and put backend-contract conformance at the repository boundary. `SocialRepositoryImpl` will map flattened backend activity items into the existing `ActivityEventModel`, and `SocialProfileViewModel` will stop silently converting unexpected parsing errors into real empty activity states.

**Tech Stack:** Flutter 3.27, Dart, Riverpod codegen, Dio, Freezed models, flutter_test.

---

## File Structure

- Modify `lib/features/social/data/repositories/social_repository.dart`
  - Responsibility: API boundary for social endpoints. Add a private mapper that accepts the backend flattened activity DTO and returns `ActivityEventModel`.
- Modify `lib/features/social/viewmodels/social_profile_viewmodel.dart`
  - Responsibility: profile detail state orchestration. Preserve graceful fallback only for expected repository exceptions, not parsing/type errors.
- Modify `test/features/social/data/social_repository_test.dart`
  - Responsibility: repository contract tests. Update activity fixture to backend flattened format and assert the mapper output.
- Modify `test/features/social/viewmodels/social_profile_viewmodel_test.dart`
  - Responsibility: view model behavior tests. Add regression coverage that an unexpected activity parsing error is not silently converted to empty.
- Modify `test/features/social/pages/social_pages_test.dart`
  - Responsibility: widget flow tests. Existing fake repository returns UI models; add/confirm feed/profile activity rendering and empty state coverage if missing.

---

### Task 1: Repository parses flattened backend activity DTO

**Files:**
- Modify: `test/features/social/data/social_repository_test.dart`
- Modify: `lib/features/social/data/repositories/social_repository.dart`

- [ ] **Step 1: Update repository activity fixture to backend shape**

In `test/features/social/data/social_repository_test.dart`, replace `_activityJson()` with:

```dart
Map<String, dynamic> _activityJson() => {
  'eventId': 'evt-1',
  'userId': 'user-1',
  'activityType': 'COMPLETED',
  'mediaId': '1',
  'mediaType': 'MOVIE',
  'mediaTitle': 'Movie',
  'metadata': <String, dynamic>{'displayName': 'Fulano'},
  'createdAt': '2026-05-20T10:00:00Z',
};
```

- [ ] **Step 2: Strengthen `getFeed` assertions for mapped fields**

In the test named `getFeed calls GET /feed with limit/cursor and parses page`, after `expect(result.items.single.eventId, 'evt-1');`, add:

```dart
expect(result.items.single.user.userId, 'user-1');
expect(result.items.single.user.displayName, 'Fulano');
expect(result.items.single.media.mediaId, '1');
expect(result.items.single.media.mediaType, 'MOVIE');
expect(result.items.single.media.title, 'Movie');
```

- [ ] **Step 3: Strengthen `getUserActivity` assertions for mapped fields**

In the test named `getUserActivity calls profile activity endpoint and parses events`, after `expect(result.items.single.eventId, 'evt-1');`, add:

```dart
expect(result.items.single.user.userId, 'user-1');
expect(result.items.single.user.displayName, 'Fulano');
expect(result.items.single.media.mediaId, '1');
expect(result.items.single.media.mediaType, 'MOVIE');
expect(result.items.single.media.title, 'Movie');
```

- [ ] **Step 4: Run repository tests and verify RED**

Run:

```bash
flutter test test/features/social/data/social_repository_test.dart
```

Expected: FAIL because `ActivityEventModel.fromJson` still expects nested `user` and `media` objects.

- [ ] **Step 5: Import UI model dependencies in repository**

In `lib/features/social/data/repositories/social_repository.dart`, add imports after the existing activity model import:

```dart
import '../models/social_media_model.dart';
import '../models/social_user_model.dart';
```

- [ ] **Step 6: Change activity endpoint parsers to use the mapper**

In `getFeed`, replace:

```dart
fromJson: ActivityEventModel.fromJson,
```

with:

```dart
fromJson: _activityEventFromJson,
```

In `getUserActivity`, replace:

```dart
fromJson: ActivityEventModel.fromJson,
```

with:

```dart
fromJson: _activityEventFromJson,
```

- [ ] **Step 7: Add backend activity mapper**

In `SocialRepositoryImpl`, add this private method before `_publicListItemFromJson`:

```dart
ActivityEventModel _activityEventFromJson(Map<String, dynamic> json) {
  final metadata = Map<String, dynamic>.from(
    (json['metadata'] as Map?) ?? const <String, dynamic>{},
  );
  return ActivityEventModel(
    eventId: json['eventId'] as String,
    user: SocialUserModel(
      userId: json['userId'] as String,
      displayName: _activityUserDisplayName(metadata),
      avatarUrl: _profileAvatarUrl(metadata['avatarUrl']),
    ),
    activityType: json['activityType'] as String,
    media: SocialMediaModel(
      mediaId: json['mediaId'] as String,
      mediaType: json['mediaType'] as String,
      title: (json['mediaTitle'] as String?)?.trim().isNotEmpty == true
          ? (json['mediaTitle'] as String).trim()
          : 'Mídia',
      posterUrl: _profileAvatarUrl(json['posterUrl']),
    ),
    metadata: metadata,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

String _activityUserDisplayName(Map<String, dynamic> metadata) {
  final displayName = (metadata['displayName'] as String?)?.trim();
  if (displayName != null && displayName.isNotEmpty) {
    return displayName;
  }
  final username = (metadata['username'] as String?)?.trim();
  if (username != null && username.isNotEmpty) {
    return username;
  }
  return 'Usuário';
}
```

- [ ] **Step 8: Run repository tests and verify GREEN**

Run:

```bash
flutter test test/features/social/data/social_repository_test.dart
```

Expected: PASS.

- [ ] **Step 9: Commit repository contract fix**

Run:

```bash
git add lib/features/social/data/repositories/social_repository.dart test/features/social/data/social_repository_test.dart
git commit -m "fix: parse backend social activity DTO"
```

---

### Task 2: Do not hide unexpected profile activity parsing errors

**Files:**
- Modify: `test/features/social/viewmodels/social_profile_viewmodel_test.dart`
- Modify: `lib/features/social/viewmodels/social_profile_viewmodel.dart`

- [ ] **Step 1: Add imports for expected repository exception types if missing**

At the top of `test/features/social/viewmodels/social_profile_viewmodel_test.dart`, add this import if it is not already present:

```dart
import 'package:lorebase/core/errors/exceptions.dart';
```

- [ ] **Step 2: Add RED test for unexpected activity parsing errors**

In `test/features/social/viewmodels/social_profile_viewmodel_test.dart`, add this test after `build keeps profile when user activity fails`:

```dart
test('build exposes unexpected user activity errors instead of empty state', () async {
  final repo = _FakeSocialRepository(activityError: TypeError());
  final container = ProviderContainer(
    overrides: [socialRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);

  await expectLater(
    container.read(socialProfileViewModelProvider('user-1').future),
    throwsA(isA<TypeError>()),
  );
});
```

- [ ] **Step 3: Keep explicit coverage for expected server activity failures**

In the existing `build keeps profile when user activity fails` test, change the fake repository setup from:

```dart
final repo = _FakeSocialRepository(activityError: Exception('boom'));
```

to:

```dart
final repo = _FakeSocialRepository(
  activityError: const ServerException(message: 'boom', statusCode: 500),
);
```

This documents that only expected repository/server failures degrade to empty activity.

- [ ] **Step 4: Run view model tests and verify RED**

Run:

```bash
flutter test test/features/social/viewmodels/social_profile_viewmodel_test.dart
```

Expected: FAIL because `SocialProfileViewModel.build` currently catches every activity error and returns empty activity.

- [ ] **Step 5: Add expected activity fallback helper**

In `lib/features/social/viewmodels/social_profile_viewmodel.dart`, add this import near the top:

```dart
import '../../../core/errors/exceptions.dart';
```

Then add this private helper inside `SocialProfileViewModel`, after `build` and before `follow`:

```dart
Future<PaginatedSocialResponse<ActivityEventModel>> _loadUserActivity(
  SocialRepository repository,
  String resolvedUserId,
) async {
  try {
    return await repository.getUserActivity(resolvedUserId);
  } on ServerException {
    return _emptyActivityResponse();
  } on NetworkException {
    return _emptyActivityResponse();
  } on AuthException {
    return _emptyActivityResponse();
  }
}
```

- [ ] **Step 6: Use the helper in build**

In `build`, replace:

```dart
final activity = await repository
    .getUserActivity(resolvedUserId)
    .catchError((_) => _emptyActivityResponse());
```

with:

```dart
final activity = await _loadUserActivity(repository, resolvedUserId);
```

- [ ] **Step 7: Run view model tests and verify GREEN**

Run:

```bash
flutter test test/features/social/viewmodels/social_profile_viewmodel_test.dart
```

Expected: PASS.

- [ ] **Step 8: Commit profile error handling fix**

Run:

```bash
git add lib/features/social/viewmodels/social_profile_viewmodel.dart test/features/social/viewmodels/social_profile_viewmodel_test.dart
git commit -m "fix: surface unexpected social activity errors"
```

---

### Task 3: Confirm page-level activity states

**Files:**
- Modify: `test/features/social/pages/social_pages_test.dart` only if coverage is missing.

- [ ] **Step 1: Inspect existing page tests for activity rendering and empty states**

Run:

```bash
rg "Feed activity cards navigate|Profile edit and activity cards navigate|social_empty_public_activity|social_empty_feed" test/features/social/pages/social_pages_test.dart
```

Expected: find existing tests covering feed activity cards, profile activity cards, profile empty activity, and feed empty state.

- [ ] **Step 2: Run page tests**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart
```

Expected: PASS. If it fails because new repository/viewmodel behavior changed a UI expectation, update only the affected assertion to match the accepted design: valid activity shows cards; real empty activity shows empty state; unexpected activity errors are not represented as empty.

- [ ] **Step 3: Commit only if page tests required changes**

If `test/features/social/pages/social_pages_test.dart` changed, run:

```bash
git add test/features/social/pages/social_pages_test.dart
git commit -m "test: cover social activity page states"
```

If no file changed, do not commit.

---

### Task 4: Diagnostics and full verification

**Files:**
- No planned source edits.

- [ ] **Step 1: Run LSP diagnostics on touched files**

Run LSP diagnostics for:

```text
lib/features/social/data/repositories/social_repository.dart
test/features/social/data/social_repository_test.dart
lib/features/social/viewmodels/social_profile_viewmodel.dart
test/features/social/viewmodels/social_profile_viewmodel_test.dart
test/features/social/pages/social_pages_test.dart
```

Expected: no errors.

- [ ] **Step 2: Run focused social tests**

Run:

```bash
flutter test test/features/social/data/social_repository_test.dart test/features/social/viewmodels/social_profile_viewmodel_test.dart test/features/social/pages/social_pages_test.dart
```

Expected: PASS.

- [ ] **Step 3: Run analyzer**

Run:

```bash
make analyze
```

Expected: PASS or warnings-only pass according to project wrapper behavior.

- [ ] **Step 4: Add WorkQ progress comment**

Run:

```bash
workq comments add lorebase-frontend:task-000022 "Implemented frontend parsing for backend flattened social activity DTO; valid activity no longer becomes empty due to schema mismatch. Tests/analyze status: <replace with actual results>."
```

Expected: comment is added. Do not mark the WorkQ task done unless the human explicitly asks.

---

## Self-Review

- Spec coverage: Task 1 implements backend flattened parsing for `/feed` and `/profiles/{userId}/activity`; Task 2 prevents unexpected parsing errors from becoming empty activity; Task 3 checks UI empty/activity states; Task 4 verifies diagnostics/tests/analyzer and records WorkQ progress.
- Placeholder scan: The plan contains exact paths, code snippets, commands, and expected outcomes. The only replaceable text is the WorkQ comment's actual verification result, which must be filled from command output at execution time.
- Type consistency: The mapper returns existing `ActivityEventModel` with `SocialUserModel` and `SocialMediaModel`, matching current widget/viewmodel expectations.
