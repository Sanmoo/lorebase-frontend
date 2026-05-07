import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/dashboard/widgets/watching_section.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';

void main() {
  group('DashboardSection', () {
    testWidgets('renders title and series list', (tester) async {
      final series = [
        const SeriesModel(
          tmdbId: 1,
          title: 'Test Show',
          genres: [],
          networks: [],
          seasonCount: 10,
          status: 'Ended',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardSection(
              title: 'Completed',
              series: series,
            ),
          ),
        ),
      );

      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Test Show'), findsOneWidget);
    });

    testWidgets('shows correct title for different sections', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardSection(
              title: 'Dropped',
              series: [],
            ),
          ),
        ),
      );

      expect(find.text('Dropped'), findsOneWidget);
    });
  });
}
