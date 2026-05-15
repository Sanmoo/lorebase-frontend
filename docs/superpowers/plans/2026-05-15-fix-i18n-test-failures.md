# Fix i18n Test Failures — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adicionar `LocaleSettings.setLocaleSync(AppLocale.ptBr)` nos 3 arquivos de teste de auth para que os testes encontrem strings em português.

**Architecture:** Mudança pontual: 1 linha por arquivo, dentro das funções `_wrap()`/`_wrapLoginPage()`, antes de construir a widget tree. Nenhuma mudança em produção.

**Tech Stack:** Flutter test, slang (i18n), Riverpod

---

### Task 1: Fix login_page_test.dart

**Files:**

- Modify: `test/features/auth/pages/login_page_test.dart` — função `_wrapLoginPage()`

- [ ] **Step 1: Adicionar setLocaleSync no \_wrapLoginPage**

No arquivo `test/features/auth/pages/login_page_test.dart`, localizar a função `_wrapLoginPage` e adicionar a linha `LocaleSettings.setLocaleSync(AppLocale.ptBr);` logo no início do corpo:

```dart
Widget _wrapLoginPage(ProviderContainer container) {
  LocaleSettings.setLocaleSync(AppLocale.ptBr);
  return UncontrolledProviderScope(
    container: container,
    child: TranslationProvider(
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/login',
          routes: [
            GoRoute(
              path: '/login',
              builder: (_, __) => const LoginPage(),
            ),
            GoRoute(
              path: '/register',
              builder: (_, __) => const SizedBox(),
            ),
            GoRoute(
              path: '/forgot-password',
              builder: (_, __) => const SizedBox(),
            ),
            GoRoute(
              path: '/dashboard',
              builder: (_, __) => const SizedBox(),
            ),
          ],
        ),
      ),
    ),
  );
}
```

- [ ] **Step 2: Rodar os testes do login_page e verificar que passam**

```bash
flutter test test/features/auth/pages/login_page_test.dart
```

Expected: **All 12 tests pass** (antes ~4-5 falhavam com `Found 0 widgets with text "Entrar"`).

- [ ] **Step 3: Commit**

```bash
git add test/features/auth/pages/login_page_test.dart
git commit -m "test: set pt_BR locale in login_page tests"
```

---

### Task 2: Fix forgot_password_page_test.dart

**Files:**

- Modify: `test/features/auth/pages/forgot_password_page_test.dart` — função `_wrap()`

- [ ] **Step 1: Adicionar setLocaleSync no \_wrap**

No arquivo `test/features/auth/pages/forgot_password_page_test.dart`, localizar a função `_wrap` e adicionar `LocaleSettings.setLocaleSync(AppLocale.ptBr);`:

```dart
Widget _wrap(ProviderContainer container) {
  LocaleSettings.setLocaleSync(AppLocale.ptBr);
  return UncontrolledProviderScope(
    container: container,
    child: TranslationProvider(
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/forgot-password',
          routes: [
            GoRoute(
              path: '/forgot-password',
              builder: (_, __) => const ForgotPasswordPage(),
            ),
            GoRoute(
              path: '/login',
              builder: (_, __) => const SizedBox(),
            ),
          ],
        ),
      ),
    ),
  );
}
```

> Nota: O conteúdo exato da função pode variar. A única mudança é adicionar a linha `LocaleSettings.setLocaleSync(AppLocale.ptBr);` como primeira instrução após a abertura da função, antes do `return`.

- [ ] **Step 2: Rodar os testes e verificar que passam**

```bash
flutter test test/features/auth/pages/forgot_password_page_test.dart
```

Expected: **All tests pass** (antes ~3-4 falhavam com `Found 0 widgets with text "Enviar código"/"Redefinir senha"/"Voltar para o login"`).

- [ ] **Step 3: Commit**

```bash
git add test/features/auth/pages/forgot_password_page_test.dart
git commit -m "test: set pt_BR locale in forgot_password_page tests"
```

---

### Task 3: Fix register_page_test.dart

**Files:**

- Modify: `test/features/auth/pages/register_page_test.dart` — função `_wrap()`

- [ ] **Step 1: Adicionar setLocaleSync no \_wrap**

No arquivo `test/features/auth/pages/register_page_test.dart`, localizar a função `_wrap` e adicionar `LocaleSettings.setLocaleSync(AppLocale.ptBr);`:

```dart
Widget _wrap(ProviderContainer container) {
  LocaleSettings.setLocaleSync(AppLocale.ptBr);
  return UncontrolledProviderScope(
    container: container,
    child: TranslationProvider(
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/register',
          routes: [
            GoRoute(
              path: '/register',
              builder: (_, __) => const RegisterPage(),
            ),
            GoRoute(
              path: '/login',
              builder: (_, __) => const SizedBox(),
            ),
            GoRoute(
              path: '/login',
              builder: (_, __) => const SizedBox(),
            ),
          ],
        ),
      ),
    ),
  );
}
```

> Nota: O conteúdo exato da função pode variar. A única mudança é adicionar a linha `LocaleSettings.setLocaleSync(AppLocale.ptBr);` como primeira instrução após a abertura da função, antes do `return`.

- [ ] **Step 2: Rodar os testes e verificar que passam**

```bash
flutter test test/features/auth/pages/register_page_test.dart
```

Expected: **All tests pass** (antes ~2-3 falhavam com `Found 0 widgets with text "Já tem conta?"/"Confirmar e entrar"`).

- [ ] **Step 3: Commit**

```bash
git add test/features/auth/pages/register_page_test.dart
git commit -m "test: set pt_BR locale in register_page tests"
```

---

### Task 4: Verificação final — quality gate

- [ ] **Step 1: Rodar make check completo**

```bash
make check
```

Expected: `dart analyze` passa (tolerando exit code 2 para warnings), cobertura ≥ 100% line + branch.

- [ ] **Step 2: Commit final (se necessário)**

Se `make check` passar limpo, nenhum commit adicional necessário.
