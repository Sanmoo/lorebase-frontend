# Auth Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement complete authentication flows (login, register, forgot password) using Amplify Auth Cognito, with auth guards on all protected routes.

**Architecture:** MVVM + Riverpod with `@riverpod` generator. Feature-based folder structure. Amplify Flutter for Cognito auth. go_router with redirect guards. Shared auth widgets (scaffold, text field, button).

**Tech Stack:** Flutter 3.x, flutter_riverpod, go_router, amplify_flutter, amplify_auth_cognito, freezed

---

## File Structure

**New files to create:**
- `lib/features/auth/data/repositories/auth_repository.dart` — Interface + Amplify implementation
- `lib/features/auth/viewmodels/auth_state.dart` — AuthStatus enum + state class
- `lib/features/auth/viewmodels/auth_viewmodel.dart` — Global auth VM (checkAuth, signOut)
- `lib/features/auth/viewmodels/login_viewmodel.dart` — Login form state + submit
- `lib/features/auth/viewmodels/register_viewmodel.dart` — Register form state + submit
- `lib/features/auth/viewmodels/forgot_password_viewmodel.dart` — Forgot password state machine
- `lib/features/auth/pages/login_page.dart` — Login UI
- `lib/features/auth/pages/register_page.dart` — Register UI
- `lib/features/auth/pages/forgot_password_page.dart` — Forgot password UI
- `lib/features/auth/widgets/auth_page_scaffold.dart` — Shared background/scaffold
- `lib/features/auth/widgets/auth_text_field.dart` — Reusable text field
- `lib/features/auth/widgets/auth_button.dart` — Primary action button

**Files to modify:**
- `lib/router.dart` — Add auth routes + redirect guards
- `lib/core/network/auth_interceptor.dart` — Integrate Amplify token injection
- `lib/main.dart` — Add Amplify configuration on startup
- `lib/core/widgets/scaffold_with_nav_bar.dart` — Add logout button/action

---

## Task 1: AuthRepository

**Files:**
- Create: `lib/features/auth/data/repositories/auth_repository.dart`

**Purpose:** Abstract all Amplify Auth interactions behind a repository interface.

- [ ] **Step 1: Write the AuthRepository interface + Amplify implementation**

```dart
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

abstract class AuthRepository {
  Future<String> signIn(String email, String password);
  Future<void> signUp(String email, String password);
  Future<void> confirmSignUp(String email, String code);
  Future<void> resendSignUpCode(String email);
  Future<void> resetPassword(String email);
  Future<void> confirmResetPassword(String email, String code, String newPassword);
  Future<void> signOut();
  Future<bool> isAuthenticated();
}

class AmplifyAuthRepository implements AuthRepository {
  @override
  Future<String> signIn(String email, String password) async {
    final result = await Amplify.Auth.signIn(
      username: email,
      password: password,
    );
    if (!result.isSignedIn) {
      throw AuthException('Login failed. Please check your credentials.');
    }
    final session = await Amplify.Auth.fetchAuthSession();
    final user = await Amplify.Auth.getCurrentUser();
    return user.userId;
  }

  @override
  Future<void> signUp(String email, String password) async {
    final result = await Amplify.Auth.signUp(
      username: email,
      password: password,
    );
    if (result.nextStep.signUpStep == AuthSignUpStep.confirmSignUp) {
      // Requires email confirmation
      return;
    }
  }

  @override
  Future<void> confirmSignUp(String email, String code) async {
    await Amplify.Auth.confirmSignUp(
      username: email,
      confirmationCode: code,
    );
  }

  @override
  Future<void> resendSignUpCode(String email) async {
    await Amplify.Auth.resendSignUpCode(username: email);
  }

  @override
  Future<void> resetPassword(String email) async {
    await Amplify.Auth.resetPassword(username: email);
  }

  @override
  Future<void> confirmResetPassword(String email, String code, String newPassword) async {
    await Amplify.Auth.confirmResetPassword(
      username: email,
      newPassword: newPassword,
      confirmationCode: code,
    );
  }

  @override
  Future<void> signOut() async {
    await Amplify.Auth.signOut();
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } catch (_) {
      return false;
    }
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/auth/data/repositories/auth_repository.dart
git commit -m "feat(auth): add AuthRepository with Amplify Cognito implementation"
```

---

## Task 2: AuthState

**Files:**
- Create: `lib/features/auth/viewmodels/auth_state.dart`

**Purpose:** Immutable state object representing authentication status.

- [ ] **Step 1: Write AuthState class**

```dart
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.unknown;

  const AuthState._({
    this.status = AuthStatus.unknown,
    this.userId,
    this.errorMessage,
  });

  const AuthState.unknown() : this._();

  const AuthState.authenticated(String userId)
      : this._(status: AuthStatus.authenticated, userId: userId);

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? errorMessage,
  }) {
    return AuthState._(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      errorMessage: errorMessage,
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/auth/viewmodels/auth_state.dart
git commit -m "feat(auth): add AuthState class"
```

---

## Task 3: AuthViewModel (Global)

**Files:**
- Create: `lib/features/auth/viewmodels/auth_viewmodel.dart`

**Purpose:** Global auth state management. Checks session on init, exposes signOut.

- [ ] **Step 1: Write AuthViewModel**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/auth_repository.dart';
import 'auth_state.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  AuthState build() {
    _checkAuth();
    return const AuthState.unknown();
  }

  Future<void> _checkAuth() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      final isAuthenticated = await repository.isAuthenticated();
      if (isAuthenticated) {
        state = const AuthState.authenticated('');
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> signOut() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signOut();
    } catch (_) {
      // Ignore sign-out errors
    }
    state = const AuthState.unauthenticated();
  }

  void setAuthenticated(String userId) {
    state = AuthState.authenticated(userId);
  }

  void setUnauthenticated() {
    state = const AuthState.unauthenticated();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AmplifyAuthRepository();
});
```

- [ ] **Step 2: Run build_runner to generate .g.dart**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/viewmodels/auth_viewmodel.dart lib/features/auth/viewmodels/auth_viewmodel.g.dart
git commit -m "feat(auth): add global AuthViewModel with Riverpod"
```

---

## Task 4: Shared Auth Widgets

### Task 4a: AuthPageScaffold

**Files:**
- Create: `lib/features/auth/widgets/auth_page_scaffold.dart`

- [ ] **Step 1: Write AuthPageScaffold**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AuthPageScaffold extends StatelessWidget {
  final List<Widget> children;

  const AuthPageScaffold({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).sizeHeight -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    // Logo
                    Icon(
                      Icons.local_movies,
                      size: 96,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'lorebase',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 48),
                    ...children,
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### Task 4b: AuthTextField

**Files:**
- Create: `lib/features/auth/widgets/auth_text_field.dart`

- [ ] **Step 2: Write AuthTextField**

```dart
import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final VoidCallback? onToggleObscure;
  final FormFieldValidator<String>? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onToggleObscure,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
```

### Task 4c: AuthButton

**Files:**
- Create: `lib/features/auth/widgets/auth_button.dart`

- [ ] **Step 3: Write AuthButton**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/auth/widgets/
git commit -m "feat(auth): add shared auth widgets (scaffold, text field, button)"
```

---

## Task 5: LoginPage + LoginViewModel

### Task 5a: LoginViewModel

**Files:**
- Create: `lib/features/auth/viewmodels/login_viewmodel.dart`

- [ ] **Step 1: Write LoginViewModel**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/auth_repository.dart';
import 'auth_viewmodel.dart';

part 'login_viewmodel.g.dart';

class LoginState {
  final String email;
  final String password;
  final bool isLoading;
  final String? errorMessage;
  final bool obscurePassword;

  const LoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.errorMessage,
    this.obscurePassword = true,
  });

  bool get isValid => email.isNotEmpty && password.isNotEmpty;

  LoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? errorMessage,
    bool? obscurePassword,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  LoginState build() => const LoginState();

  void setEmail(String email) {
    state = state.copyWith(email: email, errorMessage: null);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, errorMessage: null);
  }

  void toggleObscurePassword() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  Future<bool> submit() async {
    if (!state.isValid) {
      state = state.copyWith(errorMessage: 'Preencha e-mail e senha');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      final userId = await repository.signIn(state.email, state.password);
      ref.read(authViewModelProvider.notifier).setAuthenticated(userId);
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'E-mail ou senha incorretos',
      );
      return false;
    }
  }
}
```

### Task 5b: LoginPage

**Files:**
- Create: `lib/features/auth/pages/login_page.dart`

- [ ] **Step 2: Write LoginPage**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/login_viewmodel.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_page_scaffold.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      ref.read(loginViewModelProvider.notifier).setEmail(_emailController.text);
    });
    _passwordController.addListener(() {
      ref.read(loginViewModelProvider.notifier).setPassword(_passwordController.text);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await ref.read(loginViewModelProvider.notifier).submit();
    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);

    return AuthPageScaffold(
      children: [
        Text(
          'Bem-vindo de volta',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Entre para continuar suas listas',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 32),
        AuthTextField(
          controller: _emailController,
          hint: 'E-mail',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          errorText: loginState.errorMessage != null && !loginState.isValid
              ? loginState.errorMessage
              : null,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          controller: _passwordController,
          hint: 'Senha',
          icon: Icons.lock_outline,
          obscureText: loginState.obscurePassword,
          onToggleObscure: () {
            ref.read(loginViewModelProvider.notifier).toggleObscurePassword();
          },
        ),
        if (loginState.errorMessage != null && loginState.isValid) ...[
          const SizedBox(height: 12),
          Text(
            loginState.errorMessage!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        AuthButton(
          text: 'Entrar',
          isLoading: loginState.isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.push('/forgot-password'),
          child: const Text(
            'Esqueceu a senha?',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white30)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ou',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            ),
            Expanded(child: Divider(color: Colors.white30)),
          ],
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.push('/register'),
          child: const Text.rich(
            TextSpan(
              text: 'Não tem conta? ',
              style: TextStyle(color: Colors.white70),
              children: [
                TextSpan(
                  text: 'Cadastre-se',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/auth/viewmodels/login_viewmodel.dart lib/features/auth/viewmodels/login_viewmodel.g.dart lib/features/auth/pages/login_page.dart
git commit -m "feat(auth): add LoginPage and LoginViewModel"
```

---

## Task 6: RegisterPage + RegisterViewModel

### Task 6a: RegisterViewModel

**Files:**
- Create: `lib/features/auth/viewmodels/register_viewmodel.dart`

- [ ] **Step 1: Write RegisterViewModel**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/auth_repository.dart';
import 'auth_viewmodel.dart';

part 'register_viewmodel.g.dart';

enum PasswordStrength { weak, medium, strong }

class RegisterState {
  final String email;
  final String password;
  final String confirmPassword;
  final bool termsAccepted;
  final bool isLoading;
  final String? errorMessage;
  final bool obscurePassword;
  final bool showConfirmation; // Show code input after signUp
  final String? confirmationCode;

  const RegisterState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.termsAccepted = false,
    this.isLoading = false,
    this.errorMessage,
    this.obscurePassword = true,
    this.showConfirmation = false,
    this.confirmationCode,
  });

  PasswordStrength get passwordStrength {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;

    switch (score) {
      case 0:
      case 1:
        return PasswordStrength.weak;
      case 2:
        return PasswordStrength.medium;
      default:
        return PasswordStrength.strong;
    }
  }

  bool get isValid {
    return email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        termsAccepted &&
        password == confirmPassword &&
        passwordStrength != PasswordStrength.weak;
  }

  RegisterState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    bool? termsAccepted,
    bool? isLoading,
    String? errorMessage,
    bool? obscurePassword,
    bool? showConfirmation,
    String? confirmationCode,
  }) {
    return RegisterState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      showConfirmation: showConfirmation ?? this.showConfirmation,
      confirmationCode: confirmationCode ?? this.confirmationCode,
    );
  }
}

@riverpod
class RegisterViewModel extends _$RegisterViewModel {
  @override
  RegisterState build() => const RegisterState();

  void setEmail(String email) {
    state = state.copyWith(email: email, errorMessage: null);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, errorMessage: null);
  }

  void setConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword, errorMessage: null);
  }

  void toggleTerms() {
    state = state.copyWith(termsAccepted: !state.termsAccepted, errorMessage: null);
  }

  void toggleObscurePassword() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void setConfirmationCode(String code) {
    state = state.copyWith(confirmationCode: code, errorMessage: null);
  }

  Future<bool> submit() async {
    if (!state.isValid) {
      if (state.password != state.confirmPassword) {
        state = state.copyWith(errorMessage: 'As senhas não coincidem');
      } else if (state.passwordStrength == PasswordStrength.weak) {
        state = state.copyWith(errorMessage: 'A senha é muito fraca');
      } else if (!state.termsAccepted) {
        state = state.copyWith(errorMessage: 'Aceite os termos de uso');
      } else {
        state = state.copyWith(errorMessage: 'Preencha todos os campos');
      }
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signUp(state.email, state.password);
      // After signUp, show confirmation UI
      state = state.copyWith(isLoading: false, showConfirmation: true);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao criar conta. Tente novamente.',
      );
      return false;
    }
  }

  Future<bool> confirmSignUp() async {
    if (state.confirmationCode == null || state.confirmationCode!.isEmpty) {
      state = state.copyWith(errorMessage: 'Digite o código de confirmação');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.confirmSignUp(state.email, state.confirmationCode!);
      // Auto-login after confirmation
      final userId = await repository.signIn(state.email, state.password);
      ref.read(authViewModelProvider.notifier).setAuthenticated(userId);
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Código inválido. Tente novamente.',
      );
      return false;
    }
  }

  Future<void> resendCode() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.resendSignUpCode(state.email);
    } catch (_) {
      // Silently fail or show toast
    }
  }
}
```

### Task 6b: RegisterPage

**Files:**
- Create: `lib/features/auth/pages/register_page.dart`

- [ ] **Step 2: Write RegisterPage**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/register_viewmodel.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_page_scaffold.dart';
import '../widgets/auth_text_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      ref.read(registerViewModelProvider.notifier).setEmail(_emailController.text);
    });
    _passwordController.addListener(() {
      ref.read(registerViewModelProvider.notifier).setPassword(_passwordController.text);
    });
    _confirmController.addListener(() {
      ref.read(registerViewModelProvider.notifier).setConfirmPassword(_confirmController.text);
    });
    _codeController.addListener(() {
      ref.read(registerViewModelProvider.notifier).setConfirmationCode(_codeController.text);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await ref.read(registerViewModelProvider.notifier).submit();
    if (!success && mounted) {
      // Error already shown inline
    }
  }

  Future<void> _confirm() async {
    final success = await ref.read(registerViewModelProvider.notifier).confirmSignUp();
    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  Color _strengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Colors.redAccent;
      case PasswordStrength.medium:
        return Colors.orangeAccent;
      case PasswordStrength.strong:
        return Colors.greenAccent;
    }
  }

  String _strengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Fraca';
      case PasswordStrength.medium:
        return 'Média';
      case PasswordStrength.strong:
        return 'Forte';
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerViewModelProvider);

    return AuthPageScaffold(
      children: [
        Text(
          registerState.showConfirmation ? 'Confirme seu e-mail' : 'Criar conta',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          registerState.showConfirmation
              ? 'Digite o código enviado para ${registerState.email}'
              : 'Comece a organizar suas séries',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 32),
        if (registerState.showConfirmation) ...[
          AuthTextField(
            controller: _codeController,
            hint: 'Código de confirmação',
            icon: Icons.confirmation_number_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          AuthButton(
            text: 'Confirmar e entrar',
            isLoading: registerState.isLoading,
            onPressed: _confirm,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => ref.read(registerViewModelProvider.notifier).resendCode(),
            child: const Text(
              'Reenviar código',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ] else ...[
          AuthTextField(
            controller: _emailController,
            hint: 'E-mail',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordController,
            hint: 'Senha',
            icon: Icons.lock_outline,
            obscureText: registerState.obscurePassword,
            onToggleObscure: () {
              ref.read(registerViewModelProvider.notifier).toggleObscurePassword();
            },
          ),
          const SizedBox(height: 8),
          // Password strength indicator
          if (registerState.password.isNotEmpty)
            Row(
              children: [
                Expanded(
                  flex: registerState.passwordStrength == PasswordStrength.weak ? 1 : 0,
                  child: Container(height: 3, color: Colors.redAccent),
                ),
                Expanded(
                  flex: registerState.passwordStrength == PasswordStrength.medium ? 1 : 0,
                  child: Container(height: 3, color: Colors.orangeAccent),
                ),
                Expanded(
                  flex: registerState.passwordStrength == PasswordStrength.strong ? 1 : 0,
                  child: Container(height: 3, color: Colors.greenAccent),
                ),
                const SizedBox(width: 8),
                Text(
                  _strengthText(registerState.passwordStrength),
                  style: TextStyle(
                    color: _strengthColor(registerState.passwordStrength),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _confirmController,
            hint: 'Confirmar senha',
            icon: Icons.lock_outline,
            obscureText: registerState.obscurePassword,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: registerState.termsAccepted,
                onChanged: (_) => ref.read(registerViewModelProvider.notifier).toggleTerms(),
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return Colors.white30;
                }),
                checkColor: Theme.of(context).primaryColor,
              ),
              Expanded(
                child: Text(
                  'Li e aceito os Termos de Uso',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AuthButton(
            text: 'Criar conta',
            isLoading: registerState.isLoading,
            onPressed: _submit,
          ),
        ],
        if (registerState.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            registerState.errorMessage!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text.rich(
            TextSpan(
              text: 'Já tem conta? ',
              style: TextStyle(color: Colors.white70),
              children: [
                TextSpan(
                  text: 'Entrar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/auth/viewmodels/register_viewmodel.dart lib/features/auth/viewmodels/register_viewmodel.g.dart lib/features/auth/pages/register_page.dart
git commit -m "feat(auth): add RegisterPage and RegisterViewModel"
```

---

## Task 7: ForgotPasswordPage + ForgotPasswordViewModel

### Task 7a: ForgotPasswordViewModel

**Files:**
- Create: `lib/features/auth/viewmodels/forgot_password_viewmodel.dart`

- [ ] **Step 1: Write ForgotPasswordViewModel**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/auth_repository.dart';

part 'forgot_password_viewmodel.g.dart';

enum ForgotPasswordPhase { requestCode, resetPassword }

class ForgotPasswordState {
  final String email;
  final String code;
  final String newPassword;
  final String confirmPassword;
  final bool isLoading;
  final String? errorMessage;
  final ForgotPasswordPhase phase;
  final bool obscurePassword;

  const ForgotPasswordState({
    this.email = '',
    this.code = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.errorMessage,
    this.phase = ForgotPasswordPhase.requestCode,
    this.obscurePassword = true,
  });

  bool get canRequestCode => email.isNotEmpty;

  bool get canResetPassword {
    return code.isNotEmpty &&
        newPassword.isNotEmpty &&
        newPassword == confirmPassword;
  }

  ForgotPasswordState copyWith({
    String? email,
    String? code,
    String? newPassword,
    String? confirmPassword,
    bool? isLoading,
    String? errorMessage,
    ForgotPasswordPhase? phase,
    bool? obscurePassword,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      code: code ?? this.code,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      phase: phase ?? this.phase,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}

@riverpod
class ForgotPasswordViewModel extends _$ForgotPasswordViewModel {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  void setEmail(String email) {
    state = state.copyWith(email: email, errorMessage: null);
  }

  void setCode(String code) {
    state = state.copyWith(code: code, errorMessage: null);
  }

  void setNewPassword(String password) {
    state = state.copyWith(newPassword: password, errorMessage: null);
  }

  void setConfirmPassword(String password) {
    state = state.copyWith(confirmPassword: password, errorMessage: null);
  }

  void toggleObscurePassword() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  Future<bool> requestCode() async {
    if (!state.canRequestCode) {
      state = state.copyWith(errorMessage: 'Digite seu e-mail');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.resetPassword(state.email);
      state = state.copyWith(isLoading: false, phase: ForgotPasswordPhase.resetPassword);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao enviar código. Tente novamente.',
      );
      return false;
    }
  }

  Future<bool> resetPassword() async {
    if (!state.canResetPassword) {
      if (state.newPassword != state.confirmPassword) {
        state = state.copyWith(errorMessage: 'As senhas não coincidem');
      } else {
        state = state.copyWith(errorMessage: 'Preencha todos os campos');
      }
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.confirmResetPassword(
        state.email,
        state.code,
        state.newPassword,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao redefinir senha. Tente novamente.',
      );
      return false;
    }
  }
}
```

### Task 7b: ForgotPasswordPage

**Files:**
- Create: `lib/features/auth/pages/forgot_password_page.dart`

- [ ] **Step 2: Write ForgotPasswordPage**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/forgot_password_viewmodel.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_page_scaffold.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      ref.read(forgotPasswordViewModelProvider.notifier).setEmail(_emailController.text);
    });
    _codeController.addListener(() {
      ref.read(forgotPasswordViewModelProvider.notifier).setCode(_codeController.text);
    });
    _passwordController.addListener(() {
      ref.read(forgotPasswordViewModelProvider.notifier).setNewPassword(_passwordController.text);
    });
    _confirmController.addListener(() {
      ref.read(forgotPasswordViewModelProvider.notifier).setConfirmPassword(_confirmController.text);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    final success = await ref.read(forgotPasswordViewModelProvider.notifier).requestCode();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código enviado para seu e-mail')),
      );
    }
  }

  Future<void> _resetPassword() async {
    final success = await ref.read(forgotPasswordViewModelProvider.notifier).resetPassword();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha redefinida com sucesso')),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordViewModelProvider);

    return AuthPageScaffold(
      children: [
        Text(
          state.phase == ForgotPasswordPhase.requestCode
              ? 'Recuperar senha'
              : 'Nova senha',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          state.phase == ForgotPasswordPhase.requestCode
              ? 'Digite seu e-mail para receber um código de verificação'
              : 'Digite o código enviado para seu e-mail e sua nova senha',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 32),
        if (state.phase == ForgotPasswordPhase.requestCode) ...[
          AuthTextField(
            controller: _emailController,
            hint: 'E-mail',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          AuthButton(
            text: 'Enviar código',
            isLoading: state.isLoading,
            onPressed: _requestCode,
          ),
        ] else ...[
          AuthTextField(
            controller: _codeController,
            hint: 'Código de verificação',
            icon: Icons.confirmation_number_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordController,
            hint: 'Nova senha',
            icon: Icons.lock_outline,
            obscureText: state.obscurePassword,
            onToggleObscure: () {
              ref.read(forgotPasswordViewModelProvider.notifier).toggleObscurePassword();
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _confirmController,
            hint: 'Confirmar nova senha',
            icon: Icons.lock_outline,
            obscureText: state.obscurePassword,
          ),
          const SizedBox(height: 24),
          AuthButton(
            text: 'Redefinir senha',
            isLoading: state.isLoading,
            onPressed: _resetPassword,
          ),
        ],
        if (state.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            state.errorMessage!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text(
            'Voltar para o login',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/auth/viewmodels/forgot_password_viewmodel.dart lib/features/auth/viewmodels/forgot_password_viewmodel.g.dart lib/features/auth/pages/forgot_password_page.dart
git commit -m "feat(auth): add ForgotPasswordPage and ForgotPasswordViewModel"
```

---

## Task 8: Router Updates

**Files:**
- Modify: `lib/router.dart`

**Purpose:** Add auth routes and redirect guards.

- [ ] **Step 1: Update router.dart**

Replace the entire content of `lib/router.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/widgets/scaffold_with_nav_bar.dart';
import 'features/auth/pages/forgot_password_page.dart';
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/register_page.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/dashboard/pages/dashboard_page.dart';
import 'features/recommendation/pages/recommendation_page.dart';
import 'features/series/pages/series_search_page.dart';
import 'features/tracking/pages/tracking_list_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthRoute = ['/login', '/register', '/forgot-password']
          .contains(state.matchedLocation);
      final isAuthenticated = authState.isAuthenticated;

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SeriesSearchPage(),
          ),
          GoRoute(
            path: '/tracking',
            builder: (context, state) => const TrackingListPage(),
          ),
          GoRoute(
            path: '/recommend',
            builder: (context, state) => const RecommendationPage(),
          ),
        ],
      ),
    ],
  );
});
```

- [ ] **Step 2: Commit**

```bash
git add lib/router.dart
git commit -m "feat(auth): add auth routes and redirect guards to router"
```

---

## Task 9: AuthInterceptor Integration

**Files:**
- Modify: `lib/core/network/auth_interceptor.dart`

**Purpose:** Inject Bearer token from Amplify into all HTTP requests.

- [ ] **Step 1: Update auth_interceptor.dart**

Replace the entire content with:

```dart
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        final token = session.userPoolTokensResult.value.accessToken.raw;
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Allow request to proceed without auth header
      // Backend may handle unauthenticated requests
    }
    handler.next(options);
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/network/auth_interceptor.dart
git commit -m "feat(auth): integrate AuthInterceptor with Amplify token injection"
```

---

## Task 10: Amplify Configuration on App Startup

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/app.dart`

**Purpose:** Configure Amplify on app startup and show loading while auth state is unknown.

- [ ] **Step 1: Update main.dart**

Replace with:

```dart
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'amplifyconfiguration.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(
    const ProviderScope(
      child: LorebaseApp(),
    ),
  );
}

Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    await Amplify.addPlugin(auth);
    await Amplify.configure(amplifyconfig);
  } on Exception catch (e) {
    debugPrint('Could not configure Amplify: $e');
  }
}
```

- [ ] **Step 2: Update app.dart**

Replace with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'router.dart';

class LorebaseApp extends ConsumerWidget {
  const LorebaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return MaterialApp.router(
      title: 'lorebase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        if (authState.isLoading) {
          return Material(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        return child!;
      },
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart lib/app.dart
git commit -m "feat(auth): configure Amplify on startup and add auth loading state"
```

---

## Task 11: Logout in Navigation Scaffold

**Files:**
- Modify: `lib/core/widgets/scaffold_with_nav_bar.dart`

**Purpose:** Add logout option to the bottom nav scaffold.

- [ ] **Step 1: Read current scaffold_with_nav_bar.dart**

Read the file first to understand current structure.

- [ ] **Step 2: Add logout action**

Add an `AppBar` or menu action that calls `ref.read(authViewModelProvider.notifier).signOut()`.

For minimal change, add to the Scaffold:
```dart
appBar: AppBar(
  title: const Text('lorebase'),
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () => ref.read(authViewModelProvider.notifier).signOut(),
    ),
  ],
),
```

And add the import:
```dart
import '../../features/auth/viewmodels/auth_viewmodel.dart';
```

- [ ] **Step 3: Commit**

```bash
git add lib/core/widgets/scaffold_with_nav_bar.dart
git commit -m "feat(auth): add logout button to scaffold"
```

---

## Task 12: Build Verification

**Files:**
- All modified files

**Purpose:** Verify the app compiles successfully.

- [ ] **Step 1: Run flutter build**

```bash
flutter build apk --debug
```

Expected: Build succeeds with no errors.

- [ ] **Step 2: Fix any compilation errors**

If errors appear, fix them and re-run.

- [ ] **Step 3: Final commit**

```bash
git add .
git commit -m "feat(auth): complete auth feature implementation"
```

---

## Spec Coverage Checklist

| Spec Section | Task | Status |
|-------------|------|--------|
| AuthRepository interface + Amplify impl | Task 1 | ✅ |
| AuthState class | Task 2 | ✅ |
| AuthViewModel (global) | Task 3 | ✅ |
| Shared widgets (scaffold, text field, button) | Task 4 | ✅ |
| LoginPage + LoginViewModel | Task 5 | ✅ |
| RegisterPage + RegisterViewModel | Task 6 | ✅ |
| ForgotPasswordPage + ForgotPasswordViewModel | Task 7 | ✅ |
| Router routes + redirect guards | Task 8 | ✅ |
| AuthInterceptor token injection | Task 9 | ✅ |
| Amplify startup configuration | Task 10 | ✅ |
| Logout action | Task 11 | ✅ |
| Build verification | Task 12 | ✅ |
| Password strength indicator | Task 6b | ✅ |
| Email confirmation inline | Task 6b | ✅ |
| Error mapping (PT-BR) | Tasks 5-7 | ✅ |

---

## Open Items (Non-blocking)

1. **amplifyconfiguration.dart** — This file is generated by Amplify CLI and must exist. If it doesn't, run `amplify pull` or create a stub for local development.
2. **Backend Cognito User Pool** — Must be configured and accessible for auth to work end-to-end.
3. **Terms of Service URL** — Currently placeholder text; needs real URL before launch.

---

*End of Implementation Plan*
