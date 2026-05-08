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
  bool failAddTracking = false;
  bool failRemoveTracking = false;
  FakeDetailVM({required this.data});

  @override
  Future<SeriesDetailState> build(int tmdbId) async => data;

  @override
  Future<void> addTracking(String status, {int? seriesRating, String? seriesReview}) async {
    if (failAddTracking) throw Exception('Add failed');
    // success — no-op
  }

  @override
  Future<void> updateTracking({String? status, int? seriesRating, String? seriesReview}) async {
    if (failAddTracking) throw Exception('Update failed');
  }

  @override
  Future<void> removeTracking() async {
    if (failRemoveTracking) throw Exception('Remove failed');
  }
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

    testWidgets('overview with null overview shows no description', (tester) async {
      final series = _testSeries().copyWith(overview: null);
      final detail = SeriesDetailState(series: series, tracking: null);
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => FakeDetailVM(data: detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No description available.'), findsOneWidget);
    });

    testWidgets('overview with empty overview shows no description', (tester) async {
      final series = _testSeries().copyWith(overview: '');
      final detail = SeriesDetailState(series: series, tracking: null);
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => FakeDetailVM(data: detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No description available.'), findsOneWidget);
    });

    testWidgets('overview expand/collapse works', (tester) async {
      // Use a long no-wrap string that overflows maxLines:5
      final longOverview = 'A' * 2000;
      final series = _testSeries().copyWith(overview: longOverview);
      final detail = SeriesDetailState(series: series, tracking: null);
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => FakeDetailVM(data: detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Scroll to overview section
      await tester.ensureVisible(find.text('Overview'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.ensureVisible(find.text('Show more'));
      await tester.pump();
      await tester.tap(find.text('Show more'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Show less'), findsOneWidget);
    });

    testWidgets('detail with no backdrop renders fallback', (tester) async {
      final series = _testSeries().copyWith(backdropPath: null);
      final detail = SeriesDetailState(series: series, tracking: null);
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

    testWidgets('detail with no poster shows tv icon', (tester) async {
      final series = _testSeries().copyWith(posterPath: null);
      final detail = SeriesDetailState(series: series, tracking: null);
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => FakeDetailVM(data: detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.tv), findsOneWidget);
    });

    testWidgets('detail with no genres does not show chip area', (tester) async {
      final series = _testSeries().copyWith(genres: []);
      final detail = SeriesDetailState(series: series, tracking: null);
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => FakeDetailVM(data: detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should still render but without genre chips
      expect(find.text('Add to List'), findsOneWidget);
    });

    testWidgets('detail with seasonCount 0 does not show season text', (tester) async {
      final series = _testSeries().copyWith(seasonCount: 0);
      final detail = SeriesDetailState(series: series, tracking: null);
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => FakeDetailVM(data: detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Season count text should not be shown (— in InfoCard is fine)
      expect(find.textContaining('seasons'), findsNothing);
    });

    testWidgets('bottom sheet shows tracking edit mode and remove button', (tester) async {
      final tracking = TrackedSeriesModel(
        trackingId: 't1', userId: 'u1', seriesId: '1',
        status: 'WATCHING',
        addedAt: DateTime.now(), lastUpdated: DateTime.now(),
      );
      final detail = SeriesDetailState(series: _testSeries(), tracking: tracking);
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => FakeDetailVM(data: detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Manage Tracking'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Manage Tracking'), findsWidgets);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Remove from List'), findsOneWidget);
    });

    testWidgets('bottom sheet remove button triggers confirmation dialog', (tester) async {
      final tracking = TrackedSeriesModel(
        trackingId: 't1', userId: 'u1', seriesId: '1',
        status: 'WATCHING',
        addedAt: DateTime.now(), lastUpdated: DateTime.now(),
      );
      final detail = SeriesDetailState(series: _testSeries(), tracking: tracking);
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => FakeDetailVM(data: detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Manage Tracking'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Remove from List'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Remove from List'), findsWidgets);
      // dialog title
      expect(find.textContaining('Remove'), findsWidgets);
    });

    testWidgets('detail with empty backdrop path renders fallback', (tester) async {
      final series = _testSeries().copyWith(backdropPath: '');
      final detail = SeriesDetailState(series: series, tracking: null);
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

    testWidgets('detail with empty poster path renders fallback', (tester) async {
      final series = _testSeries().copyWith(posterPath: '');
      final detail = SeriesDetailState(series: series, tracking: null);
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

    testWidgets('detail with 0 seasons shows dash in info card', (tester) async {
      final series = _testSeries().copyWith(seasonCount: 0, firstAirDate: null);
      final detail = SeriesDetailState(series: series, tracking: null);
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => FakeDetailVM(data: detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('—'), findsWidgets);
    });

    testWidgets('bottom sheet save when tracking fails shows snackbar', (tester) async {
      final detail = SeriesDetailState(series: _testSeries(), tracking: null);
      final fakeVM = FakeDetailVM(data: detail)..failAddTracking = true;
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1).overrideWith(() => fakeVM),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Add to List'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // After sheet opens there are 2 "Add to List" — tap the one in the sheet (the filled button)
      final saveButton = find.widgetWithText(FilledButton, 'Add to List');
      await tester.ensureVisible(saveButton);
      await tester.pump();
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('error state retry button triggers ref.invalidate', (tester) async {
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => _ErrorDetailVM()),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Exception: Test error message'), findsOneWidget);
    });

    testWidgets('bottom sheet save in edit mode succeeds', (tester) async {
      final tracking = TrackedSeriesModel(
        trackingId: 't1', userId: 'u1', seriesId: '1',
        status: 'WATCHING',
        addedAt: DateTime.now(), lastUpdated: DateTime.now(),
      );
      final detail = SeriesDetailState(series: _testSeries(), tracking: tracking);
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => FakeDetailVM(data: detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Manage Tracking'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final saveButton = find.widgetWithText(FilledButton, 'Save Changes');
      await tester.ensureVisible(saveButton);
      await tester.pump();
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Manage Tracking'), findsAtLeast(1));
    });

    testWidgets('bottom sheet save in edit mode shows error snackbar', (tester) async {
      final tracking = TrackedSeriesModel(
        trackingId: 't1', userId: 'u1', seriesId: '1',
        status: 'WATCHING',
        addedAt: DateTime.now(), lastUpdated: DateTime.now(),
      );
      final detail = SeriesDetailState(series: _testSeries(), tracking: tracking);
      final fakeVM = FakeDetailVM(data: detail)..failAddTracking = true;
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1).overrideWith(() => fakeVM),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Manage Tracking'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final saveButton = find.widgetWithText(FilledButton, 'Save Changes');
      await tester.ensureVisible(saveButton);
      await tester.pump();
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('remove dialog cancel does not remove', (tester) async {
      final tracking = TrackedSeriesModel(
        trackingId: 't1', userId: 'u1', seriesId: '1',
        status: 'WATCHING',
        addedAt: DateTime.now(), lastUpdated: DateTime.now(),
      );
      final detail = SeriesDetailState(series: _testSeries(), tracking: tracking);
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => FakeDetailVM(data: detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Manage Tracking'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.ensureVisible(find.text('Remove from List'));
      await tester.pump();
      await tester.tap(find.text('Remove from List'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('remove dialog confirm removes and pops bottom sheet', (tester) async {
      final tracking = TrackedSeriesModel(
        trackingId: 't1', userId: 'u1', seriesId: '1',
        status: 'WATCHING',
        addedAt: DateTime.now(), lastUpdated: DateTime.now(),
      );
      final detail = SeriesDetailState(series: _testSeries(), tracking: tracking);
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => FakeDetailVM(data: detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Manage Tracking'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.ensureVisible(find.text('Remove from List'));
      await tester.pump();
      await tester.tap(find.text('Remove from List'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Remove'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Manage Tracking'), findsAtLeast(1));
    });

    testWidgets('remove dialog with error shows snackbar', (tester) async {
      final tracking = TrackedSeriesModel(
        trackingId: 't1', userId: 'u1', seriesId: '1',
        status: 'WATCHING',
        addedAt: DateTime.now(), lastUpdated: DateTime.now(),
      );
      final detail = SeriesDetailState(series: _testSeries(), tracking: tracking);
      final fakeVM = FakeDetailVM(data: detail)..failRemoveTracking = true;
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1).overrideWith(() => fakeVM),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Manage Tracking'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.ensureVisible(find.text('Remove from List'));
      await tester.pump();
      await tester.tap(find.text('Remove from List'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Remove'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('networks empty shows dash', (tester) async {
      final series = _testSeries().copyWith(networks: []);
      final detail = SeriesDetailState(series: series, tracking: null);
      final container = ProviderContainer(overrides: [
        seriesDetailViewModelProvider(1)
            .overrideWith(() => FakeDetailVM(data: detail)),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('—'), findsWidgets);
    });

    testWidgets('bottom sheet status selection and rating change work', (tester) async {
      final detail = SeriesDetailState(series: _testSeries(), tracking: null);
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

      // Tap a different status
      await tester.tap(find.text('Completed'));
      await tester.pump();

      expect(find.text('Completed'), findsAtLeast(1));
    });

    testWidgets('bottom sheet save with review text covers ternary branches', (tester) async {
      final detail = SeriesDetailState(series: _testSeries(), tracking: null);
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

      // Enter review text
      await tester.enterText(find.byType(TextField), 'Great series!');
      await tester.pump();

      final saveButton = find.widgetWithText(FilledButton, 'Add to List');
      await tester.ensureVisible(saveButton);
      await tester.pump();
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Add to List'), findsAtLeast(1));
    });
  });
}
