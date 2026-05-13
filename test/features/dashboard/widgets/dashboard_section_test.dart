import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/dashboard/widgets/watching_section.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_summary_model.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';

void main() {
  group('DashboardSection', () {
    testWidgets('renders title and series list', (tester) async {
      final items = [
        const TrackedMediaSummaryModel(
          tmdbId: 1,
          title: 'Test Show',
          mediaType: MediaType.series,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardSection(
              title: 'Completed',
              items: items,
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
              items: [],
            ),
          ),
        ),
      );

      expect(find.text('Dropped'), findsOneWidget);
    });
  });
}
