import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/widgets/social_empty_feed.dart';
import 'package:lorebase/l10n/strings.g.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.ptBr);

  testWidgets('renders educational copy and CTA', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: SocialEmptyFeed(onDiscoverTap: () => tapped = true),
          ),
        ),
      ),
    );

    expect(find.text(t.social_empty_feed_title), findsOneWidget);
    expect(find.text(t.social_empty_feed_body), findsOneWidget);
    await tester.tap(find.text(t.social_discover_people_cta));
    expect(tapped, isTrue);
  });
}
