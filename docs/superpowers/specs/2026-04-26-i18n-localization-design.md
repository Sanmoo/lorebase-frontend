# i18n / Localization Support

**Date:** 2026-04-26
**Status:** Draft

## Overview

Add internationalization (i18n) support to lorebase-frontend using Flutter's official toolchain, enabling Portuguese (default) and English (alternative).

## Background

The app currently has mixed-language strings: auth pages (login, register, forgot-password) and their viewmodels are in Brazilian Portuguese, while dashboard, tracking, search, recommendation, shared widgets, failures, and error interceptor are in English. No i18n infrastructure exists — no ARB files, no `flutter_localizations`, no `intl`, no `l10n.yaml`.

## Goals

- Portuguese as the default language with device-locale detection
- English as a secondary supported language
- All user-facing strings externalized to ARB files
- ViewModel error messages refactored from hardcoded strings to error codes (enums), mapped in the UI layer via `AppLocalizations`
- Zero changes to business logic, data layer, or API contracts
- Locale resolution via device locale with automatic fallback to Portuguese

## Non-Goals

- Language switcher UI / Settings page (deferred, but architecture makes it trivial)
- Date/number formatting (not needed yet)
- RTL support (not needed yet, but `GlobalMaterialLocalizations` handles it)
- Locale-aware routing / URL prefixes
- Third-party i18n packages

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  MaterialApp.router                                     │
│  ├── supportedLocales: [pt, en]                         │
│  ├── localizationsDelegates: [...]AppLocalizations...   │
│  └── locale: ref.watch(localeProvider)                  │
│                                                         │
│  ┌──────────────────┐    ┌─────────────────────────┐    │
│  │ localeProvider    │    │ AppLocalizations        │    │
│  │ (StateProvider)   │───▶│ (generated from ARB)   │    │
│  │ reads device LC   │    │ app_pt.arb + app_en.arb│    │
│  └──────────────────┘    └─────────────────────────┘    │
│                                                         │
│  ┌─────────────────────────────────────────┐             │
│  │  ViewModels return error codes/enums    │             │
│  │  → UI maps via AppLocalizations         │             │
│  └─────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────┘
```

## Files to Create

| File | Purpose |
|------|---------|
| `l10n.yaml` | Flutter l10n configuration |
| `lib/l10n/app_pt.arb` | Portuguese translation source |
| `lib/l10n/app_en.arb` | English translation source |
| `lib/core/providers/locale_provider.dart` | Riverpod `StateProvider<Locale>` |

## Files to Modify

| File | Changes |
|------|---------|
| `pubspec.yaml` | Add `flutter_localizations` SDK dep, add `intl`, enable `generate: true` |
| `lib/app.dart` | Add `supportedLocales`, `localizationsDelegates`, consume `localeProvider` |
| `analysis_options.yaml` | Exclude `lib/generated/` |
| `lib/features/tracking/data/tracking_status.dart` | Replace raw string labels with enum values |
| ~13 widget/page files | Replace hardcoded `Text('str')` with `AppLocalizations.of(context)!.key` |
| `lib/features/auth/viewmodels/*.dart` (4 files) | Return `AuthError` codes instead of hardcoded strings |
| `lib/features/auth/pages/*.dart` (3 files) | Map `AuthError` codes to `AppLocalizations` strings |
| `lib/core/errors/failures.dart` | Use localized string delegates for messages |
| `lib/core/network/error_interceptor.dart` | Use localized string delegates for messages |

## Locale Resolution

```dart
final localeProvider = StateProvider<Locale>((ref) {
  final deviceLocale = PlatformDispatcher.instance.locale;
  const supported = [Locale('pt'), Locale('en')];
  return supported.any((l) => l.languageCode == deviceLocale.languageCode)
    ? Locale(deviceLocale.languageCode)
    : const Locale('pt');
});
```

`app.dart` wires it to `MaterialApp.router`:
```dart
locale: ref.watch(localeProvider),
supportedLocales: AppLocalizations.supportedLocales,
localizationsDelegates: AppLocalizations.localizationsDelegates,
```

## ARB Structure

Files: `lib/l10n/app_pt.arb`, `lib/l10n/app_en.arb`

Keys follow `snake_case` convention with feature prefix:
- `auth_login_title`, `auth_login_email_hint`, `auth_login_empty_fields`
- `register_password_weak`, `register_password_strong`
- `dashboard_watching_label`, `dashboard_empty_series`
- `tracking_status_want_to_watch`, `tracking_status_watching`
- `nav_home`, `nav_search`, `nav_my_lists`, `nav_recommend`
- `error_network`, `error_session_expired`, `error_server`
- `common_retry`, `common_seasons` (plural handling)

Use ICU plural syntax for the `seasonCount` case:
```json
"common_seasons": "{count} {count, plural, one{season} other{seasons}}",
"common_seasons_from_pt": "{count} {count, plural, one{temporada} other{temporadas}}"
```

## ViewModel Error Refactoring

Current pattern:
```dart
// login_viewmodel.dart
throw Exception('E-mail ou senha incorretos');
```

New pattern:
```dart
// auth_errors.dart
enum AuthError {
  emptyFields,
  wrongCredentials,
  passwordsDontMatch,
  weakPassword,
  termsNotAccepted,
  // ...
}
```

UI layer:
```dart
// login_page.dart
final l10n = AppLocalizations.of(context)!;
final message = switch (error) {
  AuthError.emptyFields => l10n.auth_login_empty_fields,
  AuthError.wrongCredentials => l10n.auth_login_wrong_credentials,
  // ...
};
showSnackBar(context, message);
```

## Testing

- Rewrite `test/widget_test.dart` as a proper smoke test wrapping `LorebaseApp` with `ProviderScope` and locale delegates
- Add provider test: `localeProvider` should fallback to `pt` for an unsupported locale (e.g., `fr`)

## Implementation Order

**Phase 1 — Infrastructure:**
1. `pubspec.yaml` — add `flutter_localizations`, `intl`, `generate: true`
2. Create `l10n.yaml`
3. Create ARB files with all keys (PT first, EN mirror)
4. Create `localeProvider`
5. Run `flutter gen-l10n`
6. Wire `app.dart`

**Phase 2 — String migration (feature by feature):**
7. `core/widgets` — `scaffold_with_nav_bar.dart`, `error_widget.dart`
8. `tracking` — `tracking_status.dart`, `tracking_list_page.dart`, `status_bottom_sheet.dart`
9. `dashboard` — `dashboard_page.dart`, `watching_section.dart`
10. `series` — `series_search_page.dart`, `series_card.dart`
11. `recommendation` — `recommendation_page.dart`
12. `auth` — Create `AuthError` enum, refactor 4 viewmodels + 3 pages

**Phase 3 — Cleanup:**
13. `failures.dart`, `error_interceptor.dart` — localize remaining net/error strings
14. Tests — rewrite smoke test, add locale fallback test
15. `analysis_options.yaml` — add l10n exclusions
