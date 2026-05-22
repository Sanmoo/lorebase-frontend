# Social Onboarding Cache Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ensure the Social onboarding form appears only until profile creation succeeds, even if the user leaves before tapping **Finalizar**.

**Architecture:** Separate the “profile created” event from the “suggestions finished” event in `SocialOnboardingPage`. Invalidate `mySocialProfileProvider` immediately after a successful save while keeping the suggestions screen visible.

**Tech Stack:** Flutter 3.27, Dart, Riverpod, GoRouter, Flutter widget tests.

---

## File Structure

- Modify: `lib/features/social/pages/social_onboarding_page.dart`
  - Add a separate `onFinish` callback.
  - Call `onProfileCreated` immediately after `saveProfile()` succeeds.
  - Make the suggestions **Finalizar** button call `onFinish` instead of `onProfileCreated`.
- Modify: `test/features/social/pages/social_pages_test.dart`
  - Add a regression widget test for leaving Social after save without tapping **Finalizar**.
  - Update the existing finish-callback test to use `onFinish`.

---

### Task 1: Add regression coverage for leaving before finishing suggestions

**Files:**
- Modify: `test/features/social/pages/social_pages_test.dart`

- [ ] **Step 1: Add the failing widget test**

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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [socialRepositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(
            home: Scaffold(body: Text('Início')),
          ),
        ),
      );
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

- [ ] **Step 2: Run the regression test and verify it fails**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart --plain-name 'Social page does not show onboarding again after save without finish'
```

Expected: FAIL. The failure should show that `Feed` / `Discover` are not found or that `Crie seu perfil social` is still present after returning to Social.

- [ ] **Step 3: Commit the failing test**

```bash
git add test/features/social/pages/social_pages_test.dart
git commit -m "test: cover social onboarding return flow"
```

---

### Task 2: Separate profile-created and finish callbacks

**Files:**
- Modify: `lib/features/social/pages/social_onboarding_page.dart`
- Modify: `test/features/social/pages/social_pages_test.dart`

- [ ] **Step 1: Update the onboarding widget constructor and fields**

In `lib/features/social/pages/social_onboarding_page.dart`, replace the current constructor and callback field:

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

- [ ] **Step 2: Make the suggestions finish button use the finish callback**

In the `_showSuggestions` branch, replace:

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

- [ ] **Step 3: Call `onProfileCreated` immediately after a successful save**

In `_submit()`, replace:

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

- [ ] **Step 4: Update the finish-callback test to use `onFinish`**

In `test/features/social/pages/social_pages_test.dart`, in the test named `Onboarding save shows suggestions until finished`, replace:

```dart
      SocialOnboardingPage(onProfileCreated: () => finished = true),
```

with:

```dart
      SocialOnboardingPage(onFinish: () => finished = true),
```

- [ ] **Step 5: Run the targeted tests**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart --plain-name 'Social page does not show onboarding again after save without finish'
flutter test test/features/social/pages/social_pages_test.dart --plain-name 'Onboarding save shows suggestions until finished'
flutter test test/features/social/pages/social_pages_test.dart --plain-name 'Social page refreshes after onboarding creates profile'
```

Expected: all three commands PASS.

- [ ] **Step 6: Commit the implementation**

```bash
git add lib/features/social/pages/social_onboarding_page.dart test/features/social/pages/social_pages_test.dart
git commit -m "fix: refresh social profile after onboarding save"
```

---

### Task 3: Verify Social page suite and static analysis

**Files:**
- Verify only; no code changes expected.

- [ ] **Step 1: Run the full Social page widget test file**

Run:

```bash
flutter test test/features/social/pages/social_pages_test.dart
```

Expected: all tests PASS.

- [ ] **Step 2: Run analyzer**

Run:

```bash
dart analyze --fatal-infos
```

Expected: exits 0 with no errors, warnings, or infos. If existing unrelated analyzer issues appear, stop and report them instead of changing unrelated files.

- [ ] **Step 3: Check git status**

Run:

```bash
git status --short
```

Expected: clean working tree after the two task commits, or only intentional uncommitted files if the executor was told not to commit.

---

## Self-Review

- Spec coverage: Task 1 covers the reported bug. Task 2 implements the chosen two-callback design and preserves suggestions. Task 3 verifies tests and analyzer.
- Placeholder scan: no placeholders remain.
- Type consistency: callback names are `onProfileCreated` and `onFinish` consistently across implementation and tests.
