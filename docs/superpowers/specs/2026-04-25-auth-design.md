# lorebase Frontend — Auth Feature Design

**Date:** 2026-04-25
**Status:** Approved for Implementation
**Scope:** Login, Register, Forgot Password flows
**Tech Stack:** Flutter 3.x, Riverpod, Amplify Auth Cognito, go_router
**Architecture:** MVVM + Riverpod
**Author:** OpenCode (with user collaboration)

---

## 1. Executive Summary

This document specifies the authentication feature for the lorebase frontend. The app currently runs in "dev mode" with a hardcoded `x-user-id` header. This design replaces that with real AWS Cognito authentication via Amplify Flutter, adding dedicated UI flows for login, registration, and password reset.

**Key Decisions:**
- **Amplify Auth Cognito** for sign-in, sign-up, and password reset
- **Separate pages** for Login, Register, and Forgot Password (Option 1 from brainstorming)
- **Login as first screen** when user is unauthenticated
- **go_router redirect guards** to enforce auth on protected routes
- **AuthInterceptor** finally integrated to inject `Authorization: Bearer <token>`

---

## 2. Flow Overview

### App Launch Flow

```
main()
  └── Amplify.configure()
      └── fetchAuthSession()
          ├── Authenticated ──→ go_router redirects to /
          └── Unauthenticated ──→ go_router redirects to /login
```

### Auth Page Flows

```
+-----------+     "Não tem conta?"      +--------------+
|  /login   | ─────────────────────────→ |  /register   |
+-----------+                            +--------------+
     │                                          │
     │ "Esqueceu a senha?"                      │ "Já tem conta?"
     ▼                                          ▼
+------------------+                    +-----------+
| /forgot-password |                    |  /login   |
+------------------+                    +-----------+
```

---

## 3. Router & Guards

### Route Table

| Path | Page | Auth Required? |
|------|------|----------------|
| `/login` | `LoginPage` | No |
| `/register` | `RegisterPage` | No |
| `/forgot-password` | `ForgotPasswordPage` | No |
| `/` | `DashboardPage` | Yes |
| `/tracking` | `TrackingListPage` | Yes |
| `/series/search` | `SeriesSearchPage` | Yes |
| `/series/:id` | `SeriesDetailPage` | Yes |
| `/recommendation` | `RecommendationPage` | Yes |

### Redirect Logic

```dart
redirect: (context, state) {
  final isAuthRoute = ['/login', '/register', '/forgot-password']
      .contains(state.matchedLocation);
  final isAuthenticated = ref.read(authViewModelProvider).isAuthenticated;

  if (!isAuthenticated && !isAuthRoute) return '/login';
  if (isAuthenticated && isAuthRoute) return '/';
  return null;
}
```

---

## 4. Architecture

### 4.1 Folder Structure

```
lib/features/auth/
├── data/
│   └── repositories/
│       └── auth_repository.dart          # Interface + Amplify impl
├── viewmodels/
│   ├── auth_state.dart                   # AuthStatus enum + state
│   ├── auth_viewmodel.dart               # Global auth (checkAuth, signOut)
│   ├── login_viewmodel.dart              # Login form state + submit
│   ├── register_viewmodel.dart           # Register form state + submit
│   └── forgot_password_viewmodel.dart    # Forgot password state machine
└── pages/
    ├── login_page.dart
    ├── register_page.dart
    └── forgot_password_page.dart

lib/features/auth/widgets/
├── auth_page_scaffold.dart               # Shared background, logo, padding
├── auth_text_field.dart                  # Reusable text field with validation
└── auth_button.dart                      # Primary action button with loading
```

### 4.2 Component Responsibilities

**AuthRepository:**
- `Future<String> signIn(email, password)` — returns userId
- `Future<void> signUp(email, password)` — initiates sign-up
- `Future<void> confirmSignUp(email, code)` — confirms email with Cognito
- `Future<void> resendSignUpCode(email)` — resends confirmation code
- `Future<void> resetPassword(email)` — initiates password reset
- `Future<void> confirmResetPassword(email, code, newPassword)` — completes reset
- `Future<void> signOut()` — clears session
- `Future<bool> isAuthenticated()` — checks valid session

**AuthViewModel (global):**
- On init: calls `isAuthenticated()` → sets `AuthState`
- Exposes `signOut()` → clears state → router redirects to `/login`
- Read by router redirect guard and UI for auth-dependent decisions

**LoginViewModel:**
- Form state: email, password, isLoading, errorMessage
- `submit()` → validates → calls `AuthRepository.signIn()` → on success updates global `AuthState`

**RegisterViewModel:**
- Form state: email, password, confirmPassword, termsAccepted, isLoading, errorMessage
- `submit()` → validates → calls `AuthRepository.signUp()` → navigates to confirmation or auto-logs in
- Password strength indicator updated on password change

**ForgotPasswordViewModel:**
- Two-phase state machine: `requestCode` | `resetPassword`
- Phase 1: email → `resetPassword(email)` → transition to phase 2
- Phase 2: code + newPassword + confirmPassword → `confirmResetPassword()` → navigate to `/login`

---

## 5. Data Flow

### Login Flow

```
LoginPage (UI)
  └── LoginViewModel
      ├── validates email + password
      ├── calls AuthRepository.signIn()
      │   └── Amplify.Auth.signIn()
      └── on success:
          ├── updates AuthViewModel → authenticated
          └── router redirect to /
      └── on error:
          └── sets errorMessage → UI shows inline error
```

### Register Flow

```
RegisterPage (UI)
  └── RegisterViewModel
      ├── validates email + password + confirmPassword + terms
      ├── calls AuthRepository.signUp()
      │   └── Amplify.Auth.signUp()
      ├── if requires confirmation (Cognito default):
      │   └── shows inline message: "Verifique seu e-mail e confirme o código"
      │   └── user enters code inline or re-sends; no separate confirmation page in MVP
      └── on success (auto-login if possible):
          ├── updates AuthViewModel → authenticated
          └── router redirect to /
```

### Forgot Password Flow

```
ForgotPasswordPage (UI)
  └── ForgotPasswordViewModel
      ├── Phase 1: email → AuthRepository.resetPassword()
      │   └── Amplify.Auth.resetPassword()
      │   └── transition to Phase 2
      ├── Phase 2: code + newPassword + confirm
      │   └── AuthRepository.confirmResetPassword()
      │   └── Amplify.Auth.confirmResetPassword()
      └── on success: navigate to /login with snackbar "Senha redefinida"
```

---

## 6. UI/UX Specification

### Shared Components

**AuthPageScaffold:**
- No AppBar
- Background: gradient using `AppColors.primary` → darker shade
- SafeArea + SingleChildScrollView
- Padding: 24px horizontal
- Logo: 96px, centered, at top
- Content centered vertically with `MainAxisAlignment.center`

**AuthTextField:**
- `TextFormField` wrapped in `AnimatedContainer`
- Prefix icon: consistent with field type (mail, lock)
- Hint text with `TextStyle(color: Colors.white70)`
- Border: `OutlineInputBorder` with white30, focused white
- Error state: red border + shake animation + error text below
- Password field: suffix icon toggle for obscure text
- Keyboard types: email → `TextInputType.emailAddress`, password → `TextInputType.text`

**AuthButton:**
- Full-width `ElevatedButton`
- Height: 52px
- Border radius: 12px
- Loading state: `CircularProgressIndicator` (white, strokeWidth 2) replaces text
- Disabled state: opacity 0.6
- Enabled only when form is valid

### Login Page (`/login`)

| Element | Detail |
|---------|--------|
| Logo | `lorebase` text/icon, 96px |
| Title | "Bem-vindo de volta" |
| Subtitle | "Entre para continuar suas listas" |
| Email field | Icon: `Icons.mail_outline`, hint: "E-mail" |
| Password field | Icon: `Icons.lock_outline`, hint: "Senha", obscure toggle |
| Primary button | "Entrar" |
| Link 1 | "Esqueceu a senha?" → `/forgot-password` |
| Divider | `Divider` with "ou" (preparation for future SSO) |
| Link 2 | "Não tem conta? Cadastre-se" → `/register` |

### Register Page (`/register`)

| Element | Detail |
|---------|--------|
| Logo | Same logo |
| Title | "Criar conta" |
| Subtitle | "Comece a organizar suas séries" |
| Email field | Validation: valid email format |
| Password field | Real-time strength indicator (weak/medium/strong) |
| Confirm password | Validation: must match password |
| Terms checkbox | "Li e aceito os Termos de Uso" (links to terms) |
| Primary button | "Criar conta" — disabled until form valid + terms checked |
| Link | "Já tem conta? Entrar" → `/login` |

**Password strength rules:**
- Minimum 8 characters
- At least 1 uppercase letter
- At least 1 number
- Visual indicator: 3-bar progress (red/yellow/green)

### Forgot Password Page (`/forgot-password`)

**Phase 1 — Request code:**

| Element | Detail |
|---------|--------|
| Title | "Recuperar senha" |
| Subtitle | "Digite seu e-mail para receber um código de verificação" |
| Email field | Standard email field |
| Primary button | "Enviar código" |
| Link | "Voltar para o login" → `/login` |

**Phase 2 — New password:**

| Element | Detail |
|---------|--------|
| Title | "Nova senha" |
| Subtitle | "Digite o código enviado para seu e-mail" |
| Code field | 6-digit input, `TextInputType.number` |
| New password | With strength indicator |
| Confirm password | Match validation |
| Primary button | "Redefinir senha" |
| Link | "Voltar para o login" → `/login` |

### Animations
- Page enter: staggered fade-in (logo 0ms, title 100ms, form 200ms, button 300ms)
- Field error: horizontal shake animation (±4px, 300ms)
- Button loading: smooth transition to spinner
- Page transitions: Material horizontal slide (go_router default)

---

## 7. Error Handling

### Amplify Error Mapping

| Amplify Exception | User-Facing Message (PT-BR) |
|-------------------|----------------------------|
| `UserNotFoundException` | "E-mail ou senha incorretos" |
| `NotAuthorizedException` | "E-mail ou senha incorretos" |
| `UserAlreadyExistsException` | "Este e-mail já está cadastrado" |
| `CodeMismatchException` | "Código de verificação inválido" |
| `LimitExceededException` | "Muitas tentativas. Tente novamente mais tarde." |
| `NetworkException` | "Sem conexão. Verifique sua internet." |
| `InvalidPasswordException` | "A senha não atende aos requisitos de segurança" |
| Generic / unknown | "Algo deu errado. Tente novamente." |

### Error Display Strategy
- Validation errors: inline below the field (red text, 12px)
- Submission errors: inline below the form or SnackBar at bottom
- No dialogs for auth errors — keep user in context

---

## 8. Integration Points

### AuthInterceptor Update

The existing `AuthInterceptor` stub in `lib/core/network/auth_interceptor.dart` will be completed:

```dart
@override
void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
  try {
    final session = await Amplify.Auth.fetchAuthSession();
    if (session.isSignedIn) {
      final token = session.userPoolTokensResult.value.accessToken.raw;
      options.headers['Authorization'] = 'Bearer $token';
    }
  } catch (e) {
    // Allow request to proceed — backend may handle unauthenticated
  }
  handler.next(options);
}
```

### Removing Dev Fallback

The `x-user-id` fallback in `AuthInterceptor` and any dev-mode hardcoded auth in `AuthViewModel` will be removed.

---

## 9. State Management

### AuthState

```dart
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.unknown;

  const AuthState._({this.status = AuthStatus.unknown, this.userId, this.errorMessage});
  const AuthState.unknown() : this._();
  const AuthState.authenticated(String userId) : this._(status: AuthStatus.authenticated, userId: userId);
  const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);
}
```

### Global Provider

Using Riverpod Generator (`@riverpod`), consistent with other viewmodels in the project:

```dart
@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  AuthState build() {
    _checkAuth();
    return const AuthState.unknown();
  }

  Future<void> _checkAuth() async {
    // ... check session and update state
  }

  Future<void> signOut() async {
    // ... sign out and update state
  }
}
```

Generated provider: `authViewModelProvider`.

---

## 10. Testing Strategy

### Unit Tests (ViewModels)
- `LoginViewModel`: validate email format, validate password not empty, submit calls repository, error state on failure
- `RegisterViewModel`: password strength calculation, confirm password match, terms checkbox required
- `ForgotPasswordViewModel`: phase transition, code validation, reset success

### Widget Tests (Pages)
- `LoginPage`: renders all fields, button disabled when invalid, shows error on bad credentials
- `RegisterPage`: password strength indicator updates, terms checkbox gates submit
- `ForgotPasswordPage`: phase 1 → phase 2 transition on code sent

### Integration Tests
- Full flow: register → confirm → login → access protected route → logout → redirect to login

---

## 11. Open Questions / Future Work

| Item | Decision | Timeline |
|------|----------|----------|
| Email confirmation screen | Inline message on register page for now; separate page if UX testing shows confusion | MVP |
| Social login (Google, Apple) | Out of scope; `/login` divider "ou" is placeholder | Post-MVP |
| Biometric login | Out of scope | Post-MVP |
| Remember me / persistent session | Amplify handles token refresh automatically | Built-in |
| Terms of Service URL | Link to static page; URL configurable | Before launch |

---

## 12. Dependencies

Already present in `pubspec.yaml`:
- `amplify_flutter: ^1.6.0`
- `amplify_auth_cognito: ^1.6.0`
- `flutter_riverpod: ^2.x`
- `go_router: ^13.x`

No new dependencies required.

---

*End of Design Document*
