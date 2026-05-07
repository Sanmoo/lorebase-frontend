import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/recommendation/pages/recommendation_page.dart';

void main() {
  group('RecommendationPage', () {
    testWidgets('shows coming soon message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RecommendationPage()),
      );
      expect(find.text('Recommendation feature coming soon!'), findsOneWidget);
    });

    testWidgets('has AppBar with title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RecommendationPage()),
      );
      expect(find.text('Recommendation'), findsOneWidget);
    });
  });
}
