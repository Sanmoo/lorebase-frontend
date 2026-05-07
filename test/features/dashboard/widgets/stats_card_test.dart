import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/dashboard/widgets/stats_card.dart';

void main() {
  group('StatsCard', () {
    testWidgets('shows title, count, and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatsCard(
              title: 'Watching',
              count: 5,
              icon: Icons.play_circle_outline,
              color: Colors.green,
            ),
          ),
        ),
      );
      expect(find.text('Watching'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
    });

    testWidgets('shows zero count correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatsCard(
              title: 'Dropped',
              count: 0,
              icon: Icons.cancel_outlined,
              color: Colors.red,
            ),
          ),
        ),
      );
      expect(find.text('0'), findsOneWidget);
    });
  });
}
