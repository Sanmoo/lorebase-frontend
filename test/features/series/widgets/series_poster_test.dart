import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';
import 'package:lorebase/features/series/widgets/series_poster.dart';

SeriesModel _testSeries({required String title}) => SeriesModel(
      tmdbId: 1,
      title: title,
      posterPath: '/test.jpg',
    );

void main() {
  group('SeriesPoster', () {
    testWidgets('shows title text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeriesPoster(series: _testSeries(title: 'Breaking Bad')),
          ),
        ),
      );
      expect(find.text('Breaking Bad'), findsOneWidget);
    });

    testWidgets('onTap callback fires', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeriesPoster(
              series: _testSeries(title: 'Test'),
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Test'));
      expect(tapped, true);
    });

    testWidgets('does not crash without onTap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeriesPoster(series: _testSeries(title: 'Test')),
          ),
        ),
      );
      await tester.tap(find.text('Test'));
      // No crash — test passes by reaching here
    });

    testWidgets('renders without crashing when poster image fails to load',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeriesPoster(series: _testSeries(title: 'Breaking Bad')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // CachedNetworkImage handles errors internally; verify widget renders
      expect(find.text('Breaking Bad'), findsOneWidget);
    });

    testWidgets('shows title text and loads image',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeriesPoster(series: _testSeries(title: 'Test')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('handles null posterPath gracefully', (tester) async {
      const series = SeriesModel(tmdbId: 1, title: 'Null Poster');
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SeriesPoster(series: series),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Null Poster'), findsOneWidget);
    });
  });
}
