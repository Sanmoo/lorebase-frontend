import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';
import 'package:lorebase/features/series/widgets/series_card.dart';

void main() {
  group('SeriesCard', () {
    testWidgets('hides season count text when seasonCount is 0', (tester) async {
      final series = SeriesModel(
        tmdbId: 1,
        title: 'Test Series',
        seasonCount: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeriesCard(series: series),
          ),
        ),
      );

      expect(find.textContaining('0 season'), findsNothing);
    });

    testWidgets('shows season count text when seasonCount is greater than 0', (tester) async {
      final series = SeriesModel(
        tmdbId: 1,
        title: 'Test Series',
        seasonCount: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeriesCard(series: series),
          ),
        ),
      );

      expect(find.textContaining('5 season'), findsOneWidget);
    });
  });
}
