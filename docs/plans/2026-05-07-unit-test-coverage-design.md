# Test Coverage Plan — Unit & Widget Tests

**Date:** 2026-05-07
**Goal:** 100% coverage of all important app code (excluding pure wiring/config).

---

## 1. Classification

| Category | Count | Test Type |
|---|---|---|
| ViewModels + States | 10 | Unit test |
| Repositories | 4 | Unit test |
| Models (Freezed) | 6 | Unit test |
| Core logic | 5 | Unit test |
| Widgets | 14 | Widget test |
| Pages | 8 | Widget test |
| Excluded (pure config) | ~10 | ❌ |

**Excluded files:** `main.dart`, `app.dart`, `router.dart`, `dio_client.dart`, `core_providers.dart`, `app_colors.dart`, `app_theme.dart`, `amplifyconfiguration.dart`, `auth_repository.dart` (Amplify static), `api_constants.dart`.

---

## 2. Unit Tests — ViewModels (7 files + 3 state classes)

Use `ProviderContainer` with overrides to inject mock repositories.

### LoginViewModel (`login_viewmodel.dart`)
- `submit()` with empty fields → error message in state
- `submit()` success → `setAuthenticated(userId)` called, `isLoading` cleared
- `submit()` with `AuthException` → error message in state
- `submit()` with generic exception → fallback error message
- `setEmail()` / `setPassword()` clears `errorMessage`
- `toggleObscurePassword()` toggles flag
- `LoginState.isValid` returns false when email or password empty
- `LoginState.copyWith` with explicit `errorMessage: null` clears it

### RegisterViewModel (`register_viewmodel.dart`)
- `RegisterState.passwordStrength` — weak (len<8, no upper, no digit)
- `RegisterState.passwordStrength` — medium (2 of 3 criteria)
- `RegisterState.passwordStrength` — strong (all 3 criteria)
- `RegisterState.isValid` — false when terms not accepted
- `RegisterState.isValid` — false when passwords don't match
- `RegisterState.isValid` — false when password is weak
- `RegisterState.isValid` — true when all conditions met
- `submit()` success → `showConfirmation = true`
- `submit()` with `AuthException` → error message
- `submit()` with generic exception → fallback error
- `confirmSignUp()` without code → error
- `confirmSignUp()` with code → authenticates user, navigates
- `confirmSignUp()` with `AuthException` → error message
- `resendCode()` does not throw
- `toggleTerms()` toggles and clears error
- `toggleObscurePassword()` toggles flag
- `RegisterState.copyWith` preserves unspecified fields

### ForgotPasswordViewModel (`forgot_password_viewmodel.dart`)
- `ForgotPasswordState.canRequestCode` — true when email is not empty
- `ForgotPasswordState.canRequestCode` — false when email is empty
- `ForgotPasswordState.canResetPassword` — false when code empty
- `ForgotPasswordState.canResetPassword` — false when passwords don't match
- `ForgotPasswordState.canResetPassword` — true when all conditions met
- `requestCode()` with empty email → error
- `requestCode()` success → phase changes to `resetPassword`
- `requestCode()` with `AuthException` → error message
- `resetPassword()` with mismatched passwords → specific error
- `resetPassword()` with empty fields → generic error
- `resetPassword()` success → loading cleared
- `resetPassword()` with `AuthException` → error message
- `toggleObscurePassword()` toggles flag
- `ForgotPasswordState.copyWith` preserves unspecified fields

### DashboardViewModel (`dashboard_viewmodel.dart`)
- `build()` starts with `AsyncValue.loading()`
- Success → `AsyncValue.data(dashboard)`
- Error → `AsyncValue.error(error, stackTrace)`
- `refresh()` calls `loadDashboard()`

### SeriesSearchViewModel (`series_search_viewmodel.dart`)
- `search()` with empty/whitespace query → state cleared to `[]`
- `search()` success → `AsyncValue.data(results)`
- `search()` with Dio cancel → state unchanged (does not overwrite)
- `search()` error → `AsyncValue.error`
- `clear()` resets state to `[]`
- `search()` cancels previous in-flight request via CancelToken

### SeriesDetailViewModel (`series_detail_viewmodel.dart`)
- `build(tmdbId)` fetches series + matching tracking → `SeriesDetailState`
- `build(tmdbId)` with no matching tracking → `tracking: null`
- `build(tmdbId)` fetch error → `AsyncError`
- `addTracking()` calls `startTracking` then `updateTracking` if rating/review
- `updateTracking()` calls repository `updateTracking` and invalidates
- `removeTracking()` calls repository `deleteTracking` and invalidates
- All mutations guard against null `state.valueOrNull`

### TrackingListViewModel (`tracking_list_viewmodel.dart`)
- `loadTracking(status:)` resets page to 1, sets loading, fetches
- `loadTracking()` success → `AsyncValue.data(items)`
- `loadTracking()` error → `AsyncValue.error`
- `loadMore()` increments page, appends results
- `loadMore()` does nothing if already loading
- `refresh()` reuses current status filter

### AuthState (`auth_state.dart`)
- `AuthState.unknown()` — `isLoading=true`, `isAuthenticated=false`
- `AuthState.authenticated(id)` — `isLoading=false`, `isAuthenticated=true`
- `AuthState.unauthenticated()` — `isLoading=false`, `isAuthenticated=false`
- `copyWith` preserves unspecified fields

### SeriesDetailState (`series_detail_state.dart`)
- Factory constructor creates instance with required `series` and optional `tracking`
- Equality (Freezed-generated) works correctly

---

## 3. Unit Tests — Repositories (3 files)

Mock `Dio` to return controlled responses.

### DashboardRepositoryImpl
- `getDashboard()` success → returns `DashboardModel` from JSON
- `getDashboard()` DioException → throws `ServerException`
- `getDashboard()` DioException with embedded `ServerException` in error → propagates
- `_normalizeDashboardItems` maps `seriesId` string to `tmdbId` int
- `_normalizeDashboardItems` handles missing `items` key gracefully
- `_normalizeDashboardItems` handles non-list `items` gracefully

### SeriesRepositoryImpl
- `searchSeries(query)` success → returns `List<SeriesModel>`
- `searchSeries(query)` with `cancelToken` → passes to Dio
- `searchSeries(query)` DioException → throws `ServerException`
- `getSeriesById(id)` success → returns `SeriesModel`
- `getSeriesById(id)` DioException → throws `ServerException`

### TrackingRepositoryImpl
- `getTracking()` success → returns `List<TrackedSeriesModel>`
- `getTracking()` with status filter → passes `status` query param
- `getTracking()` with pagination → passes `page` and `pageSize`
- `getTracking()` DioException → throws `ServerException`
- `startTracking(seriesId, status)` POST → returns `TrackedSeriesModel`
- `startTracking()` DioException → throws `ServerException`
- `updateTracking(seriesId, ...)` PUT → returns `TrackedSeriesModel`
- `updateTracking()` with only status → only sends status in body
- `updateTracking()` with rating + review → sends all fields
- `updateTracking()` with seasonRatings → sends seasonRatings
- `updateTracking()` DioException → throws `ServerException`
- `deleteTracking(seriesId)` DELETE → completes without error
- `deleteTracking()` DioException → throws `ServerException`

---

## 4. Unit Tests — Core Logic (5 files)

### exceptions.dart
- `ServerException` toString includes message and statusCode
- `ServerException` toString when statusCode is null
- `NetworkException` toString
- `AuthException` toString

### failures.dart
- `ServerFailure` default message
- `NetworkFailure` default message
- `AuthFailure` default message
- Custom messages override defaults

### ErrorInterceptor
- `connectionTimeout` → wraps as `NetworkException`
- `sendTimeout` → wraps as `NetworkException`
- `receiveTimeout` → wraps as `NetworkException`
- `connectionError` → wraps as `NetworkException`
- `badResponse` with 401 → wraps as `AuthException`
- `badResponse` with 500+ → wraps as `ServerException`
- `badResponse` with 404 → wraps as `ServerException` with statusCode 404
- `badResponse` with other 4xx → passes through unchanged
- Default/unhandled type → wraps as `NetworkException`
- Handler always calls `handler.next(err)`

### TrackingStatus enum
- `TrackingStatus.fromString('WATCHING')` → `TrackingStatus.watching`
- `TrackingStatus.fromString('WANT_TO_WATCH')` → `TrackingStatus.wantToWatch`
- `TrackingStatus.fromString('COMPLETED')` → `TrackingStatus.completed`
- `TrackingStatus.fromString('DROPPED')` → `TrackingStatus.dropped`
- `TrackingStatus.fromString('INVALID')` → falls back to `wantToWatch`
- `TrackingStatus.values` has exactly 4 items
- Each status has correct `value` and `label`

---

## 5. Unit Tests — Models (Freezed, 6 files)

Each Freezed model: test `fromJson` with complete and partial JSON, verify defaults, test roundtrip (toJson → fromJson).

### SeriesModel
- Complete JSON → correct fields
- Missing optional fields → defaults (`genres: []`, `seasonCount: 0`, etc.)
- `toJson` → `fromJson` roundtrip preserves data

### DashboardModel
- JSON with all 4 sections + stats → correct structure
- Roundtrip

### DashboardSectionModel
- JSON with items, total, hasMore → correct
- Default values when fields missing

### DashboardStatsModel
- JSON with all 5 counters → correct
- Defaults to zero when fields missing

### TrackedSeriesModel
- Complete JSON with nested seasonRatings + series → correct
- Without series → `series: null`
- Roundtrip

### SeasonRatingModel
- JSON → correct fields
- Roundtrip

---

## 6. Widget Tests — Reusable Widgets (11 new)

### AuthButton
- Renders text label
- `isLoading=true` → `CircularProgressIndicator` visible, button disabled
- `onPressed` fires callback when tapped

### AuthPageScaffold
- Renders children passed to it
- Shows movie icon + "lorebase" branding
- Has gradient background

### RatingStars
- No rating → all stars unfilled (`star_border`)
- Rating=7 → 7 filled, 3 unfilled
- Tap on star calls `onRatingChanged` with correct value (1-indexed)
- Without `onRatingChanged` → tap does not crash

### StatusBottomSheet
- Renders "Update Status" title
- Shows all 4 `TrackingStatus` options
- Current status shows `check_circle` icon
- Tapping an option calls `onStatusSelected` with correct value
- Tapping an option pops the bottom sheet

### TrackingStatusChip
- `WATCHING` → green chip, label "Watching"
- `WANT_TO_WATCH` → amber chip, label "Want to Watch"
- `COMPLETED` → blue chip, label "Completed"
- `DROPPED` → red chip, label "Dropped"
- Unknown status → falls back to "Want to Watch"

### EmptyStateWidget
- Shows default icon (`inbox_outlined`)
- Shows message text
- Custom icon overrides default

### AppErrorWidget
- Shows error message
- Without `onRetry` → no button rendered
- With `onRetry` → "Retry" button visible and functional

### LoadingWidget
- Shows `CircularProgressIndicator`
- Without `message` → no text below spinner
- With `message` → text visible

### ScaffoldWithNavBar
- Renders 4 bottom navigation items with correct labels
- `_getCurrentIndex` returns 0 for `/dashboard`, 1 for `/search`, 2 for `/tracking`, 3 for `/recommend`
- Tapping nav item calls `context.go()` to correct route
- Logout `IconButton` is visible

### SeriesPoster
- Shows network image
- Shows title text (truncated to 2 lines)
- `onTap` callback fires on tap
- Without `onTap` → does not crash

### StatsCard
- Shows title, count, icon, and color
- Count of zero renders "0"

### SeriesHorizontalList
- Renders list of `SeriesPoster` widgets
- Empty list → no crash, empty `SizedBox`
- `onTap` propagates correct `SeriesModel`

---

## 7. Widget Tests — Pages (8)

### LoginPage
- Renders email field, password field, "Entrar" button
- "Esqueceu a senha?" link navigates to `/forgot-password`
- "Cadastre-se" link navigates to `/register`
- Submit with empty fields → inline error
- Submit success → navigates to `/dashboard`

### RegisterPage
- Renders email, password, confirm password fields + terms checkbox
- Password strength indicator (weak/medium/strong bar + label)
- Submit success → shows confirmation screen with code field
- Confirmation screen: "Confirmar e entrar" + "Reenviar código" buttons
- "Já tem conta?" link navigates to `/login`

### ForgotPasswordPage
- Phase 1: email field + "Enviar código" button
- Phase 1 submit → transitions to phase 2
- Phase 2: code field + new password + confirm + "Redefinir senha" button
- Phase 2 submit success → SnackBar + navigates to `/login`
- Error → inline error message
- "Voltar para o login" link navigates to `/login`

### DashboardPage
- Loading state → `LoadingWidget`
- Error state → `AppErrorWidget` with retry
- Data state → 4 `StatsCard` widgets + `DashboardSection` per category
- Pull-to-refresh triggers `refresh()`
- Empty state when all sections are empty → `EmptyStateWidget`

### SeriesSearchPage
- Search field with autofocus
- Empty query → initial state ("Type at least 2 characters")
- Query ≥ 2 chars → debounced search, results shown
- Clear button resets
- No results → "No series found"
- Error → `AppErrorWidget`

### SeriesDetailPage
- Loading → `LoadingWidget`
- Error → `AppErrorWidget`
- Data → backdrop, poster, title, genres, overview, info cards
- "Add to List" button shows tracking bottom sheet
- "Manage Tracking" button when already tracking
- Bottom sheet: status selection, rating stars, review field, save button
- Bottom sheet: "Remove from List" with confirmation dialog when editing

### TrackingListPage
- 4 tabs: Want to Watch, Watching, Completed, Dropped
- Initial tab loads data via `loadTracking`
- Tab change → new data load
- Loading → `LoadingWidget`
- Empty → `EmptyStateWidget`
- Grid shows `SeriesPoster` + `TrackingStatusChip` per item

### RecommendationPage
- Renders "Recommendation feature coming soon!" text

---

## 8. Execution Order

1. **Core logic** (exceptions, failures, TrackingStatus) — no dependencies, fast
2. **Models** (Freezed fromJson/toJson) — no dependencies
3. **States** (AuthState, LoginState, RegisterState, ForgotPasswordState) — pure Dart
4. **ViewModels** — depend on mock repositories
5. **Repositories** — depend on mock Dio
6. **Widgets** — need `flutter_test`
7. **Pages** — most complex, need `flutter_test` + mock providers

---

## 9. What NOT to Cover

- `main.dart` — entry point, Amplify config wiring
- `app.dart` — MaterialApp.router wiring
- `router.dart` — GoRouter provider wiring
- `dio_client.dart` — Dio factory, no logic
- `core_providers.dart` — provider declarations, no logic
- `app_colors.dart` — static constants
- `app_theme.dart` — ThemeData wiring
- `amplifyconfiguration.dart` — auto-generated
- `auth_repository.dart` — depends on static `Amplify.Auth.*`, unmockable without refactor
- `api_constants.dart` — depends on `dotenv.env`, low value
- `*.g.dart` / `*.freezed.dart` — auto-generated
