# Frontend i18n Design

Date: 2026-05-09

Status: Draft

Supersedes: [2026-04-26-i18n-localization-design.md](./2026-04-26-i18n-localization-design.md)

## Scope

Adicionar suporte a internacionalização no app Flutter para 3 idiomas:
Português (pt-BR), Inglês (en-US) e Espanhol (es).

A implementação cobre:

- **UI strings**: todos os textos visíveis ao usuário externalizados para arquivos
  de tradução
- **API layer**: envio do header `Accept-Language` em toda requisição Dio
- **Locale detection**: detecção do locale do sistema + override manual pelo
  usuário, persistido em `FlutterSecureStorage`
- **TrackingStatus**: labels do enum externalizadas para i18n
- **Language switcher**: seletor de idioma no AppBar

Fora de escopo:

- Dados inseridos pelo usuário (reviews, ratings)
- Formatação de data/número (não necessário no momento)
- Suporte a RTL (não necessário no momento)
- Página de settings dedicada (switcher no AppBar é suficiente)

## Toolchain

Pacote **slang** (v4) com integração Riverpod:

- `slang` — core, geração de código type-safe
- `slang_flutter` — integração Flutter (BuildContext extension + Riverpod)
- `slang_build_runner` — codegen via build_runner

Justificativa: projeto já usa build_runner + Riverpod codegen. Slang se
encaixa no mesmo ecossistema, oferece type-safety (erros de chave em
compilação), usa JSON simples como fonte, e gera providers Riverpod
automaticamente.

## Dependencies

```yaml
dependencies:
  slang: ^4.0.0
  slang_flutter: ^4.0.0
  flutter_localizations:
    sdk: flutter

dev_dependencies:
  slang_build_runner: ^4.0.0
```

`flutter_localizations` é necessária para localizar widgets do Material
(DatePicker, etc.) mesmo que o slang cuide das strings customizadas.

## Translation Files

Estrutura em `lib/l10n/`:

```
lib/l10n/
  pt_BR.json    # Português (default)
  en_US.json    # Inglês
  es.json       # Espanhol
```

Formato JSON flat com chaves em `snake_case` prefixadas por feature:

```json
{
  "nav_home": "Home",
  "nav_search": "Search",
  "nav_my_lists": "My Lists",
  "nav_recommend": "Recommend",
  "login_welcome": "Welcome back",
  "login_subtitle": "Sign in to continue your lists",
  "tracking_want_to_watch": "Want to Watch",
  "tracking_watching": "Watching",
  "tracking_completed": "Completed",
  "tracking_dropped": "Dropped",
  "tracking_empty": "No {status} series yet",
  "series_detail_season_count": "{count} {count, plural, one{season} other{seasons}}",
  "search_hint": "Search series...",
  "search_empty": "Type at least 2 characters to search",
  "search_no_results": "No series found",
  "series_detail_add_to_list": "Add to List",
  "series_detail_manage_tracking": "Manage Tracking",
  "series_detail_overview": "Overview",
  "series_detail_no_description": "No description available.",
  "series_detail_show_more": "Show more",
  "series_detail_show_less": "Show less",
  "series_detail_first_air_date": "First Air Date",
  "series_detail_seasons": "Seasons",
  "series_detail_networks": "Networks",
  "series_detail_status": "Status",
  "series_detail_rating": "Rating",
  "series_detail_review": "Review (optional)",
  "series_detail_save_changes": "Save Changes",
  "series_detail_remove_from_list": "Remove from List",
  "series_detail_remove_confirm": "Remove \"{title}\" from your list?",
  "series_detail_cancel": "Cancel",
  "series_detail_remove": "Remove",
  "dashboard_loading": "Loading your dashboard...",
  "dashboard_empty": "No series tracked yet.\\nSearch and add your first series!",
  "auth_create_account": "Create account",
  "auth_welcome_back": "Welcome back",
  "auth_confirm_email": "Confirm your email",
  "auth_code_sent_to": "Enter code sent to {email}",
  "auth_confirmation_code": "Confirmation code",
  "auth_confirm_and_login": "Confirm & Sign in",
  "auth_resend_code": "Resend code",
  "auth_password_weak": "Weak",
  "auth_password_medium": "Medium",
  "auth_password_strong": "Strong",
  "auth_accept_terms": "I accept the Terms of Use",
  "auth_already_have_account": "Already have an account?",
  "auth_sign_in": "Sign in",
  "auth_recover_password": "Recover password",
  "auth_new_password": "New password",
  "auth_email_hint": "Email",
  "auth_password_hint": "Password",
  "auth_confirm_password_hint": "Confirm password",
  "auth_send_code": "Send code",
  "auth_verification_code_hint": "Verification code",
  "auth_new_password_hint": "New password",
  "auth_confirm_new_password_hint": "Confirm new password",
  "auth_reset_password": "Reset password",
  "auth_code_sent_success": "Code sent to your email",
  "auth_password_reset_success": "Password reset successfully",
  "auth_back_to_login": "Back to login",
  "auth_or": "or",
  "auth_sign_up": "Sign up",
  "locale_pt_BR": "Português",
  "locale_en_US": "English",
  "locale_es": "Español",
  "recommend_title": "Recommendation",
  "recommend_coming_soon": "Recommendation feature coming soon!",
  "error_network": "Network error. Check your connection.",
  "error_server": "Server error. Please try again later.",
  "error_session_expired": "Session expired. Please log in again.",
  "error_resource_not_found": "Resource not found."
}
```

Suporte a pluralização via ICU syntax (nativa do slang).

## Locale Detection & Provider

Fluxo de resolução:

```
1. App inicia
2. Lê locale salvo em FlutterSecureStorage (chave: "locale")
3. Se existe → usa o salvo
4. Se não existe → usa Platform.localeName com fallback para pt-BR
5. Provider Riverpod expõe o locale atual
6. Quando usuário troca → salva no storage + atualiza provider
```

Provider (fora da codegen do slang):

```dart
// lib/core/i18n/locale_provider.dart
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _loadSavedLocale();
    return _localeFromPlatform();
  }

  Future<void> setLocale(Locale locale) async {
    // Persistir e atualizar estado
  }
}
```

### Configuração do slang

`lib/l10n/` com `slang.yaml` (ou config inline no pubspec.yaml):

```yaml
# slang.yaml
base_locale: pt_BR
fallback_strategy: base_locale
```

O slang gera:
- `lib/l10n/translations.g.dart` — classe `Translations` type-safe
- `lib/l10n/translations.g.dart` — provider Riverpod `translationProvider`
- Extension `BuildContext.t`

## MaterialApp.router Wiring

```dart
// lib/app.dart
MaterialApp.router(
  locale: ref.watch(localeProvider),
  supportedLocales: const [
    Locale('pt', 'BR'),
    Locale('en', 'US'),
    Locale('es'),
  ],
  localizationsDelegates: [
    AppLocalizations.delegate,         // flutter_localizations (Material)
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  // ...
)
```

Nota: o slang fornece o delegate automaticamente via `Translations.ensureInitialized()`.

## API Layer — Accept-Language Interceptor

Novo interceptor Dio que injeta o header `Accept-Language` em toda request:

```dart
// lib/core/network/locale_interceptor.dart
class LocaleInterceptor extends Interceptor {
  final Ref _ref;

  LocaleInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final locale = _ref.read(localeProvider);
    options.headers['Accept-Language'] = locale.toLanguageTag();
    handler.next(options);
  }
}
```

`DioClient.create()` passa a receber `Ref` para que tanto `LocaleInterceptor`
quanto `ErrorInterceptor` tenham acesso ao i18n:

```dart
static Dio create(Ref ref) {
  final dio = Dio(...);
  dio.interceptors.addAll([
    AuthInterceptor(),
    LocaleInterceptor(ref),
    ErrorInterceptor(ref),    // recebe ref para acessar traduções
    LogInterceptor(...),
  ]);
  return dio;
}
```

`ErrorInterceptor` usa `ref.read(translationProvider)` para obter as
mensagens de erro localizadas:

```dart
class ErrorInterceptor extends Interceptor {
  final Ref _ref;

  ErrorInterceptor(this._ref);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final t = _ref.read(translationProvider);
    switch (err.type) {
      case DioExceptionType.badResponse:
        if (statusCode == 401) {
          err = err.copyWith(error: AuthException(message: t.error_session_expired));
        }
        // ...
    }
  }
}
```

`dioProvider` em `core_providers.dart` passa `ref`:

```dart
final dioProvider = Provider<Dio>((ref) {
  return DioClient.create(ref);
});
```

## Uso nas Pages

Substituir strings hardcoded por `context.t.chave` ou `ref.watch(translationProvider).chave`:

```dart
// Antes
label: 'Search',

// Depois (em ConsumerWidget)
final t = ref.watch(translationProvider);
label: t.nav_search,
```

Ou em StatelessWidget sem Ref:

```dart
label: context.t.nav_search,
```

## TrackingStatus Localization

O enum ganha um campo `i18nKey`:

```dart
enum TrackingStatus {
  wantToWatch('WANT_TO_WATCH', 'tracking_want_to_watch'),
  watching('WATCHING', 'tracking_watching'),
  completed('COMPLETED', 'tracking_completed'),
  dropped('DROPPED', 'tracking_dropped');

  final String value;
  final String i18nKey;

  const TrackingStatus(this.value, this.i18nKey);

  String label(Translations t) => t.$i18nKey;  // acesso type-safe via slang
}
```

Onde se usa `status.label`, passa a usar `status.label(t)`:

```dart
// tracking_list_page.dart
Tab(text: s.label(t)),

// series_detail_page.dart
title: Text(status.label(t)),
```

## Language Switcher

Ícone de globo no AppBar ao lado do logout. Ao clicar, abre bottom sheet
com as 3 opções de idioma:

```dart
IconButton(
  icon: const Icon(Icons.language),
  onPressed: () => _showLanguageSheet(context, ref),
),
```

Bottom sheet:
```dart
void _showLanguageSheet(BuildContext context, WidgetRef ref) {
  final t = ref.watch(translationProvider);
  showModalBottomSheet(
    context: context,
    builder: (ctx) => Column(
      children: [
        ListTile(
          title: Text(t.locale_pt_BR),
          trailing: locale == const Locale('pt', 'BR') ? const Icon(Icons.check) : null,
          onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('pt', 'BR')),
        ),
        ListTile(
          title: Text(t.locale_en_US),
          trailing: locale == const Locale('en', 'US') ? const Icon(Icons.check) : null,
          onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en', 'US')),
        ),
        ListTile(
          title: Text(t.locale_es),
          trailing: locale == const Locale('es') ? const Icon(Icons.check) : null,
          onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('es')),
        ),
      ],
    ),
  );
}
```

## Places that need i18n (all hardcoded strings)

### core/widgets
- `scaffold_with_nav_bar.dart` — nav labels (5), AppBar title, logout tooltip
- `empty_state_widget.dart` — generic messages
- `error_widget.dart` — retry label
- `loading_widget.dart` — loading message

### features/auth/pages
- `login_page.dart` — welcome, subtitle, hints, button, links (15+ strings)
- `register_page.dart` — title, subtitle, hints, buttons, password strength, terms (20+ strings)
- `forgot_password_page.dart` — title, subtitle, hints, buttons, snackbars (15+ strings)

### features/dashboard/pages
- `dashboard_page.dart` — loading, empty state, stats labels (10+ strings)

### features/series/pages
- `series_search_page.dart` — search hint, empty states (3 strings)
- `series_detail_page.dart` — overview, buttons, info labels, confirm dialogs (20+ strings)

### features/tracking/pages
- `tracking_list_page.dart` — AppBar title, empty states, tab labels (via TrackingStatus)

### features/recommendation/pages
- `recommendation_page.dart` — title, coming soon text (2 strings)

### core/network
- `error_interceptor.dart` — error messages (4 strings)

## Arquivos a criar

| Arquivo | Propósito |
|---------|-----------|
| `lib/l10n/pt_BR.json` | Traduções PT-BR |
| `lib/l10n/en_US.json` | Traduções EN-US |
| `lib/l10n/es.json` | Traduções ES |
| `lib/core/i18n/locale_provider.dart` | Provider Riverpod do locale |
| `lib/core/network/locale_interceptor.dart` | Interceptor Dio do Accept-Language |
| `slang.yaml` | Configuração do slang |

## Arquivos a modificar

| Arquivo | Mudança |
|---------|---------|
| `pubspec.yaml` | Adicionar slang, slang_flutter, flutter_localizations; slang_build_runner dev |
| `lib/app.dart` | Adicionar locale, supportedLocales, localizationsDelegates |
| `lib/core/providers/core_providers.dart` | Passar ref para DioClient.create() |
| `lib/core/network/dio_client.dart` | Aceitar Ref, adicionar LocaleInterceptor |
| `lib/core/widgets/scaffold_with_nav_bar.dart` | Usar context.t |
| `lib/core/widgets/empty_state_widget.dart` | Aceitar string externa (já recebe message como param) |
| `lib/core/widgets/error_widget.dart` | Usar context.t para retry |
| `lib/core/widgets/loading_widget.dart` | Aceitar string externa (já recebe message como param) |
| `lib/core/network/error_interceptor.dart` | Receber Ref, usar translationProvider para mensagens |
| `lib/features/tracking/data/tracking_status.dart` | Adicionar i18nKey, método label(t) |
| `lib/features/tracking/pages/tracking_list_page.dart` | Usar status.label(t) |
| `lib/features/auth/pages/login_page.dart` | Usar context.t |
| `lib/features/auth/pages/register_page.dart` | Usar context.t |
| `lib/features/auth/pages/forgot_password_page.dart` | Usar context.t |
| `lib/features/dashboard/pages/dashboard_page.dart` | Usar context.t |
| `lib/features/series/pages/series_search_page.dart` | Usar context.t |
| `lib/features/series/pages/series_detail_page.dart` | Usar context.t |
| `lib/features/recommendation/pages/recommendation_page.dart` | Usar context.t |

## Implementation Order

**Phase 1 — Infrastructure:**
1. Adicionar dependências no pubspec.yaml
2. Criar `slang.yaml`
3. Criar arquivos JSON de tradução (pt_BR, en_US, es)
4. Criar `localeProvider`
5. Criar `LocaleInterceptor`
6. Atualizar `DioClient.create()` e `dioProvider`
7. Rodar build_runner
8. Wiring no `app.dart`

**Phase 2 — String migration (feature por feature):**
9. `core/widgets` — scaffold_with_nav_bar, loading, error
10. `tracking` — TrackingStatus enum, tracking_list_page
11. `dashboard` — dashboard_page
12. `series` — series_search_page, series_detail_page
13. `auth` — login_page, register_page, forgot_password_page
14. `recommendation` — recommendation_page

**Phase 3 — Language Switcher:**
15. Adicionar ícone de globo no AppBar + bottom sheet
16. Persistência da escolha do usuário

**Phase 4 — Cleanup:**
17. Rodar `dart analyze --fatal-infos` e corrigir warnings
18. Atualizar testes existentes que dependem de strings hardcoded

## Testing

- Testar que localeProvider retorna locale do sistema quando não há preferência salva
- Testar que setLocale persiste e atualiza o estado
- Testar que LocaleInterceptor adiciona Accept-Language header
- Atualizar widget tests que verificam textos específicos para usar os novos
  formatos (ex: verificar que `context.t.nav_home` retorna o valor esperado)
