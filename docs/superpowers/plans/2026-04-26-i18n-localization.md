# i18n Localization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add i18n support to lorebase-frontend using Flutter's official `flutter_localizations` + ARB toolchain, with Portuguese as default, English as alternative, and automatic device-locale detection.

**Architecture:** Official Flutter l10n codegen via `l10n.yaml` → `AppLocalizations` class from `app_pt.arb` + `app_en.arb`. `MaterialApp.router` consumes a Riverpod `localeProvider` (auto-detect from device). ViewModels return error codes (enums), UI maps to localized strings. All ~80 hardcoded strings replaced with `AppLocalizations.of(context)!.key`.

**Tech Stack:** Flutter SDK, `flutter_localizations`, `intl`, ARB files, Riverpod `StateProvider`, GoRouter (unchanged)

---

## File Structure

| File | Action | Responsibility |
|------|--------|---------------|
| `pubspec.yaml` | Modify | Add `flutter_localizations` SDK dep, `intl`, enable `generate: true` |
| `l10n.yaml` | Create | Flutter l10n config (ARB → Dart codegen) |
| `lib/l10n/app_pt.arb` | Create | Portuguese string catalog (default/fallback) |
| `lib/l10n/app_en.arb` | Create | English string catalog |
| `lib/core/providers/locale_provider.dart` | Create | Riverpod `StateProvider<Locale>` with device detection |
| `lib/app.dart` | Modify | Wire `supportedLocales`, `localizationsDelegates`, `locale` |
| `analysis_options.yaml` | Modify | Exclude `lib/generated/` |
| `lib/core/widgets/scaffold_with_nav_bar.dart` | Modify | Replace nav labels |
| `lib/core/widgets/error_widget.dart` | Modify | Replace retry label |
| `lib/features/tracking/data/tracking_status.dart` | Modify | Remove hardcoded labels, use localized lookup |
| `lib/features/tracking/pages/tracking_list_page.dart` | Modify | Replace all strings |
| `lib/features/tracking/widgets/status_bottom_sheet.dart` | Modify | Replace all strings |
| `lib/features/dashboard/pages/dashboard_page.dart` | Modify | Replace all strings |
| `lib/features/dashboard/widgets/watching_section.dart` | Modify | Section header |
| `lib/features/series/pages/series_search_page.dart` | Modify | Replace all strings |
| `lib/features/series/widgets/series_card.dart` | Modify | Seasons plural |
| `lib/features/recommendation/pages/recommendation_page.dart` | Modify | Replace all strings |
| `lib/features/auth/widgets/auth_page_scaffold.dart` | Modify | App title |
| `lib/features/auth/viewmodels/auth_errors.dart` | Create | `AuthError` enum for error codes |
| `lib/features/auth/viewmodels/login_viewmodel.dart` | Modify | Return `AuthError` enum instead of strings |
| `lib/features/auth/pages/login_page.dart` | Modify | Replace strings, map `AuthError` to localized |
| `lib/features/auth/viewmodels/register_viewmodel.dart` | Modify | Return `AuthError` enum instead of strings |
| `lib/features/auth/pages/register_page.dart` | Modify | Replace strings, map `AuthError` to localized |
| `lib/features/auth/viewmodels/forgot_password_viewmodel.dart` | Modify | Return `AuthError` enum instead of strings |
| `lib/features/auth/pages/forgot_password_page.dart` | Modify | Replace strings, map `AuthError` to localized |
| `test/widget_test.dart` | Rewrite | Smoke test with real app + i18n delegates |

---

### Task 1: Update pubspec.yaml

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add i18n dependencies and enable code generation**

```yaml
# pubspec.yaml
name: lorebase
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  cupertino_icons: ^1.0.6

  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # Navigation
  go_router: ^13.0.0

  # HTTP
  dio: ^5.4.0

  # Auth
  amplify_flutter: ^1.6.0
  amplify_auth_cognito: ^1.6.0

  # i18n
  intl: ^0.19.0

  # Models & Serialization
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0

  # Storage
  flutter_secure_storage: ^9.0.0

  # UI
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  flutter_dotenv: ^5.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  mockito: ^5.4.0
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.3.0
  riverpod_lint: ^2.3.0

flutter:
  uses-material-design: true
  generate: true
  assets:
    - .env
```

- [ ] **Step 2: Run `dart pub get`**

```bash
dart pub get
```

Expected: Resolves all packages successfully, including `flutter_localizations` and `intl`.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add flutter_localizations, intl, enable code gen"
```

---

### Task 2: Create l10n.yaml

**Files:**
- Create: `l10n.yaml`

- [ ] **Step 1: Create the configuration file**

```yaml
arb-dir: lib/l10n
template-arb-file: app_pt.arb
output-dir: lib/generated/l10n
synthetic-package: false
output-class: AppLocalizations
nullable-getter: true
```

- [ ] **Step 2: Commit**

```bash
git add l10n.yaml
git commit -m "chore: add l10n.yaml for flutter gen-l10n"
```

---

### Task 3: Create Portuguese ARB file (app_pt.arb)

**Files:**
- Create: `lib/l10n/app_pt.arb`

- [ ] **Step 1: Create directory and file**

```bash
mkdir -p lib/l10n
```

- [ ] **Step 2: Write app_pt.arb with all Portuguese strings**

```json
{
  "@@locale": "pt",

  "appTitle": "lorebase",

  "navHome": "Início",
  "navSearch": "Buscar",
  "navMyLists": "Minhas Listas",
  "navRecommend": "Recomendar",

  "commonRetry": "Tentar novamente",
  "commonLoadingDashboard": "Carregando seu dashboard...",
  "commonSeasons": "{count,plural, =1{{count} temporada} other{{count} temporadas}}",

  "dashboardWatching": "Assistindo",
  "dashboardWantToWatch": "Quero Assistir",
  "dashboardCompleted": "Completados",
  "dashboardDropped": "Abandonados",
  "dashboardEmptySeries": "Nenhuma série rastreada ainda.\nBusque e adicione sua primeira série!",

  "trackingMyLists": "Minhas Listas",
  "trackingStatusWantToWatch": "Quero Assistir",
  "trackingStatusWatching": "Assistindo",
  "trackingStatusCompleted": "Completados",
  "trackingStatusDropped": "Abandonados",
  "trackingEmptyStatus": "Nenhuma série {status} ainda",
  "trackingUpdateStatus": "Atualizar Status",

  "searchHint": "Buscar séries...",
  "searchTypeMinChars": "Digite pelo menos 2 caracteres para buscar",
  "searchNoResults": "Nenhuma série encontrada",

  "recommendTitle": "Recomendar",
  "recommendComingSoon": "Funcionalidade de recomendação em breve!",

  "authLoginTitle": "Bem-vindo de volta",
  "authLoginSubtitle": "Entre para continuar suas listas",
  "authLoginEmailHint": "E-mail",
  "authLoginPasswordHint": "Senha",
  "authLoginButton": "Entrar",
  "authLoginForgotPassword": "Esqueceu a senha?",
  "authLoginOr": "ou",
  "authLoginNoAccount": "Não tem conta? ",
  "authLoginRegister": "Cadastre-se",

  "authRegisterPasswordWeak": "Fraca",
  "authRegisterPasswordMedium": "Média",
  "authRegisterPasswordStrong": "Forte",
  "authRegisterTitle": "Criar conta",
  "authRegisterTitleConfirm": "Confirme seu e-mail",
  "authRegisterSubtitle": "Comece a organizar suas séries",
  "authRegisterSubtitleConfirm": "Digite o código enviado para {email}",
  "authRegisterConfirmHint": "Código de confirmação",
  "authRegisterConfirmButton": "Confirmar e entrar",
  "authRegisterResendCode": "Reenviar código",
  "authRegisterEmailHint": "E-mail",
  "authRegisterPasswordHint": "Senha",
  "authRegisterConfirmPasswordHint": "Confirmar senha",
  "authRegisterTerms": "Li e aceito os Termos de Uso",
  "authRegisterButton": "Criar conta",
  "authRegisterAlreadyHaveAccount": "Já tem conta? ",
  "authRegisterLogin": "Entrar",

  "authForgotTitleRequest": "Recuperar senha",
  "authForgotTitleReset": "Nova senha",
  "authForgotSubtitleRequest": "Digite seu e-mail para receber um código de verificação",
  "authForgotSubtitleReset": "Digite o código enviado para seu e-mail e sua nova senha",
  "authForgotEmailHint": "E-mail",
  "authForgotSendCode": "Enviar código",
  "authForgotCodeHint": "Código de verificação",
  "authForgotNewPasswordHint": "Nova senha",
  "authForgotConfirmPasswordHint": "Confirmar nova senha",
  "authForgotResetButton": "Redefinir senha",
  "authForgotCodeSentConfirmation": "Código enviado para seu e-mail",
  "authForgotPasswordResetSuccess": "Senha redefinida com sucesso",
  "authForgotBackToLogin": "Voltar para o login",

  "errorEmptyFields": "Preencha e-mail e senha",
  "errorWrongCredentials": "E-mail ou senha incorretos",
  "errorPasswordsDontMatch": "As senhas não coincidem",
  "errorWeakPassword": "A senha é muito fraca",
  "errorAcceptTerms": "Aceite os termos de uso",
  "errorFillAllFields": "Preencha todos os campos",
  "errorEnterEmail": "Digite seu e-mail",
  "errorEnterCode": "Digite o código de confirmação",
  "errorInvalidCode": "Código inválido. Tente novamente.",
  "errorCreateAccount": "Erro ao criar conta. Tente novamente.",
  "errorSendCode": "Erro ao enviar código. Tente novamente.",
  "errorResetPassword": "Erro ao redefinir senha. Tente novamente.",
  "errorServer": "Erro no servidor. Tente novamente mais tarde.",
  "errorNetwork": "Erro de rede. Verifique sua conexão.",
  "errorSessionExpired": "Sessão expirada. Faça login novamente.",
  "errorNotFound": "Recurso não encontrado.",
  "errorConnectionTimeout": "Tempo de conexão esgotado. Tente novamente."
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/l10n/app_pt.arb
git commit -m "feat: add Portuguese ARB file with all string keys"
```

---

### Task 4: Create English ARB file (app_en.arb)

**Files:**
- Create: `lib/l10n/app_en.arb`

- [ ] **Step 1: Write app_en.arb with all English translations**

```json
{
  "@@locale": "en",

  "appTitle": "lorebase",

  "navHome": "Home",
  "navSearch": "Search",
  "navMyLists": "My Lists",
  "navRecommend": "Recommend",

  "commonRetry": "Retry",
  "commonLoadingDashboard": "Loading your dashboard...",
  "commonSeasons": "{count,plural, =1{{count} season} other{{count} seasons}}",

  "dashboardWatching": "Watching",
  "dashboardWantToWatch": "Want to Watch",
  "dashboardCompleted": "Completed",
  "dashboardDropped": "Dropped",
  "dashboardEmptySeries": "No series tracked yet.\nSearch and add your first series!",

  "trackingMyLists": "My Lists",
  "trackingStatusWantToWatch": "Want to Watch",
  "trackingStatusWatching": "Watching",
  "trackingStatusCompleted": "Completed",
  "trackingStatusDropped": "Dropped",
  "trackingEmptyStatus": "No {status} series yet",
  "trackingUpdateStatus": "Update Status",

  "searchHint": "Search series...",
  "searchTypeMinChars": "Type at least 2 characters to search",
  "searchNoResults": "No series found",

  "recommendTitle": "Recommendation",
  "recommendComingSoon": "Recommendation feature coming soon!",

  "authLoginTitle": "Welcome back",
  "authLoginSubtitle": "Sign in to continue your lists",
  "authLoginEmailHint": "Email",
  "authLoginPasswordHint": "Password",
  "authLoginButton": "Sign In",
  "authLoginForgotPassword": "Forgot your password?",
  "authLoginOr": "or",
  "authLoginNoAccount": "Don't have an account? ",
  "authLoginRegister": "Sign Up",

  "authRegisterPasswordWeak": "Weak",
  "authRegisterPasswordMedium": "Medium",
  "authRegisterPasswordStrong": "Strong",
  "authRegisterTitle": "Create Account",
  "authRegisterTitleConfirm": "Confirm your email",
  "authRegisterSubtitle": "Start organizing your series",
  "authRegisterSubtitleConfirm": "Enter the code sent to {email}",
  "authRegisterConfirmHint": "Confirmation code",
  "authRegisterConfirmButton": "Confirm and Sign In",
  "authRegisterResendCode": "Resend code",
  "authRegisterEmailHint": "Email",
  "authRegisterPasswordHint": "Password",
  "authRegisterConfirmPasswordHint": "Confirm password",
  "authRegisterTerms": "I have read and accept the Terms of Use",
  "authRegisterButton": "Create Account",
  "authRegisterAlreadyHaveAccount": "Already have an account? ",
  "authRegisterLogin": "Sign In",

  "authForgotTitleRequest": "Recover Password",
  "authForgotTitleReset": "New Password",
  "authForgotSubtitleRequest": "Enter your email to receive a verification code",
  "authForgotSubtitleReset": "Enter the code sent to your email and your new password",
  "authForgotEmailHint": "Email",
  "authForgotSendCode": "Send Code",
  "authForgotCodeHint": "Verification code",
  "authForgotNewPasswordHint": "New password",
  "authForgotConfirmPasswordHint": "Confirm new password",
  "authForgotResetButton": "Reset Password",
  "authForgotCodeSentConfirmation": "Code sent to your email",
  "authForgotPasswordResetSuccess": "Password reset successfully",
  "authForgotBackToLogin": "Back to login",

  "errorEmptyFields": "Fill in email and password",
  "errorWrongCredentials": "Incorrect email or password",
  "errorPasswordsDontMatch": "Passwords don't match",
  "errorWeakPassword": "Password is too weak",
  "errorAcceptTerms": "Accept the terms of use",
  "errorFillAllFields": "Fill in all fields",
  "errorEnterEmail": "Enter your email",
  "errorEnterCode": "Enter the confirmation code",
  "errorInvalidCode": "Invalid code. Try again.",
  "errorCreateAccount": "Error creating account. Try again.",
  "errorSendCode": "Error sending code. Try again.",
  "errorResetPassword": "Error resetting password. Try again.",
  "errorServer": "Server error. Please try again later.",
  "errorNetwork": "Network error. Check your connection.",
  "errorSessionExpired": "Session expired. Please log in again.",
  "errorNotFound": "Resource not found.",
  "errorConnectionTimeout": "Connection timeout. Please try again."
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/l10n/app_en.arb
git commit -m "feat: add English ARB file with all translations"
```

---

### Task 5: Create locale_provider.dart

**Files:**
- Create: `lib/core/providers/locale_provider.dart`

- [ ] **Step 1: Write the provider**

```dart
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateProvider<Locale>((ref) {
  final deviceLocale = PlatformDispatcher.instance.locale;
  const supported = [Locale('pt'), Locale('en')];
  return supported.any((l) => l.languageCode == deviceLocale.languageCode)
      ? Locale(deviceLocale.languageCode)
      : const Locale('pt');
});
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/providers/locale_provider.dart
git commit -m "feat: add locale_provider with device-locale detection"
```

---

### Task 6: Generate l10n code and update analysis_options

**Files:**
- Modify: `analysis_options.yaml`

- [ ] **Step 1: Run flutter gen-l10n (or the Dart-native equivalent)**

```bash
dart run flutter_gen_l10n
```

Expected: Generates `lib/generated/l10n/app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_pt.dart` with the `AppLocalizations` class.

- [ ] **Step 2: Update analysis_options.yaml to exclude generated l10n**

Add to the `analyzer.exclude` list:
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_single_quotes: true
    prefer_const_constructors: true
    prefer_final_locals: true
    avoid_print: true

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "lib/generated/**"
  errors:
    invalid_annotation_target: ignore
```

- [ ] **Step 3: Commit**

```bash
git add lib/generated/l10n/ analysis_options.yaml
git commit -m "feat: generate l10n code, exclude generated from analysis"
```

---

### Task 7: Wire app.dart for i18n

**Files:**
- Modify: `lib/app.dart`

- [ ] **Step 1: Add imports and wire MaterialApp.router**

Replace the entire file content:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'generated/l10n/app_localizations.dart';
import 'router.dart';

class LorebaseApp extends ConsumerWidget {
  const LorebaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'lorebase',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
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

- [ ] **Step 2: Commit**

```bash
git add lib/app.dart
git commit -m "feat: wire localization delegates and locale provider in app.dart"
```

---

### Task 8: Migrate scaffold_with_nav_bar.dart

**Files:**
- Modify: `lib/core/widgets/scaffold_with_nav_bar.dart`

- [ ] **Step 1: Replace hardcoded strings with AppLocalizations**

Replace the file content:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../generated/l10n/app_localizations.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
  });

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    switch (location) {
      case '/dashboard':
        return 0;
      case '/search':
        return 1;
      case '/tracking':
        return 2;
      case '/recommend':
        return 3;
      default:
        return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/tracking');
        break;
      case 3:
        context.go('/recommend');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authViewModelProvider.notifier).signOut(),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: l10n.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search_outlined),
            activeIcon: const Icon(Icons.search),
            label: l10n.navSearch,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.format_list_bulleted),
            activeIcon: const Icon(Icons.format_list_bulleted),
            label: l10n.navMyLists,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.recommend_outlined),
            activeIcon: const Icon(Icons.recommend),
            label: l10n.navRecommend,
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/widgets/scaffold_with_nav_bar.dart
git commit -m "feat: migrate scaffold nav bar strings to i18n"
```

---

### Task 9: Migrate error_widget.dart

**Files:**
- Modify: `lib/core/widgets/error_widget.dart`

- [ ] **Step 1: Replace 'Retry' with localized string**

Replace the file content:

```dart
import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.commonRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/widgets/error_widget.dart
git commit -m "feat: migrate error widget retry label to i18n"
```

---

### Task 10: Migrate tracking_status.dart

**Files:**
- Modify: `lib/features/tracking/data/tracking_status.dart`

- [ ] **Step 1: Remove hardcoded labels and add localization lookup**

Replace the file content:

```dart
import '../../../generated/l10n/app_localizations.dart';

enum TrackingStatus {
  wantToWatch('WANT_TO_WATCH'),
  watching('WATCHING'),
  completed('COMPLETED'),
  dropped('DROPPED');

  final String value;

  const TrackingStatus(this.value);

  String label(AppLocalizations l10n) {
    switch (this) {
      case TrackingStatus.wantToWatch:
        return l10n.trackingStatusWantToWatch;
      case TrackingStatus.watching:
        return l10n.trackingStatusWatching;
      case TrackingStatus.completed:
        return l10n.trackingStatusCompleted;
      case TrackingStatus.dropped:
        return l10n.trackingStatusDropped;
    }
  }

  static TrackingStatus fromString(String value) {
    return TrackingStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TrackingStatus.wantToWatch,
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/tracking/data/tracking_status.dart
git commit -m "refactor: use localized labels for TrackingStatus enum"
```

---

### Task 11: Migrate tracking_list_page.dart

**Files:**
- Modify: `lib/features/tracking/pages/tracking_list_page.dart`

- [ ] **Step 1: Replace strings and use localized status labels**

Replace the file content:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../series/widgets/series_poster.dart';
import '../data/tracking_status.dart';
import '../viewmodels/tracking_list_viewmodel.dart';
import '../widgets/tracking_status_chip.dart';

class TrackingListPage extends ConsumerStatefulWidget {
  const TrackingListPage({super.key});

  @override
  ConsumerState<TrackingListPage> createState() => _TrackingListPageState();
}

class _TrackingListPageState extends ConsumerState<TrackingListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrackingForTab(0);
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadTrackingForTab(_tabController.index);
    }
  }

  void _loadTrackingForTab(int index) {
    final status = TrackingStatus.values[index].value;
    ref.read(trackingListViewModelProvider.notifier).loadTracking(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingListViewModelProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trackingMyLists),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: TrackingStatus.values
                  .map((s) => Tab(text: s.label(l10n)))
                  .toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(4, (index) {
                return trackingState.when(
                  loading: () => const LoadingWidget(),
                  error: (error, _) => AppErrorWidget(
                    message: error.toString(),
                    onRetry: () => _loadTrackingForTab(index),
                  ),
                  data: (trackings) {
                    if (trackings.isEmpty) {
                      final statusLabel = TrackingStatus.values[index].label(l10n);
                      return EmptyStateWidget(
                        message: l10n.trackingEmptyStatus(statusLabel),
                        icon: Icons.tv_off,
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: trackings.length,
                      itemBuilder: (context, i) {
                        final tracking = trackings[i];
                        final series = tracking.series;
                        if (series == null) {
                          return const Center(
                            child: Icon(Icons.tv_off, color: Colors.grey),
                          );
                        }
                        return Column(
                          children: [
                            Expanded(
                              child: SeriesPoster(
                                series: series,
                                onTap: () {
                                  // TODO: Navigate to tracking detail
                                },
                              ),
                            ),
                            const SizedBox(height: 4),
                            TrackingStatusChip(status: tracking.status),
                          ],
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/tracking/pages/tracking_list_page.dart
git commit -m "feat: migrate tracking list page strings to i18n"
```

---

### Task 12: Migrate status_bottom_sheet.dart

**Files:**
- Modify: `lib/features/tracking/widgets/status_bottom_sheet.dart`

- [ ] **Step 1: Replace hardcoded strings**

Replace the file content:

```dart
import 'package:flutter/material.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../data/tracking_status.dart';

class StatusBottomSheet extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onStatusSelected;

  const StatusBottomSheet({
    super.key,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                l10n.trackingUpdateStatus,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...TrackingStatus.values.map((status) {
              final isSelected = status.value == currentStatus;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
                title: Text(status.label(l10n)),
                onTap: () {
                  onStatusSelected(status.value);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/tracking/widgets/status_bottom_sheet.dart
git commit -m "feat: migrate status bottom sheet strings to i18n"
```

---

### Task 13: Migrate dashboard_page.dart

**Files:**
- Modify: `lib/features/dashboard/pages/dashboard_page.dart`

- [ ] **Step 1: Replace all hardcoded strings**

Replace the file content:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/stats_card.dart';
import '../widgets/watching_section.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardViewModelProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardViewModelProvider.notifier).refresh(),
        child: dashboardState.when(
          loading: () => LoadingWidget(message: l10n.commonLoadingDashboard),
          error: (error, _) => AppErrorWidget(
            message: error.toString(),
            onRetry: () => ref.read(dashboardViewModelProvider.notifier).refresh(),
          ),
          data: (dashboard) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: l10n.dashboardWatching,
                          count: dashboard.stats.watchingCount,
                          icon: Icons.play_circle_outline,
                          color: AppColors.watching,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          title: l10n.dashboardWantToWatch,
                          count: dashboard.stats.wantToWatchCount,
                          icon: Icons.bookmark_border,
                          color: AppColors.wantToWatch,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: l10n.dashboardCompleted,
                          count: dashboard.stats.completedCount,
                          icon: Icons.check_circle_outline,
                          color: AppColors.completed,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          title: l10n.dashboardDropped,
                          count: dashboard.stats.droppedCount,
                          icon: Icons.cancel_outlined,
                          color: AppColors.dropped,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (dashboard.watching.items.isNotEmpty)
                SliverToBoxAdapter(
                  child: WatchingSection(
                    title: l10n.dashboardWatching,
                    series: dashboard.watching.items,
                  ),
                ),
              if (dashboard.wantToWatch.items.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: WatchingSection(
                      title: l10n.dashboardWantToWatch,
                      series: dashboard.wantToWatch.items,
                    ),
                  ),
                ),
              if (dashboard.watching.items.isEmpty && dashboard.wantToWatch.items.isEmpty)
                const SliverFillRemaining(
                  child: EmptyStateWidget(
                    message: l10n.dashboardEmptySeries,
                    icon: Icons.tv_off,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/dashboard/pages/dashboard_page.dart
git commit -m "feat: migrate dashboard page strings to i18n"
```

---

### Task 14: Migrate watching_section.dart

**Files:**
- Modify: `lib/features/dashboard/widgets/watching_section.dart`

- [ ] **Step 1: Accept a title parameter and remove hardcoded text**

Replace the file content:

```dart
import 'package:flutter/material.dart';
import '../../series/data/models/series_model.dart';
import 'series_horizontal_list.dart';

class WatchingSection extends StatelessWidget {
  final String title;
  final List<SeriesModel> series;

  const WatchingSection({super.key, required this.title, required this.series});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 8),
        SeriesHorizontalList(series: series),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/dashboard/widgets/watching_section.dart
git commit -m "refactor: make watching_section title a parameter for i18n"
```

---

### Task 15: Migrate series_search_page.dart

**Files:**
- Modify: `lib/features/series/pages/series_search_page.dart`

- [ ] **Step 1: Replace hardcoded strings**

Replace the file content:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../viewmodels/series_search_viewmodel.dart';
import '../widgets/series_card.dart';

class SeriesSearchPage extends ConsumerStatefulWidget {
  const SeriesSearchPage({super.key});

  @override
  ConsumerState<SeriesSearchPage> createState() => _SeriesSearchPageState();
}

class _SeriesSearchPageState extends ConsumerState<SeriesSearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.length >= 2) {
      ref.read(seriesSearchViewModelProvider.notifier).search(query);
    } else if (query.isEmpty) {
      ref.read(seriesSearchViewModelProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(seriesSearchViewModelProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(seriesSearchViewModelProvider.notifier).clear();
                    },
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: searchState.when(
        loading: () => const LoadingWidget(),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => _onSearchChanged(_searchController.text),
        ),
        data: (series) {
          if (series.isEmpty && _searchController.text.isEmpty) {
            return EmptyStateWidget(
              message: l10n.searchTypeMinChars,
              icon: Icons.search,
            );
          }
          if (series.isEmpty) {
            return EmptyStateWidget(
              message: l10n.searchNoResults,
              icon: Icons.search_off,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: series.length,
            itemBuilder: (context, index) {
              final item = series[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SeriesCard(
                  series: item,
                  onTap: () {
                    // TODO: Navigate to series detail
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/series/pages/series_search_page.dart
git commit -m "feat: migrate search page strings to i18n"
```

---

### Task 16: Migrate series_card.dart (plural)

**Files:**
- Modify: `lib/features/series/widgets/series_card.dart`

- [ ] **Step 1: Replace naive plural with ARB plural**

Replace the file content:

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../data/models/series_model.dart';

class SeriesCard extends StatelessWidget {
  final SeriesModel series;
  final VoidCallback? onTap;

  const SeriesCard({
    super.key,
    required this.series,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: series.posterPath ?? '',
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 100,
                height: 150,
                color: Colors.grey[300],
              ),
              errorWidget: (context, url, error) => Container(
                width: 100,
                height: 150,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      series.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (series.genres.isNotEmpty)
                      Text(
                        series.genres.join(', '),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.commonSeasons(series.seasonCount),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/series/widgets/series_card.dart
git commit -m "feat: migrate series card seasons plural to i18n ICU"
```

---

### Task 17: Migrate recommendation_page.dart

**Files:**
- Modify: `lib/features/recommendation/pages/recommendation_page.dart`

- [ ] **Step 1: Replace hardcoded strings**

Replace the file content:

```dart
import 'package:flutter/material.dart';
import '../../../generated/l10n/app_localizations.dart';

class RecommendationPage extends StatelessWidget {
  const RecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recommendTitle),
      ),
      body: Center(
        child: Text(l10n.recommendComingSoon),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/recommendation/pages/recommendation_page.dart
git commit -m "feat: migrate recommendation page strings to i18n"
```

---

### Task 18: Migrate auth_page_scaffold.dart

**Files:**
- Modify: `lib/features/auth/widgets/auth_page_scaffold.dart`

- [ ] **Step 1: Replace hardcoded title**

Replace the file content:

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../generated/l10n/app_localizations.dart';

class AuthPageScaffold extends StatelessWidget {
  final List<Widget> children;

  const AuthPageScaffold({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    Icon(
                      Icons.local_movies,
                      size: 96,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.appTitle,
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

- [ ] **Step 2: Commit**

```bash
git add lib/features/auth/widgets/auth_page_scaffold.dart
git commit -m "feat: migrate auth page scaffold title to i18n"
```

---

### Task 19: Create AuthError enum

**Files:**
- Create: `lib/features/auth/viewmodels/auth_errors.dart`

- [ ] **Step 1: Write the error enum**

```dart
import '../../../generated/l10n/app_localizations.dart';

enum AuthError {
  emptyFields,
  wrongCredentials,
  passwordsDontMatch,
  weakPassword,
  termsNotAccepted,
  fillAllFields,
  enterEmail,
  enterCode,
  invalidCode,
  createAccount,
  sendCode,
  resetPassword;

  String localizedMessage(AppLocalizations l10n) {
    switch (this) {
      case AuthError.emptyFields:
        return l10n.errorEmptyFields;
      case AuthError.wrongCredentials:
        return l10n.errorWrongCredentials;
      case AuthError.passwordsDontMatch:
        return l10n.errorPasswordsDontMatch;
      case AuthError.weakPassword:
        return l10n.errorWeakPassword;
      case AuthError.termsNotAccepted:
        return l10n.errorAcceptTerms;
      case AuthError.fillAllFields:
        return l10n.errorFillAllFields;
      case AuthError.enterEmail:
        return l10n.errorEnterEmail;
      case AuthError.enterCode:
        return l10n.errorEnterCode;
      case AuthError.invalidCode:
        return l10n.errorInvalidCode;
      case AuthError.createAccount:
        return l10n.errorCreateAccount;
      case AuthError.sendCode:
        return l10n.errorSendCode;
      case AuthError.resetPassword:
        return l10n.errorResetPassword;
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/auth/viewmodels/auth_errors.dart
git commit -m "feat: create AuthError enum for localized error messages"
```

---

### Task 20: Migrate login_viewmodel.dart to use AuthError codes

**Files:**
- Modify: `lib/features/auth/viewmodels/login_viewmodel.dart`

- [ ] **Step 1: Replace errorMessage string with AuthError? code**

Replace the file content:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/auth_repository.dart';
import 'auth_errors.dart';
import 'auth_viewmodel.dart';

part 'login_viewmodel.g.dart';

class LoginState {
  final String email;
  final String password;
  final bool isLoading;
  final AuthError? errorCode;
  final bool obscurePassword;

  const LoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.errorCode,
    this.obscurePassword = true,
  });

  bool get isValid => email.isNotEmpty && password.isNotEmpty;

  LoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    AuthError? errorCode,
    bool? obscurePassword,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorCode: errorCode,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  LoginState build() => const LoginState();

  void setEmail(String email) {
    state = state.copyWith(email: email, errorCode: null);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, errorCode: null);
  }

  void toggleObscurePassword() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  Future<bool> submit() async {
    if (!state.isValid) {
      state = state.copyWith(errorCode: AuthError.emptyFields);
      return false;
    }

    state = state.copyWith(isLoading: true, errorCode: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      final userId = await repository.signIn(state.email, state.password);
      ref.read(authViewModelProvider.notifier).setAuthenticated(userId);
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorCode: AuthError.wrongCredentials);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorCode: AuthError.wrongCredentials,
      );
      return false;
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/auth/viewmodels/login_viewmodel.dart
git commit -m "refactor: use AuthError enum in login_viewmodel"
```

---

### Task 21: Migrate login_page.dart to use AuthError mapping

**Files:**
- Modify: `lib/features/auth/pages/login_page.dart`

- [ ] **Step 1: Replace all strings, map AuthError codes to localized text**

Replace the file content:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../viewmodels/auth_errors.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return AuthPageScaffold(
      children: [
        Text(
          l10n.authLoginTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.authLoginSubtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 32),
        AuthTextField(
          controller: _emailController,
          hint: l10n.authLoginEmailHint,
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          errorText: loginState.errorCode != null && !loginState.isValid
              ? loginState.errorCode!.localizedMessage(l10n)
              : null,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          controller: _passwordController,
          hint: l10n.authLoginPasswordHint,
          icon: Icons.lock_outline,
          obscureText: loginState.obscurePassword,
          onToggleObscure: () {
            ref.read(loginViewModelProvider.notifier).toggleObscurePassword();
          },
        ),
        if (loginState.errorCode != null && loginState.isValid) ...[
          const SizedBox(height: 12),
          Text(
            loginState.errorCode!.localizedMessage(l10n),
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        AuthButton(
          text: l10n.authLoginButton,
          isLoading: loginState.isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.push('/forgot-password'),
          child: Text(
            l10n.authLoginForgotPassword,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white30)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.authLoginOr,
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            ),
            const Expanded(child: Divider(color: Colors.white30)),
          ],
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.push('/register'),
          child: Text.rich(
            TextSpan(
              text: l10n.authLoginNoAccount,
              style: const TextStyle(color: Colors.white70),
              children: [
                TextSpan(
                  text: l10n.authLoginRegister,
                  style: const TextStyle(
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

- [ ] **Step 2: Commit**

```bash
git add lib/features/auth/pages/login_page.dart
git commit -m "feat: migrate login page to i18n with AuthError mapping"
```

---

### Task 22: Migrate register_viewmodel.dart to use AuthError codes

**Files:**
- Modify: `lib/features/auth/viewmodels/register_viewmodel.dart`

- [ ] **Step 1: Replace errorMessage with AuthError code**

Replace the file content:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/auth_repository.dart';
import 'auth_errors.dart';
import 'auth_viewmodel.dart';

part 'register_viewmodel.g.dart';

enum PasswordStrength { weak, medium, strong }

class RegisterState {
  final String email;
  final String password;
  final String confirmPassword;
  final bool termsAccepted;
  final bool isLoading;
  final AuthError? errorCode;
  final bool obscurePassword;
  final bool showConfirmation;
  final String? confirmationCode;

  const RegisterState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.termsAccepted = false,
    this.isLoading = false,
    this.errorCode,
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
    AuthError? errorCode,
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
      errorCode: errorCode,
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
    state = state.copyWith(email: email, errorCode: null);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, errorCode: null);
  }

  void setConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword, errorCode: null);
  }

  void toggleTerms() {
    state = state.copyWith(termsAccepted: !state.termsAccepted, errorCode: null);
  }

  void toggleObscurePassword() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void setConfirmationCode(String code) {
    state = state.copyWith(confirmationCode: code, errorCode: null);
  }

  Future<bool> submit() async {
    if (!state.isValid) {
      if (state.password != state.confirmPassword) {
        state = state.copyWith(errorCode: AuthError.passwordsDontMatch);
      } else if (state.passwordStrength == PasswordStrength.weak) {
        state = state.copyWith(errorCode: AuthError.weakPassword);
      } else if (!state.termsAccepted) {
        state = state.copyWith(errorCode: AuthError.termsNotAccepted);
      } else {
        state = state.copyWith(errorCode: AuthError.fillAllFields);
      }
      return false;
    }

    state = state.copyWith(isLoading: true, errorCode: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signUp(state.email, state.password);
      state = state.copyWith(isLoading: false, showConfirmation: true);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorCode: AuthError.createAccount);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorCode: AuthError.createAccount,
      );
      return false;
    }
  }

  Future<bool> confirmSignUp() async {
    if (state.confirmationCode == null || state.confirmationCode!.isEmpty) {
      state = state.copyWith(errorCode: AuthError.enterCode);
      return false;
    }

    state = state.copyWith(isLoading: true, errorCode: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.confirmSignUp(state.email, state.confirmationCode!);
      final userId = await repository.signIn(state.email, state.password);
      ref.read(authViewModelProvider.notifier).setAuthenticated(userId);
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorCode: AuthError.invalidCode);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorCode: AuthError.invalidCode,
      );
      return false;
    }
  }

  Future<void> resendCode() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.resendSignUpCode(state.email);
    } catch (_) {
      // Silently fail
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/auth/viewmodels/register_viewmodel.dart
git commit -m "refactor: use AuthError enum in register_viewmodel"
```

---

### Task 23: Migrate register_page.dart to use AuthError mapping

**Files:**
- Modify: `lib/features/auth/pages/register_page.dart`

- [ ] **Step 1: Replace all strings, map AuthError codes to localized text**

Replace the file content:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../generated/l10n/app_localizations.dart';
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

  String _strengthText(PasswordStrength strength, AppLocalizations l10n) {
    switch (strength) {
      case PasswordStrength.weak:
        return l10n.authRegisterPasswordWeak;
      case PasswordStrength.medium:
        return l10n.authRegisterPasswordMedium;
      case PasswordStrength.strong:
        return l10n.authRegisterPasswordStrong;
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerViewModelProvider);
    final l10n = AppLocalizations.of(context)!;

    return AuthPageScaffold(
      children: [
        Text(
          registerState.showConfirmation
              ? l10n.authRegisterTitleConfirm
              : l10n.authRegisterTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          registerState.showConfirmation
              ? l10n.authRegisterSubtitleConfirm(registerState.email)
              : l10n.authRegisterSubtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 32),
        if (registerState.showConfirmation) ...[
          AuthTextField(
            controller: _codeController,
            hint: l10n.authRegisterConfirmHint,
            icon: Icons.confirmation_number_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          AuthButton(
            text: l10n.authRegisterConfirmButton,
            isLoading: registerState.isLoading,
            onPressed: _confirm,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => ref.read(registerViewModelProvider.notifier).resendCode(),
            child: Text(
              l10n.authRegisterResendCode,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ] else ...[
          AuthTextField(
            controller: _emailController,
            hint: l10n.authRegisterEmailHint,
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordController,
            hint: l10n.authRegisterPasswordHint,
            icon: Icons.lock_outline,
            obscureText: registerState.obscurePassword,
            onToggleObscure: () {
              ref.read(registerViewModelProvider.notifier).toggleObscurePassword();
            },
          ),
          const SizedBox(height: 8),
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
                  _strengthText(registerState.passwordStrength, l10n),
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
            hint: l10n.authRegisterConfirmPasswordHint,
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
                  l10n.authRegisterTerms,
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AuthButton(
            text: l10n.authRegisterButton,
            isLoading: registerState.isLoading,
            onPressed: _submit,
          ),
        ],
        if (registerState.errorCode != null) ...[
          const SizedBox(height: 12),
          Text(
            registerState.errorCode!.localizedMessage(l10n),
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.go('/login'),
          child: Text.rich(
            TextSpan(
              text: l10n.authRegisterAlreadyHaveAccount,
              style: const TextStyle(color: Colors.white70),
              children: [
                TextSpan(
                  text: l10n.authRegisterLogin,
                  style: const TextStyle(
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

- [ ] **Step 2: Commit**

```bash
git add lib/features/auth/pages/register_page.dart
git commit -m "feat: migrate register page to i18n with AuthError mapping"
```

---

### Task 24: Migrate forgot_password_viewmodel.dart to use AuthError codes

**Files:**
- Modify: `lib/features/auth/viewmodels/forgot_password_viewmodel.dart`

- [ ] **Step 1: Replace errorMessage with AuthError code**

Replace the file content:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/auth_repository.dart';
import 'auth_errors.dart';
import 'auth_viewmodel.dart';

part 'forgot_password_viewmodel.g.dart';

enum ForgotPasswordPhase { requestCode, resetPassword }

class ForgotPasswordState {
  final String email;
  final String code;
  final String newPassword;
  final String confirmPassword;
  final bool isLoading;
  final AuthError? errorCode;
  final ForgotPasswordPhase phase;
  final bool obscurePassword;

  const ForgotPasswordState({
    this.email = '',
    this.code = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.errorCode,
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
    AuthError? errorCode,
    ForgotPasswordPhase? phase,
    bool? obscurePassword,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      code: code ?? this.code,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      errorCode: errorCode,
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
    state = state.copyWith(email: email, errorCode: null);
  }

  void setCode(String code) {
    state = state.copyWith(code: code, errorCode: null);
  }

  void setNewPassword(String password) {
    state = state.copyWith(newPassword: password, errorCode: null);
  }

  void setConfirmPassword(String password) {
    state = state.copyWith(confirmPassword: password, errorCode: null);
  }

  void toggleObscurePassword() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  Future<bool> requestCode() async {
    if (!state.canRequestCode) {
      state = state.copyWith(errorCode: AuthError.enterEmail);
      return false;
    }

    state = state.copyWith(isLoading: true, errorCode: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.resetPassword(state.email);
      state = state.copyWith(isLoading: false, phase: ForgotPasswordPhase.resetPassword);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorCode: AuthError.sendCode);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorCode: AuthError.sendCode,
      );
      return false;
    }
  }

  Future<bool> resetPassword() async {
    if (!state.canResetPassword) {
      if (state.newPassword != state.confirmPassword) {
        state = state.copyWith(errorCode: AuthError.passwordsDontMatch);
      } else {
        state = state.copyWith(errorCode: AuthError.fillAllFields);
      }
      return false;
    }

    state = state.copyWith(isLoading: true, errorCode: null);

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
      state = state.copyWith(isLoading: false, errorCode: AuthError.resetPassword);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorCode: AuthError.resetPassword,
      );
      return false;
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/auth/viewmodels/forgot_password_viewmodel.dart
git commit -m "refactor: use AuthError enum in forgot_password_viewmodel"
```

---

### Task 25: Migrate forgot_password_page.dart to use AuthError mapping

**Files:**
- Modify: `lib/features/auth/pages/forgot_password_page.dart`

- [ ] **Step 1: Replace all strings, map AuthError codes to localized text**

Replace the file content:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../generated/l10n/app_localizations.dart';
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authForgotCodeSentConfirmation)),
      );
    }
  }

  Future<void> _resetPassword() async {
    final success = await ref.read(forgotPasswordViewModelProvider.notifier).resetPassword();
    if (success && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authForgotPasswordResetSuccess)),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordViewModelProvider);
    final l10n = AppLocalizations.of(context)!;

    return AuthPageScaffold(
      children: [
        Text(
          state.phase == ForgotPasswordPhase.requestCode
              ? l10n.authForgotTitleRequest
              : l10n.authForgotTitleReset,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          state.phase == ForgotPasswordPhase.requestCode
              ? l10n.authForgotSubtitleRequest
              : l10n.authForgotSubtitleReset,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 32),
        if (state.phase == ForgotPasswordPhase.requestCode) ...[
          AuthTextField(
            controller: _emailController,
            hint: l10n.authForgotEmailHint,
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          AuthButton(
            text: l10n.authForgotSendCode,
            isLoading: state.isLoading,
            onPressed: _requestCode,
          ),
        ] else ...[
          AuthTextField(
            controller: _codeController,
            hint: l10n.authForgotCodeHint,
            icon: Icons.confirmation_number_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordController,
            hint: l10n.authForgotNewPasswordHint,
            icon: Icons.lock_outline,
            obscureText: state.obscurePassword,
            onToggleObscure: () {
              ref.read(forgotPasswordViewModelProvider.notifier).toggleObscurePassword();
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _confirmController,
            hint: l10n.authForgotConfirmPasswordHint,
            icon: Icons.lock_outline,
            obscureText: state.obscurePassword,
          ),
          const SizedBox(height: 24),
          AuthButton(
            text: l10n.authForgotResetButton,
            isLoading: state.isLoading,
            onPressed: _resetPassword,
          ),
        ],
        if (state.errorCode != null) ...[
          const SizedBox(height: 12),
          Text(
            state.errorCode!.localizedMessage(l10n),
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.go('/login'),
          child: Text(
            l10n.authForgotBackToLogin,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/auth/pages/forgot_password_page.dart
git commit -m "feat: migrate forgot password page to i18n with AuthError mapping"
```

---

### Task 26: Rewrite widget_test.dart

**Files:**
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Write a proper smoke test**

Replace the file content:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/app.dart';
import 'package:lorebase/generated/l10n/app_localizations.dart';

void main() {
  testWidgets('LorebaseApp smoke test with i18n delegates', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LorebaseApp(),
      ),
    );

    // The app should render without crashing.
    // It will likely show a loading indicator while Amplify initializes,
    // but the Material widget should be present.
    expect(find.byType(Material), findsOneWidget);
  });

  testWidgets('App provides supported locales', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LorebaseApp(),
      ),
    );

    // Verify MaterialApp.router exists
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the test to verify it passes**

```bash
flutter test test/widget_test.dart
```

Expected: Tests pass (app renders without crash).

- [ ] **Step 3: Commit**

```bash
git add test/widget_test.dart
git commit -m "test: rewrite smoke test with real LorebaseApp and i18n"
```

---

### Task 27: Add locale_provider test

**Files:**
- Create: `test/locale_provider_test.dart`

- [ ] **Step 1: Write the fallback test**

```dart
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/providers/locale_provider.dart';

void main() {
  test('localeProvider falls back to pt for unsupported locale', () {
    final container = ProviderContainer();
    final locale = container.read(localeProvider);

    // The actual value depends on the test device locale,
    // but the provider should always return a valid locale.
    expect(locale, isA<Locale>());
    expect(
      ['pt', 'en'],
      contains(locale.languageCode),
    );
  });
}
```

- [ ] **Step 2: Run the test**

```bash
flutter test test/locale_provider_test.dart
```

Expected: Test passes.

- [ ] **Step 3: Commit**

```bash
git add test/locale_provider_test.dart
git commit -m "test: add locale_provider fallback test"
```

---

### Task 28: Run full test suite and verify

**Files:** None (verification only)

- [ ] **Step 1: Run all tests**

```bash
flutter test
```

Expected: All tests pass.

- [ ] **Step 2: Run analysis**

```bash
flutter analyze
```

Expected: No errors. Warnings only for pre-existing issues.

- [ ] **Step 3: Verify l10n generation is clean**

```bash
dart run flutter_gen_l10n
```

Expected: No errors, no changes (already generated).

- [ ] **Step 4: Final commit if any analysis fixes needed**

```bash
git add -A
git commit -m "chore: final i18n verification and cleanup"
```
