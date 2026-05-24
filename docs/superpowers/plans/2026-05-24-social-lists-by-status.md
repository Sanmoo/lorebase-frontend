# Social Lists By Status Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Load each Social Profile Lists section with a status-filtered public-lists request instead of grouping one unfiltered page.

**Architecture:** Keep `SocialProfileViewModel` focused on profile, activity, and follow actions. Render the Lists tab with four independent Riverpod requests through `SocialPublicListsViewModel`, one per status, so loading/error/empty states are section-local.

**Tech Stack:** Flutter 3.27, Dart, Riverpod codegen, Flutter widget tests, existing `SocialRepository` abstraction.

---

## File Structure

- Modify: `lib/features/social/pages/social_profile_page.dart`
  - Import `social_public_lists_viewmodel.dart`.
  - Replace the current `PublicMediaListSection(items: state.publicLists.items)` Lists tab with `_PublicListsTab`.
  - Add `_PublicListsTab`, `_PublicListStatusSection`, and a tiny status config object.
- Modify: `test/features/social/pages/social_pages_test.dart`
  - Extend fake repository to return public list items by status, record public-list calls, and simulate per-status errors.
  - Add widget tests for status-filtered calls, `PLAN_TO_WATCH` rendering, section order, and section-local error degradation.
- Modify: `test/features/social/viewmodels/social_profile_viewmodel_test.dart`
  - Update tests that currently expect `SocialProfileViewModel` to call `getPublicLists` during profile build.

---

### Task 1: Update SocialProfileViewModel expectations

**Files:**
- Modify: `test/features/social/viewmodels/social_profile_viewmodel_test.dart`

- [ ] **Step 1: Write the failing test updates**

In `test/features/social/viewmodels/social_profile_viewmodel_test.dart`, change the first test name and expectations from:

```dart
test('build loads profile, activity, and public lists for userId', () async {
```

To:

```dart
test('build loads profile and activity for userId', () async {
```

In that same test, replace:

```dart
expect(state.publicLists.items.single.mediaId, 'media-1');
expect(repo.profileUserIds, ['user-1']);
expect(repo.activityUserIds, ['user-1']);
expect(repo.publicListUserIds, ['user-1']);
```

With:

```dart
expect(state.publicLists.items, isEmpty);
expect(repo.profileUserIds, ['user-1']);
expect(repo.activityUserIds, ['user-1']);
expect(repo.publicListUserIds, isEmpty);
```

In the `build loads me profile endpoint and uses resolved userId for details` test, replace:

```dart
expect(repo.publicListUserIds, ['current-user']);
```

With:

```dart
expect(repo.publicListUserIds, isEmpty);
```

Remove the entire test named:

```dart
test('build keeps profile when public lists fail', () async {
```

through its closing `});` block, because public-list failures will no longer be part of the profile build.

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/features/social/viewmodels/social_profile_viewmodel_test.dart
```

Expected: FAIL, because `SocialProfileViewModel` still calls `getPublicLists` during build.

- [ ] **Step 3: Remove profile-level public-list loading**

In `lib/features/social/viewmodels/social_profile_viewmodel.dart`, replace the profile build tuple:

```dart
final (activity, publicLists) = await (
  repository
      .getUserActivity(resolvedUserId)
      .catchError((_) => _emptyActivityResponse()),
  repository
      .getPublicLists(resolvedUserId)
      .catchError((_) => _emptyPublicListsResponse()),
).wait;

return SocialProfileDetailState(
  profile: profile,
  activity: activity,
  publicLists: publicLists,
);
```

With:

```dart
final activity = await repository
    .getUserActivity(resolvedUserId)
    .catchError((_) => _emptyActivityResponse());

return SocialProfileDetailState(
  profile: profile,
  activity: activity,
  publicLists: _emptyPublicListsResponse(),
);
```

Leave `publicLists` on `SocialProfileDetailState` for now to minimize API churn in existing tests and callers.

- [ ] **Step 4: Run test to verify it passes**

Run:

```bash
flutter test test/features/social/viewmodels/social_profile_viewmodel_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/social/viewmodels/social_profile_viewmodel.dart test/features/social/viewmodels/social_profile_viewmodel_test.dart
git commit -m "refactor: stop loading public lists with profile"
```

---

### Task 2: Render Lists tab with status-filtered sections

**Files:**
- Modify: `lib/features/social/pages/social_profile_page.dart`
- Modify: `test/features/social/pages/social_pages_test.dart`

- [ ] **Step 1: Write failing page tests**

In `test/features/social/pages/social_pages_test.dart`, add this test after `Profile page renders Activity, Lists, Followers, Following tabs`:

```dart
testWidgets('Profile Lists tab loads public lists by status sections', (
  tester,
) async {
  final repository = _FakeSocialRepository(
    publicListItemsByStatus: {
      'PLAN_TO_WATCH': [
        _publicListItem(
          mediaId: 'plan-1',
          status: 'PLAN_TO_WATCH',
          title: 'Interestelar',
        ),
      ],
      'WATCHING': [
        _publicListItem(
          mediaId: 'watching-1',
          status: 'WATCHING',
          title: 'Reacher',
          mediaType: 'SERIES',
        ),
      ],
      'COMPLETED': [
        _publicListItem(
          mediaId: 'completed-1',
          status: 'COMPLETED',
          title: 'Batman Begins',
        ),
      ],
      'DROPPED': [
        _publicListItem(
          mediaId: 'dropped-1',
          status: 'DROPPED',
          title: 'Série abandonada',
          mediaType: 'SERIES',
        ),
      ],
    },
  );
  await tester.pumpSocial(
    const SocialProfilePage(userId: 'user-1'),
    repository,
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('Lists'));
  await tester.pumpAndSettle();

  expect(repository.publicListCalls, [
    'user-1:PLAN_TO_WATCH',
    'user-1:WATCHING',
    'user-1:COMPLETED',
    'user-1:DROPPED',
  ]);
  expect(find.text('Quero ver'), findsOneWidget);
  expect(find.text('Assistindo'), findsOneWidget);
  expect(find.text('Concluído'), findsOneWidget);
  expect(find.text('Abandonado', skipOffstage: false), findsOneWidget);
  expect(find.text('Interestelar'), findsOneWidget);
  expect(find.text('Reacher'), findsOneWidget);
  expect(find.text('Batman Begins'), findsOneWidget);
  expect(find.text('Série abandonada', skipOffstage: false), findsOneWidget);
});
```

Add a second test after it:

```dart
testWidgets('Profile Lists tab degrades only the failed status section', (
  tester,
) async {
  final repository = _FakeSocialRepository(
    publicListItemsByStatus: {
      'PLAN_TO_WATCH': [
        _publicListItem(
          mediaId: 'plan-1',
          status: 'PLAN_TO_WATCH',
          title: 'Interestelar',
        ),
      ],
      'COMPLETED': [
        _publicListItem(
          mediaId: 'completed-1',
          status: 'COMPLETED',
          title: 'Batman Begins',
        ),
      ],
    },
    publicListErrorsByStatus: {
      'WATCHING': const ServerException(
        message: 'Failed watching',
        statusCode: 500,
      ),
    },
  );
  await tester.pumpSocial(
    const SocialProfilePage(userId: 'user-1'),
    repository,
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('Lists'));
  await tester.pumpAndSettle();

  expect(find.text('Interestelar'), findsOneWidget);
  expect(find.text('Batman Begins'), findsOneWidget);
  expect(find.text('Não foi possível carregar Assistindo.'), findsOneWidget);
  expect(find.text('Este perfil não está disponível no momento.'), findsNothing);
});
```

Update the fake repository constructor to accept these fields:

```dart
this.publicListItemsByStatus = const {},
this.publicListErrorsByStatus = const {},
```

Add fields to `_FakeSocialRepository`:

```dart
final Map<String, List<PublicListItemModel>> publicListItemsByStatus;
final Map<String, Object> publicListErrorsByStatus;
final publicListCalls = <String>[];
```

Replace `_FakeSocialRepository.getPublicLists` with:

```dart
@override
Future<PaginatedSocialResponse<PublicListItemModel>> getPublicLists(
  String userId, {
  String? status,
  String? mediaType,
  int limit = 20,
  String? cursor,
}) async {
  publicListCalls.add('$userId:$status');
  final error = publicListErrorsByStatus[status];
  if (error != null) {
    throw error;
  }
  return _page(publicListItemsByStatus[status] ?? const []);
}
```

Add this helper near `_event` and `_discoverUser`:

```dart
PublicListItemModel _publicListItem({
  required String mediaId,
  required String status,
  required String title,
  String mediaType = 'MOVIE',
}) {
  return PublicListItemModel(
    mediaId: mediaId,
    mediaType: mediaType,
    status: status,
    media: SocialMediaModel(
      mediaId: mediaId,
      mediaType: mediaType,
      title: title,
    ),
  );
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart
```

Expected: FAIL. The Lists tab still renders one `PublicMediaListSection` from profile state and does not call status-filtered providers.

- [ ] **Step 3: Implement status-filtered Lists tab**

In `lib/features/social/pages/social_profile_page.dart`, add this import:

```dart
import '../viewmodels/social_public_lists_viewmodel.dart';
```

Replace the Lists tab child:

```dart
PublicMediaListSection(
  title: 'Listas públicas',
  items: state.publicLists.items,
),
```

With:

```dart
_PublicListsTab(userId: state.profile.userId),
```

Add these classes after `_ActivityTab` and before `_FollowListTab`:

```dart
class _PublicListsTab extends StatelessWidget {
  const _PublicListsTab({required this.userId});

  final String userId;

  static const _sections = [
    _PublicListStatusSectionConfig(
      status: 'PLAN_TO_WATCH',
      label: 'Quero ver',
    ),
    _PublicListStatusSectionConfig(status: 'WATCHING', label: 'Assistindo'),
    _PublicListStatusSectionConfig(status: 'COMPLETED', label: 'Concluído'),
    _PublicListStatusSectionConfig(status: 'DROPPED', label: 'Abandonado'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      cacheExtent: 1000,
      children: [
        Text(
          'Listas públicas',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        for (final section in _sections)
          _PublicListStatusSection(userId: userId, section: section),
      ],
    );
  }
}

class _PublicListStatusSection extends ConsumerWidget {
  const _PublicListStatusSection({required this.userId, required this.section});

  final String userId;
  final _PublicListStatusSectionConfig section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(
      socialPublicListsViewModelProvider(userId, status: section.status),
    );
    return list.when(
      data: (data) => PublicMediaListSection(
        title: section.label,
        items: data.items,
        emptyMessage: 'Nenhum item em ${section.label}.',
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text('Não foi possível carregar ${section.label}.'),
      ),
      loading: () => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text('Carregando ${section.label}...'),
          ],
        ),
      ),
    );
  }
}

class _PublicListStatusSectionConfig {
  const _PublicListStatusSectionConfig({
    required this.status,
    required this.label,
  });

  final String status;
  final String label;
}
```

- [ ] **Step 4: Fix nested padding if tests reveal layout regressions**

If the page tests pass but widget screenshots/inspection show excessive repeated padding, change `PublicMediaListSection` to accept optional padding:

In `lib/features/social/widgets/public_media_list_section.dart`, add a constructor parameter:

```dart
this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 24),
```

Add field:

```dart
final EdgeInsetsGeometry padding;
```

Replace:

```dart
padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
```

With:

```dart
padding: padding,
```

Then pass zero horizontal padding in `social_profile_page.dart`:

```dart
padding: EdgeInsets.zero,
```

inside the `PublicMediaListSection` call. If this optional padding change is made, existing `public_media_list_section_test.dart` should still pass because the default remains unchanged.

- [ ] **Step 5: Run page tests**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/social/pages/social_profile_page.dart lib/features/social/widgets/public_media_list_section.dart test/features/social/pages/social_pages_test.dart
git commit -m "feat: load social lists by status"
```

If `public_media_list_section.dart` was not changed, omit it from `git add`.

---

### Task 3: Verify focused tests and analyzer

**Files:**
- No code changes expected unless verification finds a concrete failure.

- [ ] **Step 1: Run focused social tests**

Run:

```bash
flutter test test/features/social/viewmodels/social_profile_viewmodel_test.dart test/features/social/viewmodels/social_public_lists_viewmodel_test.dart test/features/social/pages/social_pages_test.dart test/features/social/widgets/public_media_list_section_test.dart
```

Expected: PASS.

- [ ] **Step 2: Run analyzer**

Run:

```bash
make analyze
```

Expected: PASS. If it fails because of pre-existing unrelated issues, capture the exact output and do not claim full analyzer success.

- [ ] **Step 3: Run full Flutter test suite if focused verification is clean**

Run:

```bash
flutter test
```

Expected: PASS. If this is too slow or blocked by environment, record the reason and the focused test results.

- [ ] **Step 4: Commit any verification fixes**

Only if Step 1, 2, or 3 required code/test fixes, commit them:

```bash
git add <changed-files>
git commit -m "test: stabilize social lists by status"
```

---

## Self-Review

- Spec coverage: Task 1 removes dependency on the unfiltered profile-level list load. Task 2 adds four status-filtered sections and section-local error handling. Task 3 verifies focused tests, analyzer, and optionally the full suite.
- Placeholder scan: no TBD/TODO placeholders remain in executable steps.
- Type consistency: all provider, repository, model, and helper names match existing files read during planning.
