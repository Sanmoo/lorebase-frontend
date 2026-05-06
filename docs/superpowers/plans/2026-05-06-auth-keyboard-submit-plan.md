# Auth Keyboard Submit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Enter key submission support to all auth forms (login, register, forgot password).

**Architecture:** Add optional `onSubmitted` parameter to `AuthTextField` widget, wire it to `TextFormField.onFieldSubmitted`. Configure focus-forwarding (`nextFocus()`) for intermediate fields and direct submit calls for terminal fields in each auth page.

**Tech Stack:** Flutter, Dart, flutter_test

---

### Task 1: Add `onSubmitted` to `AuthTextField`

**Files:**
- Modify: `lib/features/auth/widgets/auth_text_field.dart`
- Create: `test/features/auth/widgets/auth_text_field_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/auth/widgets/auth_text_field.dart';

void main() {
  group('AuthTextField', () {
    testWidgets('calls onSubmitted when TextFormField.onFieldSubmitted fires',
        (tester) async {
      String? submittedValue;
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              controller: controller,
              hint: 'Test',
              icon: Icons.abc,
              onSubmitted: (value) {
                submittedValue = value;
              },
            ),
          ),
        ),
      );

      controller.text = 'test@email.com';
      await tester.tap(find.byType(TextFormField));
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(submittedValue, 'test@email.com');
    });

    testWidgets('does not crash when onSubmitted is null', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              controller: controller,
              hint: 'Test',
              icon: Icons.abc,
            ),
          ),
        ),
      );

      controller.text = 'test';
      await tester.tap(find.byType(TextFormField));
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(find.byType(TextFormField), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/widgets/auth_text_field_test.dart`
Expected: FAIL — `onSubmitted` is not yet a recognized parameter

- [ ] **Step 3: Add `onSubmitted` parameter to `AuthTextField`**

In `lib/features/auth/widgets/auth_text_field.dart`:

Add parameter to class fields (after `validator`):
```dart
  final ValueChanged<String>? onSubmitted;
```

Add parameter to constructor (after `validator`):
```dart
    this.onSubmitted,
```

Wire it in `TextFormField` (after `validator: validator,`):
```dart
        onFieldSubmitted: onSubmitted,
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/widgets/auth_text_field_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/widgets/auth_text_field.dart test/features/auth/widgets/auth_text_field_test.dart
git commit -m "feat: add onSubmitted parameter to AuthTextField"
```

---

### Task 2: Wire keyboard submit on Login page

**Files:**
- Modify: `lib/features/auth/pages/login_page.dart`

- [ ] **Step 1: Add `onSubmitted` to the email field**

Find `AuthTextField(controller: _emailController, hint: 'E-mail', ...)` (around line 68) and add:
```dart
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
```

- [ ] **Step 2: Add `onSubmitted` to the password field**

Find `AuthTextField(controller: _passwordController, hint: 'Senha', ...)` (around line 78) and add:
```dart
            onSubmitted: (_) => _submit(),
```

- [ ] **Step 3: Run existing tests to verify nothing breaks**

Run: `flutter test`
Expected: All existing tests PASS

- [ ] **Step 4: Commit**

```bash
git add lib/features/auth/pages/login_page.dart
git commit -m "feat: add keyboard submit to login page"
```

---

### Task 3: Wire keyboard submit on Register page

**Files:**
- Modify: `lib/features/auth/pages/register_page.dart`

- [ ] **Step 1: Add `onSubmitted` to confirmation mode code field**

Find `AuthTextField(controller: _codeController, hint: 'Código de confirmação', ...)` (around line 110, inside `showConfirmation` block) and add:
```dart
            onSubmitted: (_) => _confirm(),
```

- [ ] **Step 2: Add `onSubmitted` to registration mode email field**

Find `AuthTextField(controller: _emailController, hint: 'E-mail', ...)` (around line 131, inside `!showConfirmation` block) and add:
```dart
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
```

- [ ] **Step 3: Add `onSubmitted` to registration mode password field**

Find `AuthTextField(controller: _passwordController, hint: 'Senha', ...)` (around line 138, inside `!showConfirmation` block) and add:
```dart
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
```

- [ ] **Step 4: Add `onSubmitted` to registration mode confirm password field**

Find `AuthTextField(controller: _confirmController, hint: 'Confirmar senha', ...)` (around line 176, inside `!showConfirmation` block) and add:
```dart
            onSubmitted: (_) => _submit(),
```

- [ ] **Step 5: Run tests to verify nothing breaks**

Run: `flutter test`
Expected: All existing tests PASS

- [ ] **Step 6: Commit**

```bash
git add lib/features/auth/pages/register_page.dart
git commit -m "feat: add keyboard submit to register page"
```

---

### Task 4: Wire keyboard submit on Forgot Password page

**Files:**
- Modify: `lib/features/auth/pages/forgot_password_page.dart`

- [ ] **Step 1: Add `onSubmitted` to request code email field**

Find `AuthTextField(controller: _emailController, hint: 'E-mail', ...)` (around line 95, inside `requestCode` phase block) and add:
```dart
            onSubmitted: (_) => _requestCode(),
```

- [ ] **Step 2: Add `onSubmitted` to reset password code field**

Find `AuthTextField(controller: _codeController, hint: 'Código de verificação', ...)` (around line 108, inside `resetPassword` phase block) and add:
```dart
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
```

- [ ] **Step 3: Add `onSubmitted` to reset password new password field**

Find `AuthTextField(controller: _passwordController, hint: 'Nova senha', ...)` (around line 115, inside `resetPassword` phase block) and add:
```dart
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
```

- [ ] **Step 4: Add `onSubmitted` to reset password confirm field**

Find `AuthTextField(controller: _confirmController, hint: 'Confirmar nova senha', ...)` (around line 125, inside `resetPassword` phase block) and add:
```dart
            onSubmitted: (_) => _resetPassword(),
```

- [ ] **Step 5: Run tests to verify nothing breaks**

Run: `flutter test`
Expected: All existing tests PASS

- [ ] **Step 6: Commit**

```bash
git add lib/features/auth/pages/forgot_password_page.dart
git commit -m "feat: add keyboard submit to forgot password page"
```

---

### Task 5: Final verification

**Files:** None (verification only)

- [ ] **Step 1: Run the full test suite**

Run: `flutter test`
Expected: All tests PASS

- [ ] **Step 2: Run static analysis**

Run: `flutter analyze lib/features/auth/`
Expected: No errors, no new warnings
