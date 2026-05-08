# AGENTS.md

## Stack

Flutter 3.27 (mise-managed), Dart >=3.3.0, Riverpod + codegen, GoRouter, Dio, Amplify + Cognito, Freezed, flutter_secure_storage, flutter_dotenv, Material 3, cached_network_image, shimmer.

## Commands

```bash
flutter pub get                          # install deps (run before build_runner)
dart run build_runner build --delete-conflicting-outputs   # codegen (one-shot)
dart run build_runner watch --delete-conflicting-outputs   # codegen (watch)
flutter test                             # unit + widget tests
dart analyze --fatal-infos               # lint (make analyze handles exit code 2 = warnings-only)
make test-coverage                       # flutter test --coverage --branch-coverage; gates at 100% line + branch
make check                               # analyze + coverage gate
flutter run                              # mobile
flutter run -d chrome                    # web (url_strategy setPathUrlStrategy enables clean paths)
```

## Architecture

- `lib/main.dart` — entrypoint: dotenv.load → Amplify configure → ProviderScope → LorebaseApp
- `lib/app.dart` — `MaterialApp.router` with auth-aware builder (shows spinner while AuthState is `unknown`)
- `lib/router.dart` — `Provider<GoRouter>` with `authRedirect()` guarding routes via `@visibleForTesting`
- Auth routes (`/login`, `/register`, `/forgot-password`) and authenticated routes (`/dashboard`, `/search`, `/series/:tmdbId`, `/tracking`, `/recommend`) under `ShellRoute` → `ScaffoldWithNavBar`

## Conventions

- **Never edit** `*.g.dart` or `*.freezed.dart` — auto-generated.
- Models: `@freezed` with `part '...freezed.dart'` and `part '...g.dart'`.
- ViewModels: `@riverpod class Foo extends _$Foo { ... }` with `part '...g.dart'`. Extend `_$Foo`.
- Plain providers: `final fooProvider = Provider<Foo>((ref) => ...);`
- Auth state (`AuthState`) is a plain Dart class (not Freezed) with named constructors and `copyWith`.
- `authRepositoryProvider` is defined inline in `lib/features/auth/viewmodels/auth_viewmodel.dart`.
- Repos: abstract interface + `*Impl` class receiving `Dio` via Riverpod.
- Navigation: use `context.go()` (not `push()`) except for sub-flows.
- `// coverage:ignore-file` at top of files meant to be excluded from coverage (app.dart, router.dart).
- Style: single quotes, const constructors, final locals (linter-enforced), `avoid_print: true`.

## Coverage quality gate

`scripts/check_coverage.dart` excludes from measurement:
- `*.g.dart`, `*.freezed.dart` (auto-generated)
- `/test/` files
- `api_constants.dart`, `core_providers.dart`, `app_theme.dart`, `dio_client.dart`, `auth_repository.dart`, `auth_interceptor.dart`

## Testing patterns

- Override providers via `ProviderScope(overrides: [...])` with inline fake view model classes extending the real VM.
- `authRedirect` is `@visibleForTesting` — test it directly with `AuthState` instances.
- Mockito (`mockito: ^5.4.0`) available for Dio/etc mocking.

## Known quirks

- `amplifyconfiguration.dart` (with Cognito pool ID / client ID) IS committed — it's not gitignored.
- `.env` is gitignored; `.env.example` only has `API_BASE_URL`.
- Web: `setPathUrlStrategy()` in main.dart enables clean URLs without `#`.
- No i18n/localization implementation yet (planned but not built).
