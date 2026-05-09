# AGENTS.md

## Stack

Flutter 3.27 (mise-managed), Dart >=3.3.0, Riverpod + codegen, GoRouter, Dio, Amplify + Cognito, Freezed, flutter_secure_storage, flutter_dotenv, Material 3, cached_network_image, shimmer.

## Commands

```bash
flutter pub get                          # install deps (run before build_runner)
dart run build_runner build --delete-conflicting-outputs   # codegen (one-shot)
dart run build_runner watch --delete-conflicting-outputs   # codegen (watch)
flutter test                             # unit + widget tests
dart analyze --fatal-infos               # lint
make analyze                             # dart analyze wrapper that treats exit code 2 (warnings-only) as pass
make test-coverage                       # runs `flutter test --coverage --branch-coverage` then gates at 100% line + branch
make check                               # analyze + coverage gate
flutter run                              # mobile
flutter run -d chrome                    # web
python scripts/get_cognito_token.py <email>  # get Cognito JWT tokens for API testing
```

## Architecture

- `lib/main.dart` — entrypoint: `setPathUrlStrategy()` → `dotenv.load()` → Amplify configure → `ProviderScope` → `LorebaseApp`
- `lib/app.dart` — `ConsumerWidget`: `MaterialApp.router` with `ThemeMode.system`, auth-aware builder (spinner while `AuthState.unknown`)
- `lib/router.dart` — plain `Provider<GoRouter>` (not riverpod codegen). `authRedirect()` is `@visibleForTesting`, checks `authState` against route path to redirect.
- Auth routes (`/login`, `/register`, `/forgot-password`) are outside `ShellRoute`. Protected routes (`/dashboard`, `/search`, `/series/:tmdbId`, `/tracking`, `/recommend`) are inside `ShellRoute` → `ScaffoldWithNavBar` (BottomNavigationBar with 4 tabs: Home, Search, My Lists, Recommend).
- `Navigation: use `context.go()` (not `push()`) — enforced by bottom nav tab switching.

## Feature structure

Each feature under `lib/features/<name>/` follows: `data/`, `pages/`, `viewmodels/`, `widgets/`.

## Conventions

- **Never edit** `*.g.dart` or `*.freezed.dart` — auto-generated.
- Models: `@freezed` with `part '...freezed.dart'` and `part '...g.dart'`.
- ViewModels: `@riverpod class Foo extends _$Foo { ... }` with `part '...g.dart'`. Extend `_$Foo`.
- Plain providers: `final fooProvider = Provider<Foo>((ref) => ...);` (e.g. `routerProvider`, `dioProvider`, `secureStorageProvider`).
- Auth state (`AuthState`) is a plain Dart class (not Freezed) with named constructors and `copyWith`.
- `authRepositoryProvider` is defined inline in `lib/features/auth/viewmodels/auth_viewmodel.dart`.
- Repos: abstract interface + `*Impl` class receiving `Dio` via Riverpod.
- `// coverage:ignore-file` at top of files meant to be excluded from coverage (`app.dart`, `router.dart`).
- Style: single quotes, const constructors, final locals (linter-enforced), `avoid_print: true`.
- Dio interceptors: `AuthInterceptor` (attaches Cognito Bearer token), `ErrorInterceptor` (maps 401→AuthException, 5xx→ServerException, timeout→NetworkException, 404→ServerException), `LogInterceptor` (debug request/response).

## Coverage quality gate

`scripts/check_coverage.dart` excludes from measurement:
- `*.g.dart`, `*.freezed.dart` (auto-generated)
- `/test/` files
- `api_constants.dart`, `core_providers.dart`, `app_theme.dart`, `dio_client.dart`, `auth_repository.dart`, `auth_interceptor.dart`

## Testing patterns

- Override providers via `ProviderScope(overrides: [...])` with inline fake view model classes extending the real VM (e.g. `_FakeAuthVM extends AuthViewModel`).
- `authRedirect` is `@visibleForTesting` — test it directly with `AuthState` instances.
- Mockito (`mockito: ^5.4.0`) available for Dio/etc mocking.

## Known quirks

- `lib/amplifyconfiguration.dart` (with Cognito pool ID / client ID) IS tracked despite being in `.gitignore` (was committed before the gitignore rule was added).
- `.env` is gitignored; `.env.example` only has `API_BASE_URL`.
- Web: `setPathUrlStrategy()` in main.dart enables clean URLs without `#`.
- No i18n/localization implementation yet (planned but not built).
