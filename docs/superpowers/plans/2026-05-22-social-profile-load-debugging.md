# Social Profile Load Debugging Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Identify and fix why authenticated users see Social onboarding without an observable profile request, while adding safe debug diagnostics.

**Architecture:** Add debug-only logging at the Social profile load boundary, then write regression tests around `SocialPage`, provider caching, and onboarding invalidation. Use the tests to drive the minimal lifecycle fix: immediate invalidation after profile creation and, if proven necessary, `autoDispose` for the current-profile provider so stale 404 state is not retained after leaving Social.

**Tech Stack:** Flutter 3.27, Dart, Riverpod `FutureProvider`, GoRouter, Dio, Flutter widget tests.

---

## File Structure

- Create: `lib/core/logging/debug_log.dart`
  - One small helper for debug-only logs. It centralizes `kDebugMode` and avoids production logging.
- Modify: `lib/features/social/pages/social_page.dart`
  - Add Social profile load logs inside `mySocialProfileProvider`.
  - Convert `mySocialProfileProvider` to `FutureProvider.autoDispose` only if the stale-provider regression test proves it is required.
- Modify: `lib/features/social/data/repositories/social_repository.dart`
  - Add repository-boundary logs around `GET /profiles/me`.
- Modify: `lib/features/social/pages/social_onboarding_page.dart`
  - Separate `onProfileCreated` from `onFinish` and call `onProfileCreated` immediately after a successful save.
- Modify: `test/features/social/pages/social_pages_test.dart`
  - Add failing tests for provider lifecycle and profile-created invalidation.
  - Update the existing onboarding finish callback test.

---

### Task 1: Add failing regression coverage for Social profile checks

**Files:**
- Modify: `test/features/social/pages/social_pages_test.dart`

- [ ] **Step 1: Add a stale-state regression test**

Insert this test after `Social page missing profile state renders onboarding once`:

```dart
  testWidgets('Social page checks profile again after leaving missing state', (
    tester,
  ) async {
    final repository = _FakeSocialRepository(missingProfile: true);
    await tester.pumpSocial(const SocialPage(), repository);
    await tester.pumpAndSettle();

    expect(find.text('Crie seu perfil social'), findsOneWidget);
    expect(repository.getMyProfileCallCount, 1);

    await tester.pumpWidget(const MaterialApp(home: Text('Home')));
    await tester.pumpAndSettle();

    repository.missingProfile = false;
    await tester.pumpSocial(const SocialPage(), repository);
    await tester.pumpAndSettle();

    expect(repository.getMyProfileCallCount, 2);
    expect(find.text('Crie seu perfil social'), findsNothing);
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
  });
```

- [ ] **Step 2: Run the stale-state regression test**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart --plain-name 'Social page checks profile again after leaving missing state'
```

Expected before implementation: FAIL if `mySocialProfileProvider` retains the first 404 after the page is removed; PASS if provider lifecycle is already correct. Record the result in your notes before changing code.

- [ ] **Step 3: Add a profile-created invalidation regression test**

Insert this test after `Social page refreshes after onboarding creates profile`:

```dart
  testWidgets(
    'Social page does not show onboarding again after save without finish',
    (tester) async {
      final repository = _FakeSocialRepository(missingProfile: true);
      await tester.pumpSocial(const SocialPage(), repository);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Fulano');
      await tester.tap(find.text('Público'));
      await tester.pump();
      await tester.tap(find.text('Salvar perfil'));
      await tester.pumpAndSettle();

      expect(repository.savedProfile, isTrue);
      expect(find.text('Sugestões para seguir'), findsOneWidget);
      expect(find.text('Crie seu perfil social'), findsNothing);

      await tester.pumpWidget(const MaterialApp(home: Text('Home')));
      await tester.pumpAndSettle();

      await tester.pumpSocial(const SocialPage(), repository);
      await tester.pumpAndSettle();

      expect(find.text('Crie seu perfil social'), findsNothing);
      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
      expect(repository.getMyProfileCallCount, greaterThanOrEqualTo(2));
    },
  );
```

- [ ] **Step 4: Run the profile-created invalidation test**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart --plain-name 'Social page does not show onboarding again after save without finish'
```

Expected before implementation: FAIL because `SocialOnboardingPage` currently calls `onProfileCreated` only when **Finalizar** is tapped.

- [ ] **Step 5: Commit the failing tests if at least one fails**

Run:

```bash
git add test/features/social/pages/social_pages_test.dart
git commit -m "test: cover social profile reload flow"
```

If both tests unexpectedly pass, do not commit an empty change. Continue to Task 2 for diagnostics and note that the manual browser symptom may require runtime logs to locate.

---

### Task 2: Add safe debug diagnostics

**Files:**
- Create: `lib/core/logging/debug_log.dart`
- Modify: `lib/features/social/pages/social_page.dart`
- Modify: `lib/features/social/data/repositories/social_repository.dart`

- [ ] **Step 1: Create debug logging helper**

Create `lib/core/logging/debug_log.dart` with this content:

```dart
import 'package:flutter/foundation.dart';

void debugLog(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}
```

- [ ] **Step 2: Add provider-boundary logs to SocialPage**

In `lib/features/social/pages/social_page.dart`, add this import:

```dart
import '../../../../core/logging/debug_log.dart';
```

Replace the current provider:

```dart
final mySocialProfileProvider = FutureProvider<SocialProfileModel>(
  retry: (_, _) => null,
  (ref) => ref.watch(socialRepositoryProvider).getMyProfile(),
);
```

with:

```dart
final mySocialProfileProvider = FutureProvider<SocialProfileModel>(
  retry: (_, _) => null,
  (ref) async {
    debugLog('[SocialProfile] load started');
    try {
      final profile = await ref.watch(socialRepositoryProvider).getMyProfile();
      debugLog('[SocialProfile] load success');
      return profile;
    } on ServerException catch (error) {
      if (error.statusCode == 404) {
        debugLog('[SocialProfile] load missing status=404');
      } else {
        debugLog(
          '[SocialProfile] load failed status=${error.statusCode} '
          'type=ServerException',
        );
      }
      rethrow;
    } catch (error) {
      debugLog('[SocialProfile] load failed type=${error.runtimeType}');
      rethrow;
    }
  },
);
```

- [ ] **Step 3: Add repository-boundary logs for getMyProfile**

In `lib/features/social/data/repositories/social_repository.dart`, add this import:

```dart
import '../../../../core/logging/debug_log.dart';
```

Replace `getMyProfile()`:

```dart
  Future<SocialProfileModel> getMyProfile() async {
    return _getProfile('/profiles/me', 'Failed to load profile');
  }
```

with:

```dart
  Future<SocialProfileModel> getMyProfile() async {
    debugLog('[SocialProfile] repository getMyProfile started path=/profiles/me');
    try {
      final profile = await _getProfile('/profiles/me', 'Failed to load profile');
      debugLog('[SocialProfile] repository getMyProfile success path=/profiles/me');
      return profile;
    } on ServerException catch (error) {
      debugLog(
        '[SocialProfile] repository getMyProfile failed '
        'path=/profiles/me status=${error.statusCode}',
      );
      rethrow;
    } catch (error) {
      debugLog(
        '[SocialProfile] repository getMyProfile failed '
        'path=/profiles/me type=${error.runtimeType}',
      );
      rethrow;
    }
  }
```

- [ ] **Step 4: Run focused tests**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart --plain-name 'Social page existing profile renders compact profile link and tabs'
flutter test test/features/social/data/social_repository_test.dart --plain-name 'getMyProfile calls GET /profiles/me and parses model'
```

Expected: PASS. Logs may appear in debug test output; no sensitive data should be printed.

- [ ] **Step 5: Commit diagnostics**

Run:

```bash
git add lib/core/logging/debug_log.dart lib/features/social/pages/social_page.dart lib/features/social/data/repositories/social_repository.dart
git commit -m "chore: add social profile debug logs"
```

---

### Task 3: Fix onboarding profile-created invalidation

**Files:**
- Modify: `lib/features/social/pages/social_onboarding_page.dart`
- Modify: `test/features/social/pages/social_pages_test.dart`

- [ ] **Step 1: Add separate callbacks to SocialOnboardingPage**

In `lib/features/social/pages/social_onboarding_page.dart`, replace:

```dart
  const SocialOnboardingPage({super.key, this.onProfileCreated});

  final VoidCallback? onProfileCreated;
```

with:

```dart
  const SocialOnboardingPage({
    super.key,
    this.onProfileCreated,
    this.onFinish,
  });

  final VoidCallback? onProfileCreated;
  final VoidCallback? onFinish;
```

- [ ] **Step 2: Make suggestions finish use onFinish**

Replace:

```dart
      return _OnboardingSuggestions(
        onFinish: () => widget.onProfileCreated?.call(),
      );
```

with:

```dart
      return _OnboardingSuggestions(
        onFinish: () => widget.onFinish?.call(),
      );
```

- [ ] **Step 3: Call onProfileCreated immediately after successful save**

Replace this block in `_submit()`:

```dart
    if (ref.read(socialOnboardingViewModelProvider).profile != null) {
      setState(() => _showSuggestions = true);
    }
```

with:

```dart
    if (ref.read(socialOnboardingViewModelProvider).profile != null) {
      widget.onProfileCreated?.call();
      setState(() => _showSuggestions = true);
    }
```

- [ ] **Step 4: Update the existing finish-callback test**

In `test/features/social/pages/social_pages_test.dart`, replace the body of `Onboarding save shows suggestions until finished` with:

```dart
  testWidgets('Onboarding save shows suggestions until finished', (
    tester,
  ) async {
    var created = false;
    var finished = false;
    final repository = _FakeSocialRepository(discoverItems: [_discoverUser()]);
    await tester.pumpSocial(
      SocialOnboardingPage(
        onProfileCreated: () => created = true,
        onFinish: () => finished = true,
      ),
      repository,
    );

    await tester.enterText(find.byType(TextFormField).first, 'Fulano');
    await tester.tap(find.text('Público'));
    await tester.pump();
    await tester.tap(find.text('Salvar perfil'));
    await tester.pumpAndSettle();

    expect(created, isTrue);
    expect(finished, isFalse);
    expect(find.text('Sugestões para seguir'), findsOneWidget);
    expect(find.text('Ciclano'), findsOneWidget);

    await tester.tap(find.text('Finalizar'));
    expect(finished, isTrue);
  });
```

- [ ] **Step 5: Run onboarding tests**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart --plain-name 'Social page does not show onboarding again after save without finish'
flutter test test/features/social/pages/social_pages_test.dart --plain-name 'Onboarding save shows suggestions until finished'
```

Expected: PASS.

- [ ] **Step 6: Commit onboarding fix**

Run:

```bash
git add lib/features/social/pages/social_onboarding_page.dart test/features/social/pages/social_pages_test.dart
git commit -m "fix: refresh social profile after onboarding save"
```

---

### Task 4: Fix stale profile provider state if the regression test still fails

**Files:**
- Modify: `lib/features/social/pages/social_page.dart`

- [ ] **Step 1: Check stale-state test result**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart --plain-name 'Social page checks profile again after leaving missing state'
```

Expected after Tasks 2-3: PASS or FAIL. Only continue with Steps 2-5 if this test fails because `repository.getMyProfileCallCount` remains `1` or onboarding remains visible after returning.

- [ ] **Step 2: Convert current-profile provider to autoDispose**

In `lib/features/social/pages/social_page.dart`, replace:

```dart
final mySocialProfileProvider = FutureProvider<SocialProfileModel>(
```

with:

```dart
final mySocialProfileProvider = FutureProvider.autoDispose<SocialProfileModel>(
```

Keep the existing `retry` and logging body unchanged.

- [ ] **Step 3: Run stale-state test**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart --plain-name 'Social page checks profile again after leaving missing state'
```

Expected: PASS. `repository.getMyProfileCallCount` should be `2`.

- [ ] **Step 4: Run Social page test file**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit provider lifecycle fix**

Run:

```bash
git add lib/features/social/pages/social_page.dart
git commit -m "fix: reload social profile after leaving social page"
```

If Step 1 passed and no code changed in this task, skip this commit.

---

### Task 5: Final verification

**Files:**
- No planned file edits.

- [ ] **Step 1: Run LSP diagnostics on changed Dart files**

Run diagnostics for:

```text
lib/core/logging/debug_log.dart
lib/features/social/pages/social_page.dart
lib/features/social/pages/social_onboarding_page.dart
lib/features/social/data/repositories/social_repository.dart
test/features/social/pages/social_pages_test.dart
```

Expected: no errors.

- [ ] **Step 2: Run focused test suites**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart
flutter test test/features/social/data/social_repository_test.dart
```

Expected: PASS.

- [ ] **Step 3: Run analyzer**

Run:

```bash
make analyze
```

Expected: PASS, or warnings-only handled by the Makefile as configured.

- [ ] **Step 4: Manual browser verification**

Run the app and reproduce the user's flows:

```bash
flutter run -d chrome
```

Expected for an existing social profile:

- click Social after fresh app load;
- Social tabs appear;
- DevTools or console shows debug profile-load messages;
- logs include `load started` and either `load success` or a clear failure status;
- no sensitive tokens, headers, e-mails, or full profile payloads appear.

Expected for a user without a social profile:

- click Social;
- onboarding form appears;
- logs include `load missing status=404`.

- [ ] **Step 5: Commit any final test-only or formatting adjustments**

If final verification required minor formatting/test edits, run:

```bash
git add <changed-files>
git commit -m "test: verify social profile loading"
```

If there are no changes, skip this commit.

---

## Self-Review Notes

- Spec coverage: The plan covers root-cause evidence, permanent debug-only diagnostics, profile load lifecycle tests, onboarding invalidation, and final verification.
- Placeholder scan: No `TBD`, `TODO`, or unspecified error-handling steps remain.
- Type consistency: Uses existing `SocialProfileModel`, `ServerException`, `SocialOnboardingPage`, `mySocialProfileProvider`, and `_FakeSocialRepository` names from the codebase.
