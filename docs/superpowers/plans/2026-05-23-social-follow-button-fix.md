# Social Follow Button Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Social Discover “Seguir” button execute visibly: show per-user loading, update to “Seguindo” on success, and show an error message on failure.

**Architecture:** Keep the repository and `SocialDiscoverViewModel.followUser` as the source of the follow action and optimistic state update. Add only UI-level pending/error feedback in the Social Discover tab and pass loading state into `DiscoverUserCard`; this avoids broad state-model changes and keeps existing provider tests valid.

**Tech Stack:** Flutter widget tests, Riverpod provider overrides, GoRouter test harness, Material `SnackBar`, existing `SocialRepository` and `SocialDiscoverViewModel`.

---

## File Structure

- Modify: `lib/features/social/widgets/discover_user_card.dart`
  - Responsibility: render a suggested user card, including the follow button. Add an `isFollowing` input that disables the button and shows a spinner for only the card currently being followed.
- Modify: `lib/features/social/pages/social_page.dart`
  - Responsibility: Social page tabs. Convert `_DiscoverTab` from `ConsumerWidget` to `ConsumerStatefulWidget` so it can track in-flight follow user IDs and show a `SnackBar` if follow fails.
- Modify: `test/features/social/widgets/discover_user_card_test.dart`
  - Responsibility: widget-level card behavior. Add a failing test for the loading state.
- Modify: `test/features/social/pages/social_pages_test.dart`
  - Responsibility: integrated Social page behavior with fake repository. Add failing tests for successful follow state update and failed follow feedback.

## Root Cause Summary

`DiscoverUserCard` currently calls `onFollow`, and `_DiscoverTab` currently passes `SocialDiscoverViewModel.followUser(user.userId)`. However, `_DiscoverTab` does not await that future, track loading, or catch failures. A failed repository call therefore surfaces no visible feedback, and a slow call gives no indication that anything happened.

---

### Task 1: Add loading behavior to `DiscoverUserCard`

**Files:**
- Modify: `lib/features/social/widgets/discover_user_card.dart`
- Test: `test/features/social/widgets/discover_user_card_test.dart`

- [ ] **Step 1: Write the failing widget test**

Add this test at the end of `test/features/social/widgets/discover_user_card_test.dart` before the closing `}` of `main()`:

```dart
  testWidgets('follow button shows spinner and disables while following', (
    tester,
  ) async {
    var calls = 0;
    await pumpCard(
      tester,
      user(),
      isFollowing: true,
      onFollow: () => calls++, 
    );

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(find.text('Seguir'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.bySemanticsLabel('Seguindo usuário'), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    expect(calls, 0);
  });
```

Then update the local `pumpCard` helper signature in the same test file to accept and pass `isFollowing`:

```dart
  Future<void> pumpCard(
    WidgetTester tester,
    DiscoverUserModel user, {
    VoidCallback? onFollow,
    bool isFollowing = false,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiscoverUserCard(
            user: user,
            onFollow: onFollow ?? () {},
            isFollowing: isFollowing,
          ),
        ),
      ),
    );
  }
```

- [ ] **Step 2: Run the focused test to verify it fails**

Run:

```bash
flutter test test/features/social/widgets/discover_user_card_test.dart
```

Expected result: FAIL because `DiscoverUserCard` does not have an `isFollowing` named parameter yet.

- [ ] **Step 3: Implement the minimal card loading state**

In `lib/features/social/widgets/discover_user_card.dart`, update the constructor and fields:

```dart
  const DiscoverUserCard({
    super.key,
    required this.user,
    required this.onFollow,
    this.onUserTap,
    this.isFollowing = false,
  });

  final DiscoverUserModel user;
  final VoidCallback onFollow;
  final VoidCallback? onUserTap;
  final bool isFollowing;
```

Replace the existing `FilledButton.tonal` inside the trailing area of the row with:

```dart
                  FilledButton.tonal(
                    onPressed: user.isFollowedByMe || isFollowing
                        ? null
                        : onFollow,
                    child: isFollowing
                        ? Semantics(
                            label: 'Seguindo usuário',
                            child: const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Text(user.isFollowedByMe ? 'Seguindo' : 'Seguir'),
                  ),
```

- [ ] **Step 4: Run the focused test to verify it passes**

Run:

```bash
flutter test test/features/social/widgets/discover_user_card_test.dart
```

Expected result: PASS.

---

### Task 2: Add Social page success and failure tests

**Files:**
- Modify: `test/features/social/pages/social_pages_test.dart`

- [ ] **Step 1: Add fake repository follow controls**

In `_FakeSocialRepository`, add these fields near the other mutable fields:

```dart
  final followedUserIds = <String>[];
  Object? followError;
  Completer<void>? _followCompleter;
```

Add these helper methods inside `_FakeSocialRepository`:

```dart
  void pauseNextFollow() {
    _followCompleter = Completer<void>();
  }

  void resumeFollow() {
    _followCompleter?.complete();
    _followCompleter = null;
  }
```

Replace the current `followUser` override:

```dart
  @override
  Future<void> followUser(String userId) async {}
```

with:

```dart
  @override
  Future<void> followUser(String userId) async {
    followedUserIds.add(userId);
    final followCompleter = _followCompleter;
    if (followCompleter != null) {
      await followCompleter.future;
    }
    final error = followError;
    if (error != null) {
      throw error;
    }
  }
```

- [ ] **Step 2: Write the failing success-flow test**

Add this test after `Discover cards navigate to user` in `test/features/social/pages/social_pages_test.dart`:

```dart
  testWidgets('Discover follow shows loading and updates to followed on success', (
    tester,
  ) async {
    final repository = _FakeSocialRepository(discoverItems: [_discoverUser()]);
    repository.pauseNextFollow();
    await tester.pumpSocial(const SocialPage(), repository);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Seguir'));
    await tester.pump();

    expect(repository.followedUserIds, ['user-2']);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.bySemanticsLabel('Seguindo usuário'), findsOneWidget);
    expect(find.text('Seguir'), findsNothing);

    repository.resumeFollow();
    await tester.pumpAndSettle();

    expect(find.text('Seguindo'), findsOneWidget);
    expect(find.text('Não foi possível seguir este usuário.'), findsNothing);
  });
```

- [ ] **Step 3: Write the failing failure-feedback test**

Add this test immediately after the success-flow test:

```dart
  testWidgets('Discover follow failure shows feedback and restores button', (
    tester,
  ) async {
    final repository = _FakeSocialRepository(discoverItems: [_discoverUser()])
      ..followError = const ServerException(
        message: 'Follow failed',
        statusCode: 500,
      );
    await tester.pumpSocial(const SocialPage(), repository);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Seguir'));
    await tester.pumpAndSettle();

    expect(repository.followedUserIds, ['user-2']);
    expect(find.text('Seguir'), findsOneWidget);
    expect(find.text('Seguindo'), findsNothing);
    expect(find.text('Não foi possível seguir este usuário.'), findsOneWidget);
  });
```

- [ ] **Step 4: Run the focused page tests to verify they fail**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart
```

Expected result: FAIL because `_DiscoverTab` does not track loading and does not catch/show follow failures yet.

---

### Task 3: Implement Discover follow loading and error handling

**Files:**
- Modify: `lib/features/social/pages/social_page.dart`
- Test: `test/features/social/pages/social_pages_test.dart`

- [ ] **Step 1: Convert `_DiscoverTab` to stateful**

In `lib/features/social/pages/social_page.dart`, replace:

```dart
class _DiscoverTab extends ConsumerWidget {
  const _DiscoverTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
```

with:

```dart
class _DiscoverTab extends ConsumerStatefulWidget {
  const _DiscoverTab();

  @override
  ConsumerState<_DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends ConsumerState<_DiscoverTab> {
  final Set<String> _followingUserIds = <String>{};

  @override
  Widget build(BuildContext context) {
```

Keep the existing body of the build method, using `ref` from `ConsumerState`.

- [ ] **Step 2: Pass per-card loading state and async handler**

In the `DiscoverUserCard` creation in `_DiscoverTabState.build`, replace:

```dart
            return DiscoverUserCard(
              user: user,
              onFollow: () => ref
                  .read(socialDiscoverViewModelProvider.notifier)
                  .followUser(user.userId),
              onUserTap: () => context.go('/social/profile/${user.userId}'),
            );
```

with:

```dart
            return DiscoverUserCard(
              user: user,
              isFollowing: _followingUserIds.contains(user.userId),
              onFollow: () => _followUser(user.userId),
              onUserTap: () => context.go('/social/profile/${user.userId}'),
            );
```

- [ ] **Step 3: Add the async follow method**

Add this method inside `_DiscoverTabState`, after the `build` method and before the class closing brace:

```dart
  Future<void> _followUser(String userId) async {
    if (_followingUserIds.contains(userId)) {
      return;
    }

    setState(() => _followingUserIds.add(userId));
    try {
      await ref.read(socialDiscoverViewModelProvider.notifier).followUser(
            userId,
          );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível seguir este usuário.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _followingUserIds.remove(userId));
      }
    }
  }
```

- [ ] **Step 4: Run the focused page tests to verify they pass**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart
```

Expected result: PASS.

---

### Task 4: Verify targeted suite and diagnostics

**Files:**
- Validate: `lib/features/social/widgets/discover_user_card.dart`
- Validate: `lib/features/social/pages/social_page.dart`
- Validate: `test/features/social/widgets/discover_user_card_test.dart`
- Validate: `test/features/social/pages/social_pages_test.dart`

- [ ] **Step 1: Run LSP diagnostics on touched Dart files**

Run diagnostics with the harness LSP tool for these files:

```text
lib/features/social/widgets/discover_user_card.dart
lib/features/social/pages/social_page.dart
test/features/social/widgets/discover_user_card_test.dart
test/features/social/pages/social_pages_test.dart
```

Expected result: no new errors.

- [ ] **Step 2: Run targeted widget/page tests**

Run:

```bash
flutter test test/features/social/widgets/discover_user_card_test.dart test/features/social/pages/social_pages_test.dart
```

Expected result: all tests pass.

- [ ] **Step 3: Run analyzer**

Run:

```bash
make analyze
```

Expected result: analyzer completes successfully. If it reports formatting/lint issues in touched files, fix only those issues and rerun `make analyze`.

- [ ] **Step 4: Review WorkQ status without marking done**

Run:

```bash
workq show lorebase-frontend:task-000007
```

Expected result: status remains `claimed`. Do not run `workq done`; the human explicitly instructed that the task should only be marked done if they ask.

---

## Self-Review

- Spec coverage: Task 1 adds visible per-button loading; Task 2 captures click success and failure behavior; Task 3 implements correct action dispatch, visual state update, and failure feedback; Task 4 verifies diagnostics/tests/analyzer and preserves WorkQ status.
- Placeholder scan: no `TBD`, `TODO`, or ambiguous “handle later” steps remain.
- Type consistency: `isFollowing` is added as a `bool` to `DiscoverUserCard`; `_followingUserIds` is a `Set<String>` in `_DiscoverTabState`; tests use existing `_FakeSocialRepository`, `ServerException`, and `DiscoverUserModel` helpers.
