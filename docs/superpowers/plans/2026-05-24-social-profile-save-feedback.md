# Social Profile Save Feedback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make social profile edit saves provide clear success/error feedback and prevent stale profile data after returning to the previous screen.

**Architecture:** Keep `EditSocialProfilePage` as the orchestration point after `SocialOnboardingViewModel.saveProfile()`. On success, invalidate both profile providers that can back the previous screen, then pop the navigation stack. On failure, keep the user on the edit page and show a generic `SnackBar`.

**Tech Stack:** Flutter 3.27, Dart, Riverpod, GoRouter, Flutter widget tests.

---

## File Structure

- Modify: `test/features/social/pages/social_pages_test.dart`
  - Add a route-based success test proving edit save returns to the previous profile page and reloads updated display name.
  - Add an error test proving failed edit save keeps the edit page visible and shows a generic `SnackBar`.
  - Extend `_FakeSocialRepository` with `Object? updateProfileError` and update-aware `getMyProfile()` behavior.

- Modify: `lib/features/social/pages/edit_social_profile_page.dart`
  - Import `package:go_router/go_router.dart` and `../viewmodels/social_profile_viewmodel.dart`.
  - After successful save, invalidate `mySocialProfileProvider` and `socialProfileViewModelProvider('me')`, then navigate back with `context.pop()` when possible.
  - After failed save, show `SnackBar` with `Não foi possível salvar o perfil. Tente novamente.`.

---

### Task 1: Add failing success test

**Files:**
- Modify: `test/features/social/pages/social_pages_test.dart`

- [ ] **Step 1: Write the failing route-based success test**

Add this test after the existing `Edit social profile loads current profile before saving` test:

```dart
  testWidgets('Edit social profile save returns and refreshes previous profile', (
    tester,
  ) async {
    final repository = _FakeSocialRepository(
      profile: _profile(displayName: 'Nome antigo'),
    );
    final router = _router(
      const SocialProfilePage(userId: 'me', isMe: true),
      repository,
    );
    await tester.pumpRouter(router);
    await tester.pumpAndSettle();

    expect(find.text('Nome antigo'), findsOneWidget);

    await tester.tap(find.text('Editar perfil'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/social/profile/edit');

    await tester.enterText(find.byType(TextFormField).first, 'Nome novo');
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/');
    expect(repository.savedDisplayName, 'Nome novo');
    expect(find.text('Nome novo'), findsOneWidget);
    expect(find.text('Nome antigo'), findsNothing);
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart --plain-name 'Edit social profile save returns and refreshes previous profile'
```

Expected: FAIL because the app remains on `/social/profile/edit` and/or the previous page does not show `Nome novo`.

- [ ] **Step 3: Extend fake repository to retain updated profile**

In `_FakeSocialRepository`, add a mutable field near the existing `profile` field:

```dart
  SocialProfileModel? updatedProfile;
```

Change `getMyProfile()` return from:

```dart
    return profile ?? _profile();
```

to:

```dart
    return updatedProfile ?? profile ?? _profile();
```

Change `updateMyProfile()` from:

```dart
    return _profile(
      displayName: displayName,
      avatarUrl: avatarUrl,
      isPublic: isPublic,
    );
```

to:

```dart
    updatedProfile = _profile(
      displayName: displayName,
      avatarUrl: avatarUrl,
      isPublic: isPublic,
    );
    return updatedProfile!;
```

- [ ] **Step 4: Implement minimal success behavior**

In `lib/features/social/pages/edit_social_profile_page.dart`, add imports:

```dart
import 'package:go_router/go_router.dart';
```

and:

```dart
import '../viewmodels/social_profile_viewmodel.dart';
```

Replace the success block in `_submit()`:

```dart
    if (saveState.profile != null &&
        saveState.errorMessage == null &&
        saveState.validationError == null) {
      ref.invalidate(mySocialProfileProvider);
    }
```

with:

```dart
    if (saveState.profile != null &&
        saveState.errorMessage == null &&
        saveState.validationError == null) {
      ref.invalidate(mySocialProfileProvider);
      ref.invalidate(socialProfileViewModelProvider('me'));
      if (context.canPop()) {
        context.pop();
      }
    }
```

- [ ] **Step 5: Run test to verify it passes**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart --plain-name 'Edit social profile save returns and refreshes previous profile'
```

Expected: PASS.

- [ ] **Step 6: Commit Task 1**

Run:

```bash
git add lib/features/social/pages/edit_social_profile_page.dart test/features/social/pages/social_pages_test.dart
git commit -m "fix: return after social profile save"
```

---

### Task 2: Add failing error feedback test

**Files:**
- Modify: `test/features/social/pages/social_pages_test.dart`
- Modify: `lib/features/social/pages/edit_social_profile_page.dart`

- [ ] **Step 1: Write the failing error test**

Add this test after the success test from Task 1:

```dart
  testWidgets('Edit social profile save failure stays and shows feedback', (
    tester,
  ) async {
    final repository = _FakeSocialRepository(
      profile: _profile(displayName: 'Fulano'),
    )..updateProfileError = const ServerException(
        message: 'Save failed',
        statusCode: 500,
      );
    final router = _router(
      const SocialProfilePage(userId: 'me', isMe: true),
      repository,
    );
    await tester.pumpRouter(router);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Editar perfil'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Nome novo');
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/social/profile/edit');
    expect(find.text('Editar perfil social'), findsOneWidget);
    expect(
      find.text('Não foi possível salvar o perfil. Tente novamente.'),
      findsOneWidget,
    );
  });
```

- [ ] **Step 2: Add fake repository failure hook**

In `_FakeSocialRepository`, add this field near `Object? followError;`:

```dart
  Object? updateProfileError;
```

At the start of `updateMyProfile()`, after `savedIsPublic = isPublic;`, add:

```dart
    final error = updateProfileError;
    if (error != null) {
      throw error;
    }
```

The method should still set `savedProfile`, `missingProfile`, `savedDisplayName`, `savedAvatarUrl`, and `savedIsPublic` before throwing so tests can verify submission happened if needed.

- [ ] **Step 3: Run test to verify it fails**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart --plain-name 'Edit social profile save failure stays and shows feedback'
```

Expected: FAIL because no `SnackBar` with the generic Portuguese error is shown yet.

- [ ] **Step 4: Implement minimal error feedback**

In `lib/features/social/pages/edit_social_profile_page.dart`, after the success `if` block in `_submit()`, add an `else if`:

```dart
    if (saveState.profile != null &&
        saveState.errorMessage == null &&
        saveState.validationError == null) {
      ref.invalidate(mySocialProfileProvider);
      ref.invalidate(socialProfileViewModelProvider('me'));
      if (context.canPop()) {
        context.pop();
      }
    } else if (saveState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar o perfil. Tente novamente.'),
        ),
      );
    }
```

- [ ] **Step 5: Run test to verify it passes**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart --plain-name 'Edit social profile save failure stays and shows feedback'
```

Expected: PASS.

- [ ] **Step 6: Commit Task 2**

Run:

```bash
git add lib/features/social/pages/edit_social_profile_page.dart test/features/social/pages/social_pages_test.dart
git commit -m "fix: show social profile save errors"
```

---

### Task 3: Verify focused suite and analysis

**Files:**
- No code changes expected unless verification reveals an issue.

- [ ] **Step 1: Run focused social page tests**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart
```

Expected: PASS for all tests in `social_pages_test.dart`.

- [ ] **Step 2: Run analyzer**

Run:

```bash
make analyze
```

Expected: PASS. If the analyzer reports only warnings and `make analyze` treats warnings-only as pass, keep the output for the final report.

- [ ] **Step 3: Inspect git status**

Run:

```bash
git status --short
```

Expected: only intentional files changed, or clean if all task commits were made.

- [ ] **Step 4: Report completion without marking WorkQ done**

Final response should summarize:

```text
Implemented social profile save feedback.
- Success invalidates profile providers and returns via navigation stack.
- Failure stays on edit page and shows a generic SnackBar.
- Verification: flutter test test/features/social/pages/social_pages_test.dart; make analyze.

I did not mark WorkQ task lorebase-frontend:task-000012 done because that requires explicit human approval.
```

Do not run `workq done` unless the human explicitly asks.
