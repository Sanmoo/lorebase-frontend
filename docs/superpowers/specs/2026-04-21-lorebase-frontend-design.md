# lorebase Frontend - Technical Design Specification

**Date:** 2026-04-21  
**Status:** Approved for Implementation  
**Tech Stack:** Flutter 3.x, Riverpod, Dio, Freezed, go_router, Amplify Flutter  
**Architecture:** MVVM + Riverpod  
**Author:** OpenCode (with user collaboration)

---

## 1. Executive Summary

This document specifies the technical architecture for the **lorebase frontend**, a cross-platform Flutter application (mobile-first, web-compatible) for tracking TV series consumption. The app consumes a single REST API: the **Experience BFF** (Backend for Frontend), which aggregates data from multiple AWS Lambda microservices.

**Key Decisions:**
- **Flutter** for cross-platform mobile + web support
- **MVVM + Riverpod** for lightweight, reactive state management
- **Dio** as HTTP client with interceptors for auth, retry, and error handling
- **Amplify Flutter** for AWS Cognito authentication
- **go_router** for declarative navigation
- **Feature-based folder structure** for scalability and isolation

---

## 2. API Context (Experience BFF)

The Flutter app communicates **exclusively** with the Experience BFF. No direct calls to downstream services (SeriesCatalog, UserTracking, Recommendation).

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `GET` | `/dashboard` | Aggregated dashboard data | Bearer JWT |
| `GET` | `/series?q={query}&limit={n}` | Search series (TMDB + cache) | Bearer JWT |
| `GET` | `/series/{id}` | Series details | Bearer JWT |
| `GET` | `/tracking?status={status}&page={n}&pageSize={n}` | List tracked series | Bearer JWT |
| `POST` | `/tracking` | Start tracking a series | Bearer JWT |
| `PUT` | `/tracking/{id}` | Update tracking (status, rating, review) | Bearer JWT |
| `DELETE` | `/tracking/{id}` | Remove tracking entry | Bearer JWT |
| `GET` | `/recommendation/next` | Random recommendation | Bearer JWT |

**Base URL:** Configurable via `API_BASE_URL` environment variable.  
**Local dev:** `http://localhost:3003`  
**Headers:** `Authorization: Bearer <cognito_jwt>` (injected by Dio interceptor).

---

## 3. Architecture

### 3.1 High-Level Diagram

```
+-----------------------------------------+
|           Flutter App                   |
|  +---------+ +---------+ +----------+ |
|  |  Pages  | | Widgets | |  Router  | |
|  +----+----+ +----+----+ +-----+----+ |
|       |           |            |       |
|  +----+-----------+------------+       |
|  |    Riverpod Providers/ViewModels    |
|  |         (AsyncValue<T>)             |
|  +---------------+----------------------+
|                  |                      |
|  +---------------+--------------------+ |
|  |   Repository Layer (Interfaces)     | |
|  |   DashboardRepository               | |
|  |   SeriesRepository                  | |
|  |   TrackingRepository                | |
|  +---------------+--------------------+ |
|                  |                      |
|  +---------------+--------------------+ |
|  |   Data Layer (Dio + DTOs)           | |
|  |   - AuthInterceptor                 | |
|  |   - ErrorInterceptor                | |
|  |   - Retry + Logging                 | |
|  +---------------+--------------------+ |
|                  | HTTP/JSON            |
+------------------+----------------------+
                   v
         +-----------------+
         |  Experience BFF |
         |  (AWS Lambda)   |
         +-----------------+
```

### 3.2 State Management with Riverpod

- **Providers** are the single source of truth for each feature's state
- **ViewModels** (StateNotifier/AsyncNotifier) encapsulate business logic and async operations
- **UI** observes `AsyncValue<T>` which handles `loading`, `data`, and `error` states declaratively
- **AutoDispose** cleans up providers when no longer needed

### 3.3 Error Handling Strategy

| Error Type | HTTP Status | UI Behavior |
|------------|-------------|-------------|
| Network/Timeout | None | Show retry widget with "Check connection" |
| Unauthorized | 401 | Redirect to `/login` (token expired) |
| Server Error | 500+ | Show generic error with retry button |
| Validation | 400 | Show field-level errors in forms |
| Not Found | 404 | Show empty state or 404 page |

---

## 4. Project Structure

```
lib/
  main.dart
  app.dart
  router.dart

  core/
    constants/
      api_constants.dart
      app_constants.dart
    errors/
      exceptions.dart
      failures.dart
    network/
      dio_client.dart
      auth_interceptor.dart
      error_interceptor.dart
    providers/
      core_providers.dart
    theme/
      app_theme.dart
      app_colors.dart
    widgets/
      loading_widget.dart
      error_widget.dart
      empty_state_widget.dart

  features/
    auth/
      data/
      viewmodels/
      pages/
        login_page.dart
        register_page.dart
      widgets/

    dashboard/
      data/
        models/
          dashboard_model.dart
        repositories/
          dashboard_repository.dart
      viewmodels/
        dashboard_viewmodel.dart
      pages/
        dashboard_page.dart
      widgets/
        watching_section.dart
        want_to_watch_section.dart
        stats_card.dart

    series/
      data/
        models/
          series_model.dart
        repositories/
          series_repository.dart
      viewmodels/
        series_search_viewmodel.dart
        series_detail_viewmodel.dart
      pages/
        series_search_page.dart
        series_detail_page.dart
      widgets/
        series_card.dart
        series_poster.dart

    tracking/
      data/
        models/
          tracked_series_model.dart
        repositories/
          tracking_repository.dart
      viewmodels/
        tracking_list_viewmodel.dart
        tracking_detail_viewmodel.dart
      pages/
        tracking_list_page.dart
        tracking_detail_page.dart
      widgets/
        tracking_status_chip.dart
        rating_stars.dart
        season_rating_dialog.dart

    recommendation/
      data/
      viewmodels/
      pages/
      widgets/

test/
  core/
  features/
    auth/
    dashboard/
    series/
    tracking/
    recommendation/
```

---

## 5. Models (Freezed)

All models are immutable, JSON-serializable, and use `@freezed`.

### SeriesModel

```dart
@freezed
class SeriesModel with _$SeriesModel {
  const factory SeriesModel({
    required String seriesId,
    required int tmdbId,
    required String title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    String? firstAirDate,
    @Default([]) List<String> genres,
    @Default([]) List<String> networks,
    @Default(0) int seasonCount,
    String? status,
  }) = _SeriesModel;

  factory SeriesModel.fromJson(Map<String, dynamic> json) =>
      _$SeriesModelFromJson(json);
}
```

### TrackedSeriesModel

```dart
@freezed
class TrackedSeriesModel with _$TrackedSeriesModel {
  const factory TrackedSeriesModel({
    required String trackingId,
    required String userId,
    required String seriesId,
    required String status,
    int? seriesRating,
    String? seriesReview,
    @Default([]) List<SeasonRatingModel> seasonRatings,
    required DateTime addedAt,
    required DateTime lastUpdated,
  }) = _TrackedSeriesModel;

  factory TrackedSeriesModel.fromJson(Map<String, dynamic> json) =>
      _$TrackedSeriesModelFromJson(json);
}
```

### SeasonRatingModel

```dart
@freezed
class SeasonRatingModel with _$SeasonRatingModel {
  const factory SeasonRatingModel({
    required int seasonNumber,
    required int rating,
    required DateTime ratedAt,
  }) = _SeasonRatingModel;

  factory SeasonRatingModel.fromJson(Map<String, dynamic> json) =>
      _$SeasonRatingModelFromJson(json);
}
```

### DashboardModel

```dart
@freezed
class DashboardModel with _$DashboardModel {
  const factory DashboardModel({
    required DashboardSection watching,
    required DashboardSection wantToWatch,
    required DashboardSection completed,
    required DashboardSection dropped,
    required DashboardStats stats,
  }) = _DashboardModel;

  factory DashboardModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardModelFromJson(json);
}

@freezed
class DashboardSection with _$DashboardSection {
  const factory DashboardSection({
    @Default([]) List<SeriesModel> items,
    @Default(0) int total,
    @Default(false) bool hasMore,
  }) = _DashboardSection;

  factory DashboardSection.fromJson(Map<String, dynamic> json) =>
      _$DashboardSectionFromJson(json);
}

@freezed
class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    @Default(0) int watchingCount,
    @Default(0) int wantToWatchCount,
    @Default(0) int completedCount,
    @Default(0) int droppedCount,
    @Default(0) int totalTracked,
  }) = _DashboardStats;

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);
}
```

---

## 6. Authentication (Amplify Flutter)

**Flow:**
1. App launches -> `Amplify.Auth.fetchAuthSession()`
2. Valid session -> redirect to `/dashboard`
3. Invalid/expired -> redirect to `/login`
4. Login/Register via `Amplify.Auth.signIn()` / `signUp()`
5. Token automatically available via Amplify
6. `AuthInterceptor` reads token and injects `Authorization: Bearer <token>`

**Logout:** `Amplify.Auth.signOut()` + invalidate Riverpod providers.

**Local Dev Fallback:** When Amplify is not configured (backend still in development), the app supports a `x-user-id` header mode for direct API testing.

---

## 7. Navigation (go_router)

**Routes:**

| Path | Page | Auth Required |
|------|------|---------------|
| `/login` | LoginPage | No |
| `/register` | RegisterPage | No |
| `/dashboard` | DashboardPage | Yes |
| `/search` | SeriesSearchPage | Yes |
| `/series/:id` | SeriesDetailPage | Yes |
| `/tracking` | TrackingListPage | Yes |
| `/tracking/:id` | TrackingDetailPage | Yes |
| `/recommend` | RecommendationPage | Yes |

**Bottom Navigation (4 tabs):**
1. Dashboard (`/dashboard`)
2. Search (`/search`)
3. My Lists (`/tracking`)
4. Recommend (`/recommend`)

**Redirect Guard:** Unauthenticated users accessing auth routes are redirected to `/login`.

---

## 8. Network Layer (Dio)

**Dio Configuration:**
- Base URL from environment
- Connect/Receive timeout: 10s
- Interceptors:
  - `AuthInterceptor`: Injects Bearer token from Amplify
  - `ErrorInterceptor`: Maps HTTP errors to exceptions, handles 401 redirect
  - `LogInterceptor`: Debug logging (dev only)

**AuthInterceptor:**
```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      final token = session.userPoolTokensResult.value?.accessToken;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // No session, proceed without token (will get 401)
    }
    handler.next(options);
  }
}
```

**ErrorInterceptor:**
```dart
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.response?.statusCode) {
      case 401:
        // Trigger auth redirect via navigator key or event bus
        break;
      case 500:
        err = err.copyWith(message: 'Server error. Please try again later.');
        break;
      case null:
        err = err.copyWith(message: 'Network error. Check your connection.');
        break;
    }
    handler.next(err);
  }
}
```

---

## 9. UI/UX Design Principles

- **Mobile-first:** Touch targets min 48dp, bottom navigation, scrollable lists
- **Cards for series:** Poster + title + status chip, tappable
- **Bottom sheets:** For actions (change status, rate, add review)
- **Pull-to-refresh:** On all list views
- **Skeleton loaders:** While loading initial data
- **Empty states:** Friendly illustrations when lists are empty
- **Offline indicator:** Snackbar when network is unavailable

---

## 10. Testing Strategy

| Type | Scope | Tool |
|------|-------|------|
| Unit | ViewModels with mocked repositories | flutter_test + mockito |
| Widget | Pages and widgets in isolation | flutter_test |
| Integration | Full user flows | integration_test |

**Unit Test Example (ViewModel):**
```dart
test('loadDashboard should emit loading then data', () async {
  final mockRepo = MockDashboardRepository();
  when(mockRepo.getDashboard()).thenAnswer((_) async => testDashboard);

  final container = ProviderContainer(overrides: [
    dashboardRepositoryProvider.overrideWithValue(mockRepo),
  ]);

  final vm = container.read(dashboardViewModelProvider.notifier);
  await vm.loadDashboard();

  final state = container.read(dashboardViewModelProvider);
  expect(state, AsyncValue.data(testDashboard));
});
```

---

## 11. Environment & Configuration

**Variables (via `--dart-define` or `.env`):**
- `API_BASE_URL`
- `COGNITO_USER_POOL_ID`
- `COGNITO_CLIENT_ID`
- `AWS_REGION`

**Build flavors:**
- `dev` -> local BFF (`localhost:3003`)
- `staging` -> staging API
- `prod` -> production API

---

## 12. Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

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

  # Models & Serialization
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0

  # Storage
  flutter_secure_storage: ^9.0.0

  # UI
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.3.0
  riverpod_lint: ^2.3.0
```

---

## 13. Implementation Phases

### Phase 1: Project Bootstrap
- Initialize Flutter project
- Configure pubspec.yaml with all dependencies
- Set up folder structure
- Configure analysis_options.yaml
- Set up build_runner

### Phase 2: Core Infrastructure
- Dio client with interceptors
- Core providers (Dio, secure storage)
- App theme and colors
- Shared widgets (loading, error, empty state)
- Router configuration with go_router

### Phase 3: Auth Feature
- Configure Amplify Flutter
- Login page UI
- Register page UI
- Auth ViewModel with Riverpod
- Auth state management (logged in / logged out)
- Redirect guards in router

### Phase 4: Dashboard Feature
- Dashboard model (Freezed)
- Dashboard repository
- Dashboard ViewModel
- Dashboard page with sections
- Widgets: watching_section, want_to_watch_section, stats_card
- Pull-to-refresh

### Phase 5: Series Search Feature
- Series model (Freezed)
- Series repository
- Search ViewModel
- Search page with search bar
- Series card widget
- Series detail page

### Phase 6: Tracking Feature
- TrackedSeries model (Freezed)
- Tracking repository (CRUD)
- Tracking list ViewModel
- Tracking detail ViewModel
- Tracking list page
- Tracking detail page (status, rating, review, season ratings)
- Bottom sheet for status change
- Rating stars widget

### Phase 7: Recommendation Feature
- Recommendation model
- Recommendation repository
- Recommendation ViewModel
- Recommendation page

### Phase 8: Testing & Polish
- Unit tests for all ViewModels
- Widget tests for critical pages
- Integration test for main flow
- Error handling refinement
- UI polish and animations

### Phase 9: Web & Build Configuration
- Web build configuration
--dart-define for environments
- Build flavors setup
- README with setup instructions

---

## 14. Open Questions & Decisions

| Question | Decision | Date |
|----------|----------|------|
| State management | Riverpod (MVVM pattern) | 2026-04-21 |
| Auth provider | Amplify Flutter (Cognito) | 2026-04-21 |
| HTTP client | Dio with interceptors | 2026-04-21 |
| Navigation | go_router (declarative) | 2026-04-21 |
| Models | Freezed + json_serializable | 2026-04-21 |
| Architecture | MVVM (simplified Clean) | 2026-04-21 |
| Offline support | None in MVP (future: Hive/SQLite) | 2026-04-21 |
| Local auth fallback | x-user-id header for dev | 2026-04-21 |

---

**End of Specification**

*This document should be reviewed and updated as the system evolves. Last updated: 2026-04-21*
