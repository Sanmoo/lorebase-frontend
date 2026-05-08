import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/series/pages/series_detail_page.dart';
import 'package:lorebase/features/series/viewmodels/series_detail_viewmodel.dart';
import 'package:lorebase/features/series/viewmodels/series_detail_state.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';
import 'package:lorebase/features/tracking/data/models/tracked_series_model.dart';
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

class _LoadingDetailVM extends SeriesDetailViewModel {
  @override
  Future<SeriesDetailState> build(int tmdbId) async {
    await Completer<Never>().future;
    throw UnimplementedError();
  }
}

class _ErrorDetailVM extends SeriesDetailViewModel {
  @override
  Future<SeriesDetailState> build(int tmdbId) async {
    throw Exception('Test error message');
  }
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

Widget _wrap(ProviderContainer container) {
  return UncontrolledProviderScope(
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
  );
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

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Add to List'), findsOneWidget);
    });

    testWidgets('loading state shows LoadingWidget', (tester) async {
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => _LoadingDetailVM()),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Loading series details...'), findsOneWidget);
    });

    testWidgets('error state shows error message and retry', (tester) async {
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => _ErrorDetailVM()),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Exception: Test error message'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('detail content renders correctly', (tester) async {
      final detail =
          SeriesDetailState(series: _testSeries(), tracking: null);
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => FakeDetailVM(data: detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test Series'), findsWidgets);
      expect(find.text('Drama'), findsOneWidget);
      expect(find.text('First Air Date'), findsOneWidget);
      expect(find.text('2024-01-01'), findsOneWidget);
      expect(find.text('Seasons'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Networks'), findsOneWidget);
      expect(find.text('HBO'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Returning Series'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('A test overview'), findsOneWidget);
    });

    testWidgets('tracking bottom sheet opens on button tap', (tester) async {
      final detail =
          SeriesDetailState(series: _testSeries(), tracking: null);
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => FakeDetailVM(data: detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Add to List'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Rating'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('watch status chip renders when tracking', (tester) async {
      final tracking = TrackedSeriesModel(
        trackingId: 't1',
        userId: 'u1',
        seriesId: '1',
        status: 'WATCHING',
        addedAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
      final detail =
          SeriesDetailState(series: _testSeries(), tracking: tracking);
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => FakeDetailVM(data: detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Manage Tracking'), findsOneWidget);
      expect(find.text('Watching'), findsOneWidget);
    });
  });
}
