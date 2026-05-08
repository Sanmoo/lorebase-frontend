import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';
import 'package:lorebase/features/series/widgets/series_card.dart';

void main() {
  group('SeriesCard', () {
    testWidgets('hides season count text when seasonCount is 0', (tester) async {
      const series = SeriesModel(
        tmdbId: 1,
        title: 'Test Series',
        seasonCount: 0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SeriesCard(series: series),
          ),
        ),
      );

      expect(find.textContaining('0 season'), findsNothing);
    });

    testWidgets('shows season count text when seasonCount is greater than 0', (tester) async {
      const series = SeriesModel(
        tmdbId: 1,
        title: 'Test Series',
        seasonCount: 5,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SeriesCard(series: series),
          ),
        ),
      );

      expect(find.textContaining('5 season'), findsOneWidget);
    });

    testWidgets('shows singular season when seasonCount is 1', (tester) async {
      const series = SeriesModel(
        tmdbId: 1,
        title: 'Test Series',
        seasonCount: 1,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SeriesCard(series: series),
          ),
        ),
      );

      expect(find.text('1 season'), findsOneWidget);
    });

    testWidgets('shows genres when provided', (tester) async {
      const series = SeriesModel(
        tmdbId: 1,
        title: 'Test Series',
        genres: ['Drama', 'Sci-Fi'],
        seasonCount: 3,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SeriesCard(series: series),
          ),
        ),
      );

      expect(find.text('Drama, Sci-Fi'), findsOneWidget);
    });

    testWidgets('hides genres when empty', (tester) async {
      const series = SeriesModel(
        tmdbId: 1,
        title: 'Test Series',
        genres: [],
        seasonCount: 3,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SeriesCard(series: series),
          ),
        ),
      );

      expect(find.textContaining('Drama'), findsNothing);
    });

    testWidgets('shows broken image on network error', (tester) async {
      const series = SeriesModel(
        tmdbId: 1,
        title: 'Test Series',
        posterPath: '/bad.jpg',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SeriesCard(series: series),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('shows loading indicator while image loads', (tester) async {
      const series = SeriesModel(
        tmdbId: 1,
        title: 'Test Series',
        posterPath: '/image.jpg',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SeriesCard(series: series),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
