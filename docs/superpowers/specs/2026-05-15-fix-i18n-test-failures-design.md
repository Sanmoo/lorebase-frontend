# Fix i18n Test Failures — Design

**Date:** 2026-05-15
**Status:** approved

## Context

After adding i18n (slang) with deferred loading, 24 tests in 3 auth page test files started failing. The quality gate (`make check`) was also affected by `/tmp` disk quota exhaustion from stale `flutter_tools.*` directories.

## Root Cause

### 1. Test failures (24 tests)

Auth page tests use hardcoded Portuguese strings (`find.text('Entrar')`, `find.text('Esqueceu a senha?')`, etc.), but the i18n system defaults to `AppLocale.en` (English) in tests because `LocaleSettings.setLocale` is never called. The `TranslationProvider` wraps the widget tree but serves English translations.

Affected files:

- `test/features/auth/pages/login_page_test.dart`
- `test/features/auth/pages/forgot_password_page_test.dart`
- `test/features/auth/pages/register_page_test.dart`

### 2. Disk quota (resolved)

Stale `flutter_tools.*` directories in `/tmp` (tmpfs 7.7G) accumulated ~4GB, causing `Disk quota exceeded (errno = 122)` when the Dart compiler tried to write `output.dill`. Resolved by manual cleanup.

## Solution Design

### Fix: Set pt_BR locale in test wrappers

In each of the 3 test files, add `LocaleSettings.setLocaleSync(AppLocale.ptBr)` inside the `_wrap()` / `_wrapLoginPage()` helper, before constructing the widget tree.

**Example:**

```dart
Widget _wrap(ProviderContainer container) {
  LocaleSettings.setLocaleSync(AppLocale.ptBr);
  return UncontrolledProviderScope(
    container: container,
    child: TranslationProvider(
      child: MaterialApp.router(...),
    ),
  );
}
```

**Why `setLocaleSync` (not `setLocale`):** The sync variant uses `buildSync()` which doesn't require deferred library loading. Safe for test environments where async loading may not complete before widget tree is built.

**Why inside `_wrap()` (not `setUpAll`):** Each test creates a new `ProviderContainer`. Setting locale at wrapper level ensures every invocation is correctly configured, avoiding shared-state issues.

### Non-scope

- The `dart analyze` warnings (5 warnings + 7 deprecation infos) are a separate issue. `make analyze` tolerates exit code 2 (warnings-only), so they don't block the quality gate.
- No changes to production code — only test files.

### Files changed

| File                                                      | Change                                                                   |
| --------------------------------------------------------- | ------------------------------------------------------------------------ |
| `test/features/auth/pages/login_page_test.dart`           | Add `LocaleSettings.setLocaleSync(AppLocale.ptBr)` in `_wrapLoginPage()` |
| `test/features/auth/pages/forgot_password_page_test.dart` | Add `LocaleSettings.setLocaleSync(AppLocale.ptBr)` in `_wrap()`          |
| `test/features/auth/pages/register_page_test.dart`        | Add `LocaleSettings.setLocaleSync(AppLocale.ptBr)` in `_wrap()`          |

## Verification

After changes:

1. `flutter test test/features/auth/pages/login_page_test.dart` — all 12 tests pass
2. `flutter test test/features/auth/pages/forgot_password_page_test.dart` — all tests pass
3. `flutter test test/features/auth/pages/register_page_test.dart` — all tests pass
4. `make check` — analyze passes, coverage gate passes at 100%
