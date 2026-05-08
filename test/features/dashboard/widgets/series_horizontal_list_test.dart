import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/dashboard/widgets/series_horizontal_list.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';

SeriesModel _series(int id, String title) => SeriesModel(
      tmdbId: id,
      title: title,
    );

void main() {
  group('SeriesHorizontalList', () {
    testWidgets('empty list does not crash', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SeriesHorizontalList(series: []),
          ),
        ),
      );
      // No crash — test passes by reaching here
    });

    testWidgets('renders with onTap without crashing', (tester) async {
      final series = [_series(1, 'Show A')];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: SeriesHorizontalList(
                series: series,
                onTap: (_) {},
              ),
            ),
          ),
        ),
      );
      // Should not throw — SeriesPoster renders with network image placeholder
    });

    testWidgets('onTap fires when tapping a poster', (tester) async {
      var tappedId = 0;
      final series = [_series(1, 'Show A')];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: SeriesHorizontalList(
                series: series,
                onTap: (s) => tappedId = s.tmdbId,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show A'));
      expect(tappedId, 1);
    });
  });
}
