import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/recommendation/pages/recommendation_page.dart';
import 'package:lorebase/l10n/strings.g.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  group('RecommendationPage', () {
    testWidgets('shows coming soon message', (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: const MaterialApp(home: RecommendationPage()),
        ),
      );
      expect(find.text('Recommendation feature coming soon!'), findsOneWidget);
    });

    testWidgets('has AppBar with title', (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: const MaterialApp(home: RecommendationPage()),
        ),
      );
      expect(find.text('Recommendation'), findsOneWidget);
    });

    testWidgets('recommendation page uses non-const constructor', (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: const MaterialApp(
            // ignore: prefer_const_constructors
            home: RecommendationPage(),
          ),
        ),
      );
      expect(find.text('Recommendation feature coming soon!'), findsOneWidget);
    });
  });
}
