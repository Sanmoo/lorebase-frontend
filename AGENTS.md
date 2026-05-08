# AGENTS.md

## Project Overview

Lorebase is a Flutter mobile/web app for tracking, discovering, and managing TV series watchlists. It connects to a backend API and uses AWS Cognito for authentication.

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.27 (managed by mise) |
| Language | Dart (SDK >=3.3.0 <4.0.0) |
| State management | Riverpod with code generation (`riverpod_annotation` / `riverpod_generator`) |
| Routing | GoRouter (declarative, auth-guarded) |
| HTTP client | Dio |
| Auth | AWS Amplify + Cognito |
| Models | Freezed + json_serializable |
| Local storage | flutter_secure_storage |
| Env vars | flutter_dotenv (`.env` file) |
| UI | Material 3, cached_network_image, shimmer |
| Linting | flutter_lints (see `analysis_options.yaml`) |

## Directory Structure

```
lib/
├── main.dart                  # Entry point: Amplify config, dotenv, ProviderScope
├── app.dart                   # MaterialApp.router with auth-aware loading
├── router.dart                # GoRouter with auth redirect + ShellRoute
├── core/
│   ├── constants/             # ApiConstants, AppConstants
│   ├── errors/                # exceptions.dart, failures.dart
│   ├── network/               # DioClient, AuthInterceptor, ErrorInterceptor
│   ├── providers/             # Shared providers (Dio, SecureStorage)
│   ├── responsive/            # Breakpoints
│   ├── theme/                 # AppColors, AppTheme (light + dark, Material 3)
│   └── widgets/               # Reusable widgets (ScaffoldWithNavBar, loading, error, empty state)
└── features/
    ├── auth/                  # Login, Register, ForgotPassword
    ├── dashboard/             # Main dashboard with stats and sections
    ├── recommendation/        # Recommendations page (stub)
    ├── series/                # Series search + detail
    └── tracking/              # Tracked series list + status management
```

Each feature follows this internal structure:
```
feature/
├── data/
│   ├── models/                # Freezed models (*.dart + generated *.freezed.dart, *.g.dart)
│   └── repositories/          # Data access, API calls via Dio
├── pages/                     # Full-screen pages (route targets)
├── viewmodels/                # Riverpod providers (*.dart + generated *.g.dart)
└── widgets/                   # Feature-specific widgets
```

## Key Conventions

### Code Generation
- **Never edit** `*.g.dart` or `*.freezed.dart` files — they are auto-generated.
- Run `dart run build_runner build` after changing any annotated file.
- Use `dart run build_runner watch` during active development.
- Models use `@freezed` annotation with `part '...freezed.dart'` and `part '...g.dart'`.
- ViewModels use `@riverpod` annotation with `part '...g.dart'`. They extend `_$ClassName` (the generated base class).

### Riverpod Patterns
- Annotated ViewModels: `@riverpod class FooViewModel extends _$FooViewModel { ... }`
- Manual providers (repositories, services): `final fooRepoProvider = Provider<FooRepository>((ref) => ...);`
- Widgets that access providers use `ConsumerWidget` or `ConsumerStatefulWidget`.
- Auth state is exposed via `authViewModelProvider` and watched at the router + app level.

### Routing
- GoRouter config lives in `router.dart` as a `Provider<GoRouter>`.
- Auth guard uses the router's `redirect` callback: unauthenticated users are sent to `/login`; authenticated users skip auth pages.
- Authenticated routes are wrapped in a `ShellRoute` that provides bottom navigation (`ScaffoldWithNavBar`).
- Always use `context.go()` (not `context.push()`) for navigation unless building a sub-flow.

### Models
- Data models use Freezed for immutability and JSON serialization.
- Example: `@freezed class DashboardModel with _$DashboardModel { const factory DashboardModel({...}) = _DashboardModel; factory DashboardModel.fromJson(...) = _$DashboardModelFromJson; }`
- Auth state (`AuthState`) is a plain Dart class (not Freezed) with named constructors.

### Networking
- `DioClient.create()` produces a Dio instance with base URL from `dotenv.env['API_BASE_URL']`.
- Interceptors: `AuthInterceptor` (attaches tokens), `ErrorInterceptor` (global error handling), `LogInterceptor`.
- Repositories receive Dio via Riverpod and call the backend API.

### Styling
- Material 3 with light/dark themes in `AppTheme`.
- Colors defined in `AppColors`.
- Single quotes, const constructors, final locals (enforced by linter).

## Environment Setup

Copy `.env.example` to `.env` and set:
```
API_BASE_URL=http://localhost:3003
```

The `.env` file is gitignored and loaded by `flutter_dotenv` in `main.dart`.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Code generation (one-shot)
dart run build_runner build --delete-conflicting-outputs

# Code generation (watch mode)
dart run build_runner watch --delete-conflicting-outputs

# Run tests
flutter test

# Run on connected device / emulator
flutter run

# Run on web
flutter run -d chrome

# Lint
dart analyze

# Coverage quality gate (line + function + branch at 100%)
make test-coverage

# Run all checks: analyze + coverage gate
make check
```

## What NOT to Do

- Don't edit `*.g.dart` or `*.freezed.dart` — they'll be overwritten by build_runner.
- Don't use `setState` in widgets that already have a Riverpod provider handling that state.
- Don't push auth pages onto the nav stack — the router redirect handles auth flow.
- Don't commit `.env` or Amplify secrets — they are gitignored.
- Don't add new features outside the `lib/features/` structure.
