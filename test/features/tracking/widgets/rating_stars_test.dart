import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/widgets/rating_stars.dart';

void main() {
  group('RatingStars', () {
    testWidgets('shows all unfilled stars when rating is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RatingStars(rating: null, maxRating: 5)),
        ),
      );
      // All stars should be star_border (unfilled)
      expect(find.byIcon(Icons.star_border), findsNWidgets(5));
      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('shows 7 filled and 3 unfilled for rating=7 max=10',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RatingStars(rating: 7, maxRating: 10)),
        ),
      );
      expect(find.byIcon(Icons.star), findsNWidgets(7));
      expect(find.byIcon(Icons.star_border), findsNWidgets(3));
    });

    testWidgets('tapping star calls onRatingChanged with correct value',
        (tester) async {
      int? tappedRating;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingStars(
              rating: null,
              maxRating: 5,
              onRatingChanged: (r) => tappedRating = r,
            ),
          ),
        ),
      );
      // Tap the 3rd star (index 2, value 3)
      await tester.tap(find.byIcon(Icons.star_border).at(2));
      expect(tappedRating, 3);
    });

    testWidgets('does not crash when onRatingChanged is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RatingStars(rating: 5, maxRating: 10)),
        ),
      );
      await tester.tap(find.byIcon(Icons.star).first);
      // No assertion needed — reaching here means no crash
    });
  });
}
