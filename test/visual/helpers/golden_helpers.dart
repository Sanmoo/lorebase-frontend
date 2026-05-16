// coverage:ignore-file
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/login_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/register_viewmodel.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_model.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_section_model.dart';
import 'package:lorebase/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:lorebase/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:lorebase/features/movies/data/models/movie_model.dart';
import 'package:lorebase/features/movies/viewmodels/movie_detail_state.dart';
import 'package:lorebase/features/movies/viewmodels/movie_detail_viewmodel.dart';
import 'package:lorebase/features/movies/viewmodels/movie_search_viewmodel.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';
import 'package:lorebase/features/series/viewmodels/series_detail_state.dart';
import 'package:lorebase/features/series/viewmodels/series_detail_viewmodel.dart';
import 'package:lorebase/features/series/viewmodels/series_search_viewmodel.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_summary_model.dart';
import 'package:lorebase/features/tracking/viewmodels/tracking_list_viewmodel.dart';

// ─── Fake ViewModels ────────────────────────────────────

class FakeAuthVM extends AuthViewModel {
  @override
  AuthState build() => const AuthState.authenticated('golden-user-1');

  @override
  void setAuthenticated(String userId) {}

  @override
  void setUnauthenticated() {}

  @override
  Future<void> signOut() async {}
}

class FakeUnauthVM extends AuthViewModel {
  @override
  AuthState build() => const AuthState.unauthenticated();

  @override
  void setAuthenticated(String userId) {}

  @override
  void setUnauthenticated() {}

  @override
  Future<void> signOut() async {}
}

class FakeLoginVM extends LoginViewModel {
  @override
  LoginState build() => const LoginState();
}

class FakeRegisterVM extends RegisterViewModel {
  @override
  RegisterState build() => const RegisterState();
}

class FakeDashboardVM extends DashboardViewModel {
  @override
  AsyncValue<DashboardModel> build() => AsyncValue.data(_dashboardWithData());

  @override
  Future<void> refresh() async {}

  @override
  Future<void> loadDashboard({MediaType mediaType = MediaType.series}) async {}
}

class FakeSeriesDetailVM extends SeriesDetailViewModel {
  @override
  Future<SeriesDetailState> build(int tmdbId) async => const SeriesDetailState(
        series: SeriesModel(
          tmdbId: 1,
          title: 'Breaking Bad',
          overview:
              'A high school chemistry teacher diagnosed with inoperable lung '
              'cancer turns to manufacturing and selling methamphetamine in '
              'order to secure his family\'s future.',
          genres: ['Drama', 'Crime', 'Thriller'],
          seasonCount: 5,
          status: 'Ended',
          firstAirDate: '2008-01-20',
          networks: ['AMC'],
        ),
        tracking: null,
      );

  @override
  Future<void> addTracking(String status, {int? rating, String? review}) async {}

  @override
  Future<void> updateTracking({String? status, int? rating, String? review}) async {}

  @override
  Future<void> removeTracking() async {}
}

class FakeMovieDetailVM extends MovieDetailViewModel {
  @override
  Future<MovieDetailState> build(int tmdbId) async => const MovieDetailState(
        movie: MovieModel(
          tmdbId: 7,
          title: 'Se7en',
          overview:
              'Two detectives, a rookie and a veteran, hunt a serial killer '
              'who uses the seven deadly sins as his motives.',
          releaseDate: '1995-09-22',
          runtimeMinutes: 127,
          genres: ['Crime', 'Mystery', 'Thriller'],
        ),
        tracking: null,
      );

  @override
  Future<void> addTracking(String status, {int? rating, String? review}) async {}

  @override
  Future<void> updateTracking({String? status, int? rating, String? review}) async {}

  @override
  Future<void> removeTracking() async {}
}

class FakeSeriesSearchVM extends SeriesSearchViewModel {
  @override
  AsyncValue<List<SeriesModel>> build() => AsyncValue.data(_searchResults());

  @override
  Future<void> search(String query) async {}

  @override
  void clear() {}
}

class FakeMovieSearchVM extends MovieSearchViewModel {
  @override
  AsyncValue<List<MovieModel>> build() => const AsyncValue.data([]);

  @override
  Future<void> search(String query) async {}

  @override
  void clear() {}
}

class FakeTrackingListVM extends TrackingListViewModel {
  @override
  AsyncValue<List<TrackedMediaModel>> build() =>
      AsyncValue.data(_trackingItems());

  @override
  Future<void> loadTracking(
      {String? status, MediaType mediaType = MediaType.series}) async {}

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> refresh() async {}
}

// ─── Data Factories ─────────────────────────────────────

DashboardModel _dashboardWithData() {
  const media = TrackedMediaSummaryModel(
    mediaId: '456',
    title: 'Breaking Bad',
    mediaType: MediaType.series,
  );
  return const DashboardModel(
    watching: DashboardSectionModel(items: [media]),
    wantToWatch: DashboardSectionModel(items: [media]),
    completed: DashboardSectionModel(items: [media]),
    dropped: DashboardSectionModel(),
    stats: DashboardStatsModel(
      watchingCount: 3,
      wantToWatchCount: 2,
      completedCount: 5,
      droppedCount: 1,
    ),
  );
}

List<SeriesModel> _searchResults() => const [
      SeriesModel(tmdbId: 1, title: 'Breaking Bad'),
      SeriesModel(tmdbId: 2, title: 'Better Call Saul'),
      SeriesModel(tmdbId: 3, title: 'Stranger Things'),
    ];

final _now = DateTime(2025, 1, 1);

List<TrackedMediaModel> _trackingItems() => [
      TrackedMediaModel(
        trackingId: 't1',
        userId: 'golden-user-1',
        mediaType: MediaType.series,
        mediaId: '1',
        status: 'WATCHING',
        media: const TrackedMediaSummaryModel(
          mediaId: '1',
          title: 'Breaking Bad',
          mediaType: MediaType.series,
        ),
        rating: 9,
        addedAt: _now,
        lastUpdated: _now,
      ),
      TrackedMediaModel(
        trackingId: 't2',
        userId: 'golden-user-1',
        mediaType: MediaType.series,
        mediaId: '2',
        status: 'WATCHING',
        media: const TrackedMediaSummaryModel(
          mediaId: '2',
          title: 'Better Call Saul',
          mediaType: MediaType.series,
        ),
        rating: 8,
        addedAt: _now,
        lastUpdated: _now,
      ),
      TrackedMediaModel(
        trackingId: 't3',
        userId: 'golden-user-1',
        mediaType: MediaType.series,
        mediaId: '3',
        status: 'WATCHING',
        media: const TrackedMediaSummaryModel(
            mediaId: '3',
            title: 'Stranger Things',
            mediaType: MediaType.series),
        rating: 7,
        addedAt: _now,
        lastUpdated: _now,
      ),
    ];

// ─── Override Helpers ───────────────────────────────────

List<Override> authOverride() => [
      authViewModelProvider.overrideWith(() => FakeAuthVM()),
    ];

List<Override> unauthOverride() => [
      authViewModelProvider.overrideWith(() => FakeUnauthVM()),
    ];

List<Override> dashboardGoldenOverrides() => [
      dashboardViewModelProvider.overrideWith(() => FakeDashboardVM()),
      ...authOverride(),
    ];

List<Override> loginGoldenOverrides() => [
      loginViewModelProvider.overrideWith(() => FakeLoginVM()),
      ...unauthOverride(),
    ];

List<Override> registerGoldenOverrides() => [
      registerViewModelProvider.overrideWith(() => FakeRegisterVM()),
      ...unauthOverride(),
    ];

List<Override> seriesDetailGoldenOverrides() => [
      seriesDetailViewModelProvider(1).overrideWith(() => FakeSeriesDetailVM()),
      ...authOverride(),
    ];

List<Override> seriesSearchGoldenOverrides() => [
      seriesSearchViewModelProvider.overrideWith(() => FakeSeriesSearchVM()),
      movieSearchViewModelProvider.overrideWith(() => FakeMovieSearchVM()),
      ...authOverride(),
    ];

List<Override> movieDetailGoldenOverrides() => [
      movieDetailViewModelProvider(7).overrideWith(() => FakeMovieDetailVM()),
      ...authOverride(),
    ];

List<Override> trackingListGoldenOverrides() => [
      trackingListViewModelProvider.overrideWith(() => FakeTrackingListVM()),
      ...authOverride(),
    ];
