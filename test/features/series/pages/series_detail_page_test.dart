import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/series/pages/series_detail_page.dart';
import 'package:lorebase/features/series/viewmodels/series_detail_viewmodel.dart';
import 'package:lorebase/features/series/viewmodels/series_detail_state.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';

SeriesModel _testSeries() => SeriesModel(
      tmdbId: 1,
      title: 'Test Series',
      overview: 'A test overview',
      genres: ['Drama'],
      seasonCount: 3,
      status: 'Returning Series',
      firstAirDate: '2024-01-01',
      networks: ['HBO'],
    );

class FakeDetailVM extends SeriesDetailViewModel {
  final SeriesDetailState data;
  FakeDetailVM({required this.data});

  @override
  Future<SeriesDetailState> build(int tmdbId) async => data;
}

class FakeAuthVM extends AuthViewModel {
  @override
  AuthState build() => const AuthState.authenticated('user-1');
  @override
  void setAuthenticated(String userId) {}
  @override
  void setUnauthenticated() {}
  @override
  Future<void> signOut() async {}
}

void main() {
  group('SeriesDetailPage', () {
    testWidgets('renders with Add to List button when not tracking',
        (tester) async {
      final detail =
          SeriesDetailState(series: _testSeries(), tracking: null);
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => FakeDetailVM(data: detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/series/1',
              routes: [
                GoRoute(
                  path: '/series/:tmdbId',
                  builder: (_, state) => SeriesDetailPage(
                      tmdbId: int.parse(state.pathParameters['tmdbId']!)),
                ),
              ],
            ),
          ),
        ),
      );
      // Wait for async build to complete
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Add to List'), findsOneWidget);
    });
  });
}
