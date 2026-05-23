# Social Discover Timeout Error Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show a clear timeout-specific error message and retry action when Social Discover fails with HTTP 504.

**Architecture:** Keep the existing Riverpod `SocialDiscoverViewModel` API unchanged and handle the presentation concern inside `_DiscoverTab`. Reuse the existing `refresh()` method for retry so the UI can recover from an error without adding new state abstractions.

**Tech Stack:** Flutter 3.27, Dart, Riverpod, Flutter widget tests, existing `ServerException` error model.

---

## File Structure

- Modify: `test/features/social/pages/social_pages_test.dart`
  - Add a widget test that reproduces a 504 from `discoverUsers()`, verifies the timeout message and retry button, taps retry, and verifies recovered content.
  - Extend `_FakeSocialRepository` with a queueable Discover failure so the first call can fail and the retry can succeed.
- Modify: `lib/features/social/pages/social_page.dart`
  - Update `_DiscoverTab` error rendering to detect `ServerException(statusCode: 504)`.
  - Render a visible message and a `Tentar novamente` button.
  - Wire the button to `SocialDiscoverViewModel.refresh()`.

No generated files should be edited.

---

### Task 1: Add failing widget test for Discover timeout retry

**Files:**
- Modify: `test/features/social/pages/social_pages_test.dart`

- [ ] **Step 1: Add fake repository support for one-shot Discover errors**

In `test/features/social/pages/social_pages_test.dart`, update `_FakeSocialRepository` constructor and fields from:

```dart
  _FakeSocialRepository({
    this.missingProfile = false,
    this.unavailableProfile = false,
    this.profile,
    this.feedItems = const [],
    this.discoverItems = const [],
    this.activityItems = const [],
  });

  bool missingProfile;
  final bool unavailableProfile;
  final SocialProfileModel? profile;
  final List<ActivityEventModel> feedItems;
  final List<DiscoverUserModel> discoverItems;
  final List<ActivityEventModel> activityItems;
```

to:

```dart
  _FakeSocialRepository({
    this.missingProfile = false,
    this.unavailableProfile = false,
    this.profile,
    this.feedItems = const [],
    this.discoverItems = const [],
    this.activityItems = const [],
    List<Object> discoverErrors = const [],
  }) : _discoverErrors = List<Object>.from(discoverErrors);

  bool missingProfile;
  final bool unavailableProfile;
  final SocialProfileModel? profile;
  final List<ActivityEventModel> feedItems;
  final List<DiscoverUserModel> discoverItems;
  final List<ActivityEventModel> activityItems;
  final List<Object> _discoverErrors;
  int discoverCallCount = 0;
```

Then update `discoverUsers()` from:

```dart
  Future<PaginatedSocialResponse<DiscoverUserModel>> discoverUsers({
    int limit = 20,
    String? cursor,
  }) async => _page(discoverItems);
```

to:

```dart
  Future<PaginatedSocialResponse<DiscoverUserModel>> discoverUsers({
    int limit = 20,
    String? cursor,
  }) async {
    discoverCallCount += 1;
    if (_discoverErrors.isNotEmpty) {
      final error = _discoverErrors.removeAt(0);
      throw error;
    }
    return _page(discoverItems);
  }
```

- [ ] **Step 2: Add the failing widget test**

Add this test after `Discover cards navigate to user` in `test/features/social/pages/social_pages_test.dart`:

```dart
  testWidgets('Discover timeout shows retry and recovers after tapping it', (
    tester,
  ) async {
    final repository = _FakeSocialRepository(
      discoverItems: [_discoverUser()],
      discoverErrors: const [
        ServerException(
          message: 'upstream request timed out',
          statusCode: 504,
        ),
      ],
    );
    await tester.pumpSocial(const SocialPage(), repository);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();

    expect(
      find.text('O Discover demorou para responder. Tente novamente em instantes.'),
      findsOneWidget,
    );
    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(repository.discoverCallCount, 1);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(repository.discoverCallCount, 2);
    expect(find.text('Ciclano'), findsOneWidget);
    expect(
      find.text('O Discover demorou para responder. Tente novamente em instantes.'),
      findsNothing,
    );
  });
```

- [ ] **Step 3: Run the new test and verify it fails for the expected reason**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart --plain-name 'Discover timeout shows retry and recovers after tapping it'
```

Expected: FAIL because the current UI does not render `O Discover demorou para responder. Tente novamente em instantes.` or `Tentar novamente`.

---

### Task 2: Implement Discover timeout error UI and retry

**Files:**
- Modify: `lib/features/social/pages/social_page.dart`

- [ ] **Step 1: Replace `_DiscoverTab` error branch with a retrying error state**

In `lib/features/social/pages/social_page.dart`, replace the current `_DiscoverTab` error branch:

```dart
      error: (_, _) => const Center(child: Text('Erro ao descobrir pessoas.')),
```

with:

```dart
      error: (error, _) => _DiscoverErrorState(
        message: error is ServerException && error.statusCode == 504
            ? 'O Discover demorou para responder. Tente novamente em instantes.'
            : 'Erro ao descobrir pessoas.',
        onRetry: () => ref.read(socialDiscoverViewModelProvider.notifier).refresh(),
      ),
```

- [ ] **Step 2: Add `_DiscoverErrorState` widget**

In `lib/features/social/pages/social_page.dart`, add this widget after `_DiscoverTab`:

```dart
class _DiscoverErrorState extends StatelessWidget {
  const _DiscoverErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Run the focused test and verify it passes**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart --plain-name 'Discover timeout shows retry and recovers after tapping it'
```

Expected: PASS.

---

### Task 3: Verify social page regression tests

**Files:**
- Test: `test/features/social/pages/social_pages_test.dart`

- [ ] **Step 1: Run the full social pages test file**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart
```

Expected: PASS for all tests in the file.

- [ ] **Step 2: Run analyzer for touched files**

Run:

```bash
dart analyze --fatal-infos lib/features/social/pages/social_page.dart test/features/social/pages/social_pages_test.dart
```

Expected: No issues found.

- [ ] **Step 3: Check git diff**

Run:

```bash
git diff -- lib/features/social/pages/social_page.dart test/features/social/pages/social_pages_test.dart docs/superpowers/plans/2026-05-23-social-discover-timeout-error.md
```

Expected: Diff only contains the new plan, the Discover timeout test/fake support, and the Discover retry error UI.

---

## Self-Review

- Spec coverage: The plan covers the reported 504 timeout, clear user message, retry action, and avoiding an empty tab panel.
- Placeholder scan: No TBD/TODO/implement-later placeholders remain.
- Type consistency: Uses existing `ServerException`, `SocialDiscoverViewModel.refresh()`, `socialDiscoverViewModelProvider`, and existing `_FakeSocialRepository` patterns.
